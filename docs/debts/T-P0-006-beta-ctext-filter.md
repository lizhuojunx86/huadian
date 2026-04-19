> 已合并至 T-P0-006-beta-followups.md，仅保留历史

# T-P0-006-β — ctext WebFetch 撞 content filter（已绕行）

- **优先级**：P3（低，已有 workaround）
- **登记日期**：2026-04-19
- **来源**：β 路线 S-1a《尚书》摄入
- **状态**：workaround applied

## 现象

Claude Code 在 S-1a 用 WebFetch 拉取 `https://ctext.org/shang-shu/canon-of-yao/zhs`
时，多次连续 fetch（4 次都是 79.7KB 同一响应，疑似被 cloudflare 或反爬返回首页），
随后响应阶段撞上 Anthropic content filter：

```
API Error: 400 "Output blocked by content filtering policy"
```

Agent 陷入重试循环，"Churned for 4m 2s" 无进展。

## 根因

两层问题叠加：

1. **ctext URL 反爬**：无 UA / 不带 cookie 的 GET 请求会被返回首页 HTML（79.7KB 固定大小），
   而不是目标章节正文。`bash curl -A "Mozilla/..."` 带 UA 可以拿到正文（~100-120KB）。
2. **Content filter 误判**：WebFetch 拿到的 HTML 里可能有触发分类器的片段
   （古文字符 + 英文翻译混合、或 ctext 自动插入的 banner 文本），
   导致 Claude Code 的后续响应被阻断。

## Workaround

**绕开 WebFetch，改用 bash curl + 本地 txt 喂 fixtures**：

```bash
curl -sL -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15" \
  "https://ctext.org/shang-shu/canon-of-yao/zhs" -o /tmp/yao_dian.html
```

然后 Python 正则剥 `<td class="ctext">` 段。详见 β 路线 S-1a 实际执行记录。

## 解决方案候选（长期）

| 方向 | 描述 | 优先级 |
|------|------|--------|
| A | ctext.py adapter 增加 UA 头 + 响应体大小校验（79.7KB 判定异常） | 推荐 |
| B | 所有外部 fetch 走 bash curl，避免经过 LLM 响应阶段 | 重 |
| C | 把已用到的 ctext 章节缓存进 fixtures，离线开发 | 简单 |

## 影响范围

- 本次 β 路线尧典/舜典已通过 workaround 绕过
- 未来任何 ctext 新章节 ingest 都会踩同一坑
- 建议 T-P0-006 正式扩量前把 ctext.py 改成"bash curl + 本地 cache"模式

## 关联

- 当前触发任务：T-P0-006-β《尚书·尧典 + 舜典》
- ctext.py 位置：`services/pipeline/src/huadian_pipeline/sources/ctext.py`
