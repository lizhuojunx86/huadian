-- ============================================================
-- Sprint T T-V03-FW-005 — framework dogfood seed fixtures
-- ============================================================
--
-- Run by docker-entrypoint-initdb.d AFTER bootstrap.sql.
--
-- Goal: enough rows to make framework dogfood scripts return
--       non-trivial results when pointed at this DB.
--
-- Volumetrics:
--   5 persons (周成王 / 楚成王 / 项羽 / 刘邦 / 张良)
--   8 person_names (each person 1-2 names)
--   1 dictionary_source ("Wikidata-stub")
--   3 dictionary_entries (mapping to 3 of the persons)
--   3 seed_mappings (mapping_status='pending_review')
--   3 pending_merge_reviews (status='pending', diverse surfaces)
--   5 triage_decisions (across 3 surfaces, multi-row audit per source)
--
-- Determinism:
--   All UUIDs are hard-coded so re-running gives same IDs.
--   Use shape `00000000-0000-4xxx-8xxx-NNNNNNNNNNNN` (UUID v4).
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- persons (5 rows)
-- ────────────────────────────────────────────────────────────

INSERT INTO persons (id, slug, name, merged_into_id, deleted_at) VALUES
    ('00000000-0000-4000-8000-000000000001', 'zhou-cheng-wang',
     '{"zh-Hans": "周成王", "en": "King Cheng of Zhou"}'::jsonb, NULL, NULL),
    ('00000000-0000-4000-8000-000000000002', 'chu-cheng-wang',
     '{"zh-Hans": "楚成王", "en": "King Cheng of Chu"}'::jsonb, NULL, NULL),
    ('00000000-0000-4000-8000-000000000003', 'xiang-yu',
     '{"zh-Hans": "项羽", "en": "Xiang Yu"}'::jsonb, NULL, NULL),
    ('00000000-0000-4000-8000-000000000004', 'liu-bang',
     '{"zh-Hans": "刘邦", "en": "Liu Bang"}'::jsonb, NULL, NULL),
    ('00000000-0000-4000-8000-000000000005', 'zhang-liang',
     '{"zh-Hans": "张良", "en": "Zhang Liang"}'::jsonb, NULL, NULL);

-- ────────────────────────────────────────────────────────────
-- person_names (8 rows)
-- ────────────────────────────────────────────────────────────

INSERT INTO person_names (id, person_id, name, is_primary, created_at) VALUES
    ('10000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000001', '周成王', true,  '2026-04-01T10:00:00Z'),
    ('10000000-0000-4000-8000-000000000002', '00000000-0000-4000-8000-000000000001', '姬诵',   false, '2026-04-01T10:01:00Z'),
    ('10000000-0000-4000-8000-000000000003', '00000000-0000-4000-8000-000000000002', '楚成王', true,  '2026-04-01T10:02:00Z'),
    ('10000000-0000-4000-8000-000000000004', '00000000-0000-4000-8000-000000000003', '项羽',   true,  '2026-04-01T10:03:00Z'),
    ('10000000-0000-4000-8000-000000000005', '00000000-0000-4000-8000-000000000003', '项籍',   false, '2026-04-01T10:04:00Z'),
    ('10000000-0000-4000-8000-000000000006', '00000000-0000-4000-8000-000000000004', '刘邦',   true,  '2026-04-01T10:05:00Z'),
    ('10000000-0000-4000-8000-000000000007', '00000000-0000-4000-8000-000000000004', '刘季',   false, '2026-04-01T10:06:00Z'),
    ('10000000-0000-4000-8000-000000000008', '00000000-0000-4000-8000-000000000005', '张良',   true,  '2026-04-01T10:07:00Z');

-- ────────────────────────────────────────────────────────────
-- dictionary_sources (1 row)
-- ────────────────────────────────────────────────────────────

INSERT INTO dictionary_sources (id, source_name, source_version, license, commercial_safe) VALUES
    ('20000000-0000-4000-8000-000000000001', 'Wikidata-stub', '2026.04', 'CC0', true);

-- ────────────────────────────────────────────────────────────
-- dictionary_entries (3 rows)
-- ────────────────────────────────────────────────────────────

INSERT INTO dictionary_entries (id, source_id, external_id, entry_type, primary_name, aliases, attributes) VALUES
    ('30000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001',
     'Q727636', 'person', '周成王', '["姬诵"]'::jsonb, '{"dynasty": "周"}'::jsonb),
    ('30000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000001',
     'Q726512', 'person', '楚成王', '["熊恽"]'::jsonb, '{"dynasty": "楚"}'::jsonb),
    ('30000000-0000-4000-8000-000000000003', '20000000-0000-4000-8000-000000000001',
     'Q9683',   'person', '项羽',   '["项籍"]'::jsonb, '{"dynasty": "秦末"}'::jsonb);

-- ────────────────────────────────────────────────────────────
-- seed_mappings (3 rows / all pending_review)
-- ────────────────────────────────────────────────────────────

