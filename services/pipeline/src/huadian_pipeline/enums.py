"""Domain enums mirroring PostgreSQL enum types.

Values must match the DB enum definitions exactly (string representation).
"""

from enum import StrEnum


class ProvenanceTier(StrEnum):
    """Mirrors PG enum `provenance_tier`. See migrations/0000_*.sql.

    Stage 1 of ADR-015 uses AI_INFERRED for NER-derived evidence;
    SEED_DICTIONARY will be added in T-P0-023 Stage 1d alongside
    the SQL migration that extends the PG enum.
    """

    PRIMARY_TEXT = "primary_text"
    SCHOLARLY_CONSENSUS = "scholarly_consensus"
    AI_INFERRED = "ai_inferred"
    CROWDSOURCED = "crowdsourced"
    UNVERIFIED = "unverified"
    SEED_DICTIONARY = "seed_dictionary"
