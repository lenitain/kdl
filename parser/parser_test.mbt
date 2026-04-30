///|
test "parse simple node" {
  let result = parse("foo")
  match result {
    Ok(doc) => {
      let nodes = doc.nodes()
      assert_eq(nodes.length(), 1)
      assert_eq(nodes[0].name.value(), "foo")
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse node with argument" {
  let result = parse("foo 42")
  match result {
    Ok(doc) => {
      let nodes = doc.nodes()
      assert_eq(nodes.length(), 1)
      assert_eq(nodes[0].name.value(), "foo")
      assert_eq(nodes[0].entries.length(), 1)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse node with children" {
  let result = parse("foo { bar }")
  match result {
    Ok(doc) => {
      let nodes = doc.nodes()
      assert_eq(nodes.length(), 1)
      assert_eq(nodes[0].name.value(), "foo")
      match nodes[0].children {
        Some(children) => {
          assert_eq(children.length(), 1)
          assert_eq(children[0].name.value(), "bar")
        }
        None => assert_true(false)
      }
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse multiple nodes" {
  let result = parse("foo\nbar")
  match result {
    Ok(doc) => {
      let nodes = doc.nodes()
      assert_eq(nodes.length(), 2)
      assert_eq(nodes[0].name.value(), "foo")
      assert_eq(nodes[1].name.value(), "bar")
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse property" {
  let result = parse("foo key=42")
  match result {
    Ok(doc) => {
      let nodes = doc.nodes()
      assert_eq(nodes.length(), 1)
      assert_eq(nodes[0].entries.length(), 1)
      assert_true(nodes[0].entries[0].is_prop())
    }
    Err(_) => assert_true(false)
  }
}

// KDL v2 Tests

///|
test "v2 multiline string basic" {
  let doc = parse("node \"\"\"\n    hello\n    world\n    \"\"\"").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.name.value(), "node")
  assert_eq(node.entries.length(), 1)
  assert_true(node.entries[0].value is String("hello\nworld"))
}

///|
test "v2 multiline string with empty lines" {
  let doc = parse("node \"\"\"\n    hello\n\n    world\n    \"\"\"").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_true(node.entries[0].value is String("hello\n\nworld"))
}

///|
test "v2 multiline string dedent" {
  let doc = parse("node \"\"\"\n        foo\n    bar\n    \"\"\"").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_true(node.entries[0].value is String("    foo\nbar"))
}

///|
test "v2 multiline string empty" {
  let doc = parse("node \"\"\"\n    \"\"\"").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_true(node.entries[0].value is String(""))
}

///|
test "v2 string with \\s escape" {
  let doc = parse("node \"hello\\sworld\"").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_true(node.entries[0].value is String("hello world"))
}

///|
test "v2 version marker v2" {
  let doc = parse("/- kdl-version 2\nnode \"value\"").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.name.value(), "node")
}

///|
test "v2 version marker v1" {
  let doc = parse("/- kdl-version 1\nnode \"value\"").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.name.value(), "node")
}

///|
test "v2 keyword #true" {
  let doc = parse("node #true").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.entries.length(), 1)
  assert_true(node.entries[0].value is Bool(true))
}

///|
test "v2 keyword #false" {
  let doc = parse("node #false").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.entries.length(), 1)
  assert_true(node.entries[0].value is Bool(false))
}

///|
test "v2 keyword #null" {
  let doc = parse("node #null").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.entries.length(), 1)
  assert_true(node.entries[0].value is Null)
}

///|
test "v2 keyword #inf" {
  let doc = parse("node #inf").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.entries.length(), 1)
  assert_true(node.entries[0].value is Float(_))
}

///|
test "v2 keyword #-inf" {
  let doc = parse("node #-inf").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.entries.length(), 1)
  assert_true(node.entries[0].value is Float(_))
}

///|
test "v2 keyword #nan" {
  let doc = parse("node #nan").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.entries.length(), 1)
  assert_true(node.entries[0].value is Float(_))
}

