-- HuaDian Pipeline Seed Dump
-- Generated: 2026-04-24T16:43:27.169643+00:00
-- Book ID: 6c8df42d-df09-4d5d-8d59-1663cf1a74a5
-- Prompt: ner/v1-r4
-- Model: claude-sonnet-4-6
-- Total cost: $0.8260
-- Persons: 585

BEGIN;

-- ============================================================
-- persons
-- ============================================================

-- Person: 百里奚 (bai-li-xi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8e9ed2e2-65e5-47be-b6de-8f321275a726', 'bai-li-xi', '{"zh-Hans": "百里奚"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "其谏言未被穆公采纳，致使三将兵败"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 白起 (bai-qi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7022b479-f8fa-4be2-ba14-7c396849a160', 'bai-qi', '{"zh-Hans": "白起"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦国名将，屡立战功，后因罪被贬为士伍并赐死"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 白乙丙 (bai-yi-bing)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('27961404-6aea-4f84-aa22-e81fc25688a5', 'bai-yi-bing', '{"zh-Hans": "白乙丙"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受命与孟明视、西乞术同将兵袭郑"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 褒姒 (bao-si)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('599b25fb-44d7-47d9-96c0-03f5aca26d28', 'bao-si', '{"zh-Hans": "褒姒"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "幽王宠妃，幽王为其废太子，立其子为嗣"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 比干 (bi-gan)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c74a2aac-841b-4816-89c8-26c8063abde7', 'bi-gan', '{"zh-Hans": "比干"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "商王子，被纣所杀 商朝忠臣，武王命闳夭封其墓"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伯夷 (bo-yi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ec440301-5a6f-4d5b-86bf-1f1dabcaf5ff', 'bo-yi', '{"zh-Hans": "伯夷"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "孤竹国人，闻西伯善养老而往归之"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 昌仆 (chang-pu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b1a6ecae-5d13-476f-b8e5-3541b689921b', 'chang-pu', '{"zh-Hans": "昌仆"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "蜀山氏之女，昌意之妻，生高阳"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 常先 (chang-xian)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5c131454-8f7e-4b63-8f0f-cf49c4ec6159', 'chang-xian', '{"zh-Hans": "常先"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被黄帝举用以治民的贤臣之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 昌意 (chang-yi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1c404625-59ff-47a9-a239-097e432ad822', 'chang-yi', '{"zh-Hans": "昌意"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "颛顼之父，黄帝之子，禹之曾大父，未得帝位为人臣"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蚩尤 (chi-you)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('abf65a85-0faf-4ad3-a3dc-c7d04e5aceda', 'chi-you', '{"zh-Hans": "蚩尤"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "汤诰中被引为反面典型，与其大夫作乱百姓，被帝所弃"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 倕 (chui)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2595b9c9-b30f-4701-a553-a1d2a83895e4', 'chui', '{"zh-Hans": "倕"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "自尧时举用，列于群臣之中"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 樗里疾 (chu-li-ji)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('fd3cd100-04c0-47c8-8d2f-a112dd44da68', 'chu-li-ji', '{"zh-Hans": "樗里疾"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "攻魏焦使其降，又虏赵将庄，并助韩攻齐 与甘茂同为秦初置丞相时的左右丞相，后相韩 昭襄王七年去世"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 楚庄王 (chu-zhuang-wang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b703a0a6-7a59-4c2d-917a-5e7925285a9d', 'chu-zhuang-wang', '{"zh-Hans": "楚庄王"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "强盛北进至雒，问鼎周室 服郑后北败晋兵于河上，称霸会盟诸侯"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 大费 (da-fei)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3ce918d0-a9b2-4520-8342-cef32f03301a', 'da-fei', '{"zh-Hans": "大费"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "女华之子，辅佐禹平水土，佐舜调驯鸟兽，被赐姓嬴氏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 大鸿 (da-hong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1d6cd4d4-e9c8-4d14-8d48-cc4c5714e87d', 'da-hong', '{"zh-Hans": "大鸿"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被黄帝举用以治民的贤臣之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 妲己 (da-ji)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('309c1421-c0b5-4cb7-8d55-aaecd5a532e0', 'da-ji', '{"zh-Hans": "妲己"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "纣王所爱宠妃，纣从其言行事 被周武王杀死"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 丹朱 (dan-zhu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('46add4d2-e583-449a-8ad4-2732b43b9618', 'dan-zhu', '{"zh-Hans": "丹朱"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被帝告诫禹勿效仿其傲慢放纵之行"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝喾 (di-ku)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('fa14f49f-8dbc-4f3f-a04c-b67df9a5b4e7', 'di-ku', '{"zh-Hans": "帝喾"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "姜原之夫，弃之父"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 放齐 (fang-qi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9f8e4f38-6c25-47a6-9a2b-72fb9f068f64', 'fang-qi', '{"zh-Hans": "放齐"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "向帝推荐胤子朱启明，认为其可登庸"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 非子 (fei-zi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2392b897-452d-4096-889f-cf84b3f0570e', 'fei-zi', '{"zh-Hans": "非子"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "大骆之子，因造父之宠蒙赵城，姓赵氏 居犬丘，善养马，被孝王封邑于秦，赐号秦嬴，续嬴氏祀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 风后 (feng-hou)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('981f922d-5697-4b1b-b427-e8f66bd8de9d', 'feng-hou', '{"zh-Hans": "风后"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被黄帝举用以治民的贤臣之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 傅说 (fu-yue)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('39081f94-bd83-4196-87cc-2f766cc31830', 'fu-yue', '{"zh-Hans": "傅说"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被武丁梦见，得于傅险，原为胥靡筑役，后被举为相，以傅险为姓"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 甘茂 (gan-mao)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('65e8d7d2-ef7b-4ad4-969c-1c67ff63f100', 'gan-mao', '{"zh-Hans": "甘茂"}'::jsonb, '战国·秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与樗里疾同为左右丞相，受命与庶长封伐宜阳 昭襄王元年出走至魏国"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 皋陶 (gao-yao)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('041aef60-51bd-4509-88b2-d41969f80805', 'gao-yao', '{"zh-Hans": "皋陶"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "禹谦让司空之职时所推举的人选之一 被帝命为士，掌管五刑五流之法"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 共工 (gong-gong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0fa67188-558b-4622-8d67-2205c3f6ef72', 'gong-gong', '{"zh-Hans": "共工"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被驩兜举荐，帝斥其静言庸违、象恭滔天 被流放于幽洲，列四罪之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 句望 (gou-wang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3f93f19e-b6c9-4d22-9a55-01c091b7f23b', 'gou-wang', '{"zh-Hans": "句望"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "桥牛之父，敬康之子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 管仲 (guan-zhong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('01561739-d388-49b8-925b-d2f0558aff62', 'guan-zhong', '{"zh-Hans": "管仲"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "齐国名臣，与隰朋同年去世"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 古公亶父 (gu-gong-dan-fu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('174458b8-eb08-4bb2-bbb4-3a1a27785e86', 'gu-gong-dan-fu', '{"zh-Hans": "古公亶父"}'::jsonb, '先周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "复修后稷、公刘之业，积德行义，率民迁岐，贬戎狄之俗，营建城郭 周族首领，欲立季历以传位于昌，预言昌将兴周 去世后由季历继位 文王所效法之法度的制定者之一 被文王追尊为太王，王瑞自其兴起"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 鲧 (gun)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2654bbc9-aa0e-4f85-b99b-2f593d08bc84', 'gun', '{"zh-Hans": "鲧"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被四岳举荐治水，帝以其方命圮族而疑之，岳请试用 被殛于羽山，列四罪之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 瞽叟 (gu-sou)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ed16177a-3f8d-49d0-89d8-aad52d591dc1', 'gu-sou', '{"zh-Hans": "瞽叟"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "舜之父，桥牛之子 舜之父，目盲，偏爱后妻之子，常欲杀舜 舜之父，顽劣，欲杀舜 舜之父，多次谋害舜，纵火焚廪、填井欲杀之 舜之父，舜践帝位后仍以子道往朝之"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 和叔 (he-shu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('62f42495-d83e-4c58-a905-e43e655c8465', 'he-shu', '{"zh-Hans": "和叔"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受命居朔方幽都，主掌北方冬季历法授时"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 和仲 (he-zhong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5cf16973-6ab3-4df3-a493-57a1b19f0632', 'he-zhong', '{"zh-Hans": "和仲"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受命居西方昧谷，主掌西方秋季历法授时"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 后稷 (hou-ji)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('709a5ab7-7bb3-4091-a80f-d209caaf5a48', 'hou-ji', '{"zh-Hans": "后稷"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "周族始祖，卒后由子不窋继立 周族始祖，古公亶父所效法复修之先业 文王所遵循的先祖之业的开创者 周之先王世代继承后稷之职，服事虞夏 《颂》中所颂之人，能配天、立民，布利于周"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 黄帝 (huang-di)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3197e202-55e0-4eca-aa91-098d9de33bc9', 'huang-di', '{"zh-Hans": "黄帝"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "由余论政时提及，称其作礼乐法度以先天下"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 简狄 (jian-di)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('340d8d24-c305-4f0e-b517-3f8460dc0b28', 'jian-di', '{"zh-Hans": "简狄"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "有娀氏之女，帝喾次妃，吞玄鸟卵而生契"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蹇叔 (jian-shu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a1548cd0-a3da-491b-8f7f-4c1376ce627c', 'jian-shu', '{"zh-Hans": "蹇叔"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "百里傒之贤友，多次劝止百里傒免于祸难，后被秦缪公迎为上大夫 劝谏穆公不可袭郑，哭送出征之子西乞术 其谏言未被穆公采纳，致使三将兵败 其谋未被缪公采用，缪公誓师时追悔"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蟜极 (jiao-ji)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6dc49a58-ae29-4938-92bf-15cc8fb705a2', 'jiao-ji', '{"zh-Hans": "蟜极"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝喾之父，玄嚣之子，未得在位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 桀 (jie)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('48cdbfcf-f96b-4623-b5b4-1de19f342fd5', 'jie', '{"zh-Hans": "桀"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "行虐政淫荒，被汤讨伐 败于有娀之虚，奔于鸣条，夏师败绩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 季历 (ji-li)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c8862c58-9eb8-49f4-9792-86ab89eaaadd', 'ji-li', '{"zh-Hans": "季历"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "古公少子，太伯、虞仲让位于他，娶太任生昌 古公之后继位，修古公遗道，行义得诸侯顺服"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 敬康 (jing-kang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1a2a3fba-061f-4bf4-adba-4bd3eb16a861', 'jing-kang', '{"zh-Hans": "敬康"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "句望之父，穷蝉之子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 晋文公 (jin-wen-gong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('022b3f84-4289-475f-a809-c94b892e8be9', 'jin-wen-gong', '{"zh-Hans": "晋文公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与秦缪公共助周襄王复位，败楚于城濮，围郑，三十二年冬卒 其丧未葬之际，秦军趁机破滑，引发崤之战"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 箕子 (ji-zi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('28804aff-e388-4025-951e-ea5bfac7380f', 'ji-zi', '{"zh-Hans": "箕子"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被纣囚禁 被囚之商朝贤臣，武王命召公将其释放 不忍言殷之恶，以存亡国之道及天道作答"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 孔甲 (kong-jia)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('17dcc539-9089-4a1c-adac-d652bdb1cf16', 'kong-jia', '{"zh-Hans": "孔甲"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝不降之子，好鬼神淫乱，致夏后氏德衰，赐刘累姓御龙氏 夏代帝王，其后诸侯多叛夏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 夔 (kui)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('66f1ad60-8174-4ed9-b780-102df2a0609d', 'kui', '{"zh-Hans": "夔"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "伯夷谦让秩宗之职时所推举的人选之一 被命掌管音乐、教导贵族子弟，自言击石拊石可使百兽起舞"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 嫘祖 (lei-zu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b4e47b19-2fa1-46c2-8fb7-3945c9564c3c', 'lei-zu', '{"zh-Hans": "嫘祖"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "西陵氏之女，黄帝正妃，生玄嚣与昌意"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 力牧 (li-mu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('86b04ce2-b0d2-4729-9aea-d38c492f840e', 'li-mu', '{"zh-Hans": "力牧"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被黄帝举用以治民的贤臣之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 刘累 (liu-lei)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8c656cb3-3e73-4c5a-b75a-d8bb825496d2', 'liu-lei', '{"zh-Hans": "刘累"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "陶唐氏之后，学扰龙于豢龙氏，事孔甲，被赐姓御龙氏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 龙 (long)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('91dca574-3049-437a-b777-bfed43d78ae8', 'long', '{"zh-Hans": "龙"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "伯夷谦让秩宗之职时所推举的人选之一 被帝命为纳言，负责夙夜传达帝命"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 吕不韦 (lv-bu-wei)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ffce9f7e-478b-4fe6-917e-db45b42d09f1', 'lv-bu-wei', '{"zh-Hans": "吕不韦"}'::jsonb, '战国·秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "以相国身份奉命诛东周君，尽入其国"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蒙骜 (meng-ao)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bc7d2658-9fdd-4d3e-8a87-5e6f42c7f9b8', 'meng-ao', '{"zh-Hans": "蒙骜"}'::jsonb, '战国·秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "多次率秦军伐韩、赵、魏，后被魏将无忌击败"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 孟明视 (meng-ming-shi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d0ac7c81-d528-469f-9d6b-af4ccda31a2e', 'meng-ming-shi', '{"zh-Hans": "孟明视"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "百里傒之子，受命将兵袭郑 受缪公之命率兵伐晋，战于彭衙"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 盘庚 (pan-geng)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d01e3221-22c5-40fb-a74a-a38d0ffc69c9', 'pan-geng', '{"zh-Hans": "盘庚"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "迁都河南治亳，行汤之政，使殷道复兴 崩后百姓思念，作盘庚三篇以纪念 其政被武王命武庚修行，以安殷民"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 彭祖 (peng-zu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cdae4ce6-714d-4ffc-8c53-2823ca74af69', 'peng-zu', '{"zh-Hans": "彭祖"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "自尧时举用，列于群臣之中"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 启 (qi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('aaa3998f-cad8-4054-9ae4-6d9f5dc40486', 'qi', '{"zh-Hans": "启"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "禹与涂山氏所生之子 禹之子，贤德得天下归心，诸侯去益朝启，遂即天子之位 禹之子，母为涂山氏之女，夏朝君主 伐有扈氏，作甘誓召六卿，遂灭有扈氏，天下咸朝 夏后帝启崩，其子太康继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 桥牛 (qiao-niu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e330634f-161c-4084-902c-a6e1e1a9b33a', 'qiao-niu', '{"zh-Hans": "桥牛"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "瞽叟之父，句望之子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 齐桓公 (qi-huan-gong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1e74495b-7648-4afb-8779-47fe67a52e6c', 'qi-huan-gong', '{"zh-Hans": "齐桓公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被雍廪拥立为齐国君主，齐国由此成为强国 在鄄地会盟诸侯，称霸 率军讨伐山戎，驻军于孤竹 伐楚至邵陵 于葵丘召集诸侯会盟 十八年卒"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦惠文王 (qin-hui-wen-wang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bb59e4cd-6486-4358-87d2-2df4e3b1ba11', 'qin-hui-wen-wang', '{"zh-Hans": "秦惠文王"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "孝公之子，即位后诛杀卫鞅，曾以太子身份犯禁 秦惠文君元年至四年间，诸侯来朝，天子致胙，齐魏称王"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦穆公 (qin-mu-gong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('144a7a2c-4330-480c-a2cb-4cf09245de8f', 'qin-mu-gong', '{"zh-Hans": "秦穆公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "德公少子 元年亲征茅津得胜，四年迎晋女为妇 以五羖羊皮赎回百里傒，授以国政，又厚币迎蹇叔为上大夫 亲自率军伐晋，战于河曲 许夷吾之请，派百里傒送其归晋，后与丕郑谋划，阴用丕豹 晋国请粟，听从百里傒与公孙支之言，决定给予粟食 与晋惠公战于韩地，被围后获救，虏晋君归秦后又释之 怨子圉出逃，迎重耳于楚并厚礼相待，助其返晋为君 将兵助晋文公送周襄王复位，杀王弟带，后又助晋围郑，被郑说服罢兵 不听蹇叔百里傒劝阻，决意发兵袭郑 三将归后素服郊迎，哭言己过，复其官秩并厚待之 再度派孟明视等将兵伐晋，战于彭衙不利而归 接见由余，施离间计使由余归秦，问伐戎之策 率军伐晋，渡河焚船大败晋人，后誓师悔过不用蹇叔百里傒之谋 用由余谋伐戎霸西戎，三十九年卒，从死者百七十七人 康公之父，其卒年与晋襄公同年"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦孝公 (qin-xiao-gong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9c1c50e3-6c4f-4963-960a-89d90a70ca67', 'qin-xiao-gong', '{"zh-Hans": "秦孝公"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "献公之子，四年正月庚寅生，献公卒后即位，时年二十一岁 布惠招贤，下令求奇计强秦，东围陜城，西斩獂王 卫鞅西入秦国求见的对象 采纳卫鞅变法建议，拜鞅为左庶长 秦君，卒后子惠文君立，鞅之变法依托其推行"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦昭襄王 (qin-zhao-xiang-wang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cfefc568-fe69-4625-9629-84fbf0cd7807', 'qin-zhao-xiang-wang', '{"zh-Hans": "秦昭襄王"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦国君主，本段记载其元年至十二年间的大事 五十六年秋卒，子孝文王继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦仲 (qin-zhong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('514927c6-2c90-43d2-b7fb-7aa9fb69df2f', 'qin-zhong', '{"zh-Hans": "秦仲"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "公伯之子，秦国继任君主 被周宣王任命为大夫讨伐西戎，战死于戎"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦庄公 (qin-zhuang-gong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('82cca4dd-aa67-4760-9087-2e6de8a43722', 'qin-zhuang-gong', '{"zh-Hans": "秦庄公"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "居西犬丘，生三子，立四十四年后卒，由襄公继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 穷蝉 (qiong-chan)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2b170470-d8a2-4ebd-a166-cdbd5b913003', 'qiong-chan', '{"zh-Hans": "穷蝉"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "颛顼之子 敬康之父，颛顼之子，自此以下皆为庶人"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 商均 (shang-jun)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('34b568ad-7280-41fa-bd84-83a4d25f29f1', 'shang-jun', '{"zh-Hans": "商均"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "舜之子，禹辞让天下于他，但诸侯皆去之而朝禹"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 商鞅 (shang-yang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('957e9a25-30f6-4fd6-a163-785231f1a3ed', 'shang-yang', '{"zh-Hans": "商鞅"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "劝说孝公变法修刑，最终被拜为左庶长 击魏虏公子卬，因功封列侯，号商君 为秦施法，以黥太子傅师推行法令，孝公卒后被车裂"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 少典 (shao-dian)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c9177893-35ad-48f5-887b-c48d38d6031d', 'shao-dian', '{"zh-Hans": "少典"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "女华之父，大业之岳父"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 少康 (shao-kang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('26d68429-421d-4695-99b7-995150cb77aa', 'shao-kang', '{"zh-Hans": "少康"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝相之子，夏代帝王，崩后由子帝予继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 神农氏 (shen-nong-shi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5187db9f-1864-49f0-97d2-d6cc60b5fd2a', 'shen-nong-shi', '{"zh-Hans": "神农氏"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "武王追思先圣王，褒封其后裔于焦"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 舜 (shun)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f1a7e4d2-41fa-400c-881b-dfb4919e8200', 'shun', '{"zh-Hans": "舜"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "赞赏大费辅禹之功，赐其皂游并姚姓玉女为妻，后赐姓嬴氏 伯翳为其主畜，赐姓嬴"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 叔齐 (shu-qi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2d90798a-563c-4b13-8826-48fb6e2c7640', 'shu-qi', '{"zh-Hans": "叔齐"}'::jsonb, '先周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "孤竹国人，与伯夷同往归西伯"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太伯 (tai-bo)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('da24cfb1-a188-4b56-a441-2a481f1f242d', 'tai-bo', '{"zh-Hans": "太伯"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "古公长子，知父欲立季历传昌，与虞仲奔荆蛮以让位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太甲 (tai-jia)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c01208ae-99a0-4445-8284-6aff6a1703ce', 'tai-jia', '{"zh-Hans": "太甲"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "太丁之子、成汤嫡长孙，由伊尹拥立为帝 即位三年，暴虐不遵汤法，被伊尹放逐于桐宫 居桐宫三年悔过，修德后被伊尹迎回授政，诸侯归附，被称太宗"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太康 (tai-kang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7a21bebe-cb2f-470f-a9a4-7d54876e51e4', 'tai-kang', '{"zh-Hans": "太康"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "启之子，继位后失国，其昆弟五人作五子之歌 崩后由弟中康继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 汤 (tang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('578b71f6-e9aa-4fc3-b8c8-1a7c20a3c910', 'tang', '{"zh-Hans": "汤"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "征伐诸侯，首伐葛伯，发表治国言论并作汤征 被伊尹以滋味游说，后举伊尹任以国政 见猎人张网四面，去其三面，以仁德感化诸侯 兴师伐昆吾与桀，发汤誓，自号武王 伐三嵕，胜夏，践天子位，平定海内 灭夏后归至泰卷陶，还亳作汤诰以令诸侯 改正朔、易服色，尚白，朝会以昼 商朝开国君主，崩后由外丙继位 商朝开国之君，太甲不遵其法度"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 三父 (u4e09-u7236)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8dd91bc0-0e5d-4356-ad8d-2beaf284fb1d', 'u4e09-u7236', '{"zh-Hans": "三父"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与弗忌、威垒共废太子立出子，后又令人贼杀出子 因杀出子被武公诛灭三族"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 不窋 (u4e0d-u7a8b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0bc8f019-378d-40ac-9ed5-6da0cb57d253', 'u4e0d-u7a8b', '{"zh-Hans": "不窋"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "后稷之子，末年因夏政衰失官，奔逃戎狄之间 夏衰弃稷不务，失官而自窜于戎狄之间，仍守德不怠"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 丕豹 (u4e15-u8c79)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('76fc0ab6-c337-4edc-934d-ce98a0ae8b3a', 'u4e15-u8c79', '{"zh-Hans": "丕豹"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "丕郑之子，父被杀后奔秦，劝缪公伐晋，被缪公阴用 劝说穆公趁晋国饥荒出兵伐晋，不与粟 秦穆公命其为将出击晋军"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 丕郑 (u4e15-u90d1)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ba7cb650-3ab7-46e6-82ed-111bf01a7358', 'u4e15-u90d1', '{"zh-Hans": "丕郑"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "奉夷吾命赴秦谢罪背约，后与缪公谋划引重耳入晋，被夷吾所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 世父 (u4e16-u7236)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9587f2ca-6131-42fa-b8ca-62a834f5ee07', 'u4e16-u7236', '{"zh-Hans": "世父"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "庄公长男，誓杀戎王为祖父报仇，让位于弟襄公，后被戎人所虏，岁余归还"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 东周君 (u4e1c-u5468-u541b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('68a7a5a1-fef9-4804-9886-aea64d28ce86', 'u4e1c-u5468-u541b', '{"zh-Hans": "东周君"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "十七年来朝秦 与诸侯谋秦，被吕不韦诛灭，秦赐阳人地以奉其祭祀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 东周惠公 (u4e1c-u5468-u60e0-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('417e76b8-64e2-4837-8013-ca95b75d6830', 'u4e1c-u5468-u60e0-u516c', '{"zh-Hans": "东周惠公"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "惠公少子，受封于巩以奉王室，号东周惠公"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 严君疾 (u4e25-u541b-u75be)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ac9cec6f-aac4-4c4b-889e-99a6bcc400b0', 'u4e25-u541b-u75be', '{"zh-Hans": "严君疾"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "昭襄王元年任秦相"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 中丁 (u4e2d-u4e01)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b7f3b550-95c1-4dd0-aba7-a2ba1634bed2', 'u4e2d-u4e01', '{"zh-Hans": "中丁"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "商王，自其起废嫡立诸弟子，导致九世之乱"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 中壬 (u4e2d-u58ec)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6fc7f1f3-ad30-4f50-b54d-50442be3adde', 'u4e2d-u58ec', '{"zh-Hans": "中壬"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "外丙之弟，继外丙之位，在位四年而崩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 中潏 (u4e2d-u6f4f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0f0e6db9-45eb-4a11-8908-02a384ff2fe2', 'u4e2d-u6f4f', '{"zh-Hans": "中潏"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "蜚廉之父，在西戎保西垂 戎胥轩与郦山之女所生，因亲故归周，保西垂"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 中行氏 (u4e2d-u884c-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f3eb6cc1-0fec-4503-bde3-a735327b05e7', 'u4e2d-u884c-u6c0f', '{"zh-Hans": "中行氏"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋卿，与范氏反晋，兵败亡奔齐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 丰王 (u4e30-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4111e1d2-435b-4183-82d1-f60b051f7dfa', 'u4e30-u738b', '{"zh-Hans": "丰王"}'::jsonb, '西周', 'uncertain', 'ai_inferred', NULL, NULL, '{"zh-Hans": "娶秦襄公女弟缪嬴为妻，疑为戎族首领"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 主壬 (u4e3b-u58ec)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7e488b33-62f5-4969-b453-3987fc1634f5', 'u4e3b-u58ec', '{"zh-Hans": "主壬"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "报丙之子，继立后卒，由子主癸继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 主癸 (u4e3b-u7678)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a8279874-a200-49a7-8e4e-c468219ef32d', 'u4e3b-u7678', '{"zh-Hans": "主癸"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "主壬之子，继立后卒，由子天乙（成汤）继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 义伯 (u4e49-u4f2f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1e584772-09ba-4d15-bdff-dfb5c4ad34b2', 'u4e49-u4f2f', '{"zh-Hans": "义伯"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与仲伯共同作典宝"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 义渠君 (u4e49-u6e20-u541b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('736154aa-3211-4acd-86b9-c5f9c3d490e5', 'u4e49-u6e20-u541b', '{"zh-Hans": "义渠君"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "义渠被县后，义渠君臣服于秦"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 乌获 (u4e4c-u83b7)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b3a9ad73-fbe1-4805-95dc-3c6d4a1e9810', 'u4e4c-u83b7', '{"zh-Hans": "乌获"}'::jsonb, '战国·秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦武王力士，官至大官"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 乐池 (u4e50-u6c60)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('13845cb3-85a5-440e-94c9-f223c07ed0b6', 'u4e50-u6c60', '{"zh-Hans": "乐池"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "七年时任秦国相"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 九侯 (u4e5d-u4faf)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8f82fd72-bf8c-4c9a-b920-1e2c721a531c', 'u4e5d-u4faf', '{"zh-Hans": "九侯"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "三公之一，献女于纣，因女不喜淫被杀，自身被醢"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 九侯女 (u4e5d-u4faf-u5973)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('48abfa8c-6e65-4508-b86c-363ba3794621', 'u4e5d-u4faf-u5973', '{"zh-Hans": "九侯女"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "九侯之女，入宫于纣，因不喜淫被纣所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 亚圉 (u4e9a-u5709)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('426bc5b9-b846-4c99-a82a-3dc4d5ad9d93', 'u4e9a-u5709', '{"zh-Hans": "亚圉"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "高圉之子，卒后由子公叔祖类继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 亳王 (u4eb3-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('006756ba-3604-4aa1-a170-cf522a2f83f7', 'u4eb3-u738b', '{"zh-Hans": "亳王"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与秦战败后奔戎"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 仲伯 (u4ef2-u4f2f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('20850745-a1af-49d1-bb0f-7bec11e0a342', 'u4ef2-u4f2f', '{"zh-Hans": "仲伯"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与义伯共同作典宝"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 仲山甫 (u4ef2-u5c71-u752b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d3a7a7ff-1263-40d6-95ce-f1b219281ae6', 'u4ef2-u5c71-u752b', '{"zh-Hans": "仲山甫"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "谏宣王不可料民，但未被采纳"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 仲行 (u4ef2-u884c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('26b4a7ff-5b99-4343-8457-5341cf8eac48', 'u4ef2-u884c', '{"zh-Hans": "仲行"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "子舆氏三良之一，随秦缪公从死"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 任鄙 (u4efb-u9119)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('53d5b17f-98d9-4f3c-9d2c-18a4f892f92a', 'u4efb-u9119', '{"zh-Hans": "任鄙"}'::jsonb, '战国·秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦武王力士，官至大官 为汉中守，二十年卒"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伊陟 (u4f0a-u965f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1ed80e86-c057-4d2b-977f-1f499c6ad2e4', 'u4f0a-u965f', '{"zh-Hans": "伊陟"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "太戊之相，劝帝修德以应祥桑之异，被太戊赞于庙而辞让臣位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伍子胥 (u4f0d-u5b50-u80e5)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('53907bb5-fa99-467d-8cda-d813d57bbe3a', 'u4f0d-u5b50-u80e5', '{"zh-Hans": "伍子胥"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "楚平王欲诛太子建时奔吴，后随吴王阖闾伐楚入郢"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伯与 (u4f2f-u4e0e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('88b58309-e730-4e12-9be8-06646b876308', 'u4f2f-u4e0e', '{"zh-Hans": "伯与"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "垂谦让共工之职时所推举的人选之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伯士 (u4f2f-u58eb)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b88b8afc-3dbf-4e2c-8194-6d9fc7af458c', 'u4f2f-u58eb', '{"zh-Hans": "伯士"}'::jsonb, '西周', 'uncertain', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与大毕并称，其终后犬戎氏仍以职来王"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伯服 (u4f2f-u670d)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('601401f6-cb13-429f-b74d-cef7132bd45d', 'u4f2f-u670d', '{"zh-Hans": "伯服"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "褒姒所生之子，被幽王立为太子 周王使者，奉命赴郑请滑，被郑文公囚禁"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伯翳 (u4f2f-u7ff3)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ab395f42-126a-4409-85e2-0867e02fe9d3', 'u4f2f-u7ff3', '{"zh-Hans": "伯翳"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "为舜主畜，畜多息，被赐姓嬴，为非子先祖"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伯臩 (u4f2f-u81e9)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('04315466-58af-4a52-89dd-fa0d6af076e6', 'u4f2f-u81e9', '{"zh-Hans": "伯臩"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受穆王之命申诫太仆，作臩命"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伯阳 (u4f2f-u9633)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('13b74d99-7f3d-4603-a048-91c1f2ea97aa', 'u4f2f-u9633', '{"zh-Hans": "伯阳"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "周太史，读史记后断言周将亡，后又言祸已成"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伯阳甫 (u4f2f-u9633-u752b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f1f1d224-c8d2-4383-aac9-4b5f305ccbfb', 'u4f2f-u9633-u752b', '{"zh-Hans": "伯阳甫"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "预言三川地震乃周将亡之兆，论阴阳失序与国亡之关系"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 儋 (u510b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('fbd9f46f-c652-4d14-ac8a-54fdf45e5b08', 'u510b', '{"zh-Hans": "儋"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "周太史，谒见献公，预言周秦合分及霸王出世"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 公伯 (u516c-u4f2f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f60fa67d-3037-4e31-92fa-bbf0ce6d7afd', 'u516c-u4f2f', '{"zh-Hans": "公伯"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦侯之子，在位三年而卒，生秦仲"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 公刘 (u516c-u5218)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c5a918e2-2022-440f-bdeb-4293c7995dcc', 'u516c-u5218', '{"zh-Hans": "公刘"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "鞠之子，在戎狄间复修后稷农业之业，周道兴起自此始 周先祖，古公亶父所效法复修之先业 文王所遵循的先祖之业的传承者"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 公叔祖类 (u516c-u53d4-u7956-u7c7b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9da3b0c4-8d15-4100-b553-0eb99a81f9f8', 'u516c-u53d4-u7956-u7c7b', '{"zh-Hans": "公叔祖类"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "亚圉之子，卒后由子古公亶父继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 公子卬 (u516c-u5b50-u536c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b9d51ed8-a76a-471e-a2cb-4fd1e66791a2', 'u516c-u5b50-u536c', '{"zh-Hans": "公子卬"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "魏国公子，被卫鞅击败俘虏 与魏战，虏将龙贾，斩首八万"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 公子咎 (u516c-u5b50-u548e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('25dab0d1-1165-45ca-840d-a36acee38c44', 'u516c-u5b50-u548e', '{"zh-Hans": "公子咎"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "西周武公庶子之一，最终被立为太子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 公子少官 (u516c-u5b50-u5c11-u5b98)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bc2a7260-4511-445e-8709-4003b1a67580', 'u516c-u5b50-u5c11-u5b98', '{"zh-Hans": "公子少官"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦使其率师会诸侯于逢泽，朝见天子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 公子市 (u516c-u5b50-u5e02)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c9f93c52-3dfc-42c9-9885-6451b018e7b9', 'u516c-u5b50-u5e02', '{"zh-Hans": "公子市"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "十六年封宛为诸侯"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 公子悝 (u516c-u5b50-u609d)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('10024d6d-229b-41e1-aeba-6ca23e751c15', 'u516c-u5b50-u609d', '{"zh-Hans": "公子悝"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "十六年封邓为诸侯，四十五年出国，未至而死"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 公子翬 (u516c-u5b50-u7fec)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9b600e45-5a57-483d-82b2-9fe778383381', 'u516c-u5b50-u7fec', '{"zh-Hans": "公子翬"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "鲁国公子，弑杀其君隐公"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 公子通 (u516c-u5b50-u901a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('04866e08-57ce-4459-a2a8-8522f03fe014', 'u516c-u5b50-u901a', '{"zh-Hans": "公子通"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被封于蜀地"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 公孙喜 (u516c-u5b59-u559c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cdf5ec1d-75c6-454b-bdc0-6d7164af0fd0', 'u516c-u5b59-u559c', '{"zh-Hans": "公孙喜"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "魏国将领，参与联军攻楚方城 伊阙之战中被白起俘虏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 公孙支 (u516c-u5b59-u652f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1158ad02-67b3-4f55-884e-b09bd5a6922a', 'u516c-u5b59-u652f', '{"zh-Hans": "公孙支"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "认为饥穰交替乃常事，主张应当给晋粟"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 公孙无知 (u516c-u5b59-u65e0-u77e5)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('442189d8-779f-4c24-af5b-e7490fc4ebcc', 'u516c-u5b59-u65e0-u77e5', '{"zh-Hans": "公孙无知"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被管至父等人拥立为齐君，后被雍廪所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 公孙痤 (u516c-u5b59-u75e4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('922fdc1a-2eba-4a74-b53c-d0fdaa01cc6e', 'u516c-u5b59-u75e4', '{"zh-Hans": "公孙痤"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "魏晋联军将领，少梁之战中被秦军俘虏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 公非 (u516c-u975e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('babb1c2f-7688-490a-8390-956c07ed74cc', 'u516c-u975e', '{"zh-Hans": "公非"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "毁隃之子，卒后由子高圉继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 共公 (u5171-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2b8b4d73-d627-4e1c-b888-4ae8acf2dc10', 'u5171-u516c', '{"zh-Hans": "共公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "在位五年后卒，其子桓公继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 共王 (u5171-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('80d1a3a7-ae26-4fd7-8e96-d008ec33fb76', 'u5171-u738b', '{"zh-Hans": "共王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "游于泾上，因密康公不献三女，灭密国 辟方之兄，段落中以辟方之父辈身份被提及"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 养由基 (u517b-u7531-u57fa)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('91ec3bfa-e886-4fa8-ab70-7f6b6c5dc7a6', 'u517b-u7531-u57fa', '{"zh-Hans": "养由基"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "楚国善射者，百步穿杨，被引为譬喻说明不知适时而止的危险"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 内史廖 (u5185-u53f2-u5ed6)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('778831d0-6caa-4837-b4dc-04304cd50b27', 'u5185-u53f2-u5ed6', '{"zh-Hans": "内史廖"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦穆公谋臣，献离间由余之计"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 冥 (u51a5)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5990ba1c-5b30-4c41-a759-349afbbe343a', 'u51a5', '{"zh-Hans": "冥"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "曹圉之子，继立后卒，由子振继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 出子 (u51fa-u5b50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f0e68dde-3ef7-4af8-a815-89fbd42ae3b8', 'u51fa-u5b50', '{"zh-Hans": "出子"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "宁公之子，五岁立为君，在位六年被三父等贼杀 被三父等人所杀，武公为其复仇诛三父 在位二年被杀，与其母同沉于渊旁"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 卓子 (u5353-u5b50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4809e1f5-6271-4e4e-b62a-ba659d4f265d', 'u5353-u5b50', '{"zh-Hans": "卓子"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "荀息所立之晋君，被里克所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 南公揭 (u5357-u516c-u63ed)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('320e99e7-f0d5-4a5d-8d5a-2827457a252d', 'u5357-u516c-u63ed', '{"zh-Hans": "南公揭"}'::jsonb, '战国·韩', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "卒后由樗里疾相韩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 南宫括 (u5357-u5bab-u62ec)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4807c065-52c2-4206-8008-177b28e45f8b', 'u5357-u5bab-u62ec', '{"zh-Hans": "南宫括"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受命散鹿台之财、发钜桥之粟以振贫弱，又与史佚展九鼎保玉"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 南庚 (u5357-u5e9a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('89961cef-fb71-4cf0-906d-8e062272b716', 'u5357-u5e9a', '{"zh-Hans": "南庚"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "沃甲之子，祖丁崩后继位为帝南庚"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 卫康叔 (u536b-u5eb7-u53d4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('df3b0ed4-a1b3-4258-8ca0-7699fefcde4c', 'u536b-u5eb7-u53d4', '{"zh-Hans": "卫康叔"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "武王少弟，收殷余民被封为卫康叔"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 卫康叔封 (u536b-u5eb7-u53d4-u5c01)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f400d227-9909-407b-a2fc-945aec96b334', 'u536b-u5eb7-u53d4-u5c01', '{"zh-Hans": "卫康叔封"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "布兹（铺席）参与祭告仪式"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 厉共公 (u5389-u5171-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8301e32d-186d-4f57-9729-4d9cc57dede9', 'u5389-u5171-u516c', '{"zh-Hans": "厉共公"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦君，在位期间伐大荔、伐义渠，卒后子躁公继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 厉王 (u5389-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a3f85a2d-d93b-498a-9142-9852970fb289', 'u5389-u738b', '{"zh-Hans": "厉王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "夷王之子，好利近荣夷公，不听芮良夫谏，终以荣公为卿士"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 厘王 (u5398-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('93598628-fd40-44d5-81fd-337c0d696117', 'u5398-u738b', '{"zh-Hans": "厘王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "庄王之子，继位为周厘王，在位第三年齐桓公开始称霸 崩后由子惠王阆继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 去疾 (u53bb-u75be)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('74c589ed-6ffe-4741-9997-bc471a29d4aa', 'u53bb-u75be', '{"zh-Hans": "去疾"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "定王长子，立三月后被弟叔袭杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 叔 (u53d4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('37d94958-4a57-4437-a2e7-be1a9a692c17', 'u53d4', '{"zh-Hans": "叔"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "定王之子，袭杀哀王自立，在位五月后被少弟嵬攻杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 叔振铎 (u53d4-u632f-u94ce)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('66a1c45b-23d6-4808-8fc8-1da956e17a04', 'u53d4-u632f-u94ce', '{"zh-Hans": "叔振铎"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "武王之弟，奉陈常车随行"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 召公 (u53ec-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b93e26ca-a089-4cdf-82c7-b22057884c37', 'u53ec-u516c', '{"zh-Hans": "召公"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "左右武王，辅佐继承文王绪业 受武王之命释放箕子 奉命复营洛邑，任保，与周公共同辅政 受成王命与毕公率诸侯辅立太子钊 多次进谏厉王，以防水喻防民之口，劝王广开言路 曾多次谏厉王，国人围其家时以己子代太子使太子得脱 与周公共同摄政，史称共和，后共立太子静为宣王 受成王之命卜居洛邑"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 召公过 (u53ec-u516c-u8fc7)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('210ffdf6-3651-49a6-8998-50a0740826e3', 'u53ec-u516c-u8fc7', '{"zh-Hans": "召公过"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "奉天子之命前往贺秦缪公以金鼓"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 史佚 (u53f2-u4f5a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('abe3c70f-0d13-4d1f-b780-f6e6edb8f839', 'u53f2-u4f5a', '{"zh-Hans": "史佚"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与南宫括共同展示九鼎保玉"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 史厌 (u53f2-u538c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1f4e0897-9e8f-44cc-92f4-b6d837e6860c', 'u53f2-u538c', '{"zh-Hans": "史厌"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "向周君献策，建议借韩秦之间的矛盾为周解困"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 司马梗 (u53f8-u9a6c-u6897)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3852a84b-cae1-43bc-abc4-a3f5f3952dd7', 'u53f8-u9a6c-u6897', '{"zh-Hans": "司马梗"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "四十八年北定太原，尽有韩上党"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 司马翦 (u53f8-u9a6c-u7fe6)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8eb6c44a-c80c-4a57-bcb2-c848c4e0a085', 'u53f8-u9a6c-u7fe6', '{"zh-Hans": "司马翦"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "向楚王建议以地资助公子咎争立太子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 司马迁 (u53f8-u9a6c-u8fc1)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7128aa48-c9a1-43a1-a338-383370cd01c2', 'u53f8-u9a6c-u8fc1', '{"zh-Hans": "司马迁"}'::jsonb, '西汉', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "作者自述，以颂次契之事，采书诗以记成汤以来史事"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 司马错 (u53f8-u9a6c-u9519)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a8aa410d-21b3-42bd-9a18-49aeaae4c241', 'u53f8-u9a6c-u9519', '{"zh-Hans": "司马错"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "奉命伐蜀并将其灭亡 奉命平定蜀侯辉之叛乱 二十七年发陇西，因蜀攻楚黔中，拔之"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 后子针 (u540e-u5b50-u9488)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0efd69d5-121c-49d4-b023-ec72b4f1ddff', 'u540e-u5b50-u9488', '{"zh-Hans": "后子针"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "景公母弟，因被谗言恐诛而奔晋，后归秦"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 向寿 (u5411-u5bff)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4c929cf7-e9fb-42cc-a7f0-24537f8eafdf', 'u5411-u5bff', '{"zh-Hans": "向寿"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "十三年伐韩，取武始"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 吕甥 (u5415-u7525)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3bdc6a18-465a-45e1-a108-f21cc3e7d8fa', 'u5415-u7525', '{"zh-Hans": "吕甥"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋国大臣，丕郑称其为背秦约、杀里克之谋主，疑丕郑有间"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 吕礼 (u5415-u793c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('419f6945-c8b9-472a-8b3a-c798aed141aa', 'u5415-u793c', '{"zh-Hans": "吕礼"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "十九年来自归秦"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 吴王阖闾 (u5434-u738b-u9616-u95fe)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d6e71c63-5fd0-45e5-b43d-e8eab96dde20', 'u5434-u738b-u9616-u95fe', '{"zh-Hans": "吴王阖闾"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与伍子胥伐楚，攻入郢都"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周元王 (u5468-u5143-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('075a775f-c44f-4b9a-847a-6e48fb731a1a', 'u5468-u5143-u738b', '{"zh-Hans": "周元王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "敬王之子，在位八年后崩，由子定王介继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周公 (u5468-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('be21116e-6b67-4df9-b3e6-3edab8c7eca6', 'u5468-u516c', '{"zh-Hans": "周公"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "斋戒祓除，自愿以身代武王受死 摄政当国，平定管蔡武庚之乱，行政七年后归政成王 复卜申视营筑洛邑，以王命告殷遗民，任师，东伐淮夷 其颂中有''载戢干戈，载櫜弓矢''之语，被引以说明先王耀德不观兵之义 与召公共同摄政，史称共和，后共立太子静为宣王 葬于镐东南杜中之毕地"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周公旦 (u5468-u516c-u65e6)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('18513390-791f-44c5-8261-634fa9a62ba8', 'u5468-u516c-u65e6', '{"zh-Hans": "周公旦"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "武王即位后任辅，协助治国 手持大钺夹护武王 武王之弟，封于曲阜，国号鲁 夜间至武王处问其不寐之故，参与谋划定都"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周公黑肩 (u5468-u516c-u9ed1-u80a9)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('10aa9fd0-5e57-4e5b-b5b5-cdc228dcfd3f', 'u5468-u516c-u9ed1-u80a9', '{"zh-Hans": "周公黑肩"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "欲杀庄王以立王子克，事泄被庄王所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周匡王 (u5468-u5321-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('931a167e-1367-4e21-be8f-cd3af627ae36', 'u5468-u5321-u738b', '{"zh-Hans": "周匡王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "顷王之子，在位六年后崩，弟定王瑜继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周厉王 (u5468-u5389-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1f6831b1-1c73-409d-8f0c-1322d4395569', 'u5468-u5389-u738b', '{"zh-Hans": "周厉王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "无道，导致诸侯叛离、西戎反叛王室"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周天子 (u5468-u5929-u5b50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a10b59c2-3c97-40ae-a798-62c91c870a66', 'u5468-u5929-u5b50', '{"zh-Hans": "周天子"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "以晋与周同姓为由，向秦穆公请求释放晋君"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周孝王 (u5468-u5b5d-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('be0ef800-e0de-4c62-98f9-1293131a818d', 'u5468-u5b5d-u738b', '{"zh-Hans": "周孝王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "召非子主马，欲以其为大骆适嗣，后封非子于秦为附庸"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周定王 (u5468-u5b9a-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e9dd5635-452d-4661-a7b3-67668e4f6f5a', 'u5468-u5b9a-u738b', '{"zh-Hans": "周定王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "匡王之弟，继匡王之位为定王 在位期间楚庄王问鼎、围郑等事件发生 在位二十一年后崩，子简王夷继位 元王之子，继位为周定王"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周宣王 (u5468-u5ba3-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2f7a3782-f560-4af5-be5c-0047f71506cb', 'u5468-u5ba3-u738b', '{"zh-Hans": "周宣王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "即位后任命秦仲为大夫伐戎，后召庄公兄弟五人复仇并赐地"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周平王 (u5468-u5e73-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('95764d6b-d7fc-475f-b939-afdfcddc826a', 'u5468-u5e73-u738b', '{"zh-Hans": "周平王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "东迁雒邑，封秦襄公为诸侯，赐岐以西之地"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周幽王 (u5468-u5e7d-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c54236c3-108b-484c-a31e-34967cbcb0bf', 'u5468-u5e7d-u738b', '{"zh-Hans": "周幽王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "用褒姒废太子，立褒姒子为嗣，数欺诸侯，被西戎犬戎与申侯所杀于郦山下"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周庄王 (u5468-u5e84-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b63a5ca9-4ac4-4120-9f28-1b0310347745', 'u5468-u5e84-u738b', '{"zh-Hans": "周庄王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "富辰所列曾受郑劳之周王之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周康王 (u5468-u5eb7-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c940e469-3d24-4ba0-b68e-97e68693ce9a', 'u5468-u5eb7-u738b', '{"zh-Hans": "周康王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "宣王修政所效法的先王之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周悼王 (u5468-u60bc-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2d788ceb-e577-479d-8f02-0dc45ca87507', 'u5468-u60bc-u738b', '{"zh-Hans": "周悼王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "景王长子，国人立为王，后被子朝攻杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周惠王 (u5468-u60e0-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6608abd7-5a51-4f3c-9d78-61e710257fbc', 'u5468-u60e0-u738b', '{"zh-Hans": "周惠王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "富辰所列曾受郑劳之周王之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周成王 (u5468-u6210-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4f53bf47-41ac-44dc-b0e5-517afd4f6d2b', 'u5468-u6210-u738b', '{"zh-Hans": "周成王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "孟增受其宠幸"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周敬王 (u5468-u656c-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7d77c554-a099-4715-8735-58aa042326b5', 'u5468-u656c-u738b', '{"zh-Hans": "周敬王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "景王之子，晋人攻子朝后立丐为敬王 在位四十二年后崩，由子元王仁继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周景王 (u5468-u666f-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7d5df00d-600e-4bca-8ded-2c5b6be279b0', 'u5468-u666f-u738b', '{"zh-Hans": "周景王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "灵王之子，在位二十年后崩，欲立子朝而未果"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周桓王 (u5468-u6853-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ccebe8f3-2d91-4e4b-9778-1ec692b95edf', 'u5468-u6853-u738b', '{"zh-Hans": "周桓王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "不礼郑庄公，后伐郑被射伤而归 富辰所列曾受郑劳之周王之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周武王 (u5468-u6b66-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e87fbc15-0b9d-4916-9d23-919ca3bdada7', 'u5468-u6b66-u738b', '{"zh-Hans": "周武王"}'::jsonb, '周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "伐纣时并杀恶来"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周相国 (u5468-u76f8-u56fd)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e65483a9-32a2-4f53-a7a9-c7395f29b67b', 'u5468-u76f8-u56fd', '{"zh-Hans": "周相国"}'::jsonb, '战国', 'uncertain', 'ai_inferred', NULL, NULL, '{"zh-Hans": "周令其出使秦国，被客劝说应急见秦王以取重"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周穆王 (u5468-u7a46-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ee05a798-3884-4c0e-b48a-12ae0010fb90', 'u5468-u7a46-u738b', '{"zh-Hans": "周穆王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "宠幸造父，西巡狩乐而忘归，造父为其御驾救乱，封造父赵城"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周简王 (u5468-u7b80-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('96d7192d-ef9f-41a1-989c-623044058ee6', 'u5468-u7b80-u738b', '{"zh-Hans": "周简王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "定王之子，继位为简王，在位十三年时晋悼公被立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周聚 (u5468-u805a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9d558416-3c7c-405d-b286-67db50820392', 'u5468-u805a', '{"zh-Hans": "周聚"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "周君之臣，先被客劝誉秦王，后向秦王陈说攻周之害"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周襄王 (u5468-u8944-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('704b3c67-4bb0-4cca-8240-de9a2ead1e24', 'u5468-u8944-u738b', '{"zh-Hans": "周襄王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被弟带引翟兵攻伐，出居郑，后由秦晋助其复位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 周顷王 (u5468-u9877-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('82088dd0-3092-44ff-84e8-87c2942e3104', 'u5468-u9877-u738b', '{"zh-Hans": "周顷王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "襄王之子，在位六年后崩，子匡王班继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 咎单 (u548e-u5355)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('085afa0a-27c9-4034-87e9-434343bad7f3', 'u548e-u5355', '{"zh-Hans": "咎单"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "作《明居》 伊尹葬后，整理伊尹事迹，作《沃丁》篇"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 唐太后 (u5510-u592a-u540e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e0bca3e2-9292-4f67-9ad5-df97cc844eae', 'u5510-u592a-u540e', '{"zh-Hans": "唐太后"}'::jsonb, '战国·秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "孝文王即位后尊唐八子为唐太后，与先王合葬"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 唐眛 (u5510-u771b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a55c44d5-91c2-4340-8df8-42aa9b7482c6', 'u5510-u771b', '{"zh-Hans": "唐眛"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "楚将，被联军所取（擒获）"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 商容 (u5546-u5bb9)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2fad187e-d800-4681-9475-610725fa502e', 'u5546-u5bb9', '{"zh-Hans": "商容"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "商朝贤人，武王命表彰其所居之闾"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 嘉 (u5609)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8873cecc-3c8f-4330-95c9-6f9c46421964', 'u5609', '{"zh-Hans": "嘉"}'::jsonb, '西汉', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "周室苗裔，被汉天子封三十里地，号周子南君"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 城阳君 (u57ce-u9633-u541b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('256875c4-2476-46c7-8fe2-aa8163e969a9', 'u57ce-u9633-u541b', '{"zh-Hans": "城阳君"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "十七年入朝秦"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 外丙 (u5916-u4e19)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bbfb70fe-0e15-4509-8c47-0ddf373fd9bf', 'u5916-u4e19', '{"zh-Hans": "外丙"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "太丁之弟，继汤之位，在位三年而崩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 大业 (u5927-u4e1a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e828d7ac-f59e-436e-a5e8-aa43ed765f34', 'u5927-u4e1a', '{"zh-Hans": "大业"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "女修之子，娶少典之子女华"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 大毕 (u5927-u6bd5)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7d64a92a-1659-4ecf-b3cf-a41d42f9288a', 'u5927-u6bd5', '{"zh-Hans": "大毕"}'::jsonb, '西周', 'uncertain', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与伯士并称，其终后犬戎氏仍以职来王，穆王以不享为由欲征之"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 大骆 (u5927-u9a86)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b4915d4d-a374-4ff6-bceb-6494b346b4f7', 'u5927-u9a86', '{"zh-Hans": "大骆"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "太几之子，非子之父 非子之父，娶申侯之女，生适子成 其族在犬丘被西戎所灭，秦仲后裔后来收复其地"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太丁 (u592a-u4e01)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4fe29020-b3da-41aa-8812-c045474e34b5', 'u592a-u4e01', '{"zh-Hans": "太丁"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "汤之太子，未及即位而卒 武乙之子，继位后崩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太任 (u592a-u4efb)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('41394482-c6b9-47e7-87d4-eeed3ea334ba', 'u592a-u4efb', '{"zh-Hans": "太任"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "季历之妻，贤妇人，生文王昌"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太几 (u592a-u51e0)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b603f18a-174c-46d3-84f3-01625fea9cc5', 'u592a-u51e0', '{"zh-Hans": "太几"}'::jsonb, '西周', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "旁皋之子，大骆之父"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太史儋 (u592a-u53f2-u510b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d3cb56c4-7ae9-484e-8a03-0b0ad2a83384', 'u592a-u53f2-u510b', '{"zh-Hans": "太史儋"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "周太史，往见秦献公，预言周秦合分及霸王出世"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太史公 (u592a-u53f2-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e9542991-4023-4a9d-82da-212749f8fc4e', 'u592a-u53f2-u516c', '{"zh-Hans": "太史公"}'::jsonb, '西汉', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "作者自称，发表关于秦先祖嬴姓分封的评论"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太姜 (u592a-u59dc)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ec8a326b-a4e9-4d64-9118-32b861113b18', 'u592a-u59dc', '{"zh-Hans": "太姜"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "古公之妻，生少子季历，被称为贤妇人"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太子圉 (u592a-u5b50-u5709)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('76591c5f-395c-4b8e-a94a-dab9aac644bc', 'u592a-u5b50-u5709', '{"zh-Hans": "太子圉"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋惠公之子，被送往秦国为质，秦以宗女妻之"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太子建 (u592a-u5b50-u5efa)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a1608524-96aa-4b19-b28c-d67c7ba5aea2', 'u592a-u5b50-u5efa', '{"zh-Hans": "太子建"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "楚平王为其求秦女为妻，后被平王欲诛而出奔"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太庚 (u592a-u5e9a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8da2df10-2abe-4d81-828a-2b3bd4dcad0d', 'u592a-u5e9a', '{"zh-Hans": "太庚"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "沃丁之弟，继位为帝太庚，崩后子小甲立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太戊 (u592a-u620a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d8bf838d-daad-4282-97ae-49f671909d28', 'u592a-u620a', '{"zh-Hans": "太戊"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "雍己之弟，立伊陟为相，修德使殷复兴，诸侯归附，称中宗"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太颠 (u592a-u98a0)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c227043f-8ca0-43bb-9cbf-b818c03c6348', 'u592a-u98a0', '{"zh-Hans": "太颠"}'::jsonb, '先周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "归附西伯的贤士之一 执剑护卫武王"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 夫差 (u592b-u5dee)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6e90a2ec-bb36-420b-b0bb-f9356b2abb56', 'u592b-u5dee', '{"zh-Hans": "夫差"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "吴王，与晋定公争长于黄池，吴国强盛凌压中原"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 夷吾 (u5937-u543e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c04e0814-6557-40af-b35d-5fec14bd80bb', 'u5937-u543e', '{"zh-Hans": "夷吾"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "因骊姬之乱出奔他国"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 夷王 (u5937-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7a572542-02d9-435d-a6c5-3bf8a378aeaf', 'u5937-u738b', '{"zh-Hans": "夷王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "懿王太子，孝王崩后被诸侯复立为夷王 厉王之父，崩后由子胡继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 奄息 (u5944-u606f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1f524e25-a029-4379-b82d-c7cceaff3c9d', 'u5944-u606f', '{"zh-Hans": "奄息"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "子舆氏三良之一，随秦缪公从死"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 奚齐 (u595a-u9f50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('39f06e0e-bf12-4002-9810-1e0e1f7cfcde', 'u595a-u9f50', '{"zh-Hans": "奚齐"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "骊姬之子，晋献公死后被立为君，旋被里克所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 女修 (u5973-u4fee)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7cbe5667-441a-485c-9ff3-01376d2772ca', 'u5973-u4fee', '{"zh-Hans": "女修"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "颛顼苗裔孙，织布时吞玄鸟卵，生子大业"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 女华 (u5973-u534e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e8ca4a3f-2b03-4265-abe4-cf5199ee9f51', 'u5973-u534e', '{"zh-Hans": "女华"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "少典之子，嫁大业，生大费"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 女房 (u5973-u623f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a2e28a22-9375-4e29-a295-969035563da3', 'u5973-u623f', '{"zh-Hans": "女房"}'::jsonb, '商', 'uncertain', 'ai_inferred', NULL, NULL, '{"zh-Hans": "伊尹入亳北门时所遇之人，伊尹为之作篇"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 女防 (u5973-u9632)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('82dc3e8d-5d67-468d-85dd-44b575291565', 'u5973-u9632', '{"zh-Hans": "女防"}'::jsonb, '商末周初', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "恶来之子，旁皋之父"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 女鸠 (u5973-u9e20)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('eca161d1-ebc5-484e-b5c3-6b3a3e43375c', 'u5973-u9e20', '{"zh-Hans": "女鸠"}'::jsonb, '商', 'uncertain', 'ai_inferred', NULL, NULL, '{"zh-Hans": "伊尹入亳北门时所遇之人，伊尹为之作篇"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 姚 (u59da)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('38dd7ce0-c96f-4b92-9fa8-b9cc2536d92a', 'u59da', '{"zh-Hans": "姚"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "庄王宠姬，生子颓"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 姜原 (u59dc-u539f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b29ae21b-f95d-4176-86cd-29d5f8880b06', 'u59dc-u539f', '{"zh-Hans": "姜原"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "有邰氏女，帝喾元妃，踩巨人足迹而孕，生弃并收养之"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 姜尚 (u59dc-u5c1a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('aa831571-ec89-4f9d-8568-87ab12965e91', 'u59dc-u5c1a', '{"zh-Hans": "姜尚"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "武王即位后任师，辅佐武王 牵牲参与祭告仪式 功臣谋士之首，被封于营丘，国号齐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 威公 (u5a01-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1de71063-d8fe-4bcb-8644-9b48d9ef836c', 'u5a01-u516c', '{"zh-Hans": "威公"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "桓公之子，继桓公之位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 威垒 (u5a01-u5792)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('236684bd-1c94-49e2-9802-7ed523a82215', 'u5a01-u5792', '{"zh-Hans": "威垒"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与弗忌、三父共废太子立出子，后又杀出子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 威烈王 (u5a01-u70c8-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9a536139-f9bc-40db-941d-51c91a0aebab', 'u5a01-u70c8-u738b', '{"zh-Hans": "威烈王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "考王之子，继位为周天子 周天子，命韩、魏、赵三家为诸侯"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 嬴政 (u5b34-u653f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2a63d8aa-8e38-421a-bf06-e827efb0c684', 'u5b34-u653f', '{"zh-Hans": "嬴政"}'::jsonb, '秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "立二十六年初并天下，号始皇帝，五十一年而崩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 子之 (u5b50-u4e4b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('557e7bfe-57c7-4114-b550-c8fb4f580b62', 'u5b50-u4e4b', '{"zh-Hans": "子之"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "燕君将君位禅让给他"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 子圉 (u5b50-u5709)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4bdd2dd1-8e72-4f5a-915a-565367700490', 'u5b50-u5709', '{"zh-Hans": "子圉"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "闻晋君病而逃归晋，继位后被重耳派人杀死，谥怀公"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 子婴 (u5b50-u5a74)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6ea97184-d5d2-4b81-9fef-efa447e2e651', 'u5b50-u5a74', '{"zh-Hans": "子婴"}'::jsonb, '秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被赵高立为王，月余后被诸侯所诛，秦遂灭亡"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 子颓 (u5b50-u9893)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d17c5cec-e575-4440-a8c2-517faeed9290', 'u5b50-u9893', '{"zh-Hans": "子颓"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "曾作乱，乱由郑平定，富辰以此为据劝王勿弃郑"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 孔子 (u5b54-u5b50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a387e3b7-5ae1-4869-84ef-6d4f6cb61947', 'u5b54-u5b50', '{"zh-Hans": "孔子"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "行鲁相事 于秦悼公十二年卒"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 孝文王 (u5b5d-u6587-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ae68feda-5705-4b96-a571-b71c96f95060', 'u5b5d-u6587-u738b', '{"zh-Hans": "孝文王"}'::jsonb, '战国秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "赦罪人、修功臣、褒亲戚、弛苑囿，除丧即位三日后卒"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 孝王 (u5b5d-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4ffdaa98-c914-417c-92f7-82c10338455e', 'u5b5d-u738b', '{"zh-Hans": "孝王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "共王之弟，懿王崩后即位为孝王，崩后由懿王太子燮继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 孟增 (u5b5f-u589e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e22fe542-8833-43a8-ade0-0e13287c4eff', 'u5b5f-u589e', '{"zh-Hans": "孟增"}'::jsonb, '西周', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "季胜之子，幸于周成王，号宅皋狼"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 孟尝君 (u5b5f-u5c1d-u541b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('548ca8aa-2517-4ef4-b29b-42463dde864e', 'u5b5f-u5c1d-u541b', '{"zh-Hans": "孟尝君"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "来秦任相，后以金贿赂免职"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 孟明 (u5b5f-u660e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9dde5128-320a-4a33-8a05-744caab71b66', 'u5b5f-u660e', '{"zh-Hans": "孟明"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被秦缪公重用，率兵伐晋大败晋人"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 孟说 (u5b5f-u8bf4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('29fcfe8c-e404-4c5c-8f9d-f4d4dc4d391e', 'u5b5f-u8bf4', '{"zh-Hans": "孟说"}'::jsonb, '战国·秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦武王力士，与武王举鼎，武王死后被族诛"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 季胜 (u5b63-u80dc)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e17c1086-2a2e-4d17-b551-6e5196f0de68', 'u5b63-u80dc', '{"zh-Hans": "季胜"}'::jsonb, '商末周初', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "蜚廉之子，孟增之父"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 孺子 (u5b7a-u5b50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6d762926-7af9-4e3a-b116-0ee934450127', 'u5b7a-u5b50', '{"zh-Hans": "孺子"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "齐君，被田乞所弑"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 宁公 (u5b81-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('30e9e183-8181-41b3-be5e-780f7c00ddcc', 'u5b81-u516c', '{"zh-Hans": "宁公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦宁公，迁居平阳，伐荡社灭之，在位十二年卒"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 安国君 (u5b89-u56fd-u541b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ee06485e-929e-4ec6-805a-e13156a453ba', 'u5b89-u56fd-u541b', '{"zh-Hans": "安国君"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "四十二年立为太子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 安王 (u5b89-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('fb71f9fd-03aa-4785-b2c4-a984187edb60', 'u5b89-u738b', '{"zh-Hans": "安王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "周安王，其父崩后即位 在位二十六年后崩，其子烈王继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 宋王 (u5b8b-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6983f8d6-e43e-4609-bb61-1de487812b05', 'u5b8b-u738b', '{"zh-Hans": "宋王"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "齐破宋后，宋王在魏，死于温"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 客卿灶 (u5ba2-u537f-u7076)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c7e47add-a629-49fe-97a1-6dcb407a54b1', 'u5ba2-u537f-u7076', '{"zh-Hans": "客卿灶"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "三十六年攻齐，取刚、寿，予穰侯"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 宣公 (u5ba3-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4d22b414-afd8-4773-9e50-8fdd5b26623e', 'u5ba3-u516c', '{"zh-Hans": "宣公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "在位期间参与周室政争，与晋战于河阳，卒后无子继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 宣太后 (u5ba3-u592a-u540e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ca450aa0-2745-478a-aa71-b6f6f84a1830', 'u5ba3-u592a-u540e', '{"zh-Hans": "宣太后"}'::jsonb, '战国·秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "昭襄王之母，楚人，姓芈氏，号宣太后 四十二年十月薨，葬芷阳郦山"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 宰予 (u5bb0-u4e88)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b8ce9615-c7fc-45c9-b5fc-269100b37710', 'u5bb0-u4e88', '{"zh-Hans": "宰予"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "向孔子问五帝德及帝系姓，其问答被孔子所传"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 密康公 (u5bc6-u5eb7-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a43a483a-7af9-447c-b98e-40b3bd425403', 'u5bc6-u5eb7-u516c', '{"zh-Hans": "密康公"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "随共王游泾上，有三女奔之，不听母劝献女，一年后被共王所灭"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 密康公之母 (u5bc6-u5eb7-u516c-u4e4b-u6bcd)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('050d8ebf-86e7-4ccb-8028-284a8d41ba5b', 'u5bc6-u5eb7-u516c-u4e4b-u6bcd', '{"zh-Hans": "密康公之母"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "劝密康公将三女献给共王，预言不献必亡"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 富辰 (u5bcc-u8fb0)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1217c9e0-a951-4d71-91bc-41c0d8891438', 'u5bcc-u8fb0', '{"zh-Hans": "富辰"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "周大夫，多次谏阻襄王联翟伐郑及立翟后，终以属死之"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 尉斯离 (u5c09-u65af-u79bb)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bd0ae58a-be25-4643-9e9f-2d8fbb9c8906', 'u5c09-u65af-u79bb', '{"zh-Hans": "尉斯离"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "二十三年与三晋、燕伐齐，破之济西"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 小乙 (u5c0f-u4e59)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f701d782-874d-4756-8cce-486d700e2925', 'u5c0f-u4e59', '{"zh-Hans": "小乙"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "小辛之弟，小辛崩后继位 武丁之父，崩后由子武丁继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 小甲 (u5c0f-u7532)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4f06d7b1-2ff4-4063-b69a-7fee28dea28e', 'u5c0f-u7532', '{"zh-Hans": "小甲"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "太庚之子，继位后崩，弟雍己立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 小辛 (u5c0f-u8f9b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f44b4d81-fa93-4f42-a646-c1f76cd107fb', 'u5c0f-u8f9b', '{"zh-Hans": "小辛"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "盘庚之弟，继位后殷复衰"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 少暤氏 (u5c11-u66a4-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2e9ab3c3-7bc7-48e3-a700-47b237c5eb37', 'u5c11-u66a4-u6c0f', '{"zh-Hans": "少暤氏"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "其不才子被天下称为穷奇，为四凶之一的来源氏族首领"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 尹佚 (u5c39-u4f5a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9ce6d4e4-5f2b-45d2-830a-ad96b81775b8', 'u5c39-u4f5a', '{"zh-Hans": "尹佚"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "宣读祝文，历数纣王罪行"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 屈丐 (u5c48-u4e10)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2a5ca791-8cbf-49cd-81f8-cf70826f4182', 'u5c48-u4e10', '{"zh-Hans": "屈丐"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "丹阳之战中被秦军俘虏的楚国将领"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 崇侯虎 (u5d07-u4faf-u864e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a54abbd1-05b1-4ab7-b2ce-b8519fcd1078', 'u5d07-u4faf-u864e', '{"zh-Hans": "崇侯虎"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "向纣王进谗言诬陷西伯，后被西伯揭发 被西伯所伐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 崔杼 (u5d14-u677c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('75b2076f-ec26-4df9-9707-b33ae9f4105e', 'u5d14-u677c', '{"zh-Hans": "崔杼"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "齐国大臣，弑杀齐庄公"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 嵬 (u5d6c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('44a70bc3-9cc8-4440-a8ad-695423fa705a', 'u5d6c', '{"zh-Hans": "嵬"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "定王少子，攻杀思王而自立为考王"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 左成 (u5de6-u6210)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('10d167de-87a9-49e9-84b9-db6760b9d6f8', 'u5de6-u6210', '{"zh-Hans": "左成"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "反对司马翦之策，建议先探明周君意向再资助"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 巫咸 (u5deb-u54b8)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('62092322-6254-48e2-9467-9e65a5e41d87', 'u5deb-u54b8', '{"zh-Hans": "巫咸"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受伊陟称赞，治王家有成，作《咸艾》《太戊》"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 巫贤 (u5deb-u8d24)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('314c2e92-b8be-444a-8cad-34e2627c091d', 'u5deb-u8d24', '{"zh-Hans": "巫贤"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "祖乙时期任职辅政"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 差弗 (u5dee-u5f17)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1e8fe82f-14b1-4cd6-854b-f803db3f021c', 'u5dee-u5f17', '{"zh-Hans": "差弗"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "皇仆之子，卒后由子毁隃继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 师武 (u5e08-u6b66)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('98b4db47-2118-46be-b077-3cd44b067219', 'u5e08-u6b66', '{"zh-Hans": "师武"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被白起击败的将领"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 师涓 (u5e08-u6d93)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6ac54d78-abbd-4e78-b417-06fe22811f8b', 'u5e08-u6d93', '{"zh-Hans": "师涓"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受纣命创作新的淫靡乐声"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝不降 (u5e1d-u4e0d-u964d)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0e30735f-6d22-4574-9920-171bce1eae14', 'u5e1d-u4e0d-u964d', '{"zh-Hans": "帝不降"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝泄之子，夏代帝王，崩后弟帝扃继位，其子孔甲后亦立为帝"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

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

-- Person: 帝泄 (u5e1d-u6cc4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2cca90ac-fc2b-470d-857d-1e61641276ac', 'u5e1d-u6cc4', '{"zh-Hans": "帝泄"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝芒之子，夏代帝王，崩后由子帝不降继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝皋 (u5e1d-u768b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5d148846-8cd5-40fc-b831-f100d2255387', 'u5e1d-u768b', '{"zh-Hans": "帝皋"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "孔甲之子，继位后崩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝相 (u5e1d-u76f8)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('408b9a55-0afd-4c91-8d31-4e85b2727319', 'u5e1d-u76f8', '{"zh-Hans": "帝相"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "中康之子，夏代帝王，崩后由子少康继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝芒 (u5e1d-u8292)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bebe0656-0ad7-4347-b43b-41dec4d02be8', 'u5e1d-u8292', '{"zh-Hans": "帝芒"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝槐之子，夏代帝王，崩后由子帝泄继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 庄公 (u5e84-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('32a7c8ef-3f53-4eb2-9f60-402752301815', 'u5e84-u516c', '{"zh-Hans": "庄公"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦仲长子，与兄弟五人奉周宣王命破西戎，被封为西垂大夫"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 庄王 (u5e84-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2fbbe30a-6a5a-44f6-b3f4-35b2ef532e97', 'u5e84-u738b', '{"zh-Hans": "庄王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "桓王之子，继位后诛杀欲谋害自己的周公黑肩 在位十五年后崩，子厘王继位 宠爱姬姚，生子颓"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 庄襄王 (u5e84-u8944-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2cbfdc8d-9444-4fae-9c14-28139a7710bc', 'u5e84-u8944-u738b', '{"zh-Hans": "庄襄王"}'::jsonb, '战国秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "孝文王之子，孝文王卒后继位 秦王，大赦罪人、施德布惠，在位期间多次对外用兵，卒后子政继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 庆封 (u5e86-u5c01)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0b398bdf-700a-4e8e-a410-0e4246337262', 'u5e86-u5c01', '{"zh-Hans": "庆封"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被楚灵王在申会盟时杀死"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 庆节 (u5e86-u8282)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('413d2238-8ce7-44da-b5d1-525049d9a577', 'u5e86-u8282', '{"zh-Hans": "庆节"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "公刘之子，继立后建国于豳 周先祖之一，卒后由子皇仆继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 庶长壮 (u5eb6-u957f-u58ee)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3123214a-26df-409c-8703-c969ab15744d', 'u5eb6-u957f-u58ee', '{"zh-Hans": "庶长壮"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与大臣、诸侯、公子谋逆，被诛"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 庶长奂 (u5eb6-u957f-u5942)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5103c43d-61a3-4b33-b48a-1f2cbfe4a184', 'u5eb6-u957f-u5942', '{"zh-Hans": "庶长奂"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "伐楚斩首二万，后又攻楚取八城并杀楚将景快"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 庶长封 (u5eb6-u957f-u5c01)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1730a107-15b9-48bc-a273-0af1e03df83c', 'u5eb6-u957f-u5c01', '{"zh-Hans": "庶长封"}'::jsonb, '战国·秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与甘茂同伐宜阳"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 庶长改 (u5eb6-u957f-u6539)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8ed08360-c748-43b3-85ed-87effe97dc62', 'u5eb6-u957f-u6539', '{"zh-Hans": "庶长改"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "迎立献公，杀出子及其母"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 庶长朝 (u5eb6-u957f-u671d)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cdedb68a-4751-440d-9678-fb26559ec444', 'u5eb6-u957f-u671d', '{"zh-Hans": "庶长朝"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与大臣合谋围困怀公，致其自杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 庶长章 (u5eb6-u957f-u7ae0)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('eb903e93-8909-4165-9945-9cef4089c138', 'u5eb6-u957f-u7ae0', '{"zh-Hans": "庶长章"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "在丹阳击楚，俘屈丐，斩首八万，又取汉中六百里"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 康王 (u5eb7-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('18cece48-6285-46b3-864b-3a8f9d5fb00b', 'u5eb7-u738b', '{"zh-Hans": "康王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "成王之子，由召公、毕公辅立，在位期间天下安宁，刑错四十余年不用 昭王之父，卒后由子昭王瑕继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 弗忌 (u5f17-u5fcc)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('003998a4-bbf5-40a1-9abb-4ad0e21fe16f', 'u5f17-u5fcc', '{"zh-Hans": "弗忌"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "大庶长，废太子立出子，后又令人杀出子复立武公"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 张唐 (u5f20-u5510)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('620ef450-d006-48e0-bd8a-1700dad51a12', 'u5f20-u5510', '{"zh-Hans": "张唐"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "四十九年攻魏，五十年攻郑拔之，又拔宁新中"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 弦高 (u5f26-u9ad8)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3e33d037-3828-47c9-8726-22875fba9936', 'u5f26-u9ad8', '{"zh-Hans": "弦高"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "郑国贩牛商人，以献牛之计迷惑秦军，使其放弃袭郑"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 强 (u5f3a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8922b82b-3dad-4efa-87a1-fd465a984e52', 'u5f3a', '{"zh-Hans": "强"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "商少师，抱乐器出奔投周"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 徐偃王 (u5f90-u5043-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('fd1c2c35-d6a8-4e2c-ad47-e066320b436f', 'u5f90-u5043-u738b', '{"zh-Hans": "徐偃王"}'::jsonb, '西周', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "作乱，造父为穆王御驾一日千里归周以救乱"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 微 (u5fae)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('436bf856-818a-43fb-b567-4dbafa582cf6', 'u5fae', '{"zh-Hans": "微"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "振之子，继立后卒，由子报丁继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 微子开 (u5fae-u5b50-u5f00)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d641964e-5b22-4335-87b2-b008a355e2b9', 'u5fae-u5b50-u5f00', '{"zh-Hans": "微子开"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被立为殷后，封国于宋"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 德公 (u5fb7-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cc9aede7-93dc-48a5-a369-65abe1c90f85', 'u5fb7-u516c', '{"zh-Hans": "德公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "武公之弟，与武公同母鲁姬子所生 武公之弟，武公卒后继立为君"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 怀公 (u6000-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d9d68f23-566e-47ab-a3ae-82b4985d60e8', 'u6000-u516c', '{"zh-Hans": "怀公"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "躁公之弟，躁公卒后继位 被庶长朝与大臣围困，自杀身亡"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 恶来 (u6076-u6765)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cf3bad71-102d-4ce9-8c00-35d2dc1af0d7', 'u6076-u6765', '{"zh-Hans": "恶来"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "蜚廉之子，有力，事殷纣，周武王伐纣时被杀，早死"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 悼公 (u60bc-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3903656e-c034-4e92-966d-e9bba54f3d18', 'u60bc-u516c', '{"zh-Hans": "悼公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "惠公之子，惠公卒后继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 悼太子 (u60bc-u592a-u5b50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0b8405bf-ef2d-4f5f-87f0-306c0060b0ef', 'u60bc-u592a-u5b50', '{"zh-Hans": "悼太子"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "四十年死于魏，归葬芷阳"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 悼武王后 (u60bc-u6b66-u738b-u540e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5292fa37-9391-48a7-a7b0-7da87bceea95', 'u60bc-u6b66-u738b-u540e', '{"zh-Hans": "悼武王后"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被遣出归魏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 惠公 (u60e0-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f42c18dd-2d16-4206-98cb-082f104d416c', 'u60e0-u516c', '{"zh-Hans": "惠公"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "鲁国君主，在位十年卒 简公之子，简公卒后继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 惠后 (u60e0-u540e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b054c171-d9f5-41b4-b72f-fbab37f7f9d2', 'u60e0-u540e', '{"zh-Hans": "惠后"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "惠王后母，生叔带，受惠王宠爱 欲立王子带，引翟人入周"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 惠文后 (u60e0-u6587-u540e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e90c71ae-e36e-4f44-b621-948b39bbe830', 'u60e0-u6587-u540e', '{"zh-Hans": "惠文后"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "因庶长壮之乱株连，不得善终"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 惠王 (u60e0-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1f9cf15d-ccf7-4097-8cf1-11fb3446e660', 'u60e0-u738b', '{"zh-Hans": "惠王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被卫、燕逐出，后由郑伯、虢叔迎回复位 去世后由子武王继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 慎靓王 (u614e-u9753-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('91593f9f-b141-4663-8ec4-ad304e835f30', 'u614e-u9753-u738b', '{"zh-Hans": "慎靓王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "显王之子，在位六年后崩，子赧王继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 懿王 (u61ff-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1bdc5c56-4d22-488f-8d6e-ae2fd5993ffc', 'u61ff-u738b', '{"zh-Hans": "懿王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "共王之子，其时王室衰落，诗人作刺 驾崩后由共王之弟辟方继位，其太子燮后被诸侯复立为夷王"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 戎王 (u620e-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a52cf3db-4a13-4330-ada6-627142da8000', 'u620e-u738b', '{"zh-Hans": "戎王"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "派由余出使秦国，受女乐后怠政，与由余生嫌隙"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 戎胥轩 (u620e-u80e5-u8f69)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('364d44ad-a3a8-4e2a-bdfd-25789d01f09d', 'u620e-u80e5-u8f69', '{"zh-Hans": "戎胥轩"}'::jsonb, '西周', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "娶郦山之女，生中潏，为申侯先祖姻亲"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 成 (u6210)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8d82c106-c497-4249-a819-2344d2847b29', 'u6210', '{"zh-Hans": "成"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "申侯之女所生，大骆适子，孝王保留其适嗣地位以和西戎"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 成公 (u6210-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('40906a0d-f843-455a-ae42-1fafacfb0464', 'u6210-u516c', '{"zh-Hans": "成公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "宣公之弟，宣公卒后无子继位，遂立为君 在位四年后去世，子七人皆未立，由弟缪公继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 报丁 (u62a5-u4e01)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ed3b3b19-bad9-4f2a-93e8-5920dde6fcc3', 'u62a5-u4e01', '{"zh-Hans": "报丁"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "微之子，继立后卒，由子报乙继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 报丙 (u62a5-u4e19)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8c725d8e-2dd1-4830-a179-02f3e69051c5', 'u62a5-u4e19', '{"zh-Hans": "报丙"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "报乙之子，继立后卒，由子主壬继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 报乙 (u62a5-u4e59)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e5eacaaa-6910-461e-99a9-13a876eef70a', 'u62a5-u4e59', '{"zh-Hans": "报乙"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "报丁之子，继立后卒，由子报丙继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 振 (u632f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4f47836e-dc17-49e6-9ff0-5cc10d484c20', 'u632f', '{"zh-Hans": "振"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "冥之子，继立后卒，由子微继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 摎 (u644e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b2464f7e-db1c-4061-a21b-33cad5d7f19a', 'u644e', '{"zh-Hans": "摎"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦将军，攻韩取阳城、负黍，又奉命攻西周 受秦命伐魏，攻取吴城"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 散宜生 (u6563-u5b9c-u751f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1042374f-1a56-459a-9e76-3c256d4fe4e9', 'u6563-u5b9c-u751f', '{"zh-Hans": "散宜生"}'::jsonb, '先周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "归附西伯的贤士之一 执剑护卫武王"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 文嬴 (u6587-u5b34)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('78a202d7-25fe-406b-b5c3-6197d4bfc578', 'u6587-u5b34', '{"zh-Hans": "文嬴"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦女，为秦三囚将向晋君请求释放归秦"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 旁皋 (u65c1-u768b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('798070e1-b9c2-4c4f-9e91-a9354a488eb5', 'u65c1-u768b', '{"zh-Hans": "旁皋"}'::jsonb, '西周', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "女防之子，太几之父"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 无知 (u65e0-u77e5)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7211e0a5-71ef-4f59-9c26-4054e3a2b63e', 'u65e0-u77e5', '{"zh-Hans": "无知"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "齐国之君，百里傒曾欲事之，被蹇叔劝止"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 昌若 (u660c-u82e5)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('dc8083af-064f-490d-bad2-2d9960213458', 'u660c-u82e5', '{"zh-Hans": "昌若"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "相土之子，继立后卒，由子曹圉继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 昭子 (u662d-u5b50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8c0890b1-e82e-4895-ba71-c54ce3ac1a1a', 'u662d-u5b50', '{"zh-Hans": "昭子"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "怀公太子，早死，其子后被立为灵公"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 昭明 (u662d-u660e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f71793a2-6ce3-4fd6-af8c-e331cc0505db', 'u662d-u660e', '{"zh-Hans": "昭明"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "契之子，继立后卒，由子相土继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 昭王 (u662d-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('138c6b9c-21f2-4ac1-871f-8a2f0ff4420d', 'u662d-u738b', '{"zh-Hans": "昭王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "康王之子，在位时王道微缺，南巡狩不返，卒于江上"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 昭襄王 (u662d-u8944-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d7616ce7-a0a9-4dbf-9245-4e5a398f333c', 'u662d-u8944-u738b', '{"zh-Hans": "昭襄王"}'::jsonb, '战国·秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "武王异母弟，质于燕，武王死后被送归即位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 显王 (u663e-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('16eb05e7-7f10-48ae-975e-fbe00bfcccf0', 'u663e-u738b', '{"zh-Hans": "显王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "烈王之弟，继位后多次与秦交往，贺秦献公、孝公、惠王 在位四十八年后崩，子慎靓王继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 晋厉公 (u664b-u5389-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2c63b966-e4d6-4693-994b-be9468dc3c64', 'u664b-u5389-u516c', '{"zh-Hans": "晋厉公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "初立时与秦桓公夹河而盟，归后秦背盟 被栾书弑杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 晋唐叔 (u664b-u5510-u53d4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ca33fcb5-9162-407a-b63c-fea4cad6b7f5', 'u664b-u5510-u53d4', '{"zh-Hans": "晋唐叔"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "得嘉谷献于成王，成王转归周公"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 晋太子申生 (u664b-u592a-u5b50-u7533-u751f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('647b1123-794a-42fd-985f-b34f9287a0e0', 'u664b-u592a-u5b50-u7533-u751f', '{"zh-Hans": "晋太子申生"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "其姊嫁给秦穆公为妇"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 晋定公 (u664b-u5b9a-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b313dfe8-173e-4413-bd08-67399e1a5236', 'u664b-u5b9a-u516c', '{"zh-Hans": "晋定公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与吴王夫差在黄池争盟主之长，最终先于吴"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 晋平公 (u664b-u5e73-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8c8cba52-c9c0-4399-bbf8-9afb97020bd3', 'u664b-u5e73-u516c', '{"zh-Hans": "晋平公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与秦景公会盟，又接纳出奔的后子针并与之对话"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 晋悼公 (u664b-u60bc-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9318f515-2b0d-4200-9e50-0656e7e6c041', 'u664b-u60bc-u516c', '{"zh-Hans": "晋悼公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "为诸侯盟主，强盛时率诸侯伐秦，败秦军"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 晋惠公 (u664b-u60e0-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f1f48820-ebc7-41bd-8e87-2c5454bcad91', 'u664b-u60e0-u516c', '{"zh-Hans": "晋惠公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "请秦助其入晋为君，即位后背约不割河西城并杀里克、丕郑 曾得罪于秦穆公，百里傒以其百姓无辜为由请求给粟 与秦战于韩地被俘，后献河西地并送太子为质方得归国 晋国国君，病卒后子圉继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 晋武公 (u664b-u6b66-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0b320972-ba4f-4f08-89e2-d0f0b094375b', 'u664b-u6b66-u516c', '{"zh-Hans": "晋武公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "曲沃吞并晋国，始正式成为晋侯"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 晋灵公 (u664b-u7075-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b28a7e2f-9132-419b-8366-c43b57ec70ae', 'u664b-u7075-u516c', '{"zh-Hans": "晋灵公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋国国君，被赵穿所弑"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 晋献公 (u664b-u732e-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f4f17679-5e38-4c89-a529-b898d452e24a', 'u664b-u732e-u516c', '{"zh-Hans": "晋献公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "灭虞、虢两国，俘虏虞君及百里傒 晋国国君，其死引发晋国内乱"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 晋襄公 (u664b-u8944-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('67c02843-fc5b-4869-a82b-a508a25608c4', 'u664b-u8944-u516c', '{"zh-Hans": "晋襄公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "怒秦趁丧破滑，墨衰绖发兵于崤大破秦军，后许秦女之请归还三将 与秦穆公同年卒，其子后被立为晋君"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 景快 (u666f-u5feb)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ccc6c733-f331-4f1c-9d3e-aa52c8655191', 'u666f-u5feb', '{"zh-Hans": "景快"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "楚国将领，被庶长奂所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 景监 (u666f-u76d1)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3db4e1c5-342f-4cc1-a884-3ddfe51897eb', 'u666f-u76d1', '{"zh-Hans": "景监"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦孝公近臣，卫鞅借其引荐求见孝公"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 智伯 (u667a-u4f2f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cb68a112-4f43-4308-8cdc-e43afa5aa3bb', 'u667a-u4f2f', '{"zh-Hans": "智伯"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋国权臣，晋乱中被杀，封国被赵韩魏三家瓜分"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 智开 (u667a-u5f00)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bb70fa09-081f-469a-8cb3-44b6a5273268', 'u667a-u5f00', '{"zh-Hans": "智开"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "智伯族人，与邑人一同出奔投秦"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 智氏 (u667a-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0883125d-1240-4232-b88e-0a63707f3241', 'u667a-u6c0f', '{"zh-Hans": "智氏"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受晋命攻伐范氏、中行氏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 暴鸢 (u66b4-u9e22)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3ecafb42-827c-42ee-ba6b-fa21d228aba5', 'u66b4-u9e22', '{"zh-Hans": "暴鸢"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "韩国将领，参与联军攻楚方城 三十二年被穰侯攻魏时击破，斩首四万，鸢走"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 曹圉 (u66f9-u5709)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2e1f9ec6-7463-4efa-8ecd-d7a28e609cfe', 'u66f9-u5709', '{"zh-Hans": "曹圉"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "昌若之子，继立后卒，由子冥继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 朱虎 (u6731-u864e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c02c2701-7bab-4e22-9437-39e2ccb0ce90', 'u6731-u864e', '{"zh-Hans": "朱虎"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "益拜谢后谦让的对象之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 杜挚 (u675c-u631a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cce26fdb-a4be-4525-827d-17dbe098323b', 'u675c-u631a', '{"zh-Hans": "杜挚"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与甘龙等反对卫鞅变法"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 栾书 (u683e-u4e66)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9bc2bf2b-58f8-4569-8674-de0b4f25b68d', 'u683e-u4e66', '{"zh-Hans": "栾书"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋臣，弑杀晋厉公"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 桓公 (u6853-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4673104c-d9ce-4a4b-92ba-04206e6c7db3', 'u6853-u516c', '{"zh-Hans": "桓公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "共公之子，共公卒后继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 梁伯 (u6881-u4f2f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6d2d4e6b-1bcb-49a1-900b-b98fb218506d', 'u6881-u4f2f', '{"zh-Hans": "梁伯"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "来朝秦德公 来朝觐见"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 梁王 (u6881-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('766444fc-144c-4373-9cae-bb54dc9777b6', 'u6881-u738b', '{"zh-Hans": "梁王"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被马犯游说，先派兵戍周，后改为为周筑城"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 梼杌 (u68bc-u674c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('673368d9-1523-4a7b-a105-2c7ed6367318', 'u68bc-u674c', '{"zh-Hans": "梼杌"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "颛顼氏之不才子，不可教训、不知话言，被天下称为梼杌"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 楚公子围 (u695a-u516c-u5b50-u56f4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5b1d1dc0-98a0-41b7-8d2a-6a1a3f4725e5', 'u695a-u516c-u5b50-u56f4', '{"zh-Hans": "楚公子围"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "弑其君自立为楚灵王，后会诸侯于申并杀齐庆封"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 楚声王 (u695a-u58f0-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2e37c5c3-04ff-4309-a1f9-6a54225ea785', 'u695a-u58f0-u738b', '{"zh-Hans": "楚声王"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被盗贼杀害"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 楚宣王 (u695a-u5ba3-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('62555e1f-2aa6-47eb-80a6-c729c7d225dd', 'u695a-u5ba3-u738b', '{"zh-Hans": "楚宣王"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与秦孝公同时期的楚国君主"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 楚平王 (u695a-u5e73-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3c6c000e-d3c5-4cac-919d-7c432d512cdb', 'u695a-u5e73-u738b', '{"zh-Hans": "楚平王"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "弑灵王自立，求秦女为太子建妻却自娶，后欲诛太子建"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 楚怀王 (u695a-u6000-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('777778a4-bc13-4f91-b2c3-6f8efd1b0e72', 'u695a-u6000-u738b', '{"zh-Hans": "楚怀王"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "入朝秦国被扣留，出逃至赵被拒，返秦后死，归葬楚"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 楚成王 (u695a-u6210-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a088b8e2-758b-4c3d-82f9-2f43d064cbed', 'u695a-u6210-u738b', '{"zh-Hans": "楚成王"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "楚国国君，被太子商臣弑杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 楚昭王 (u695a-u662d-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b83dcf8a-5370-49e2-85a6-86c4394e914e', 'u695a-u662d-u738b', '{"zh-Hans": "楚昭王"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "吴师入郢时出奔随国，后得申包胥借秦兵击退吴师而复入郢"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 楚灵王 (u695a-u7075-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0937bb0d-82a0-477f-b3e6-508c7dccae2b', 'u695a-u7075-u738b', '{"zh-Hans": "楚灵王"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被公子弃疾弑杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 楚王 (u695a-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('52014459-0a6e-4077-902c-84b718ded20e', 'u695a-u738b', '{"zh-Hans": "楚王"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与秦王会于黄棘，秦归还上庸"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 楚穆王 (u695a-u7a46-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c361d1cd-27a0-4759-8afc-37fae21a321d', 'u695a-u7a46-u738b', '{"zh-Hans": "楚穆王"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "楚太子，弑父成王后即位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 楼缓 (u697c-u7f13)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('76523e8e-cb37-41fc-bb07-f44db1ee89c6', 'u697c-u7f13', '{"zh-Hans": "楼缓"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "任秦丞相，后被免职"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 武乙 (u6b66-u4e59)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b45f2e48-f669-4b36-93ed-213e3b36a0eb', 'u6b66-u4e59', '{"zh-Hans": "武乙"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "无道，制偶人射天，猎于河渭之间被雷震死"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 武公 (u6b66-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('dc392c18-ed6d-440b-9e2f-75ee6b04cab8', 'u6b66-u516c', '{"zh-Hans": "武公"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "宁公长男，原为太子，被废后复立为君 伐彭戏氏、邽冀戎，诛三父等，灭小虢，初设县制 秦武公，在位二十年后卒，葬雍平阳，初行人殉，从死者六十六人"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 武庚 (u6b66-u5e9a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('70e67046-bba3-491e-8f41-64c8b46af1ea', 'u6b66-u5e9a', '{"zh-Hans": "武庚"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与管叔蔡叔作乱叛周，被周公奉成王命诛杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 殳斨 (u6bb3-u65a8)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ede0056d-29a5-45a5-999c-904cc6eb0e82', 'u6bb3-u65a8', '{"zh-Hans": "殳斨"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "垂谦让共工之职时所推举的人选之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 毁隃 (u6bc1-u9683)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('07f5e40a-0ff4-42e0-8f84-a0e5b33f0fe8', 'u6bc1-u9683', '{"zh-Hans": "毁隃"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "差弗之子，卒后由子公非继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 毕公 (u6bd5-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('53fc8b30-2303-4339-b3db-045e3f0b8b38', 'u6bd5-u516c', '{"zh-Hans": "毕公"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "左右武王，辅佐继承文王绪业 手持小钺夹护武王 受武王之命释放百姓之囚 受成王命与召公率诸侯辅立太子钊，后受康王命作《毕命》分居里"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 毛叔郑 (u6bdb-u53d4-u90d1)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('827364d8-c7fb-4322-8084-e537cc8eac56', 'u6bdb-u53d4-u90d1', '{"zh-Hans": "毛叔郑"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "奉明水参与祭告仪式"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 沃丁 (u6c83-u4e01)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c65680a5-8e79-41c8-ad07-7f7fdaffc0e2', 'u6c83-u4e01', '{"zh-Hans": "沃丁"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "太宗之子，继位后在位期间伊尹去世 崩后由弟太庚继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 沃甲 (u6c83-u7532)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('479b1fd2-d739-43d2-a7c6-75284b6eaa82', 'u6c83-u7532', '{"zh-Hans": "沃甲"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "祖辛之弟，继位为帝沃甲，崩后由侄祖丁继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 河亶甲 (u6cb3-u4eb6-u7532)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('85531e86-3424-4048-a90a-ef090fe9f336', 'u6cb3-u4eb6-u7532', '{"zh-Hans": "河亶甲"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "居相，后继外壬为帝，在位时殷再度衰落 崩逝，其子祖乙继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 泄父 (u6cc4-u7236)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1dbe91cd-5506-4bd5-8e40-3643a931370e', 'u6cc4-u7236', '{"zh-Hans": "泄父"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "平王太子，早死未能继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 泾阳君 (u6cfe-u9633-u541b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4f0e082e-7ab5-4cb6-a6b9-faa7e73abc47', 'u6cfe-u9633-u541b', '{"zh-Hans": "泾阳君"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "作为人质赴齐 二十一年封宛"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 浑沌 (u6d51-u6c8c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8f15868e-a5b6-4003-ab74-87a8df633206', 'u6d51-u6c8c', '{"zh-Hans": "浑沌"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝鸿氏之不才子，掩义隐贼、好行凶慝，被天下称为浑沌"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 涂山氏 (u6d82-u5c71-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0aff7cb5-0ffd-4097-a2d0-9539c44856d6', 'u6d82-u5c71-u6c0f', '{"zh-Hans": "涂山氏"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "禹之妻，生启 涂山氏之女，禹之妻，启之母"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 游孙 (u6e38-u5b59)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('111de572-6811-4416-a4ae-59d51c3aa997', 'u6e38-u5b59', '{"zh-Hans": "游孙"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "周王使者，奉命赴郑请滑，被郑人囚禁"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 灵公 (u7075-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0623012c-d2bd-45c7-8382-5473a4e59610', 'u7075-u516c', '{"zh-Hans": "灵公"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "昭子之子，怀公之孙，被大臣拥立为君 献公之父，段落中以父辈身份被提及"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 灵王 (u7075-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f6e2f921-1f10-48c3-b982-63c4eb1f5586', 'u7075-u738b', '{"zh-Hans": "灵王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "简王之子，继位为灵王，在位二十四年时齐发生弑君事件"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 烈王 (u70c8-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('81148632-939a-4900-a410-68740062209c', 'u70c8-u738b', '{"zh-Hans": "烈王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "安王之子，继位为周烈王，在位二年时太史儋见秦献公 周天子，崩后由弟扁继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 熊罴 (u718a-u7f74)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e15a3a4b-5cae-4015-9a11-01d6f39e98f8', 'u718a-u7f74', '{"zh-Hans": "熊罴"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "益拜谢后谦让的对象之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 燕悼侯 (u71d5-u60bc-u4faf)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0284ee00-69db-464b-a9c0-7c8293f7df9d', 'u71d5-u60bc-u4faf', '{"zh-Hans": "燕悼侯"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与秦孝公同时期的燕国君主"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 犀首 (u7280-u9996)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0ec5331f-0ef2-43a0-bf1a-c3f4f0418968', 'u7280-u9996', '{"zh-Hans": "犀首"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "阴晋人，被任命为大良造 岸门之战中韩军将领，兵败后逃走"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 献公 (u732e-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ebcd8d48-2cda-49c9-9a6d-47267842dcec', 'u732e-u516c', '{"zh-Hans": "献公"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "灵公之子，被庶长改从河西迎回立为君"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 王子克 (u738b-u5b50-u514b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5558d845-95eb-4043-92a4-ed26c57805ba', 'u738b-u5b50-u514b', '{"zh-Hans": "王子克"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "周公黑肩欲立之为王，事败后出奔燕国"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 王子带 (u738b-u5b50-u5e26)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7c34a692-0caf-4919-b027-04f08d5314dd', 'u738b-u5b50-u5e26', '{"zh-Hans": "王子带"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "周襄王之弟，引翟兵伐王，后被秦缪公与晋文公所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 王子朝 (u738b-u5b50-u671d)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('31bbceec-f626-4986-b832-1b0d4844067a', 'u738b-u5b50-u671d', '{"zh-Hans": "王子朝"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "景王爱子，景王欲立之，后攻杀猛，终被晋人击败"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 王子颓 (u738b-u5b50-u9893)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a2bdf817-24cc-4e1b-a31c-c5381c845daf', 'u738b-u5b50-u9893', '{"zh-Hans": "王子颓"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被卫、燕扶立为王，后被郑伯、虢叔所杀 周王子，好牛，百里傒以养牛干谒之，欲用百里傒，被蹇叔劝止"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 王孙满 (u738b-u5b59-u6ee1)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('896d6b73-62d1-4a0b-9a20-966b39bd6be7', 'u738b-u5b59-u6ee1', '{"zh-Hans": "王孙满"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "见秦师过周北门无礼，断言其必败"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 王颓 (u738b-u9893)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a8430d03-ac7f-4a96-be08-221f2368df88', 'u738b-u9893', '{"zh-Hans": "王颓"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "庄王之子，被大夫边伯等拥立为王，后被郑、虢君伐杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 王龁 (u738b-u9f81)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('36c8288d-f0fd-43f8-a931-e1eb162db3c0', 'u738b-u9f81', '{"zh-Hans": "王龁"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "四十八年将伐赵拔皮牢，后代陵攻邯郸，又攻汾城 攻上党"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 甘龙 (u7518-u9f99)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7004f032-0964-4336-9e64-7e2021330b10', 'u7518-u9f99', '{"zh-Hans": "甘龙"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与杜挚等反对卫鞅变法"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 甫侯 (u752b-u4faf)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b72647cb-3802-408f-9975-d93d91eee027', 'u752b-u4faf', '{"zh-Hans": "甫侯"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "向王进言修订刑法，此刑法因此命名为甫刑"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 田乞 (u7530-u4e5e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c65795a6-4481-46a4-8b11-95c6246033ab', 'u7530-u4e5e', '{"zh-Hans": "田乞"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "齐臣，弑君孺子，立阳生为悼公"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 田常 (u7530-u5e38)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f7155b07-cd14-4cca-91cb-2a8338ced753', 'u7530-u5e38', '{"zh-Hans": "田常"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "弑齐简公，立平公，自任相国"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 申侯 (u7533-u4faf)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c7de1699-5d38-4f62-8206-590008278f70', 'u7533-u4faf', '{"zh-Hans": "申侯"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "向孝王陈述申骆联姻之利，请求保留其女之子成为大骆适嗣 联合西戎犬戎伐周，杀幽王于郦山下"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 申包胥 (u7533-u5305-u80e5)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('94cc1a89-4cd6-4808-bf7b-d61556261283', 'u7533-u5305-u80e5', '{"zh-Hans": "申包胥"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "楚大夫，赴秦告急，七日不食哭泣，促使秦出兵救楚"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 申后 (u7533-u540e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('417d113d-108f-42f2-b23d-3e23dc52a9a9', 'u7533-u540e', '{"zh-Hans": "申后"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "申侯之女，幽王之后，因幽王宠褒姒而被废 幽王之后，被幽王废黜"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 申差 (u7533-u5dee)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('569926d1-3bbd-409b-8970-109702bf5379', 'u7533-u5dee', '{"zh-Hans": "申差"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "修鱼之战中被秦军俘虏的将领"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 申生 (u7533-u751f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d06e316e-dc9d-44d3-b216-6d5fd6cc5912', 'u7533-u751f', '{"zh-Hans": "申生"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋国太子，因骊姬作乱死于新城"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 疵 (u75b5)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4b737d50-b77b-48ef-8e8d-8808005139ad', 'u75b5', '{"zh-Hans": "疵"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "商太师，抱乐器出奔投周"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 白 (u767d)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8babae5a-940d-4c43-8b1a-6189c530e89b', 'u767d', '{"zh-Hans": "白"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "武公之子，未继位，被封于平阳"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 百里傒 (u767e-u91cc-u5092)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c9ac1302-73ca-418c-a911-47c87759f285', 'u767e-u91cc-u5092', '{"zh-Hans": "百里傒"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "虞国大夫，被俘后辗转入秦，以五羖羊皮赎回，获秦缪公重用，号五羖大夫 秦穆公命其将兵护送夷吾归晋 以晋国百姓无罪为由，主张给予晋国粟食 与蹇叔同谏穆公，哭送出征之子孟明视 其谋未被缪公采用，缪公誓师时追悔"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 皇仆 (u7687-u4ec6)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ca1f6e3f-7e21-4a75-ae16-0fd4433714f8', 'u7687-u4ec6', '{"zh-Hans": "皇仆"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "庆节之子，卒后由子差弗继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 相土 (u76f8-u571f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6e851a98-5b2d-4d3f-93da-9d1794d5d600', 'u76f8-u571f', '{"zh-Hans": "相土"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "昭明之子，继立后卒，由子昌若继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 礼 (u793c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6e32a367-6a4e-4719-ba80-d8a10ead3f83', 'u793c', '{"zh-Hans": "礼"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "十三年出亡奔魏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 祖丁 (u7956-u4e01)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d153de2d-51be-4672-9831-840891edf6a8', 'u7956-u4e01', '{"zh-Hans": "祖丁"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "祖辛之子，沃甲崩后继位为帝祖丁"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 祖乙 (u7956-u4e59)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cc710738-64ef-418f-9895-fe256ea4c9df', 'u7956-u4e59', '{"zh-Hans": "祖乙"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "迁都于邢 河亶甲之子，继位后殷商复兴 崩后由子帝祖辛继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 祖伊 (u7956-u4f0a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ed76029d-aab1-4a46-9f4c-eafaea8be9de', 'u7956-u4f0a', '{"zh-Hans": "祖伊"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "殷之祖伊闻西伯伐国，惧而告知帝纣"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 祖己 (u7956-u5df1)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('840736ab-900f-4ebd-b7a9-b3475ab89d5f', 'u7956-u5df1', '{"zh-Hans": "祖己"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "劝谏武丁勿忧，训王修政行德以顺天意 嘉许武丁以祥雉为德，为其立庙称高宗，并作高宗肜日及训"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 祖庚 (u7956-u5e9a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('179a1a4f-6409-4315-8418-67266a664858', 'u7956-u5e9a', '{"zh-Hans": "祖庚"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "武丁之子，武丁崩后继位为帝 商王，崩后由弟祖甲继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 祖甲 (u7956-u7532)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3f3ec17b-d7ae-434e-a919-fe3ade0af69f', 'u7956-u7532', '{"zh-Hans": "祖甲"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "祖庚之弟，继位后淫乱，致殷再度衰落"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 祖辛 (u7956-u8f9b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ed306319-a294-43af-bdb7-184d1c1c4f56', 'u7956-u8f9b', '{"zh-Hans": "祖辛"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "祖乙之子，继位后崩，弟沃甲立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 祭公谋父 (u796d-u516c-u8c0b-u7236)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('51248eed-0768-410a-934e-c5631f0c4a86', 'u796d-u516c-u8c0b-u7236', '{"zh-Hans": "祭公谋父"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "谏穆王勿征犬戎，陈先王德政之道，言犬戎有备难御"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦侯 (u79e6-u4faf)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a838f266-7e1e-4c80-9f36-fba7928a2f97', 'u79e6-u4faf', '{"zh-Hans": "秦侯"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦嬴之子，在位十年而卒，生公伯"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦共公 (u79e6-u5171-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6a954196-a878-49e5-a85b-f9a03b6f5ba3', 'u79e6-u5171-u516c', '{"zh-Hans": "秦共公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "康公之子，康公卒后继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦出子 (u79e6-u51fa-u5b50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('38f5fd55-7ce9-48a6-bf96-fa3f73d76ed5', 'u79e6-u51fa-u5b50', '{"zh-Hans": "秦出子"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "惠公十二年出生，惠公卒后继位 孝公所提及的不宁之先君之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦厉共公 (u79e6-u5389-u5171-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6a85ef15-5933-4cf7-98f5-257d90fa5f3a', 'u79e6-u5389-u5171-u516c', '{"zh-Hans": "秦厉共公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦悼公之子，悼公卒后继位 孝公所提及的不宁之先君之一，致使国家内忧"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦哀公 (u79e6-u54c0-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c1739df3-4de7-4bb4-acc8-d99c467878b5', 'u79e6-u54c0-u516c', '{"zh-Hans": "秦哀公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "景公之子，景公卒后继位 在位三十六年，发五百乘救楚败吴师"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦夷公 (u79e6-u5937-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1d50c774-f2d6-41b1-b7c5-ae46e9a1559d', 'u79e6-u5937-u516c', '{"zh-Hans": "秦夷公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "哀公太子，早死未得立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦始皇 (u79e6-u59cb-u7687)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('90e1802e-506f-47c7-80b2-8b3a96eaea7a', 'u79e6-u59cb-u7687', '{"zh-Hans": "秦始皇"}'::jsonb, '秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "庄襄王之子，庄襄王卒后继位，即秦始皇帝"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦嬴 (u79e6-u5b34)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4f78e051-68fb-4e75-b862-07fd215cd243', 'u79e6-u5b34', '{"zh-Hans": "秦嬴"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦侯之父，秦国早期先君"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦孝公 (u79e6-u5b5d-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4624bb13-45fc-4b26-92da-aaac3bf14ca9', 'u79e6-u5b5d-u516c', '{"zh-Hans": "秦孝公"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "显王九年受文武胙，二十六年受周致伯"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦孝文王 (u79e6-u5b5d-u6587-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d4b61e89-82a8-4921-a417-f0b9a67badcf', 'u79e6-u5b5d-u6587-u738b', '{"zh-Hans": "秦孝文王"}'::jsonb, '战国·秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "昭襄王之子，昭襄王卒后继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦宁公 (u79e6-u5b81-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('00b70ef0-25af-483f-b896-5dd324736dc1', 'u79e6-u5b81-u516c', '{"zh-Hans": "秦宁公"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "竫公之子，文公之孙，文公卒后继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦宣公 (u79e6-u5ba3-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d3b5caa1-36b2-4b27-a72f-841a2a6742f6', 'u79e6-u5ba3-u516c', '{"zh-Hans": "秦宣公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "德公长子，德公卒后继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦庄襄王 (u79e6-u5e84-u8944-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('75baf2b8-5af3-4210-b122-59cac87682e8', 'u79e6-u5e84-u8944-u738b', '{"zh-Hans": "秦庄襄王"}'::jsonb, '秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "灭东周，使东西周皆入于秦"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦康公 (u79e6-u5eb7-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7ca9d4b9-3bdb-4c89-a198-cb31b75e8093', 'u79e6-u5eb7-u516c', '{"zh-Hans": "秦康公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦缪公太子，缪公卒后继位，是为康公 秦国君主，在位十二年，多次与晋交战"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦德公 (u79e6-u5fb7-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('77726816-4189-4191-b8ae-ce9d4b6ae564', 'u79e6-u5fb7-u516c', '{"zh-Hans": "秦德公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "初居雍城大郑宫，立二年卒，生子三人"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦怀公 (u79e6-u6000-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b76bd25a-a78b-4179-bc39-63ee0f82faf9', 'u79e6-u6000-u516c', '{"zh-Hans": "秦怀公"}'::jsonb, '春秋战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "简公之父，昭子与简公悼子之父"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦悼公 (u79e6-u60bc-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b788b8da-9e37-44cb-a034-79b5f718f38d', 'u79e6-u60bc-u516c', '{"zh-Hans": "秦悼公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "在位十四年后卒，子厉共公继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦惠公 (u79e6-u60e0-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3d647c32-9b0b-4f94-b19d-5263b6412e61', 'u79e6-u60e0-u516c', '{"zh-Hans": "秦惠公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "夷公之子，夷公早死后被立为君 在位期间伐蜀取南郑，卒后由出子继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦惠王 (u79e6-u60e0-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9e121cb9-fd9e-4b37-9137-47fe13ead716', 'u79e6-u60e0-u738b', '{"zh-Hans": "秦惠王"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "显王三十三年受贺，三十五年受文武胙，四十四年称王"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦成公 (u79e6-u6210-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('48061209-63f6-4d69-9eba-471de7985e25', 'u79e6-u6210-u516c', '{"zh-Hans": "秦成公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "德公次子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦文公 (u79e6-u6587-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1acac368-f62d-468a-9464-da4a5f44c1f6', 'u79e6-u6587-u516c', '{"zh-Hans": "秦文公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦襄公之子，襄公卒后继位 秦早期君主，东猎营邑、伐戎收周余民，在位五十年"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦昭子 (u79e6-u662d-u5b50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('eda7daad-8b7b-40e7-9fa0-a2a5b8944218', 'u79e6-u662d-u5b50', '{"zh-Hans": "秦昭子"}'::jsonb, '春秋战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "简公之兄，怀公之子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦昭王 (u79e6-u662d-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f25ff1dc-53b7-40b4-adec-a96529d8c0ac', 'u79e6-u662d-u738b', '{"zh-Hans": "秦昭王"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "因西周背秦与诸侯约从而大怒，命将军摎攻西周"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦景公 (u79e6-u666f-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('acd63240-e9a6-4dc1-908a-4f6fa776a055', 'u79e6-u666f-u516c', '{"zh-Hans": "秦景公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦桓公之子，桓公卒后继立 在位四十年，与晋、楚等国周旋，最终卒，子哀公继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦桓公 (u79e6-u6853-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('fe882af0-51f4-46a6-9a4f-61011d2f4c46', 'u79e6-u6853-u516c', '{"zh-Hans": "秦桓公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与晋厉公夹河而盟后背盟，联翟攻晋，立二十七年卒"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦灵公 (u79e6-u7075-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bb347375-b66c-4050-8864-124c8e2318e4', 'u79e6-u7075-u516c', '{"zh-Hans": "秦灵公"}'::jsonb, '春秋战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "在位期间晋城少梁，秦击之，后卒，子献公未得立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦献公 (u79e6-u732e-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('caa24f9d-5cea-4743-8690-e4b1a47b06a5', 'u79e6-u732e-u516c', '{"zh-Hans": "秦献公"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "灵公之子，灵公卒后未得立位 秦国君主，止从死、城栎阳、与晋魏交战，二十四年卒 孝公之父，镇抚边境，徙治栎阳，欲东伐复缪公故地"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦王 (u79e6-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c5f0f89b-0a98-4419-84f3-4c2ae7853c41', 'u79e6-u738b', '{"zh-Hans": "秦王"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被马犯告知梁将伐周，遂出兵边境观望 被周聚劝说勿攻周，周聚陈述攻周将使天下合齐之害"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦穆公夫人 (u79e6-u7a46-u516c-u592b-u4eba)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4f9b6d25-e59e-4821-baeb-6a0ba2ea63ca', 'u79e6-u7a46-u516c-u592b-u4eba', '{"zh-Hans": "秦穆公夫人"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋惠公夷吾之姊，嫁缪公为夫人，为兄被俘而衰绖请命"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦简公 (u79e6-u7b80-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bd7f9f66-b7c5-4d0c-b576-c4d08ddbb28a', 'u79e6-u7b80-u516c', '{"zh-Hans": "秦简公"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "灵公季父，献公未立而被立为君，即简公 孝公所提及的不宁之先君之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦缪公 (u79e6-u7f2a-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a1d87a9d-ecde-4486-9285-aeba4a25e2d3', 'u79e6-u7f2a-u516c', '{"zh-Hans": "秦缪公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "孝公先祖，东平晋乱，西霸戎翟，广地千里，天子致伯"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦襄公 (u79e6-u8944-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('68cacaa2-03dc-4fb6-bfaf-6bf160888e18', 'u79e6-u8944-u516c', '{"zh-Hans": "秦襄公"}'::jsonb, '西周/春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "庄公次子，继位为太子后即位，救周有功，被平王封为诸侯，赐岐西之地，始建秦国"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 秦躁公 (u79e6-u8e81-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('305ddd4f-ee69-4353-bf97-b3a6f513d9f6', 'u79e6-u8e81-u516c', '{"zh-Hans": "秦躁公"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "孝公所提及的不宁之先君之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 穆王 (u7a46-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2eba9b3e-b6e0-4a83-b355-0404342198ac', 'u7a46-u738b', '{"zh-Hans": "穆王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "昭王之子，即位时已五十岁，闵文武之道缺，命伯臩申诫太仆 听取甫侯建议，颁布祥刑之法 在位五十五年后崩，子共王继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 穷奇 (u7a77-u5947)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('923f754d-2767-4698-9ef6-4c2b0f9701fc', 'u7a77-u5947', '{"zh-Hans": "穷奇"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "少暤氏之不才子，毁信恶忠、崇饰恶言，被天下称为穷奇"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 章子 (u7ae0-u5b50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('215b38cd-ac73-48b5-9635-9524f1197e6d', 'u7ae0-u5b50', '{"zh-Hans": "章子"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "齐国将领，参与联军攻楚方城"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 竫公 (u7aeb-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8e5e85c0-f9aa-4e6f-936d-2fff07ada6ba', 'u7aeb-u516c', '{"zh-Hans": "竫公"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "文公太子，先文公而卒，赐谥竫公"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 简公 (u7b80-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e6e9d27e-b800-4c54-8296-19ac3cfcec42', 'u7b80-u516c', '{"zh-Hans": "简公"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "在位期间令吏带剑、堑洛、城重泉，十六年后卒"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 管叔 (u7ba1-u53d4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6371d326-0731-4488-bf85-243ea3fcc5e1', 'u7ba1-u53d4', '{"zh-Hans": "管叔"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "疑周公，与武庚作乱叛周，被周公奉成王命诛杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 管叔鲜 (u7ba1-u53d4-u9c9c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f2911b94-414d-43e2-9ce8-b3eef81e3b76', 'u7ba1-u53d4-u9c9c', '{"zh-Hans": "管叔鲜"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "武王之弟，受命辅佐禄父治殷，后封于管"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 管至父 (u7ba1-u81f3-u7236)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('812e812b-df41-4488-93fa-4843b2be109f', 'u7ba1-u81f3-u7236', '{"zh-Hans": "管至父"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "齐人，参与杀齐襄公并立公孙无知，后被雍廪所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 缙云氏 (u7f19-u4e91-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ae47eddd-804b-4715-974a-d1eb99a19509', 'u7f19-u4e91-u6c0f', '{"zh-Hans": "缙云氏"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "其不才子被天下称为饕餮，为四凶之一的来源氏族首领"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 缪公 (u7f2a-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('dfbc851d-f3bc-4d4d-bdab-efd522f63865', 'u7f2a-u516c', '{"zh-Hans": "缪公"}'::jsonb, 'uncertain', 'uncertain', 'ai_inferred', NULL, NULL, '{"zh-Hans": "成公之弟，因成公诸子未立而继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 缪嬴 (u7f2a-u5b34)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b45d696f-f555-4e83-ac79-e7eec6d5a881', 'u7f2a-u5b34', '{"zh-Hans": "缪嬴"}'::jsonb, '西周/春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "襄公之女弟，嫁给丰王为妻"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 胡亥 (u80e1-u4ea5)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('57a05049-d840-487f-892d-344c1b60b85d', 'u80e1-u4ea5', '{"zh-Hans": "胡亥"}'::jsonb, '秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "始皇帝之子，继位为二世皇帝，在位三年被赵高所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 胡阳 (u80e1-u9633)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0baa918f-4de5-4ad6-ad18-bb05064af08a', 'u80e1-u9633', '{"zh-Hans": "胡阳"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "三十三年攻魏取卷、蔡阳、长社，击芒卯于华阳；三十八年攻赵阏与不能取"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 胤 (u80e4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bcc268f7-cdb8-45f6-bc1c-b713335c158a', 'u80e4', '{"zh-Hans": "胤"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "奉命征讨湎淫废时的羲、和，作《胤征》"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 芈戎 (u8288-u620e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a43e96dd-f32d-42e1-8454-b7911f626fc8', 'u8288-u620e', '{"zh-Hans": "芈戎"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受命为将军攻楚，取新市"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 芒卯 (u8292-u536f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b1a65226-c85c-40f0-86be-5432d89ea865', 'u8292-u536f', '{"zh-Hans": "芒卯"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "三十三年在华阳被秦军击破"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 芮伯 (u82ae-u4f2f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('33c3fc0d-8a20-484c-86a5-a12fa70fc252', 'u82ae-u4f2f', '{"zh-Hans": "芮伯"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "来朝秦德公 来朝觐见"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 芮良夫 (u82ae-u826f-u592b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7b9e7074-eb0f-4417-85e1-d08e4d025c38', 'u82ae-u826f-u592b', '{"zh-Hans": "芮良夫"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "大夫，谏厉王勿近荣夷公、勿专利，厉王不听"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 苏代 (u82cf-u4ee3)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('98c7b6fe-1eb2-45cf-b1f5-b5ee035f5ce9', 'u82cf-u4ee3', '{"zh-Hans": "苏代"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "为周游说楚王，劝楚勿伐周，以疏周于秦之策 为东周君出谋划策，游说韩相国停止征甲粟并割让高都"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 苏厉 (u82cf-u5389)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bc219c2b-0855-4c80-9717-73d837edca9d', 'u82cf-u5389', '{"zh-Hans": "苏厉"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "游说周君，建议令人劝白起称病不出"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 若 (u82e5)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8d252418-77ad-4e2c-8c52-ab84db80f49a', 'u82e5', '{"zh-Hans": "若"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "三十年以蜀守身份伐楚，取巫郡及江南为黔中郡"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 范氏 (u8303-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e5d4a3e7-a096-434a-892c-48909c5e71c3', 'u8303-u6c0f', '{"zh-Hans": "范氏"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋卿，与中行氏反晋，兵败亡奔齐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 荀息 (u8340-u606f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d1257616-881f-4678-b90c-62ae78a300cf', 'u8340-u606f', '{"zh-Hans": "荀息"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋国大臣，立卓子为君，后被里克所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 荣伯 (u8363-u4f2f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ac17502b-e21e-4b6f-8e3c-b2a683bed0cc', 'u8363-u4f2f', '{"zh-Hans": "荣伯"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "成王赐命其作贿息慎之命"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 荣夷公 (u8363-u5937-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('35339d44-9255-426b-97a8-71fb2de7878f', 'u8363-u5937-u516c', '{"zh-Hans": "荣夷公"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "厉王所亲近之臣，好专利，被芮良夫批评，终被厉王任为卿士"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 葛伯 (u845b-u4f2f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('15525c10-3e44-4885-a386-37bfb92f02da', 'u845b-u4f2f', '{"zh-Hans": "葛伯"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "不行祭祀，被汤首先讨伐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蒙武 (u8499-u6b66)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ba9a4ea6-1204-4955-95da-142ca48dde6a', 'u8499-u6b66', '{"zh-Hans": "蒙武"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "二十二年伐齐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蔡叔 (u8521-u53d4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('749ac677-2ff0-4dc4-a2e2-1580f163988e', 'u8521-u53d4', '{"zh-Hans": "蔡叔"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "疑周公，与武庚作乱叛周，被周公放逐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蔡叔度 (u8521-u53d4-u5ea6)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('435565e5-f8f4-4d41-9223-a568458f6a48', 'u8521-u53d4-u5ea6', '{"zh-Hans": "蔡叔度"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "武王之弟，受命辅佐禄父治殷，后封于蔡"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蔡尉 (u8521-u5c09)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('04b6a296-ea84-48d8-b4f4-c27bad05d332', 'u8521-u5c09', '{"zh-Hans": "蔡尉"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "捐弗守，被张唐还斩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 虞仲 (u865e-u4ef2)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5b508025-03f8-4be4-8e95-d62dedae88df', 'u865e-u4ef2', '{"zh-Hans": "虞仲"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "古公次子，与太伯同奔荆蛮，文身断发以让季历"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 虞君 (u865e-u541b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('16a84469-dc96-487e-a086-8c8dee943798', 'u865e-u541b', '{"zh-Hans": "虞君"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "因以璧马贿赂晋国而亡国，被晋献公所虏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 虢叔 (u8662-u53d4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('652f7c9d-b0b1-47cc-ab86-1bcb21ccdc0d', 'u8662-u53d4', '{"zh-Hans": "虢叔"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与郑伯合力杀子颓，迎惠王复位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 虢射 (u8662-u5c04)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('db256f55-d4cf-4082-b9e3-a0ffefbea291', 'u8662-u5c04', '{"zh-Hans": "虢射"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋君谋臣，建议趁秦饥荒出兵伐秦"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 虢文公 (u8662-u6587-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2aa261cf-b43a-4e61-be0f-0daeccbc8519', 'u8662-u6587-u516c', '{"zh-Hans": "虢文公"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "谏宣王不可不修籍田，王不听"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 虢石父 (u8662-u77f3-u7236)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5409e935-d2bf-4f81-b185-d8a7642d208b', 'u8662-u77f3-u7236', '{"zh-Hans": "虢石父"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "幽王宠臣，为卿用事，佞巧善谀好利，国人皆怨"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蜀侯 (u8700-u4faf)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('27cb905e-2cc8-493d-901b-e1a55adc69dc', 'u8700-u4faf', '{"zh-Hans": "蜀侯"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被蜀相壮所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蜀侯辉 (u8700-u4faf-u8f89)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a08474e9-9d06-403c-8f25-d9dd9d723e5f', 'u8700-u4faf-u8f89', '{"zh-Hans": "蜀侯辉"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "反叛秦国，被司马错平定"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蜀壮 (u8700-u58ee)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3c50af45-c95f-438b-9044-ceb1d8527dea', 'u8700-u58ee', '{"zh-Hans": "蜀壮"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "杀蜀侯后降秦"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蜚廉 (u871a-u5ec9)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ad649f1e-d81d-44a1-9559-fd62042b1f81', 'u871a-u5ec9', '{"zh-Hans": "蜚廉"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "善走，与子恶来俱以材力事殷纣，纣死后为坛霍太山而报，得石棺铭文"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 衡父 (u8861-u7236)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0f10ccc8-fd79-4193-8c00-190d81bd8eff', 'u8861-u7236', '{"zh-Hans": "衡父"}'::jsonb, '西周', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "皋狼之子，造父之父"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 襄王 (u8944-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ce5a2daf-8aa8-42a9-9c07-90d92f986b25', 'u8944-u738b', '{"zh-Hans": "襄王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "周惠王之子，继位后畏叔带，后借齐桓公之力平戎 周襄王，因与卫滑之事被郑文公怨恨，后欲以翟女为后"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 西周公 (u897f-u5468-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7ee3e4c8-08c2-48b0-92aa-88e5fa070a6f', 'u897f-u5468-u516c', '{"zh-Hans": "西周公"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦取九鼎后被迁至惮狐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 西周君 (u897f-u5468-u541b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('632d35ad-7c7f-4e32-b138-aafc458f0cee', 'u897f-u5468-u541b', '{"zh-Hans": "西周君"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "背秦联合诸侯攻秦，兵败后亲赴秦国请罪，献三十六城"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 谭伯 (u8c2d-u4f2f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('655092c4-7033-4ed2-8108-89bb23d7dc96', 'u8c2d-u4f2f', '{"zh-Hans": "谭伯"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "翟人来诛时被杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 贲 (u8d32)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2e2350ed-a024-4012-a100-db597e75998a', 'u8d32', '{"zh-Hans": "贲"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "四十五年攻韩，取十城"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 费中 (u8d39-u4e2d)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('501f609e-c754-49f6-abcd-b9eb414fa1e3', 'u8d39-u4e2d', '{"zh-Hans": "费中"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "纣所用佞臣，善谀好利，殷人不亲"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 费仲 (u8d39-u4ef2)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('77f70097-a549-4940-a71e-a959c1e2131d', 'u8d39-u4ef2', '{"zh-Hans": "费仲"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "殷纣王的嬖臣，闳夭等人通过他向纣王献礼"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 赧王 (u8d67-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('dbbdeb41-047c-4810-93f0-708ecfebba85', 'u8d67-u738b', '{"zh-Hans": "赧王"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "慎靓王之子，时东西周分治，徙都西周"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 赵成侯 (u8d75-u6210-u4faf)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e512ae63-7f0d-42d6-8e21-d78ec0797777', 'u8d75-u6210-u4faf', '{"zh-Hans": "赵成侯"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与秦孝公同时期的赵国君主"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 赵渴 (u8d75-u6e34)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e2fe2c7b-7983-4706-93bd-80f452fa8b14', 'u8d75-u6e34', '{"zh-Hans": "赵渴"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "修鱼之战中被秦军击败的赵国公子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 赵盾 (u8d75-u76fe)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3f40b446-d2cf-452a-8e64-8499ed261b2d', 'u8d75-u76fe', '{"zh-Hans": "赵盾"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋国权臣，欲立公子雍为君，后又反击秦师"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 赵穿 (u8d75-u7a7f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5937a2a6-423a-46e7-8270-4a96f52f020e', 'u8d75-u7a7f', '{"zh-Hans": "赵穿"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋国大夫，弑杀晋灵公"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 赵衰 (u8d75-u8870)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('be96a4a8-ccb9-44b4-9428-cf52f9fc76e4', 'u8d75-u8870', '{"zh-Hans": "赵衰"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "造父之后，赵氏后裔"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 赵鞅 (u8d75-u9785)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4c2c0627-ad2d-43eb-bbf0-29e208b69e18', 'u8d75-u9785', '{"zh-Hans": "赵鞅"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受晋命与智氏共攻范氏、中行氏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 躁公 (u8e81-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a07fbfa1-e498-4bf6-a3b2-b942f071463b', 'u8e81-u516c', '{"zh-Hans": "躁公"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "厉共公之子，厉共公卒后继位为秦君 在位期间南郑叛乱、义渠来伐，十四年卒"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 辛伯 (u8f9b-u4f2f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c278ff99-bd0f-4b1f-bd72-ca7bd6c051fc', 'u8f9b-u4f2f', '{"zh-Hans": "辛伯"}'::jsonb, '东周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "向庄王告发周公黑肩谋逆之事"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 辛甲 (u8f9b-u7532)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cfb53d56-8f54-49f7-baee-03a851a1c4bb', 'u8f9b-u7532', '{"zh-Hans": "辛甲"}'::jsonb, '先周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "归附西伯的大夫之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 边伯 (u8fb9-u4f2f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2e72f058-5386-450d-b1ee-f11cdaf0017e', 'u8fb9-u4f2f', '{"zh-Hans": "边伯"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "大夫，因惠王夺地而作乱，谋召燕卫之师伐惠王"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 连称 (u8fde-u79f0)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7db35712-be8c-4122-875f-ed16dc60be05', 'u8fde-u79f0', '{"zh-Hans": "连称"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "齐人，参与杀齐襄公并立公孙无知"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 造父 (u9020-u7236)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('37ebea05-2c41-46fc-9a00-83096ad66179', 'u9020-u7236', '{"zh-Hans": "造父"}'::jsonb, '西周', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "善御，幸于周穆王，平徐偃王之乱，受封赵城，赵氏由此得姓 秦之先祖，因封于赵城而为赵氏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 郑伯 (u90d1-u4f2f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2e4c014c-3559-42c5-8565-c0494ea36940', 'u90d1-u4f2f', '{"zh-Hans": "郑伯"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与虢叔合力杀子颓，迎惠王复位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 郑庄公 (u90d1-u5e84-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1b159872-8960-453d-bc80-c588766fb61f', 'u90d1-u5e84-u516c', '{"zh-Hans": "郑庄公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "朝见桓王未受礼遇，后与鲁易许田，并射伤桓王"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 郑文公 (u90d1-u6587-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e2164b35-e993-49ca-af83-3e630080d674', 'u90d1-u6587-u516c', '{"zh-Hans": "郑文公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "因怨惠王与襄王，囚禁周使伯服，引发周翟伐郑"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 郑昭公 (u90d1-u662d-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e7ed54b2-e72c-4fdb-b3de-f46fcf4390f1', 'u90d1-u662d-u516c', '{"zh-Hans": "郑昭公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "郑国君主，被高渠眯所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 郤芮 (u90e4-u82ae)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3ad49c32-6c8a-408d-a4bf-dc0439470ec2', 'u90e4-u82ae', '{"zh-Hans": "郤芮"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋国大臣，与吕甥同谋背秦约，疑丕郑有间"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 郦山女 (u90e6-u5c71-u5973)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e666ae5e-9e34-4ff6-8972-edf5536975e4', 'u90e6-u5c71-u5973', '{"zh-Hans": "郦山女"}'::jsonb, '西周', 'uncertain', 'ai_inferred', NULL, NULL, '{"zh-Hans": "申侯先祖之女，嫁戎胥轩为妻，生中潏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 鄂侯 (u9102-u4faf)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ffa19925-910a-4a0e-b4b0-4bc79a4e1956', 'u9102-u4faf', '{"zh-Hans": "鄂侯"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "三公之一，为九侯之死力争，被纣脯杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 里克 (u91cc-u514b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d3cfcc45-a7c6-4d38-a513-2048da313d8d', 'u91cc-u514b', '{"zh-Hans": "里克"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋国大臣，先杀奚齐，后杀卓子及荀息，最终被夷吾所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 重耳 (u91cd-u8033)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6ed51c70-8cef-4cb7-ad4c-5f050a73011e', 'u91cd-u8033', '{"zh-Hans": "重耳"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "因骊姬之乱出奔他国 晋国公子，丕郑称晋人实欲立其为君 流亡楚国，被秦缪公迎回晋国立为君，即晋文公，后派人杀子圉"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 针虎 (u9488-u864e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7230a5de-6ffb-4e45-a40d-99c10180502f', 'u9488-u864e', '{"zh-Hans": "针虎"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "子舆氏三良之一，随秦缪公从死"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 错 (u9519)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e088e560-2c73-4e9d-8b83-7cb14fe9feb1', 'u9519', '{"zh-Hans": "错"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "取轵及邓，后攻垣、河雍，又攻魏河内"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 闳夭 (u95f3-u592d)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('12f8f815-d9ac-46e6-ab39-d0ba778bd0d6', 'u95f3-u592d', '{"zh-Hans": "闳夭"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "归附西伯的贤士之一 为西伯被囚而忧患，设法搜集美女文马奇物贿赂纣王以求释放 执剑护卫武王 受命封比干之墓"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 阳甲 (u9633-u7532)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0abe51f4-21b6-4c4f-9200-0bfc8996712c', 'u9633-u7532', '{"zh-Hans": "阳甲"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "祖丁之子，南庚崩后继位，在位时殷道衰 盘庚之兄，崩后由盘庚继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 陵 (u9675)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('270e019a-aa95-449f-9539-ac077f9ebab6', 'u9675', '{"zh-Hans": "陵"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "四十八年攻赵邯郸，战不善被免"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 随会 (u968f-u4f1a)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('902b7e5a-922f-40b8-9825-d26652e1bda7', 'u968f-u4f1a', '{"zh-Hans": "随会"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋臣，赴秦迎公子雍，后奔秦，被魏雠馀诈谋骗回晋国"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 隰朋 (u96b0-u670b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('90588659-57dc-4cb5-afe8-ccd2f82a14aa', 'u96b0-u670b', '{"zh-Hans": "隰朋"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "齐国大臣，与管仲同年去世"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 雍 (u96cd)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('41527dc6-3aad-4e44-8ef9-4facaa939e51', 'u96cd', '{"zh-Hans": "雍"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋襄公之弟，秦女所生，在秦，赵盾欲立之为晋君"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 雍己 (u96cd-u5df1)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bbb04292-6c55-4710-9599-7d2bc9773e00', 'u96cd-u5df1', '{"zh-Hans": "雍己"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "小甲之弟，继位为帝雍己，在位时殷道衰，诸侯或不至 商王，崩后由弟太戊继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 雍廪 (u96cd-u5eea)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cf170ae3-101e-4d71-a4ca-39b3a5c78d0b', 'u96cd-u5eea', '{"zh-Hans": "雍廪"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "齐人，杀无知及管至父等，拥立齐桓公"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 鞠 (u97a0)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a7e8b909-90bc-4157-a20b-a5bc0f16dbc7', 'u97a0', '{"zh-Hans": "鞠"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "不窋之子，继立后卒，传位于子公刘"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 韩公叔 (u97e9-u516c-u53d4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a034027f-03b3-495d-ab6d-05945a12941f', 'u97e9-u516c-u53d4', '{"zh-Hans": "韩公叔"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "史厌建议周君派人游说的韩国要人"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 韩公子长 (u97e9-u516c-u5b50-u957f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ad5e43e7-5290-418f-97d2-0c5e3f0711c4', 'u97e9-u516c-u5b50-u957f', '{"zh-Hans": "韩公子长"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被封为诸侯"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 韩哀侯 (u97e9-u54c0-u4faf)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c6492ccb-c78c-4495-9cc6-f029903aee0c', 'u97e9-u54c0-u4faf', '{"zh-Hans": "韩哀侯"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与秦孝公同时期的韩国君主"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 韩奂 (u97e9-u5942)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5bfa7691-7410-437d-ba49-0bb4c90b8b34', 'u97e9-u5942', '{"zh-Hans": "韩奂"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "修鱼之战中被秦军击败的韩国太子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 韩王 (u97e9-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('450ba16b-7216-4469-939f-7f65ee1abf45', 'u97e9-u738b', '{"zh-Hans": "韩王"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "入朝秦国，委国听令，又衰绖入吊昭襄王丧"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 韩相国 (u97e9-u76f8-u56fd)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('4496625d-0c60-4e14-8452-96ab0aadb88e', 'u97e9-u76f8-u56fd', '{"zh-Hans": "韩相国"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "韩国相国，被苏代说服停止向东周征甲粟并割让高都"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 韩襄王 (u97e9-u8944-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9f54f781-57a4-46f0-a821-63a1223f138d', 'u97e9-u8944-u738b', '{"zh-Hans": "韩襄王"}'::jsonb, '战国·韩', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与秦武王会于临晋外"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 饕餮 (u9955-u992e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0cc1ea00-0a98-4c3a-b7af-c021d69ac6aa', 'u9955-u992e', '{"zh-Hans": "饕餮"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "缙云氏之不才子，贪于饮食、冒于货贿，被天下称为饕餮"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 驩兜 (u9a69-u515c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('73d7a713-158d-4b92-8de0-f130c267297e', 'u9a69-u515c', '{"zh-Hans": "驩兜"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "向帝举荐共工，称其方鸠僝功 被放逐于崇山，列四罪之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 马犯 (u9a6c-u72af)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7b9d062d-5d9a-4726-886a-2e52a86e694c', 'u9a6c-u72af', '{"zh-Hans": "马犯"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "游说周君与梁王、秦王，借各方力量使梁国为周筑城护周"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 骊姬 (u9a8a-u59ec)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cc611d13-d62d-408b-a453-1776b02f1ed4', 'u9a8a-u59ec', '{"zh-Hans": "骊姬"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "在晋国作乱，导致太子申生死、重耳夷吾出奔 晋献公之妾，奚齐之母"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 高圉 (u9ad8-u5709)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d99d0563-1e02-4ba5-a381-f64ca360dacc', 'u9ad8-u5709', '{"zh-Hans": "高圉"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "公非之子，卒后由子亚圉继立"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 高渠眯 (u9ad8-u6e20-u772f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('fa90aaa5-068c-45c4-8f48-84f82347333f', 'u9ad8-u6e20-u772f', '{"zh-Hans": "高渠眯"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "郑国人，弑杀其君昭公"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 鬻子 (u9b3b-u5b50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('14f0cab1-808e-4a6d-b3e3-7c34fcaf3074', 'u9b3b-u5b50', '{"zh-Hans": "鬻子"}'::jsonb, '先周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "归附西伯的贤士之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 魏公子劲 (u9b4f-u516c-u5b50-u52b2)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0d881f4f-1b42-4290-aa2a-b325bfebb653', 'u9b4f-u516c-u5b50-u52b2', '{"zh-Hans": "魏公子劲"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被封为诸侯"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 魏惠王 (u9b4f-u60e0-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('deb3f551-77be-40c0-8a66-f2a5e4a0d4d2', 'u9b4f-u60e0-u738b', '{"zh-Hans": "魏惠王"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与秦孝公同时期的魏国君主，魏筑长城与秦接界 与秦会于杜平 与秦武王会于临晋"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 魏无忌 (u9b4f-u65e0-u5fcc)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d092d1ff-c4c0-41e1-b574-0613537c83f7', 'u9b4f-u65e0-u5fcc', '{"zh-Hans": "魏无忌"}'::jsonb, '战国·魏', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "以魏将身份率五国兵击秦，使秦却于河外，蒙骜败退"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 魏章 (u9b4f-u7ae0)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('88ec113e-deae-49af-934c-084244520411', 'u9b4f-u7ae0', '{"zh-Hans": "魏章"}'::jsonb, '战国·秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与张仪同东出至魏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 魏错 (u9b4f-u9519)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('11f435c5-04e8-4524-91a9-08da9f88adeb', 'u9b4f-u9519', '{"zh-Hans": "魏错"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋国将领，在雁门之战中被虏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 魏雠馀 (u9b4f-u96e0-u9980)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3cdaa58a-89dc-4b3c-b244-d865c17dacea', 'u9b4f-u96e0-u9980', '{"zh-Hans": "魏雠馀"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "晋臣，奉命诈装叛晋入秦，设谋将随会骗回晋国"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 鲁姬子 (u9c81-u59ec-u5b50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('258e188d-6f5f-476b-9c79-1af70e8cfd84', 'u9c81-u59ec-u5b50', '{"zh-Hans": "鲁姬子"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "宁公之妾，武公与德公之母"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 鲁桓公 (u9c81-u6853-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8480eaa3-4a83-4c92-b8ec-2d28a02efd43', 'u9c81-u6853-u516c', '{"zh-Hans": "鲁桓公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "隐公被杀后被立为鲁君"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 鲁武公 (u9c81-u6b66-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6e75b2d2-1bb4-4df6-90e9-9024adcb760d', 'u9c81-u6b66-u516c', '{"zh-Hans": "鲁武公"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "宣王十二年来朝觐见"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 鲁隐公 (u9c81-u9690-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('eb23cc65-2371-46e1-9820-77982dfd5bb5', 'u9c81-u9690-u516c', '{"zh-Hans": "鲁隐公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "鲁国君主，被公子翬弑杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 齐威王 (u9f50-u5a01-u738b)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b19f6c72-8248-4d48-9c79-e9b69da2d01c', 'u9f50-u5a01-u738b', '{"zh-Hans": "齐威王"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与秦孝公同时期的东方强国君主之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 齐平公 (u9f50-u5e73-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('07cb4e6f-0bae-4d45-89a9-ea1ba0830da0', 'u9f50-u5e73-u516c', '{"zh-Hans": "齐平公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "简公之弟，被田常拥立为齐君"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 齐庄公 (u9f50-u5e84-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('87b297bf-7373-47fa-9a00-3dfc1e7baab7', 'u9f50-u5e84-u516c', '{"zh-Hans": "齐庄公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "齐国君主，被崔杼所弑"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 齐悼公 (u9f50-u60bc-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('355801eb-85d0-45e4-ae73-8858c798dd46', 'u9f50-u60bc-u516c', '{"zh-Hans": "齐悼公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "孺子之兄，被田乞拥立为齐君，后被齐人所弑"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 齐简公 (u9f50-u7b80-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a51201ed-88f6-44c7-997e-27aa19e8e948', 'u9f50-u7b80-u516c', '{"zh-Hans": "齐简公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "悼公之子，悼公被弑后立为齐君，后被田常所弑"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 齐襄公 (u9f50-u8944-u516c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3571f505-d3e0-4bc5-9782-d3e76f71f164', 'u9f50-u8944-u516c', '{"zh-Hans": "齐襄公"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被管至父、连称等人所杀"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 龙贾 (u9f99-u8d3e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a175dd35-39bf-4629-bf0c-b7135c5bd21c', 'u9f99-u8d3e', '{"zh-Hans": "龙贾"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "魏国将领，被公子卬所虏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 魏冉 (wei-ran)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('672bcec6-d517-41fb-89db-6c3f57fac05b', 'wei-ran', '{"zh-Hans": "魏冉"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "楼缓免职后继任秦相 封陶为诸侯，多次为相，后出之陶"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 卫鞅 (wei-yang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('513377a3-bee4-43d4-9dc1-ab0086f277e0', 'wei-yang', '{"zh-Hans": "卫鞅"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "听闻秦孝公求贤令，西入秦国，通过景监求见孝公 被任命为大良造，率兵围攻魏安邑并使其降服"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 微子启 (wei-zi-qi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('89ce41bc-f9d2-4ebb-aa9c-de3e4e18abb0', 'wei-zi-qi', '{"zh-Hans": "微子启"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝乙长子，因母出身低贱而不得继承王位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 武丁 (wu-ding)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('28626579-1c80-4789-b14b-7b9369885397', 'wu-ding', '{"zh-Hans": "武丁"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "即位后思复兴殷，夜梦圣人，寻得傅说并举为相，殷国大治 祭成汤时遇飞雉登鼎，听从祖己劝谏修政行德，使殷道复兴 商王，崩后被祖己立庙称高宗，有高宗肜日及训传世"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 武王 (wu-wang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('205b5203-ace4-49d9-80ec-c7c693f914e0', 'wu-wang', '{"zh-Hans": "武王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "惠王之子，继位后韩魏齐楚越皆宾从 秦武王，与魏会盟、伐宜阳、举鼎绝膑而死"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 象 (xiang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0cdfa4af-4767-484f-a678-426a035a781c', 'xiang', '{"zh-Hans": "象"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "舜之弟，性格傲慢，与顽父嚚母同被提及，舜仍能以孝和谐家庭"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 西伯昌 (xi-bo-chang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('cc6fe4f8-3f8c-4620-ade4-61ec6cd672a1', 'xi-bo-chang', '{"zh-Hans": "西伯昌"}'::jsonb, '商', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "为三公之一，闻九侯鄂侯之死窃叹，被囚羑里，后献地请除炮格之刑获赦"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 契 (xie)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('10ccab31-8acf-4d89-9e85-accc4eda7787', 'xie', '{"zh-Hans": "契"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "禹谦让司空之职时所推举的人选之一 被帝任命为司徒，负责教化百姓、推行五教"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 西乞术 (xi-qi-shu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('993226cf-0558-4c85-91c5-17f06cb7bddb', 'xi-qi-shu', '{"zh-Hans": "西乞术"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "蹇叔之子，受命将兵袭郑"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 羲叔 (xi-shu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('64e7b89d-b0c6-4e8b-8d67-5ebde716b623', 'xi-shu', '{"zh-Hans": "羲叔"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受命居南交，主掌南方夏季历法授时"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 羲仲 (xi-zhong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bd91336a-400f-43c8-a430-0835a9607aa7', 'xi-zhong', '{"zh-Hans": "羲仲"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受命居嵎夷旸谷，主掌东方春季历法授时"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 玄嚣 (xuan-xiao)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d946e274-3979-40b5-a01d-e044ff05660c', 'xuan-xiao', '{"zh-Hans": "玄嚣"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "黄帝长子，又名青阳，降居江水 帝喾之祖父，其孙高辛继颛顼之位 黄帝之子，蟜极之父，未得在位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 炎帝 (yan-di)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5f41c43c-db30-44c5-a6b0-3608b70e2438', 'yan-di', '{"zh-Hans": "炎帝"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "欲侵陵诸侯，与轩辕战于阪泉之野，三战后被制服"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 尧 (yao)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2da772b8-3c0b-4e13-9452-5e85ae34bf26', 'yao', '{"zh-Hans": "尧"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "闻弃善农耕，举弃为农师 武王追思先圣王，褒封其后裔于蓟"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 益 (yi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ea880e29-01ac-40ed-b4f3-5f1f9da8814a', 'yi', '{"zh-Hans": "益"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被帝任命为虞官，拜谢后谦让于朱虎、熊罴"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伊尹 (yi-yin)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('02ee394b-9b9c-442c-ba7e-a8c7d2b1c05e', 'yi-yin', '{"zh-Hans": "伊尹"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "称赞汤之言明智，劝勉汤听道进善 以滋味说汤致于王道，后被任以国政，曾去汤适夏又归亳 随从汤出征伐桀 汤胜夏后作报（报告/祭告） 作《咸有一德》 中壬崩后立太甲为帝，并作伊训等篇以辅佐 将太甲放逐桐宫，摄行政事代理国政，朝见诸侯 迎帝太甲归政，嘉其修德，作太甲训三篇褒扬之 于沃丁之时去世，葬于亳，其事迹由咎单整理成篇"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 幽王 (you-wang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('56b3770d-997e-4d1f-92c2-d865e1114b42', 'you-wang', '{"zh-Hans": "幽王"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被犬戎所败，导致周室东迁洛邑"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 由余 (you-yu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ba62fa14-e185-4bb4-9bf7-b4a1d4fb14b1', 'you-yu', '{"zh-Hans": "由余"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "戎王使臣，先祖为晋人，后降秦，助秦谋伐戎 为秦缪公谋划伐戎，助秦霸西戎"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 禹 (yu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('95638bf0-ec39-42c0-a74b-f101d1d22f58', 'yu', '{"zh-Hans": "禹"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "平水土，得帝赐玄圭，称大费为辅"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 张仪 (zhang-yi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('103a5ee9-1a04-4c64-9820-8014c0b38d61', 'zhang-yi', '{"zh-Hans": "张仪"}'::jsonb, '战国', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "出任秦国相，后奉命伐取陜地 先后相魏、相秦、相楚，并与齐楚大臣会盟于啮桑 与魏章东出至魏，后死于魏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 赵高 (zhao-gao)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('feb4aea2-e7c8-44d3-b2d2-c1f289f39192', 'zhao-gao', '{"zh-Hans": "赵高"}'::jsonb, '秦', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "杀二世皇帝，立子婴为王"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 召公奭 (zhao-gong-shi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('d5d7e8d5-3fb8-4d06-a06f-dd3a79bbcf1c', 'zhao-gong-shi', '{"zh-Hans": "召公奭"}'::jsonb, '西周', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "赞采参与祭告仪式 被封于燕"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 中康 (zhong-kang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3dad64e2-c955-4d0f-b845-cdbc21ce84df', 'zhong-kang', '{"zh-Hans": "中康"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "太康之弟，太康崩后继位为帝 夏代帝王，崩后由子帝相继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 纣 (zhou-xin)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9d46a8fd-ae53-4b95-ace4-0892e92c94ec', 'zhou-xin', '{"zh-Hans": "纣"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "蜚廉、恶来父子所事之殷王，被周武王所伐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 颛顼 (zhuan-xu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c26a5df8-35d3-4339-a520-c56f3fe26b11', 'zhuan-xu', '{"zh-Hans": "颛顼"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "秦之先祖女修的远祖"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- person_names
-- ============================================================

-- Name for bai-li-xi: 百里奚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('48975dc1-b739-46a4-b3e7-8e4a7609c7d1', '8e9ed2e2-65e5-47be-b6de-8f321275a726', '百里奚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for bai-li-xi: 百里傒
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9f4ed445-271a-4496-aa33-7b3d6111fa71', '8e9ed2e2-65e5-47be-b6de-8f321275a726', '百里傒', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for bai-qi: 白起 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2f938d1c-d424-4174-b45e-d17d9b6a984b', '7022b479-f8fa-4be2-ba14-7c396849a160', '白起', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for bai-qi: 武安君
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c46dc4dd-8142-45e2-8e22-99dbb42e794c', '7022b479-f8fa-4be2-ba14-7c396849a160', '武安君', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for bai-qi: 武安君白起
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('39884598-0e0b-416e-b1b0-8a80a1b13c3f', '7022b479-f8fa-4be2-ba14-7c396849a160', '武安君白起', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for bai-yi-bing: 白乙丙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c065f673-b408-4791-ad05-4fa4cce655f8', '27961404-6aea-4f84-aa22-e81fc25688a5', '白乙丙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for bao-si: 褒姒 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('60fc004d-d7d0-4f62-8a4c-f127dfa80aae', '599b25fb-44d7-47d9-96c0-03f5aca26d28', '褒姒', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for bi-gan: 比干 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('14e90ddd-76fa-4355-9ea4-c8cd7ea71c7b', 'c74a2aac-841b-4816-89c8-26c8063abde7', '比干', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for bi-gan: 王子比干
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5bb69d97-9a71-4f99-abf9-e47c869b1fde', 'c74a2aac-841b-4816-89c8-26c8063abde7', '王子比干', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for bo-yi: 伯夷 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('804c6960-ce2b-427e-8d2d-353e670bc7be', 'ec440301-5a6f-4d5b-86bf-1f1dabcaf5ff', '伯夷', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for bo-yi: 伯
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1f3255f0-ce6b-432e-bbd7-26d90dcdb082', 'ec440301-5a6f-4d5b-86bf-1f1dabcaf5ff', '伯', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for chang-pu: 昌仆 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7913fb27-1e7a-46e3-85e5-a21fe3697ec9', 'b1a6ecae-5d13-476f-b8e5-3541b689921b', '昌仆', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for chang-pu: 蜀山氏女
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('93763fe7-959f-42df-ac1e-e8efc98b646c', 'b1a6ecae-5d13-476f-b8e5-3541b689921b', '蜀山氏女', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for chang-xian: 常先 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6bdaefd8-c55d-4996-b1a9-32cbaeeed600', '5c131454-8f7e-4b63-8f0f-cf49c4ec6159', '常先', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for chang-yi: 昌意 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c30825fe-d7b5-40cf-86e7-e85289439ab6', '1c404625-59ff-47a9-a239-097e432ad822', '昌意', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for chi-you: 蚩尤 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d29a77b3-1c6a-4ac4-a010-b2b00b4d18e2', 'abf65a85-0faf-4ad3-a3dc-c7d04e5aceda', '蚩尤', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for chui: 倕 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c2a57fce-73a0-404e-a72c-777d533ba24e', '2595b9c9-b30f-4701-a553-a1d2a83895e4', '倕', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for chu-li-ji: 樗里疾 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('28dd09db-656d-4ff0-b2d6-99890c52f545', 'fd3cd100-04c0-47c8-8d2f-a112dd44da68', '樗里疾', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for chu-li-ji: 庶长疾
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('573b4406-3372-4241-9a3e-a36adb50e34a', 'fd3cd100-04c0-47c8-8d2f-a112dd44da68', '庶长疾', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for chu-li-ji: 摢里子
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f4059bee-4af6-4ede-9d52-0556d9690fde', 'fd3cd100-04c0-47c8-8d2f-a112dd44da68', '摢里子', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for chu-li-ji: 摢里疾
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3bc95bc8-36c4-4d66-81e8-907a91ff6fc1', 'fd3cd100-04c0-47c8-8d2f-a112dd44da68', '摢里疾', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for chu-zhuang-wang: 楚庄王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a1b1ce17-00a1-4e1c-a934-d31b33e064b8', 'b703a0a6-7a59-4c2d-917a-5e7925285a9d', '楚庄王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for da-fei: 大费 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('08ed2422-47dc-4f27-ab4a-6de62f8d0160', '3ce918d0-a9b2-4520-8342-cef32f03301a', '大费', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for da-fei: 柏翳
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d7ef26c0-8f3b-4a83-9b38-89f6163a37d9', '3ce918d0-a9b2-4520-8342-cef32f03301a', '柏翳', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for da-fei: 费
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ae6e3f82-6bf8-4729-afe0-d46bed1e77c7', '3ce918d0-a9b2-4520-8342-cef32f03301a', '费', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for da-hong: 大鸿 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f5bc7c83-5c86-4590-a654-7760c8dc2048', '1d6cd4d4-e9c8-4d14-8d48-cc4c5714e87d', '大鸿', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for da-ji: 妲己 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('472cb03a-fbbd-4af8-b73f-d57810a468ab', '309c1421-c0b5-4cb7-8d55-aaecd5a532e0', '妲己', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for dan-zhu: 丹朱 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fcf417f6-c5e4-44a1-9ab3-18051dd8724d', '46add4d2-e583-449a-8ad4-2732b43b9618', '丹朱', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for di-ku: 高辛 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7c4e6533-a55b-4dd3-8a54-b4f2553f5eb1', 'fa14f49f-8dbc-4f3f-a04c-b67df9a5b4e7', '高辛', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for di-ku: 帝喾
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('efbfcbd2-ac9d-42e9-9707-3d08081bec69', 'fa14f49f-8dbc-4f3f-a04c-b67df9a5b4e7', '帝喾', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for di-ku: 帝喾高辛者
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('351b03d7-f811-467b-b730-3972f0c6e405', 'fa14f49f-8dbc-4f3f-a04c-b67df9a5b4e7', '帝喾高辛者', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for di-ku: 高辛氏
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0c3d0e63-78a6-48c0-9131-9084513d4932', 'fa14f49f-8dbc-4f3f-a04c-b67df9a5b4e7', '高辛氏', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for fang-qi: 放齐 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('04d59dcc-f60c-4068-a040-79f8c9aebbd1', '9f8e4f38-6c25-47a6-9a2b-72fb9f068f64', '放齐', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for fei-zi: 非子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('266eb0b4-0ae4-4634-bff3-86d9b10cc8e8', '2392b897-452d-4096-889f-cf84b3f0570e', '非子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for feng-hou: 风后 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('29372dad-bb20-46b4-9496-38a6a3a2883b', '981f922d-5697-4b1b-b427-e8f66bd8de9d', '风后', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for fu-yue: 傅说
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c9739c99-978d-4fee-92e4-5f2bfb124335', '39081f94-bd83-4196-87cc-2f766cc31830', '傅说', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for fu-yue: 说
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('20801374-88d6-4611-8b09-45bdecdb1940', '39081f94-bd83-4196-87cc-2f766cc31830', '说', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for gan-mao: 甘茂 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4d24b9a1-4eee-4d2d-89c6-ee5a3ede1b23', '65e8d7d2-ef7b-4ad4-969c-1c67ff63f100', '甘茂', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for gao-yao: 皋陶 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4fa2e3f7-128c-4577-9742-1b786bbf0966', '041aef60-51bd-4509-88b2-d41969f80805', '皋陶', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for gong-gong: 共工 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1d5e3b4c-61c7-48b6-b2ce-610ecc67da78', '0fa67188-558b-4622-8d67-2205c3f6ef72', '共工', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for gou-wang: 句望 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5e9ddae1-3834-4ba4-85ea-e5fe1da0ce3f', '3f93f19e-b6c9-4d22-9a55-01c091b7f23b', '句望', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for guan-zhong: 管仲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a9564683-54c6-4d9f-91dc-f0ce5c6c388c', '01561739-d388-49b8-925b-d2f0558aff62', '管仲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for gu-gong-dan-fu: 古公亶父 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1d87ff2e-b749-4852-aae8-075c1f85fd4c', '174458b8-eb08-4bb2-bbb4-3a1a27785e86', '古公亶父', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for gu-gong-dan-fu: 古公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('43d87e9a-3a71-4888-9e50-97cb7572035f', '174458b8-eb08-4bb2-bbb4-3a1a27785e86', '古公', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for gu-gong-dan-fu: 太王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4123995e-1c07-45a0-a708-5204c8a2d3fc', '174458b8-eb08-4bb2-bbb4-3a1a27785e86', '太王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for gun: 鲧 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cd68d96c-ade0-4ea5-a413-90a675816942', '2654bbc9-aa0e-4f85-b99b-2f593d08bc84', '鲧', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for gu-sou: 瞽叟 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('efe412e5-696e-496a-90e0-951802826fe6', 'ed16177a-3f8d-49d0-89d8-aad52d591dc1', '瞽叟', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for he-shu: 和叔 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8955101d-ad9e-46f8-8e4a-41e8d6df5fc5', '62f42495-d83e-4c58-a905-e43e655c8465', '和叔', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for he-zhong: 和仲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b751353b-e5b3-471c-9d85-3c449eb295f3', '5cf16973-6ab3-4df3-a493-57a1b19f0632', '和仲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for hou-ji: 弃 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6e990b7e-8091-4dc1-9817-6d1a46f78e58', '709a5ab7-7bb3-4091-a80f-d209caaf5a48', '弃', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for hou-ji: 后稷
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cbea21d3-eddc-4bd5-a220-e0e17008e277', '709a5ab7-7bb3-4091-a80f-d209caaf5a48', '后稷', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for hou-ji: 稷
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('99b6eb2b-6cce-42f9-a626-83e800026749', '709a5ab7-7bb3-4091-a80f-d209caaf5a48', '稷', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for huang-di: 轩辕 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d3bf0088-204e-46b1-9512-b8c98e569e27', '3197e202-55e0-4eca-aa91-098d9de33bc9', '轩辕', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for huang-di: 帝鸿氏
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f7d20e48-2170-48be-be1d-9962033ae781', '3197e202-55e0-4eca-aa91-098d9de33bc9', '帝鸿氏', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for huang-di: 黄帝
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6869aa73-ed9b-4448-b128-0d7b580f0567', '3197e202-55e0-4eca-aa91-098d9de33bc9', '黄帝', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for huang-di: 黄帝之后
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b4ea09b1-ab94-4695-96b4-777dba4ee60e', '3197e202-55e0-4eca-aa91-098d9de33bc9', '黄帝之后', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for jian-di: 简狄 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9b862096-124c-4efd-bfd2-e6787be848a5', '340d8d24-c305-4f0e-b517-3f8460dc0b28', '简狄', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for jian-shu: 蹇叔 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7fd065da-18cc-4528-9a49-b93c57ae3153', 'a1548cd0-a3da-491b-8f7f-4c1376ce627c', '蹇叔', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for jiao-ji: 蟜极 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b99a0a8a-32e1-4d61-9a2a-b1a6c432870a', '6dc49a58-ae29-4938-92bf-15cc8fb705a2', '蟜极', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for jie: 帝履癸 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('efc1973d-8ecd-4a0c-82b0-b1ae19b80ca8', '48cdbfcf-f96b-4623-b5b4-1de19f342fd5', '帝履癸', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for jie: 夏桀
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d83c9869-14ba-460c-81d2-33c1fa31d0e0', '48cdbfcf-f96b-4623-b5b4-1de19f342fd5', '夏桀', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for jie: 夏王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7d3ec13d-ad25-4e3b-b9d2-42e85b78ccb4', '48cdbfcf-f96b-4623-b5b4-1de19f342fd5', '夏王', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for jie: 帝桀
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2e806db0-3e91-4d7e-90d9-a20225ff0110', '48cdbfcf-f96b-4623-b5b4-1de19f342fd5', '帝桀', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for jie: 桀
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('122360d4-926b-4315-8b96-c3d8ebfc2d67', '48cdbfcf-f96b-4623-b5b4-1de19f342fd5', '桀', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for ji-li: 季历 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8cbdac52-4af9-4923-991a-228b99e8736d', 'c8862c58-9eb8-49f4-9792-86ab89eaaadd', '季历', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for ji-li: 公季
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('88f941b2-8cb1-471a-a2f3-df8c6be2febc', 'c8862c58-9eb8-49f4-9792-86ab89eaaadd', '公季', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for jing-kang: 敬康 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1695d959-109f-4f79-8fd3-1e0403722c2a', '1a2a3fba-061f-4bf4-adba-4bd3eb16a861', '敬康', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for jin-wen-gong: 晋文公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('047dcd29-154f-469d-bfde-93ef6e5811cb', '022b3f84-4289-475f-a809-c94b892e8be9', '晋文公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

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

-- Name for lv-bu-wei: 吕不韦 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('37e17077-2a61-4c95-9a1a-3f613211962e', 'ffce9f7e-478b-4fe6-917e-db45b42d09f1', '吕不韦', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for meng-ao: 蒙骜 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ae57b56c-43d2-46e5-bd6d-4f8b848fa27c', 'bc7d2658-9fdd-4d3e-8a87-5e6f42c7f9b8', '蒙骜', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for meng-ming-shi: 孟明视 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8c845280-6125-41a7-9428-bd016a9df473', 'd0ac7c81-d528-469f-9d6b-af4ccda31a2e', '孟明视', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for pan-geng: 盘庚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1a7a603c-3ea7-4a3f-a0ea-17e33177f7a0', 'd01e3221-22c5-40fb-a74a-a38d0ffc69c9', '盘庚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for pan-geng: 帝盘庚
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('11f8273c-18a4-40ef-b1b4-ea045f2de3f9', 'd01e3221-22c5-40fb-a74a-a38d0ffc69c9', '帝盘庚', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for peng-zu: 彭祖 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('09c63058-9440-4b5a-9a7e-0f031af905f5', 'cdae4ce6-714d-4ffc-8c53-2823ca74af69', '彭祖', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for qi: 启 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7e422109-22ff-400e-99f6-5e6c5c4acf86', 'aaa3998f-cad8-4054-9ae4-6d9f5dc40486', '启', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for qi: 夏后帝启
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cc942392-c46f-406f-830d-fb55ad3b6c02', 'aaa3998f-cad8-4054-9ae4-6d9f5dc40486', '夏后帝启', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for qi: 禹子启
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9672c7b9-2483-48f0-a583-251d7c17cbfe', 'aaa3998f-cad8-4054-9ae4-6d9f5dc40486', '禹子启', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for qiao-niu: 桥牛 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c90aed71-71a7-4c80-a661-84d118f9915d', 'e330634f-161c-4084-902c-a6e1e1a9b33a', '桥牛', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for qi-huan-gong: 齐桓公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('835831a3-ed33-4623-a370-1b19ae10572a', '1e74495b-7648-4afb-8779-47fe67a52e6c', '齐桓公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for qin-hui-wen-wang: 秦惠文王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1e344990-fded-40d5-a53d-3d87165d5a91', 'bb59e4cd-6486-4358-87d2-2df4e3b1ba11', '秦惠文王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for qin-hui-wen-wang: 太子
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0b286a22-ecd9-40d2-a871-7db06cb961a6', 'bb59e4cd-6486-4358-87d2-2df4e3b1ba11', '太子', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for qin-hui-wen-wang: 惠文君
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b720c263-be61-4fed-8f4c-232aebdfb764', 'bb59e4cd-6486-4358-87d2-2df4e3b1ba11', '惠文君', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for qin-mu-gong: 秦穆公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8970bdd5-3ae4-413e-87b7-4276b27e7275', '144a7a2c-4330-480c-a2cb-4cf09245de8f', '秦穆公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for qin-mu-gong: 任好
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d8e5fe09-d80c-4c1a-9c4b-fa50c0104943', '144a7a2c-4330-480c-a2cb-4cf09245de8f', '任好', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for qin-mu-gong: 孤
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('76de7673-0a9b-43b4-a626-d0c06025e977', '144a7a2c-4330-480c-a2cb-4cf09245de8f', '孤', NULL, 'self_ref', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for qin-mu-gong: 寡人
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cfc8a3ef-a548-4519-9d77-a08d9418cfbb', '144a7a2c-4330-480c-a2cb-4cf09245de8f', '寡人', NULL, 'self_ref', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for qin-mu-gong: 秦缪公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a6f2ee64-2248-4ea7-b011-6202028b65bb', '144a7a2c-4330-480c-a2cb-4cf09245de8f', '秦缪公', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for qin-mu-gong: 穆公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('421d3f50-4619-45c6-8264-529649e26f1c', '144a7a2c-4330-480c-a2cb-4cf09245de8f', '穆公', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for qin-mu-gong: 缪公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('bf039794-d429-4ae9-9037-0954e699db57', '144a7a2c-4330-480c-a2cb-4cf09245de8f', '缪公', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for qin-xiao-gong: 秦孝公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8298dfdc-421e-4d1b-86c1-e98467aaf253', '9c1c50e3-6c4f-4963-960a-89d90a70ca67', '秦孝公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for qin-xiao-gong: 孝公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1456e1ac-ebc3-41e0-a1ca-3bf40b3c0553', '9c1c50e3-6c4f-4963-960a-89d90a70ca67', '孝公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for qin-zhao-xiang-wang: 秦昭襄王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('21d745c6-8e59-4315-adca-31d816e662b7', 'cfefc568-fe69-4625-9629-84fbf0cd7807', '秦昭襄王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for qin-zhao-xiang-wang: 昭襄王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5706df4e-1375-464a-a21e-37e1ed542315', 'cfefc568-fe69-4625-9629-84fbf0cd7807', '昭襄王', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for qin-zhong: 秦仲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2cc206aa-cd47-4654-8bfd-b0c75b399a4f', '514927c6-2c90-43d2-b7fb-7aa9fb69df2f', '秦仲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for qin-zhuang-gong: 秦庄公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c8a0c2fb-35ed-4b34-b834-5dc9d6aa6fd3', '82cca4dd-aa67-4760-9087-2e6de8a43722', '秦庄公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for qin-zhuang-gong: 庄公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8f87c5ce-d3c3-4ad2-bc41-79d4ba6ea6a8', '82cca4dd-aa67-4760-9087-2e6de8a43722', '庄公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for qiong-chan: 穷蝉 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ff07d0d0-1163-492d-b8da-ec407f0aa3a4', '2b170470-d8a2-4ebd-a166-cdbd5b913003', '穷蝉', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for shang-jun: 商均 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('15a669cb-fcad-4f84-bd3b-aa0260d687af', '34b568ad-7280-41fa-bd84-83a4d25f29f1', '商均', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shang-jun: 舜之子商均
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('245030c6-69ce-4a42-8b23-fd4856b94c7a', '34b568ad-7280-41fa-bd84-83a4d25f29f1', '舜之子商均', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for shang-yang: 商鞅 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c612b70a-1d7a-4fce-ab47-83f4c8f0c51d', '957e9a25-30f6-4fd6-a163-785231f1a3ed', '商鞅', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shang-yang: 卫鞅
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3504f32e-48b3-4698-a706-3f4b2c3ce3e2', '957e9a25-30f6-4fd6-a163-785231f1a3ed', '卫鞅', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shang-yang: 商君
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1f62651e-c1c4-48f9-b196-a8701565f274', '957e9a25-30f6-4fd6-a163-785231f1a3ed', '商君', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shang-yang: 鞅
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0e5b5b3c-823c-433c-9310-9ec4ef1f451b', '957e9a25-30f6-4fd6-a163-785231f1a3ed', '鞅', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for shao-dian: 少典 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('95b3c475-a7de-4f40-9f6f-df68a3089306', 'c9177893-35ad-48f5-887b-c48d38d6031d', '少典', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for shao-kang: 少康 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b2798bf3-a7a0-4798-8451-8638d19a2631', '26d68429-421d-4695-99b7-995150cb77aa', '少康', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shao-kang: 帝少康
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6c546983-b5dd-46f8-874c-30f0ac5672ef', '26d68429-421d-4695-99b7-995150cb77aa', '帝少康', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for shen-nong-shi: 神农之后
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('863194d1-1083-4ade-99a8-c546ae120d96', '5187db9f-1864-49f0-97d2-d6cc60b5fd2a', '神农之后', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shen-nong-shi: 神农氏
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c71bc8c0-fea1-44dc-a51a-5f2a340135c0', '5187db9f-1864-49f0-97d2-d6cc60b5fd2a', '神农氏', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for shun: 舜 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e262b667-d462-47c4-9a79-714d2c6e199d', 'f1a7e4d2-41fa-400c-881b-dfb4919e8200', '舜', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shun: 帝舜
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6ecff6c9-c5be-4020-a5a2-106acb2b0cfd', 'f1a7e4d2-41fa-400c-881b-dfb4919e8200', '帝舜', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shun: 帝舜之后
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('86dad5e3-6232-4dff-b232-75b7c6f2aea1', 'f1a7e4d2-41fa-400c-881b-dfb4919e8200', '帝舜之后', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shun: 有虞
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1e6ceb56-e78d-42e3-a8bf-484bd975c780', 'f1a7e4d2-41fa-400c-881b-dfb4919e8200', '有虞', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shun: 虞帝
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('368c1362-4a97-49a2-9e07-754ce657c4b0', 'f1a7e4d2-41fa-400c-881b-dfb4919e8200', '虞帝', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shun: 虞舜
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('596185ac-4124-42b3-8883-a8cb7d435812', 'f1a7e4d2-41fa-400c-881b-dfb4919e8200', '虞舜', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for shun: 重华
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c5f9cb6f-1f17-4791-abc8-1fd03f6a38e8', 'f1a7e4d2-41fa-400c-881b-dfb4919e8200', '重华', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for shu-qi: 叔齐 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1655cc48-32fa-4245-ae80-4207d2c750d6', '2d90798a-563c-4b13-8826-48fb6e2c7640', '叔齐', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for tai-bo: 太伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('798be51e-9955-45ad-84c8-bb8389fe9888', 'da24cfb1-a188-4b56-a441-2a481f1f242d', '太伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

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
-- Name for tang: 成汤
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d051ee9c-d797-4465-beab-466cbadd390f', '578b71f6-e9aa-4fc3-b8c8-1a7c20a3c910', '成汤', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for tang: 武王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8b383dc2-6bb4-46cb-9cfc-f36d196e1aa1', '578b71f6-e9aa-4fc3-b8c8-1a7c20a3c910', '武王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e09-u7236: 三父 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4935f772-0fbf-46f1-9c2f-8a9fb33d2dae', '8dd91bc0-0e5d-4356-ad8d-2beaf284fb1d', '三父', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e0d-u7a8b: 不窋 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b39ac261-c28a-484e-9973-43dd0736030c', '0bc8f019-378d-40ac-9ed5-6da0cb57d253', '不窋', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e15-u8c79: 丕豹 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8649338e-5a19-47f8-bb66-630021b1108a', '76fc0ab6-c337-4edc-934d-ce98a0ae8b3a', '丕豹', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u4e15-u8c79: 豹
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('793704b9-3864-482a-ad27-71814edfbe0b', '76fc0ab6-c337-4edc-934d-ce98a0ae8b3a', '豹', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e15-u90d1: 丕郑 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8f320c2d-91e5-4219-895c-1ad861ecd1a5', 'ba7cb650-3ab7-46e6-82ed-111bf01a7358', '丕郑', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e16-u7236: 世父 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('53a89f41-6541-4ee4-87b6-a3566d2f3dfa', '9587f2ca-6131-42fa-b8ca-62a834f5ee07', '世父', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e1c-u5468-u541b: 东周君 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7683b7c3-2c98-4441-8e30-3061ed5b3c7d', '68a7a5a1-fef9-4804-9886-aea64d28ce86', '东周君', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u4e1c-u5468-u541b: 周君
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e6a79d4b-d470-4478-ab27-21e52e91d14b', '68a7a5a1-fef9-4804-9886-aea64d28ce86', '周君', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e1c-u5468-u60e0-u516c: 东周惠公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6ffc889c-fc93-47a7-a4d5-c0282dd2ef10', '417e76b8-64e2-4837-8013-ca95b75d6830', '东周惠公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e25-u541b-u75be: 严君疾 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0d132ad8-ad16-4e51-8e76-4f37372385b4', 'ac9cec6f-aac4-4c4b-889e-99a6bcc400b0', '严君疾', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e2d-u4e01: 中丁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f191b098-a02b-48ad-802c-04393ba52c08', 'b7f3b550-95c1-4dd0-aba7-a2ba1634bed2', '中丁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e2d-u58ec: 中壬 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('96e0896b-0144-4221-95bf-32c3370a2c41', '6fc7f1f3-ad30-4f50-b54d-50442be3adde', '中壬', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u4e2d-u58ec: 帝中壬
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b5f1b58f-26ab-4858-8524-88d5ea74605f', '6fc7f1f3-ad30-4f50-b54d-50442be3adde', '帝中壬', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e2d-u6f4f: 中潏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c0fe4aa8-f667-4ff4-86cb-e84f207d0ebb', '0f0e6db9-45eb-4a11-8908-02a384ff2fe2', '中潏', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e2d-u884c-u6c0f: 中行氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4be63f5d-d049-4776-b32d-6ac4a88be193', 'f3eb6cc1-0fec-4503-bde3-a735327b05e7', '中行氏', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u4e2d-u884c-u6c0f: 中行
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3ec95042-e90d-4fdc-aa02-68b9019f3fee', 'f3eb6cc1-0fec-4503-bde3-a735327b05e7', '中行', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e30-u738b: 丰王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('83305ec5-3473-40a0-8275-87c7645bc44f', '4111e1d2-435b-4183-82d1-f60b051f7dfa', '丰王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e3b-u58ec: 主壬 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('837d08c4-c4d8-4ffe-aecc-c00b53565085', '7e488b33-62f5-4969-b453-3987fc1634f5', '主壬', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e3b-u7678: 主癸 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1c6f45c3-f79e-46c0-a9b8-19051be49770', 'a8279874-a200-49a7-8e4e-c468219ef32d', '主癸', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e49-u4f2f: 义伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8fd0f8e5-2858-4c3b-8013-c7d715f81f3c', '1e584772-09ba-4d15-bdff-dfb5c4ad34b2', '义伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e49-u6e20-u541b: 义渠君 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('99e63a4a-af97-416d-8423-02f3871fc061', '736154aa-3211-4acd-86b9-c5f9c3d490e5', '义渠君', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e4c-u83b7: 乌获 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e1c73840-f9d1-46d8-b8ea-aa7f69dc9f35', 'b3a9ad73-fbe1-4805-95dc-3c6d4a1e9810', '乌获', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e50-u6c60: 乐池 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('14ba5066-3b82-4283-8c67-5673c4ea98a6', '13845cb3-85a5-440e-94c9-f223c07ed0b6', '乐池', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e5d-u4faf: 九侯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('182b4454-83cc-4f2b-a8cc-4d07996a4330', '8f82fd72-bf8c-4c9a-b920-1e2c721a531c', '九侯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e5d-u4faf-u5973: 九侯女 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e545297d-f4aa-4fec-9c14-9e90933051bf', '48abfa8c-6e65-4508-b86c-363ba3794621', '九侯女', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4e9a-u5709: 亚圉 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('dbbca1bb-da52-4767-a6b7-7f4b3396e074', '426bc5b9-b846-4c99-a82a-3dc4d5ad9d93', '亚圉', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4eb3-u738b: 亳王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('89ca9b6f-1069-42dd-b21f-2d979facd3a1', '006756ba-3604-4aa1-a170-cf522a2f83f7', '亳王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4ef2-u4f2f: 仲伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('afacb9ef-8b7b-49dc-981b-8e742290de70', '20850745-a1af-49d1-bb0f-7bec11e0a342', '仲伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4ef2-u5c71-u752b: 仲山甫 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('968f61ff-8af5-42e2-8393-ce99ce0b4c57', 'd3a7a7ff-1263-40d6-95ce-f1b219281ae6', '仲山甫', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4ef2-u884c: 仲行 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c439c7ba-33b8-46d7-b6ff-0665d3dda9f3', '26b4a7ff-5b99-4343-8457-5341cf8eac48', '仲行', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4efb-u9119: 任鄙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b98982d2-50f4-434b-86f2-e98316eab1b0', '53d5b17f-98d9-4f3c-9d2c-18a4f892f92a', '任鄙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4f0a-u965f: 伊陟 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d2accf8b-b568-4c73-86e5-f7c21818ac46', '1ed80e86-c057-4d2b-977f-1f499c6ad2e4', '伊陟', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4f0d-u5b50-u80e5: 伍子胥 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b5d15124-9077-4745-846c-5bf486eed941', '53907bb5-fa99-467d-8cda-d813d57bbe3a', '伍子胥', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4f2f-u4e0e: 伯与 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('efc354f4-d3f2-4f63-973d-81f24c4e532b', '88b58309-e730-4e12-9be8-06646b876308', '伯与', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4f2f-u58eb: 伯士 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('88cb3897-84ed-4e2a-b552-be4645d0bf77', 'b88b8afc-3dbf-4e2c-8194-6d9fc7af458c', '伯士', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4f2f-u670d: 伯服 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('24de633c-9bf6-471e-bd19-7587afc351e6', '601401f6-cb13-429f-b74d-cef7132bd45d', '伯服', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4f2f-u7ff3: 伯翳 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('32c555aa-358e-4e3d-b2d5-70e4b1201be0', 'ab395f42-126a-4409-85e2-0867e02fe9d3', '伯翳', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4f2f-u81e9: 伯臩 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0acfa76d-fbe2-44a9-b933-b81f5932d537', '04315466-58af-4a52-89dd-fa0d6af076e6', '伯臩', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4f2f-u9633: 伯阳 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f35d6632-2dee-4569-8823-06231e5f5288', '13b74d99-7f3d-4603-a048-91c1f2ea97aa', '伯阳', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u4f2f-u9633: 周太史伯阳
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d2aa1914-392d-4b95-8789-391404eef1cf', '13b74d99-7f3d-4603-a048-91c1f2ea97aa', '周太史伯阳', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u4f2f-u9633: 太史伯阳
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2bc2e4a8-4c60-4782-a214-ecfefadc0e92', '13b74d99-7f3d-4603-a048-91c1f2ea97aa', '太史伯阳', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4f2f-u9633-u752b: 伯阳甫 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('535744e9-3e82-4a1b-a1d5-d498bea3734c', 'f1f1d224-c8d2-4383-aac9-4b5f305ccbfb', '伯阳甫', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u510b: 儋 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('22a20f83-ae50-4d6a-aa39-53805eb2358d', 'fbd9f46f-c652-4d14-ac8a-54fdf45e5b08', '儋', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u510b: 周太史儋
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8aade4aa-d816-48d1-b892-a0ad31ddc727', 'fbd9f46f-c652-4d14-ac8a-54fdf45e5b08', '周太史儋', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u516c-u4f2f: 公伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b95268ad-477d-43e8-a2eb-8c59f32f7813', 'f60fa67d-3037-4e31-92fa-bbf0ce6d7afd', '公伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u516c-u5218: 公刘 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('24ff4688-6ed2-42e4-b870-6214be90f569', 'c5a918e2-2022-440f-bdeb-4293c7995dcc', '公刘', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u516c-u53d4-u7956-u7c7b: 公叔祖类 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fdd10d9a-9027-4124-a52b-afc7136cdbc4', '9da3b0c4-8d15-4100-b553-0eb99a81f9f8', '公叔祖类', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u516c-u5b50-u536c: 公子卬 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7aec0de9-74d9-4e51-a4f0-4930f794786d', 'b9d51ed8-a76a-471e-a2cb-4fd1e66791a2', '公子卬', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u516c-u5b50-u536c: 魏公子卬
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b629e2f3-26b4-4bbf-96d1-4f6736dc9d9f', 'b9d51ed8-a76a-471e-a2cb-4fd1e66791a2', '魏公子卬', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u516c-u5b50-u548e: 公子咎 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5b34d406-f563-4503-b546-20512a177a41', '25dab0d1-1165-45ca-840d-a36acee38c44', '公子咎', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u516c-u5b50-u5c11-u5b98: 公子少官 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('acbe547c-9e7c-4141-81a3-75b497757279', 'bc2a7260-4511-445e-8709-4003b1a67580', '公子少官', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u516c-u5b50-u5e02: 公子市 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3db93a80-4e16-48c5-8728-5ca39c9a037c', 'c9f93c52-3dfc-42c9-9885-6451b018e7b9', '公子市', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u516c-u5b50-u609d: 公子悝 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1d753b48-0be3-4ed4-8bf5-894cba6ad7d8', '10024d6d-229b-41e1-aeba-6ca23e751c15', '公子悝', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u516c-u5b50-u609d: 叶阳君悝
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('97c9993a-9e50-4676-875d-deb8174f43ab', '10024d6d-229b-41e1-aeba-6ca23e751c15', '叶阳君悝', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u516c-u5b50-u7fec: 公子翬 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8ce607c4-1b03-4964-88f7-89ff198b7b6d', '9b600e45-5a57-483d-82b2-9fe778383381', '公子翬', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u516c-u5b50-u7fec: 鲁公子翬
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('054eb900-928a-43d9-abe1-fa1d4eff5a5a', '9b600e45-5a57-483d-82b2-9fe778383381', '鲁公子翬', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u516c-u5b50-u901a: 公子通 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8cb597df-7f32-4093-b932-cd8a76bd4476', '04866e08-57ce-4459-a2a8-8522f03fe014', '公子通', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u516c-u5b59-u559c: 公孙喜 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('80335b97-d332-4a82-b322-e7779357cc30', 'cdf5ec1d-75c6-454b-bdc0-6d7164af0fd0', '公孙喜', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u516c-u5b59-u652f: 公孙支 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d68a472e-1d62-45f5-8924-f775286d8fa3', '1158ad02-67b3-4f55-884e-b09bd5a6922a', '公孙支', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u516c-u5b59-u652f: 支
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e8ed1182-b7ad-463a-9ffc-3ce087b648c2', '1158ad02-67b3-4f55-884e-b09bd5a6922a', '支', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u516c-u5b59-u65e0-u77e5: 公孙无知 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fed6aa72-6ff3-4c3a-85ff-9046b1dda9d9', '442189d8-779f-4c24-af5b-e7490fc4ebcc', '公孙无知', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u516c-u5b59-u65e0-u77e5: 无知
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4c54ed97-51c2-46cd-b7db-7180e138b125', '442189d8-779f-4c24-af5b-e7490fc4ebcc', '无知', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u516c-u5b59-u75e4: 公孙痤 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('26dbb216-f78e-4888-bf6e-6cdb717c20ad', '922fdc1a-2eba-4a74-b53c-d0fdaa01cc6e', '公孙痤', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u516c-u975e: 公非 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2e67f406-8801-4c44-a217-e7fc81bcbdad', 'babb1c2f-7688-490a-8390-956c07ed74cc', '公非', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5171-u516c: 共公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('07966745-5394-4f0e-a185-6d4661fb29d9', '2b8b4d73-d627-4e1c-b888-4ae8acf2dc10', '共公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5171-u738b: 共王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d595355f-ea0e-4438-9680-d3300272a7f1', '80d1a3a7-ae26-4fd7-8e96-d008ec33fb76', '共王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5171-u738b: 繄扈
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('20046aca-9b16-45e4-8e63-ade2e084db28', '80d1a3a7-ae26-4fd7-8e96-d008ec33fb76', '繄扈', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u517b-u7531-u57fa: 养由基 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('866834b9-c9cb-4394-8406-994985b21b33', '91ec3bfa-e886-4fa8-ab70-7f6b6c5dc7a6', '养由基', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5185-u53f2-u5ed6: 内史廖 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2f5d98d2-ce47-4309-8aaf-0ed2e6157f88', '778831d0-6caa-4837-b4dc-04304cd50b27', '内史廖', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u51a5: 冥 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a579184b-a36e-436b-90e2-7195d6fd889b', '5990ba1c-5b30-4c41-a759-349afbbe343a', '冥', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u51fa-u5b50: 出子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b033fe8d-20c8-46cd-8cea-986e181e0ba4', 'f0e68dde-3ef7-4af8-a815-89fbd42ae3b8', '出子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5353-u5b50: 卓子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e71ef721-38a4-460c-bebc-d5509f82b0af', '4809e1f5-6271-4e4e-b62a-ba659d4f265d', '卓子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5357-u516c-u63ed: 南公揭 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('eccab0bf-696c-4f42-9e14-d92c92c9f0bb', '320e99e7-f0d5-4a5d-8d5a-2827457a252d', '南公揭', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5357-u5bab-u62ec: 南宫括 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2d223197-d8d2-4fa0-b0fe-4042f0e69807', '4807c065-52c2-4206-8008-177b28e45f8b', '南宫括', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5357-u5e9a: 南庚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('809cc4ff-d709-41f3-bfa5-680a4d34d0d2', '89961cef-fb71-4cf0-906d-8e062272b716', '南庚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5357-u5e9a: 帝南庚
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('454107e1-bfd0-4400-af6c-18422507396c', '89961cef-fb71-4cf0-906d-8e062272b716', '帝南庚', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u536b-u5eb7-u53d4: 卫康叔
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('25a4e8ee-0188-4765-a208-9e105f34d405', 'df3b0ed4-a1b3-4258-8ca0-7699fefcde4c', '卫康叔', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u536b-u5eb7-u53d4: 封
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1944087c-3200-4edf-aa2c-9a7ca5161103', 'df3b0ed4-a1b3-4258-8ca0-7699fefcde4c', '封', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u536b-u5eb7-u53d4-u5c01: 卫康叔封 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5db3022e-6ba2-44fc-be97-e5db2f4080a5', 'f400d227-9909-407b-a2fc-945aec96b334', '卫康叔封', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5389-u5171-u516c: 厉共公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1a0d4dc2-dd6e-47b9-816a-68d6a977ff5c', '8301e32d-186d-4f57-9729-4d9cc57dede9', '厉共公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5389-u738b: 厉王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4abaa964-5116-4434-921c-25fb349f38d0', 'a3f85a2d-d93b-498a-9142-9852970fb289', '厉王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5389-u738b: 胡
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e0366b03-3bbf-4ca2-8c1a-c2f710ef40a5', 'a3f85a2d-d93b-498a-9142-9852970fb289', '胡', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5398-u738b: 厘王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f97a6e0f-c7ca-4739-bbda-a5fa5bc2bab5', '93598628-fd40-44d5-81fd-337c0d696117', '厘王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5398-u738b: 胡齐
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('403b629d-6c20-4e05-ab11-19d1edcaf807', '93598628-fd40-44d5-81fd-337c0d696117', '胡齐', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u53bb-u75be: 去疾 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('eeb16351-4c25-4f9c-99e0-d7324cfe3259', '74c589ed-6ffe-4741-9997-bc471a29d4aa', '去疾', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u53bb-u75be: 哀王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('de85a508-e72e-4d9c-9139-d8810c5a2f31', '74c589ed-6ffe-4741-9997-bc471a29d4aa', '哀王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u53d4: 叔 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ab33d43e-f435-48e7-9bc8-bd55fc67eb61', '37d94958-4a57-4437-a2e7-be1a9a692c17', '叔', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u53d4: 思王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0669db51-df51-4559-a694-fab2508b241e', '37d94958-4a57-4437-a2e7-be1a9a692c17', '思王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u53d4-u632f-u94ce: 叔振铎 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3730a7f9-93fe-49c1-8ecf-f1e88153765b', '66a1c45b-23d6-4808-8fc8-1da956e17a04', '叔振铎', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u53ec-u516c: 召公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('382b1cf9-45ac-4e36-b5db-ffff25733ec0', 'b93e26ca-a089-4cdf-82c7-b22057884c37', '召公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u53ec-u516c-u8fc7: 召公过 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c5012cc9-1f92-46b1-9fa4-9a012a40cd5b', '210ffdf6-3651-49a6-8998-50a0740826e3', '召公过', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u53f2-u4f5a: 史佚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7e3e2b4c-5755-4b81-b247-58d2d41a427b', 'abe3c70f-0d13-4d1f-b780-f6e6edb8f839', '史佚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u53f2-u538c: 史厌 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0c61ef00-28f2-4440-af34-c2952f2dbb64', '1f4e0897-9e8f-44cc-92f4-b6d837e6860c', '史厌', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u53f8-u9a6c-u6897: 司马梗 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1dba1366-0cb4-4b11-9078-d8b952d53067', '3852a84b-cae1-43bc-abc4-a3f5f3952dd7', '司马梗', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u53f8-u9a6c-u7fe6: 司马翦 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2719899d-a603-42d4-829b-f624e91f5456', '8eb6c44a-c80c-4a57-bcb2-c848c4e0a085', '司马翦', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u53f8-u9a6c-u7fe6: 翦
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7d16284d-c4ab-456d-9292-90da2c24e17b', '8eb6c44a-c80c-4a57-bcb2-c848c4e0a085', '翦', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u53f8-u9a6c-u8fc1: 司马迁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('20069722-92f6-4a89-983c-663d668c19cf', '7128aa48-c9a1-43a1-a338-383370cd01c2', '司马迁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u53f8-u9a6c-u8fc1: 太史公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5fc91b9e-4bf3-46d8-8822-e205f7ee15d0', '7128aa48-c9a1-43a1-a338-383370cd01c2', '太史公', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u53f8-u9a6c-u9519: 司马错 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('52a6bfb8-9d0e-4db0-bf9b-1c83f5ddbdcc', 'a8aa410d-21b3-42bd-9a18-49aeaae4c241', '司马错', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u540e-u5b50-u9488: 后子针 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8d224ff8-cecd-417e-850a-d8fb7ac1a4f3', '0efd69d5-121c-49d4-b023-ec72b4f1ddff', '后子针', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u540e-u5b50-u9488: 后子
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8d70f77e-1784-48e6-8006-8e03bece8ade', '0efd69d5-121c-49d4-b023-ec72b4f1ddff', '后子', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5411-u5bff: 向寿 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('dc460f21-ca3d-42fa-912e-7b2299874f64', '4c929cf7-e9fb-42cc-a7f0-24537f8eafdf', '向寿', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5415-u7525: 吕甥 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cb61e2bc-4a6a-4cee-bd59-6d5c5cb6601f', '3bdc6a18-465a-45e1-a108-f21cc3e7d8fa', '吕甥', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5415-u7525: 吕
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6af28609-4d97-4ac5-bc8c-568f3dfd9e33', '3bdc6a18-465a-45e1-a108-f21cc3e7d8fa', '吕', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5415-u793c: 吕礼 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c698be92-f5a6-4869-afb2-441140d511ce', '419f6945-c8b9-472a-8b3a-c798aed141aa', '吕礼', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5434-u738b-u9616-u95fe: 吴王阖闾 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8102719a-b3ec-4ae5-8512-2c00d57588f0', 'd6e71c63-5fd0-45e5-b43d-e8eab96dde20', '吴王阖闾', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u5143-u738b: 周元王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('66c9bdf4-791a-4910-b238-a3f2344b53f9', '075a775f-c44f-4b9a-847a-6e48fb731a1a', '周元王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5143-u738b: 仁
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('688027bc-65ab-4dce-a422-083bda7978d4', '075a775f-c44f-4b9a-847a-6e48fb731a1a', '仁', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5143-u738b: 元王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('75ff6c0c-bd91-4d27-8ccf-2c43cae735fd', '075a775f-c44f-4b9a-847a-6e48fb731a1a', '元王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u516c: 周公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0d34210b-117e-444d-a23f-06815803f4f3', 'be21116e-6b67-4df9-b3e6-3edab8c7eca6', '周公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u516c: 周文公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0957e6a1-da33-4f8e-b9e1-eca24ac8717f', 'be21116e-6b67-4df9-b3e6-3edab8c7eca6', '周文公', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u516c-u65e6: 周公旦 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ba846cab-3b47-4a24-83b5-1fa36d404b87', '18513390-791f-44c5-8261-634fa9a62ba8', '周公旦', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u516c-u9ed1-u80a9: 周公黑肩 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5d0da258-814f-4c45-823e-359eb2e0cc23', '10aa9fd0-5e57-4e5b-b5b5-cdc228dcfd3f', '周公黑肩', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u5321-u738b: 周匡王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6b87bed8-6ce0-44cc-a6c4-7e972738a1dd', '931a167e-1367-4e21-be8f-cd3af627ae36', '周匡王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5321-u738b: 匡王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('35d0859b-2c7e-4006-80b2-7e944bdb24d6', '931a167e-1367-4e21-be8f-cd3af627ae36', '匡王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5321-u738b: 班
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2a6f11a0-6def-4efc-bc9f-26786905390f', '931a167e-1367-4e21-be8f-cd3af627ae36', '班', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u5389-u738b: 周厉王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3aaf2667-4d22-4ced-9d09-cf1ba70c5319', '1f6831b1-1c73-409d-8f0c-1322d4395569', '周厉王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u5929-u5b50: 周天子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3a912605-2d35-45cb-8952-055c6e24d63a', 'a10b59c2-3c97-40ae-a798-62c91c870a66', '周天子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u5b5d-u738b: 周孝王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('712b9fff-8f3b-4f27-92f4-e27e2b1f21a2', 'be0ef800-e0de-4c62-98f9-1293131a818d', '周孝王', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5b5d-u738b: 孝王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d2386e14-13de-4a4d-8b79-33eedba23b06', 'be0ef800-e0de-4c62-98f9-1293131a818d', '孝王', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u5b9a-u738b: 周定王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('dad26000-db7f-4c40-8a3a-2b895e3c4522', 'e9dd5635-452d-4661-a7b3-67668e4f6f5a', '周定王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5b9a-u738b: 介
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('73f062ec-3de3-408d-bdba-cfbc5a5b21a5', 'e9dd5635-452d-4661-a7b3-67668e4f6f5a', '介', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5b9a-u738b: 定王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3c0f1b1a-e2af-412b-aa6b-31ae8b37e905', 'e9dd5635-452d-4661-a7b3-67668e4f6f5a', '定王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5b9a-u738b: 瑜
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('30e56926-1401-4c8e-abf2-1faa1fc1cd07', 'e9dd5635-452d-4661-a7b3-67668e4f6f5a', '瑜', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u5ba3-u738b: 周宣王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('97d48548-e7d2-4cfb-b12e-c21315bbca72', '2f7a3782-f560-4af5-be5c-0047f71506cb', '周宣王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5ba3-u738b: 厉王太子静
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c93f678a-e05e-42ed-b81f-b3a57359e9c1', '2f7a3782-f560-4af5-be5c-0047f71506cb', '厉王太子静', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5ba3-u738b: 太子静
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a77ba8d2-7259-4192-8f88-309d5694cad7', '2f7a3782-f560-4af5-be5c-0047f71506cb', '太子静', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5ba3-u738b: 宣王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3989375f-e916-4ed6-95ec-32369e9a491b', '2f7a3782-f560-4af5-be5c-0047f71506cb', '宣王', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5ba3-u738b: 王太子
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d84c8d49-f1ce-4a2f-8421-66627877d23d', '2f7a3782-f560-4af5-be5c-0047f71506cb', '王太子', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u5e73-u738b: 周平王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0671cc2c-8e53-476a-a7d1-ec95c665df48', '95764d6b-d7fc-475f-b939-afdfcddc826a', '周平王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5e73-u738b: 宜臼
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3106d243-0f27-47e7-b63f-5d342355eec1', '95764d6b-d7fc-475f-b939-afdfcddc826a', '宜臼', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5e73-u738b: 平
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('28133baf-009a-4a44-be97-8c8d26dfed10', '95764d6b-d7fc-475f-b939-afdfcddc826a', '平', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5e73-u738b: 平王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('41da945f-d152-4165-842e-194cd320bdf8', '95764d6b-d7fc-475f-b939-afdfcddc826a', '平王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u5e7d-u738b: 周幽王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('29841e1e-03f3-4baa-a2bd-9455b9a8b5e6', 'c54236c3-108b-484c-a31e-34967cbcb0bf', '周幽王', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5e7d-u738b: 幽王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('25b19a5d-eee4-462b-96c2-345be8a020e9', 'c54236c3-108b-484c-a31e-34967cbcb0bf', '幽王', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u5e84-u738b: 周庄王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f0b1b696-d789-4c88-89eb-8760955787a8', 'b63a5ca9-4ac4-4120-9f28-1b0310347745', '周庄王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5e84-u738b: 庄
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c65ed469-e6af-43a4-9c02-df18de043bd8', 'b63a5ca9-4ac4-4120-9f28-1b0310347745', '庄', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u5eb7-u738b: 周康王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f16ae42b-c92c-487e-bc01-300e179eafdc', 'c940e469-3d24-4ba0-b68e-97e68693ce9a', '周康王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u5eb7-u738b: 康
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c1571b85-d5f6-4fa2-80be-62f1b87331ed', 'c940e469-3d24-4ba0-b68e-97e68693ce9a', '康', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u60bc-u738b: 周悼王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('bcd77f61-7c41-4abb-8542-02c558b30a8b', '2d788ceb-e577-479d-8f02-0dc45ca87507', '周悼王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u60bc-u738b: 悼王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7a792f72-2d59-4313-be28-6f75f46f8896', '2d788ceb-e577-479d-8f02-0dc45ca87507', '悼王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u60bc-u738b: 猛
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c122550c-fd24-4dc4-b055-ddf4d44c3549', '2d788ceb-e577-479d-8f02-0dc45ca87507', '猛', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u60e0-u738b: 周惠王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('69ee4bcd-6580-4d5d-afd7-ae35179fd8fe', '6608abd7-5a51-4f3c-9d78-61e710257fbc', '周惠王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u60e0-u738b: 惠
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d58d46de-58ad-4d54-a4f0-7495ffa95a6f', '6608abd7-5a51-4f3c-9d78-61e710257fbc', '惠', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u6210-u738b: 周成王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('680c2bb8-e1ee-47ae-877b-f4569d5be85a', '4f53bf47-41ac-44dc-b0e5-517afd4f6d2b', '周成王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u6210-u738b: 成
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('22edaae2-49e3-4ad0-a93d-9d3c492ed145', '4f53bf47-41ac-44dc-b0e5-517afd4f6d2b', '成', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u6210-u738b: 成王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f7c738b3-cb2d-4f74-80a9-3ac4f2519a3d', '4f53bf47-41ac-44dc-b0e5-517afd4f6d2b', '成王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u656c-u738b: 周敬王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('52f3ff39-ceaf-4a41-85e9-d23842223db1', '7d77c554-a099-4715-8735-58aa042326b5', '周敬王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u656c-u738b: 丐
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d889fea5-981d-44f4-927b-9a987532747e', '7d77c554-a099-4715-8735-58aa042326b5', '丐', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u656c-u738b: 敬王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d56be06a-7fdb-43b4-9c05-0dc6d0dc3260', '7d77c554-a099-4715-8735-58aa042326b5', '敬王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u666f-u738b: 周景王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5bef003f-a485-49bc-a057-2e96c59c9a16', '7d5df00d-600e-4bca-8ded-2c5b6be279b0', '周景王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u666f-u738b: 景王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('09a540ee-7b67-4462-95c8-af46a202804b', '7d5df00d-600e-4bca-8ded-2c5b6be279b0', '景王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u666f-u738b: 贵
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f5987744-5a1a-49a0-a20a-171fb313d923', '7d5df00d-600e-4bca-8ded-2c5b6be279b0', '贵', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u6853-u738b: 周桓王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('27e5405c-4673-47a5-abf8-dbc5078e67bc', 'ccebe8f3-2d91-4e4b-9778-1ec692b95edf', '周桓王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u6853-u738b: 桓
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('36ff48cc-54a7-49c2-816a-9080c0229bba', 'ccebe8f3-2d91-4e4b-9778-1ec692b95edf', '桓', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u6853-u738b: 桓王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8188994f-a263-4edc-8923-807832ad1e5b', 'ccebe8f3-2d91-4e4b-9778-1ec692b95edf', '桓王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u6b66-u738b: 发 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0cc08865-1007-42f8-ad7f-3436d979c174', 'e87fbc15-0b9d-4916-9d23-919ca3bdada7', '发', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u6b66-u738b: 周武王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('442736cf-3988-4dac-a80e-04912eb526f8', 'e87fbc15-0b9d-4916-9d23-919ca3bdada7', '周武王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u6b66-u738b: 武
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a93dc069-c313-46d9-a640-84130bd533f8', 'e87fbc15-0b9d-4916-9d23-919ca3bdada7', '武', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u6b66-u738b: 武王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5c612e4f-9f0c-44b4-b534-3a872ab900c7', 'e87fbc15-0b9d-4916-9d23-919ca3bdada7', '武王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u76f8-u56fd: 周相国 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('298b862c-1d97-482e-a791-d08383296b46', 'e65483a9-32a2-4f53-a7a9-c7395f29b67b', '周相国', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u76f8-u56fd: 相国
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('83f0653a-26fd-4766-9c78-f74ad7a398d6', 'e65483a9-32a2-4f53-a7a9-c7395f29b67b', '相国', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u7a46-u738b: 周穆王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b4b02cf6-b2d6-4cba-96f2-756bb70bc8d2', 'ee05a798-3884-4c0e-b48a-12ae0010fb90', '周穆王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u7a46-u738b: 周缪王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d6cfe6e9-9985-4c95-8e08-d37be37c26d4', 'ee05a798-3884-4c0e-b48a-12ae0010fb90', '周缪王', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u7a46-u738b: 缪王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('969ab540-1005-49cc-9ae1-745e61777caa', 'ee05a798-3884-4c0e-b48a-12ae0010fb90', '缪王', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u7b80-u738b: 周简王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3e8152a9-d449-4152-a07e-1dd71bc7c52c', '96d7192d-ef9f-41a1-989c-623044058ee6', '周简王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u7b80-u738b: 夷
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6e8446d4-5e34-477f-a07f-9fa3649f55f7', '96d7192d-ef9f-41a1-989c-623044058ee6', '夷', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u7b80-u738b: 简王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f0533b38-c211-4e06-9ad8-afe6aab20a6b', '96d7192d-ef9f-41a1-989c-623044058ee6', '简王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u805a: 周聚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1d659f3e-ecc5-438c-aa6c-07999cb72dfc', '9d558416-3c7c-405d-b286-67db50820392', '周聚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u805a: 周（最）
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d6ca8fe1-4fc4-4a8d-88c7-3837a1d16906', '9d558416-3c7c-405d-b286-67db50820392', '周（最）', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u8944-u738b: 周襄王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8aa55ff0-4c66-418f-8702-9a4ebc89d964', '704b3c67-4bb0-4cca-8240-de9a2ead1e24', '周襄王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5468-u9877-u738b: 周顷王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('29621650-8ae0-42bf-a083-5fbd40db4de8', '82088dd0-3092-44ff-84e8-87c2942e3104', '周顷王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u9877-u738b: 壬臣
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('57920b3f-d72f-44e1-8f1f-e03b2f9d892b', '82088dd0-3092-44ff-84e8-87c2942e3104', '壬臣', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5468-u9877-u738b: 顷王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cb9435d2-3896-4ceb-bbce-1be589389174', '82088dd0-3092-44ff-84e8-87c2942e3104', '顷王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u548e-u5355: 咎单 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4c566ed6-494c-4ed9-a977-7889fb33c34a', '085afa0a-27c9-4034-87e9-434343bad7f3', '咎单', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5510-u592a-u540e: 唐太后 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9281d62a-d1a7-4c53-b914-6715ee34f137', 'e0bca3e2-9292-4f67-9ad5-df97cc844eae', '唐太后', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5510-u592a-u540e: 唐八子
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ada0da8d-610a-43a5-ba6e-2462a523540b', 'e0bca3e2-9292-4f67-9ad5-df97cc844eae', '唐八子', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5510-u771b: 唐眛 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5dc1cf80-cd21-4ca0-a214-bfc622e22caf', 'a55c44d5-91c2-4340-8df8-42aa9b7482c6', '唐眛', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5546-u5bb9: 商容 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3704aadc-65bf-497e-bf84-89f4eff36c6d', '2fad187e-d800-4681-9475-610725fa502e', '商容', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5609: 嘉 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1171b8dc-2fb6-450b-a8b1-94e68ea24254', '8873cecc-3c8f-4330-95c9-6f9c46421964', '嘉', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u57ce-u9633-u541b: 城阳君 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6e8d912a-8b9b-46d6-8fbd-00f5767c9ea1', '256875c4-2476-46c7-8fe2-aa8163e969a9', '城阳君', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5916-u4e19: 外丙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f4622b83-d977-4d2c-8102-ad4e61545147', 'bbfb70fe-0e15-4509-8c47-0ddf373fd9bf', '外丙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5916-u4e19: 帝外丙
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ccb26bb2-b4bd-4ba7-9b63-324a7417aa1a', 'bbfb70fe-0e15-4509-8c47-0ddf373fd9bf', '帝外丙', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5927-u4e1a: 大业 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5f3afa95-02b7-426d-92e0-a31dd7ae75f0', 'e828d7ac-f59e-436e-a5e8-aa43ed765f34', '大业', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5927-u6bd5: 大毕 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('90e491f0-2b6f-41fa-bde4-cfe69288dba7', '7d64a92a-1659-4ecf-b3cf-a41d42f9288a', '大毕', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5927-u9a86: 大骆 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('dbc11587-cc51-46d8-9198-cfa1370da1ca', 'b4915d4d-a374-4ff6-bceb-6494b346b4f7', '大骆', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u592a-u4e01: 太丁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('efe05834-7ae3-42bb-9d3f-2e3ee3004da6', '4fe29020-b3da-41aa-8812-c045474e34b5', '太丁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u592a-u4e01: 帝太丁
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('155088b5-0db3-4d56-abb3-a233140c9bba', '4fe29020-b3da-41aa-8812-c045474e34b5', '帝太丁', NULL, 'temple', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u592a-u4efb: 太任 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3c28288b-39ec-4780-8c00-c6f3b95a89ed', '41394482-c6b9-47e7-87d4-eeed3ea334ba', '太任', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u592a-u51e0: 太几 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('342d67bd-217a-49b5-bbb6-af5e780fca26', 'b603f18a-174c-46d3-84f3-01625fea9cc5', '太几', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u592a-u53f2-u510b: 太史儋 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e4d73e91-fd2a-45b4-8732-c02d8fc975dd', 'd3cb56c4-7ae9-484e-8a03-0b0ad2a83384', '太史儋', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u592a-u53f2-u510b: 儋
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0c7c6c20-fe6e-44b0-a81a-81e1ac1de5a8', 'd3cb56c4-7ae9-484e-8a03-0b0ad2a83384', '儋', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u592a-u53f2-u510b: 周太史儋
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8be6b84c-1134-4a24-8fc0-40bb77e0b53e', 'd3cb56c4-7ae9-484e-8a03-0b0ad2a83384', '周太史儋', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u592a-u53f2-u516c: 太史公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('473e677a-9661-4518-8100-6544bbc7f2ca', 'e9542991-4023-4a9d-82da-212749f8fc4e', '太史公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u592a-u59dc: 太姜 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1e82b7b4-bb75-4c55-954d-d5047d11f7b5', 'ec8a326b-a4e9-4d64-9118-32b861113b18', '太姜', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u592a-u5b50-u5709: 圉
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b9472378-06fa-4ec3-ac98-d5bd5c6e069e', '76591c5f-395c-4b8e-a94a-dab9aac644bc', '圉', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u592a-u5b50-u5709: 太子圉
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e5890f7d-4e93-4ad6-b0f1-b99dafde3168', '76591c5f-395c-4b8e-a94a-dab9aac644bc', '太子圉', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u592a-u5b50-u5709: 子圉
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('218a05fd-5fcf-4ecc-8aad-6c74561b78fa', '76591c5f-395c-4b8e-a94a-dab9aac644bc', '子圉', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u592a-u5b50-u5efa: 太子建 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1c12683c-f2e0-47a0-b4e2-6c8d1d2b3f60', 'a1608524-96aa-4b19-b28c-d67c7ba5aea2', '太子建', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u592a-u5b50-u5efa: 建
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('34448db6-59da-45e8-bccf-74c3bc5410d9', 'a1608524-96aa-4b19-b28c-d67c7ba5aea2', '建', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

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

-- Name for u592a-u98a0: 太颠 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6a131f36-6fe5-48e3-9dcd-ffb5e32109f8', 'c227043f-8ca0-43bb-9cbf-b818c03c6348', '太颠', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u592b-u5dee: 夫差 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6f9ef87c-6eef-4acb-a077-1cbfd03e44ad', '6e90a2ec-bb36-420b-b0bb-f9356b2abb56', '夫差', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u592b-u5dee: 吴王夫差
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('84483dc0-13e6-40b7-a4a3-580d8b211521', '6e90a2ec-bb36-420b-b0bb-f9356b2abb56', '吴王夫差', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5937-u543e: 夷吾 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cb920590-acd0-4be5-9f07-a2dea67bd6cf', 'c04e0814-6557-40af-b35d-5fec14bd80bb', '夷吾', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5937-u738b: 夷王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('78bbd351-ddc8-436a-8982-e48c6a0e654c', '7a572542-02d9-435d-a6c5-3bf8a378aeaf', '夷王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5937-u738b: 燮
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6c1110c3-63c3-4b0b-9b78-092522f7335a', '7a572542-02d9-435d-a6c5-3bf8a378aeaf', '燮', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5944-u606f: 奄息 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('712229ee-a811-463a-b3ec-fa25929dc46b', '1f524e25-a029-4379-b82d-c7cceaff3c9d', '奄息', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u595a-u9f50: 奚齐 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6166a4f5-e730-48e9-be03-e36e55c3f90c', '39f06e0e-bf12-4002-9810-1e0e1f7cfcde', '奚齐', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5973-u4fee: 女修 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2ec09c50-82b2-4ae8-8586-c76b22d4ab2f', '7cbe5667-441a-485c-9ff3-01376d2772ca', '女修', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5973-u534e: 女华 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0e89ba54-bea9-4df3-89ab-91d9106c2dfe', 'e8ca4a3f-2b03-4265-abe4-cf5199ee9f51', '女华', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5973-u623f: 女房 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9f44438b-f923-49f0-9e38-736b881e9a28', 'a2e28a22-9375-4e29-a295-969035563da3', '女房', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5973-u9632: 女防 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7fb8bd77-dae4-48a8-8f63-f823fcfbf501', '82dc3e8d-5d67-468d-85dd-44b575291565', '女防', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5973-u9e20: 女鸠 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('71f5fcec-793b-4563-845b-30bb629e8cc7', 'eca161d1-ebc5-484e-b5c3-6b3a3e43375c', '女鸠', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u59da: 姚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5d7fc5df-74b8-43c9-a6ad-c98895a7821c', '38dd7ce0-c96f-4b92-9fa8-b9cc2536d92a', '姚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u59da: 姬姚
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('248a83be-9f72-4c8c-838b-ff478339e3cb', '38dd7ce0-c96f-4b92-9fa8-b9cc2536d92a', '姬姚', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u59dc-u539f: 姜原 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9bfb6df6-9a01-4ef7-b40e-3ce0a0c86d17', 'b29ae21b-f95d-4176-86cd-29d5f8880b06', '姜原', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u59dc-u5c1a: 姜尚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3420bb2e-09cd-4822-9742-64f49ae50b18', 'aa831571-ec89-4f9d-8568-87ab12965e91', '姜尚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u59dc-u5c1a: 太公望
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7596b7bd-3c67-4d21-98d5-1b57ee619dbe', 'aa831571-ec89-4f9d-8568-87ab12965e91', '太公望', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u59dc-u5c1a: 尚父
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d610a8f6-e642-416d-9ce2-afc967e15117', 'aa831571-ec89-4f9d-8568-87ab12965e91', '尚父', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u59dc-u5c1a: 师尚父
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('317ffded-86ff-4ae9-9333-02fa3b13e108', 'aa831571-ec89-4f9d-8568-87ab12965e91', '师尚父', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5a01-u516c: 威公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ab8d2bd8-8468-4b41-968a-ecbf03b577cc', '1de71063-d8fe-4bcb-8644-9b48d9ef836c', '威公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5a01-u5792: 威垒 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('800c13f8-0431-43b8-b0f1-0420329d5a2e', '236684bd-1c94-49e2-9802-7ed523a82215', '威垒', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5a01-u70c8-u738b: 午
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8d886bdc-ae56-4bb3-a028-d7eaa2c06c49', '9a536139-f9bc-40db-941d-51c91a0aebab', '午', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5a01-u70c8-u738b: 威烈王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b9de3fd3-a36d-40f8-8dc9-c4067f6b155c', '9a536139-f9bc-40db-941d-51c91a0aebab', '威烈王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5a01-u70c8-u738b: 威烈王午
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e63e15a2-ea5b-4b21-af1a-89eef4b5c1cf', '9a536139-f9bc-40db-941d-51c91a0aebab', '威烈王午', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b34-u653f: 嬴政 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('41245072-f02f-4dd5-b075-f7494bb2e2c3', '2a63d8aa-8e38-421a-bf06-e827efb0c684', '嬴政', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5b34-u653f: 始皇帝
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f40d19c4-2533-4e2f-90f4-5ec88a3ce5bb', '2a63d8aa-8e38-421a-bf06-e827efb0c684', '始皇帝', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5b34-u653f: 秦王政
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d415f97a-c11f-492a-b867-a626c1d0759e', '2a63d8aa-8e38-421a-bf06-e827efb0c684', '秦王政', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b50-u4e4b: 子之 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('56705626-915c-4d5b-8131-0b40c24d990f', '557e7bfe-57c7-4114-b550-c8fb4f580b62', '子之', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b50-u5709: 子圉 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('29f414d8-8d51-4b8e-b4fc-c27c54d92d6c', '4bdd2dd1-8e72-4f5a-915a-565367700490', '子圉', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5b50-u5709: 怀公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8ae0bc83-091b-4968-807a-3aaf7dcbbff0', '4bdd2dd1-8e72-4f5a-915a-565367700490', '怀公', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5b50-u5709: 晋公子圉
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('06705e19-5d0b-49f8-8eef-cc3944e1e42a', '4bdd2dd1-8e72-4f5a-915a-565367700490', '晋公子圉', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b50-u5a74: 子婴 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b49a7e06-cd78-4201-ace2-dd2fc2c54e5a', '6ea97184-d5d2-4b81-9fef-efa447e2e651', '子婴', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b50-u9893: 子颓 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('25608e85-1964-47b9-9d2f-c70ac7b8b895', 'd17c5cec-e575-4440-a8c2-517faeed9290', '子颓', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b54-u5b50: 孔子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8c3e118d-4975-4d84-b619-7895dd9895ff', 'a387e3b7-5ae1-4869-84ef-6d4f6cb61947', '孔子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b5d-u6587-u738b: 孝文王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('933c3e61-9d19-44f6-92f3-f69fcef9360d', 'ae68feda-5705-4b96-a571-b71c96f95060', '孝文王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b5d-u738b: 孝王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d3500bd0-0b6f-4eb1-869c-49d5995623fa', '4ffdaa98-c914-417c-92f7-82c10338455e', '孝王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5b5d-u738b: 辟方
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d78160e1-82d5-4527-8299-e23a9a81b1d0', '4ffdaa98-c914-417c-92f7-82c10338455e', '辟方', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b5f-u589e: 孟增 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('548eae22-1f52-4fce-b6da-86b3a84cc75e', 'e22fe542-8833-43a8-ade0-0e13287c4eff', '孟增', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5b5f-u589e: 宅皋狼
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a560b995-6b4d-4fd6-a1d3-1cbaa5945338', 'e22fe542-8833-43a8-ade0-0e13287c4eff', '宅皋狼', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b5f-u5c1d-u541b: 孟尝君 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('846b06fc-7e1d-4cbb-93da-e3cb626599ee', '548ca8aa-2517-4ef4-b29b-42463dde864e', '孟尝君', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5b5f-u5c1d-u541b: 孟尝君薛文
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('86aafdb0-1963-4a4c-86e2-e2ac44d2425a', '548ca8aa-2517-4ef4-b29b-42463dde864e', '孟尝君薛文', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5b5f-u5c1d-u541b: 薛文
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f8a307b1-844d-47ca-89a1-431aff2f0415', '548ca8aa-2517-4ef4-b29b-42463dde864e', '薛文', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b5f-u660e: 孟明 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e76d2b74-b465-4dd9-bbdf-38cadb73726c', '9dde5128-320a-4a33-8a05-744caab71b66', '孟明', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b5f-u8bf4: 孟说 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5a08dc31-da0c-4ec1-a66e-bf245c186c0e', '29fcfe8c-e404-4c5c-8f9d-f4d4dc4d391e', '孟说', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b63-u80dc: 季胜 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5f8c1f7d-170a-4df7-9ba8-0a7471a62765', 'e17c1086-2a2e-4d17-b551-6e5196f0de68', '季胜', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b7a-u5b50: 孺子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ad97e239-b0d6-406f-9e60-0d5d09a12b15', '6d762926-7af9-4e3a-b116-0ee934450127', '孺子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b81-u516c: 宁公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('60d505b2-1268-45a5-9ace-f2bacc07f158', '30e9e183-8181-41b3-be5e-780f7c00ddcc', '宁公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b89-u56fd-u541b: 安国君 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5ccc9cc2-7bc4-4b7b-aba3-5641a2af8c3b', 'ee06485e-929e-4ec6-805a-e13156a453ba', '安国君', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b89-u738b: 安王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c29db36b-045c-4e91-935d-8033f9ff9b83', 'fb71f9fd-03aa-4785-b2c4-a984187edb60', '安王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5b89-u738b: 安王骄
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6d3b0b44-e47a-4dbf-bc8e-6e696a70e3fc', 'fb71f9fd-03aa-4785-b2c4-a984187edb60', '安王骄', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5b89-u738b: 骄
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('34b866fc-1899-4cdc-913c-bb28022cd350', 'fb71f9fd-03aa-4785-b2c4-a984187edb60', '骄', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b8b-u738b: 宋王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('affb7102-363b-4c0b-810a-e537d588580f', '6983f8d6-e43e-4609-bb61-1de487812b05', '宋王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5ba2-u537f-u7076: 客卿灶 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c5181a9c-22d2-4399-8b58-a02040527fae', 'c7e47add-a629-49fe-97a1-6dcb407a54b1', '客卿灶', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5ba3-u516c: 宣公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('90deb33e-6441-4d50-8c4f-e21ea744af5b', '4d22b414-afd8-4773-9e50-8fdd5b26623e', '宣公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5ba3-u592a-u540e: 宣太后 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('02f24a4e-b771-4dd9-a654-985bf1a101b8', 'ca450aa0-2745-478a-aa71-b6f6f84a1830', '宣太后', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5ba3-u592a-u540e: 昭襄母
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e5962e19-acbc-4b7b-a611-f5bafc026c8f', 'ca450aa0-2745-478a-aa71-b6f6f84a1830', '昭襄母', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5ba3-u592a-u540e: 芈氏
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('44e6990b-8930-46c8-bb40-b7b11c25961f', 'ca450aa0-2745-478a-aa71-b6f6f84a1830', '芈氏', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5bb0-u4e88: 宰予 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0e24f4e8-851d-4611-8261-9cc4ad490c5e', 'b8ce9615-c7fc-45c9-b5fc-269100b37710', '宰予', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5bc6-u5eb7-u516c: 密康公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f5dea057-6519-432b-b22d-57deee2655a6', 'a43a483a-7af9-447c-b98e-40b3bd425403', '密康公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5bc6-u5eb7-u516c: 康公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('321185be-1695-48d1-a250-2997eadcfc70', 'a43a483a-7af9-447c-b98e-40b3bd425403', '康公', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5bc6-u5eb7-u516c-u4e4b-u6bcd: 密康公之母 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b4a4388b-abd7-4626-bfdd-d45fbcd72ccb', '050d8ebf-86e7-4ccb-8028-284a8d41ba5b', '密康公之母', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5bc6-u5eb7-u516c-u4e4b-u6bcd: 其母
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8f55b34e-9cab-47ec-bdea-d2e49ad2e81e', '050d8ebf-86e7-4ccb-8028-284a8d41ba5b', '其母', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5bcc-u8fb0: 富辰 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2397248a-9227-484b-9fe3-a8a78a5bfe66', '1217c9e0-a951-4d71-91bc-41c0d8891438', '富辰', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5c09-u65af-u79bb: 尉斯离 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7a05c964-81fb-41c5-b72a-16f6f77cc786', 'bd0ae58a-be25-4643-9e9f-2d8fbb9c8906', '尉斯离', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

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

-- Name for u5c11-u66a4-u6c0f: 少暤氏
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('626f7492-26cc-4246-9c49-50e36aa7f721', '2e9ab3c3-7bc7-48e3-a700-47b237c5eb37', '少暤氏', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5c39-u4f5a: 尹佚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('81aae57b-fdb8-40dd-a38a-e5caee1251a5', '9ce6d4e4-5f2b-45d2-830a-ad96b81775b8', '尹佚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5c48-u4e10: 屈丐 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('499c1b77-b3fe-4603-b253-8aab64e1b42f', '2a5ca791-8cbf-49cd-81f8-cf70826f4182', '屈丐', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5d07-u4faf-u864e: 崇侯虎 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7cfc0f93-3cfc-48cc-8413-cc06c9a07264', 'a54abbd1-05b1-4ab7-b2ce-b8519fcd1078', '崇侯虎', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5d14-u677c: 崔杼 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9c0dd961-60bd-4295-8759-99768a81f0f3', '75b2076f-ec26-4df9-9707-b33ae9f4105e', '崔杼', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5d6c: 嵬 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9df1235e-571e-4db2-a72e-cf125d1c1983', '44a70bc3-9cc8-4440-a8ad-695423fa705a', '嵬', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5d6c: 考王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('eab01609-2dc1-4727-8f5c-e0c81c145ea3', '44a70bc3-9cc8-4440-a8ad-695423fa705a', '考王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5de6-u6210: 左成 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a7fea3ae-6e68-4887-a5e4-1eaa45637e9a', '10d167de-87a9-49e9-84b9-db6760b9d6f8', '左成', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5deb-u54b8: 巫咸 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d6a881a1-be55-47b8-9f43-47f90acdb3dc', '62092322-6254-48e2-9467-9e65a5e41d87', '巫咸', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5deb-u8d24: 巫贤 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('beee826c-674e-40cd-b373-c233af41ffde', '314c2e92-b8be-444a-8cad-34e2627c091d', '巫贤', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5dee-u5f17: 差弗 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c6eb6cb8-c9ab-4ffe-b795-cf9b278a8192', '1e8fe82f-14b1-4cd6-854b-f803db3f021c', '差弗', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e08-u6b66: 师武 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('82e6868a-0ad5-4915-a98e-3be7b4a83933', '98b4db47-2118-46be-b077-3cd44b067219', '师武', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e08-u6d93: 师涓 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8d792615-d812-473e-b00c-2e588c60345f', '6ac54d78-abbd-4e78-b417-06fe22811f8b', '师涓', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u4e0d-u964d: 帝不降 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('85c608d5-0199-422e-b600-dd94629a8b46', '0e30735f-6d22-4574-9920-171bce1eae14', '帝不降', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u4e59: 帝乙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a71b2738-2196-4af3-8787-2ffa77f6f10b', 'cb277c3d-41ea-40ec-961f-8713034371d9', '帝乙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u4e88: 帝予 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8efb2d59-83a1-4876-82eb-8cf4330183e1', '2c0c3aa9-3803-4e09-a7cd-be98306e5d34', '帝予', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u53d1: 帝发 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('97cbb36e-1ce8-41ab-96bd-34b15394df06', '9d04cdda-0f60-4073-ae80-44b6311c49b8', '帝发', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u5916-u58ec: 外壬 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d04358fa-41db-4d50-a9e5-33d97a169d77', '7a29a307-6bb1-4c04-b2be-34ce1d10f6b1', '外壬', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5e1d-u5916-u58ec: 帝外壬
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a828d66d-fc82-4984-9735-e5beec9bfa89', '7a29a307-6bb1-4c04-b2be-34ce1d10f6b1', '帝外壬', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u5e9a-u4e01: 庚丁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('bc1fe57e-464e-491f-9b17-83666faf0b7b', 'b1b69239-f9f4-4d3c-af0a-d8ecd54ffcb3', '庚丁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5e1d-u5e9a-u4e01: 帝庚丁
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('54aa8a38-72af-4ea7-bdb0-4a286378f8da', 'b1b69239-f9f4-4d3c-af0a-d8ecd54ffcb3', '帝庚丁', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u5ed1: 帝廑 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('45ffc3dd-7703-4715-bb77-588d2e59ded4', 'b1a062a0-1dc2-42f7-b8e9-c67496f6bac2', '帝廑', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u5eea-u8f9b: 帝廪辛 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('080f4ba4-27f0-45fd-9294-8b8cd6891f16', 'f9e7ee84-007f-434e-95e3-bcc94184211e', '帝廪辛', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u6243: 帝扃 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1025ae21-2252-4a40-a756-82d1a5b41b26', '31c34676-b8ea-492f-a8ce-7650e8363e5e', '帝扃', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u631a: 挚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('02987f1e-ed2c-48dc-a68d-5b3c8d4ca485', 'a8d7695f-c9a6-42a6-a01f-527daeb3f191', '挚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5e1d-u631a: 帝挚
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('503c6f30-828e-4739-9d90-a7988849c08f', 'a8d7695f-c9a6-42a6-a01f-527daeb3f191', '帝挚', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u69d0: 帝槐 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7c09cd7d-46a6-49ec-95fa-109339f9dad1', 'd2a6fcfa-ce08-4400-9797-6f10a99e4963', '帝槐', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u6cc4: 帝泄 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0a7cfed8-a023-45b4-9fa5-c76194d41c97', '2cca90ac-fc2b-470d-857d-1e61641276ac', '帝泄', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u768b: 帝皋 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('693ee940-75ac-4846-966f-1cdd96a8cd81', '5d148846-8cd5-40fc-b831-f100d2255387', '帝皋', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u76f8: 相 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('364e8621-9599-4223-b806-464a68b511c7', '408b9a55-0afd-4c91-8d31-4e85b2727319', '相', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5e1d-u76f8: 帝相
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8b8e67b2-5ffc-4459-b5df-a8fe6aa807f9', '408b9a55-0afd-4c91-8d31-4e85b2727319', '帝相', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u8292: 帝芒 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9d427169-1455-45a7-bf2f-889659c0cd6d', 'bebe0656-0ad7-4347-b43b-41dec4d02be8', '帝芒', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e84-u516c: 庄公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('419d1fa9-68de-4042-b7b7-10aa23459c17', '32a7c8ef-3f53-4eb2-9f60-402752301815', '庄公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e84-u738b: 佗
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ab9ebfac-2edc-412f-822f-77e1f658ea98', '2fbbe30a-6a5a-44f6-b3f4-35b2ef532e97', '佗', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5e84-u738b: 庄王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e6651bf0-e472-4df4-adc2-d078a6b205b2', '2fbbe30a-6a5a-44f6-b3f4-35b2ef532e97', '庄王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e84-u8944-u738b: 庄襄王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('01cc61f7-1129-4209-80d9-61262b661915', '2cbfdc8d-9444-4fae-9c14-28139a7710bc', '庄襄王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e86-u5c01: 庆封 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a65c0753-5769-461c-b26a-8a151d238892', '0b398bdf-700a-4e8e-a410-0e4246337262', '庆封', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5e86-u5c01: 齐庆封
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9a68e59f-9156-4ff1-bfa0-345a175d329d', '0b398bdf-700a-4e8e-a410-0e4246337262', '齐庆封', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e86-u8282: 庆节 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('bc788914-5592-4a54-bc89-2bb20f427f80', '413d2238-8ce7-44da-b5d1-525049d9a577', '庆节', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5eb6-u957f-u58ee: 庶长壮 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c296818b-33bc-416b-8332-9656e30e8922', '3123214a-26df-409c-8703-c969ab15744d', '庶长壮', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5eb6-u957f-u5942: 庶长奂 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('71e8648c-0ddc-4092-8c32-9c053a272449', '5103c43d-61a3-4b33-b48a-1f2cbfe4a184', '庶长奂', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5eb6-u957f-u5942: 奂
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('05da0a25-b894-4f0a-91c2-1105c3b5afe2', '5103c43d-61a3-4b33-b48a-1f2cbfe4a184', '奂', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5eb6-u957f-u5c01: 庶长封 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b96aaf0f-0a19-4f60-958c-7d9bfbd60e92', '1730a107-15b9-48bc-a273-0af1e03df83c', '庶长封', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5eb6-u957f-u6539: 庶长改 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('463cb874-b475-4d30-8450-4e6ee606a2e4', '8ed08360-c748-43b3-85ed-87effe97dc62', '庶长改', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5eb6-u957f-u671d: 庶长朝 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5cf586c1-bf66-4ab9-a35b-43e4f105b004', 'cdedb68a-4751-440d-9678-fb26559ec444', '庶长朝', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5eb6-u957f-u7ae0: 庶长章 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3f367913-61d9-4ea6-8f3e-513bb457326b', 'eb903e93-8909-4165-9945-9cef4089c138', '庶长章', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5eb7-u738b: 康王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('060c0f02-4929-40f9-83a6-cc5631672076', '18cece48-6285-46b3-864b-3a8f9d5fb00b', '康王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5eb7-u738b: 太子钊
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('340bd493-9b31-46bd-924a-a107e4cf6ae7', '18cece48-6285-46b3-864b-3a8f9d5fb00b', '太子钊', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5f17-u5fcc: 弗忌 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d8b930f2-016a-4b64-b7ba-1c5188cb4eaf', '003998a4-bbf5-40a1-9abb-4ad0e21fe16f', '弗忌', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5f20-u5510: 张唐 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('bcdd898b-173e-4db2-9969-fa7b014fa8cc', '620ef450-d006-48e0-bd8a-1700dad51a12', '张唐', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5f20-u5510: 唐
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('749881e5-ecca-4e7e-bcd9-e68671fbac23', '620ef450-d006-48e0-bd8a-1700dad51a12', '唐', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5f20-u5510: 将军张唐
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ef94eb7f-fe47-4352-a852-9459cbca8f5f', '620ef450-d006-48e0-bd8a-1700dad51a12', '将军张唐', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5f26-u9ad8: 弦高 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('bb767a6e-93ac-411f-a115-b201360315c3', '3e33d037-3828-47c9-8726-22875fba9936', '弦高', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5f3a: 强 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('66112104-4f0e-4514-9ac1-5170c606b89f', '8922b82b-3dad-4efa-87a1-fd465a984e52', '强', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5f3a: 少师强
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7e849eb2-48a9-4207-a292-9a398dede724', '8922b82b-3dad-4efa-87a1-fd465a984e52', '少师强', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5f90-u5043-u738b: 徐偃王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e229ca5c-1e02-4850-806a-a8aa0618a895', 'fd1c2c35-d6a8-4e2c-ad47-e066320b436f', '徐偃王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5fae: 微 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('11fe4c8e-aa00-486d-b310-267593f04c50', '436bf856-818a-43fb-b567-4dbafa582cf6', '微', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5fae-u5b50-u5f00: 微子开 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a5adfd78-1da8-44c2-a0b3-7d0c58854501', 'd641964e-5b22-4335-87b2-b008a355e2b9', '微子开', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5fb7-u516c: 德公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('10dd1369-2e17-482c-bf2e-261e7d6a22c8', 'cc9aede7-93dc-48a5-a369-65abe1c90f85', '德公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6000-u516c: 怀公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6d9b978b-f984-45db-975c-0113df2ff263', 'd9d68f23-566e-47ab-a3ae-82b4985d60e8', '怀公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6076-u6765: 恶来 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('69157e6c-95cf-47dc-882e-1805f8c0f9a8', 'cf3bad71-102d-4ce9-8c00-35d2dc1af0d7', '恶来', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6076-u6765: 恶来革
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3987f87b-1122-47a6-a0c3-722de83df529', 'cf3bad71-102d-4ce9-8c00-35d2dc1af0d7', '恶来革', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u60bc-u516c: 悼公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e14c488a-f88b-4183-a02a-f82f7cf65e1d', '3903656e-c034-4e92-966d-e9bba54f3d18', '悼公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u60bc-u592a-u5b50: 悼太子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f0a24072-6427-4ba7-8af8-6c513763a2a2', '0b8405bf-ef2d-4f5f-87f0-306c0060b0ef', '悼太子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u60bc-u6b66-u738b-u540e: 悼武王后 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3633302c-874b-4c2a-b97f-0e1544f366bb', '5292fa37-9391-48a7-a7b0-7da87bceea95', '悼武王后', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u60e0-u516c: 惠公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7fa00dbc-7cf0-43c6-a0b7-e39b61ce7beb', 'f42c18dd-2d16-4206-98cb-082f104d416c', '惠公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u60e0-u540e: 惠后 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a092cf49-6d8d-48f8-8280-a817f1d08a3a', 'b054c171-d9f5-41b4-b72f-fbab37f7f9d2', '惠后', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u60e0-u6587-u540e: 惠文后 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c44c582e-0f1b-4740-a3e5-62676b2bda6e', 'e90c71ae-e36e-4f44-b621-948b39bbe830', '惠文后', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u60e0-u738b: 惠王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3b8ec9fe-5d54-49be-a1e3-7a7915682dc8', '1f9cf15d-ccf7-4097-8cf1-11fb3446e660', '惠王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u60e0-u738b: 阆
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fed3cbe0-e45e-43cb-ad6e-52cbab5eb845', '1f9cf15d-ccf7-4097-8cf1-11fb3446e660', '阆', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u614e-u9753-u738b: 定
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cb4571ce-15cf-41f3-b8b9-792d0e97d072', '91593f9f-b141-4663-8ec4-ad304e835f30', '定', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u614e-u9753-u738b: 慎靓王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ea1fa78b-526e-4407-a9d8-e64e48c70c1f', '91593f9f-b141-4663-8ec4-ad304e835f30', '慎靓王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u61ff-u738b: 懿王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('852b3c6f-fe68-4328-8c85-d721f8b64be8', '1bdc5c56-4d22-488f-8d6e-ae2fd5993ffc', '懿王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u61ff-u738b: 艰
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c5ce36a8-943c-445e-b09b-9266fc7bb496', '1bdc5c56-4d22-488f-8d6e-ae2fd5993ffc', '艰', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u620e-u738b: 戎王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f29efb4d-e139-4c16-b175-bc88b9cb95ba', 'a52cf3db-4a13-4330-ada6-627142da8000', '戎王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u620e-u80e5-u8f69: 戎胥轩 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('80356a3b-ba0b-4e2b-9077-f61dd689360a', '364d44ad-a3a8-4e2a-bdfd-25789d01f09d', '戎胥轩', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6210: 成 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('818d4fce-abcb-4d2e-8d87-40edbddb5ea8', '8d82c106-c497-4249-a819-2344d2847b29', '成', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6210-u516c: 成公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c7203c8f-6f0b-48ef-8081-3fe3398f3fd5', '40906a0d-f843-455a-ae42-1fafacfb0464', '成公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u62a5-u4e01: 报丁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('efb04d15-144c-4467-9cd1-1c90d7011903', 'ed3b3b19-bad9-4f2a-93e8-5920dde6fcc3', '报丁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u62a5-u4e19: 报丙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('02727d41-6ed4-4805-93b2-2d64fcc91fdd', '8c725d8e-2dd1-4830-a179-02f3e69051c5', '报丙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u62a5-u4e59: 报乙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d1e10382-43f5-460f-80c7-d9a1f912cc7b', 'e5eacaaa-6910-461e-99a9-13a876eef70a', '报乙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u632f: 振 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0c0a8bdb-a6ea-4ea9-a171-be3044ff4ba7', '4f47836e-dc17-49e6-9ff0-5cc10d484c20', '振', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u644e: 摎 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f0006679-7311-40e8-a6bc-a56280e6f6cc', 'b2464f7e-db1c-4061-a21b-33cad5d7f19a', '摎', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6563-u5b9c-u751f: 散宜生 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c353b062-15ef-4a66-b732-bb12b7ea2049', '1042374f-1a56-459a-9e76-3c256d4fe4e9', '散宜生', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6587-u5b34: 文嬴 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ba6380cc-2dbf-464d-aafd-4f27afcb1525', '78a202d7-25fe-406b-b5c3-6197d4bfc578', '文嬴', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6587-u5b34: 文公夫人
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b0dd623b-0234-4285-9721-d2c45d5468c8', '78a202d7-25fe-406b-b5c3-6197d4bfc578', '文公夫人', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u65c1-u768b: 旁皋 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8a7d42a8-c234-4844-9bba-58e23078dd5b', '798070e1-b9c2-4c4f-9e91-a9354a488eb5', '旁皋', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u65e0-u77e5: 无知 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fd817adf-b954-4fda-8f27-e13c8b7c471d', '7211e0a5-71ef-4f59-9c26-4054e3a2b63e', '无知', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u660c-u82e5: 昌若 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1e0ea145-ecf5-4ea5-ad22-457e6909f7e2', 'dc8083af-064f-490d-bad2-2d9960213458', '昌若', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u662d-u5b50: 昭子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('dfbf4a5c-cd92-4d89-ab12-d0d4992eb777', '8c0890b1-e82e-4895-ba71-c54ce3ac1a1a', '昭子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u662d-u660e: 昭明 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8696bd18-3b33-4f02-a83d-aa9667fad418', 'f71793a2-6ce3-4fd6-af8c-e331cc0505db', '昭明', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u662d-u738b: 昭王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('60461092-bc8f-43e5-9468-6316d739cd19', '138c6b9c-21f2-4ac1-871f-8a2f0ff4420d', '昭王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u662d-u738b: 瑕
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('95ae5b2b-5248-4d79-a1c2-3244e920d197', '138c6b9c-21f2-4ac1-871f-8a2f0ff4420d', '瑕', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u662d-u8944-u738b: 昭襄王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6f7d98d6-6add-4e03-ac0a-3d7ad692b806', 'd7616ce7-a0a9-4dbf-9245-4e5a398f333c', '昭襄王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u663e-u738b: 扁
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e31b44cf-90f5-45e7-9c88-65ea86c88bc2', '16eb05e7-7f10-48ae-975e-fbe00bfcccf0', '扁', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u663e-u738b: 显王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fed08a41-d35e-4e5f-96ab-8641a56cc8bc', '16eb05e7-7f10-48ae-975e-fbe00bfcccf0', '显王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u664b-u5389-u516c: 晋厉公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6da4695b-c7e9-428a-9f95-ada7a136423b', '2c63b966-e4d6-4693-994b-be9468dc3c64', '晋厉公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u664b-u5389-u516c: 厉公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9f88af79-2b5c-47b0-a884-86c659a97d47', '2c63b966-e4d6-4693-994b-be9468dc3c64', '厉公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u664b-u5510-u53d4: 晋唐叔 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b6bad777-e38d-4e7b-9a59-d004dffe9ec3', 'ca33fcb5-9162-407a-b63c-fea4cad6b7f5', '晋唐叔', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u664b-u592a-u5b50-u7533-u751f: 晋太子申生 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f43772a5-ac0d-4dcb-a04d-ffb6ffe60830', '647b1123-794a-42fd-985f-b34f9287a0e0', '晋太子申生', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u664b-u592a-u5b50-u7533-u751f: 申生
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0ef843d1-faed-4c2d-8dc8-a9d825491918', '647b1123-794a-42fd-985f-b34f9287a0e0', '申生', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u664b-u5b9a-u516c: 晋定公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('071d179b-3eed-4902-8725-d734cf5afbf8', 'b313dfe8-173e-4413-bd08-67399e1a5236', '晋定公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u664b-u5e73-u516c: 晋平公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b5d85624-b39e-4dec-b5d2-13535ad58fbb', '8c8cba52-c9c0-4399-bbf8-9afb97020bd3', '晋平公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u664b-u5e73-u516c: 平公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('255332ea-baae-4a31-b97e-8dd9a299e7a4', '8c8cba52-c9c0-4399-bbf8-9afb97020bd3', '平公', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u664b-u60bc-u516c: 晋悼公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3fc59212-2433-4c66-9da3-d78ea6c9f10c', '9318f515-2b0d-4200-9e50-0656e7e6c041', '晋悼公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u664b-u60bc-u516c: 子周
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6528ad9f-a25f-4336-a996-94b3f48d7138', '9318f515-2b0d-4200-9e50-0656e7e6c041', '子周', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u664b-u60bc-u516c: 悼公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c8b9c9da-834f-4cc1-9310-d27c97e12344', '9318f515-2b0d-4200-9e50-0656e7e6c041', '悼公', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u664b-u60e0-u516c: 夷吾
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5851ee90-a524-4b12-8317-a36a87a405bd', 'f1f48820-ebc7-41bd-8e87-2c5454bcad91', '夷吾', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u664b-u60e0-u516c: 晋君
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3b39b04e-b695-4efe-8441-e53ab91df571', 'f1f48820-ebc7-41bd-8e87-2c5454bcad91', '晋君', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u664b-u60e0-u516c: 晋君夷吾
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('44677cac-1650-4f0c-86c5-ab9f8517236b', 'f1f48820-ebc7-41bd-8e87-2c5454bcad91', '晋君夷吾', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u664b-u60e0-u516c: 晋惠公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('276cd942-01c2-4741-bad7-176ae0b5ee99', 'f1f48820-ebc7-41bd-8e87-2c5454bcad91', '晋惠公', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u664b-u6b66-u516c: 晋武公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3b2526bc-0249-49da-82b7-1e1f3a600fdd', '0b320972-ba4f-4f08-89e2-d0f0b094375b', '晋武公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u664b-u6b66-u516c: 晋曲沃
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ab2461a1-ec2e-49e0-b93f-d7144e04ecc6', '0b320972-ba4f-4f08-89e2-d0f0b094375b', '晋曲沃', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u664b-u7075-u516c: 晋灵公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('405d1c91-7746-45ab-bf0f-6825038e74ae', 'b28a7e2f-9132-419b-8366-c43b57ec70ae', '晋灵公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u664b-u7075-u516c: 灵公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5a7a667e-b89d-41fb-8a32-3117420c815f', 'b28a7e2f-9132-419b-8366-c43b57ec70ae', '灵公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u664b-u732e-u516c: 晋献公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e9294156-90fa-472c-914a-ea63f349670f', 'f4f17679-5e38-4c89-a529-b898d452e24a', '晋献公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u664b-u8944-u516c: 晋襄公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3d363b9f-4347-43c1-9a58-0098cf824a52', '67c02843-fc5b-4869-a82b-a508a25608c4', '晋襄公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u664b-u8944-u516c: 太子襄公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3b7a2d03-c796-4b07-93b5-26c35b3fa93e', '67c02843-fc5b-4869-a82b-a508a25608c4', '太子襄公', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u664b-u8944-u516c: 晋君
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9754242c-9f94-4cea-ad51-885047fc4b8d', '67c02843-fc5b-4869-a82b-a508a25608c4', '晋君', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u664b-u8944-u516c: 襄公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ec347e7d-d1f1-43db-a6c4-d9f76e187653', '67c02843-fc5b-4869-a82b-a508a25608c4', '襄公', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u666f-u5feb: 景快 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('71e422e2-ef24-45fd-ac2d-9f41f7cfedd1', 'ccc6c733-f331-4f1c-9d3e-aa52c8655191', '景快', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u666f-u76d1: 景监 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d9b9e083-7a6d-4178-a868-8b59aff91610', '3db4e1c5-342f-4cc1-a884-3ddfe51897eb', '景监', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u667a-u4f2f: 智伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('eb749b5d-36b7-43e6-bb14-88166dcaf721', 'cb68a112-4f43-4308-8cdc-e43afa5aa3bb', '智伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u667a-u5f00: 智开 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('39c789e1-1fec-4f67-b29d-a992c2210a97', 'bb70fa09-081f-469a-8cb3-44b6a5273268', '智开', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u667a-u6c0f: 智氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f57bc48c-8b55-4e8e-bc1c-62e719f5bca1', '0883125d-1240-4232-b88e-0a63707f3241', '智氏', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u66b4-u9e22: 暴鸢 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('be200910-88ac-48b5-b719-c545e7a57074', '3ecafb42-827c-42ee-ba6b-fa21d228aba5', '暴鸢', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u66b4-u9e22: 鸢
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a59f3c87-8635-4315-8677-f72eb330defa', '3ecafb42-827c-42ee-ba6b-fa21d228aba5', '鸢', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u66f9-u5709: 曹圉 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e7fb187d-b43f-43fc-b3db-d2bb18d36016', '2e1f9ec6-7463-4efa-8ecd-d7a28e609cfe', '曹圉', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6731-u864e: 朱虎 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4eac7b74-c0c4-49a9-b0e5-5b6d526c2f33', 'c02c2701-7bab-4e22-9437-39e2ccb0ce90', '朱虎', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u675c-u631a: 杜挚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8a9812f0-a779-48d5-9a04-90a3049a3f0a', 'cce26fdb-a4be-4525-827d-17dbe098323b', '杜挚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u683e-u4e66: 栾书 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('50a72d20-fa2f-4581-9771-c8306d8f48b8', '9bc2bf2b-58f8-4569-8674-de0b4f25b68d', '栾书', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6853-u516c: 桓公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('efd480a9-bfc5-4def-8868-288eebdff10d', '4673104c-d9ce-4a4b-92ba-04206e6c7db3', '桓公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6881-u4f2f: 梁伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('dda92bea-442f-4e95-8745-29835428e5fb', '6d2d4e6b-1bcb-49a1-900b-b98fb218506d', '梁伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6881-u738b: 梁王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('afae6ced-9cb4-49c0-a9bd-2567f018ca29', '766444fc-144c-4373-9cae-bb54dc9777b6', '梁王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u68bc-u674c: 梼杌 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('79d04c03-be27-4c0b-98a5-9d08abaed7b8', '673368d9-1523-4a7b-a105-2c7ed6367318', '梼杌', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u695a-u516c-u5b50-u56f4: 楚公子围 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6cd2af89-dd8a-4426-86c5-4556d96bfdb1', '5b1d1dc0-98a0-41b7-8d2a-6a1a3f4725e5', '楚公子围', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u695a-u516c-u5b50-u56f4: 灵王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f4bad5a5-44df-46a4-a2c6-c575b03c6374', '5b1d1dc0-98a0-41b7-8d2a-6a1a3f4725e5', '灵王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u695a-u58f0-u738b: 楚声王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('96811851-55fa-4d15-a1f6-64a7e467a832', '2e37c5c3-04ff-4309-a1f9-6a54225ea785', '楚声王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u695a-u5ba3-u738b: 楚宣王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('dbd9216d-2a3f-4f63-b00e-8f589e67cc75', '62555e1f-2aa6-47eb-80a6-c729c7d225dd', '楚宣王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u695a-u5ba3-u738b: 楚宣
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('66cbc4a2-128c-441a-a3aa-ac8db02c561e', '62555e1f-2aa6-47eb-80a6-c729c7d225dd', '楚宣', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u695a-u5e73-u738b: 弃疾
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b03fda90-ad15-49e3-9338-be7d46416ede', '3c6c000e-d3c5-4cac-919d-7c432d512cdb', '弃疾', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u695a-u5e73-u738b: 楚平王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('af55efbe-fb98-4902-aaca-19660f92d787', '3c6c000e-d3c5-4cac-919d-7c432d512cdb', '楚平王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u695a-u6000-u738b: 楚怀王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8fb2afc3-9662-4123-89ce-bd1a81b10f1b', '777778a4-bc13-4f91-b2c3-6f8efd1b0e72', '楚怀王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u695a-u6210-u738b: 楚成王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e4b53f56-a363-468c-8c9b-602c1992acb9', 'a088b8e2-758b-4c3d-82f9-2f43d064cbed', '楚成王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u695a-u6210-u738b: 成王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('619d79fe-e9af-4fd9-a155-dae08c7e9cb2', 'a088b8e2-758b-4c3d-82f9-2f43d064cbed', '成王', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u695a-u662d-u738b: 楚昭王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('57242151-a73a-466e-a0fe-a6b240472386', 'b83dcf8a-5370-49e2-85a6-86c4394e914e', '楚昭王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u695a-u662d-u738b: 楚王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8b987450-d06c-4d61-83b3-06c010060095', 'b83dcf8a-5370-49e2-85a6-86c4394e914e', '楚王', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u695a-u7075-u738b: 楚灵王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fc0eae6d-d400-4e21-bba0-9df4feb8be7c', '0937bb0d-82a0-477f-b3e6-508c7dccae2b', '楚灵王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u695a-u7075-u738b: 灵王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2efd73b0-2dfd-42dc-a663-84fde85b9bef', '0937bb0d-82a0-477f-b3e6-508c7dccae2b', '灵王', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u695a-u738b: 楚王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7f6bc9d3-b7d9-4d35-a675-45623b79cada', '52014459-0a6e-4077-902c-84b718ded20e', '楚王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u695a-u7a46-u738b: 楚穆王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8384c9f3-bea5-4c65-b3e1-b16a09f9be43', 'c361d1cd-27a0-4759-8afc-37fae21a321d', '楚穆王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u695a-u7a46-u738b: 商臣
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e63e015f-7643-443c-a8b3-f2109eff1c7e', 'c361d1cd-27a0-4759-8afc-37fae21a321d', '商臣', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u697c-u7f13: 楼缓 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b342a63f-b63e-4dd0-a2b3-fa816cf70868', '76523e8e-cb37-41fc-bb07-f44db1ee89c6', '楼缓', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6b66-u4e59: 武乙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0014e4d4-dff6-44c9-a900-fdd88c8f9c38', 'b45f2e48-f669-4b36-93ed-213e3b36a0eb', '武乙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6b66-u4e59: 帝武乙
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('72ca65a0-eaf9-473e-a2cc-e3894ed64aa4', 'b45f2e48-f669-4b36-93ed-213e3b36a0eb', '帝武乙', NULL, 'temple', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6b66-u516c: 武公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5da8bcde-b58b-409e-b01e-d8fedaf3c28c', 'dc392c18-ed6d-440b-9e2f-75ee6b04cab8', '武公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6b66-u5e9a: 武庚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('44a30981-287f-448d-ae5b-190def45dc71', '70e67046-bba3-491e-8f41-64c8b46af1ea', '武庚', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6b66-u5e9a: 禄父
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5b7a5672-a079-48c1-a89b-0927171ff8bf', '70e67046-bba3-491e-8f41-64c8b46af1ea', '禄父', NULL, 'courtesy', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6bb3-u65a8: 殳斨 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d64c9190-19d9-4565-99b5-a5dbf47a0553', 'ede0056d-29a5-45a5-999c-904cc6eb0e82', '殳斨', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6bc1-u9683: 毁隃 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d282bb38-7d3a-4af4-bee3-c9010becb077', '07f5e40a-0ff4-42e0-8f84-a0e5b33f0fe8', '毁隃', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6bd5-u516c: 毕公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('417cdfd9-be56-4b0e-9e8c-6b205e856761', '53fc8b30-2303-4339-b3db-045e3f0b8b38', '毕公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6bdb-u53d4-u90d1: 毛叔郑 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5e6d469a-4413-4575-940c-dc7de6ee7ab2', '827364d8-c7fb-4322-8084-e537cc8eac56', '毛叔郑', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6c83-u4e01: 沃丁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('252452af-30e8-44cd-8021-6c78489c59c5', 'c65680a5-8e79-41c8-ad07-7f7fdaffc0e2', '沃丁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6c83-u4e01: 帝沃丁
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f2fa7014-421a-40ea-b5e8-a438d66699e9', 'c65680a5-8e79-41c8-ad07-7f7fdaffc0e2', '帝沃丁', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6c83-u7532: 沃甲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('518f1fe8-6659-4453-9661-b53a1367b570', '479b1fd2-d739-43d2-a7c6-75284b6eaa82', '沃甲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6c83-u7532: 帝沃甲
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('95714bec-988a-4227-bfc5-f02a2dc91adb', '479b1fd2-d739-43d2-a7c6-75284b6eaa82', '帝沃甲', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6cb3-u4eb6-u7532: 河亶甲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9582b70d-3c7d-4ec2-b122-1156008c0cef', '85531e86-3424-4048-a90a-ef090fe9f336', '河亶甲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6cb3-u4eb6-u7532: 帝河亶甲
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0e75f5d4-7348-448a-8b8b-d0b6a84d37b8', '85531e86-3424-4048-a90a-ef090fe9f336', '帝河亶甲', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6cc4-u7236: 泄父 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9aac5241-6d7c-4d72-9809-0b38917978cf', '1dbe91cd-5506-4bd5-8e40-3643a931370e', '泄父', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6cfe-u9633-u541b: 泾阳君 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f31ca9b5-09d1-4f43-b484-7c4e9b9001ee', '4f0e082e-7ab5-4cb6-a6b9-faa7e73abc47', '泾阳君', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6d51-u6c8c: 浑沌 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('62151be8-64a2-4853-b1dc-b7322f95bf86', '8f15868e-a5b6-4003-ab74-87a8df633206', '浑沌', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6d82-u5c71-u6c0f: 涂山氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('882e1246-a940-474f-a6be-5b76cdbf308d', '0aff7cb5-0ffd-4097-a2d0-9539c44856d6', '涂山氏', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6d82-u5c71-u6c0f: 涂山
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('33189ffa-58f5-4b08-a057-86d3ad460a9c', '0aff7cb5-0ffd-4097-a2d0-9539c44856d6', '涂山', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u6d82-u5c71-u6c0f: 涂山氏之女
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a6e714d6-f5ae-43e1-ae80-d166c7ee2b50', '0aff7cb5-0ffd-4097-a2d0-9539c44856d6', '涂山氏之女', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u6e38-u5b59: 游孙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('74a521cc-2271-46df-ac98-b5df901a3d43', '111de572-6811-4416-a4ae-59d51c3aa997', '游孙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7075-u516c: 灵公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('af92a8de-0b1c-4cf1-96e6-e92e6f1facbe', '0623012c-d2bd-45c7-8382-5473a4e59610', '灵公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7075-u738b: 泄心
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('68582afc-1e87-41bc-b40f-dc07ec246b11', 'f6e2f921-1f10-48c3-b982-63c4eb1f5586', '泄心', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u7075-u738b: 灵王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0483faee-5259-4849-8bca-2c3e7be79f38', 'f6e2f921-1f10-48c3-b982-63c4eb1f5586', '灵王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u70c8-u738b: 喜
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('807dbeee-fa52-4031-8ebb-d8819e582aa3', '81148632-939a-4900-a410-68740062209c', '喜', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u70c8-u738b: 烈王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ba386ff5-f7e5-469a-86e4-c26af9eba6a5', '81148632-939a-4900-a410-68740062209c', '烈王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u718a-u7f74: 熊罴 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('92fb0251-cb52-4f13-ad30-5305a337481b', 'e15a3a4b-5cae-4015-9a11-01d6f39e98f8', '熊罴', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u71d5-u60bc-u4faf: 燕悼侯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('dbb42fd6-2fcf-4003-bf94-3db12570b802', '0284ee00-69db-464b-a9c0-7c8293f7df9d', '燕悼侯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u71d5-u60bc-u4faf: 燕悼
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6c8d7dab-98d8-4c73-9330-77e4a94176d4', '0284ee00-69db-464b-a9c0-7c8293f7df9d', '燕悼', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7280-u9996: 犀首 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cfb9bc0a-dd03-4641-bc1b-46c6a5592e11', '0ec5331f-0ef2-43a0-bf1a-c3f4f0418968', '犀首', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u732e-u516c: 献公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ee1c2792-13d6-4a8f-9c48-52f4c008277c', 'ebcd8d48-2cda-49c9-9a6d-47267842dcec', '献公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u738b-u5b50-u514b: 王子克 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('68bf33b7-cf39-413b-9ad1-bb7082b37a19', '5558d845-95eb-4043-92a4-ed26c57805ba', '王子克', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u738b-u5b50-u5e26: 叔带
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('62c12ef6-2fc8-49c9-a75a-8babf5f85e18', '7c34a692-0caf-4919-b027-04f08d5314dd', '叔带', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u738b-u5b50-u5e26: 带
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('041ef687-d845-4b12-b820-0f5f14313e57', '7c34a692-0caf-4919-b027-04f08d5314dd', '带', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u738b-u5b50-u5e26: 王子带
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('323d6f53-d922-4444-a647-27ac5b8f5786', '7c34a692-0caf-4919-b027-04f08d5314dd', '王子带', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u738b-u5b50-u671d: 王子朝 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e8d7d754-474e-4df1-b38f-d7ba9a6f5b92', '31bbceec-f626-4986-b832-1b0d4844067a', '王子朝', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u738b-u5b50-u671d: 子朝
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fc4506cb-60c2-4630-9bd2-4b08b09e38ec', '31bbceec-f626-4986-b832-1b0d4844067a', '子朝', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u738b-u5b50-u9893: 王子颓 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1c732fc2-9680-4d5f-9025-2909aa8a09f6', 'a2bdf817-24cc-4e1b-a31c-c5381c845daf', '王子颓', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u738b-u5b50-u9893: 周王子颓
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3cd8d2b8-29cd-41b0-9c35-ecb46b71072d', 'a2bdf817-24cc-4e1b-a31c-c5381c845daf', '周王子颓', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u738b-u5b50-u9893: 颓
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4ec8f9f1-d901-44cd-98c0-18f0a2b9417b', 'a2bdf817-24cc-4e1b-a31c-c5381c845daf', '颓', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u738b-u5b59-u6ee1: 王孙满 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ee357a1c-4179-430d-ac7b-e93b76479fc0', '896d6b73-62d1-4a0b-9a20-966b39bd6be7', '王孙满', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u738b-u5b59-u6ee1: 周王孙满
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9a667371-89a4-47c0-a066-ec2f8bd127ec', '896d6b73-62d1-4a0b-9a20-966b39bd6be7', '周王孙满', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u738b-u9893: 王颓
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ff788fb9-2988-48c0-a57b-2a9092d7273d', 'a8430d03-ac7f-4a96-be08-221f2368df88', '王颓', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u738b-u9893: 颓
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9840cce2-e39f-42f6-83fd-69fe6b437e74', 'a8430d03-ac7f-4a96-be08-221f2368df88', '颓', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u738b-u9f81: 王龁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6d2a2e50-8744-4cbc-901c-3b3924bf5814', '36c8288d-f0fd-43f8-a931-e1eb162db3c0', '王龁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u738b-u9f81: 龁
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('622f5153-88b6-4542-b87d-21d8179d1489', '36c8288d-f0fd-43f8-a931-e1eb162db3c0', '龁', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7518-u9f99: 甘龙 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('85a88056-b7b0-4d5f-84df-a7a3c181659d', '7004f032-0964-4336-9e64-7e2021330b10', '甘龙', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u752b-u4faf: 甫侯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('65c631de-3627-49cc-8cc5-617981fcc910', 'b72647cb-3802-408f-9975-d93d91eee027', '甫侯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7530-u4e5e: 田乞 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('aa9d93ca-45c7-416b-9c32-05c825be2f90', 'c65795a6-4481-46a4-8b11-95c6246033ab', '田乞', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7530-u5e38: 田常 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('90f8176b-0b7e-465b-b616-d2abe20a81fc', 'f7155b07-cd14-4cca-91cb-2a8338ced753', '田常', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7533-u4faf: 申侯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f3f8b4bb-9f13-4e74-a2ec-2565bba4ed7f', 'c7de1699-5d38-4f62-8206-590008278f70', '申侯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7533-u5305-u80e5: 申包胥 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('63a0373a-c0f5-4c7d-9de8-cf782f33b232', '94cc1a89-4cd6-4808-bf7b-d61556261283', '申包胥', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7533-u540e: 申后 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f2a73750-18c7-49c9-93a1-a4679af0487f', '417d113d-108f-42f2-b23d-3e23dc52a9a9', '申后', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7533-u5dee: 申差 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ac82f496-afd0-4b69-9a3f-eb3572b43ef6', '569926d1-3bbd-409b-8970-109702bf5379', '申差', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7533-u751f: 申生 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ae8d6cf8-2d09-49f4-976f-ce475a8da342', 'd06e316e-dc9d-44d3-b216-6d5fd6cc5912', '申生', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u75b5: 疵 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1f28e0b2-1b94-46ce-8046-2f9afbbc6b9d', '4b737d50-b77b-48ef-8e8d-8808005139ad', '疵', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u75b5: 太师疵
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('19ea5a96-6bc0-4088-9013-2a1221a2e1bc', '4b737d50-b77b-48ef-8e8d-8808005139ad', '太师疵', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u767d: 白 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4de8855f-5ada-4c2e-98b0-0186d1e9b71e', '8babae5a-940d-4c43-8b1a-6189c530e89b', '白', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u767e-u91cc-u5092: 百里傒 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a4d88f02-0d7b-47ea-96f5-3c5106319e0a', 'c9ac1302-73ca-418c-a911-47c87759f285', '百里傒', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u767e-u91cc-u5092: 五羖大夫
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('745c0e96-c303-4a98-9eb2-f527508d3aae', 'c9ac1302-73ca-418c-a911-47c87759f285', '五羖大夫', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u767e-u91cc-u5092: 傒
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('98083752-ad95-48e6-b895-3a334966a4c4', 'c9ac1302-73ca-418c-a911-47c87759f285', '傒', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7687-u4ec6: 皇仆 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f5383447-d7ca-4df1-9119-78467f24e9f7', 'ca1f6e3f-7e21-4a75-ae16-0fd4433714f8', '皇仆', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u76f8-u571f: 相土 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9f03fea9-3708-4461-92c9-9f9ff6cf0888', '6e851a98-5b2d-4d3f-93da-9d1794d5d600', '相土', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u793c: 礼 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d2fb2453-3241-4187-a7cd-1cabc8fcbaca', '6e32a367-6a4e-4719-ba80-d8a10ead3f83', '礼', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u793c: 五大夫礼
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('405998e3-6125-475d-bf07-a2ccb4ecf600', '6e32a367-6a4e-4719-ba80-d8a10ead3f83', '五大夫礼', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7956-u4e01: 祖丁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('95c839d6-4a69-4973-a116-33519f510ac1', 'd153de2d-51be-4672-9831-840891edf6a8', '祖丁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u7956-u4e01: 帝祖丁
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('67d8717e-4a0f-4aa1-9886-95bb6b40539b', 'd153de2d-51be-4672-9831-840891edf6a8', '帝祖丁', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

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
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('21206474-7bb5-41e1-9bcc-06c4ddec924c', 'ed306319-a294-43af-bdb7-184d1c1c4f56', '帝祖辛', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u796d-u516c-u8c0b-u7236: 祭公谋父 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9d9a2dd9-25db-4711-8c29-5f082255758d', '51248eed-0768-410a-934e-c5631f0c4a86', '祭公谋父', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u4faf: 秦侯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7865619a-57fa-4d79-9bc9-0e22cff69eca', 'a838f266-7e1e-4c80-9f36-fba7928a2f97', '秦侯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u5171-u516c: 秦共公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('431480f2-1c75-4ccb-a883-0318e35fd75b', '6a954196-a878-49e5-a85b-f9a03b6f5ba3', '秦共公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u5171-u516c: 共公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('62d90294-802d-4cb9-bfcd-8e9292371c0c', '6a954196-a878-49e5-a85b-f9a03b6f5ba3', '共公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u51fa-u5b50: 秦出子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2a59afb4-be51-438a-b8ee-db19f9284072', '38f5fd55-7ce9-48a6-bf96-fa3f73d76ed5', '秦出子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u51fa-u5b50: 出子
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('519bfeb5-cf3c-48b8-ad9f-17e20ef89276', '38f5fd55-7ce9-48a6-bf96-fa3f73d76ed5', '出子', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u5389-u5171-u516c: 秦厉共公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ee983f93-83be-4355-9547-ee841500fb1e', '6a85ef15-5933-4cf7-98f5-257d90fa5f3a', '秦厉共公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u5389-u5171-u516c: 厉
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b4aaa83f-7b4d-402b-a626-45a23554a3ae', '6a85ef15-5933-4cf7-98f5-257d90fa5f3a', '厉', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u5389-u5171-u516c: 厉共公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4b0dbe5a-b9e2-41e4-badc-a1038b5674c1', '6a85ef15-5933-4cf7-98f5-257d90fa5f3a', '厉共公', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u54c0-u516c: 秦哀公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('dc113c22-e94a-46f6-8696-1da4812154f9', 'c1739df3-4de7-4bb4-acc8-d99c467878b5', '秦哀公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u54c0-u516c: 哀公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1695d640-0ecf-4f2d-98cb-f6d65329c9fc', 'c1739df3-4de7-4bb4-acc8-d99c467878b5', '哀公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u5937-u516c: 秦夷公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7d64e52c-1527-450b-9f2c-59258318fbab', '1d50c774-f2d6-41b1-b7c5-ae46e9a1559d', '秦夷公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u5937-u516c: 夷公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('02efef8a-7bad-473a-86f2-e175e3d27271', '1d50c774-f2d6-41b1-b7c5-ae46e9a1559d', '夷公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u59cb-u7687: 秦始皇 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ab3027e2-e12f-4be2-b165-1726de14df50', '90e1802e-506f-47c7-80b2-8b3a96eaea7a', '秦始皇', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u59cb-u7687: 政
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7fcee444-ef41-477d-9c5e-c3e273f4b71d', '90e1802e-506f-47c7-80b2-8b3a96eaea7a', '政', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u59cb-u7687: 秦始皇帝
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('10d7c537-7975-4bfe-8274-de951dcba9a3', '90e1802e-506f-47c7-80b2-8b3a96eaea7a', '秦始皇帝', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u5b34: 秦嬴 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('73fa1c2f-bd51-4c9a-ba32-0389efc4ec85', '4f78e051-68fb-4e75-b862-07fd215cd243', '秦嬴', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u5b5d-u516c: 秦孝公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('21ca9546-5a4e-4f17-a484-310d31577509', '4624bb13-45fc-4b26-92da-aaac3bf14ca9', '秦孝公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u5b5d-u6587-u738b: 秦孝文王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('369be354-bace-4834-83a9-9b4c00d77eae', 'd4b61e89-82a8-4921-a417-f0b9a67badcf', '秦孝文王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u5b5d-u6587-u738b: 孝文王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cc951a69-2a4f-497c-9198-06699e1d6848', 'd4b61e89-82a8-4921-a417-f0b9a67badcf', '孝文王', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u5b81-u516c: 秦宁公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('371a97fa-3f70-4071-b7b6-30ac5d08c742', '00b70ef0-25af-483f-b896-5dd324736dc1', '秦宁公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u5b81-u516c: 宁公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3bf31814-b1ef-469f-a5fe-2c4cb541730a', '00b70ef0-25af-483f-b896-5dd324736dc1', '宁公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u5ba3-u516c: 秦宣公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('20e39066-4ebe-4896-a401-fc39dcbd0511', 'd3b5caa1-36b2-4b27-a72f-841a2a6742f6', '秦宣公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u5ba3-u516c: 宣公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d370f797-ff84-4227-928a-2ddc57af6b9b', 'd3b5caa1-36b2-4b27-a72f-841a2a6742f6', '宣公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u5e84-u8944-u738b: 秦庄襄王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('971d45cc-aad8-4295-9473-36d74f7881d5', '75baf2b8-5af3-4210-b122-59cac87682e8', '秦庄襄王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u5eb7-u516c: 秦康公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('38c85015-5a2f-45ad-ba79-4340a9228814', '7ca9d4b9-3bdb-4c89-a198-cb31b75e8093', '秦康公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u5eb7-u516c: 嵤
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('459bc756-bf80-4bac-8eca-6c813c318790', '7ca9d4b9-3bdb-4c89-a198-cb31b75e8093', '嵤', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u5eb7-u516c: 康公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e6e2d770-3e37-47e7-9dc1-0a78eed7cf98', '7ca9d4b9-3bdb-4c89-a198-cb31b75e8093', '康公', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u5fb7-u516c: 秦德公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9aac79ef-ad0f-4470-930a-bee4a38a7da0', '77726816-4189-4191-b8ae-ce9d4b6ae564', '秦德公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u5fb7-u516c: 德公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f0eeeca1-fc63-43d7-a240-8e9d48180f68', '77726816-4189-4191-b8ae-ce9d4b6ae564', '德公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u6000-u516c: 秦怀公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('06b03636-cde3-4d41-9b9b-6f60b666efe9', 'b76bd25a-a78b-4179-bc39-63ee0f82faf9', '秦怀公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u6000-u516c: 怀公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5a0b8ae3-d243-4975-a521-ea688e2feecd', 'b76bd25a-a78b-4179-bc39-63ee0f82faf9', '怀公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u60bc-u516c: 秦悼公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0eb72925-fbb8-466b-b8fa-1059ba4f5c07', 'b788b8da-9e37-44cb-a034-79b5f718f38d', '秦悼公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u60e0-u516c: 秦惠公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f87f71e3-89b9-4d69-887a-dd1debd7e4ea', '3d647c32-9b0b-4f94-b19d-5263b6412e61', '秦惠公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u60e0-u516c: 惠公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('710a8431-3657-4df2-9df7-e056783bf5dd', '3d647c32-9b0b-4f94-b19d-5263b6412e61', '惠公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u60e0-u738b: 秦惠王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6e225e8d-9c36-40a4-8c63-cb3821c7cbb2', '9e121cb9-fd9e-4b37-9137-47fe13ead716', '秦惠王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u6210-u516c: 秦成公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('509d9868-2793-4fb4-a23f-0cbcbb64b732', '48061209-63f6-4d69-9eba-471de7985e25', '秦成公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u6210-u516c: 成公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('79b71853-ca19-44f9-a138-22a41478e5cd', '48061209-63f6-4d69-9eba-471de7985e25', '成公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u6587-u516c: 秦文公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cac68bf5-9950-4c9e-845a-181bcfe80058', '1acac368-f62d-468a-9464-da4a5f44c1f6', '秦文公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u6587-u516c: 文公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7c8ed5fb-67ea-433c-b0f6-77b5e65a1aa4', '1acac368-f62d-468a-9464-da4a5f44c1f6', '文公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u662d-u5b50: 秦昭子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('096ca910-09df-48aa-93d9-75173e3cf7e7', 'eda7daad-8b7b-40e7-9fa0-a2a5b8944218', '秦昭子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u662d-u5b50: 昭子
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e5aca41d-b424-424c-ad67-5709b686f6f5', 'eda7daad-8b7b-40e7-9fa0-a2a5b8944218', '昭子', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u662d-u738b: 秦昭王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2bb9da01-9c72-4247-b6e7-87696c387808', 'f25ff1dc-53b7-40b4-adec-a96529d8c0ac', '秦昭王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u666f-u516c: 秦景公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6aac9394-bd1f-4c5c-92b0-588f4fd6e8fe', 'acd63240-e9a6-4dc1-908a-4f6fa776a055', '秦景公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u666f-u516c: 景公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9fc58b70-d799-4e34-a416-949187912749', 'acd63240-e9a6-4dc1-908a-4f6fa776a055', '景公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u6853-u516c: 桓公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a008b199-ae1d-433f-aa3f-cafa68591896', 'fe882af0-51f4-46a6-9a4f-61011d2f4c46', '桓公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u6853-u516c: 秦桓公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a4030f66-4999-41ae-a0d0-663ccad5727e', 'fe882af0-51f4-46a6-9a4f-61011d2f4c46', '秦桓公', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u7075-u516c: 秦灵公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c5e5c5a8-27a1-4305-94a9-a120c800ae03', 'bb347375-b66c-4050-8864-124c8e2318e4', '秦灵公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u7075-u516c: 灵公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fd8e0546-feef-4085-a727-9c15ae00725e', 'bb347375-b66c-4050-8864-124c8e2318e4', '灵公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u732e-u516c: 秦献公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8c6fa4ff-253d-40b4-b43b-89bbd6a89af1', 'caa24f9d-5cea-4743-8690-e4b1a47b06a5', '秦献公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u732e-u516c: 献公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ab80190b-9120-4c3f-8877-a92b8247520e', 'caa24f9d-5cea-4743-8690-e4b1a47b06a5', '献公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u738b: 秦王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a476d234-e3ac-4d93-8b69-dd07225d9725', 'c5f0f89b-0a98-4419-84f3-4c2ae7853c41', '秦王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u7a46-u516c-u592b-u4eba: 秦穆公夫人 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('738f8734-32f0-4abd-a0a5-cdb71c0079fc', '4f9b6d25-e59e-4821-baeb-6a0ba2ea63ca', '秦穆公夫人', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u7a46-u516c-u592b-u4eba: 夫人
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5d561e67-09a5-4cff-bc68-adfda911dbde', '4f9b6d25-e59e-4821-baeb-6a0ba2ea63ca', '夫人', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u7b80-u516c: 秦简公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6248afbe-b8ff-4ac5-aa60-ce6f63fa7ab4', 'bd7f9f66-b7c5-4d0c-b576-c4d08ddbb28a', '秦简公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u7b80-u516c: 悼子
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4fc1957d-b712-40b1-959c-37c45328bf2b', 'bd7f9f66-b7c5-4d0c-b576-c4d08ddbb28a', '悼子', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u7b80-u516c: 简公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6dc7c9e0-178d-460f-a133-fbcd5057aff7', 'bd7f9f66-b7c5-4d0c-b576-c4d08ddbb28a', '简公', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u7f2a-u516c: 秦缪公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6794fd34-f813-44b0-b8c9-894bbb9a64b1', 'a1d87a9d-ecde-4486-9285-aeba4a25e2d3', '秦缪公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u7f2a-u516c: 缪公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('af5c24bb-a1f3-466a-beeb-b3fdeda696c8', 'a1d87a9d-ecde-4486-9285-aeba4a25e2d3', '缪公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u8944-u516c: 秦襄公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f7c3c32c-86d8-41af-b492-81f7af753917', '68cacaa2-03dc-4fb6-bfaf-6bf160888e18', '秦襄公', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u8944-u516c: 襄公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c96d953b-5d91-481f-8054-d3e246ba34d6', '68cacaa2-03dc-4fb6-bfaf-6bf160888e18', '襄公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u79e6-u8e81-u516c: 秦躁公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('57572b3d-e3d0-4ab7-8aec-78b2b0e153b5', '305ddd4f-ee69-4353-bf97-b3a6f513d9f6', '秦躁公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u79e6-u8e81-u516c: 躁
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ef41e330-48d0-4384-92f9-bcb80ed51e11', '305ddd4f-ee69-4353-bf97-b3a6f513d9f6', '躁', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7a46-u738b: 满
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7939789d-3198-4b2c-a9b5-99e0779e5a9d', '2eba9b3e-b6e0-4a83-b355-0404342198ac', '满', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u7a46-u738b: 穆王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('60ae791d-554b-40ac-a84c-22e8c823460d', '2eba9b3e-b6e0-4a83-b355-0404342198ac', '穆王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7a77-u5947: 穷奇 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('281c6d5f-4416-44a0-b1ab-d3a934789d5e', '923f754d-2767-4698-9ef6-4c2b0f9701fc', '穷奇', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7ae0-u5b50: 章子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b5562b4e-efaa-43d3-9ea3-f005edaa9570', '215b38cd-ac73-48b5-9635-9524f1197e6d', '章子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7aeb-u516c: 竫公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7fa3dc77-c553-4c76-bdfb-359eba5af987', '8e5e85c0-f9aa-4e6f-936d-2fff07ada6ba', '竫公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u7aeb-u516c: 文公太子
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f6454555-03a3-4195-ae97-d4f0bce13896', '8e5e85c0-f9aa-4e6f-936d-2fff07ada6ba', '文公太子', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7b80-u516c: 简公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('44bd75b0-6fb6-4184-abe1-f55d52760599', 'e6e9d27e-b800-4c54-8296-19ac3cfcec42', '简公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7ba1-u53d4: 管叔 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('237db603-99c8-42cb-b94a-e6c6ce79cee8', '6371d326-0731-4488-bf85-243ea3fcc5e1', '管叔', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u7ba1-u53d4: 管
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('10d36a98-da2e-47a8-8a71-fc39ee04488a', '6371d326-0731-4488-bf85-243ea3fcc5e1', '管', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7ba1-u53d4-u9c9c: 管叔鲜 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('224f02eb-7c57-490a-bcfe-794301ea0853', 'f2911b94-414d-43e2-9ce8-b3eef81e3b76', '管叔鲜', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u7ba1-u53d4-u9c9c: 叔鲜
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('33dce703-cb19-45c6-845e-2da7cb86b8f8', 'f2911b94-414d-43e2-9ce8-b3eef81e3b76', '叔鲜', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7ba1-u81f3-u7236: 管至父 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('496e6ec5-3efd-4182-9bdf-f58bce9f3ffe', '812e812b-df41-4488-93fa-4843b2be109f', '管至父', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7f19-u4e91-u6c0f: 缙云氏
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a59d23fa-f749-4de1-8621-681cb273e85e', 'ae47eddd-804b-4715-974a-d1eb99a19509', '缙云氏', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7f2a-u516c: 缪公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6a27af84-07a6-4e14-b274-acfda8bbf0a6', 'dfbc851d-f3bc-4d4d-bdab-efd522f63865', '缪公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u7f2a-u5b34: 缪嬴 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8d4885c6-a20e-4e95-8267-520c2d983272', 'b45d696f-f555-4e83-ac79-e7eec6d5a881', '缪嬴', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u80e1-u4ea5: 胡亥 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('505d9b8c-446b-4e0e-a550-253b1bf0c3bb', '57a05049-d840-487f-892d-344c1b60b85d', '胡亥', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u80e1-u4ea5: 二世皇帝
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('49f82cd2-a076-4858-943e-7cd445b66698', '57a05049-d840-487f-892d-344c1b60b85d', '二世皇帝', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u80e1-u9633: 胡阳 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a84b4843-b601-4b09-a2e4-f99fd890d38c', '0baa918f-4de5-4ad6-ad18-bb05064af08a', '胡阳', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u80e1-u9633: 中更胡（伤）［阳］
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3f6bdc2a-a7aa-4453-98d3-657a3b8e90f2', '0baa918f-4de5-4ad6-ad18-bb05064af08a', '中更胡（伤）［阳］', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u80e1-u9633: 客卿胡（伤）［阳］
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ab0448c2-4577-4cbd-bc38-8963dda21c5f', '0baa918f-4de5-4ad6-ad18-bb05064af08a', '客卿胡（伤）［阳］', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u80e4: 胤 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ce633e02-6071-4089-a6dd-bd9306745ddd', 'bcc268f7-cdb8-45f6-bc1c-b713335c158a', '胤', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8288-u620e: 芈戎 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9cb29c0a-ee22-4966-8f90-20eaaeabc2f9', 'a43e96dd-f32d-42e1-8454-b7911f626fc8', '芈戎', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8292-u536f: 芒卯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c971517a-73d4-4105-99d3-fdb528700f1b', 'b1a65226-c85c-40f0-86be-5432d89ea865', '芒卯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u82ae-u4f2f: 芮伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6559824e-6517-401b-b721-d74329299ba1', '33c3fc0d-8a20-484c-86a5-a12fa70fc252', '芮伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u82ae-u826f-u592b: 芮良夫 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('373b97c7-678b-45dd-ae60-2933d6d485c5', '7b9e7074-eb0f-4417-85e1-d08e4d025c38', '芮良夫', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u82cf-u4ee3: 苏代 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a8034ab4-8f77-4aa4-8d0d-47eae2a3611c', '98c7b6fe-1eb2-45cf-b1f5-b5ee035f5ce9', '苏代', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u82cf-u4ee3: 代
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e4c5f1e6-3103-4a55-bd8e-47998ecbc22d', '98c7b6fe-1eb2-45cf-b1f5-b5ee035f5ce9', '代', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u82cf-u5389: 苏厉 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d0321ef1-007f-4303-99e2-cfa33091b111', 'bc219c2b-0855-4c80-9717-73d837edca9d', '苏厉', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u82e5: 若 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d18f5f4d-6143-4801-9430-d76c7b50d2c0', '8d252418-77ad-4e2c-8c52-ab84db80f49a', '若', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u82e5: 蜀守若
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('59cc95a8-292e-4130-9fd6-4fbd8c157e5f', '8d252418-77ad-4e2c-8c52-ab84db80f49a', '蜀守若', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8303-u6c0f: 范氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('da89e453-b7cc-4996-a560-4b4f84d9c08d', 'e5d4a3e7-a096-434a-892c-48909c5e71c3', '范氏', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u8303-u6c0f: 范
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b95c3eee-fc18-4fdc-ac4e-54b82df24a5e', 'e5d4a3e7-a096-434a-892c-48909c5e71c3', '范', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8340-u606f: 荀息 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('67310c8d-cf39-4a76-8d0c-b8ddcf21d7ec', 'd1257616-881f-4678-b90c-62ae78a300cf', '荀息', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8363-u4f2f: 荣伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f264c1e2-4057-405c-ae58-e289cf8436bd', 'ac17502b-e21e-4b6f-8e3c-b2a683bed0cc', '荣伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8363-u5937-u516c: 荣夷公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b17681dd-40a7-46c9-ad09-d8c259200182', '35339d44-9255-426b-97a8-71fb2de7878f', '荣夷公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u8363-u5937-u516c: 荣公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('de8e5fb8-ce75-478a-904f-b04b8bc32322', '35339d44-9255-426b-97a8-71fb2de7878f', '荣公', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u845b-u4f2f: 葛伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('99ea14ab-8e83-4f58-9d97-554571617895', '15525c10-3e44-4885-a386-37bfb92f02da', '葛伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8499-u6b66: 蒙武 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('700f2ab9-ea89-4aa9-b716-b0be31bf5e44', 'ba9a4ea6-1204-4955-95da-142ca48dde6a', '蒙武', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8521-u53d4: 蔡叔 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('43c69ff9-7e97-4bc0-bf63-577681bc6ce6', '749ac677-2ff0-4dc4-a2e2-1580f163988e', '蔡叔', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u8521-u53d4: 蔡
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cb8c6a64-5592-4f64-8ba7-2252e499c16d', '749ac677-2ff0-4dc4-a2e2-1580f163988e', '蔡', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8521-u53d4-u5ea6: 蔡叔度 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fe9018f2-c62b-4ac8-90bb-81633ac63b04', '435565e5-f8f4-4d41-9223-a568458f6a48', '蔡叔度', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u8521-u53d4-u5ea6: 叔度
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3e80de3e-9c46-4d2a-8373-1a378d04ccfc', '435565e5-f8f4-4d41-9223-a568458f6a48', '叔度', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8521-u5c09: 蔡尉 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('909cbe0d-7c13-45ce-9b77-ccb9c4c1850a', '04b6a296-ea84-48d8-b4f4-c27bad05d332', '蔡尉', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u865e-u4ef2: 虞仲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9952ef3b-18e1-4c44-9461-a52c17df2d7c', '5b508025-03f8-4be4-8e95-d62dedae88df', '虞仲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u865e-u541b: 虞君 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ed839069-6b23-43e0-ac4e-3f03d1245438', '16a84469-dc96-487e-a086-8c8dee943798', '虞君', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8662-u53d4: 虢叔 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2f87458f-4160-42d9-b73e-05ab53468a02', '652f7c9d-b0b1-47cc-ab86-1bcb21ccdc0d', '虢叔', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8662-u5c04: 虢射 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('eddc0049-380a-4a40-ae3a-842c1893e618', 'db256f55-d4cf-4082-b9e3-a0ffefbea291', '虢射', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8662-u6587-u516c: 虢文公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5fc4ed9f-b73c-4d3a-999c-1b81d6908522', '2aa261cf-b43a-4e61-be0f-0daeccbc8519', '虢文公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8662-u77f3-u7236: 虢石父 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b903b432-18da-4bb5-8b93-1229819473a4', '5409e935-d2bf-4f81-b185-d8a7642d208b', '虢石父', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u8662-u77f3-u7236: 石父
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3c03ee7d-4293-41e3-8171-744f08a9b161', '5409e935-d2bf-4f81-b185-d8a7642d208b', '石父', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8700-u4faf: 蜀侯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('167d9e64-2224-4b6a-9eaf-b47f35a5be8e', '27cb905e-2cc8-493d-901b-e1a55adc69dc', '蜀侯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8700-u4faf-u8f89: 蜀侯辉 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8234c13b-17c2-4146-b16f-17ca8d3e3f50', 'a08474e9-9d06-403c-8f25-d9dd9d723e5f', '蜀侯辉', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8700-u58ee: 蜀壮 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f2e72681-7fdc-455f-99f3-cc852bb2cb3a', '3c50af45-c95f-438b-9044-ceb1d8527dea', '蜀壮', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u8700-u58ee: 蜀相壮
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1d8b21f1-d821-4cfb-90d3-c893336ba121', '3c50af45-c95f-438b-9044-ceb1d8527dea', '蜀相壮', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u871a-u5ec9: 蜚廉 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5e3d1437-4597-4611-be41-35af3bf16049', 'ad649f1e-d81d-44a1-9559-fd62042b1f81', '蜚廉', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8861-u7236: 衡父 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('88552321-768a-4d23-8ed2-bd520c579a0e', '0f10ccc8-fd79-4193-8c00-190d81bd8eff', '衡父', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8944-u738b: 襄王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('89afdca9-9adc-4088-b668-832c8cb77e73', 'ce5a2daf-8aa8-42a9-9c07-90d92f986b25', '襄王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u8944-u738b: 襄王郑
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7684efd6-b9c4-468f-8c6e-dff0608cf578', 'ce5a2daf-8aa8-42a9-9c07-90d92f986b25', '襄王郑', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u897f-u5468-u516c: 西周公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a19df813-9ee5-4eb0-bf55-d53d5c3d99a0', '7ee3e4c8-08c2-48b0-92aa-88e5fa070a6f', '西周公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u897f-u5468-u541b: 西周君 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f3a47ffd-7716-4170-9f12-6adb877ef7fe', '632d35ad-7c7f-4e32-b138-aafc458f0cee', '西周君', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8c2d-u4f2f: 谭伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b5633185-7c9d-4cf0-9b2f-ee1de8224f65', '655092c4-7033-4ed2-8108-89bb23d7dc96', '谭伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8d32: 贲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('70a80b43-31d6-497c-8637-a255731e66e2', '2e2350ed-a024-4012-a100-db597e75998a', '贲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u8d32: 五大夫贲
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('349e1b0a-b3b6-4bf1-a147-7c17eac594f6', '2e2350ed-a024-4012-a100-db597e75998a', '五大夫贲', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8d39-u4e2d: 费中 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('36acea36-248a-41d1-b41e-6c9fdbe0881f', '501f609e-c754-49f6-abcd-b9eb414fa1e3', '费中', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8d39-u4ef2: 费仲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f1824ef6-5b57-4bed-99f3-4dc8b76631a5', '77f70097-a549-4940-a71e-a959c1e2131d', '费仲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8d67-u738b: 延
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('df199ee1-d705-4ff8-8455-262cbe34a56c', 'dbbdeb41-047c-4810-93f0-708ecfebba85', '延', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u8d67-u738b: 王赧
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3c44c0b1-b434-4a33-ad93-18c08ebd4e3f', 'dbbdeb41-047c-4810-93f0-708ecfebba85', '王赧', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u8d67-u738b: 赧王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e070617c-3ee5-490f-828e-d7815d315fd2', 'dbbdeb41-047c-4810-93f0-708ecfebba85', '赧王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8d75-u6210-u4faf: 赵成侯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e34c2369-ab29-4558-aea5-1b5961774947', 'e512ae63-7f0d-42d6-8e21-d78ec0797777', '赵成侯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8d75-u6e34: 赵渴 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9c74505f-7707-4c59-aae6-03c70c710742', 'e2fe2c7b-7983-4706-93bd-80f452fa8b14', '赵渴', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u8d75-u6e34: 赵公子渴
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1c6c4428-f68f-4e86-a76e-445a1f2293d9', 'e2fe2c7b-7983-4706-93bd-80f452fa8b14', '赵公子渴', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8d75-u76fe: 赵盾 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b262e91a-7c2b-44fd-b667-8ddc1c3942de', '3f40b446-d2cf-452a-8e64-8499ed261b2d', '赵盾', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8d75-u7a7f: 赵穿 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d70f27b0-15f0-414a-919b-eaf2f54705f0', '5937a2a6-423a-46e7-8270-4a96f52f020e', '赵穿', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8d75-u8870: 赵衰 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('bce78ba6-a263-4059-8f03-70002797d454', 'be96a4a8-ccb9-44b4-9428-cf52f9fc76e4', '赵衰', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8d75-u9785: 赵鞅 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4398af54-8d59-414b-87d9-c4202bea7362', '4c2c0627-ad2d-43eb-bbf0-29e208b69e18', '赵鞅', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u8d75-u9785: 赵简子
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('87e070d2-1d75-4eba-9a2a-cdbc25f559d8', '4c2c0627-ad2d-43eb-bbf0-29e208b69e18', '赵简子', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8e81-u516c: 躁公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1052c0ba-bb54-469c-b893-bd9b8451164b', 'a07fbfa1-e498-4bf6-a3b2-b942f071463b', '躁公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8f9b-u4f2f: 辛伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c4c4e190-ad0a-4ca8-bdec-18a3f5b56f1c', 'c278ff99-bd0f-4b1f-bd72-ca7bd6c051fc', '辛伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8f9b-u7532: 辛甲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4112fc8b-f2b3-4e7c-9369-4ff488ccc12b', 'cfb53d56-8f54-49f7-baee-03a851a1c4bb', '辛甲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u8f9b-u7532: 辛甲大夫
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('de856ca0-d212-4c5d-995b-1ea1102d186e', 'cfb53d56-8f54-49f7-baee-03a851a1c4bb', '辛甲大夫', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8fb9-u4f2f: 边伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('11b77e26-4978-4ba7-bba7-2942827cf378', '2e72f058-5386-450d-b1ee-f11cdaf0017e', '边伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u8fde-u79f0: 连称 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('696224cd-c513-4401-a704-d78b0369c679', '7db35712-be8c-4122-875f-ed16dc60be05', '连称', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9020-u7236: 造父 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9dd0708b-b437-405c-8668-6dfa0016634c', '37ebea05-2c41-46fc-9a00-83096ad66179', '造父', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u90d1-u4f2f: 郑伯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0b4a216d-7432-4cd5-81c0-0b888c9847ef', '2e4c014c-3559-42c5-8565-c0494ea36940', '郑伯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u90d1-u5e84-u516c: 郑庄公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f43b85fd-0b0d-45e9-bc12-65f2a13a6d8c', '1b159872-8960-453d-bc80-c588766fb61f', '郑庄公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u90d1-u6587-u516c: 郑文公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('76667f50-8bf4-461b-9ea9-a01cad84dfe3', 'e2164b35-e993-49ca-af83-3e630080d674', '郑文公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u90d1-u662d-u516c: 郑昭公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('233eee12-b1e8-438a-93f2-827abca096c3', 'e7ed54b2-e72c-4fdb-b3de-f46fcf4390f1', '郑昭公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u90d1-u662d-u516c: 昭公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('99eb93c1-1917-48f1-ad00-18b8fa0228ff', 'e7ed54b2-e72c-4fdb-b3de-f46fcf4390f1', '昭公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u90e4-u82ae: 郤芮 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b94d59e3-a632-4884-a36b-e308d47085d3', '3ad49c32-6c8a-408d-a4bf-dc0439470ec2', '郤芮', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u90e4-u82ae: 郤
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2e271106-f388-4863-af88-eb0cec02b415', '3ad49c32-6c8a-408d-a4bf-dc0439470ec2', '郤', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u90e6-u5c71-u5973: 郦山女 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('07fdf17c-8473-41ab-9466-de0c68f8f173', 'e666ae5e-9e34-4ff6-8972-edf5536975e4', '郦山女', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u90e6-u5c71-u5973: 郦山之女
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c7d31ee1-f68d-4e63-991b-34a476e19494', 'e666ae5e-9e34-4ff6-8972-edf5536975e4', '郦山之女', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9102-u4faf: 鄂侯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0b2e3ce9-fc7d-432d-a63b-776117ad4a3b', 'ffa19925-910a-4a0e-b4b0-4bc79a4e1956', '鄂侯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u91cc-u514b: 里克 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('824e5e09-4f64-4e51-8f52-9312b70a5cc8', 'd3cfcc45-a7c6-4d38-a513-2048da313d8d', '里克', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u91cd-u8033: 重耳 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('daf4360e-dfc0-4e7b-90a9-466c24044f93', '6ed51c70-8cef-4cb7-ad4c-5f050a73011e', '重耳', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u91cd-u8033: 文公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('23d63e95-ecae-4295-8709-b6971da5897f', '6ed51c70-8cef-4cb7-ad4c-5f050a73011e', '文公', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u91cd-u8033: 晋公子重耳
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3a589e74-8a69-42ef-9bfd-56d9bec3e9cf', '6ed51c70-8cef-4cb7-ad4c-5f050a73011e', '晋公子重耳', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9488-u864e: 针虎 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0b0abe8d-7872-482c-aa26-c6ad47cf4c81', '7230a5de-6ffb-4e45-a40d-99c10180502f', '针虎', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9519: 错 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('00e6d05e-b144-475c-ad6d-df6b67730ad4', 'e088e560-2c73-4e9d-8b83-7cb14fe9feb1', '错', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9519: 左更错
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2819d13d-97a3-47ca-8de7-072c040586d7', 'e088e560-2c73-4e9d-8b83-7cb14fe9feb1', '左更错', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u95f3-u592d: 闳夭 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('89bebb9b-b778-4971-ac25-0bf7f4383d0f', '12f8f815-d9ac-46e6-ab39-d0ba778bd0d6', '闳夭', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9633-u7532: 阳甲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('26e579c4-5e5f-4d36-8632-d2cf58eea114', '0abe51f4-21b6-4c4f-9200-0bfc8996712c', '阳甲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9633-u7532: 帝阳甲
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c8d32919-1e16-4d14-b3b6-10f038f72acf', '0abe51f4-21b6-4c4f-9200-0bfc8996712c', '帝阳甲', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9675: 陵 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a736207c-dab3-4712-838d-04c94b210f6b', '270e019a-aa95-449f-9539-ac077f9ebab6', '陵', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9675: 五大夫陵
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('06afbb1d-6976-43a3-b477-318c98c99bc6', '270e019a-aa95-449f-9539-ac077f9ebab6', '五大夫陵', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u968f-u4f1a: 随会 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('490aabf5-953f-4632-ab06-5d2bc878175f', '902b7e5a-922f-40b8-9825-d26652e1bda7', '随会', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u968f-u4f1a: 会
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5ea5df34-208f-46a1-adab-1c1b86412702', '902b7e5a-922f-40b8-9825-d26652e1bda7', '会', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u96b0-u670b: 隰朋 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3a3789fa-f22f-4909-964a-bcda91665cd2', '90588659-57dc-4cb5-afe8-ccd2f82a14aa', '隰朋', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u96cd: 雍 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a6c33268-4b79-4cdc-a286-d96a8a4b0f38', '41527dc6-3aad-4e44-8ef9-4facaa939e51', '雍', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u96cd-u5df1: 雍己 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('652394b2-4bd8-4b9f-83bd-2bcbd57ab11a', 'bbb04292-6c55-4710-9599-7d2bc9773e00', '雍己', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u96cd-u5df1: 帝雍己
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a013bbd9-0781-4604-bc18-c4b395f9ccce', 'bbb04292-6c55-4710-9599-7d2bc9773e00', '帝雍己', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u96cd-u5eea: 雍廪 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1bfe4370-1fb1-41c9-b25b-564fa34575ac', 'cf170ae3-101e-4d71-a4ca-39b3a5c78d0b', '雍廪', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u97a0: 鞠 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ca9edfee-b4da-445e-a1e8-bc68a4ac1bbb', 'a7e8b909-90bc-4157-a20b-a5bc0f16dbc7', '鞠', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u97e9-u516c-u53d4: 韩公叔 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d43caf1b-e1bd-46ca-83ce-e1bb395c2bf7', 'a034027f-03b3-495d-ab6d-05945a12941f', '韩公叔', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u97e9-u516c-u5b50-u957f: 韩公子长 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1e211ca1-e95c-4a51-ad91-4dfb832fed6b', 'ad5e43e7-5290-418f-97d2-0c5e3f0711c4', '韩公子长', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u97e9-u54c0-u4faf: 韩哀侯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ae5f0b9f-a006-4153-9cf2-eaf1895c8e45', 'c6492ccb-c78c-4495-9cc6-f029903aee0c', '韩哀侯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u97e9-u54c0-u4faf: 韩哀
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7810f6f2-f73c-4e25-95ed-e6f011689380', 'c6492ccb-c78c-4495-9cc6-f029903aee0c', '韩哀', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u97e9-u5942: 韩奂 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('30d2ebaa-2192-4bda-af44-8bef689ff87b', '5bfa7691-7410-437d-ba49-0bb4c90b8b34', '韩奂', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u97e9-u5942: 韩太子奂
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a2281bef-5f81-4061-9ef5-8f57544e3eb2', '5bfa7691-7410-437d-ba49-0bb4c90b8b34', '韩太子奂', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u97e9-u738b: 韩王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fdfedd4e-7e92-4673-b6d5-52ce6d85dd19', '450ba16b-7216-4469-939f-7f65ee1abf45', '韩王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u97e9-u76f8-u56fd: 韩相国 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9f4ab2d1-8c8c-4f86-9672-8e23afdd05ba', '4496625d-0c60-4e14-8452-96ab0aadb88e', '韩相国', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u97e9-u8944-u738b: 韩襄王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('14a90587-b307-46ac-8ad7-175dbcea11a4', '9f54f781-57a4-46f0-a821-63a1223f138d', '韩襄王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9955-u992e: 饕餮 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1663d36c-bf8e-4153-916b-bdc50938c1ba', '0cc1ea00-0a98-4c3a-b7af-c021d69ac6aa', '饕餮', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9a69-u515c: 驩兜 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1c180734-f5e1-4d0d-935b-a0cbcde710c1', '73d7a713-158d-4b92-8de0-f130c267297e', '驩兜', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9a69-u515c: 欢兜
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('041da989-928c-4de9-8eb1-f04976adc451', '73d7a713-158d-4b92-8de0-f130c267297e', '欢兜', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9a6c-u72af: 马犯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('03326407-7125-4b27-8087-c65dc7942f35', '7b9d062d-5d9a-4726-886a-2e52a86e694c', '马犯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9a6c-u72af: 犯
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c899e228-b006-450b-a86c-9185c205f57d', '7b9d062d-5d9a-4726-886a-2e52a86e694c', '犯', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9a8a-u59ec: 骊姬 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('903cc921-ac13-42cf-885b-e5b2783be52d', 'cc611d13-d62d-408b-a453-1776b02f1ed4', '骊姬', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9ad8-u5709: 高圉 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1936e595-321c-495e-aa3f-fae675ff0e11', 'd99d0563-1e02-4ba5-a381-f64ca360dacc', '高圉', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9ad8-u6e20-u772f: 高渠眯 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ef846a45-3d23-4110-8d2e-965766bd5475', 'fa90aaa5-068c-45c4-8f48-84f82347333f', '高渠眯', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9b3b-u5b50: 鬻子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4616d4e1-a496-4d7c-bcf8-ebd6596335f1', '14f0cab1-808e-4a6d-b3e3-7c34fcaf3074', '鬻子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9b4f-u516c-u5b50-u52b2: 魏公子劲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0f32f8e9-3ef2-4b66-82d9-7aae7cd20852', '0d881f4f-1b42-4290-aa2a-b325bfebb653', '魏公子劲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9b4f-u60e0-u738b: 魏惠王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('91175024-0892-43d8-a4e4-017c0ef8b269', 'deb3f551-77be-40c0-8a66-f2a5e4a0d4d2', '魏惠王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9b4f-u60e0-u738b: 魏惠
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b782b4e9-bfd2-4fc2-a3ae-37b455549d03', 'deb3f551-77be-40c0-8a66-f2a5e4a0d4d2', '魏惠', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9b4f-u65e0-u5fcc: 魏无忌 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6ee52b3d-959f-4731-b4aa-70d15ef5d309', 'd092d1ff-c4c0-41e1-b574-0613537c83f7', '魏无忌', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9b4f-u65e0-u5fcc: 无忌
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7e2ce7ab-89ed-4d69-b97a-30c9ccece9a1', 'd092d1ff-c4c0-41e1-b574-0613537c83f7', '无忌', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9b4f-u7ae0: 魏章 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('bfb605ff-17a5-4899-9d81-fb28b2edd31f', '88ec113e-deae-49af-934c-084244520411', '魏章', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9b4f-u9519: 魏错 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('dbb1304c-29b5-4232-8b7d-e4a83c4bc5e8', '11f435c5-04e8-4524-91a9-08da9f88adeb', '魏错', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9b4f-u96e0-u9980: 魏雠馀 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a67fd6a1-db7f-47e4-bf9a-d5155dbc2f59', '3cdaa58a-89dc-4b3c-b244-d865c17dacea', '魏雠馀', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9c81-u59ec-u5b50: 鲁姬子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('10079e99-0d20-4aad-b12d-8a0bcc95fed7', '258e188d-6f5f-476b-9c79-1af70e8cfd84', '鲁姬子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9c81-u6853-u516c: 鲁桓公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('239fb40b-6bfa-453b-b753-d8670dc199a2', '8480eaa3-4a83-4c92-b8ec-2d28a02efd43', '鲁桓公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9c81-u6853-u516c: 桓公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6c467315-6791-4376-b06c-cc75b153f4ee', '8480eaa3-4a83-4c92-b8ec-2d28a02efd43', '桓公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9c81-u6b66-u516c: 鲁武公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('fc0af818-7d23-4858-b4a6-f379d5663dcb', '6e75b2d2-1bb4-4df6-90e9-9024adcb760d', '鲁武公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9c81-u9690-u516c: 鲁隐公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('bdc6cd59-03c6-466f-ac21-24a77680e0c2', 'eb23cc65-2371-46e1-9820-77982dfd5bb5', '鲁隐公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9c81-u9690-u516c: 隐公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2808dfa4-321a-4c27-a755-f6f9f5cbc8f9', 'eb23cc65-2371-46e1-9820-77982dfd5bb5', '隐公', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9f50-u5a01-u738b: 齐威王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a6c7899a-f714-4ec3-bd63-87e8298bf9c8', 'b19f6c72-8248-4d48-9c79-e9b69da2d01c', '齐威王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9f50-u5a01-u738b: 齐威
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0437e053-4309-4210-82ab-304074785910', 'b19f6c72-8248-4d48-9c79-e9b69da2d01c', '齐威', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9f50-u5e73-u516c: 齐平公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('970c223b-3a65-4e89-92af-2eec09de6844', '07cb4e6f-0bae-4d45-89a9-ea1ba0830da0', '齐平公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9f50-u5e73-u516c: 平公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8dc41d78-3670-468b-8e3e-e2a37d5bcd78', '07cb4e6f-0bae-4d45-89a9-ea1ba0830da0', '平公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9f50-u5e84-u516c: 齐庄公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('44fa52ab-cae7-48f6-bd06-8e216698e3fa', '87b297bf-7373-47fa-9a00-3dfc1e7baab7', '齐庄公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9f50-u5e84-u516c: 庄公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1787c87c-e82d-4c03-aaf3-7e19952661a3', '87b297bf-7373-47fa-9a00-3dfc1e7baab7', '庄公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9f50-u60bc-u516c: 齐悼公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d441be08-5ffc-4808-bd94-937eb05c59f4', '355801eb-85d0-45e4-ae73-8858c798dd46', '齐悼公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9f50-u60bc-u516c: 悼公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ec1afcfd-369c-469a-b1d7-1b9a428317a1', '355801eb-85d0-45e4-ae73-8858c798dd46', '悼公', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9f50-u60bc-u516c: 阳生
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('04f7ce7c-2f1c-45f0-979a-773a26f6f53c', '355801eb-85d0-45e4-ae73-8858c798dd46', '阳生', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9f50-u7b80-u516c: 齐简公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('71089ed0-cf02-4a2d-96b7-5af0083837c1', 'a51201ed-88f6-44c7-997e-27aa19e8e948', '齐简公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9f50-u7b80-u516c: 简公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('91cca178-4bd3-442d-a527-48cedec53d87', 'a51201ed-88f6-44c7-997e-27aa19e8e948', '简公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9f50-u8944-u516c: 齐襄公 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('da0690ea-fe35-4a92-82ce-6a2fd04089da', '3571f505-d3e0-4bc5-9782-d3e76f71f164', '齐襄公', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9f50-u8944-u516c: 襄公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5d4551b8-22aa-4cda-82e1-3f51ab70298f', '3571f505-d3e0-4bc5-9782-d3e76f71f164', '襄公', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9f99-u8d3e: 龙贾 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d1502a7e-02b8-4158-a08e-e8b6f8d0e13c', 'a175dd35-39bf-4629-bf0c-b7135c5bd21c', '龙贾', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for wei-ran: 魏冉 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0edc4ef9-3d3c-4c37-b043-0e05ee7b18b2', '672bcec6-d517-41fb-89db-6c3f57fac05b', '魏冉', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for wei-ran: 侯冉
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5f429267-d723-4e45-964f-0773120f4187', '672bcec6-d517-41fb-89db-6c3f57fac05b', '侯冉', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for wei-ran: 相穰侯
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('eb52b5fe-edb8-4f06-b2f2-2b74ab469aff', '672bcec6-d517-41fb-89db-6c3f57fac05b', '相穰侯', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for wei-ran: 穰侯
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e04ec031-8a06-4efc-b9bf-a686579790d3', '672bcec6-d517-41fb-89db-6c3f57fac05b', '穰侯', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for wei-ran: 穰侯魏冉
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f05b978f-7240-4cf3-9708-f1edb57e1e5e', '672bcec6-d517-41fb-89db-6c3f57fac05b', '穰侯魏冉', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for wei-yang: 卫鞅 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7a37efe4-ff7e-4535-aaf2-2ea999c816cc', '513377a3-bee4-43d4-9dc1-ab0086f277e0', '卫鞅', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for wei-zi-qi: 启
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('59dfe538-3fa5-48dc-942a-1a0a9be9e896', '89ce41bc-f9d2-4ebb-aa9c-de3e4e18abb0', '启', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for wei-zi-qi: 微子启
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('41d707b5-437a-4e1d-a971-34621ad5da97', '89ce41bc-f9d2-4ebb-aa9c-de3e4e18abb0', '微子启', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for wu-ding: 武丁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('94a67176-b08d-4597-a825-a3ef37ee05e2', '28626579-1c80-4789-b14b-7b9369885397', '武丁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for wu-ding: 帝武丁
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('55d8820b-fcb1-410e-8153-2c9a13d5c56c', '28626579-1c80-4789-b14b-7b9369885397', '帝武丁', NULL, 'temple', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for wu-ding: 高宗
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('36dd52c9-38da-482b-a803-6674111dbdc0', '28626579-1c80-4789-b14b-7b9369885397', '高宗', NULL, 'temple', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for wu-wang: 发
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c19fe7f5-8020-4689-a9d4-8c06bebd4632', '205b5203-ace4-49d9-80ec-c7c693f914e0', '发', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for wu-wang: 太子发
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0c1a2406-72f5-4b9a-9e83-38c14629cff8', '205b5203-ace4-49d9-80ec-c7c693f914e0', '太子发', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for wu-wang: 武王
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5bb1d5e0-1e86-4e11-8300-fe51ba5d8422', '205b5203-ace4-49d9-80ec-c7c693f914e0', '武王', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

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

-- Name for xi-qi-shu: 西乞术 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6663e783-50f9-48db-af31-b8f76038ea52', '993226cf-0558-4c85-91c5-17f06cb7bddb', '西乞术', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for xi-shu: 羲叔 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('13c81493-f3df-4048-900e-c0d2fd49bfcd', '64e7b89d-b0c6-4e8b-8d67-5ebde716b623', '羲叔', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for xi-zhong: 羲仲 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('39f628ba-aea4-4148-979c-31ea2878ab99', 'bd91336a-400f-43c8-a430-0835a9607aa7', '羲仲', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for xuan-xiao: 玄嚣 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8edb1c40-adac-4f65-bf13-1cc5f2e1d565', 'd946e274-3979-40b5-a01d-e044ff05660c', '玄嚣', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for xuan-xiao: 青阳
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('93ebbec1-9d0f-4696-98c2-617b90b2b9cf', 'd946e274-3979-40b5-a01d-e044ff05660c', '青阳', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for yan-di: 炎帝 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('944cd706-901c-4dce-b936-29e4886af6ec', '5f41c43c-db30-44c5-a6b0-3608b70e2438', '炎帝', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for yao: 尧 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ca8ac1e1-a8b3-4da8-bea1-5c5a5ef50ba6', '2da772b8-3c0b-4e13-9452-5e85ae34bf26', '尧', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yao: 帝尧
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8ea51ac9-1979-4ffe-8263-d9eaee4b69cb', '2da772b8-3c0b-4e13-9452-5e85ae34bf26', '帝尧', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yao: 帝尧之后
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3fd044ea-9258-49e9-a838-d47c27ac9050', '2da772b8-3c0b-4e13-9452-5e85ae34bf26', '帝尧之后', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yao: 放勋
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b0d91237-009e-434f-b2a4-f3db62aa6bd8', '2da772b8-3c0b-4e13-9452-5e85ae34bf26', '放勋', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yao: 陶唐
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('20b4eeff-393d-4f79-ba84-27a93a355cf3', '2da772b8-3c0b-4e13-9452-5e85ae34bf26', '陶唐', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for yi: 益 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('a124469b-fb47-44b8-bd88-3e72e51ea42e', 'ea880e29-01ac-40ed-b4f3-5f1f9da8814a', '益', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for yi-yin: 伊尹 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7fa30be1-c044-47cc-84bf-c29d0b415e9c', '02ee394b-9b9c-442c-ba7e-a8c7d2b1c05e', '伊尹', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yi-yin: 阿衡
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0420d97b-5018-433b-a3cf-8f4a75ef7c38', '02ee394b-9b9c-442c-ba7e-a8c7d2b1c05e', '阿衡', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for you-wang: 幽王 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('89dcfe00-c858-4f39-bb93-5f8fc46529d1', '56b3770d-997e-4d1f-92c2-d865e1114b42', '幽王', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for you-yu: 由余 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('3ff89f08-a763-42c3-9ff3-8aa6cc13697a', 'ba62fa14-e185-4bb4-9bf7-b4a1d4fb14b1', '由余', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

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
-- Name for yu: 大禹之后
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('35ac6128-3c5e-4bf0-a7b3-86698f551df6', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '大禹之后', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yu: 姒
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('80846d25-e83b-4722-b3b1-cfd0fd50c2ac', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '姒', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yu: 帝禹
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7f468473-b594-4140-bdb7-f11806cf914b', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '帝禹', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yu: 文命
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('31be7b4c-42cd-4d62-a77a-6f6191630fa2', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '文命', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for zhang-yi: 张仪 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4dc8bd12-3f35-401d-b256-218e14beba00', '103a5ee9-1a04-4c64-9820-8014c0b38d61', '张仪', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for zhao-gao: 赵高 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('dbe25c90-81f2-482c-adb3-a35fc500ff87', 'feb4aea2-e7c8-44d3-b2d2-c1f289f39192', '赵高', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for zhao-gong-shi: 召公奭 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f27c2bcf-3835-477a-8c1b-e7f9f7c4391c', 'd5d7e8d5-3fb8-4d06-a06f-dd3a79bbcf1c', '召公奭', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for zhong-kang: 中康 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('749694c1-2bc4-425e-b517-19d9b4ea78dc', '3dad64e2-c955-4d0f-b845-cdbc21ce84df', '中康', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhong-kang: 帝中康
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1d273d04-7a07-4d41-8cd4-cd9739f7da60', '3dad64e2-c955-4d0f-b845-cdbc21ce84df', '帝中康', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for zhou-xin: 辛 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1160cf2e-f323-44e8-9faa-72a7b4113a0a', '9d46a8fd-ae53-4b95-ace4-0892e92c94ec', '辛', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhou-xin: 商纣
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ed5042ed-6bf0-44ae-b172-592e6045bb9c', '9d46a8fd-ae53-4b95-ace4-0892e92c94ec', '商纣', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhou-xin: 季纣
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f0197800-58bc-4374-ab55-a8217cb26d74', '9d46a8fd-ae53-4b95-ace4-0892e92c94ec', '季纣', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhou-xin: 帝纣
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d12dcd0c-0276-4ddd-9d35-462cce831765', '9d46a8fd-ae53-4b95-ace4-0892e92c94ec', '帝纣', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhou-xin: 帝辛
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b7122206-f1cb-4e2a-a679-09779ed6b782', '9d46a8fd-ae53-4b95-ace4-0892e92c94ec', '帝辛', NULL, 'temple', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhou-xin: 殷王受
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c1aa0b86-2d99-4ed0-986b-b873d81c2ee3', '9d46a8fd-ae53-4b95-ace4-0892e92c94ec', '殷王受', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhou-xin: 殷王纣
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('03d0de53-2177-4f7c-81d4-d9f2b9986515', '9d46a8fd-ae53-4b95-ace4-0892e92c94ec', '殷王纣', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhou-xin: 殷纣
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b6dd9f92-3ddf-4bc9-842e-ed2c1ae7c67d', '9d46a8fd-ae53-4b95-ace4-0892e92c94ec', '殷纣', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhou-xin: 纣
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('30ac4c4b-daed-4e00-9b35-e0e396c328ab', '9d46a8fd-ae53-4b95-ace4-0892e92c94ec', '纣', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for zhuan-xu: 颛顼 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9974f033-d83d-43d0-a1f5-9aa46279db43', 'c26a5df8-35d3-4339-a520-c56f3fe26b11', '颛顼', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhuan-xu: 帝颛顼
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('94297d6f-c99c-4da3-b642-0ff59b741d6b', 'c26a5df8-35d3-4339-a520-c56f3fe26b11', '帝颛顼', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhuan-xu: 帝颛顼高阳
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f39eeafc-b0b2-4faa-b32a-938b93bfe92b', 'c26a5df8-35d3-4339-a520-c56f3fe26b11', '帝颛顼高阳', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhuan-xu: 颛顼氏
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('30c5ce05-eafd-4edd-97ca-1ad91b4bc456', 'c26a5df8-35d3-4339-a520-c56f3fe26b11', '颛顼氏', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhuan-xu: 高阳
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('60b65d0d-456b-40a8-9487-6b058bea3456', 'c26a5df8-35d3-4339-a520-c56f3fe26b11', '高阳', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for zhuan-xu: 高阳氏
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('6aa66522-d176-4af7-9713-72dfd3ed5f7d', 'c26a5df8-35d3-4339-a520-c56f3fe26b11', '高阳氏', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

COMMIT;
