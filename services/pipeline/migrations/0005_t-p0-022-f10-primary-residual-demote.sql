-- T-P0-022: Demote merge source's undemoted primary name rows to alias
-- See ADR-014 §7 & debts/T-P0-006-beta-followups.md F10

BEGIN;

UPDATE person_names
SET name_type = 'alias'
WHERE person_id IN (
  SELECT id FROM persons
  WHERE deleted_at IS NOT NULL
    AND merged_into_id IS NOT NULL
)
AND name_type = 'primary'
RETURNING id, person_id, name, name_type, is_primary;

COMMIT;
