-- T-P0-023 Stage 1d: Extend provenance_tier enum with seed_dictionary.
-- Reserved for future dictionary loader (T-P0-024) that will ingest
-- data/dictionaries/persons.seed.json into person_names.
--
-- Forward-only: PostgreSQL does not support DROP VALUE. A rollback
-- would require recreating the enum type (dump + swap + drop).
-- See ADR-017 (forward-only migrations) and ADR-015 (evidence chain).
--
-- NOTE: ALTER TYPE ... ADD VALUE cannot run inside a transaction block
-- (PostgreSQL limitation). Do NOT wrap in BEGIN/COMMIT.

ALTER TYPE provenance_tier ADD VALUE IF NOT EXISTS 'seed_dictionary';
