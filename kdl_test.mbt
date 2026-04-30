///|
test "KdlValue String" {
  let v : KdlValue = KdlValue::String("hello")
  assert_true(v.is_string())
  assert_false(v.is_integer())
  assert_false(v.is_float())
  assert_false(v.is_bool())
  assert_false(v.is_null())
  assert_eq(v.as_string(), Some("hello"))
  assert_eq(v.as_integer(), None)
  assert_eq(v.as_float(), None)
  assert_eq(v.as_bool(), None)
}

///|
test "KdlValue Integer" {
  let v : KdlValue = KdlValue::Integer(42L)
  assert_false(v.is_string())
  assert_true(v.is_integer())
  assert_false(v.is_float())
  assert_false(v.is_bool())
  assert_false(v.is_null())
  assert_eq(v.as_string(), None)
  assert_eq(v.as_integer(), Some(42L))
  assert_eq(v.as_float(), None)
  assert_eq(v.as_bool(), None)
}

///|
test "KdlValue Float" {
  let v : KdlValue = KdlValue::Float(3.14)
  assert_false(v.is_string())
  assert_false(v.is_integer())
  assert_true(v.is_float())
  assert_false(v.is_bool())
  assert_false(v.is_null())
  assert_eq(v.as_string(), None)
  assert_eq(v.as_integer(), None)
  assert_eq(v.as_float(), Some(3.14))
  assert_eq(v.as_bool(), None)
}

///|
test "KdlValue Bool" {
  let v : KdlValue = KdlValue::Bool(true)
  assert_false(v.is_string())
  assert_false(v.is_integer())
  assert_false(v.is_float())
  assert_true(v.is_bool())
  assert_false(v.is_null())
  assert_eq(v.as_string(), None)
  assert_eq(v.as_integer(), None)
  assert_eq(v.as_float(), None)
  assert_eq(v.as_bool(), Some(true))
}

///|
test "KdlValue Null" {
  let v : KdlValue = KdlValue::Null
  assert_false(v.is_string())
  assert_false(v.is_integer())
  assert_false(v.is_float())
  assert_false(v.is_bool())
  assert_true(v.is_null())
  assert_eq(v.as_string(), None)
  assert_eq(v.as_integer(), None)
  assert_eq(v.as_float(), None)
  assert_eq(v.as_bool(), None)
}

///|
test "KdlValue Debug" {
  inspect(KdlValue::String("hello"), content="String(\"hello\")")
  inspect(KdlValue::Integer(42L), content="Integer(42L)")
  inspect(KdlValue::Float(3.14), content="Float(3.14)")
  inspect(KdlValue::Bool(true), content="Bool(true)")
  inspect(KdlValue::Null, content="Null")
}

///|
test "KdlIdentifier new" {
  let id = KdlIdentifier::new("node-name")
  assert_eq(id.value(), "node-name")
  assert_eq(id.repr(), None)
  assert_eq(id.to_string(), "node-name")
}

///|
test "KdlIdentifier with repr" {
  let id = KdlIdentifier::with_repr("node", "\"node\"")
  assert_eq(id.value(), "node")
  assert_eq(id.repr(), Some("\"node\""))
  assert_eq(id.to_string(), "\"node\"")
}

///|
test "KdlIdentifier Eq" {
  let a = KdlIdentifier::new("foo")
  let b = KdlIdentifier::new("foo")
  let c = KdlIdentifier::new("bar")
  assert_eq(a == b, true)
  assert_eq(a == c, false)
  assert_eq(a != b, false)
  assert_eq(a != c, true)
}

///|
test "KdlIdentifier Debug" {
  let id = KdlIdentifier::new("test")
  inspect(id, content="{value: \"test\", repr: None}")
}

///|
test "KdlEntry new (argument)" {
  let entry = KdlEntry::new(KdlValue::Integer(42L))
  assert_eq(entry.is_prop(), false)
  assert_eq(entry.name, None)
  assert_true(entry.value is Integer(42L))
  assert_eq(entry.ty, None)
}

