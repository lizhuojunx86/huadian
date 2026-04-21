"""Wikidata SPARQL adapter for seed dictionary loading.

Handles:
- SPARQL query construction (batch label match, single altLabel match)
- HTTP transport with rate limiting + exponential backoff retry
- Response parsing into typed dataclasses

ADR: ADR-021 §2.1
"""

from __future__ import annotations

import asyncio
import json
import logging
from dataclasses import dataclass, field

import httpx

logger = logging.getLogger(__name__)

WIKIDATA_ENDPOINT = "https://query.wikidata.org/sparql"
DEFAULT_USER_AGENT = (
    "HuaDian-Loader/0.1 (https://github.com/lizhuojunx86/huadian; T-P0-025) httpx/0.28"
)
DEFAULT_RATE_LIMIT = 1.1  # seconds between requests (>1 per Wikidata policy)
DEFAULT_TIMEOUT = 30.0
MAX_RETRIES = 3


@dataclass(frozen=True)
class WikidataHit:
    """A single Wikidata entity match."""

    qid: str
    label_zh: str
    description_zh: str = ""


@dataclass
class SparqlResult:
    """Result of a SPARQL query batch."""

    hits_by_name: dict[str, list[WikidataHit]] = field(default_factory=dict)
    http_requests: int = 0
    errors: int = 0


def build_label_batch_query(names: list[str]) -> str:
    """Build Round 1 SPARQL: exact zh label match, instance of human.

    Uses VALUES clause for batched matching.
    """
    values = " ".join(f'"{n}"@zh' for n in names)
    return f"""
SELECT ?item ?itemLabel ?name ?description WHERE {{
  VALUES ?name {{ {values} }}
  ?item rdfs:label ?name ;
        wdt:P31 wd:Q5 .
  OPTIONAL {{ ?item schema:description ?description .
              FILTER(LANG(?description) = "zh") }}
  SERVICE wikibase:label {{ bd:serviceParam wikibase:language "zh,en" }}
}}
"""


def build_altlabel_query(alias: str) -> str:
    """Build Round 2/3 SPARQL: altLabel or label match for a single name."""
    return f"""
SELECT ?item ?itemLabel ?description WHERE {{
  {{
    ?item skos:altLabel "{alias}"@zh ;
          wdt:P31 wd:Q5 .
  }} UNION {{
    ?item rdfs:label "{alias}"@zh ;
          wdt:P31 wd:Q5 .
  }}
  OPTIONAL {{ ?item schema:description ?description .
              FILTER(LANG(?description) = "zh") }}
  SERVICE wikibase:label {{ bd:serviceParam wikibase:language "zh,en" }}
}}
LIMIT 5
"""


def parse_qid(uri: str) -> str:
    """Extract Q-number from Wikidata URI."""
    return uri.rsplit("/", 1)[-1] if "/" in uri else uri


def parse_bindings(bindings: list[dict]) -> dict[str, list[WikidataHit]]:
    """Group SPARQL bindings by matched name text → deduplicated hits."""
    by_name: dict[str, list[WikidataHit]] = {}
    for b in bindings:
        # For batch queries, 'name' holds the VALUES variable;
        # for single queries, fall back to itemLabel
        name_val = b.get("name", {}).get("value", "")
        if not name_val:
            name_val = b.get("itemLabel", {}).get("value", "")
        qid = parse_qid(b.get("item", {}).get("value", ""))
        label = b.get("itemLabel", {}).get("value", "")
        desc = b.get("description", {}).get("value", "")

        if name_val not in by_name:
            by_name[name_val] = []
        # Deduplicate by QID within same name
        if not any(h.qid == qid for h in by_name[name_val]):
            by_name[name_val].append(WikidataHit(qid=qid, label_zh=label, description_zh=desc))
    return by_name


class WikidataAdapter:
    """Async SPARQL client for Wikidata with rate limiting and retry."""

    def __init__(
        self,
        *,
        user_agent: str = DEFAULT_USER_AGENT,
        rate_limit: float = DEFAULT_RATE_LIMIT,
        timeout: float = DEFAULT_TIMEOUT,
    ) -> None:
        self._user_agent = user_agent
        self._rate_limit = rate_limit
        self._timeout = timeout
        self._client: httpx.AsyncClient | None = None
        self._total_requests = 0
        self._total_errors = 0

    async def __aenter__(self) -> WikidataAdapter:
        self._client = httpx.AsyncClient(
            headers={
                "User-Agent": self._user_agent,
                "Accept": "application/sparql-results+json",
            },
        )
        return self

    async def __aexit__(self, *args: object) -> None:
        if self._client:
            await self._client.aclose()
            self._client = None

    @property
    def total_requests(self) -> int:
        return self._total_requests

    @property
    def total_errors(self) -> int:
        return self._total_errors

    async def query_sparql(self, sparql: str, *, _retry: int = 0) -> list[dict]:
        """Execute a SPARQL query with retry + rate limit."""
        assert self._client is not None, "Use as async context manager"

        self._total_requests += 1
        try:
            resp = await self._client.get(
                WIKIDATA_ENDPOINT,
                params={"query": sparql, "format": "json"},
                timeout=self._timeout,
            )
            if resp.status_code == 429:
                wait = 2 ** (_retry + 1)
                logger.warning("429 Too Many Requests, backing off %ds", wait)
                await asyncio.sleep(wait)
                if _retry < MAX_RETRIES:
                    return await self.query_sparql(sparql, _retry=_retry + 1)
                self._total_errors += 1
                return []
            resp.raise_for_status()
            data = resp.json()
            return data.get("results", {}).get("bindings", [])
        except (httpx.HTTPError, json.JSONDecodeError, KeyError) as e:
            if _retry < MAX_RETRIES:
                wait = 2**_retry
                logger.warning("SPARQL error (%s), retry %d in %ds", e, _retry + 1, wait)
                await asyncio.sleep(wait)
                return await self.query_sparql(sparql, _retry=_retry + 1)
            self._total_errors += 1
            logger.error("SPARQL failed after %d retries: %s", MAX_RETRIES, e)
            return []

    async def batch_label_match(self, names: list[str]) -> SparqlResult:
        """Run Round 1 batch label match. Returns hits grouped by name."""
        result = SparqlResult()
        sparql = build_label_batch_query(names)
        bindings = await self.query_sparql(sparql)
        result.http_requests = 1

        if not bindings and len(names) > 1:
            # Batch might have timed out; fall back to individual queries
            logger.warning(
                "Batch returned 0 bindings for %d names, falling back to individual", len(names)
            )
            for name in names:
                individual_sparql = build_label_batch_query([name])
                individual_bindings = await self.query_sparql(individual_sparql)
                result.http_requests += 1
                hits = parse_bindings(individual_bindings)
                result.hits_by_name.update(hits)
                await asyncio.sleep(self._rate_limit)
        else:
            result.hits_by_name = parse_bindings(bindings)

        return result

    async def single_altlabel_match(self, name: str) -> list[WikidataHit]:
        """Run Round 2/3 altLabel + label match for a single name."""
        sparql = build_altlabel_query(name)
        bindings = await self.query_sparql(sparql)
        hits: list[WikidataHit] = []
        for b in bindings:
            qid = parse_qid(b.get("item", {}).get("value", ""))
            label = b.get("itemLabel", {}).get("value", "")
            desc = b.get("description", {}).get("value", "")
            if not any(h.qid == qid for h in hits):
                hits.append(WikidataHit(qid=qid, label_zh=label, description_zh=desc))
        return hits

    async def throttle(self) -> None:
        """Wait for rate limit interval."""
        await asyncio.sleep(self._rate_limit)