INSERT INTO seed_mappings (id, target_entity_id, target_entity_type, dictionary_entry_id,
                            mapping_status, mapping_method, confidence, notes,
                            mapping_created_at) VALUES
    ('40000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000001', 'person',
     '30000000-0000-4000-8000-000000000001', 'pending_review', 'wikidata-seed-match', 0.92,
     '{"reason": "primary_name match"}'::jsonb, '2026-04-15T08:00:00Z'),
    ('40000000-0000-4000-8000-000000000002', '00000000-0000-4000-8000-000000000002', 'person',
     '30000000-0000-4000-8000-000000000002', 'pending_review', 'wikidata-seed-match', 0.88,
     '{"reason": "primary_name match"}'::jsonb, '2026-04-16T08:00:00Z'),
    ('40000000-0000-4000-8000-000000000003', '00000000-0000-4000-8000-000000000003', 'person',
     '30000000-0000-4000-8000-000000000003', 'pending_review', 'wikidata-seed-match', 0.95,
     '{"reason": "primary_name + alias match"}'::jsonb, '2026-04-17T08:00:00Z');

-- ────────────────────────────────────────────────────────────
-- pending_merge_reviews (3 rows / all pending)
-- ────────────────────────────────────────────────────────────

INSERT INTO pending_merge_reviews (id, person_a_id, person_b_id,
                                    proposed_rule, guard_type, guard_payload, evidence,
                                    status, created_at) VALUES
    -- 周成王 vs 楚成王 — surface "成王" 同名 / cross_dynasty 拦
    ('50000000-0000-4000-8000-000000000001',
     '00000000-0000-4000-8000-000000000001',
     '00000000-0000-4000-8000-000000000002',
     'R1', 'cross_dynasty',
     '{"surface_a": "周成王", "surface_b": "楚成王", "dynasty_a": "周", "dynasty_b": "楚", "gap_years": 250}'::jsonb,
     '{"shared_name": "成王"}'::jsonb,
     'pending', '2026-04-20T09:00:00Z'),
    -- 项羽 vs 刘邦 — surface "项羽" / cross_dynasty 拦（同 surface 下 hint banner 测试用）
    ('50000000-0000-4000-8000-000000000002',
     '00000000-0000-4000-8000-000000000003',
     '00000000-0000-4000-8000-000000000004',
     'R5', 'cross_dynasty',
     '{"surface_a": "项羽", "surface_b": "刘邦", "dynasty_a": "秦末", "dynasty_b": "西汉初", "gap_years": 12}'::jsonb,
     '{"alias_overlap": null}'::jsonb,
     'pending', '2026-04-21T09:00:00Z'),
    -- 周成王 vs 张良 — 另一个 "周成王" surface（cluster 测试用）
    ('50000000-0000-4000-8000-000000000003',
     '00000000-0000-4000-8000-000000000001',
     '00000000-0000-4000-8000-000000000005',
     'R3', 'state_prefix',
     '{"surface_a": "周成王", "surface_b": "张良", "state_a": "周", "state_b": null}'::jsonb,
     '{"surface_normalized": "成王"}'::jsonb,
     'pending', '2026-04-22T09:00:00Z');

-- ────────────────────────────────────────────────────────────
-- triage_decisions (5 rows / cross 3 surfaces / multi-row audit per source)
-- ────────────────────────────────────────────────────────────

INSERT INTO triage_decisions (id, source_table, source_id, surface_snapshot,
                               decision, reason_text, reason_source_type,
                               historian_id, decided_at) VALUES
    -- 周成王 surface — 4 历史决策
    ('60000000-0000-4000-8000-000000000001',
     'pending_merge_reviews', '50000000-0000-4000-8000-000000000001', '周成王',
     'reject', '《左传》明确周成王为西周第二代君主，与楚成王（春秋楚国君）非同一人', 'in_chapter',
     'chief-historian', '2026-04-23T10:00:00Z'),
    ('60000000-0000-4000-8000-000000000002',
     'pending_merge_reviews', '50000000-0000-4000-8000-000000000003', '周成王',
     'reject', '周成王 vs 张良：朝代差距太大，非同一人', 'in_chapter',
     'chief-historian', '2026-04-23T10:05:00Z'),
    ('60000000-0000-4000-8000-000000000003',
     'seed_mappings', '40000000-0000-4000-8000-000000000001', '周成王',
     'approve', 'Wikidata Q727636 即周成王（姬诵），可信', 'wikidata',
     'chief-historian', '2026-04-23T10:10:00Z'),
    ('60000000-0000-4000-8000-000000000004',
     'pending_merge_reviews', '50000000-0000-4000-8000-000000000001', '周成王',
     'defer', '需要进一步查《史记·周本纪》确认', 'in_chapter',
     'chief-historian', '2026-04-23T11:00:00Z'),
    -- 项羽 surface — 1 历史决策
    ('60000000-0000-4000-8000-000000000005',
     'pending_merge_reviews', '50000000-0000-4000-8000-000000000002', '项羽',
     'reject', '项羽 vs 刘邦：政治对手，非同一人', 'in_chapter',
     'chief-historian', '2026-04-24T10:00:00Z');
