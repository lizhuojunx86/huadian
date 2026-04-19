-- T-P0-020: Enforce persons.merged_into_id → deleted_at pairing
-- See ADR-014 §7 & debts/T-P0-006-beta-followups.md F3/F4
--
-- Constraint semantics: merged_into_id IS NOT NULL → deleted_at IS NOT NULL
-- Allows:
--   (deleted_at=NULL, merged_into_id=NULL)     - active person
--   (deleted_at≠NULL, merged_into_id=NULL)     - pure soft-delete (T-P0-014 R3-non-person)
--   (deleted_at≠NULL, merged_into_id≠NULL)     - merge soft-delete (apply_merges normal path)
-- Rejects:
--   (deleted_at=NULL, merged_into_id≠NULL)     - F3 violation (merged but not deleted)
-- Contrapositive: deleted_at=NULL → merged_into_id=NULL ensures unified "active" definition

ALTER TABLE persons ADD CONSTRAINT persons_merge_requires_delete
  CHECK (merged_into_id IS NULL OR deleted_at IS NOT NULL);
