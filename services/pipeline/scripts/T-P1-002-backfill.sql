-- T-P1-002: Backfill — demote extra primaries to alias
-- Direction C (hybrid): write-side primary demotion
--
-- Rule cascade for choosing which primary to keep:
--   (a) slug-rooted: person.slug unicode reverse matches name → keep
--   (b) pinyin slug can't reverse → fall through to (c)
--   (c) char_length(name) ASC — shortest name wins
--   (d) created_at ASC — tiebreaker
--
-- All demoted primaries become 'alias'.
-- Idempotent: re-running when no multi-primary exists → 0 rows affected.
--
-- Usage:
--   psql -h localhost -p 5433 -U huadian -d huadian -f T-P1-002-backfill.sql

BEGIN;

-- Step 1: Identify persons with multiple primaries
WITH multi_primary_persons AS (
  SELECT person_id
  FROM person_names
  WHERE name_type = 'primary'
  GROUP BY person_id
  HAVING count(*) > 1
),

-- Step 2: For each person, compute the slug-derived name (unicode slugs only)
person_slug_name AS (
  SELECT
    p.id AS person_id,
    p.slug,
    CASE
      WHEN p.slug ~ '^u[0-9a-f]{4}(-u[0-9a-f]{4})*$' THEN
        (SELECT string_agg(
           chr(('x' || lpad(substring(part FROM 2), 8, '0'))::bit(32)::int),
           '' ORDER BY ord
         )
         FROM unnest(string_to_array(p.slug, '-')) WITH ORDINALITY AS t(part, ord))
      ELSE NULL  -- pinyin slug, cannot reverse
    END AS slug_derived_name
  FROM persons p
  WHERE p.id IN (SELECT person_id FROM multi_primary_persons)
),

-- Step 3: Rank primaries per person — winner (rn=1) keeps primary, rest demoted
ranked_primaries AS (
  SELECT
    pn.id AS pn_id,
    pn.person_id,
    pn.name,
    psn.slug_derived_name,
    ROW_NUMBER() OVER (
      PARTITION BY pn.person_id
      ORDER BY
        -- (a) slug-rooted match: 0 = match, 1 = no match
        CASE WHEN psn.slug_derived_name IS NOT NULL
              AND pn.name = psn.slug_derived_name THEN 0 ELSE 1 END,
        -- (c) shortest name first (pinyin fallback)
        char_length(pn.name),
        -- (d) earliest created_at
        pn.created_at
    ) AS rn
  FROM person_names pn
  JOIN person_slug_name psn ON psn.person_id = pn.person_id
  WHERE pn.name_type = 'primary'
    AND pn.person_id IN (SELECT person_id FROM multi_primary_persons)
)

-- Step 4: Demote all non-winner primaries to alias
UPDATE person_names
SET name_type = 'alias'
FROM ranked_primaries rp
WHERE person_names.id = rp.pn_id
  AND rp.rn > 1;

-- Verify: no person should have >1 primary after backfill
DO $$
DECLARE
  violation_count int;
BEGIN
  SELECT count(*) INTO violation_count
  FROM (
    SELECT person_id
    FROM person_names
    WHERE name_type = 'primary'
    GROUP BY person_id
    HAVING count(*) > 1
  ) sub;

  IF violation_count > 0 THEN
    RAISE EXCEPTION 'BACKFILL VERIFICATION FAILED: % persons still have >1 primary', violation_count;
  END IF;

  RAISE NOTICE 'BACKFILL VERIFIED: 0 persons with >1 primary';
END $$;

COMMIT;
