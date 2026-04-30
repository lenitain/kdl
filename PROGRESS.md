# KDL MoonBit Library - Development Progress

## 目标
为 [MoonBit](https://moonbitlang.com) 实现完整 KDL 文档语言库。
- 参考: [KDL Spec](https://github.com/kdl-org/kdl) (~/.cloned/kdl)
- 参考: [kdl-rs](https://github.com/kdl-org/kdl-rs) (~/.cloned/kdl-rs) Rust 实现

---

## 目录结构规划

参照 toml-parser 项目结构，最终目标：

```
kdl/
├── kdl.mbt                              # 公开 API re-export
├── types.mbt                            # KdlValue, KdlIdentifier, KdlEntry, KdlNode, KdlDocument
├── error.mbt                            # KdlError, KdlDiagnostic, KdlSeverity
├── format.mbt                           # KDL 序列化/格式化输出
├── moon.mod.json                        # 模块配置
├── moon.pkg                             # 包配置
├── LICENSE                              # Apache-2.0
├── README.mbt.md                        # 带可执行示例的文档
├── PROGRESS.md                          # 开发进度
│
├── internal/                            # 内部模块
│   └── tokenize/                        # 词法分析
│       ├── tokenize.mbt                 # 主 tokenizer 实现
│       ├── token.mbt                    # Token 类型定义
│       ├── lexer_test.mbt               # Lexer 单元测试
│       ├── lexer_bug_test.mbt           # Lexer 回归测试
│       └── moon.pkg.json                # Tokenizer 包配置
│
├── parser/                              # 解析器
│   ├── parser.mbt                       # v1/v2 解析逻辑
│   ├── v1_compat.mbt                    # v1 兼容适配
│   ├── parser_test.mbt                  # 解析器单元测试
│   └── moon.pkg.json                    # Parser 包配置
│
├── query/                               # KQL 查询引擎 (Phase 6)
│   ├── query.mbt                        # 查询执行
│   ├── query_parser.mbt                 # KQL 选择器解析
│   ├── query_test.mbt                   # 查询测试
│   └── moon.pkg.json                    # Query 包配置
│
├── schema/                              # Schema 验证 (Phase 7)
│   ├── schema.mbt                       # Schema 定义与验证
│   ├── schema_test.mbt                  # Schema 测试
│   └── moon.pkg.json                    # Schema 包配置
│
├── cmd/                                 # 命令行工具
│   └── main/                            # CLI 演示
│       ├── main.mbt                     # 交互式 KDL parser demo
│       ├── main_test.mbt                # Demo 测试
│       └── moon.pkg.json                # Main 包配置
│
├── 测试套件 (目标 5000+ 行)
│   ├── kdl_test.mbt                     # 核心类型测试
│   ├── kdl_wbtest.mbt                   # 白盒测试
│   ├── parser_test.mbt                  # 解析器测试
│   ├── parser_v1_test.mbt               # KDL v1 解析测试
│   ├── parser_v2_test.mbt               # KDL v2 解析测试
│   ├── format_test.mbt                  # 序列化测试
│   ├── official_kdl_test_suite_test.mbt # 官方 KDL 规范合规测试
│   ├── comprehensive_test.mbt           # 复杂真实场景测试
│   ├── coverage_test.mbt                # 覆盖率增强测试
│   └── special_value_test.mbt           # 特殊值 (inf, nan, #null) 测试
│
└── target/                              # 构建产物 (生成)
    ├── wasm-gc/                          # WebAssembly 输出
    └── packages.json                     # 包依赖信息
```

### 迁移计划

从当前扁平结构迁移到目标结构：

| 阶段 | 操作 | 当前状态 |
|------|------|----------|
| Phase 1 | `types.mbt`, `error.mbt` 保留在根目录 | ✅ 已完成 |
| Phase 2 | 创建 `internal/tokenize/` 子包 | ⏳ 待开始 |
| Phase 3 | 创建 `parser/` 子包 | ⏳ 待开始 |
| Phase 5 | 创建 `format.mbt` (根目录) | ⏳ 待开始 |
| Phase 6 | 创建 `query/` 子包 | ⏳ 待开始 |
| Phase 7 | 创建 `schema/` 子包 | ⏳ 待开始 |
| Phase 8 | 创建 `cmd/main/` CLI 工具 | ⏳ 待开始 |

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

## Phase 2: Tokenizer / Lexer 🔄 进行中
- [ ] 创建 `internal/tokenize/` 子包 (token.mbt + tokenize.mbt + moon.pkg.json)
- [ ] Token 类型设计: `KdlToken` 枚举 (Ident, String, Integer, Float, Bool, Null, LBrace, RBrace, LParen, RParen, Eq, Slashdash, etc.)
- [ ] 基本的字符流处理 (Cursor/SourcePosition)
- [ ] 空白/换行处理
- [ ] 注释处理: `//`, `/* */` (可嵌套)
- [ ] Slashdash `/-` 注释
- [ ] 行继续符 `\` + 换行
- [ ] 禁止字符检测 (NUL, 控制字符, BIDI, BOM 处理)
- [ ] Lexer 单元测试 + 回归测试

## Phase 3: Parser — v1 支持
- [ ] 创建 `parser/` 子包 (parser.mbt + moon.pkg.json)
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
- [ ] 创建 `query/` 子包
- [ ] KQL Tokenizer
- [ ] KQL Parser (选择器 + 匹配器)
- [ ] 文档查询引擎: 子代, 后代, 兄弟选择器
- [ ] 值/属性/类型匹配与比较

## Phase 7: Schema 支持
- [ ] 创建 `schema/` 子包
- [ ] Schema 文档解析
- [ ] 节点定义验证
- [ ] 属性/值校验
- [ ] 类型检查

## Phase 8: 工具与完善
- [ ] Autoformat
- [ ] 创建 `cmd/main/` CLI 工具 (parse, check, format)
- [ ] 完整文档 (README.mbt.md)
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
6. **模块化子包** — tokenizer/parser/query/schema 各自独立子包, 类似 toml-parser 结构

## 当前文件结构
```
kdl/
├── kdl.mbt              — 公开 API (待补充 re-export)
├── types.mbt            — KdlValue, KdlIdentifier, KdlEntry, KdlNode, KdlDocument ✅
├── error.mbt            — KdlError, KdlDiagnostic, KdlSeverity ✅
├── kdl_test.mbt         — 黑盒测试 (35 tests) ✅
├── kdl_wbtest.mbt       — 白盒测试
├── moon.mod.json        — 模块: lenitain/kdl
├── moon.pkg             — 包配置
└── PROGRESS.md          — 本文件
```
