# lenitain/kdl

A MoonBit library for parsing, formatting, querying, and validating [KDL](https://github.com/kdl-org/kdl) documents.

## Installation

Add the dependency to your `moon.mod.json`:

```json
{
  "deps": {
    "lenitain/kdl": "0.1.0"
  }
}
```

## Quick Start

```moonbit nocheck
let doc = @parser.parse(r#"node "hello" { child key=42 }"#)?
println(doc.to_kdl_string())

let node = doc.get("node")
println(node)
```

## Parsing

```moonbit nocheck
// Parse KDL v2 (default)
let doc = @parser.parse(input)?

// Parse KDL v1
let doc = @parser.parse_v1(input)?

// Access document nodes
let nodes = doc.nodes()
let first = doc.get("node-name")
```

Returns `Result[KdlDocument, KdlError]`. Errors contain `KdlDiagnostic` entries with span info, severity, and messages.

## Types

| Type | Description |
|---|---|
| `KdlDocument` | Top-level document containing an array of nodes |
| `KdlNode` | A named node with entries and optional children |
| `KdlEntry` | A value argument or `key=value` property |
| `KdlValue` | Enum: `String`, `Integer(Int64)`, `Float(Double)`, `Bool`, `Null` |
| `KdlIdentifier` | A node/property key name with optional repr |
| `KdlError` | Collection of `KdlDiagnostic` errors |
| `KdlDiagnostic` | Single diagnostic with span, message, label, severity |

### Building documents programmatically

```moonbit nocheck
let node = @KdlNode::new(@KdlIdentifier::new("server"))
let doc = @KdlDocument::new()
doc.push(node)
println(doc.to_kdl_string())
```

### Accessing values

```moonbit nocheck
match entry.value {
  String(s) => println(s)
  Integer(n) => println(n.to_string())
  Float(f) => println(f.to_string())
  Bool(b) => println(b.to_string())
  Null => println("null")
}
```

## Formatting

```moonbit nocheck
// Compact output
println(doc.to_kdl_string())

// Pretty-printed with 2-space indentation
println(doc.to_kdl_string_formatted(2))
```

## Querying (KQL)

The `query` subpackage implements [KDL Query Language (KQL)](https://github.com/kdl-org/kdl/blob/main/SPEC.md):

```moonbit nocheck
let results = @query.query(doc, "node > child")?
```

## Schema Validation

Validate documents against a KDL schema:

```moonbit nocheck
let schema_doc = @parser.parse(schema_input)?
let schema = @schema.parse_schema(schema_doc)?
@schema.validate(doc, schema)?
```

## CLI Tool

Build the CLI from `cmd/main/`:

```sh
moon build cmd/main
```

Subcommands:

```
kdl parse <file>            Parse and print document summary
kdl check <file> [schema]   Validate against optional schema
kdl format <file>           Pretty-print a KDL file
kdl help                    Show usage
```

## Subpackage Import Paths

| Import | Purpose |
|---|---|
| `lenitain/kdl` | Core types |
| `lenitain/kdl/parser` | Parsing functions |
| `lenitain/kdl/query` | KQL queries |
| `lenitain/kdl/schema` | Schema validation |

## License

Apache-2.0
