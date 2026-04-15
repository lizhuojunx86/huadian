# 06 TraceGuard 集成方案

> **TraceGuard** 定位：多 agent LLM 管线的**自愈式质量保障框架**。
> 它在管线步骤间插入轻量 checkpoint，自动验证输出、评估质量、触发纠正动作，把"盲目的 agent 链"变成"自监控系统"。
>
> 在华典智谱中，TraceGuard 被确立为**管线 QA 运行时底座**（一等公民组件），而非可选审计工具。

---

## 一、为什么必须用

华典智谱的数据管线是典型的"多 agent 链式 LLM 管线"：

```
RawText → NER → Relations → Events → Disambiguation → Geocoding → QC → DB
                 ↑            ↑          ↑              ↑
            每一步都是 LLM 调用，每一步都可能产生劣质结果
```

没有 TraceGuard：
- NER 返回错的实体 → Relations 基于错的实体抽关系 → Events 又基于错的关系 → 错误级联放大
- 要到 QC 阶段才能发现 → 回溯到哪一步出错代价高
- Prompt 改版后旧数据不知道哪里受影响

有 TraceGuard：
- 每一步 LLM 调用后插入 checkpoint 验证
- 不合格立即降级 / 重试 / 送人工 → 错误不跨步
- Checkpoint 结果持久化 → prompt 迭代可回放对比
- Agent 交接物自动校验格式与合约

---

## 二、集成位置（四处）

### 2.1 【核心】Pipeline Step Checkpoints

每个管线步骤后强制插入 TraceGuard checkpoint：

```python
# services/pipeline/src/extraction/ner.py

from traceguard import Checkpoint, CheckResult

@Checkpoint(
    name="ner_output_v1",
    rules=[
        "json_schema:schemas/ner_output.json",
        "entity_surface_in_source",   # 自定义：抽取的 surface_text 必须在原文中
        "confidence_threshold:0.5",    # 置信度阈值
    ],
    on_fail="retry:2 then human_queue"
)
async def extract_ner(paragraph: RawText, prompt_version: str) -> NERResult:
    response = await llm_gateway.call(
        prompt_id="ner",
        version=prompt_version,
        input=paragraph.raw_text,
    )
    return NERResult.model_validate(response)
```

失败处理策略：
- `retry:N` — 重试 N 次（指数退避）
- `degrade:simpler_prompt` — 切换到更简单的 prompt
- `degrade:smaller_model` — 降级到 Haiku
- `human_queue` — 进人工复核队列
- `flag_and_continue` — 打标签但继续（用于非关键步骤）

### 2.2 Agent Handoff Validation

多角色 agent 之间的交接物校验：

```python
# services/pipeline/src/agents/historian_review.py

@Checkpoint(
    name="historian_to_pipeline_handoff",
    rules=[
        "json_schema:schemas/historian_decision.json",
        "all_referenced_entities_exist_or_new",
        "no_contradiction_with_existing_rules",
    ],
    on_fail="reject_and_notify:historian"
)
async def receive_historian_decision(decision: HistorianDecision) -> None:
    # 把历史专家的决策写入字典 / 规则库
    ...
```

### 2.3 LLM Gateway 层

所有 LLM 调用统一经 TraceGuard wrap：

```python
# services/pipeline/src/ai/gateway.py

class LLMGateway:
    async def call(self, prompt_id, version, input, model="claude-sonnet-4-6"):
        # 1. 缓存查询
        cache_key = hash((prompt_id, version, input, model))
        if cached := await self.cache.get(cache_key):
            return cached

        # 2. TraceGuard 入口钩子
        ckpt_id = await traceguard.begin_checkpoint(
            name=f"llm_call/{prompt_id}",
            meta={"version": version, "model": model}
        )

        # 3. 实际调用
        try:
            response = await self.anthropic.messages.create(...)
            # 4. TraceGuard 校验
            ckpt_result = await traceguard.end_checkpoint(
                ckpt_id,
                output=response,
                validators=self.validators_for(prompt_id)
            )

            # 5. 写入 llm_calls 表
            await self.db.insert_llm_call(
                prompt_id=prompt_id, version=version,
                prompt_hash=cache_key.prompt_hash,
                input_hash=cache_key.input_hash,
                response=response,
                traceguard_checkpoint_id=ckpt_id,
                status=ckpt_result.status,
            )

            if not ckpt_result.passed:
                return await self.handle_failure(ckpt_result)
            return response
        except Exception as e:
            await traceguard.fail_checkpoint(ckpt_id, error=str(e))
            raise
```

