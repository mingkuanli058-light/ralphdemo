# AGENTS.md
# Autonomous Execution Rules for Ralph

本文件定义 Ralph 在本工程中的**执行规则与操作边界**。
它是机器可读的操作手册，不是进度记录、不是设计文档、不是需求说明。

---

## Project Structure（Reference）

```text
.
├── specs/                     # 需求规格（最高权威）
│   └── bugs/                  # Bug 描述文件（修复模式使用）
├── src/                       # 应用源码
├── src/lib/                   # 标准库 / 权威实现 / 可复用能力中心
├── tests/                     # pytest 测试（背压）
├── IMPLEMENTATION_PLAN.md     # 当前任务状态（自动维护，可丢弃）
├── PROMPT_plan.md             # 规划模式 prompt
├── PROMPT_build.md            # 构建模式 prompt
├── PROMPT_fix.md              # 修复模式 prompt（省 Token）
└── AGENTS.md                  # 本文件
```
上述文件与目录是系统执行所必需的组成部分。
如任一文件不存在，必须先创建后再继续执行。
---

## Orientation（入口规则）

- 所有需求均定义在 `specs/*.md` 中。
- 源代码位于 `src/` 目录下。
- 当前任务状态记录在 `IMPLEMENTATION_PLAN.md` 中。
- `specs/*.md` 的优先级高于任何其他文件。
---

## PROMPT Modes（执行模式说明）

PROMPT_plan.md 与 PROMPT_build.md 是执行过程中使用的独立 prompt 模板文件，必须存在于仓库中。

本工程使用两种 PROMPT 模式，不同模式具有不同职责边界：

### PROMPT_plan.md（规划模式）
- 用于以下情况：
  - 项目尚未生成 `IMPLEMENTATION_PLAN.md`
  - 需求（`specs/*.md`）发生明显变化
  - 当前计划明显不完整或偏离需求
- 职责：
  - 阅读 `specs/*.md` 与现有代码
  - 生成或重建 `IMPLEMENTATION_PLAN.md`
- 限制：
  - 不允许实现代码
  - 不允许运行测试
  - 不允许提交

### PROMPT_build.md（构建模式）
- 默认使用的执行模式
- 职责：
  - 从 `IMPLEMENTATION_PLAN.md` 中选择一个最重要的任务
  - 实现、验证并提交该任务
- 限制：
  - 每次只完成一个任务
  - 必须遵守所有 Validation 与 Execution Rules

当构建过程中发现计划不清或明显错误时，应退出构建模式并切换回 `PROMPT_plan.md`。

### PROMPT_fix.md（修复模式）
- 用于快速修复已知 Bug，跳过完整规划阶段以节省 Token
- 用于以下情况：
  - 需要修复明确的 Bug（有清晰的现象和复现步骤）
  - Bug 描述已记录在 `specs/bugs/*.md` 中
- 职责：
  - 根据 Bug 描述定位问题根因
  - 实现最小必要修复
  - 验证并提交
  - 在 `IMPLEMENTATION_PLAN.md` 末尾追加修复记录
- 限制：
  - 每次只修复一个 Bug
  - 不加载完整 `specs/*.md`（除非 Bug 描述明确引用）
  - 不进行与 Bug 无关的重构或优化
  - 如修复需要架构级改动，应转入规划模式

## Investigation Rules（搜索纪律）

- 永远不要假设功能缺失
- 在实现之前始终搜索现有代码库
- 优先复用 `src/lib/`中已有的工具和模式
- 不要引入重复实现
---
## Codebase Authority（代码权威层级）

- `src/lib/` 被视为项目的标准库（standard library）
- 通用、可复用的能力必须优先放入 `src/lib/`
- 严禁在其他目录中复制已有的 `src/lib/` 实现
- 发现重复实现时，应重构并迁移至 `src/lib/`
- 当 `src/lib/` 与其他实现存在冲突时，以 `src/lib/` 为准


## Execution Rules（执行纪律）

- 只从 `IMPLEMENTATION_PLAN.md` 中选择 **一个** 任务
- 在继续之前完整完成所选任务
- 不要在一个循环中部分实现多个任务
- 遵循现有代码风格和项目模式

---

## Validation（Backpressure，背压规则）

优先运行与当前任务直接相关的测试：
```bash
pytest tests/
```
当无法明确判断影响范围时，应运行全量测试：
```bash
pytest -q
```
规则：
- 在提交之前，所有测试必须通过
- 测试失败表示任务 尚未完成
- 如果没有与该更改相关的测试，则创建测试
- 测试是 唯一 的完成信号
---

## State Updates（记忆与进化）

- 在以下情况下更新 `IMPLEMENTATION_PLAN.md`：
  - 某个任务已完成
  - 发现了新的问题、缺口或后续工作
- `IMPLEMENTATION_PLAN.md` 表示短期状态，可以被重写
- 仅在以下情况下更新`AGENTS.md`：
  - 新增构建 / 运行命令
  - 新增验证步骤
- 不要 在 `AGENTS.md` 中记录进度、历史或任务状态
---

## Commit Rules（提交规则）

- 仅在验证成功后提交
- 一次提交对应一个已完成的任务
- 提交信息应清晰描述完成了什么内容
---

## Exit Conditions（退出条件）
- 所选任务已完成且所有测试通过
- `IMPLEMENTATION_PLAN.md`中不再有剩余任务
- 规划不正确 → 切换到  `PROMPT_plan.md`

---

## General Principles（通用原则）
- Specs 定义 做什么（WHAT）
- Prompts 定义 能做什么 / 如何做（CAN / HOW）
- Tests 定义 通过 / 失败（PASS / FAIL）
- AGENTS.md 定义 如何执行（HOW TO EXECUTE）

## Loop Awareness

- 每一次执行视为一个独立循环
- 不保留跨循环的上下文假设
- 所有长期状态必须写入磁盘文件

## Failure Handling（失败处理）

在以下情况下，应立即停止当前构建循环：
- 连续两次测试失败且原因不明确
- `IMPLEMENTATION_PLAN.md` 与 `specs/*.md` 明显矛盾
- 多次修改同一文件但未取得进展

处理方式：
- 退出当前构建循环
- 切换至 `PROMPT_plan.md`
- 重建 `IMPLEMENTATION_PLAN.md`

## Build & Run（执行入口）

本项目的最小可运行方式如下：

```bash
python src/main.py
```
如运行失败，应按以下顺序依次检查：
1. Python 版本是否正确
2. 依赖是否已安装
3. 是否缺失必要的环境变量
