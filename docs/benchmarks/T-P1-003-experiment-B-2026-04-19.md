# T-P1-003 Experiment: experiment-B

| Metric | Value |
|--------|-------|
| Macro P | 90.0% |
| Macro R | 100.0% |
| Macro F1 | 93.0% |
| Perfect | 24/30 |
| Disallowed | 3 |

## Non-Perfect

- **G02 "禹"**: P=0.5 R=1 F1=0.6667 returned=[yu,qi]
- **G04 "帝中"**: P=0.3333 R=1 F1=0.5 DISALLOWED=[u4e2d-u58ec,zhong-kang] returned=[u4e2d-u4e01,u4e2d-u58ec,zhong-kang]
- **G05 "帝中丁"**: P=0.3333 R=1 F1=0.5 DISALLOWED=[u4e2d-u58ec,zhong-kang] returned=[u4e2d-u4e01,u4e2d-u58ec,zhong-kang]
- **G12 "帝武乙"**: P=0.5 R=1 F1=0.6667 DISALLOWED=[wu-ding] returned=[u6b66-u4e59,wu-ding]
- **G16 "舜"**: P=0.5 R=1 F1=0.6667 returned=[shun,shang-jun]
- **G30 "太"**: P=0.8333 R=1 F1=0.9091 returned=[u53f8-u9a6c-u8fc1,tai-kang,u592a-u4e01,u592a-u5e9a,tai-jia]
