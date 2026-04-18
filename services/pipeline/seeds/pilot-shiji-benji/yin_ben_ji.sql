-- HuaDian Pipeline Seed Dump
-- Generated: 2026-04-18T03:26:00.749765+00:00
-- Book ID: fc75773e-8545-4f24-8b9d-4bbd8db7dc9a
-- Prompt: ner/v1
-- Model: claude-sonnet-4-6
-- Total cost: $0.6747
-- Persons: 169

BEGIN;

-- ============================================================
-- persons
-- ============================================================

-- Person: 比干 (bi-gan)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c74a2aac-841b-4816-89c8-26c8063abde7', 'bi-gan', '{"zh-Hans": "比干"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "向纣王进谏，未被采纳 强谏纣王，被纣剖心而死，后被武王封墓"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伯夷 (bo-yi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ec440301-5a6f-4d5b-86bf-1f1dabcaf5ff', 'bo-yi', '{"zh-Hans": "伯夷"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与禹、皋陶同在帝舜朝前相语"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 昌仆 (chang-pu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b1a6ecae-5d13-476f-b8e5-3541b689921b', 'chang-pu', '{"zh-Hans": "昌仆"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "蜀山氏之女，昌意之妻，生高阳"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 常先 (chang-xian)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5c131454-8f7e-4b63-8f0f-cf49c4ec6159', 'chang-xian', '{"zh-Hans": "常先"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被黄帝举用以治民的贤臣之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 昌意 (chang-yi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1c404625-59ff-47a9-a239-097e432ad822', 'chang-yi', '{"zh-Hans": "昌意"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "颛顼之父，黄帝之子，禹之曾大父，未得帝位为人臣"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 成汤 (cheng-tang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4d3fe231-eefe-461a-afa5-f5b2d2edc4fd', 'cheng-tang', '{"zh-Hans": "成汤"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "始居亳，从先王之居，作帝诰 商朝开国之君，盘庚以其故居及德政为效法对象 被武丁祭祀的商朝开国先王 商朝开国之君，太史公采录史事自此始"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蚩尤 (chi-you)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('abf65a85-0faf-4ad3-a3dc-c7d04e5aceda', 'chi-you', '{"zh-Hans": "蚩尤"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "汤诰中被引为反面典型，与其大夫作乱百姓，被帝所弃"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 倕 (chui)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2595b9c9-b30f-4701-a553-a1d2a83895e4', 'chui', '{"zh-Hans": "倕"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "自尧时举用，列于群臣之中"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 大鸿 (da-hong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1d6cd4d4-e9c8-4d14-8d48-cc4c5714e87d', 'da-hong', '{"zh-Hans": "大鸿"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被黄帝举用以治民的贤臣之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 妲己 (da-ji)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('309c1421-c0b5-4cb7-8d55-aaecd5a532e0', 'da-ji', '{"zh-Hans": "妲己"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "纣王所爱宠妃，纣从其言行事 被周武王杀死"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 丹朱 (dan-zhu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('46add4d2-e583-449a-8ad4-2732b43b9618', 'dan-zhu', '{"zh-Hans": "丹朱"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被帝告诫禹勿效仿其傲慢放纵之行"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝喾 (di-ku)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('fa14f49f-8dbc-4f3f-a04c-b67df9a5b4e7', 'di-ku', '{"zh-Hans": "帝喾"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "简狄之夫，契之父，五帝之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 放齐 (fang-qi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9f8e4f38-6c25-47a6-9a2b-72fb9f068f64', 'fang-qi', '{"zh-Hans": "放齐"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "向尧举荐嗣子丹朱，被尧否定"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 风后 (feng-hou)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('981f922d-5697-4b1b-b427-e8f66bd8de9d', 'feng-hou', '{"zh-Hans": "风后"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被黄帝举用以治民的贤臣之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 傅说 (fu-yue)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('39081f94-bd83-4196-87cc-2f766cc31830', 'fu-yue', '{"zh-Hans": "傅说"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被武丁梦见，得于傅险，原为胥靡筑役，后被举为相，以傅险为姓"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 皋陶 (gao-yao)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('041aef60-51bd-4509-88b2-d41969f80805', 'gao-yao', '{"zh-Hans": "皋陶"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "汤诰中被称为久劳于外、有功于民的先贤"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 共工 (gong-gong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0fa67188-558b-4622-8d67-2205c3f6ef72', 'gong-gong', '{"zh-Hans": "共工"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被驩兜举荐，尧以其言善用僻、似恭漫天而否定 被驩兜举荐为工师，行事淫辟，后被舜流放于幽陵"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 句望 (gou-wang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3f93f19e-b6c9-4d22-9a55-01c091b7f23b', 'gou-wang', '{"zh-Hans": "句望"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "桥牛之父，敬康之子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 鲧 (gun)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2654bbc9-aa0e-4f85-b99b-2f593d08bc84', 'gun', '{"zh-Hans": "鲧"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "禹之父，颛顼之子，未得帝位，为人臣 受命治水九年无功，被舜殛于羽山而死 禹之父，因治水功业未成而受诛"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 瞽叟 (gu-sou)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ed16177a-3f8d-49d0-89d8-aad52d591dc1', 'gu-sou', '{"zh-Hans": "瞽叟"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "舜之父，桥牛之子 舜之父，目盲，偏爱后妻之子，常欲杀舜 舜之父，顽劣，欲杀舜 舜之父，多次谋害舜，纵火焚廪、填井欲杀之 舜之父，舜践帝位后仍以子道往朝之"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 和叔 (he-shu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('62f42495-d83e-4c58-a905-e43e655c8465', 'he-shu', '{"zh-Hans": "和叔"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "居北方幽都，掌管冬季伏物，以星昴定仲冬"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 和仲 (he-zhong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5cf16973-6ab3-4df3-a493-57a1b19f0632', 'he-zhong', '{"zh-Hans": "和仲"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "居西土昧谷，掌管日入，以星虚定仲秋"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 后稷 (hou-ji)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('709a5ab7-7bb3-4091-a80f-d209caaf5a48', 'hou-ji', '{"zh-Hans": "后稷"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "汤诰中被称为降播农殖百谷、有功于民的先贤"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 黄帝 (huang-di)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3197e202-55e0-4eca-aa91-098d9de33bc9', 'huang-di', '{"zh-Hans": "黄帝"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "禹之高祖，昌意之父，上古帝王"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 简狄 (jian-di)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('340d8d24-c305-4f0e-b517-3f8460dc0b28', 'jian-di', '{"zh-Hans": "简狄"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "有娀氏之女，帝喾次妃，吞玄鸟卵而生契"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蟜极 (jiao-ji)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6dc49a58-ae29-4938-92bf-15cc8fb705a2', 'jiao-ji', '{"zh-Hans": "蟜极"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝喾之父，玄嚣之子，未得在位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 桀 (jie)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('48cdbfcf-f96b-4623-b5b4-1de19f342fd5', 'jie', '{"zh-Hans": "桀"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "行虐政淫荒，被汤讨伐 败于有娀之虚，奔于鸣条，夏师败绩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 敬康 (jing-kang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1a2a3fba-061f-4bf4-adba-4bd3eb16a861', 'jing-kang', '{"zh-Hans": "敬康"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "句望之父，穷蝉之子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 箕子 (ji-zi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('28804aff-e388-4025-951e-ea5bfac7380f', 'ji-zi', '{"zh-Hans": "箕子"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "惧而佯狂为奴，被纣囚禁，后被武王释放"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 孔甲 (kong-jia)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('17dcc539-9089-4a1c-adac-d652bdb1cf16', 'kong-jia', '{"zh-Hans": "孔甲"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝不降之子，好鬼神淫乱，致夏后氏德衰，赐刘累姓御龙氏 夏代帝王，其后诸侯多叛夏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 夔 (kui)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('66f1ad60-8174-4ed9-b780-102df2a0609d', 'kui', '{"zh-Hans": "夔"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "行乐，使箫韶九成、凤皇来仪、百兽率舞"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 嫘祖 (lei-zu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b4e47b19-2fa1-46c2-8fb7-3945c9564c3c', 'lei-zu', '{"zh-Hans": "嫘祖"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "西陵氏之女，黄帝正妃，生玄嚣与昌意"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 力牧 (li-mu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('86b04ce2-b0d2-4729-9aea-d38c492f840e', 'li-mu', '{"zh-Hans": "力牧"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被黄帝举用以治民的贤臣之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 刘累 (liu-lei)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8c656cb3-3e73-4c5a-b75a-d8bb825496d2', 'liu-lei', '{"zh-Hans": "刘累"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "陶唐氏之后，学扰龙于豢龙氏，事孔甲，被赐姓御龙氏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 龙 (long)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('91dca574-3049-437a-b777-bfed43d78ae8', 'long', '{"zh-Hans": "龙"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受命为纳言，夙夜传达帝命，惟信 主掌宾客接待，使远方之人来归"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 盘庚 (pan-geng)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d01e3221-22c5-40fb-a74a-a38d0ffc69c9', 'pan-geng', '{"zh-Hans": "盘庚"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "迁都河南治亳，行汤之政，使殷道复兴 崩后百姓思念，作盘庚三篇以纪念 其政被武王命武庚修行，以安殷民"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 彭祖 (peng-zu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cdae4ce6-714d-4ffc-8c53-2823ca74af69', 'peng-zu', '{"zh-Hans": "彭祖"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "自尧时举用，列于群臣之中"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 启 (qi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('aaa3998f-cad8-4054-9ae4-6d9f5dc40486', 'qi', '{"zh-Hans": "启"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "禹与涂山氏所生之子 禹之子，贤德得天下归心，诸侯去益朝启，遂即天子之位 禹之子，母为涂山氏之女，夏朝君主 伐有扈氏，作甘誓召六卿，遂灭有扈氏，天下咸朝 夏后帝启崩，其子太康继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 桥牛 (qiao-niu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e330634f-161c-4084-902c-a6e1e1a9b33a', 'qiao-niu', '{"zh-Hans": "桥牛"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "瞽叟之父，句望之子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 穷蝉 (qiong-chan)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2b170470-d8a2-4ebd-a166-cdbd5b913003', 'qiong-chan', '{"zh-Hans": "穷蝉"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "颛顼之子 敬康之父，颛顼之子，自此以下皆为庶人"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 商均 (shang-jun)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('34b568ad-7280-41fa-bd84-83a4d25f29f1', 'shang-jun', '{"zh-Hans": "商均"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "舜之子，禹辞让天下于他，但诸侯皆去之而朝禹"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 少典 (shao-dian)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c9177893-35ad-48f5-887b-c48d38d6031d', 'shao-dian', '{"zh-Hans": "少典"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "黄帝之父"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 少康 (shao-kang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('26d68429-421d-4695-99b7-995150cb77aa', 'shao-kang', '{"zh-Hans": "少康"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝相之子，夏代帝王，崩后由子帝予继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 神农氏 (shen-nong-shi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5187db9f-1864-49f0-97d2-d6cc60b5fd2a', 'shen-nong-shi', '{"zh-Hans": "神农氏"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "世衰不能征伐诸侯，天子之位被轩辕取代"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 舜 (shun)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f1a7e4d2-41fa-400c-881b-dfb4919e8200', 'shun', '{"zh-Hans": "舜"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "命契为司徒，敷五教，封契于商赐姓子氏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太甲 (tai-jia)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c01208ae-99a0-4445-8284-6aff6a1703ce', 'tai-jia', '{"zh-Hans": "太甲"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "太丁之子、成汤嫡长孙，由伊尹拥立为帝 即位三年，暴虐不遵汤法，被伊尹放逐于桐宫 居桐宫三年悔过，修德后被伊尹迎回授政，诸侯归附，被称太宗"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太康 (tai-kang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7a21bebe-cb2f-470f-a9a4-7d54876e51e4', 'tai-kang', '{"zh-Hans": "太康"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "启之子，继位后失国，其昆弟五人作五子之歌 崩后由弟中康继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 汤 (tang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('578b71f6-e9aa-4fc3-b8c8-1a7c20a3c910', 'tang', '{"zh-Hans": "汤"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "征伐诸侯，首伐葛伯，发表治国言论并作汤征 被伊尹以滋味游说，后举伊尹任以国政 见猎人张网四面，去其三面，以仁德感化诸侯 兴师伐昆吾与桀，发汤誓，自号武王 伐三嵕，胜夏，践天子位，平定海内 灭夏后归至泰卷陶，还亳作汤诰以令诸侯 改正朔、易服色，尚白，朝会以昼 商朝开国君主，崩后由外丙继位 商朝开国之君，太甲不遵其法度"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 中丁 (u4e2d-u4e01)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b7f3b550-95c1-4dd0-aba7-a2ba1634bed2', 'u4e2d-u4e01', '{"zh-Hans": "中丁"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "商王，自其起废嫡立诸弟子，导致九世之乱"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 中壬 (u4e2d-u58ec)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6fc7f1f3-ad30-4f50-b54d-50442be3adde', 'u4e2d-u58ec', '{"zh-Hans": "中壬"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "外丙之弟，继外丙之位，在位四年而崩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 中宗 (u4e2d-u5b97)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a4d84d4e-fdcf-45a0-b00c-d5fe98454f68', 'u4e2d-u5b97', '{"zh-Hans": "中宗"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "驾崩后由子帝中丁继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 主壬 (u4e3b-u58ec)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7e488b33-62f5-4969-b453-3987fc1634f5', 'u4e3b-u58ec', '{"zh-Hans": "主壬"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "报丙之子，继立后卒，由子主癸继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 主癸 (u4e3b-u7678)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a8279874-a200-49a7-8e4e-c468219ef32d', 'u4e3b-u7678', '{"zh-Hans": "主癸"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "主壬之子，继立后卒，由子天乙（成汤）继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 义伯 (u4e49-u4f2f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1e584772-09ba-4d15-bdff-dfb5c4ad34b2', 'u4e49-u4f2f', '{"zh-Hans": "义伯"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与仲伯共同作典宝"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 九侯 (u4e5d-u4faf)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8f82fd72-bf8c-4c9a-b920-1e2c721a531c', 'u4e5d-u4faf', '{"zh-Hans": "九侯"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "三公之一，献女于纣，因女不喜淫被杀，自身被醢"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 九侯女 (u4e5d-u4faf-u5973)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('48abfa8c-6e65-4508-b86c-363ba3794621', 'u4e5d-u4faf-u5973', '{"zh-Hans": "九侯女"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "九侯之女，入宫于纣，因不喜淫被纣所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 仲伯 (u4ef2-u4f2f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('20850745-a1af-49d1-bb0f-7bec11e0a342', 'u4ef2-u4f2f', '{"zh-Hans": "仲伯"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与义伯共同作典宝"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伊陟 (u4f0a-u965f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1ed80e86-c057-4d2b-977f-1f499c6ad2e4', 'u4f0a-u965f', '{"zh-Hans": "伊陟"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "太戊之相，劝帝修德以应祥桑之异，被太戊赞于庙而辞让臣位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伯益 (u4f2f-u76ca)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6743e16f-5146-471f-9ed7-632497774605', 'u4f2f-u76ca', '{"zh-Hans": "伯益"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与禹同奉帝命，受命向众庶分发稻种以种卑湿之地 与禹共同为众庶提供稻鲜食物"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 冥 (u51a5)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5990ba1c-5b30-4c41-a759-349afbbe343a', 'u51a5', '{"zh-Hans": "冥"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "曹圉之子，继立后卒，由子振继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 南庚 (u5357-u5e9a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('89961cef-fb71-4cf0-906d-8e062272b716', 'u5357-u5e9a', '{"zh-Hans": "南庚"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "沃甲之子，祖丁崩后继位为帝南庚"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 司马迁 (u53f8-u9a6c-u8fc1)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7128aa48-c9a1-43a1-a338-383370cd01c2', 'u53f8-u9a6c-u8fc1', '{"zh-Hans": "司马迁"}'::jsonb, '西汉', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "作者自述，以颂次契之事，采书诗以记成汤以来史事"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周公 (u5468-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('be21116e-6b67-4df9-b3e6-3edab8c7eca6', 'u5468-u516c', '{"zh-Hans": "周公"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "奉成王之命诛灭武庚等叛乱者"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周成王 (u5468-u6210-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4f53bf47-41ac-44dc-b0e5-517afd4f6d2b', 'u5468-u6210-u738b', '{"zh-Hans": "周成王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "命周公平定武庚之乱，封微子于宋"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周文王 (u5468-u6587-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e583a2a0-e6e8-4d41-92e0-04450f690375', 'u5468-u6587-u738b', '{"zh-Hans": "周文王"}'::jsonb, '商末周初', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "归国后阴修德行善，诸侯多归附，后伐饥国灭之，卒后武王继续东伐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周武王 (u5468-u6b66-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e87fbc15-0b9d-4916-9d23-919ca3bdada7', 'u5468-u6b66-u738b', '{"zh-Hans": "周武王"}'::jsonb, '周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "文王卒后东伐至盟津，八百诸侯来会，以天命未至为由暂归 率诸侯伐纣，斩纣头，封比干墓，释箕子，成为天子 崩逝后引发武庚等人叛乱"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 和氏 (u548c-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c67494ce-eac5-4524-a8d2-0a8c03d24373', 'u548c-u6c0f', '{"zh-Hans": "和氏"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受命敬顺昊天，数法日月星辰，敬授民时"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 咎单 (u548e-u5355)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('085afa0a-27c9-4034-87e9-434343bad7f3', 'u548e-u5355', '{"zh-Hans": "咎单"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "作《明居》 伊尹葬后，整理伊尹事迹，作《沃丁》篇"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 商容 (u5546-u5bb9)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2fad187e-d800-4681-9475-610725fa502e', 'u5546-u5bb9', '{"zh-Hans": "商容"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "贤者，百姓爱之，被纣废黜 其闾被周武王表彰"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 商汤 (u5546-u6c64)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9df3fee6-c1b9-4b7e-8be5-26403caa16d8', 'u5546-u6c64', '{"zh-Hans": "商汤"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "主癸之子，继立为商族首领，即成汤"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 垂 (u5782)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ca247afa-919a-4095-b681-3847685cd8ce', 'u5782', '{"zh-Hans": "垂"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被举荐为共工，掌百工之事 主掌工师，百工皆能尽职致功"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 外丙 (u5916-u4e19)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bbfb70fe-0e15-4509-8c47-0ddf373fd9bf', 'u5916-u4e19', '{"zh-Hans": "外丙"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "太丁之弟，继汤之位，在位三年而崩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太丁 (u592a-u4e01)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4fe29020-b3da-41aa-8812-c045474e34b5', 'u592a-u4e01', '{"zh-Hans": "太丁"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "汤之太子，未及即位而卒 武乙之子，继位后崩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太宗 (u592a-u5b97)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('80145529-2e5e-4234-91a8-6e83c47fd813', 'u592a-u5b97', '{"zh-Hans": "太宗"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "驾崩后由子沃丁继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太庚 (u592a-u5e9a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8da2df10-2abe-4d81-828a-2b3bd4dcad0d', 'u592a-u5e9a', '{"zh-Hans": "太庚"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "沃丁之弟，继位为帝太庚，崩后子小甲立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太戊 (u592a-u620a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d8bf838d-daad-4282-97ae-49f671909d28', 'u592a-u620a', '{"zh-Hans": "太戊"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "雍己之弟，立伊陟为相，修德使殷复兴，诸侯归附，称中宗"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 女房 (u5973-u623f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a2e28a22-9375-4e29-a295-969035563da3', 'u5973-u623f', '{"zh-Hans": "女房"}'::jsonb, '商', 'uncertain', 'ai_inferred', NULL, NULL, '{"zh-Hans": "伊尹入亳北门时所遇之人，伊尹为之作篇"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 女鸠 (u5973-u9e20)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('eca161d1-ebc5-484e-b5c3-6b3a3e43375c', 'u5973-u9e20', '{"zh-Hans": "女鸠"}'::jsonb, '商', 'uncertain', 'ai_inferred', NULL, NULL, '{"zh-Hans": "伊尹入亳北门时所遇之人，伊尹为之作篇"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 姒氏 (u59d2-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('16e09751-1795-4a4b-a0cf-4b5cb8409004', 'u59d2-u6c0f', '{"zh-Hans": "姒氏"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "禹所姓之氏，即夏后氏之姓"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 孔子 (u5b54-u5b50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a387e3b7-5ae1-4869-84ef-6d4f6cb61947', 'u5b54-u5b50', '{"zh-Hans": "孔子"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "引述其言，称殷人路车精善且尚白色"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 宰予 (u5bb0-u4e88)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b8ce9615-c7fc-45c9-b5fc-269100b37710', 'u5bb0-u4e88', '{"zh-Hans": "宰予"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "向孔子问五帝德及帝系姓，其问答被孔子所传"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 小乙 (u5c0f-u4e59)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f701d782-874d-4756-8cce-486d700e2925', 'u5c0f-u4e59', '{"zh-Hans": "小乙"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "小辛之弟，小辛崩后继位 武丁之父，崩后由子武丁继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 小甲 (u5c0f-u7532)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4f06d7b1-2ff4-4063-b69a-7fee28dea28e', 'u5c0f-u7532', '{"zh-Hans": "小甲"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "太庚之子，继位后崩，弟雍己立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 小辛 (u5c0f-u8f9b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f44b4d81-fa93-4f42-a646-c1f76cd107fb', 'u5c0f-u8f9b', '{"zh-Hans": "小辛"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "盘庚之弟，继位后殷复衰"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 少暤氏 (u5c11-u66a4-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2e9ab3c3-7bc7-48e3-a700-47b237c5eb37', 'u5c11-u66a4-u6c0f', '{"zh-Hans": "少暤氏"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "其不才子被天下称为穷奇，为四凶之一的来源氏族首领"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 崇侯虎 (u5d07-u4faf-u864e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a54abbd1-05b1-4ab7-b2ce-b8519fcd1078', 'u5d07-u4faf-u864e', '{"zh-Hans": "崇侯虎"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "得知西伯昌窃叹之事，告发于纣"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 巫咸 (u5deb-u54b8)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('62092322-6254-48e2-9467-9e65a5e41d87', 'u5deb-u54b8', '{"zh-Hans": "巫咸"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受伊陟称赞，治王家有成，作《咸艾》《太戊》"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 巫贤 (u5deb-u8d24)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('314c2e92-b8be-444a-8cad-34e2627c091d', 'u5deb-u8d24', '{"zh-Hans": "巫贤"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "祖乙时期任职辅政"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 师涓 (u5e08-u6d93)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6ac54d78-abbd-4e78-b417-06fe22811f8b', 'u5e08-u6d93', '{"zh-Hans": "师涓"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受纣命创作新的淫靡乐声"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝不降 (u5e1d-u4e0d-u964d)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0e30735f-6d22-4574-9920-171bce1eae14', 'u5e1d-u4e0d-u964d', '{"zh-Hans": "帝不降"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝泄之子，夏代帝王，崩后弟帝扃继位，其子孔甲后亦立为帝"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝中丁 (u5e1d-u4e2d-u4e01)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8b81b996-087c-411f-9d30-dd59ca600b11', 'u5e1d-u4e2d-u4e01', '{"zh-Hans": "帝中丁"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "中宗之子，继位后迁都于隞"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝乙 (u5e1d-u4e59)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cb277c3d-41ea-40ec-961f-8713034371d9', 'u5e1d-u4e59', '{"zh-Hans": "帝乙"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "太丁之子，继位后殷益衰 商王，其长子微子启因母贱不得嗣，少子辛继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝予 (u5e1d-u4e88)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2c0c3aa9-3803-4e09-a7cd-be98306e5d34', 'u5e1d-u4e88', '{"zh-Hans": "帝予"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "少康之子，夏代帝王，崩后由子帝槐继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝发 (u5e1d-u53d1)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9d04cdda-0f60-4073-ae80-44b6311c49b8', 'u5e1d-u53d1', '{"zh-Hans": "帝发"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝皋之子，继位后崩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝外壬 (u5e1d-u5916-u58ec)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7a29a307-6bb1-4c04-b2be-34ce1d10f6b1', 'u5e1d-u5916-u58ec', '{"zh-Hans": "帝外壬"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝中丁之弟，中丁崩后继位为帝"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝庚丁 (u5e1d-u5e9a-u4e01)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b1b69239-f9f4-4d3c-af0a-d8ecd54ffcb3', 'u5e1d-u5e9a-u4e01', '{"zh-Hans": "帝庚丁"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝廪辛之弟，继位为帝庚丁，崩后由子帝武乙继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝廑 (u5e1d-u5ed1)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b1a062a0-1dc2-42f7-b8e9-c67496f6bac2', 'u5e1d-u5ed1', '{"zh-Hans": "帝廑"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝扃之子，夏代帝王，崩后立帝不降之子孔甲"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝廪辛 (u5e1d-u5eea-u8f9b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f9e7ee84-007f-434e-95e3-bcc94184211e', 'u5e1d-u5eea-u8f9b', '{"zh-Hans": "帝廪辛"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝甲之子，继位后崩，由弟庚丁继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝扃 (u5e1d-u6243)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('31c34676-b8ea-492f-a8ce-7650e8363e5e', 'u5e1d-u6243', '{"zh-Hans": "帝扃"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝不降之弟，夏代帝王，崩后由子帝廑继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝挚 (u5e1d-u631a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a8d7695f-c9a6-42a6-a01f-527daeb3f191', 'u5e1d-u631a', '{"zh-Hans": "帝挚"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝喾与娵訾氏女之子，继帝喾之位但不善，后由弟放勋代立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝槐 (u5e1d-u69d0)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d2a6fcfa-ce08-4400-9797-6f10a99e4963', 'u5e1d-u69d0', '{"zh-Hans": "帝槐"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝予之子，夏代帝王，崩后由子帝芒继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝武乙 (u5e1d-u6b66-u4e59)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6bc7e23d-dd50-42f3-9f4f-14364fe74e59', 'u5e1d-u6b66-u4e59', '{"zh-Hans": "帝武乙"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝庚丁之子，继位后殷都迁至河北"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝泄 (u5e1d-u6cc4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2cca90ac-fc2b-470d-857d-1e61641276ac', 'u5e1d-u6cc4', '{"zh-Hans": "帝泄"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝芒之子，夏代帝王，崩后由子帝不降继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝甲 (u5e1d-u7532)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9ac28aaa-b707-415a-832c-60bea1de7ba1', 'u5e1d-u7532', '{"zh-Hans": "帝甲"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "崩后由子帝廪辛继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝皋 (u5e1d-u768b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5d148846-8cd5-40fc-b831-f100d2255387', 'u5e1d-u768b', '{"zh-Hans": "帝皋"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "孔甲之子，继位后崩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝相 (u5e1d-u76f8)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('408b9a55-0afd-4c91-8d31-4e85b2727319', 'u5e1d-u76f8', '{"zh-Hans": "帝相"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "中康之子，夏代帝王，崩后由子少康继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝芒 (u5e1d-u8292)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bebe0656-0ad7-4347-b43b-41dec4d02be8', 'u5e1d-u8292', '{"zh-Hans": "帝芒"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝槐之子，夏代帝王，崩后由子帝泄继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝鸿氏 (u5e1d-u9e3f-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('19ef3926-eaf1-42e1-ba4b-f0fc4b9de9dd', 'u5e1d-u9e3f-u6c0f', '{"zh-Hans": "帝鸿氏"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "其不才子被天下称为浑沌，为四凶之一的来源氏族首领"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 弃 (u5f03)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b33d8c16-006e-46e1-8b34-a1981663ddbc', 'u5f03', '{"zh-Hans": "弃"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "主掌农稷，使百谷按时茂盛 周之始祖，姓姬氏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 微 (u5fae)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('436bf856-818a-43fb-b567-4dbafa582cf6', 'u5fae', '{"zh-Hans": "微"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "振之子，继立后卒，由子报丁继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 微子 (u5fae-u5b50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('efb3377d-cff3-4658-b723-cb472ab9ff1b', 'u5fae-u5b50', '{"zh-Hans": "微子"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "数谏纣不听，与大师、少师谋后离去 被成王封于宋，以延续殷商后裔"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 恶来 (u6076-u6765)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cf3bad71-102d-4ce9-8c00-35d2dc1af0d7', 'u6076-u6765', '{"zh-Hans": "恶来"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "纣所用佞臣，善毁谗，致诸侯益疏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 报丁 (u62a5-u4e01)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ed3b3b19-bad9-4f2a-93e8-5920dde6fcc3', 'u62a5-u4e01', '{"zh-Hans": "报丁"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "微之子，继立后卒，由子报乙继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 报丙 (u62a5-u4e19)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8c725d8e-2dd1-4830-a179-02f3e69051c5', 'u62a5-u4e19', '{"zh-Hans": "报丙"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "报乙之子，继立后卒，由子主壬继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 报乙 (u62a5-u4e59)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e5eacaaa-6910-461e-99a9-13a876eef70a', 'u62a5-u4e59', '{"zh-Hans": "报乙"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "报丁之子，继立后卒，由子报丙继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 振 (u632f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4f47836e-dc17-49e6-9ff0-5cc10d484c20', 'u632f', '{"zh-Hans": "振"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "冥之子，继立后卒，由子微继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 昆吾氏 (u6606-u543e-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('be1927a1-1aef-4ae6-9a56-4640fd7c9ab0', 'u6606-u543e-u6c0f', '{"zh-Hans": "昆吾氏"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "诸侯中作乱者，被汤率师讨伐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 昌若 (u660c-u82e5)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('dc8083af-064f-490d-bad2-2d9960213458', 'u660c-u82e5', '{"zh-Hans": "昌若"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "相土之子，继立后卒，由子曹圉继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 昭明 (u662d-u660e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f71793a2-6ce3-4fd6-af8c-e331cc0505db', 'u662d-u660e', '{"zh-Hans": "昭明"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "契之子，继立后卒，由子相土继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 曹圉 (u66f9-u5709)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2e1f9ec6-7463-4efa-8ecd-d7a28e609cfe', 'u66f9-u5709', '{"zh-Hans": "曹圉"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "昌若之子，继立后卒，由子冥继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 朱虎 (u6731-u864e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c02c2701-7bab-4e22-9437-39e2ccb0ce90', 'u6731-u864e', '{"zh-Hans": "朱虎"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "益让位于他，被任为虞之佐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 梼杌 (u68bc-u674c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('673368d9-1523-4a7b-a105-2c7ed6367318', 'u68bc-u674c', '{"zh-Hans": "梼杌"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "颛顼氏之不才子，不可教训、不知话言，被天下称为梼杌"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 武乙 (u6b66-u4e59)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b45f2e48-f669-4b36-93ed-213e3b36a0eb', 'u6b66-u4e59', '{"zh-Hans": "武乙"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "无道，制偶人射天，猎于河渭之间被雷震死"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 武庚 (u6b66-u5e9a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('70e67046-bba3-491e-8f41-64c8b46af1ea', 'u6b66-u5e9a', '{"zh-Hans": "武庚"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "纣之子，被武王封以续殷祀，令修行盘庚之政 与管叔、蔡叔作乱，被周公诛杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 沃丁 (u6c83-u4e01)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c65680a5-8e79-41c8-ad07-7f7fdaffc0e2', 'u6c83-u4e01', '{"zh-Hans": "沃丁"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "太宗之子，继位后在位期间伊尹去世 崩后由弟太庚继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 沃甲 (u6c83-u7532)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('479b1fd2-d739-43d2-a7c6-75284b6eaa82', 'u6c83-u7532', '{"zh-Hans": "沃甲"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "祖辛之弟，继位为帝沃甲，崩后由侄祖丁继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 河亶甲 (u6cb3-u4eb6-u7532)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('85531e86-3424-4048-a90a-ef090fe9f336', 'u6cb3-u4eb6-u7532', '{"zh-Hans": "河亶甲"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "居相，后继外壬为帝，在位时殷再度衰落 崩逝，其子祖乙继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 浑沌 (u6d51-u6c8c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8f15868e-a5b6-4003-ab74-87a8df633206', 'u6d51-u6c8c', '{"zh-Hans": "浑沌"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝鸿氏之不才子，掩义隐贼、好行凶慝，被天下称为浑沌"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 涂山氏 (u6d82-u5c71-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0aff7cb5-0ffd-4097-a2d0-9539c44856d6', 'u6d82-u5c71-u6c0f', '{"zh-Hans": "涂山氏"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "禹之妻，生启 涂山氏之女，禹之妻，启之母"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 熊罴 (u718a-u7f74)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e15a3a4b-5cae-4015-9a11-01d6f39e98f8', 'u718a-u7f74', '{"zh-Hans": "熊罴"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "益让位于他，被任为虞之佐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 相土 (u76f8-u571f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6e851a98-5b2d-4d3f-93da-9d1794d5d600', 'u76f8-u571f', '{"zh-Hans": "相土"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "昭明之子，继立后卒，由子昌若继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 祖丁 (u7956-u4e01)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d153de2d-51be-4672-9831-840891edf6a8', 'u7956-u4e01', '{"zh-Hans": "祖丁"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "祖辛之子，沃甲崩后继位为帝祖丁"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 祖乙 (u7956-u4e59)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cc710738-64ef-418f-9895-fe256ea4c9df', 'u7956-u4e59', '{"zh-Hans": "祖乙"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "迁都于邢 河亶甲之子，继位后殷商复兴 崩后由子帝祖辛继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 祖伊 (u7956-u4f0a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ed76029d-aab1-4a46-9f4c-eafaea8be9de', 'u7956-u4f0a', '{"zh-Hans": "祖伊"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "闻西伯灭饥国而忧，奔告纣王天命将失，纣不听，叹纣不可谏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 祖己 (u7956-u5df1)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('840736ab-900f-4ebd-b7a9-b3475ab89d5f', 'u7956-u5df1', '{"zh-Hans": "祖己"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "劝谏武丁勿忧，训王修政行德以顺天意 嘉许武丁以祥雉为德，为其立庙称高宗，并作高宗肜日及训"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 祖庚 (u7956-u5e9a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('179a1a4f-6409-4315-8418-67266a664858', 'u7956-u5e9a', '{"zh-Hans": "祖庚"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "武丁之子，武丁崩后继位为帝 商王，崩后由弟祖甲继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 祖甲 (u7956-u7532)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3f3ec17b-d7ae-434e-a919-fe3ade0af69f', 'u7956-u7532', '{"zh-Hans": "祖甲"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "祖庚之弟，继位后淫乱，致殷再度衰落"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 祖辛 (u7956-u8f9b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ed306319-a294-43af-bdb7-184d1c1c4f56', 'u7956-u8f9b', '{"zh-Hans": "祖辛"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "祖乙之子，继位后崩，弟沃甲立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 穷奇 (u7a77-u5947)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('923f754d-2767-4698-9ef6-4c2b0f9701fc', 'u7a77-u5947', '{"zh-Hans": "穷奇"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "少暤氏之不才子，毁信恶忠、崇饰恶言，被天下称为穷奇"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 管叔 (u7ba1-u53d4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6371d326-0731-4488-bf85-243ea3fcc5e1', 'u7ba1-u53d4', '{"zh-Hans": "管叔"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与武庚、蔡叔共同作乱，被周公诛讨"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 缙云氏 (u7f19-u4e91-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ae47eddd-804b-4715-974a-d1eb99a19509', 'u7f19-u4e91-u6c0f', '{"zh-Hans": "缙云氏"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "其不才子被天下称为饕餮，为四凶之一的来源氏族首领"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 羲氏 (u7fb2-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('411ee7c8-a7fe-4f0b-8018-d1e63b0440bf', 'u7fb2-u6c0f', '{"zh-Hans": "羲氏"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受命敬顺昊天，数法日月星辰，敬授民时"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 胤 (u80e4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bcc268f7-cdb8-45f6-bc1c-b713335c158a', 'u80e4', '{"zh-Hans": "胤"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "奉命征讨湎淫废时的羲、和，作《胤征》"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 荤粥 (u8364-u7ca5)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b40287a2-64ed-4bc3-83bf-3f51a8e1a48f', 'u8364-u7ca5', '{"zh-Hans": "荤粥"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "北方部族，被黄帝北逐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 葛伯 (u845b-u4f2f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('15525c10-3e44-4885-a386-37bfb92f02da', 'u845b-u4f2f', '{"zh-Hans": "葛伯"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "不行祭祀，被汤首先讨伐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蔡叔 (u8521-u53d4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('749ac677-2ff0-4dc4-a2e2-1580f163988e', 'u8521-u53d4', '{"zh-Hans": "蔡叔"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与武庚、管叔共同作乱，被周公诛讨"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 费中 (u8d39-u4e2d)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('501f609e-c754-49f6-abcd-b9eb414fa1e3', 'u8d39-u4e2d', '{"zh-Hans": "费中"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "纣所用佞臣，善谀好利，殷人不亲"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 鄂侯 (u9102-u4faf)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ffa19925-910a-4a0e-b4b0-4bc79a4e1956', 'u9102-u4faf', '{"zh-Hans": "鄂侯"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "三公之一，为九侯之死力争，被纣脯杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 闳夭 (u95f3-u592d)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('12f8f815-d9ac-46e6-ab39-d0ba778bd0d6', 'u95f3-u592d', '{"zh-Hans": "闳夭"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "西伯之臣，求美女奇物善马献纣以赎西伯"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 阳甲 (u9633-u7532)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0abe51f4-21b6-4c4f-9200-0bfc8996712c', 'u9633-u7532', '{"zh-Hans": "阳甲"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "祖丁之子，南庚崩后继位，在位时殷道衰 盘庚之兄，崩后由盘庚继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 雍己 (u96cd-u5df1)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bbb04292-6c55-4710-9599-7d2bc9773e00', 'u96cd-u5df1', '{"zh-Hans": "雍己"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "小甲之弟，继位为帝雍己，在位时殷道衰，诸侯或不至 商王，崩后由弟太戊继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 饕餮 (u9955-u992e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0cc1ea00-0a98-4c3a-b7af-c021d69ac6aa', 'u9955-u992e', '{"zh-Hans": "饕餮"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "缙云氏之不才子，贪于饮食、冒于货贿，被天下称为饕餮"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 驩兜 (u9a69-u515c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('73d7a713-158d-4b92-8de0-f130c267297e', 'u9a69-u515c', '{"zh-Hans": "驩兜"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被禹举为知人能惠则无需忧虑之反面例证"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 微子启 (wei-zi-qi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('89ce41bc-f9d2-4ebb-aa9c-de3e4e18abb0', 'wei-zi-qi', '{"zh-Hans": "微子启"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝乙长子，因母出身低贱而不得继承王位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 武丁 (wu-ding)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('28626579-1c80-4789-b14b-7b9369885397', 'wu-ding', '{"zh-Hans": "武丁"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "即位后思复兴殷，夜梦圣人，寻得傅说并举为相，殷国大治 祭成汤时遇飞雉登鼎，听从祖己劝谏修政行德，使殷道复兴 商王，崩后被祖己立庙称高宗，有高宗肜日及训传世"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 象 (xiang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0cdfa4af-4767-484f-a678-426a035a781c', 'xiang', '{"zh-Hans": "象"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "瞽叟与后妻所生之子，性格傲慢，为舜之弟 舜之弟，傲慢，与父母同谋欲杀舜 舜之弟，与瞽叟共谋害舜，以为舜死后占其宫室琴妻 舜之弟，被舜封为诸侯"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 西伯昌 (xi-bo-chang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cc6fe4f8-3f8c-4620-ade4-61ec6cd672a1', 'xi-bo-chang', '{"zh-Hans": "西伯昌"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "为三公之一，闻九侯鄂侯之死窃叹，被囚羑里，后献地请除炮格之刑获赦"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 契 (xie)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('10ccab31-8acf-4d89-9e85-accc4eda7787', 'xie', '{"zh-Hans": "契"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "简狄吞玄鸟卵所生，佐禹治水有功，被舜封于商赐姓子氏 商族始祖，卒后由子昭明继立 商族始祖，自契至汤历八迁 殷商始祖，子姓之源，其后分封各氏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 羲叔 (xi-shu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('64e7b89d-b0c6-4e8b-8d67-5ebde716b623', 'xi-shu', '{"zh-Hans": "羲叔"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "居南交，掌管南方夏务，以星火定仲夏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 羲仲 (xi-zhong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bd91336a-400f-43c8-a430-0835a9607aa7', 'xi-zhong', '{"zh-Hans": "羲仲"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "居郁夷旸谷，掌管日出，观测春分星象以定仲春"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 玄嚣 (xuan-xiao)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d946e274-3979-40b5-a01d-e044ff05660c', 'xuan-xiao', '{"zh-Hans": "玄嚣"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "黄帝长子，又名青阳，降居江水 帝喾之祖父，其孙高辛继颛顼之位 黄帝之子，蟜极之父，未得在位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 炎帝 (yan-di)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5f41c43c-db30-44c5-a6b0-3608b70e2438', 'yan-di', '{"zh-Hans": "炎帝"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "欲侵陵诸侯，与轩辕战于阪泉之野，三战后被制服"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 尧 (yao)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2da772b8-3c0b-4e13-9452-5e85ae34bf26', 'yao', '{"zh-Hans": "尧"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "求治水之人，用鲧九年无功，后得舜继位摄政 已崩，舜问群臣如何成就其未竟之事"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 益 (yi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ea880e29-01ac-40ed-b4f3-5f1f9da8814a', 'yi', '{"zh-Hans": "益"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "皋陶卒后被禹举荐任政 受禹授天下，三年丧毕后让位于启，隐居箕山之阳"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伊尹 (yi-yin)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('02ee394b-9b9c-442c-ba7e-a8c7d2b1c05e', 'yi-yin', '{"zh-Hans": "伊尹"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "称赞汤之言明智，劝勉汤听道进善 以滋味说汤致于王道，后被任以国政，曾去汤适夏又归亳 随从汤出征伐桀 汤胜夏后作报（报告/祭告） 作《咸有一德》 中壬崩后立太甲为帝，并作伊训等篇以辅佐 将太甲放逐桐宫，摄行政事代理国政，朝见诸侯 迎帝太甲归政，嘉其修德，作太甲训三篇褒扬之 于沃丁之时去世，葬于亳，其事迹由咎单整理成篇"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 禹 (yu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('95638bf0-ec39-42c0-a74b-f101d1d22f58', 'yu', '{"zh-Hans": "禹"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "契佐其治水有功，与唐虞并称契兴起之际 汤诰中被称为久劳于外、有功于民的先贤，治理四渎使万民安居"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 中康 (zhong-kang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3dad64e2-c955-4d0f-b845-cdbc21ce84df', 'zhong-kang', '{"zh-Hans": "中康"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "太康之弟，太康崩后继位为帝 夏代帝王，崩后由子帝相继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 纣 (zhou-xin)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9d46a8fd-ae53-4b95-ace4-0892e92c94ec', 'zhou-xin', '{"zh-Hans": "纣"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝乙少子，母为正后，继承王位，天下称之为纣 商末暴君，好酒淫乐，厚赋税，建鹿台，为长夜之饮 商末暴君，重刑炮格，杀九侯、鄂侯，囚西伯，任用费中、恶来 淫虐自绝，不听比干谏言，废商容，失诸侯之心 淫乱不止，杀比干、囚箕子，兵败后登鹿台赴火而死"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 颛顼 (zhuan-xu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c26a5df8-35d3-4339-a520-c56f3fe26b11', 'zhuan-xu', '{"zh-Hans": "颛顼"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "鲧之父，昌意之子，黄帝之孙，禹之祖父"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- person_names
-- ============================================================

-- Name for bi-gan: 比干 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('14e90ddd-76fa-4355-9ea4-c8cd7ea71c7b', 'c74a2aac-841b-4816-89c8-26c8063abde7', '比干', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for bi-gan: 王子比干
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5bb69d97-9a71-4f99-abf9-e47c869b1fde', 'c74a2aac-841b-4816-89c8-26c8063abde7', '王子比干', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for bo-yi: 伯夷 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('804c6960-ce2b-427e-8d2d-353e670bc7be', 'ec440301-5a6f-4d5b-86bf-1f1dabcaf5ff', '伯夷', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for chang-pu: 昌仆 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7913fb27-1e7a-46e3-85e5-a21fe3697ec9', 'b1a6ecae-5d13-476f-b8e5-3541b689921b', '昌仆', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for chang-pu: 蜀山氏女
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('93763fe7-959f-42df-ac1e-e8efc98b646c', 'b1a6ecae-5d13-476f-b8e5-3541b689921b', '蜀山氏女', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for chang-xian: 常先 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6bdaefd8-c55d-4996-b1a9-32cbaeeed600', '5c131454-8f7e-4b63-8f0f-cf49c4ec6159', '常先', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for chang-yi: 昌意 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c30825fe-d7b5-40cf-86e7-e85289439ab6', '1c404625-59ff-47a9-a239-097e432ad822', '昌意', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for cheng-tang: 成汤 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3e59a8bf-ad0b-471f-ad9f-b2fcdd34c9bd', '4d3fe231-eefe-461a-afa5-f5b2d2edc4fd', '成汤', NULL, 'posthumous', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for cheng-tang: 汤
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fe40d8a4-d809-4468-99d7-7430240e5888', '4d3fe231-eefe-461a-afa5-f5b2d2edc4fd', '汤', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for cheng-tang: 高后成汤
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f9efdd2b-6211-4025-943a-08f641a2bfae', '4d3fe231-eefe-461a-afa5-f5b2d2edc4fd', '高后成汤', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for chi-you: 蚩尤 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d29a77b3-1c6a-4ac4-a010-b2b00b4d18e2', 'abf65a85-0faf-4ad3-a3dc-c7d04e5aceda', '蚩尤', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for chui: 倕 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c2a57fce-73a0-404e-a72c-777d533ba24e', '2595b9c9-b30f-4701-a553-a1d2a83895e4', '倕', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for da-hong: 大鸿 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f5bc7c83-5c86-4590-a654-7760c8dc2048', '1d6cd4d4-e9c8-4d14-8d48-cc4c5714e87d', '大鸿', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for da-ji: 妲己 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('472cb03a-fbbd-4af8-b73f-d57810a468ab', '309c1421-c0b5-4cb7-8d55-aaecd5a532e0', '妲己', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for dan-zhu: 丹朱 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fcf417f6-c5e4-44a1-9ab3-18051dd8724d', '46add4d2-e583-449a-8ad4-2732b43b9618', '丹朱', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for di-ku: 帝喾 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('efbfcbd2-ac9d-42e9-9707-3d08081bec69', 'fa14f49f-8dbc-4f3f-a04c-b67df9a5b4e7', '帝喾', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for di-ku: 帝喾高辛者
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('351b03d7-f811-467b-b730-3972f0c6e405', 'fa14f49f-8dbc-4f3f-a04c-b67df9a5b4e7', '帝喾高辛者', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for di-ku: 高辛
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7c4e6533-a55b-4dd3-8a54-b4f2553f5eb1', 'fa14f49f-8dbc-4f3f-a04c-b67df9a5b4e7', '高辛', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for di-ku: 高辛氏
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0c3d0e63-78a6-48c0-9131-9084513d4932', 'fa14f49f-8dbc-4f3f-a04c-b67df9a5b4e7', '高辛氏', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for fang-qi: 放齐 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('04d59dcc-f60c-4068-a040-79f8c9aebbd1', '9f8e4f38-6c25-47a6-9a2b-72fb9f068f64', '放齐', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for feng-hou: 风后 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('29372dad-bb20-46b4-9496-38a6a3a2883b', '981f922d-5697-4b1b-b427-e8f66bd8de9d', '风后', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for fu-yue: 傅说 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c9739c99-978d-4fee-92e4-5f2bfb124335', '39081f94-bd83-4196-87cc-2f766cc31830', '傅说', NULL, 'alias', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for fu-yue: 说
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('20801374-88d6-4611-8b09-45bdecdb1940', '39081f94-bd83-4196-87cc-2f766cc31830', '说', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for gao-yao: 皋陶 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4fa2e3f7-128c-4577-9742-1b786bbf0966', '041aef60-51bd-4509-88b2-d41969f80805', '皋陶', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for gong-gong: 共工 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1d5e3b4c-61c7-48b6-b2ce-610ecc67da78', '0fa67188-558b-4622-8d67-2205c3f6ef72', '共工', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for gou-wang: 句望 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5e9ddae1-3834-4ba4-85ea-e5fe1da0ce3f', '3f93f19e-b6c9-4d22-9a55-01c091b7f23b', '句望', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for gun: 鲧 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cd68d96c-ade0-4ea5-a413-90a675816942', '2654bbc9-aa0e-4f85-b99b-2f593d08bc84', '鲧', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for gu-sou: 瞽叟 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('efe412e5-696e-496a-90e0-951802826fe6', 'ed16177a-3f8d-49d0-89d8-aad52d591dc1', '瞽叟', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for he-shu: 和叔 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8955101d-ad9e-46f8-8e4a-41e8d6df5fc5', '62f42495-d83e-4c58-a905-e43e655c8465', '和叔', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for he-zhong: 和仲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b751353b-e5b3-471c-9d85-3c449eb295f3', '5cf16973-6ab3-4df3-a493-57a1b19f0632', '和仲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for hou-ji: 后稷 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cbea21d3-eddc-4bd5-a220-e0e17008e277', '709a5ab7-7bb3-4091-a80f-d209caaf5a48', '后稷', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for hou-ji: 弃
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6e990b7e-8091-4dc1-9817-6d1a46f78e58', '709a5ab7-7bb3-4091-a80f-d209caaf5a48', '弃', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for hou-ji: 稷
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('99b6eb2b-6cce-42f9-a626-83e800026749', '709a5ab7-7bb3-4091-a80f-d209caaf5a48', '稷', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for huang-di: 黄帝 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6869aa73-ed9b-4448-b128-0d7b580f0567', '3197e202-55e0-4eca-aa91-098d9de33bc9', '黄帝', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for huang-di: 轩辕
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d3bf0088-204e-46b1-9512-b8c98e569e27', '3197e202-55e0-4eca-aa91-098d9de33bc9', '轩辕', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for jian-di: 简狄 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9b862096-124c-4efd-bfd2-e6787be848a5', '340d8d24-c305-4f0e-b517-3f8460dc0b28', '简狄', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for jiao-ji: 蟜极 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b99a0a8a-32e1-4d61-9a2a-b1a6c432870a', '6dc49a58-ae29-4938-92bf-15cc8fb705a2', '蟜极', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for jie: 桀 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('122360d4-926b-4315-8b96-c3d8ebfc2d67', '48cdbfcf-f96b-4623-b5b4-1de19f342fd5', '桀', NULL, 'posthumous', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for jie: 夏桀
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d83c9869-14ba-460c-81d2-33c1fa31d0e0', '48cdbfcf-f96b-4623-b5b4-1de19f342fd5', '夏桀', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for jie: 夏王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7d3ec13d-ad25-4e3b-b9d2-42e85b78ccb4', '48cdbfcf-f96b-4623-b5b4-1de19f342fd5', '夏王', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for jie: 帝履癸
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('efc1973d-8ecd-4a0c-82b0-b1ae19b80ca8', '48cdbfcf-f96b-4623-b5b4-1de19f342fd5', '帝履癸', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for jie: 帝桀
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2e806db0-3e91-4d7e-90d9-a20225ff0110', '48cdbfcf-f96b-4623-b5b4-1de19f342fd5', '帝桀', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for jing-kang: 敬康 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1695d959-109f-4f79-8fd3-1e0403722c2a', '1a2a3fba-061f-4bf4-adba-4bd3eb16a861', '敬康', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for ji-zi: 箕子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('bdff8738-fdea-4e0a-ab74-0dc56e3ee962', '28804aff-e388-4025-951e-ea5bfac7380f', '箕子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for kong-jia: 孔甲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('618e9d74-6ac0-4305-9c02-2c1ed74f0a26', '17dcc539-9089-4a1c-adac-d652bdb1cf16', '孔甲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for kong-jia: 帝孔甲
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('109ed92f-8ae1-4084-8044-e49806b13f6d', '17dcc539-9089-4a1c-adac-d652bdb1cf16', '帝孔甲', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for kui: 夔 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('67eb43f6-26b9-46c5-8840-c71c27ad597e', '66f1ad60-8174-4ed9-b780-102df2a0609d', '夔', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for lei-zu: 嫘祖 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fa608aa8-ee1c-45f7-b83c-a1ac1a8c3d69', 'b4e47b19-2fa1-46c2-8fb7-3945c9564c3c', '嫘祖', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for lei-zu: 西陵之女
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('edad3b5f-c02c-4788-8325-2389802dd287', 'b4e47b19-2fa1-46c2-8fb7-3945c9564c3c', '西陵之女', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for li-mu: 力牧 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fd478480-8945-4305-a3df-04cd70c36f4b', '86b04ce2-b0d2-4729-9aea-d38c492f840e', '力牧', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for liu-lei: 刘累 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('eec613f5-b01d-473c-8dce-7a2f54fe32d6', '8c656cb3-3e73-4c5a-b75a-d8bb825496d2', '刘累', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for long: 龙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f10028c1-feee-4646-af69-93af7d39ea57', '91dca574-3049-437a-b777-bfed43d78ae8', '龙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for pan-geng: 盘庚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1a7a603c-3ea7-4a3f-a0ea-17e33177f7a0', 'd01e3221-22c5-40fb-a74a-a38d0ffc69c9', '盘庚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for pan-geng: 帝盘庚
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('11f8273c-18a4-40ef-b1b4-ea045f2de3f9', 'd01e3221-22c5-40fb-a74a-a38d0ffc69c9', '帝盘庚', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for peng-zu: 彭祖 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('09c63058-9440-4b5a-9a7e-0f031af905f5', 'cdae4ce6-714d-4ffc-8c53-2823ca74af69', '彭祖', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for qi: 启 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7e422109-22ff-400e-99f6-5e6c5c4acf86', 'aaa3998f-cad8-4054-9ae4-6d9f5dc40486', '启', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for qi: 夏后帝启
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cc942392-c46f-406f-830d-fb55ad3b6c02', 'aaa3998f-cad8-4054-9ae4-6d9f5dc40486', '夏后帝启', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for qi: 禹子启
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9672c7b9-2483-48f0-a583-251d7c17cbfe', 'aaa3998f-cad8-4054-9ae4-6d9f5dc40486', '禹子启', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for qiao-niu: 桥牛 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c90aed71-71a7-4c80-a661-84d118f9915d', 'e330634f-161c-4084-902c-a6e1e1a9b33a', '桥牛', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for qiong-chan: 穷蝉 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ff07d0d0-1163-492d-b8da-ec407f0aa3a4', '2b170470-d8a2-4ebd-a166-cdbd5b913003', '穷蝉', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for shang-jun: 商均 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('15a669cb-fcad-4f84-bd3b-aa0260d687af', '34b568ad-7280-41fa-bd84-83a4d25f29f1', '商均', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shang-jun: 舜之子商均
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('245030c6-69ce-4a42-8b23-fd4856b94c7a', '34b568ad-7280-41fa-bd84-83a4d25f29f1', '舜之子商均', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for shao-dian: 少典 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('95b3c475-a7de-4f40-9f6f-df68a3089306', 'c9177893-35ad-48f5-887b-c48d38d6031d', '少典', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for shao-kang: 少康 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b2798bf3-a7a0-4798-8451-8638d19a2631', '26d68429-421d-4695-99b7-995150cb77aa', '少康', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shao-kang: 帝少康
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6c546983-b5dd-46f8-874c-30f0ac5672ef', '26d68429-421d-4695-99b7-995150cb77aa', '帝少康', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for shen-nong-shi: 神农氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c71bc8c0-fea1-44dc-a51a-5f2a340135c0', '5187db9f-1864-49f0-97d2-d6cc60b5fd2a', '神农氏', NULL, 'alias', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for shun: 舜 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e262b667-d462-47c4-9a79-714d2c6e199d', 'f1a7e4d2-41fa-400c-881b-dfb4919e8200', '舜', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shun: 帝
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('16fff91e-d78b-4327-a028-d02c65bc7fc3', 'f1a7e4d2-41fa-400c-881b-dfb4919e8200', '帝', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shun: 帝舜
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6ecff6c9-c5be-4020-a5a2-106acb2b0cfd', 'f1a7e4d2-41fa-400c-881b-dfb4919e8200', '帝舜', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shun: 有虞
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1e6ceb56-e78d-42e3-a8bf-484bd975c780', 'f1a7e4d2-41fa-400c-881b-dfb4919e8200', '有虞', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shun: 虞帝
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('368c1362-4a97-49a2-9e07-754ce657c4b0', 'f1a7e4d2-41fa-400c-881b-dfb4919e8200', '虞帝', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shun: 虞舜
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('596185ac-4124-42b3-8883-a8cb7d435812', 'f1a7e4d2-41fa-400c-881b-dfb4919e8200', '虞舜', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shun: 重华
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c5f9cb6f-1f17-4791-abc8-1fd03f6a38e8', 'f1a7e4d2-41fa-400c-881b-dfb4919e8200', '重华', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for tai-jia: 太甲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e95710e2-83ae-4421-b3ec-97c53b50a984', 'c01208ae-99a0-4445-8284-6aff6a1703ce', '太甲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for tai-jia: 太宗
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('113f967f-fc7b-41f1-b506-bf4772291c97', 'c01208ae-99a0-4445-8284-6aff6a1703ce', '太宗', NULL, 'temple', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for tai-jia: 帝太甲
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2e7360bf-a5e0-413c-b9d6-5051c5188fd5', 'c01208ae-99a0-4445-8284-6aff6a1703ce', '帝太甲', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for tai-kang: 太康 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('65fca07d-866f-4a4e-8378-ae070ae841dc', '7a21bebe-cb2f-470f-a9a4-7d54876e51e4', '太康', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for tai-kang: 帝太康
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7f5805ef-0415-4b5a-bbaf-d585a6dc2ab4', '7a21bebe-cb2f-470f-a9a4-7d54876e51e4', '帝太康', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for tang: 汤 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('34729f89-cecf-45fa-a744-ee8426224cfa', '578b71f6-e9aa-4fc3-b8c8-1a7c20a3c910', '汤', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for tang: 予一人
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0da61057-d0ed-4a8f-9808-a18b924ee25d', '578b71f6-e9aa-4fc3-b8c8-1a7c20a3c910', '予一人', NULL, 'self_ref', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for tang: 成汤
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d051ee9c-d797-4465-beab-466cbadd390f', '578b71f6-e9aa-4fc3-b8c8-1a7c20a3c910', '成汤', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for tang: 朕
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('acb1d71f-5314-43dd-9339-c458a36e5248', '578b71f6-e9aa-4fc3-b8c8-1a7c20a3c910', '朕', NULL, 'self_ref', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for tang: 武王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8b383dc2-6bb4-46cb-9cfc-f36d196e1aa1', '578b71f6-e9aa-4fc3-b8c8-1a7c20a3c910', '武王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for tang: 王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cd98d890-51ac-4d98-8ca6-38fb87a635b7', '578b71f6-e9aa-4fc3-b8c8-1a7c20a3c910', '王', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e2d-u4e01: 中丁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f191b098-a02b-48ad-802c-04393ba52c08', 'b7f3b550-95c1-4dd0-aba7-a2ba1634bed2', '中丁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e2d-u58ec: 中壬 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('96e0896b-0144-4221-95bf-32c3370a2c41', '6fc7f1f3-ad30-4f50-b54d-50442be3adde', '中壬', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u4e2d-u58ec: 帝中壬
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b5f1b58f-26ab-4858-8524-88d5ea74605f', '6fc7f1f3-ad30-4f50-b54d-50442be3adde', '帝中壬', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e2d-u5b97: 中宗 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ccef6cf0-9ef5-4fe8-a5e4-d39798869d16', 'a4d84d4e-fdcf-45a0-b00c-d5fe98454f68', '中宗', NULL, 'temple', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e3b-u58ec: 主壬 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('837d08c4-c4d8-4ffe-aecc-c00b53565085', '7e488b33-62f5-4969-b453-3987fc1634f5', '主壬', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e3b-u7678: 主癸 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1c6f45c3-f79e-46c0-a9b8-19051be49770', 'a8279874-a200-49a7-8e4e-c468219ef32d', '主癸', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e49-u4f2f: 义伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8fd0f8e5-2858-4c3b-8013-c7d715f81f3c', '1e584772-09ba-4d15-bdff-dfb5c4ad34b2', '义伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e5d-u4faf: 九侯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('182b4454-83cc-4f2b-a8cc-4d07996a4330', '8f82fd72-bf8c-4c9a-b920-1e2c721a531c', '九侯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e5d-u4faf-u5973: 九侯女 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e545297d-f4aa-4fec-9c14-9e90933051bf', '48abfa8c-6e65-4508-b86c-363ba3794621', '九侯女', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4ef2-u4f2f: 仲伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('afacb9ef-8b7b-49dc-981b-8e742290de70', '20850745-a1af-49d1-bb0f-7bec11e0a342', '仲伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4f0a-u965f: 伊陟 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d2accf8b-b568-4c73-86e5-f7c21818ac46', '1ed80e86-c057-4d2b-977f-1f499c6ad2e4', '伊陟', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4f2f-u76ca: 伯益 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cff1c8b7-d67b-4d59-b866-05ed50be40e7', '6743e16f-5146-471f-9ed7-632497774605', '伯益', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u4f2f-u76ca: 益
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('093c3fd0-3bdc-481e-b38d-b1b664a2790b', '6743e16f-5146-471f-9ed7-632497774605', '益', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u51a5: 冥 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a579184b-a36e-436b-90e2-7195d6fd889b', '5990ba1c-5b30-4c41-a759-349afbbe343a', '冥', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5357-u5e9a: 南庚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('809cc4ff-d709-41f3-bfa5-680a4d34d0d2', '89961cef-fb71-4cf0-906d-8e062272b716', '南庚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5357-u5e9a: 帝南庚
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('454107e1-bfd0-4400-af6c-18422507396c', '89961cef-fb71-4cf0-906d-8e062272b716', '帝南庚', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u53f8-u9a6c-u8fc1: 司马迁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('20069722-92f6-4a89-983c-663d668c19cf', '7128aa48-c9a1-43a1-a338-383370cd01c2', '司马迁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u53f8-u9a6c-u8fc1: 太史公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5fc91b9e-4bf3-46d8-8822-e205f7ee15d0', '7128aa48-c9a1-43a1-a338-383370cd01c2', '太史公', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u516c: 周公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0d34210b-117e-444d-a23f-06815803f4f3', 'be21116e-6b67-4df9-b3e6-3edab8c7eca6', '周公', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u6210-u738b: 周成王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('680c2bb8-e1ee-47ae-877b-f4569d5be85a', '4f53bf47-41ac-44dc-b0e5-517afd4f6d2b', '周成王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u6210-u738b: 成王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f7c738b3-cb2d-4f74-80a9-3ac4f2519a3d', '4f53bf47-41ac-44dc-b0e5-517afd4f6d2b', '成王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u6587-u738b: 周文王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d24f6ca5-b1d3-4706-924b-38cb38363816', 'e583a2a0-e6e8-4d41-92e0-04450f690375', '周文王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u6587-u738b: 西伯
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('83bdb166-a79c-4580-8285-2f845663624c', 'e583a2a0-e6e8-4d41-92e0-04450f690375', '西伯', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u6b66-u738b: 周武王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('442736cf-3988-4dac-a80e-04912eb526f8', 'e87fbc15-0b9d-4916-9d23-919ca3bdada7', '周武王', NULL, 'posthumous', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u6b66-u738b: 武王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5c612e4f-9f0c-44b4-b534-3a872ab900c7', 'e87fbc15-0b9d-4916-9d23-919ca3bdada7', '武王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u548c-u6c0f: 和氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9c6b7498-5cb8-42b6-bb0e-494f3d0fd008', 'c67494ce-eac5-4524-a8d2-0a8c03d24373', '和氏', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u548c-u6c0f: 和
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('dc631a15-9897-44c1-a046-a6e67d66c262', 'c67494ce-eac5-4524-a8d2-0a8c03d24373', '和', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u548e-u5355: 咎单 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4c566ed6-494c-4ed9-a977-7889fb33c34a', '085afa0a-27c9-4034-87e9-434343bad7f3', '咎单', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5546-u5bb9: 商容 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3704aadc-65bf-497e-bf84-89f4eff36c6d', '2fad187e-d800-4681-9475-610725fa502e', '商容', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5546-u6c64: 商汤 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8a8daefe-4b03-47c6-8e64-bfa0d975c04f', '9df3fee6-c1b9-4b7e-8be5-26403caa16d8', '商汤', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5546-u6c64: 天乙
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('24f77a15-aece-4637-a61b-d97516d63f78', '9df3fee6-c1b9-4b7e-8be5-26403caa16d8', '天乙', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5546-u6c64: 成汤
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ebe6fa2c-501f-45f4-a393-9c867660c0d9', '9df3fee6-c1b9-4b7e-8be5-26403caa16d8', '成汤', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5782: 垂 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e8174766-06d4-4ee9-9943-9cf0547703b1', 'ca247afa-919a-4095-b681-3847685cd8ce', '垂', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5916-u4e19: 外丙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f4622b83-d977-4d2c-8102-ad4e61545147', 'bbfb70fe-0e15-4509-8c47-0ddf373fd9bf', '外丙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5916-u4e19: 帝外丙
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ccb26bb2-b4bd-4ba7-9b63-324a7417aa1a', 'bbfb70fe-0e15-4509-8c47-0ddf373fd9bf', '帝外丙', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u592a-u4e01: 太丁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('efe05834-7ae3-42bb-9d3f-2e3ee3004da6', '4fe29020-b3da-41aa-8812-c045474e34b5', '太丁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u592a-u4e01: 帝太丁
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('155088b5-0db3-4d56-abb3-a233140c9bba', '4fe29020-b3da-41aa-8812-c045474e34b5', '帝太丁', NULL, 'temple', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u592a-u5b97: 太宗 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('70c29189-1502-41ef-a245-b595ed39a9cf', '80145529-2e5e-4234-91a8-6e83c47fd813', '太宗', NULL, 'temple', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u592a-u5e9a: 太庚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('20afb788-97fe-4eb4-958e-a112f486ada0', '8da2df10-2abe-4d81-828a-2b3bd4dcad0d', '太庚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u592a-u5e9a: 帝太庚
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fcc8ce67-8d03-4080-bedc-27c255a349f5', '8da2df10-2abe-4d81-828a-2b3bd4dcad0d', '帝太庚', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u592a-u620a: 太戊 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ce283d5b-74a9-49b2-acd1-20ce0079fc69', 'd8bf838d-daad-4282-97ae-49f671909d28', '太戊', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u592a-u620a: 中宗
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3b05b0d6-e39f-485f-a3f6-bf8d756f5d17', 'd8bf838d-daad-4282-97ae-49f671909d28', '中宗', NULL, 'temple', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u592a-u620a: 帝太戊
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1b3d85c1-ab62-443a-986e-ff46b297c1b6', 'd8bf838d-daad-4282-97ae-49f671909d28', '帝太戊', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5973-u623f: 女房 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9f44438b-f923-49f0-9e38-736b881e9a28', 'a2e28a22-9375-4e29-a295-969035563da3', '女房', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5973-u9e20: 女鸠 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('71f5fcec-793b-4563-845b-30bb629e8cc7', 'eca161d1-ebc5-484e-b5c3-6b3a3e43375c', '女鸠', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u59d2-u6c0f: 姒氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('76dfc387-1890-4689-99fd-8aa8b9f3d0d4', '16e09751-1795-4a4b-a0cf-4b5cb8409004', '姒氏', NULL, 'alias', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b54-u5b50: 孔子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8c3e118d-4975-4d84-b619-7895dd9895ff', 'a387e3b7-5ae1-4869-84ef-6d4f6cb61947', '孔子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5bb0-u4e88: 宰予 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0e24f4e8-851d-4611-8261-9cc4ad490c5e', 'b8ce9615-c7fc-45c9-b5fc-269100b37710', '宰予', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5c0f-u4e59: 小乙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d9ca6f7d-bd0c-4c78-a054-883d11e1e182', 'f701d782-874d-4756-8cce-486d700e2925', '小乙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5c0f-u4e59: 帝小乙
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e343cd06-f73b-4dd9-8028-3a8affdb1cb9', 'f701d782-874d-4756-8cce-486d700e2925', '帝小乙', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5c0f-u7532: 小甲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('007de680-a610-4d21-a472-06be8925c3c9', '4f06d7b1-2ff4-4063-b69a-7fee28dea28e', '小甲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5c0f-u7532: 帝小甲
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('55e37046-3ebc-482f-b360-02175ba79c1f', '4f06d7b1-2ff4-4063-b69a-7fee28dea28e', '帝小甲', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5c0f-u8f9b: 小辛 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d211f2d2-e3d3-4c34-98c8-c369fd3fe788', 'f44b4d81-fa93-4f42-a646-c1f76cd107fb', '小辛', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5c0f-u8f9b: 帝小辛
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7411bd18-a2cd-454d-be23-ee4fb47f1ba3', 'f44b4d81-fa93-4f42-a646-c1f76cd107fb', '帝小辛', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5c11-u66a4-u6c0f: 少暤氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('626f7492-26cc-4246-9c49-50e36aa7f721', '2e9ab3c3-7bc7-48e3-a700-47b237c5eb37', '少暤氏', NULL, 'alias', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5d07-u4faf-u864e: 崇侯虎 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7cfc0f93-3cfc-48cc-8413-cc06c9a07264', 'a54abbd1-05b1-4ab7-b2ce-b8519fcd1078', '崇侯虎', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5deb-u54b8: 巫咸 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d6a881a1-be55-47b8-9f43-47f90acdb3dc', '62092322-6254-48e2-9467-9e65a5e41d87', '巫咸', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5deb-u8d24: 巫贤 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('beee826c-674e-40cd-b373-c233af41ffde', '314c2e92-b8be-444a-8cad-34e2627c091d', '巫贤', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e08-u6d93: 师涓 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8d792615-d812-473e-b00c-2e588c60345f', '6ac54d78-abbd-4e78-b417-06fe22811f8b', '师涓', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u4e0d-u964d: 帝不降 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('85c608d5-0199-422e-b600-dd94629a8b46', '0e30735f-6d22-4574-9920-171bce1eae14', '帝不降', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u4e2d-u4e01: 帝中丁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a67da7ef-8af3-4792-9409-6624597a192e', '8b81b996-087c-411f-9d30-dd59ca600b11', '帝中丁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5e1d-u4e2d-u4e01: 中丁
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d55065e0-c9b4-40eb-847d-cf7f9ee0ae89', '8b81b996-087c-411f-9d30-dd59ca600b11', '中丁', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u4e59: 帝乙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a71b2738-2196-4af3-8787-2ffa77f6f10b', 'cb277c3d-41ea-40ec-961f-8713034371d9', '帝乙', NULL, 'temple', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u4e88: 帝予 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8efb2d59-83a1-4876-82eb-8cf4330183e1', '2c0c3aa9-3803-4e09-a7cd-be98306e5d34', '帝予', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u53d1: 帝发 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('97cbb36e-1ce8-41ab-96bd-34b15394df06', '9d04cdda-0f60-4073-ae80-44b6311c49b8', '帝发', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u5916-u58ec: 帝外壬 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a828d66d-fc82-4984-9735-e5beec9bfa89', '7a29a307-6bb1-4c04-b2be-34ce1d10f6b1', '帝外壬', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5e1d-u5916-u58ec: 外壬
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d04358fa-41db-4d50-a9e5-33d97a169d77', '7a29a307-6bb1-4c04-b2be-34ce1d10f6b1', '外壬', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u5e9a-u4e01: 帝庚丁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('54aa8a38-72af-4ea7-bdb0-4a286378f8da', 'b1b69239-f9f4-4d3c-af0a-d8ecd54ffcb3', '帝庚丁', NULL, 'posthumous', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5e1d-u5e9a-u4e01: 庚丁
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('bc1fe57e-464e-491f-9b17-83666faf0b7b', 'b1b69239-f9f4-4d3c-af0a-d8ecd54ffcb3', '庚丁', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u5ed1: 帝廑 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('45ffc3dd-7703-4715-bb77-588d2e59ded4', 'b1a062a0-1dc2-42f7-b8e9-c67496f6bac2', '帝廑', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u5eea-u8f9b: 帝廪辛 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('080f4ba4-27f0-45fd-9294-8b8cd6891f16', 'f9e7ee84-007f-434e-95e3-bcc94184211e', '帝廪辛', NULL, 'posthumous', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u6243: 帝扃 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1025ae21-2252-4a40-a756-82d1a5b41b26', '31c34676-b8ea-492f-a8ce-7650e8363e5e', '帝扃', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u631a: 帝挚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('503c6f30-828e-4739-9d90-a7988849c08f', 'a8d7695f-c9a6-42a6-a01f-527daeb3f191', '帝挚', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5e1d-u631a: 挚
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('02987f1e-ed2c-48dc-a68d-5b3c8d4ca485', 'a8d7695f-c9a6-42a6-a01f-527daeb3f191', '挚', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u69d0: 帝槐 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7c09cd7d-46a6-49ec-95fa-109339f9dad1', 'd2a6fcfa-ce08-4400-9797-6f10a99e4963', '帝槐', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u6b66-u4e59: 帝武乙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('61cef9e3-ffb8-4dad-a6b0-964090ab3c66', '6bc7e23d-dd50-42f3-9f4f-14364fe74e59', '帝武乙', NULL, 'posthumous', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u6cc4: 帝泄 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0a7cfed8-a023-45b4-9fa5-c76194d41c97', '2cca90ac-fc2b-470d-857d-1e61641276ac', '帝泄', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u7532: 帝甲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c767c7d8-88d5-43bc-8e1e-209a600133be', '9ac28aaa-b707-415a-832c-60bea1de7ba1', '帝甲', NULL, 'posthumous', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u768b: 帝皋 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('693ee940-75ac-4846-966f-1cdd96a8cd81', '5d148846-8cd5-40fc-b831-f100d2255387', '帝皋', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u76f8: 帝相 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8b8e67b2-5ffc-4459-b5df-a8fe6aa807f9', '408b9a55-0afd-4c91-8d31-4e85b2727319', '帝相', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5e1d-u76f8: 相
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('364e8621-9599-4223-b806-464a68b511c7', '408b9a55-0afd-4c91-8d31-4e85b2727319', '相', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u8292: 帝芒 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9d427169-1455-45a7-bf2f-889659c0cd6d', 'bebe0656-0ad7-4347-b43b-41dec4d02be8', '帝芒', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u9e3f-u6c0f: 帝鸿氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fada51df-a679-449c-b4c2-08ff9cf7bcb1', '19ef3926-eaf1-42e1-ba4b-f0fc4b9de9dd', '帝鸿氏', NULL, 'alias', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5f03: 弃 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('29c10820-1041-4bcc-a598-706e1e9b7815', 'b33d8c16-006e-46e1-8b34-a1981663ddbc', '弃', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5fae: 微 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('11fe4c8e-aa00-486d-b310-267593f04c50', '436bf856-818a-43fb-b567-4dbafa582cf6', '微', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5fae-u5b50: 微子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e0df3d11-5985-432a-848b-6b340fa8f624', 'efb3377d-cff3-4658-b723-cb472ab9ff1b', '微子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6076-u6765: 恶来 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('69157e6c-95cf-47dc-882e-1805f8c0f9a8', 'cf3bad71-102d-4ce9-8c00-35d2dc1af0d7', '恶来', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u62a5-u4e01: 报丁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('efb04d15-144c-4467-9cd1-1c90d7011903', 'ed3b3b19-bad9-4f2a-93e8-5920dde6fcc3', '报丁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u62a5-u4e19: 报丙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('02727d41-6ed4-4805-93b2-2d64fcc91fdd', '8c725d8e-2dd1-4830-a179-02f3e69051c5', '报丙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u62a5-u4e59: 报乙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d1e10382-43f5-460f-80c7-d9a1f912cc7b', 'e5eacaaa-6910-461e-99a9-13a876eef70a', '报乙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u632f: 振 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0c0a8bdb-a6ea-4ea9-a171-be3044ff4ba7', '4f47836e-dc17-49e6-9ff0-5cc10d484c20', '振', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6606-u543e-u6c0f: 昆吾氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4a876013-8d4e-4be4-a3c0-f467f06ab675', 'be1927a1-1aef-4ae6-9a56-4640fd7c9ab0', '昆吾氏', NULL, 'alias', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u660c-u82e5: 昌若 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1e0ea145-ecf5-4ea5-ad22-457e6909f7e2', 'dc8083af-064f-490d-bad2-2d9960213458', '昌若', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u662d-u660e: 昭明 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8696bd18-3b33-4f02-a83d-aa9667fad418', 'f71793a2-6ce3-4fd6-af8c-e331cc0505db', '昭明', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u66f9-u5709: 曹圉 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e7fb187d-b43f-43fc-b3db-d2bb18d36016', '2e1f9ec6-7463-4efa-8ecd-d7a28e609cfe', '曹圉', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6731-u864e: 朱虎 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4eac7b74-c0c4-49a9-b0e5-5b6d526c2f33', 'c02c2701-7bab-4e22-9437-39e2ccb0ce90', '朱虎', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u68bc-u674c: 梼杌 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('79d04c03-be27-4c0b-98a5-9d08abaed7b8', '673368d9-1523-4a7b-a105-2c7ed6367318', '梼杌', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6b66-u4e59: 武乙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0014e4d4-dff6-44c9-a900-fdd88c8f9c38', 'b45f2e48-f669-4b36-93ed-213e3b36a0eb', '武乙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6b66-u4e59: 帝武乙
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('72ca65a0-eaf9-473e-a2cc-e3894ed64aa4', 'b45f2e48-f669-4b36-93ed-213e3b36a0eb', '帝武乙', NULL, 'temple', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6b66-u5e9a: 武庚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('44a30981-287f-448d-ae5b-190def45dc71', '70e67046-bba3-491e-8f41-64c8b46af1ea', '武庚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6b66-u5e9a: 禄父
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5b7a5672-a079-48c1-a89b-0927171ff8bf', '70e67046-bba3-491e-8f41-64c8b46af1ea', '禄父', NULL, 'courtesy', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6c83-u4e01: 沃丁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('252452af-30e8-44cd-8021-6c78489c59c5', 'c65680a5-8e79-41c8-ad07-7f7fdaffc0e2', '沃丁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6c83-u4e01: 帝沃丁
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f2fa7014-421a-40ea-b5e8-a438d66699e9', 'c65680a5-8e79-41c8-ad07-7f7fdaffc0e2', '帝沃丁', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6c83-u7532: 沃甲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('518f1fe8-6659-4453-9661-b53a1367b570', '479b1fd2-d739-43d2-a7c6-75284b6eaa82', '沃甲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6c83-u7532: 帝沃甲
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('95714bec-988a-4227-bfc5-f02a2dc91adb', '479b1fd2-d739-43d2-a7c6-75284b6eaa82', '帝沃甲', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6cb3-u4eb6-u7532: 河亶甲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9582b70d-3c7d-4ec2-b122-1156008c0cef', '85531e86-3424-4048-a90a-ef090fe9f336', '河亶甲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6cb3-u4eb6-u7532: 帝河亶甲
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0e75f5d4-7348-448a-8b8b-d0b6a84d37b8', '85531e86-3424-4048-a90a-ef090fe9f336', '帝河亶甲', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6d51-u6c8c: 浑沌 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('62151be8-64a2-4853-b1dc-b7322f95bf86', '8f15868e-a5b6-4003-ab74-87a8df633206', '浑沌', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6d82-u5c71-u6c0f: 涂山氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('882e1246-a940-474f-a6be-5b76cdbf308d', '0aff7cb5-0ffd-4097-a2d0-9539c44856d6', '涂山氏', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6d82-u5c71-u6c0f: 涂山
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('33189ffa-58f5-4b08-a057-86d3ad460a9c', '0aff7cb5-0ffd-4097-a2d0-9539c44856d6', '涂山', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6d82-u5c71-u6c0f: 涂山氏之女
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a6e714d6-f5ae-43e1-ae80-d166c7ee2b50', '0aff7cb5-0ffd-4097-a2d0-9539c44856d6', '涂山氏之女', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u718a-u7f74: 熊罴 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('92fb0251-cb52-4f13-ad30-5305a337481b', 'e15a3a4b-5cae-4015-9a11-01d6f39e98f8', '熊罴', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u76f8-u571f: 相土 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9f03fea9-3708-4461-92c9-9f9ff6cf0888', '6e851a98-5b2d-4d3f-93da-9d1794d5d600', '相土', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7956-u4e01: 祖丁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('95c839d6-4a69-4973-a116-33519f510ac1', 'd153de2d-51be-4672-9831-840891edf6a8', '祖丁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u7956-u4e01: 帝祖丁
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('67d8717e-4a0f-4aa1-9886-95bb6b40539b', 'd153de2d-51be-4672-9831-840891edf6a8', '帝祖丁', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7956-u4e59: 祖乙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('434f70f4-54cd-4bc6-a0d9-8ef1e7f3aef6', 'cc710738-64ef-418f-9895-fe256ea4c9df', '祖乙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u7956-u4e59: 帝祖乙
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3741e448-5b64-4bad-be4a-c8b4ce309f6b', 'cc710738-64ef-418f-9895-fe256ea4c9df', '帝祖乙', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7956-u4f0a: 祖伊 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0a237f20-48e5-42ea-8d72-7b2690008bca', 'ed76029d-aab1-4a46-9f4c-eafaea8be9de', '祖伊', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7956-u5df1: 祖己 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9e11a4ec-8cc9-4690-95ee-ea7b981386c1', '840736ab-900f-4ebd-b7a9-b3475ab89d5f', '祖己', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7956-u5e9a: 祖庚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('aca9fee1-047f-4e6c-8e66-740e01d64010', '179a1a4f-6409-4315-8418-67266a664858', '祖庚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u7956-u5e9a: 帝祖庚
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2295c979-bb26-4014-866a-487f63ec0212', '179a1a4f-6409-4315-8418-67266a664858', '帝祖庚', NULL, 'temple', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7956-u7532: 祖甲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1d98e7e0-f86e-4032-b309-16123a5b012e', '3f3ec17b-d7ae-434e-a919-fe3ade0af69f', '祖甲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u7956-u7532: 帝甲
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('720fd8b3-9840-4c23-b191-a6650908699d', '3f3ec17b-d7ae-434e-a919-fe3ade0af69f', '帝甲', NULL, 'temple', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7956-u8f9b: 祖辛 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d6bfbbaa-6827-46db-9dba-6cd0d0274046', 'ed306319-a294-43af-bdb7-184d1c1c4f56', '祖辛', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u7956-u8f9b: 帝祖辛
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('21206474-7bb5-41e1-9bcc-06c4ddec924c', 'ed306319-a294-43af-bdb7-184d1c1c4f56', '帝祖辛', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7a77-u5947: 穷奇 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('281c6d5f-4416-44a0-b1ab-d3a934789d5e', '923f754d-2767-4698-9ef6-4c2b0f9701fc', '穷奇', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7ba1-u53d4: 管叔 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('237db603-99c8-42cb-b94a-e6c6ce79cee8', '6371d326-0731-4488-bf85-243ea3fcc5e1', '管叔', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7f19-u4e91-u6c0f: 缙云氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a59d23fa-f749-4de1-8621-681cb273e85e', 'ae47eddd-804b-4715-974a-d1eb99a19509', '缙云氏', NULL, 'alias', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7fb2-u6c0f: 羲氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('eb3b00c6-3503-42b7-acbe-34c414396e56', '411ee7c8-a7fe-4f0b-8018-d1e63b0440bf', '羲氏', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u7fb2-u6c0f: 羲
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a7eaaada-0b73-4fb8-818a-a7a252ddf8b7', '411ee7c8-a7fe-4f0b-8018-d1e63b0440bf', '羲', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u80e4: 胤 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ce633e02-6071-4089-a6dd-bd9306745ddd', 'bcc268f7-cdb8-45f6-bc1c-b713335c158a', '胤', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8364-u7ca5: 荤粥 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8f64dbbb-02bc-4ef6-80f3-4ad3c2862f0f', 'b40287a2-64ed-4bc3-83bf-3f51a8e1a48f', '荤粥', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u845b-u4f2f: 葛伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('99ea14ab-8e83-4f58-9d97-554571617895', '15525c10-3e44-4885-a386-37bfb92f02da', '葛伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8521-u53d4: 蔡叔 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('43c69ff9-7e97-4bc0-bf63-577681bc6ce6', '749ac677-2ff0-4dc4-a2e2-1580f163988e', '蔡叔', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8d39-u4e2d: 费中 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('36acea36-248a-41d1-b41e-6c9fdbe0881f', '501f609e-c754-49f6-abcd-b9eb414fa1e3', '费中', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9102-u4faf: 鄂侯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0b2e3ce9-fc7d-432d-a63b-776117ad4a3b', 'ffa19925-910a-4a0e-b4b0-4bc79a4e1956', '鄂侯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u95f3-u592d: 闳夭 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('89bebb9b-b778-4971-ac25-0bf7f4383d0f', '12f8f815-d9ac-46e6-ab39-d0ba778bd0d6', '闳夭', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9633-u7532: 阳甲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('26e579c4-5e5f-4d36-8632-d2cf58eea114', '0abe51f4-21b6-4c4f-9200-0bfc8996712c', '阳甲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9633-u7532: 帝阳甲
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c8d32919-1e16-4d14-b3b6-10f038f72acf', '0abe51f4-21b6-4c4f-9200-0bfc8996712c', '帝阳甲', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u96cd-u5df1: 雍己 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('652394b2-4bd8-4b9f-83bd-2bcbd57ab11a', 'bbb04292-6c55-4710-9599-7d2bc9773e00', '雍己', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u96cd-u5df1: 帝雍己
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a013bbd9-0781-4604-bc18-c4b395f9ccce', 'bbb04292-6c55-4710-9599-7d2bc9773e00', '帝雍己', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9955-u992e: 饕餮 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1663d36c-bf8e-4153-916b-bdc50938c1ba', '0cc1ea00-0a98-4c3a-b7af-c021d69ac6aa', '饕餮', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9a69-u515c: 驩兜 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1c180734-f5e1-4d0d-935b-a0cbcde710c1', '73d7a713-158d-4b92-8de0-f130c267297e', '驩兜', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9a69-u515c: 欢兜
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('041da989-928c-4de9-8eb1-f04976adc451', '73d7a713-158d-4b92-8de0-f130c267297e', '欢兜', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for wei-zi-qi: 微子启 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('41d707b5-437a-4e1d-a971-34621ad5da97', '89ce41bc-f9d2-4ebb-aa9c-de3e4e18abb0', '微子启', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for wei-zi-qi: 启
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('59dfe538-3fa5-48dc-942a-1a0a9be9e896', '89ce41bc-f9d2-4ebb-aa9c-de3e4e18abb0', '启', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for wu-ding: 武丁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('94a67176-b08d-4597-a825-a3ef37ee05e2', '28626579-1c80-4789-b14b-7b9369885397', '武丁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for wu-ding: 帝武丁
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('55d8820b-fcb1-410e-8153-2c9a13d5c56c', '28626579-1c80-4789-b14b-7b9369885397', '帝武丁', NULL, 'temple', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for wu-ding: 王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('77af3b31-a408-4ea6-88ea-39b4623f95eb', '28626579-1c80-4789-b14b-7b9369885397', '王', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for wu-ding: 高宗
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('36dd52c9-38da-482b-a803-6674111dbdc0', '28626579-1c80-4789-b14b-7b9369885397', '高宗', NULL, 'temple', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for xiang: 象 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ad336f35-7e2d-4c08-aadb-79d79985f7d5', '0cdfa4af-4767-484f-a678-426a035a781c', '象', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for xi-bo-chang: 西伯昌 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('553cffc3-cbad-4485-9312-31ed89fac006', 'cc6fe4f8-3f8c-4620-ade4-61ec6cd672a1', '西伯昌', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for xi-bo-chang: 西伯
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1802d2c9-963f-4859-ac20-95e3684a46a8', 'cc6fe4f8-3f8c-4620-ade4-61ec6cd672a1', '西伯', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for xie: 契 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('bca03024-b706-41eb-9b97-9ce6cf299b93', '10ccab31-8acf-4d89-9e85-accc4eda7787', '契', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for xie: 殷契
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('791683e1-789b-4c1b-8cf9-47101a869b2f', '10ccab31-8acf-4d89-9e85-accc4eda7787', '殷契', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for xi-shu: 羲叔 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('13c81493-f3df-4048-900e-c0d2fd49bfcd', '64e7b89d-b0c6-4e8b-8d67-5ebde716b623', '羲叔', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for xi-zhong: 羲仲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('39f628ba-aea4-4148-979c-31ea2878ab99', 'bd91336a-400f-43c8-a430-0835a9607aa7', '羲仲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for xuan-xiao: 玄嚣 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8edb1c40-adac-4f65-bf13-1cc5f2e1d565', 'd946e274-3979-40b5-a01d-e044ff05660c', '玄嚣', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for xuan-xiao: 青阳
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('93ebbec1-9d0f-4696-98c2-617b90b2b9cf', 'd946e274-3979-40b5-a01d-e044ff05660c', '青阳', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for yan-di: 炎帝 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('944cd706-901c-4dce-b936-29e4886af6ec', '5f41c43c-db30-44c5-a6b0-3608b70e2438', '炎帝', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for yao: 尧 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ca8ac1e1-a8b3-4da8-bea1-5c5a5ef50ba6', '2da772b8-3c0b-4e13-9452-5e85ae34bf26', '尧', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yao: 帝
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('34bde727-66e5-4d23-a1b1-d309e19cc06d', '2da772b8-3c0b-4e13-9452-5e85ae34bf26', '帝', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yao: 帝尧
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8ea51ac9-1979-4ffe-8263-d9eaee4b69cb', '2da772b8-3c0b-4e13-9452-5e85ae34bf26', '帝尧', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yao: 帝舜
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a8396067-0d73-4278-bee3-1589f77bb3a4', '2da772b8-3c0b-4e13-9452-5e85ae34bf26', '帝舜', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yao: 放勋
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b0d91237-009e-434f-b2a4-f3db62aa6bd8', '2da772b8-3c0b-4e13-9452-5e85ae34bf26', '放勋', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yao: 陶唐
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('20b4eeff-393d-4f79-ba84-27a93a355cf3', '2da772b8-3c0b-4e13-9452-5e85ae34bf26', '陶唐', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for yi: 益 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a124469b-fb47-44b8-bd88-3e72e51ea42e', 'ea880e29-01ac-40ed-b4f3-5f1f9da8814a', '益', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for yi-yin: 伊尹 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7fa30be1-c044-47cc-84bf-c29d0b415e9c', '02ee394b-9b9c-442c-ba7e-a8c7d2b1c05e', '伊尹', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yi-yin: 阿衡
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0420d97b-5018-433b-a3cf-8f4a75ef7c38', '02ee394b-9b9c-442c-ba7e-a8c7d2b1c05e', '阿衡', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for yu: 禹 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('750fb490-b34d-4481-a77f-24bd6024582f', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '禹', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yu: 伯禹
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('aa8a7a3b-7741-4481-9f53-c19e06677921', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '伯禹', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yu: 夏后
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('90cc77e2-14d7-461f-9ede-b3f35bc16ae1', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '夏后', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yu: 夏禹
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('73992d0a-e4db-4e18-9a03-609d0be19f1b', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '夏禹', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yu: 大禹
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('28bfe26f-29fd-4f8e-b36f-e30b8d4fcc13', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '大禹', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yu: 姒
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('80846d25-e83b-4722-b3b1-cfd0fd50c2ac', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '姒', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yu: 帝禹
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7f468473-b594-4140-bdb7-f11806cf914b', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '帝禹', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yu: 文命
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('31be7b4c-42cd-4d62-a77a-6f6191630fa2', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '文命', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for zhong-kang: 中康 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('749694c1-2bc4-425e-b517-19d9b4ea78dc', '3dad64e2-c955-4d0f-b845-cdbc21ce84df', '中康', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhong-kang: 帝中康
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1d273d04-7a07-4d41-8cd4-cd9739f7da60', '3dad64e2-c955-4d0f-b845-cdbc21ce84df', '帝中康', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for zhou-xin: 纣 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('30ac4c4b-daed-4e00-9b35-e0e396c328ab', '9d46a8fd-ae53-4b95-ace4-0892e92c94ec', '纣', NULL, 'posthumous', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhou-xin: 帝纣
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d12dcd0c-0276-4ddd-9d35-462cce831765', '9d46a8fd-ae53-4b95-ace4-0892e92c94ec', '帝纣', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhou-xin: 帝辛
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b7122206-f1cb-4e2a-a679-09779ed6b782', '9d46a8fd-ae53-4b95-ace4-0892e92c94ec', '帝辛', NULL, 'temple', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhou-xin: 辛
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1160cf2e-f323-44e8-9faa-72a7b4113a0a', '9d46a8fd-ae53-4b95-ace4-0892e92c94ec', '辛', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for zhuan-xu: 颛顼 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9974f033-d83d-43d0-a1f5-9aa46279db43', 'c26a5df8-35d3-4339-a520-c56f3fe26b11', '颛顼', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhuan-xu: 帝颛顼
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('94297d6f-c99c-4da3-b642-0ff59b741d6b', 'c26a5df8-35d3-4339-a520-c56f3fe26b11', '帝颛顼', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhuan-xu: 帝颛顼高阳
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f39eeafc-b0b2-4faa-b32a-938b93bfe92b', 'c26a5df8-35d3-4339-a520-c56f3fe26b11', '帝颛顼高阳', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhuan-xu: 颛顼氏
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('30c5ce05-eafd-4edd-97ca-1ad91b4bc456', 'c26a5df8-35d3-4339-a520-c56f3fe26b11', '颛顼氏', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhuan-xu: 高阳
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('60b65d0d-456b-40a8-9487-6b058bea3456', 'c26a5df8-35d3-4339-a520-c56f3fe26b11', '高阳', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhuan-xu: 高阳氏
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6aa66522-d176-4af7-9713-72dfd3ed5f7d', 'c26a5df8-35d3-4339-a520-c56f3fe26b11', '高阳氏', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

COMMIT;
