-- HuaDian Pipeline Seed Dump
-- Generated: 2026-04-18T03:21:59.645104+00:00
-- Book ID: 3fa76810-d788-484d-8452-f10cea1d9ad3
-- Prompt: ner/v1
-- Model: claude-sonnet-4-6
-- Total cost: $0.5553
-- Persons: 84

BEGIN;

-- ============================================================
-- persons
-- ============================================================

-- Person: 伯夷 (bo-yi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ec440301-5a6f-4d5b-86bf-1f1dabcaf5ff', 'bo-yi', '{"zh-Hans": "伯夷"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与禹、皋陶同在帝舜朝前相语"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 昌仆 (chang-pu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b1a6ecae-5d13-476f-b8e5-3541b689921b', 'chang-pu', '{"zh-Hans": "昌仆"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "蜀山氏之女，昌意之妻，生高阳"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 常先 (chang-xian)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('5c131454-8f7e-4b63-8f0f-cf49c4ec6159', 'chang-xian', '{"zh-Hans": "常先"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被黄帝举用以治民的贤臣之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 昌意 (chang-yi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1c404625-59ff-47a9-a239-097e432ad822', 'chang-yi', '{"zh-Hans": "昌意"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "颛顼之父，黄帝之子，禹之曾大父，未得帝位为人臣"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蚩尤 (chi-you)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('abf65a85-0faf-4ad3-a3dc-c7d04e5aceda', 'chi-you', '{"zh-Hans": "蚩尤"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "最为暴虐，作乱不从帝命，被黄帝率师擒杀于涿鹿之野"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 倕 (chui)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2595b9c9-b30f-4701-a553-a1d2a83895e4', 'chui', '{"zh-Hans": "倕"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "自尧时举用，列于群臣之中"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 大鸿 (da-hong)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1d6cd4d4-e9c8-4d14-8d48-cc4c5714e87d', 'da-hong', '{"zh-Hans": "大鸿"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被黄帝举用以治民的贤臣之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 丹朱 (dan-zhu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('46add4d2-e583-449a-8ad4-2732b43b9618', 'dan-zhu', '{"zh-Hans": "丹朱"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被帝告诫禹勿效仿其傲慢放纵之行"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝喾 (di-ku)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('fa14f49f-8dbc-4f3f-a04c-b67df9a5b4e7', 'di-ku', '{"zh-Hans": "帝喾"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "玄嚣之孙，颛顼崩后继位，是为帝喾 黄帝曾孙，颛顼族子，继位为帝 生而神灵，仁威兼备，执中治天下，日月所照莫不从服 娶陈锋氏女生放勋，娶娵訾氏女生挚，崩后由挚继位 有才子八人称''八元''，世代传承其美名 国号高辛，五帝之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 放齐 (fang-qi)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9f8e4f38-6c25-47a6-9a2b-72fb9f068f64', 'fang-qi', '{"zh-Hans": "放齐"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "向尧举荐嗣子丹朱，被尧否定"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 风后 (feng-hou)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('981f922d-5697-4b1b-b427-e8f66bd8de9d', 'feng-hou', '{"zh-Hans": "风后"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被黄帝举用以治民的贤臣之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 皋陶 (gao-yao)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('041aef60-51bd-4509-88b2-d41969f80805', 'gao-yao', '{"zh-Hans": "皋陶"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "禹拜谢时谦让的对象之一 作士理民，在帝舜朝与禹、伯夷论道，陈述九德之谋 质问禹何谓孳孳，听完禹的陈述后称赞其功绩 敬重禹之德，令民效法禹，不从者以刑惩之 拜手稽首，歌颂元首股肱，劝诫慎法敬事 被禹举荐并授政，后卒，其后裔被封于英、六"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

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
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('709a5ab7-7bb3-4091-a80f-d209caaf5a48', 'hou-ji', '{"zh-Hans": "后稷"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "禹拜谢时谦让的对象之一 与禹同奉帝命，受命向众庶分发难得之食以救饥荒 与禹共同为众庶提供难得之食，调剂余缺"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 黄帝 (huang-di)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3197e202-55e0-4eca-aa91-098d9de33bc9', 'huang-di', '{"zh-Hans": "黄帝"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "禹之高祖，昌意之父，上古帝王"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 蟜极 (jiao-ji)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6dc49a58-ae29-4938-92bf-15cc8fb705a2', 'jiao-ji', '{"zh-Hans": "蟜极"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝喾之父，玄嚣之子，未得在位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 桀 (jie)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('48cdbfcf-f96b-4623-b5b4-1de19f342fd5', 'jie', '{"zh-Hans": "桀"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "夏末暴君，不务德伤百姓，囚汤后释之，终被汤伐，走鸣条而死"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 敬康 (jing-kang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('1a2a3fba-061f-4bf4-adba-4bd3eb16a861', 'jing-kang', '{"zh-Hans": "敬康"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "句望之父，穷蝉之子"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

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
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('f1a7e4d2-41fa-400c-881b-dfb4919e8200', 'shun', '{"zh-Hans": "舜"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被尧擢用摄行天子之政，诛鲧于羽山，举禹续治水之业 尧崩后问四岳可用之人，命禹平水土 赐禹玄圭，宣告天下治平之功 在其朝堂之上，禹、伯夷、皋陶相与论道 命禹发表意见，引出禹陈述治水功绩 与禹对话，阐述用臣辅政、观象听音、纳谏去谗之道 告诫禹勿效丹朱之傲慢，并称赞禹之功德 德行大明，为段落背景中的在位帝王 作歌赞颂股肱百工，拜谢皋陶之言，命群臣往敬其职 荐禹为嗣，在位十七年后崩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 太康 (tai-kang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7a21bebe-cb2f-470f-a9a4-7d54876e51e4', 'tai-kang', '{"zh-Hans": "太康"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "启之子，继位后失国，其昆弟五人作五子之歌 崩后由弟中康继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 汤 (tang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('578b71f6-e9aa-4fc3-b8c8-1a7c20a3c910', 'tang', '{"zh-Hans": "汤"}'::jsonb, '商', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "修德得诸侯归附，伐夏桀后践天子位，建立商朝"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 伯益 (u4f2f-u76ca)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('6743e16f-5146-471f-9ed7-632497774605', 'u4f2f-u76ca', '{"zh-Hans": "伯益"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "与禹同奉帝命，受命向众庶分发稻种以种卑湿之地 与禹共同为众庶提供稻鲜食物"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 司马迁 (u53f8-u9a6c-u8fc1)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('7128aa48-c9a1-43a1-a338-383370cd01c2', 'u53f8-u9a6c-u8fc1', '{"zh-Hans": "司马迁"}'::jsonb, '西汉', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "作者自述治学经历，论述五帝记载之难考与著本纪之由"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 和氏 (u548c-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c67494ce-eac5-4524-a8d2-0a8c03d24373', 'u548c-u6c0f', '{"zh-Hans": "和氏"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受命敬顺昊天，数法日月星辰，敬授民时"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 垂 (u5782)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ca247afa-919a-4095-b681-3847685cd8ce', 'u5782', '{"zh-Hans": "垂"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被举荐为共工，掌百工之事 主掌工师，百工皆能尽职致功"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 姒氏 (u59d2-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('16e09751-1795-4a4b-a0cf-4b5cb8409004', 'u59d2-u6c0f', '{"zh-Hans": "姒氏"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "禹所姓之氏，即夏后氏之姓"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 孔子 (u5b54-u5b50)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('a387e3b7-5ae1-4869-84ef-6d4f6cb61947', 'u5b54-u5b50', '{"zh-Hans": "孔子"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "校正夏时，学者多传其所传夏小正"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 宰予 (u5bb0-u4e88)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b8ce9615-c7fc-45c9-b5fc-269100b37710', 'u5bb0-u4e88', '{"zh-Hans": "宰予"}'::jsonb, '春秋', 'historical', 'ai_inferred', NULL, NULL, '{"zh-Hans": "向孔子问五帝德及帝系姓，其问答被孔子所传"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 少暤氏 (u5c11-u66a4-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2e9ab3c3-7bc7-48e3-a700-47b237c5eb37', 'u5c11-u66a4-u6c0f', '{"zh-Hans": "少暤氏"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "其不才子被天下称为穷奇，为四凶之一的来源氏族首领"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝不降 (u5e1d-u4e0d-u964d)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0e30735f-6d22-4574-9920-171bce1eae14', 'u5e1d-u4e0d-u964d', '{"zh-Hans": "帝不降"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝泄之子，夏代帝王，崩后弟帝扃继位，其子孔甲后亦立为帝"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝予 (u5e1d-u4e88)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('2c0c3aa9-3803-4e09-a7cd-be98306e5d34', 'u5e1d-u4e88', '{"zh-Hans": "帝予"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "少康之子，夏代帝王，崩后由子帝槐继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝发 (u5e1d-u53d1)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('9d04cdda-0f60-4073-ae80-44b6311c49b8', 'u5e1d-u53d1', '{"zh-Hans": "帝发"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝皋之子，继位后崩"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 帝廑 (u5e1d-u5ed1)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b1a062a0-1dc2-42f7-b8e9-c67496f6bac2', 'u5e1d-u5ed1', '{"zh-Hans": "帝廑"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝扃之子，夏代帝王，崩后立帝不降之子孔甲"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

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

-- Person: 帝鸿氏 (u5e1d-u9e3f-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('19ef3926-eaf1-42e1-ba4b-f0fc4b9de9dd', 'u5e1d-u9e3f-u6c0f', '{"zh-Hans": "帝鸿氏"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "其不才子被天下称为浑沌，为四凶之一的来源氏族首领"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 弃 (u5f03)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b33d8c16-006e-46e1-8b34-a1981663ddbc', 'u5f03', '{"zh-Hans": "弃"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "主掌农稷，使百谷按时茂盛 周之始祖，姓姬氏"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 朱虎 (u6731-u864e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c02c2701-7bab-4e22-9437-39e2ccb0ce90', 'u6731-u864e', '{"zh-Hans": "朱虎"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "益让位于他，被任为虞之佐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 梼杌 (u68bc-u674c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('673368d9-1523-4a7b-a105-2c7ed6367318', 'u68bc-u674c', '{"zh-Hans": "梼杌"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "颛顼氏之不才子，不可教训、不知话言，被天下称为梼杌"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 浑沌 (u6d51-u6c8c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('8f15868e-a5b6-4003-ab74-87a8df633206', 'u6d51-u6c8c', '{"zh-Hans": "浑沌"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "帝鸿氏之不才子，掩义隐贼、好行凶慝，被天下称为浑沌"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 涂山氏 (u6d82-u5c71-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0aff7cb5-0ffd-4097-a2d0-9539c44856d6', 'u6d82-u5c71-u6c0f', '{"zh-Hans": "涂山氏"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "禹之妻，生启 涂山氏之女，禹之妻，启之母"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 熊罴 (u718a-u7f74)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('e15a3a4b-5cae-4015-9a11-01d6f39e98f8', 'u718a-u7f74', '{"zh-Hans": "熊罴"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "益让位于他，被任为虞之佐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 穷奇 (u7a77-u5947)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('923f754d-2767-4698-9ef6-4c2b0f9701fc', 'u7a77-u5947', '{"zh-Hans": "穷奇"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "少暤氏之不才子，毁信恶忠、崇饰恶言，被天下称为穷奇"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 缙云氏 (u7f19-u4e91-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('ae47eddd-804b-4715-974a-d1eb99a19509', 'u7f19-u4e91-u6c0f', '{"zh-Hans": "缙云氏"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "其不才子被天下称为饕餮，为四凶之一的来源氏族首领"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 羲氏 (u7fb2-u6c0f)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('411ee7c8-a7fe-4f0b-8018-d1e63b0440bf', 'u7fb2-u6c0f', '{"zh-Hans": "羲氏"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "受命敬顺昊天，数法日月星辰，敬授民时"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 胤 (u80e4)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('bcc268f7-cdb8-45f6-bc1c-b713335c158a', 'u80e4', '{"zh-Hans": "胤"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "奉命征讨湎淫废时的羲、和，作《胤征》"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 荤粥 (u8364-u7ca5)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('b40287a2-64ed-4bc3-83bf-3f51a8e1a48f', 'u8364-u7ca5', '{"zh-Hans": "荤粥"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "北方部族，被黄帝北逐"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 饕餮 (u9955-u992e)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0cc1ea00-0a98-4c3a-b7af-c021d69ac6aa', 'u9955-u992e', '{"zh-Hans": "饕餮"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "缙云氏之不才子，贪于饮食、冒于货贿，被天下称为饕餮"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 驩兜 (u9a69-u515c)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('73d7a713-158d-4b92-8de0-f130c267297e', 'u9a69-u515c', '{"zh-Hans": "驩兜"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "被禹举为知人能惠则无需忧虑之反面例证"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 象 (xiang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('0cdfa4af-4767-484f-a678-426a035a781c', 'xiang', '{"zh-Hans": "象"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "瞽叟与后妻所生之子，性格傲慢，为舜之弟 舜之弟，傲慢，与父母同谋欲杀舜 舜之弟，与瞽叟共谋害舜，以为舜死后占其宫室琴妻 舜之弟，被舜封为诸侯"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 契 (xie)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('10ccab31-8acf-4d89-9e85-accc4eda7787', 'xie', '{"zh-Hans": "契"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "禹拜谢时谦让的对象之一"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

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

-- Person: 禹 (yu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('95638bf0-ec39-42c0-a74b-f101d1d22f58', 'yu', '{"zh-Hans": "禹"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "名文命，黄帝玄孙、颛顼之孙，父鲧皆为人臣 鲧之子，被舜举用以续鲧治水之业 被四岳举荐为司空，受舜命平水土，谦让于契、后稷、皋陶 品德仁信、勤勉有度，为天下纲纪 奉帝命治水，劳身焦思十三年，过家门不入，开九州通九道 自冀州始治水，疏导壶口、太原、衡漳等地 治水功成，受帝赐玄圭，天下太平 与皋陶对话，赞美其言并论知人安民之道 陈述治水经过，乘车舟橇檋行山泽，与益、稷共同安定民众 向帝进言，劝帝慎位辅德，并回应帝的施政之道 娶涂山氏，治水成功，辅成五服，请帝关注三苗之顽 德行被皋陶推崇，令民效法 天下皆宗其明度数声乐，为山川神主 被舜荐于天为嗣，丧毕后即天子位，建国号夏后，姓姒氏 即位后举荐皋陶并授政，皋陶卒后又举益任政 东巡至会稽而崩，以天下授益 启之父，夏朝开创者 姒姓之祖，会诸侯于江南，计功后崩葬会稽"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 中康 (zhong-kang)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('3dad64e2-c955-4d0f-b845-cdbc21ce84df', 'zhong-kang', '{"zh-Hans": "中康"}'::jsonb, '夏', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "太康之弟，太康崩后继位为帝 夏代帝王，崩后由子帝相继位"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- Person: 颛顼 (zhuan-xu)
INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, birth_date, death_date, biography) VALUES ('c26a5df8-35d3-4339-a520-c56f3fe26b11', 'zhuan-xu', '{"zh-Hans": "颛顼"}'::jsonb, '上古', 'legendary', 'ai_inferred', NULL, NULL, '{"zh-Hans": "鲧之父，昌意之子，黄帝之孙，禹之祖父"}'::jsonb) ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- person_names
-- ============================================================

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

-- Name for chi-you: 蚩尤 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d29a77b3-1c6a-4ac4-a010-b2b00b4d18e2', 'abf65a85-0faf-4ad3-a3dc-c7d04e5aceda', '蚩尤', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for chui: 倕 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('c2a57fce-73a0-404e-a72c-777d533ba24e', '2595b9c9-b30f-4701-a553-a1d2a83895e4', '倕', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for da-hong: 大鸿 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('f5bc7c83-5c86-4590-a654-7760c8dc2048', '1d6cd4d4-e9c8-4d14-8d48-cc4c5714e87d', '大鸿', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

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

-- Name for jiao-ji: 蟜极 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('b99a0a8a-32e1-4d61-9a2a-b1a6c432870a', '6dc49a58-ae29-4938-92bf-15cc8fb705a2', '蟜极', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for jie: 桀 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('122360d4-926b-4315-8b96-c3d8ebfc2d67', '48cdbfcf-f96b-4623-b5b4-1de19f342fd5', '桀', NULL, 'posthumous', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for jie: 夏桀
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('d83c9869-14ba-460c-81d2-33c1fa31d0e0', '48cdbfcf-f96b-4623-b5b4-1de19f342fd5', '夏桀', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for jie: 帝履癸
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('efc1973d-8ecd-4a0c-82b0-b1ae19b80ca8', '48cdbfcf-f96b-4623-b5b4-1de19f342fd5', '帝履癸', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for jie: 帝桀
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('2e806db0-3e91-4d7e-90d9-a20225ff0110', '48cdbfcf-f96b-4623-b5b4-1de19f342fd5', '帝桀', NULL, 'posthumous', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for jing-kang: 敬康 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1695d959-109f-4f79-8fd3-1e0403722c2a', '1a2a3fba-061f-4bf4-adba-4bd3eb16a861', '敬康', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

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

-- Name for tai-kang: 太康 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('65fca07d-866f-4a4e-8378-ae070ae841dc', '7a21bebe-cb2f-470f-a9a4-7d54876e51e4', '太康', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for tai-kang: 帝太康
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7f5805ef-0415-4b5a-bbaf-d585a6dc2ab4', '7a21bebe-cb2f-470f-a9a4-7d54876e51e4', '帝太康', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for tang: 汤 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('34729f89-cecf-45fa-a744-ee8426224cfa', '578b71f6-e9aa-4fc3-b8c8-1a7c20a3c910', '汤', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u4f2f-u76ca: 伯益 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('cff1c8b7-d67b-4d59-b866-05ed50be40e7', '6743e16f-5146-471f-9ed7-632497774605', '伯益', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u4f2f-u76ca: 益
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('093c3fd0-3bdc-481e-b38d-b1b664a2790b', '6743e16f-5146-471f-9ed7-632497774605', '益', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u53f8-u9a6c-u8fc1: 司马迁 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('20069722-92f6-4a89-983c-663d668c19cf', '7128aa48-c9a1-43a1-a338-383370cd01c2', '司马迁', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u53f8-u9a6c-u8fc1: 太史公
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('5fc91b9e-4bf3-46d8-8822-e205f7ee15d0', '7128aa48-c9a1-43a1-a338-383370cd01c2', '太史公', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u548c-u6c0f: 和氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('9c6b7498-5cb8-42b6-bb0e-494f3d0fd008', 'c67494ce-eac5-4524-a8d2-0a8c03d24373', '和氏', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u548c-u6c0f: 和
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('dc631a15-9897-44c1-a046-a6e67d66c262', 'c67494ce-eac5-4524-a8d2-0a8c03d24373', '和', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5782: 垂 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('e8174766-06d4-4ee9-9943-9cf0547703b1', 'ca247afa-919a-4095-b681-3847685cd8ce', '垂', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u59d2-u6c0f: 姒氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('76dfc387-1890-4689-99fd-8aa8b9f3d0d4', '16e09751-1795-4a4b-a0cf-4b5cb8409004', '姒氏', NULL, 'alias', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5b54-u5b50: 孔子 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8c3e118d-4975-4d84-b619-7895dd9895ff', 'a387e3b7-5ae1-4869-84ef-6d4f6cb61947', '孔子', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5bb0-u4e88: 宰予 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0e24f4e8-851d-4611-8261-9cc4ad490c5e', 'b8ce9615-c7fc-45c9-b5fc-269100b37710', '宰予', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5c11-u66a4-u6c0f: 少暤氏 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('626f7492-26cc-4246-9c49-50e36aa7f721', '2e9ab3c3-7bc7-48e3-a700-47b237c5eb37', '少暤氏', NULL, 'alias', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u4e0d-u964d: 帝不降 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('85c608d5-0199-422e-b600-dd94629a8b46', '0e30735f-6d22-4574-9920-171bce1eae14', '帝不降', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u4e88: 帝予 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('8efb2d59-83a1-4876-82eb-8cf4330183e1', '2c0c3aa9-3803-4e09-a7cd-be98306e5d34', '帝予', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u53d1: 帝发 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('97cbb36e-1ce8-41ab-96bd-34b15394df06', '9d04cdda-0f60-4073-ae80-44b6311c49b8', '帝发', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u5ed1: 帝廑 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('45ffc3dd-7703-4715-bb77-588d2e59ded4', 'b1a062a0-1dc2-42f7-b8e9-c67496f6bac2', '帝廑', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u6243: 帝扃 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1025ae21-2252-4a40-a756-82d1a5b41b26', '31c34676-b8ea-492f-a8ce-7650e8363e5e', '帝扃', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u631a: 帝挚 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('503c6f30-828e-4739-9d90-a7988849c08f', 'a8d7695f-c9a6-42a6-a01f-527daeb3f191', '帝挚', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u5e1d-u631a: 挚
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('02987f1e-ed2c-48dc-a68d-5b3c8d4ca485', 'a8d7695f-c9a6-42a6-a01f-527daeb3f191', '挚', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u69d0: 帝槐 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('7c09cd7d-46a6-49ec-95fa-109339f9dad1', 'd2a6fcfa-ce08-4400-9797-6f10a99e4963', '帝槐', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u5e1d-u6cc4: 帝泄 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('0a7cfed8-a023-45b4-9fa5-c76194d41c97', '2cca90ac-fc2b-470d-857d-1e61641276ac', '帝泄', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

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

-- Name for u6731-u864e: 朱虎 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('4eac7b74-c0c4-49a9-b0e5-5b6d526c2f33', 'c02c2701-7bab-4e22-9437-39e2ccb0ce90', '朱虎', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u68bc-u674c: 梼杌 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('79d04c03-be27-4c0b-98a5-9d08abaed7b8', '673368d9-1523-4a7b-a105-2c7ed6367318', '梼杌', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

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

-- Name for u7a77-u5947: 穷奇 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('281c6d5f-4416-44a0-b1ab-d3a934789d5e', '923f754d-2767-4698-9ef6-4c2b0f9701fc', '穷奇', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

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

-- Name for u9955-u992e: 饕餮 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1663d36c-bf8e-4153-916b-bdc50938c1ba', '0cc1ea00-0a98-4c3a-b7af-c021d69ac6aa', '饕餮', NULL, 'nickname', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for u9a69-u515c: 驩兜 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('1c180734-f5e1-4d0d-935b-a0cbcde710c1', '73d7a713-158d-4b92-8de0-f130c267297e', '驩兜', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for u9a69-u515c: 欢兜
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('041da989-928c-4de9-8eb1-f04976adc451', '73d7a713-158d-4b92-8de0-f130c267297e', '欢兜', NULL, 'primary', false, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for xiang: 象 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('ad336f35-7e2d-4c08-aadb-79d79985f7d5', '0cdfa4af-4767-484f-a678-426a035a781c', '象', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

-- Name for xie: 契 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('bca03024-b706-41eb-9b97-9ce6cf299b93', '10ccab31-8acf-4d89-9e85-accc4eda7787', '契', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;

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

-- Name for yu: 禹 [primary]
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('750fb490-b34d-4481-a77f-24bd6024582f', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '禹', NULL, 'primary', true, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yu: 伯禹
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('aa8a7a3b-7741-4481-9f53-c19e06677921', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '伯禹', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yu: 夏后
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('90cc77e2-14d7-461f-9ede-b3f35bc16ae1', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '夏后', NULL, 'alias', false, NULL, NULL) ON CONFLICT DO NOTHING;
-- Name for yu: 夏禹
INSERT INTO person_names (id, person_id, name, name_pinyin, name_type, is_primary, start_year, end_year) VALUES ('73992d0a-e4db-4e18-9a03-609d0be19f1b', '95638bf0-ec39-42c0-a74b-f101d1d22f58', '夏禹', NULL, 'nickname', false, NULL, NULL) ON CONFLICT DO NOTHING;
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