///|
test "KdlEntry new_prop (property)" {
  let key = KdlIdentifier::new("name")
  let entry = KdlEntry::new_prop(key, KdlValue::String("value"))
  assert_eq(entry.is_prop(), true)
  assert_eq(entry.name, Some(KdlIdentifier::new("name")))
  assert_true(entry.value is String("value"))
}

///|
test "KdlEntry Eq" {
  let a = KdlEntry::new(KdlValue::Bool(true))
  let b = KdlEntry::new(KdlValue::Bool(true))
  let c = KdlEntry::new(KdlValue::Bool(false))
  assert_eq(a == b, true)
  assert_eq(a == c, false)
}

///|
test "KdlEntry Debug" {
  let entry = KdlEntry::new(KdlValue::Null)
  inspect(entry, content="KdlEntry { ty: None, value: Null, name: None }")
}

///|
test "KdlNode new" {
  let name = KdlIdentifier::new("mynode")
  let node = KdlNode::new(name)
  assert_eq(node.name, KdlIdentifier::new("mynode"))
  assert_eq(node.ty, None)
  assert_eq(node.entries.length(), 0)
  assert_eq(node.children, None)
}

///|
test "KdlNode with entries" {
  let name = KdlIdentifier::new("author")
  let node = KdlNode::new(name)
  node.entries.push(KdlEntry::new(KdlValue::String("foo")))
  let key = KdlIdentifier::new("age")
  node.entries.push(KdlEntry::new_prop(key, KdlValue::Integer(30L)))
  assert_eq(node.entries.length(), 2)
  assert_eq(node.entries[0].is_prop(), false)
  assert_eq(node.entries[1].is_prop(), true)
}

///|
test "KdlNode with children" {
  let child = KdlNode::new(KdlIdentifier::new("child"))
  let node = KdlNode::with_children(KdlIdentifier::new("parent"), [child])
  assert_eq(node.children.map(fn(arr) { arr.length() }), Some(1))
}

///|
test "KdlNode Eq" {
  let a = KdlNode::new(KdlIdentifier::new("x"))
  let b = KdlNode::new(KdlIdentifier::new("x"))
  let c = KdlNode::new(KdlIdentifier::new("y"))
  assert_eq(a == b, true)
  assert_eq(a == c, false)
}

///|
test "KdlNode Debug" {
  let node = KdlNode::new(KdlIdentifier::new("n"))
  inspect(
    node,
    content="KdlNode { ty: None, name: {value: \"n\", repr: None}, entries: [], children: None }",
  )
}

///|
test "KdlDocument new" {
  let doc = KdlDocument::new()
  assert_eq(doc.nodes().length(), 0)
}

///|
test "KdlDocument push and nodes" {
  let doc = KdlDocument::new()
  doc.push(KdlNode::new(KdlIdentifier::new("a")))
  doc.push(KdlNode::new(KdlIdentifier::new("b")))
  assert_eq(doc.nodes().length(), 2)
}

///|
test "KdlDocument get" {
  let doc = KdlDocument::new()
  doc.push(KdlNode::new(KdlIdentifier::new("foo")))
  doc.push(KdlNode::new(KdlIdentifier::new("bar")))
  doc.push(KdlNode::new(KdlIdentifier::new("foo")))
  let found = doc.get("foo")
  assert_true(found is Some(_))
  assert_eq(found.unwrap().name.value(), "foo")
  assert_eq(doc.get("baz"), None)
}

///|
test "KdlDocument Eq" {
  let a = KdlDocument::new()
  let b = KdlDocument::new()
  assert_eq(a == b, true)
  a.push(KdlNode::new(KdlIdentifier::new("x")))
  assert_eq(a == b, false)
}

///|
test "KdlDocument Debug" {
  let doc = KdlDocument::new()
  inspect(doc, content="KdlDocument { version: None, nodes: [] }")
}

