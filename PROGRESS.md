# KDL MoonBit Library - Development Progress

## Goal
Implement a complete KDL document language library for [MoonBit](https://moonbitlang.com).
- Reference: [KDL Spec](https://github.com/kdl-org/kdl) (~/.cloned/kdl)
- Reference: [kdl-rs](https://github.com/kdl-org/kdl-rs) (~/.cloned/kdl-rs) Rust implementation

---

## Directory Structure Plan

Project structure, final goal. Tests live inside each package (`_test.mbt` for blackbox, `_wbtest.mbt` for whitebox), following MoonBit convention.

```
kdl/
├── kdl.mbt                              # Public API re-export
├── types.mbt                            # KdlValue, KdlIdentifier, KdlEntry, KdlNode, KdlDocument
├── error.mbt                            # KdlError, KdlDiagnostic, KdlSeverity
├── format.mbt                           # KDL serialization/formatting output
├── format_test.mbt                      # Format tests
├── kdl_test.mbt                         # Root package blackbox tests
├── kdl_wbtest.mbt                       # Root package whitebox tests
├── moon.mod.json                        # Module config
├── moon.pkg                             # Package config
├── LICENSE                              # Apache-2.0
├── README.mbt.md                        # Documentation with executable examples
├── PROGRESS.md                          # Development progress
│
├── internal/                            # Internal modules
│   └── tokenize/                        # Lexical analysis
│       ├── token.mbt                    # Token type definition
│       ├── tokenize.mbt                 # Main tokenizer implementation
│       ├── lexer_test.mbt               # Lexer unit tests
│       └── moon.pkg                     # Tokenizer package config
│
├── parser/                              # Parser
│   ├── parser.mbt                       # v1 parsing logic
│   ├── parser_test.mbt                  # Parser unit tests
│   └── moon.pkg                         # Parser package config
│
├── query/                               # KQL query engine
│   ├── query_token.mbt                  # KQL token types
│   ├── query_tokenize.mbt               # KQL tokenizer
│   ├── query_parser.mbt                 # KQL selector/matcher parsing
│   ├── query_engine.mbt                 # Query execution engine
│   ├── query_test.mbt                   # KQL tests
│   └── moon.pkg                         # Query package config
│
├── schema/                              # Schema validation (Phase 7)
│   ├── schema.mbt                       # Schema definition and validation
│   ├── schema_test.mbt                  # Schema tests
│   └── moon.pkg                         # Schema package config
│
└── cmd/                                 # Command line tools (Phase 8)
    └── main/                            # CLI demo
        ├── main.mbt                     # Interactive KDL parser demo
        ├── main_test.mbt                # Demo tests
        └── moon.pkg                     # Main package config
```

### Migration Plan

Migrate from current flat structure to target structure:

| Phase | Operation | Current Status |
|-------|-----------|----------------|
| Phase 1 | Keep `types.mbt`, `error.mbt` in root directory | ✅ Completed |
| Phase 2 | Create `internal/tokenize/` subpackage | ✅ Completed |
| Phase 3 | Create `parser/` subpackage | ✅ Completed |
| Phase 5 | Create `format.mbt` (root directory) | ✅ Completed |
| Phase 6 | Create `query/` subpackage | ✅ Completed |
| Phase 7 | Create `schema/` subpackage | ⏳ Pending |
| Phase 8 | Create `cmd/main/` CLI tool | ⏳ Pending |

---

## Phase 1: Core Data Types ✅ Completed
- [x] Plan project structure
- [x] Create `PROGRESS.md`

### Phase 1.1: KDL Value Type System
- [x] `KdlValue` enum: `String`, `Integer(Int64)`, `Float(Double)`, `Bool`, `Null`
- [x] `KdlIdentifier`: Node name/property name/type annotation (value + repr)
- [x] `KdlEntry`: Argument (positional) / Property (key-value pair)
- [x] `KdlNode`: Type annotation + name + entries + children
- [x] `KdlDocument`: Root document / child node block

### Phase 1.2: Error Types
- [x] `KdlError` / `KdlDiagnostic`: Multiple error collection, source position

## Phase 2: Tokenizer / Lexer ✅ Completed
- [x] Create `internal/tokenize/` subpackage (token.mbt + tokenize.mbt + moon.pkg)
- [x] Token type design: `KdlToken` enum (Ident, String, Integer, Float, Bool, Null, Inf, NegInf, Nan, LBrace, RBrace, LParen, RParen, Eq, Slashdash, Semicolon, Newline, Eof)
- [x] Basic character stream processing (Cursor/SourcePosition)
- [x] Whitespace/newline handling
- [x] Comment handling: `//`, `/* */` (nestable)
- [x] Slashdash `/-` comments
- [x] Line continuation `\` + newline
- [x] Disallowed character detection (NUL, control characters, BIDI, BOM handling)
- [x] Number parsing: decimal/hex/octal/binary integers + floats + scientific notation
- [x] Lexer unit tests (66 tests, all passing)

## Phase 3: Parser — v1 Support
- [x] Create `parser/` subpackage (parser.mbt + moon.pkg)
- [x] Bare identifier parsing
- [x] Number parsing: decimal/hexadecimal/octal/binary (with `_` separator)
- [x] Quoted string parsing: escape sequences `\n`, `\t`, `\\`, `\"`, `\/`, `\b`, `\f`, `\u{...}`
- [x] Raw string parsing `r"..."#`, `r##"..."##`
- [x] Boolean: `true`/`false`
- [x] Null: `null`
- [x] Type annotation: `(bare-id)`
- [x] Node parsing: name + entries + children `{}`
- [ ] Document parsing: version marker `/kdl-version 1`
- [x] End-to-end parsing of a complete KDL v1 document

## Phase 4: Parser — v2 Support
- [ ] Identifier string (bare word)
- [ ] Multiline string `"""..."""`
- [ ] New escape: `\s`, escaped whitespace
- [ ] Keyword numbers: `#inf`, `#-inf`, `#nan`
- [ ] `#true`/`#false`/`#null`
- [ ] Type annotation supports strings: `(string)` with internal whitespace
- [ ] Node name/property key supports arbitrary string types
- [ ] Slashdash supports child node blocks
- [ ] Version marker `/kdl-version 2`
- [ ] Complete KDL v2 document parsing

### v1/v2 Compatibility
- [ ] Heuristic detection of v1/v2 documents
- [ ] Unified internal representation (v1 values converted to v2 representation)

## Phase 5: Serialization (KDL Output) ✅ Completed
- [x] `KdlDocument.to_string()` / `show()` — basic serialization
- [x] Formatted output of values
- [x] Serialization with indentation
- [x] Optional formatting configuration (indent size, etc.)

## Phase 6: Query (KQL) ✅ Completed
- [x] Create `query/` subpackage
- [x] KQL Tokenizer
- [x] KQL Parser (selector + matcher)
- [x] Document query engine: child, descendant, sibling selectors
- [x] Value/property/type matching and comparison
- [x] 194 tests passing (tokenizer + parser + engine)

## Phase 7: Schema Support
- [ ] Create `schema/` subpackage
- [ ] Schema document parsing
- [ ] Node definition validation
- [ ] Property/value validation
- [ ] Type checking

## Phase 8: Tools and Polish
- [ ] Autoformat
- [ ] Create `cmd/main/` CLI tool (parse, check, format)
- [ ] Complete documentation (README.mbt.md)
- [ ] MoonBit package publication

---

## Status Key
- `✅ Completed` — Work completed
- `🔄 In Progress` — Current work
- `⏳ Pending` — Not yet started
- `⬜ Needs Research` — Requires further investigation

## Design Principles
1. **Parse first, format later** — Don't pursue round-trip precision (unlike kdl-rs), use simple data model first
2. **Lightweight dependencies** — Zero external dependencies, pure MoonBit standard library
3. **v2 first, compatible with v1** — Main parser targets v2, v1 input adapted to unified representation
4. **Error resilience** — Continue parsing on errors to collect multiple diagnostics
5. **MoonBit idiomatic style** — Use MoonBit's error handling, enum, Result, etc.
6. **Modular subpackages** — tokenizer/parser/query/schema each independent subpackages, similar to toml-parser structure

## Current File Structure
```
kdl/
├── kdl.mbt              — Public API (pending re-export)
├── types.mbt            — KdlValue, KdlIdentifier, KdlEntry, KdlNode, KdlDocument ✅
├── error.mbt            — KdlError, KdlDiagnostic, KdlSeverity ✅
├── format.mbt           — KDL serialization/formatting output ✅
├── format_test.mbt      — Format tests (27 tests) ✅
├── kdl_test.mbt         — Root package blackbox tests (35 tests) ✅
├── kdl_wbtest.mbt       — Root package whitebox tests
├── moon.mod.json        — Module: lenitain/kdl
├── moon.pkg             — Package config
├── PROGRESS.md          — This file
│
├── internal/tokenize/   — Lexical analysis ✅
│   ├── token.mbt        — Token type definition ✅
│   ├── tokenize.mbt     — Main tokenizer implementation ✅
│   ├── lexer_test.mbt   — Lexer unit tests (66 tests) ✅
│   └── moon.pkg         — Tokenizer package config ✅
│
├── parser/              — Parser ✅
│   ├── parser.mbt       — v1 parsing logic ✅
│   ├── parser_test.mbt  — Parser unit tests (5 tests) ✅
│   └── moon.pkg         — Parser package config ✅
│
└── query/               — KQL query engine ✅
    ├── query_token.mbt  — KQL token types (27 variants) ✅
    ├── query_tokenize.mbt — KQL tokenizer ✅
    ├── query_parser.mbt — KQL parser (AST + parsing) ✅
    ├── query_engine.mbt — Query execution engine ✅
    ├── query_test.mbt   — 194 tests (tokenizer + parser + engine) ✅
    └── moon.pkg         — Query package config ✅
```
