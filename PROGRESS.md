# KDL MoonBit Library - Development Progress

## 目标
为 [MoonBit](https://moonbitlang.com) 实现完整 KDL 文档语言库。
- 参考: [KDL Spec](https://github.com/kdl-org/kdl) (~/.cloned/kdl)
- 参考: [kdl-rs](https://github.com/kdl-org/kdl-rs) (~/.cloned/kdl-rs) Rust 实现

---

## Phase 1: 核心数据类型 ✅ 已完成
- [x] 规划项目结构
- [x] 创建 `PROGRESS.md`

### Phase 1.1: KDL Value 类型系统
- [x] `KdlValue` 枚举: `String`, `Integer(Int64)`, `Float(Double)`, `Bool`, `Null`
- [x] `KdlIdentifier`: 节点名/属性名/类型注解 (value + repr)
- [x] `KdlEntry`: Argument(位置参数) / Property(键值对)
- [x] `KdlNode`: 类型注解 + 名称 + entries + children
- [x] `KdlDocument`: 根文档 / 子节点块

### Phase 1.2: 错误类型
- [x] `KdlError` / `KdlDiagnostic`: 多错误收集, 源码位置

## Phase 2: Tokenizer / Lexer
- [ ] 基本的字符流处理
- [ ] 空白/换行处理
- [ ] 注释处理: `//`, `/* */` (可嵌套)
- [ ] Slashdash `/-` 注释
- [ ] 行继续符 `\` + 换行
- [ ] 禁止字符检测 (NUL, 控制字符, BIDI, BOM 处理)
- [ ] Token 类型设计

## Phase 3: Parser — v1 支持
- [ ] 裸标识符解析 (bare identifier)
- [ ] 数值解析: 十进制/十六进制/八进制/二进制 (含`_`分隔符)
- [ ] 引号字符串解析: 转义序列 `\n`, `\t`, `\\`, `\"`, `\/`, `\b`, `\f`, `\u{...}`
- [ ] 原始字符串解析 `r"..."#`, `r##"..."##`
- [ ] 布尔值: `true`/`false`
- [ ] Null: `null`
- [ ] 类型注解: `(bare-id)`
- [ ] 节点解析: 名称 + entries + children `{}`
- [ ] 文档解析: 版本标记 `/kdl-version 1`
- [ ] 一个完整 KDL v1 文档的端到端解析

## Phase 4: Parser — v2 支持
- [ ] 标识符字符串 (bare word)
- [ ] 多行字符串 `"""..."""`
- [ ] 新转义: `\s`, 转义空白
- [ ] 关键字数字: `#inf`, `#-inf`, `#nan`
- [ ] `#true`/`#false`/`#null`
- [ ] 类型注解支持字符串: `(string)` 含内部空白
- [ ] 节点名/属性键支持任意字符串类型
- [ ] Slashdash 支持子节点块
- [ ] 版本标记 `/kdl-version 2`
- [ ] 完整的 KDL v2 文档解析

### v1/v2 兼容
- [ ] 启发式检测 v1/v2 文档
- [ ] 统一内部表示 (v1 值转换为 v2 表示)

## Phase 5: 序列化 (KDL 输出)
- [ ] `KdlDocument.to_string()` / `show()` — 基本序列化
- [ ] 值的格式化输出
- [ ] 带缩进的序列化
- [ ] 可选格式化配置 (缩进大小等)

## Phase 6: 查询 (KQL)
- [ ] KQL Tokenizer
- [ ] KQL Parser (选择器 + 匹配器)
- [ ] 文档查询引擎: 子代, 后代, 兄弟选择器
- [ ] 值/属性/类型匹配与比较

## Phase 7: Schema 支持
- [ ] Schema 文档解析
- [ ] 节点定义验证
- [ ] 属性/值校验
- [ ] 类型检查

## Phase 8: 工具与完善
- [ ] Autoformat
- [ ] CLI 工具 (parse, check, format)
- [ ] 完整文档
- [ ] MoonBit 包发布

---

## 状态键
- `✅ 已完成` — 工作完成
- `🔄 进行中` — 当前工作
- `⏳ 待开始` — 尚未开始
- `⬜ 需要调研` — 需要进一步调研

## 设计原则
1. **先解析, 后格式化** — 不追求 round-trip 精确 (区别于 kdl-rs), 先用简单数据模型
2. **轻量依赖** — 零外部依赖, 纯 MoonBit 标准库
3. **v2 优先, 兼容 v1** — 主解析器面向 v2, v1 输入经适配后统一表示
4. **错误弹性** — 遇到错误尽量继续解析收集多个诊断
5. **MoonBit 惯用风格** — 使用 MoonBit 的 error handling, enum, Result 等

## 模块结构 (预期)
```
kdl/
  kdl.mbt          — 公开 API re-export
  types.mbt        — KdlValue, KdlEntry, KdlNode, KdlDocument, KdlIdentifier
  error.mbt        — KdlError, KdlDiagnostic
  lexer.mbt        — Tokenizer
  parser.mbt       — v1/v2 解析器
  format.mbt       — 序列化
  query.mbt        — KQL 查询 (Phase 6)
  schema.mbt       — Schema 验证 (Phase 7)
  deprecated.mbt   — 弃用代码 (如有)
```
