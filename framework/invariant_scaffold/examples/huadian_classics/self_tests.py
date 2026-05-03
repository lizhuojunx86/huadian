"""HuaDian invariant self-tests — verify each invariant catches injected violations.

Each self-test:
    1. Inject a row that should violate the target invariant
    2. (SelfTestRunner runs the invariant + checks for caught violation)
    3. Always rolls back via _RollbackSentinel — no DB pollution

Source: services/pipeline/tests/test_invariants_v*.py self-tests.
"""

from __future__ import annotations

import uuid

from framework.invariant_scaffold import DBPort, Violation


def _make_test_person_sql() -> tuple[str, list]:
    """Return (sql, args) for inserting a test person — caller binds person_id."""
    return (
        """INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier)
           VALUES ($1, $2, $3::jsonb, '上古', 'legendary', 'primary_text')""",
        [],  # caller fills (person_id, slug, name_json)
    )


# ---------------------------------------------------------------------------
# V9 self-test
# ---------------------------------------------------------------------------


class V9MissingPrimarySelfTest:
    """Inject a person with zero is_primary=true names → V9 catches."""

    name = "v9_missing_primary"
    invariant_name = "V9"

    def __init__(self) -> None:
        self._injected_id: str | None = None

    async def setup_violation(self, port: DBPort) -> None:
        person_id = str(uuid.uuid4())
        self._injected_id = person_id
        slug = f"test-v9-{person_id.split('-')[0]}"
        await port.execute(
            """INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier)
               VALUES ($1::uuid, $2, '{"zh-Hans": "test-v9"}'::jsonb, '上古', 'legendary',
                       'primary_text')""",
            person_id,
            slug,
        )
        # is_primary=false → V9 should flag this person
        await port.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1::uuid, '测试人物', 'alias', false)""",
            person_id,
        )

    def expected_violation_predicate(self, violation: Violation) -> bool:
        if self._injected_id is None:
            return False
        return violation.row_data.get("id") == self._injected_id


# ---------------------------------------------------------------------------
# V10.a self-test (orphan target — mapping → merged person)
# ---------------------------------------------------------------------------


class V10AOrphanTargetSelfTest:
    """Inject mapping pointing to a soft-merged person → V10.a catches.

    V10.a returns count_only — we cannot match an injected ID to the
    aggregated count. Instead we check that count > 0 (was 0 pre-injection).
    """

    name = "v10a_orphan_target"
    invariant_name = "V10.a"

    async def setup_violation(self, port: DBPort) -> None:
        dead = str(uuid.uuid4())
        live = str(uuid.uuid4())
        for pid, slug in [
            (dead, f"v10-dead-{dead.split('-')[0]}"),
            (live, f"v10-live-{live.split('-')[0]}"),
        ]:
            await port.execute(
                """INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier)
                   VALUES ($1::uuid, $2, '{"zh-Hans": "test-v10a"}'::jsonb, '上古',
                           'legendary', 'primary_text')""",
                pid,
                slug,
            )
            await port.execute(
                """INSERT INTO person_names (person_id, name, name_type, is_primary)
                   VALUES ($1::uuid, $2, 'primary', true)""",
                pid,
                f"test-{slug}",
            )
        # Soft-merge dead → live
        await port.execute(
            "UPDATE persons SET deleted_at = now(), merged_into_id = $1::uuid WHERE id = $2::uuid",
            live,
            dead,
        )
        # Create seed infra
        source_id = await port.fetchval(
            """INSERT INTO dictionary_sources (source_name, source_version, license, commercial_safe)
               VALUES ('test-v10a-st', 'v0', 'CC0', true)
               ON CONFLICT (source_name, source_version)
                 DO UPDATE SET source_name = 'test-v10a-st'
               RETURNING id"""
        )
        entry_id = await port.fetchval(
            """INSERT INTO dictionary_entries (source_id, external_id, entry_type,
                                                primary_name, attributes)
               VALUES ($1, 'Q_V10A_ST', 'person', 'orphan-st', '{}'::jsonb)
               ON CONFLICT (source_id, external_id)
                 DO UPDATE SET source_id = dictionary_entries.source_id
               RETURNING id""",
            source_id,
        )
        # Active mapping → dead person → V10.a violation
        await port.execute(
            """INSERT INTO seed_mappings (dictionary_entry_id, target_entity_type,
                                           target_entity_id, confidence, mapping_method,
                                           mapping_status)
               VALUES ($1, 'person', $2::uuid, 0.90, 'test', 'active')""",
            entry_id,
            dead,
        )

    def expected_violation_predicate(self, violation: Violation) -> bool:
        # V10.a is count_only; we accept if the count went from 0 to >= 1.
        # Since the bootstrap state is 0, any violation row from this run
        # is the injected one.
        return violation.row_data.get("count", 0) >= 1


# ---------------------------------------------------------------------------
# V11 self-test (duplicate active mappings)
# ---------------------------------------------------------------------------


class V11DuplicateMappingSelfTest:
    """Inject 2 active mappings for same person → V11 catches."""

    name = "v11_duplicate_mapping"
    invariant_name = "V11"

    async def setup_violation(self, port: DBPort) -> None:
        person_id = str(uuid.uuid4())
        slug = f"v11-{person_id.split('-')[0]}"
        await port.execute(
            """INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier)
               VALUES ($1::uuid, $2, '{"zh-Hans": "test-v11"}'::jsonb, '上古',
                       'legendary', 'primary_text')""",
            person_id,
            slug,
        )
        await port.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1::uuid, $2, 'primary', true)""",
            person_id,
            f"test-{slug}",
        )
        source_id = await port.fetchval(
            """INSERT INTO dictionary_sources (source_name, source_version, license,
                                                commercial_safe)
               VALUES ('test-v11-st', 'v0', 'CC0', true)
               ON CONFLICT (source_name, source_version)
                 DO UPDATE SET source_name = 'test-v11-st'
               RETURNING id"""
        )
        for qid in ("Q_V11_A", "Q_V11_B"):
            entry_id = await port.fetchval(
                """INSERT INTO dictionary_entries (source_id, external_id, entry_type,
                                                    primary_name, attributes)
                   VALUES ($1, $2, 'person', 'dup-st', '{}'::jsonb)
                   ON CONFLICT (source_id, external_id)
                     DO UPDATE SET source_id = dictionary_entries.source_id
                   RETURNING id""",
                source_id,
                qid,
            )
            await port.execute(
                """INSERT INTO seed_mappings (dictionary_entry_id, target_entity_type,
                                               target_entity_id, confidence, mapping_method,
                                               mapping_status)
                   VALUES ($1, 'person', $2::uuid, 0.90, 'test', 'active')""",
                entry_id,
                person_id,
            )

    def expected_violation_predicate(self, violation: Violation) -> bool:
        return violation.row_data.get("count", 0) >= 1