### 2.4 API Response Contract Validation

GraphQL resolver 返回前做最后一道校验（关键路径）：

```typescript
// services/api/src/resolvers/person.ts

import { checkpoint } from '@huadian/traceguard-node';

export const personResolver = async (_, { id }, ctx) => {
  const person = await ctx.db.person.findById(id);

  const result = await checkpoint({
    name: 'person_response_v1',
    rules: [
      'has_slug',
      'has_provenance_tier',
      'all_user_facing_fields_have_zh_hans',
      'evidence_ids_not_empty',
    ],
    payload: person,
    onFail: 'log_and_return'   // API 层通常不阻断，只日志
  });

  return person;
};
```

---

## 三、TraceGuard 规则库（华典智谱专用）

所有自定义规则放在 `services/pipeline/src/qc/traceguard_rules/`：

```
traceguard_rules/
├── entities/
│   ├── entity_surface_in_source.py        # 实体 surface_text 必须在原文中
│   ├── no_duplicate_entities.py           # 同次抽取内不重复
│   ├── confidence_threshold.py
│   └── dynasty_consistency.py             # 朝代与时间一致
├── relations/
│   ├── direction_semantic_valid.py        # 关系方向与类型语义一致
│   ├── time_range_valid.py
│   └── participants_exist.py
├── events/
│   ├── causality_no_cycle.py              # 因果链无环
│   ├── account_diversity_check.py
│   └── participants_alive_at_event.py     # 参与者在事件时间点活着
├── handoffs/
│   ├── historian_decision_schema.py
│   ├── pm_prd_completeness.py
│   └── designer_prototype_ready.py
└── common/
    ├── json_schema_validator.py
    ├── multilingual_field_check.py
    └── provenance_tier_valid.py
```

每条规则：
- 独立 Python 模块（可测试）
- 有 unit test（`tests/rules/*`）
- 有性能上限（< 50ms 每次校验）
- 可组合（`rules: [A, B, C]`）

---

## 四、数据关联

TraceGuard 的 checkpoint 结果必须与华典智谱的数据表关联：

```sql
-- llm_calls.traceguard_checkpoint_id 已在 docs/02 定义
ALTER TABLE llm_calls
  ADD COLUMN traceguard_checkpoint_id TEXT;

-- pipeline_runs 增加 checkpoint 聚合
ALTER TABLE pipeline_runs
  ADD COLUMN checkpoints_passed INTEGER DEFAULT 0,
  ADD COLUMN checkpoints_failed INTEGER DEFAULT 0,
  ADD COLUMN checkpoint_ids TEXT[];

-- feedback 关联 checkpoint
ALTER TABLE feedback
  ADD COLUMN related_checkpoint_ids TEXT[];
```

当用户"存疑"时，追溯链路：
```
feedback.id
  → feedback.evidence_id
    → source_evidences.llm_call_id
      → llm_calls.traceguard_checkpoint_id
        → TraceGuard 存储（prompt / input / output / rules / result）
```

---

## 五、仓库组织

TraceGuard 本身有独立仓库（`/Users/lizhuojun/Desktop/APP/traceguard`）。华典智谱按以下方式集成：

**选项 A（推荐）**：TraceGuard 发布为 Python 包 / Node 包
```yaml
# services/pipeline/pyproject.toml
dependencies:
  traceguard = "^1.0.0"

# services/api/package.json
"dependencies": {
  "@huadian/traceguard-node": "^1.0.0"
}
```

**选项 B**：TraceGuard 作为 git submodule
```
huadian/
└── vendor/
    └── traceguard/      # git submodule
```

**选项 C**：独立服务 + REST/gRPC
```yaml
docker-compose.yml:
  traceguard:
    image: traceguard:latest
    ports: [9090:9090]
```

**我建议**：MVP 阶段先用 A（Python / Node 包直接集成，速度快），Phase 3 商业化时评估切到 C（独立服务，便于多租户）。

最终选型由 TraceGuard 作者（用户）+ 架构师联合决定，通过 ADR-TG-001 确定。

---

## 六、配置与环境

