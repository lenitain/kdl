///|
test "repeat_str basic" {
  assert_eq(repeat_str("ab", 3), "ababab")
  assert_eq(repeat_str("x", 0), "")
  assert_eq(repeat_str("  ", 2), "    ")
}

///|
test "format_diagnostic with message" {
  let diag = @kdl.KdlDiagnostic::new(
    "input",
    0,
    0,
    Some("test error"),
    None,
    None,
    @kdl.Error,
  )
  assert_eq(format_diagnostic(diag), "[Error] test error")
}

///|
test "format_diagnostic without message" {
  let diag = @kdl.KdlDiagnostic::new(
    "input",
    0,
    0,
    None,
    None,
    None,
    @kdl.Warning,
  )
  assert_eq(format_diagnostic(diag), "[Warning] (no message)")
}

///|
test "format_error multiple diagnostics" {
  let err = @kdl.KdlError::new("input")
  err.push(
    @kdl.KdlDiagnostic::new("input", 0, 0, Some("err1"), None, None, @kdl.Error),
  )
  err.push(
    @kdl.KdlDiagnostic::new(
      "input",
      5,
      0,
      Some("err2"),
      None,
      None,
      @kdl.Warning,
    ),
  )
  let result = format_error(err)
  assert_true(result.contains("[Error] err1"))
  assert_true(result.contains("[Warning] err2"))
}

///|
test "node_summary leaf node" {
  let node = @kdl.KdlNode::new(@kdl.KdlIdentifier::new("leaf"))
  let result = node_summary(node, 0)
  assert_eq(result, "leaf")
}

///|
test "node_summary node with entries" {
  let node = @kdl.KdlNode::with_entries(@kdl.KdlIdentifier::new("foo"), [
    @kdl.KdlEntry::new(@kdl.KdlValue::Integer(42L)),
    @kdl.KdlEntry::new(@kdl.KdlValue::String("bar")),
  ])
  let result = node_summary(node, 0)
  assert_eq(result, "foo (2 entries)")
}

///|
test "node_summary node with children" {
  let child = @kdl.KdlNode::new(@kdl.KdlIdentifier::new("child"))
  let node = @kdl.KdlNode::with_children(@kdl.KdlIdentifier::new("parent"), [
    child,
  ])
  let result = node_summary(node, 0)
  assert_true(result.contains("parent (1 children)"))
  assert_true(result.contains("  child"))
}

///|
test "node_summary node with entries and children" {
  let child = @kdl.KdlNode::new(@kdl.KdlIdentifier::new("b"))
  let node = @kdl.KdlNode::full(
    None,
    @kdl.KdlIdentifier::new("a"),
    [@kdl.KdlEntry::new(@kdl.KdlValue::Integer(1L))],
    Some([child]),
  )
  let result = node_summary(node, 0)
  assert_true(result.contains("a (1 entries, 1 children)"))
  assert_true(result.contains("  b"))
}

///|
test "document_summary empty" {
  let doc = @kdl.KdlDocument::new()
  assert_eq(document_summary(doc), "Document with 0 node(s):")
}

///|
test "document_summary with nodes" {
  let doc = @kdl.KdlDocument::new()
  doc.push(@kdl.KdlNode::new(@kdl.KdlIdentifier::new("foo")))
  doc.push(@kdl.KdlNode::new(@kdl.KdlIdentifier::new("bar")))
  let result = document_summary(doc)
  assert_true(result.contains("Document with 2 node(s):"))
  assert_true(result.contains("foo"))
  assert_true(result.contains("bar"))
}