///|
test "KdlDocument version getter/setter" {
  let doc = KdlDocument::new()
  assert_eq(doc.get_version(), None)
  doc.set_version(1)
  assert_eq(doc.get_version(), Some(1))
  doc.set_version(2)
  assert_eq(doc.get_version(), Some(2))
}

///|
test "KdlSeverity Eq" {
  assert_eq(KdlSeverity::Error == KdlSeverity::Error, true)
  assert_eq(KdlSeverity::Warning == KdlSeverity::Warning, true)
  assert_eq(KdlSeverity::Error == KdlSeverity::Warning, false)
}

///|
test "KdlSeverity Debug" {
  inspect(KdlSeverity::Error, content="Error")
  inspect(KdlSeverity::Warning, content="Warning")
}

///|
test "KdlDiagnostic new" {
  let diag = KdlDiagnostic::new(
    "let x = 1;",
    4,
    1,
    Some("unexpected token"),
    Some("here"),
    Some("remove this"),
    KdlSeverity::Error,
  )
  assert_eq(diag.input, "let x = 1;")
  assert_eq(diag.span_start, 4)
  assert_eq(diag.span_len, 1)
  assert_eq(diag.message, Some("unexpected token"))
  assert_eq(diag.label, Some("here"))
  assert_eq(diag.help, Some("remove this"))
  assert_eq(diag.severity, KdlSeverity::Error)
}

///|
test "KdlDiagnostic with optional None" {
  let diag = KdlDiagnostic::new(
    "x",
    0,
    1,
    None,
    None,
    None,
    KdlSeverity::Warning,
  )
  assert_eq(diag.message, None)
  assert_eq(diag.label, None)
  assert_eq(diag.help, None)
  assert_eq(diag.severity, KdlSeverity::Warning)
}

///|
test "KdlDiagnostic Eq" {
  let a = KdlDiagnostic::new("x", 0, 1, None, None, None, KdlSeverity::Error)
  let b = KdlDiagnostic::new("x", 0, 1, None, None, None, KdlSeverity::Error)
  let c = KdlDiagnostic::new("y", 0, 1, None, None, None, KdlSeverity::Error)
  assert_eq(a == b, true)
  assert_eq(a == c, false)
}

///|
test "KdlDiagnostic Debug" {
  let diag = KdlDiagnostic::new("x", 0, 1, None, None, None, KdlSeverity::Error)
  inspect(
    diag,
    content="KdlDiagnostic { input: \"x\", span_start: 0, span_len: 1, message: None, label: None, help: None, severity: Error }",
  )
}

///|
test "KdlError new is empty" {
  let err = KdlError::new("input")
  assert_eq(err.is_empty(), true)
  assert_eq(err.input, "input")
}

///|
test "KdlError push and is_empty" {
  let err = KdlError::new("test")
  assert_eq(err.is_empty(), true)
  let diag = KdlDiagnostic::new(
    "test",
    0,
    1,
    None,
    None,
    None,
    KdlSeverity::Error,
  )
  err.push(diag)
  assert_eq(err.is_empty(), false)
}

///|
test "KdlError multiple diagnostics" {
  let err = KdlError::new("abc")
  err.push(
    KdlDiagnostic::new(
      "abc",
      0,
      1,
      Some("err1"),
      None,
      None,
      KdlSeverity::Error,
    ),
  )
  err.push(
    KdlDiagnostic::new(
      "abc",
      2,
      1,
      Some("err2"),
      None,
      None,
      KdlSeverity::Warning,
    ),
  )
  assert_eq(err.is_empty(), false)
}

///|
test "KdlError Eq" {
  let a = KdlError::new("x")
  let b = KdlError::new("x")
  assert_eq(a == b, true)
  a.push(KdlDiagnostic::new("x", 0, 1, None, None, None, KdlSeverity::Error))
  assert_eq(a == b, false)
}

///|
test "KdlError Debug" {
  let err = KdlError::new("test")
  inspect(err, content="KdlError { input: \"test\", diagnostics: [] }")
}
