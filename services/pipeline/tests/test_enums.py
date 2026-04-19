"""Guard tests for Python domain enums — must match PG enum definitions."""

from huadian_pipeline.enums import ProvenanceTier


def test_provenance_tier_values_match_db_schema():
    """All ProvenanceTier values must exactly match PG enum `provenance_tier`.

    If this test fails after adding a new value to ProvenanceTier,
    ensure the corresponding SQL migration has been created (ALTER TYPE
    provenance_tier ADD VALUE '...') and Drizzle enums.ts is updated.
    """
    expected = {
        "primary_text",
        "scholarly_consensus",
        "ai_inferred",
        "crowdsourced",
        "unverified",
    }
    assert {t.value for t in ProvenanceTier} == expected


def test_provenance_tier_is_str_enum():
    """ProvenanceTier members can be used as plain strings (asyncpg compat)."""
    assert ProvenanceTier.AI_INFERRED == "ai_inferred"
    assert ProvenanceTier.AI_INFERRED.value == "ai_inferred"
    assert isinstance(ProvenanceTier.PRIMARY_TEXT, str)