```yaml
# .env.example
TRACEGUARD_ENABLED=true
TRACEGUARD_MODE=enforce        # enforce / observe / off
TRACEGUARD_STORAGE=postgres     # postgres / sqlite / file
TRACEGUARD_PG_SCHEMA=traceguard
TRACEGUARD_RULE_DIR=./services/pipeline/src/qc/traceguard_rules
TRACEGUARD_DEFAULT_ON_FAIL=retry:2 then human_queue
TRACEGUARD_SAMPLING=1.0         # 1.0 = 全量校验；0.1 = 抽样
```

不同环境策略：
- `dev`: `observe`（记录不阻断，便于调试）
- `staging`: `enforce` + `sampling=1.0`
- `prod`: `enforce` + `sampling=1.0`（数据质量优先）
- `batch_backfill`: `enforce`（回补历史数据时必须全量）

---

## 七、反馈驱动的规则演化

用户反馈是 TraceGuard 规则库演化的最佳输入：

```
feedback.feedback_type = 'factual_error'
  → 历史专家分析
  → 若是常见错误模式（如"韩信 vs 韩王信"混淆）
  → 新增规则 rules/entities/han_xin_disambiguation.py
  → 回补到历史数据（带该 prompt_version 的 llm_calls 重跑）
  → 发版后新数据自动防护
```

这个闭环保证系统会随时间变得越来越稳健，而不是越来越烂。

---

## 八、Phase 0 落地步骤

在 Phase 0 就要确立 TraceGuard 的骨架，避免后期改造：

1. **T-TG-001**：确认 TraceGuard 接口（Python + Node 客户端）
2. **T-TG-002**：实现 `LLMGateway` 时集成 TraceGuard 的 checkpoint 钩子
3. **T-TG-003**：写 3 个初始规则（`json_schema` / `entity_surface_in_source` / `confidence_threshold`）
4. **T-TG-004**：在鸿门宴 MVP 的 NER 步骤验证 checkpoint 触发
5. **T-TG-005**：文档化规则开发指南 + 回归测试规范

---

## 九、风险与边界

### 性能风险
- 同步 checkpoint 会拖慢管线
- **对策**：非关键规则异步校验；关键规则 < 50ms；批量处理时用 batch checkpoint

### 规则蔓延
- 规则库无人维护会腐化
- **对策**：每条规则有 owner + sunset 机制（6 个月没触发自动标 deprecated）

### False Positive
- 规则太严，合法数据被拦
- **对策**：`observe` 模式先跑 2 周 → 调阈值 → 再切 `enforce`

### 与 Pydantic/Zod 的关系
- Pydantic/Zod 是"数据模型层"的格式校验
- TraceGuard 是"流程层"的语义校验 + 动作编排
- 两者并存：Pydantic 校验数据形状，TraceGuard 校验数据含义与管线流转

---

## 十、待用户（TraceGuard 作者）确认的接口点

| # | 问题 | 需确认 |
|---|------|-------|
| 1 | TraceGuard 当前是否有 Python 客户端？Node 客户端？ | |
| 2 | Checkpoint 的返回值结构？是否支持异步？ | |
| 3 | 规则编写格式（decorator / 配置文件 / Python 类）？ | |
| 4 | 结果存储（自带 store / 外接 PG / 外接 Redis）？ | |
| 5 | 是否支持规则组合（AND/OR/NOT）？ | |
| 6 | 是否支持动作编排（retry → degrade → queue）？ | |
| 7 | 是否支持 sampling / 环境分组？ | |

上述问题用户可在下一轮对话中回答，我会据此精确化上面的代码示例并生成 ADR-TG-001（TraceGuard 集成合同）。

---

## 十一、状态更新（2026-04-15）

§十 的 7 个问题已由架构师（用户授权）通过 **Port/Adapter 模式**统一回答，封版于
**[ADR-004 TraceGuard 集成合同](decisions/ADR-004-traceguard-integration-contract.md)**。

核心结论：
- 华典智谱不绑定 TraceGuard 的"现有 API"，而是定义自身所需的 **TraceGuardPort 协议**
- 由管线工程师在 **T-TG-002** 任务中实现 Adapter 对接 TraceGuard 当前版本
- 所有"动作编排（retry/degrade/queue）/ 规则组合 / sampling / 存储"均**不依赖** TraceGuard 原生能力，由 Adapter 层在华典侧实现

§二 ~ §七 的代码示例视作"参考实现"，以 **ADR-004 为准**。
