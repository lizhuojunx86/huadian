"""Sprint F Stage 4: v1-r5 dry-run verification on 5 秦本纪 segments.

Runs NER v1-r5 prompt on selected paragraphs and checks auto-promotion count.
Does NOT write to the database (dry-run only).

Usage:
  cd services/pipeline
  DATABASE_URL=... uv run python scripts/v1r5_dryrun.py
"""

from __future__ import annotations

import asyncio
import logging
import os
import sys

logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
logger = logging.getLogger(__name__)

# Paragraphs to test (秦本纪 segments with 官衔+名 patterns)
TARGET_PARAGRAPHS = [54, 62, 64, 66, 65]


async def main():
    import asyncpg

    from huadian_pipeline.ai.anthropic_provider import AnthropicGateway
    from huadian_pipeline.extract import _parse_response
    from huadian_pipeline.load import (
        MergedPerson,
        _enforce_single_primary,
        _filter_pronoun_surfaces,
    )
    from huadian_pipeline.prompts.loader import load_prompt
    from huadian_pipeline.qc.adapter import TraceGuardAdapter

    db_url = os.environ.get("DATABASE_URL")
    if not db_url:
        print("ERROR: DATABASE_URL not set")
        sys.exit(1)

    # Load v1-r5 prompt
    prompt = load_prompt("ner", "v1-r5")
    logger.info("Loaded prompt: %s/%s", prompt.prompt_id, prompt.version)

    # Connect to DB and fetch target paragraphs
    conn = await asyncpg.connect(db_url)
    try:
        rows = await conn.fetch(
            """
            SELECT rt.id, rt.paragraph_no, rt.raw_text
            FROM raw_texts rt
            JOIN books b ON b.id = rt.book_id
            WHERE b.title->>'zh-Hans' LIKE '%秦本纪%'
              AND rt.deleted_at IS NULL
              AND rt.paragraph_no = ANY($1)
            ORDER BY rt.paragraph_no
            """,
            TARGET_PARAGRAPHS,
        )
    finally:
        await conn.close()

    if not rows:
        print("ERROR: No paragraphs found")
        sys.exit(1)

    logger.info("Found %d paragraphs: %s", len(rows), [r["paragraph_no"] for r in rows])

    # Create gateway with TraceGuard in shadow mode (dry-run, no DB writes)
    tg = TraceGuardAdapter(mode="shadow")
    gateway = AnthropicGateway(tg=tg)

    total_cost = 0.0
    total_persons = 0
    auto_promotion_count = 0
    critical_promotions = []

    for row in rows:
        pno = row["paragraph_no"]
        raw_text = row["raw_text"]
        chunk_id = str(row["id"])

        # Truncate very long paragraphs for cost control
        if len(raw_text) > 800:
            logger.info(
                "  §%d: truncating from %d to 800 chars for cost control", pno, len(raw_text)
            )
            raw_text = raw_text[:800]

        logger.info("  §%d: extracting (%d chars)...", pno, len(raw_text))

        try:
            response = await gateway.call(
                prompt,
                raw_text,
                metadata={"paragraph_no": pno, "task": "ner-v1r5-dryrun"},
            )
        except Exception as e:
            logger.error("  §%d: LLM error: %s", pno, e)
            continue

        total_cost += response.cost_usd
        logger.info(
            "  §%d: $%.4f (%d+%d tokens)",
            pno,
            response.cost_usd,
            response.input_tokens,
            response.output_tokens,
        )

        # Parse response
        persons = _parse_response(response.content, pno, chunk_id)
        total_persons += len(persons)

        # Check auto-promotion for each person
        for p in persons:
            merged = MergedPerson(
                name_zh=p.name_zh,
                slug=f"dryrun-{p.name_zh}",
                surface_forms=list(p.surface_forms),
                dynasty=p.dynasty,
                reality_status=p.reality_status,
                briefs=[p.brief] if p.brief else [],
                identity_notes=[p.identity_notes] if p.identity_notes else [],
                confidence=p.confidence,
                chunk_ids=[chunk_id],
                paragraph_nos=[pno],
            )

            filtered = _filter_pronoun_surfaces(merged)
            if not filtered:
                continue

            merged.surface_forms = filtered
            validated = _enforce_single_primary(merged)

            # Check if auto-promotion happened (0 primaries → promoted)
            primaries = [sf for sf in p.surface_forms if sf.name_type == "primary"]
            if len(primaries) == 0:
                auto_promotion_count += 1
                promoted = next((sf for sf in validated if sf.name_type == "primary"), None)
                is_critical = promoted and promoted.text != p.name_zh
                if is_critical:
                    critical_promotions.append(f"§{pno} {p.name_zh} → promoted {promoted.text}")
                    logger.warning("  CRITICAL auto-promotion: %s → %s", p.name_zh, promoted.text)

            # Check name_zh vs surface_forms alignment
            name_zh_in_forms = any(sf.text == p.name_zh for sf in validated)
            if not name_zh_in_forms:
                logger.info(
                    "  §%d person %s: name_zh not in surface_forms (will be canonical primary)",
                    pno,
                    p.name_zh,
                )

    # Summary
    print("\n" + "=" * 60)
    print("v1-r5 Dry-Run Summary")
    print("=" * 60)
    print(f"Paragraphs tested: {len(rows)}")
    print(f"Total persons extracted: {total_persons}")
    print(f"Total LLM cost: ${total_cost:.4f}")
    print(f"Auto-promotions: {auto_promotion_count}")
    print(f"CRITICAL auto-promotions: {len(critical_promotions)}")
    for cp in critical_promotions:
        print(f"  - {cp}")
    print("\nTarget: CRITICAL ≤ 2 (was 6 with v1-r4)")
    print(f"Result: {'PASS' if len(critical_promotions) <= 2 else 'FAIL'}")
    print(f"Cost check: {'PASS' if total_cost <= 0.30 else 'FAIL'} (${total_cost:.4f} / $0.30)")


if __name__ == "__main__":
    asyncio.run(main())
