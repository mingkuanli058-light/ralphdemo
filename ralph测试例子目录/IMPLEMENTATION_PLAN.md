# IMPLEMENTATION_PLAN.md

本文件是执行状态的唯一来源。

- 所有当前任务、优先级和下一步操作都必须体现在此处。
- 不得假定本文件之外存在任何执行状态。
- 本文件可以在任何时候被重写、重新排序或重新生成。
- AGENTS.md 定义执行规则；本文件仅定义当前状态。
- 文件其余部分只能包含当前的执行计划。
- 不得包含历史日志或叙述性说明。

---

## 当前目标（Current Objective）

实现一个可在浏览器运行的民警信息管理系统，支持民警信息的录入、修改、删除、查询功能，具备有效性校验和身份证号唯一性约束。

---

## 可执行任务（Executable Tasks · BUILD 阶段唯一合法来源）

### 任务列表（按优先级排序）

1. `[NEW]` 实现民警数据模型与内存存储
   - 创建 src/lib/police_model.py 定义民警数据结构
   - 字段：姓名、警号、身份证号（唯一标识）、单位、联系方式、专长、备注
   - 实现内存存储的 CRUD 接口
   - **验证方式**：tests/test_police_model.py 测试通过

2. `[NEW]` 实现民警信息有效性校验模块
   - 创建 src/lib/validators.py
   - 身份证号格式校验（18位，校验码验证）
   - 身份证号唯一性校验
   - 必填字段校验（姓名、警号、身份证号、单位、联系方式）
   - **验证方式**：tests/test_validators.py 测试通过

3. `[NEW]` 实现民警信息管理 API 接口
   - 创建 src/routes/police_routes.py
   - POST /api/police - 录入民警信息
   - PUT /api/police/<id_card> - 修改民警信息
   - DELETE /api/police/<id_card> - 删除民警信息
   - GET /api/police - 查询民警列表（支持条件查询）
   - GET /api/police/<id_card> - 查询单个民警信息
   - **验证方式**：tests/test_police_api.py 测试通过

4. `[NEW]` 实现前端页面（民警信息管理界面）
   - 创建 src/templates/index.html
   - 创建 src/static/styles.css（参考 ui_reference 风格）
   - 创建 src/static/app.js（前端交互逻辑）
   - 实现录入表单、列表展示、编辑、删除、查询功能
   - 包含 Logo 和版权信息：北京宽和精英科技发展有限公司
   - **验证方式**：浏览器访问可正常操作所有功能，符合 ui_reference 风格

5. `[TEST]` 补充集成测试
   - 创建 tests/test_integration.py
   - 覆盖完整的用户操作流程：录入 → 查询 → 修改 → 删除
   - **验证方式**：pytest tests/ 全部通过

---

## 延后处理 / 不可执行任务（Deferred / Out of Scope）

### 技术债 / 风险记录

- `[DEBT]` 当前使用内存存储，重启后数据丢失。如需持久化，未来可考虑引入 SQLite 或其他数据库
- `[DEBT]` 未实现用户认证与权限管理
- `[DEBT]` 未实现分页功能（当前假设数据量较小）

### 未决问题（需要澄清后才能进入可执行区）

- 无

---

## 规划备注（仅用于 PLAN 阶段）

- specs/我的任务.md 未指定持久化方式，当前选择内存存储以简化实现
- UI 参考为通用执法办案系统风格，民警管理页面需适配为单独功能模块
- function_map.md 中的功能映射与本需求无关（属于其他子系统），本次实现为独立新功能
