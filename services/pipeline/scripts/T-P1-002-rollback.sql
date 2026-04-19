-- T-P1-002: Rollback — reverse primary demotion + drop UNIQUE constraint
--
-- WARNING: This only reverses the UNIQUE constraint and provides guidance
-- for reversing the primary demotion. The exact original name_types are
-- not preserved (we only know they were 'primary' before demotion).
--
-- Usage:
--   psql -h localhost -p 5433 -U huadian -d huadian -f T-P1-002-rollback.sql

BEGIN;

-- Step 1: Drop UNIQUE constraint (if exists)
DROP INDEX IF EXISTS "uq_person_names_person_name";

-- Step 2: Restore demoted primaries
-- For persons that currently have exactly 1 primary and aliases that were
-- likely demoted (alias names that match common multi-name patterns),
-- we can reverse by looking at historical patterns. However, automatic
-- reversal is risky — manual review recommended.
--
-- To identify which names were demoted, check the git diff of this commit
-- or use the backfill dry-run output.

RAISE NOTICE 'UNIQUE constraint dropped. Primary demotion reversal requires manual review.';
RAISE NOTICE 'To find which names were originally primary, check the commit diff or re-run the backfill dry-run query.';

COMMIT;
