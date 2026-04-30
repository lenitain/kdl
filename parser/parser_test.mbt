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
