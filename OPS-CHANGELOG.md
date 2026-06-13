# OPS-CHANGELOG

运营系统自动感知此文件。开发团队每有用户可感知的变更就加一行。

- YYYY-MM-DD | 类型 | 一句话
- 2026-06-14 | 重构 | 移除继承自 CCGS 的 49 个 studio agents，CFG 不再默认模拟 49 人工作室架构
- 2026-06-14 | 重构 | 框架身份由 CCGS 明确为 CFG；窗口与技能治理入口命令统一重命名为 -cfg 系列
- 2026-06-14 | 新增 | D-director 导演裁决 lane：玩家体验/视觉质量/canon 裁决、工单与 project-canon
- 2026-06-14 | 重构 | 移除旧 sprint/story/smoke 生产动线，改用工单驱动的 active queue
- 2026-06-14 | 移除 | 删除 CCGS Skill Testing Framework（维护者本机治理链，不随纯净版发布）
- 2026-06-14 | 改进 | Z-platform lane 模板从「框架维护者」重写为「项目平台/框架适配」视角，服务用户改造自己的引擎与工具链生态
- 2026-06-14 | 新增 | 生成物生命周期治理与运行清单（generated-artifact-governance.md、cfg-operating-checklist.md）
