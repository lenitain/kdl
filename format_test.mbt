///|
test "KdlValue to_kdl_string String" {
  assert_eq(KdlValue::String("hello").to_kdl_string(), "\"hello\"")
}

///|
test "KdlValue to_kdl_string String empty" {
  assert_eq(KdlValue::String("").to_kdl_string(), "\"\"")
}

///|
test "KdlValue to_kdl_string String escapes" {
  assert_eq(KdlValue::String("a\nb").to_kdl_string(), "\"a\\nb\"")
  assert_eq(KdlValue::String("a\tb").to_kdl_string(), "\"a\\tb\"")
  assert_eq(KdlValue::String("a\\b").to_kdl_string(), "\"a\\\\b\"")
  assert_eq(KdlValue::String("a\"b").to_kdl_string(), "\"a\\\"b\"")
  assert_eq(KdlValue::String("a\rb").to_kdl_string(), "\"a\\rb\"")
  assert_eq(KdlValue::String("a/b").to_kdl_string(), "\"a\\/b\"")
}

///|
test "KdlValue to_kdl_string Integer" {
  assert_eq(KdlValue::Integer(42L).to_kdl_string(), "42")
  assert_eq(KdlValue::Integer(-1L).to_kdl_string(), "-1")
  assert_eq(KdlValue::Integer(0L).to_kdl_string(), "0")
}

///|
test "KdlValue to_kdl_string Float" {
  assert_eq(KdlValue::Float(3.14).to_kdl_string(), "3.14")
  assert_eq(KdlValue::Float(-0.5).to_kdl_string(), "-0.5")
  assert_eq(KdlValue::Float(1.0).to_kdl_string(), "1.0")
}

///|
test "KdlValue to_kdl_string Float special" {
  assert_eq(KdlValue::Float(1.0 / 0.0).to_kdl_string(), "#inf")
  assert_eq(KdlValue::Float(-1.0 / 0.0).to_kdl_string(), "#-inf")
  assert_eq(KdlValue::Float(0.0 / 0.0).to_kdl_string(), "#nan")
}

///|
test "KdlValue to_kdl_string Bool" {
  assert_eq(KdlValue::Bool(true).to_kdl_string(), "true")
  assert_eq(KdlValue::Bool(false).to_kdl_string(), "false")
}

///|
test "KdlValue to_kdl_string Null" {
  assert_eq(KdlValue::Null.to_kdl_string(), "null")
}

///|
test "KdlEntry to_kdl_string argument" {
  let entry = KdlEntry::new(KdlValue::Integer(42L))
  assert_eq(entry.to_kdl_string(), "42")
}

///|
test "KdlEntry to_kdl_string string argument" {
  let entry = KdlEntry::new(KdlValue::String("hello"))
  assert_eq(entry.to_kdl_string(), "\"hello\"")
}

///|
test "KdlEntry to_kdl_string property" {
  let entry = KdlEntry::new_prop(
    KdlIdentifier::new("key"),
    KdlValue::String("val"),
  )
  assert_eq(entry.to_kdl_string(), "key=\"val\"")
}

///|
test "KdlEntry to_kdl_string property with int" {
  let entry = KdlEntry::new_prop(
    KdlIdentifier::new("port"),
    KdlValue::Integer(8080L),
  )
  assert_eq(entry.to_kdl_string(), "port=8080")
}

///|
test "KdlEntry to_kdl_string Bool property" {
  let entry = KdlEntry::new_prop(
    KdlIdentifier::new("enabled"),
    KdlValue::Bool(true),
  )
  assert_eq(entry.to_kdl_string(), "enabled=true")
}

///|
test "KdlEntry to_kdl_string Null argument" {
  let entry = KdlEntry::new(KdlValue::Null)
  assert_eq(entry.to_kdl_string(), "null")
}

///|
test "KdlNode to_kdl_string bare" {
  let node = KdlNode::new(KdlIdentifier::new("foo"))
  assert_eq(node.to_kdl_string(), "foo")
}

///|
test "KdlNode to_kdl_string with args" {
  let node = KdlNode::with_entries(KdlIdentifier::new("author"), [
    KdlEntry::new(KdlValue::String("foo")),
    KdlEntry::new_prop(KdlIdentifier::new("age"), KdlValue::Integer(30L)),
  ])
  assert_eq(node.to_kdl_string(), "author \"foo\" age=30")
}