///|
test "v2 keyword property #true" {
  let doc = parse("node key=#true").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.entries.length(), 1)
  assert_true(node.entries[0].is_prop())
  assert_true(node.entries[0].value is Bool(true))
}

///|
test "v2 slashdash node" {
  let doc = parse("/- node \"hidden\"\nvisible").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.name.value(), "visible")
}

///|
test "v2 slashdash argument" {
  let doc = parse("node /- \"hidden\" \"visible\"").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.entries.length(), 1)
  assert_true(node.entries[0].value is String("visible"))
}

///|
test "v2 slashdash property" {
  let doc = parse("node /- key=\"hidden\" visible").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.entries.length(), 1)
  assert_true(node.entries[0].value is String("visible"))
}

///|
test "v2 slashdash children" {
  let doc = parse("node /- { child1 child2 }").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.children, None)
}

///|
test "v2 slashdash children with other children" {
  let doc = parse("node /- { hidden } { visible }").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_true(node.children is Some(_))
  assert_eq(node.children.unwrap().length(), 1)
  assert_eq(node.children.unwrap()[0].name.value(), "visible")
}

///|
test "v2 type annotation" {
  let doc = parse("(type)node").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_true(node.ty is Some(_))
  assert_eq(node.ty.unwrap().value(), "type")
}

///|
test "v2 type annotation with value" {
  let doc = parse("node (u8)42").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.entries.length(), 1)
  assert_true(node.entries[0].ty is Some(_))
  assert_true(node.entries[0].value is Integer(42L))
}

///|
test "detect_version v2 keyword" {
  assert_eq(detect_version("node #true"), 2)
  assert_eq(detect_version("node #false"), 2)
  assert_eq(detect_version("node #null"), 2)
  assert_eq(detect_version("node #inf"), 2)
  assert_eq(detect_version("node #-inf"), 2)
  assert_eq(detect_version("node #nan"), 2)
}

///|
test "detect_version v2 multiline" {
  assert_eq(detect_version("node \"\"\"\n    text\n    \"\"\""), 2)
}

///|
test "detect_version v2 marker" {
  assert_eq(detect_version("/- kdl-version 2\nnode"), 2)
}

///|
test "detect_version v1 marker" {
  assert_eq(detect_version("/- kdl-version 1\nnode"), 1)
}

///|
test "detect_version v1 default" {
  assert_eq(detect_version("node \"value\""), 1)
  assert_eq(detect_version("node 42"), 1)
  assert_eq(detect_version("node true"), 1)
}

///|
test "parse_v2 basic" {
  let doc = parse_v2("node #true key=#false").unwrap()
  assert_eq(doc.nodes().length(), 1)
  let node = doc.nodes()[0]
  assert_eq(node.name.value(), "node")
  assert_eq(node.entries.length(), 2)
  assert_true(node.entries[0].value is Bool(true))
  assert_true(node.entries[1].value is Bool(false))
}

///|
test "version marker v1 stored" {
  let doc = parse("/- kdl-version 1\nnode \"value\"").unwrap()
  assert_eq(doc.get_version(), Some(1))
  assert_eq(doc.nodes().length(), 1)
}

///|
test "version marker v2 stored" {
  let doc = parse("/- kdl-version 2\nnode \"value\"").unwrap()
  assert_eq(doc.get_version(), Some(2))
  assert_eq(doc.nodes().length(), 1)
}

///|
test "no version marker returns None" {
  let doc = parse("node \"value\"").unwrap()
  assert_eq(doc.get_version(), None)
}

///|
test "version marker v1 with leading whitespace" {
  let doc = parse("  /- kdl-version 1\nnode").unwrap()
  assert_eq(doc.get_version(), Some(1))
}

///|
test "version marker followed by multiple nodes" {
  let doc = parse("/- kdl-version 1\nfoo\nbar").unwrap()
  assert_eq(doc.get_version(), Some(1))
  assert_eq(doc.nodes().length(), 2)
}