# ---------------------------------------------------------------------------
# V8 self-test (single-char prefix collision)
# ---------------------------------------------------------------------------


class V8PrefixCollisionSelfTest:
    """Inject single-char '甲' (nickname, no evidence) on person A and '甲骨' on person B.

    V8 should detect the collision (single-char + unexempted prefix of longer name).
    """

    name = "v8_prefix_collision"
    invariant_name = "V8"

    def __init__(self) -> None:
        self._injected_short_slug: str | None = None

    async def setup_violation(self, port: DBPort) -> None:
        person_a = str(uuid.uuid4())
        person_b = str(uuid.uuid4())
        slug_a = f"test-v8-a-{person_a.split('-')[0]}"
        slug_b = f"test-v8-b-{person_b.split('-')[0]}"
        self._injected_short_slug = slug_a
        for pid, slug in [(person_a, slug_a), (person_b, slug_b)]:
            await port.execute(
                """INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier)
                   VALUES ($1::uuid, $2, '{"zh-Hans": "test-v8"}'::jsonb, '上古',
                           'legendary', 'primary_text')""",
                pid,
                slug,
            )
        # Person A: single-char '甲' (nickname, no source_evidence) — unexempted
        await port.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1::uuid, '甲', 'nickname', true)""",
            person_a,
        )
        # Person B: '甲骨' — creates prefix collision
        await port.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1::uuid, '甲骨', 'primary', true)""",
            person_b,
        )

    def expected_violation_predicate(self, violation: Violation) -> bool:
        if self._injected_short_slug is None:
            return False
        return violation.row_data.get("short_slug") == self._injected_short_slug


# ---------------------------------------------------------------------------
# Aggregate factory
# ---------------------------------------------------------------------------


def make_huadian_self_tests() -> list:
    """Return all HuaDian self-tests as a list (for SelfTestRunner.verify_all)."""
    return [
        V9MissingPrimarySelfTest(),
        V10AOrphanTargetSelfTest(),
        V11DuplicateMappingSelfTest(),
        V8PrefixCollisionSelfTest(),
    ]