///|
test "KdlNode to_kdl_string with empty children" {
  let node = KdlNode::with_children(KdlIdentifier::new("block"), [])
  assert_eq(node.to_kdl_string(), "block {}")
}

///|
test "KdlNode to_kdl_string with children" {
  let child = KdlNode::new(KdlIdentifier::new("child"))
  let node = KdlNode::with_children(KdlIdentifier::new("parent"), [child])
  assert_eq(node.to_kdl_string(), "parent {\n  child\n}")
}

///|
test "KdlNode to_kdl_string with type annotation" {
  let node = KdlNode::full(
    Some(KdlIdentifier::new("type")),
    KdlIdentifier::new("foo"),
    [],
    None,
  )
  assert_eq(node.to_kdl_string(), "(type)foo")
}

///|
test "KdlNode to_kdl_string nested children" {
  let grandchild = KdlNode::new(KdlIdentifier::new("d"))
  let child = KdlNode::with_children(KdlIdentifier::new("b"), [grandchild])
  let root = KdlNode::with_children(KdlIdentifier::new("a"), [child])
  assert_eq(root.to_kdl_string(), "a {\n  b {\n    d\n  }\n}")
}

///|
test "KdlNode to_kdl_string_formatted indent 4" {
  let child = KdlNode::new(KdlIdentifier::new("x"))
  let node = KdlNode::with_children(KdlIdentifier::new("root"), [child])
  assert_eq(node.to_kdl_string_formatted(4), "root {\n    x\n}")
}

///|
test "KdlDocument to_kdl_string empty" {
  let doc = KdlDocument::new()
  assert_eq(doc.to_kdl_string(), "")
}

///|
test "KdlDocument to_kdl_string single node" {
  let doc = KdlDocument::new()
  doc.push(KdlNode::new(KdlIdentifier::new("foo")))
  assert_eq(doc.to_kdl_string(), "foo")
}

///|
test "KdlDocument to_kdl_string multiple nodes" {
  let doc = KdlDocument::new()
  doc.push(KdlNode::new(KdlIdentifier::new("a")))
  doc.push(KdlNode::new(KdlIdentifier::new("b")))
  assert_eq(doc.to_kdl_string(), "a\nb")
}

///|
test "KdlDocument to_kdl_string with entries and children" {
  let doc = KdlDocument::new()
  doc.push(
    KdlNode::with_entries(KdlIdentifier::new("name"), [
      KdlEntry::new(KdlValue::String("test")),
    ]),
  )
  let child = KdlNode::with_entries(KdlIdentifier::new("child"), [
    KdlEntry::new_prop(KdlIdentifier::new("x"), KdlValue::Integer(1L)),
  ])
  doc.push(KdlNode::with_children(KdlIdentifier::new("parent"), [child]))
  assert_eq(doc.to_kdl_string(), "name \"test\"\nparent {\n  child x=1\n}")
}

///|
test "KdlDocument to_kdl_string_formatted indent 4" {
  let doc = KdlDocument::new()
  let child = KdlNode::new(KdlIdentifier::new("b"))
  doc.push(KdlNode::with_children(KdlIdentifier::new("a"), [child]))
  assert_eq(doc.to_kdl_string_formatted(4), "a {\n    b\n}")
}

///|
test "KdlValue to_kdl_string with Bool false" {
  let v = KdlValue::Bool(false)
  assert_eq(v.to_kdl_string(), "false")
}

///|
test "KdlNode to_kdl_string property only" {
  let node = KdlNode::with_entries(KdlIdentifier::new("config"), [
    KdlEntry::new_prop(KdlIdentifier::new("debug"), KdlValue::Bool(true)),
  ])
  assert_eq(node.to_kdl_string(), "config debug=true")
}

///|
test "KdlNode to_kdl_string mixed args and props" {
  let node = KdlNode::with_entries(KdlIdentifier::new("node"), [
    KdlEntry::new(KdlValue::String("arg")),
    KdlEntry::new_prop(KdlIdentifier::new("key"), KdlValue::Null),
    KdlEntry::new(KdlValue::Float(1.5)),
  ])
  assert_eq(node.to_kdl_string(), "node \"arg\" key=null 1.5")
}
