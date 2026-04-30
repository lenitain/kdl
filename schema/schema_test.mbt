///|
test "parse minimal schema with document node" {
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::new(@lenitain/kdl.KdlIdentifier::new("document")),
  )
  let result = parse_schema(doc)
  assert_true(result is Ok(_))
}

///|
test "parse schema with info" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let info = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("info"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("title"),
        @lenitain/kdl.KdlValue::String("Test Schema"),
      ),
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("description"),
        @lenitain/kdl.KdlValue::String("A test schema"),
      ),
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("version"),
        @lenitain/kdl.KdlValue::String("1.0"),
      ),
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("author"),
        @lenitain/kdl.KdlValue::String("Test Author"),
      ),
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("license"),
        @lenitain/kdl.KdlValue::String("MIT"),
      ),
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("url"),
        @lenitain/kdl.KdlValue::String("https://example.com"),
      ),
    ],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [info],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) => {
      assert_eq(schema.info.title, Some("Test Schema"))
      assert_eq(schema.info.description, Some("A test schema"))
      assert_eq(schema.info.version, Some("1.0"))
      assert_eq(schema.info.author, Some("Test Author"))
      assert_eq(schema.info.license, Some("MIT"))
      assert_eq(schema.info.url, Some("https://example.com"))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse node schema with validations" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let type_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("type"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("string"))],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [type_node],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("my-node"),
    ),
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) => {
      assert_eq(schema.nodes.length(), 1)
      assert_eq(schema.nodes[0].name, Some("my-node"))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse prop schema" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let prop = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("prop"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("key"),
        @lenitain/kdl.KdlValue::String("name"),
      ),
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("required"),
        @lenitain/kdl.KdlValue::Bool(true),
      ),
    ],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [prop],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) => {
      assert_eq(schema.nodes.length(), 1)
      assert_eq(schema.nodes[0].props.length(), 1)
      assert_eq(schema.nodes[0].props[0].key, Some("name"))
      assert_true(schema.nodes[0].props[0].required)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse value schema" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let value_schema = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("min"),
        @lenitain/kdl.KdlValue::Integer(1L),
      ),
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("max"),
        @lenitain/kdl.KdlValue::Integer(5L),
      ),
    ],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) => {
      assert_eq(schema.nodes.length(), 1)
      assert_eq(schema.nodes[0].values.length(), 1)
      assert_eq(schema.nodes[0].values[0].min, Some(1))
      assert_eq(schema.nodes[0].values[0].max, Some(5))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse children schema" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let child_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("name"),
        @lenitain/kdl.KdlValue::String("child"),
      ),
    ],
  )
  let children_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("children"),
    [child_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [children_schema],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) => {
      assert_eq(schema.nodes.length(), 1)
      match schema.nodes[0].children {
        Some(ch) => {
          assert_eq(ch.nodes.length(), 1)
          assert_eq(ch.nodes[0].name, Some("child"))
        }
        None => assert_true(false)
      }
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse definitions" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let def_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("name"),
        @lenitain/kdl.KdlValue::String("reusable"),
      ),
    ],
  )
  let defs = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("definitions"),
    [def_node],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [defs],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) => {
      assert_eq(schema.definitions.nodes.length(), 1)
      assert_eq(schema.definitions.nodes[0].name, Some("reusable"))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "missing document node returns error" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let result = parse_schema(doc)
  assert_true(result is Err(_))
}

///|
test "parse node with min/max children" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let node_schema = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("name"),
        @lenitain/kdl.KdlValue::String("items"),
      ),
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("min"),
        @lenitain/kdl.KdlValue::Integer(1L),
      ),
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("max"),
        @lenitain/kdl.KdlValue::Integer(10L),
      ),
    ],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) => {
      assert_eq(schema.nodes.length(), 1)
      assert_eq(schema.nodes[0].min, Some(1))
      assert_eq(schema.nodes[0].max, Some(10))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse validation type constraint" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let type_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("type"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("number"))],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [type_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) =>
      assert_eq(
        schema.nodes[0].values[0].validation.type_constraint,
        Some("number"),
      )
    Err(_) => assert_true(false)
  }
}

///|
test "parse validation enum" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let enum_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("enum"),
    [
      @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("a")),
      @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("b")),
      @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("c")),
    ],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [enum_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) =>
      match schema.nodes[0].values[0].validation.enum_values {
        Some(vals) => assert_eq(vals.length(), 3)
        None => assert_true(false)
      }
    Err(_) => assert_true(false)
  }
}

///|
test "parse other-nodes-allowed and other-tags-allowed" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let ona = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("other-nodes-allowed"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Bool(true))],
  )
  let ota = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("other-tags-allowed"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Bool(true))],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [ona, ota],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) => {
      assert_true(schema.other_nodes_allowed)
      assert_true(schema.other_tags_allowed)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse tag schema" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let tag_schema = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("tag"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("name"),
        @lenitain/kdl.KdlValue::String("my-tag"),
      ),
    ],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [tag_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) => {
      assert_eq(schema.tags.length(), 1)
      assert_eq(schema.tags[0].name, Some("my-tag"))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse node-names validation" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let pattern_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("pattern"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("^[a-z]+$"))],
  )
  let nn = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node-names"),
    [pattern_node],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [nn],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) =>
      match schema.node_names_validation {
        Some(v) => assert_eq(v.pattern, Some("^[a-z]+$"))
        None => assert_true(false)
      }
    Err(_) => assert_true(false)
  }
}

///|
test "parse definitions with props, values, children, tags" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let prop = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("prop"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("key"),
        @lenitain/kdl.KdlValue::String("x"),
      ),
    ],
  )
  let val = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [],
  )
  let ch = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("children"),
    [],
  )
  let tag = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("tag"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("name"),
        @lenitain/kdl.KdlValue::String("t"),
      ),
    ],
  )
  let defs = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("definitions"),
    [prop, val, ch, tag],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [defs],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) => {
      assert_eq(schema.definitions.props.length(), 1)
      assert_eq(schema.definitions.values.length(), 1)
      assert_eq(schema.definitions.children.length(), 1)
      assert_eq(schema.definitions.tags.length(), 1)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse tag-names validation" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let type_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("type"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("string"))],
  )
  let tn = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("tag-names"),
    [type_node],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [tn],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) =>
      match schema.tag_names_validation {
        Some(v) => assert_eq(v.type_constraint, Some("string"))
        None => assert_true(false)
      }
    Err(_) => assert_true(false)
  }
}

///|
test "parse pattern validation" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let pattern_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("pattern"),
    [
      @lenitain/kdl.KdlEntry::new(
        @lenitain/kdl.KdlValue::String("^[a-z]+-\\d+$"),
      ),
    ],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [pattern_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) =>
      assert_eq(
        schema.nodes[0].values[0].validation.pattern,
        Some("^[a-z]+-\\d+$"),
      )
    Err(_) => assert_true(false)
  }
}

///|
test "parse format validation" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let format_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("format"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("date-time"))],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [format_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) =>
      assert_eq(schema.nodes[0].values[0].validation.format, Some("date-time"))
    Err(_) => assert_true(false)
  }
}

///|
test "parse numeric operators >, >=, <, <=" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let gt_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new(">"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Float(0.0))],
  )
  let gte_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new(">="),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Integer(1L))],
  )
  let lt_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("<"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Float(100.5))],
  )
  let lte_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("<="),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Integer(50L))],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [gt_node, gte_node, lt_node, lte_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) => {
      let v = schema.nodes[0].values[0].validation
      assert_true(v.gt is Some(0.0))
      assert_true(v.gte is Some(1.0))
      assert_true(v.lt is Some(100.5))
      assert_true(v.lte is Some(50.0))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse modulus with divisor and remainder" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let mod_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("%"),
    [
      @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Integer(3L)),
      @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Integer(0L)),
    ],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [mod_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) => {
      let v = schema.nodes[0].values[0].validation
      assert_true(v.modulus_divisor is Some(3.0))
      assert_true(v.modulus_remainder is Some(0.0))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse ref_ on prop, value, children, node" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let prop = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("prop"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("key"),
        @lenitain/kdl.KdlValue::String("x"),
      ),
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("ref"),
        @lenitain/kdl.KdlValue::String("#/definitions/props/x-prop"),
      ),
    ],
  )
  let value = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("ref"),
        @lenitain/kdl.KdlValue::String("#/definitions/values/x-val"),
      ),
    ],
  )
  let children = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("children"),
    [
      @lenitain/kdl.KdlNode::with_entries(
        @lenitain/kdl.KdlIdentifier::new("node-names"),
        [],
      ),
    ],
  )
  children.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("ref"),
      @lenitain/kdl.KdlValue::String("#/definitions/children/x-ch"),
    ),
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [prop, value, children],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("my-node"),
    ),
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("ref"),
      @lenitain/kdl.KdlValue::String("#/definitions/nodes/x-node"),
    ),
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) => {
      assert_eq(schema.nodes[0].ref_, Some("#/definitions/nodes/x-node"))
      assert_eq(
        schema.nodes[0].props[0].ref_,
        Some("#/definitions/props/x-prop"),
      )
      assert_eq(
        schema.nodes[0].values[0].ref_,
        Some("#/definitions/values/x-val"),
      )
      match schema.nodes[0].children {
        Some(ch) => assert_eq(ch.ref_, Some("#/definitions/children/x-ch"))
        None => assert_true(false)
      }
    }
    Err(_) => assert_true(false)
  }
}

///|
test "parse tag with nested validations" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let type_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("type"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("string"))],
  )
  let enum_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("enum"),
    [
      @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("foo")),
      @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("bar")),
    ],
  )
  let tag_val_node = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("tag"),
    [type_node, enum_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [tag_val_node],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("my-node"),
    ),
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) =>
      match schema.nodes[0].tag_validation {
        Some(tv) =>
          match tv.tag {
            Some(nested) => {
              assert_eq(nested.type_constraint, Some("string"))
              match nested.enum_values {
                Some(vals) => assert_eq(vals.length(), 2)
                None => assert_true(false)
              }
            }
            None => assert_true(false)
          }
        None => assert_true(false)
      }
    Err(_) => assert_true(false)
  }
}

///|
test "parse prop-names validation" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let pattern_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("pattern"),
    [
      @lenitain/kdl.KdlEntry::new(
        @lenitain/kdl.KdlValue::String("^[a-z][a-z0-9-]*$"),
      ),
    ],
  )
  let pn = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("prop-names"),
    [pattern_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [pn],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("my-node"),
    ),
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) =>
      match schema.nodes[0].prop_names_validation {
        Some(v) => assert_eq(v.pattern, Some("^[a-z][a-z0-9-]*$"))
        None => assert_true(false)
      }
    Err(_) => assert_true(false)
  }
}

///|
test "parse other-props-allowed at node level" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let opa = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("other-props-allowed"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Bool(true))],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [opa],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("my-node"),
    ),
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) => assert_true(schema.nodes[0].other_props_allowed)
    Err(_) => assert_true(false)
  }
}

///|
test "enum_values concatenation in merge" {
  let doc = @lenitain/kdl.KdlDocument::new()
  let enum1 = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("enum"),
    [
      @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("a")),
      @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("b")),
    ],
  )
  let enum2 = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("enum"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("c"))],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [enum1, enum2],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      [node_schema],
    ),
  )
  let result = parse_schema(doc)
  match result {
    Ok(schema) =>
      match schema.nodes[0].values[0].validation.enum_values {
        Some(vals) => assert_eq(vals.length(), 3)
        None => assert_true(false)
      }
    Err(_) => assert_true(false)
  }
}

// ========== Validation Tests ==========

///|
fn make_schema_doc(
  children : Array[@lenitain/kdl.KdlNode],
) -> @lenitain/kdl.KdlDocument {
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("document"),
      children,
    ),
  )
  doc
}

///|
test "valid document passes validation" {
  let type_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("type"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("string"))],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [type_node],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("greeting"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("greeting"),
      [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("hello"))],
    ),
  )
  assert_true(validate(doc, schema) is Ok(_))
}

///|
test "missing required node fails" {
  let node_schema = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("name"),
        @lenitain/kdl.KdlValue::String("required-node"),
      ),
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("min"),
        @lenitain/kdl.KdlValue::Integer(1L),
      ),
    ],
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "extra node fails when other_nodes_allowed is false" {
  let node_schema = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("name"),
        @lenitain/kdl.KdlValue::String("allowed"),
      ),
    ],
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::new(@lenitain/kdl.KdlIdentifier::new("allowed")),
  )
  doc.push(
    @lenitain/kdl.KdlNode::new(@lenitain/kdl.KdlIdentifier::new("extra")),
  )
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "extra node allowed when other_nodes_allowed is true" {
  let ona = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("other-nodes-allowed"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Bool(true))],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("name"),
        @lenitain/kdl.KdlValue::String("allowed"),
      ),
    ],
  )
  let schema_doc = make_schema_doc([ona, node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::new(@lenitain/kdl.KdlIdentifier::new("allowed")),
  )
  doc.push(
    @lenitain/kdl.KdlNode::new(@lenitain/kdl.KdlIdentifier::new("extra")),
  )
  assert_true(validate(doc, schema) is Ok(_))
}

///|
test "missing required prop fails" {
  let prop = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("prop"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("key"),
        @lenitain/kdl.KdlValue::String("name"),
      ),
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("required"),
        @lenitain/kdl.KdlValue::Bool(true),
      ),
    ],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [prop],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("person"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::new(@lenitain/kdl.KdlIdentifier::new("person")),
  )
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "extra prop fails when other_props_allowed is false" {
  let prop = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("prop"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("key"),
        @lenitain/kdl.KdlValue::String("name"),
      ),
    ],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [prop],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("person"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("person"),
      [
        @lenitain/kdl.KdlEntry::new_prop(
          @lenitain/kdl.KdlIdentifier::new("name"),
          @lenitain/kdl.KdlValue::String("Alice"),
        ),
        @lenitain/kdl.KdlEntry::new_prop(
          @lenitain/kdl.KdlIdentifier::new("age"),
          @lenitain/kdl.KdlValue::Integer(30L),
        ),
      ],
    ),
  )
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "type mismatch fails" {
  let type_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("type"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("number"))],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [type_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("count"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("count"),
      [
        @lenitain/kdl.KdlEntry::new(
          @lenitain/kdl.KdlValue::String("not-a-number"),
        ),
      ],
    ),
  )
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "type match passes" {
  let type_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("type"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("number"))],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [type_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("count"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("count"),
      [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Integer(42L))],
    ),
  )
  assert_true(validate(doc, schema) is Ok(_))
}

///|
test "enum value not in list fails" {
  let enum_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("enum"),
    [
      @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("red")),
      @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("green")),
      @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("blue")),
    ],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [enum_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("color"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("color"),
      [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("yellow"))],
    ),
  )
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "enum value in list passes" {
  let enum_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("enum"),
    [
      @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("red")),
      @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("green")),
      @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("blue")),
    ],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [enum_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("color"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("color"),
      [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("red"))],
    ),
  )
  assert_true(validate(doc, schema) is Ok(_))
}

///|
test "pattern mismatch fails" {
  let pattern_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("pattern"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("^[a-z]+$"))],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [pattern_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("id"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("id"),
      [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("ABC123"))],
    ),
  )
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "pattern match passes" {
  let pattern_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("pattern"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("^[a-z]+$"))],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [pattern_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("id"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("id"),
      [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("hello"))],
    ),
  )
  assert_true(validate(doc, schema) is Ok(_))
}

///|
test "string length validation - too short" {
  let min_len = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("min-length"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Integer(3L))],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [min_len],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("name"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("name"),
      [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("ab"))],
    ),
  )
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "string length validation - too long" {
  let max_len = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("max-length"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Integer(5L))],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [max_len],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("name"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("name"),
      [
        @lenitain/kdl.KdlEntry::new(
          @lenitain/kdl.KdlValue::String("toolongvalue"),
        ),
      ],
    ),
  )
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "string length validation - passes" {
  let min_len = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("min-length"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Integer(2L))],
  )
  let max_len = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("max-length"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Integer(10L))],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [min_len, max_len],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("name"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("name"),
      [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("hello"))],
    ),
  )
  assert_true(validate(doc, schema) is Ok(_))
}

///|
test "numeric comparison - gt fails" {
  let gt_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new(">"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Integer(10L))],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [gt_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("num"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("num"),
      [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Integer(10L))],
    ),
  )
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "numeric comparison - gt passes" {
  let gt_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new(">"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Integer(10L))],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [gt_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("num"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("num"),
      [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Integer(11L))],
    ),
  )
  assert_true(validate(doc, schema) is Ok(_))
}

///|
test "numeric comparison - lte fails" {
  let lte_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("<="),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Integer(100L))],
  )
  let value_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [lte_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("num"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("num"),
      [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::Integer(101L))],
    ),
  )
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "value count validation - min fails" {
  let value_schema = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("min"),
        @lenitain/kdl.KdlValue::Integer(2L),
      ),
    ],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("items"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("items"),
      [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("a"))],
    ),
  )
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "value count validation - max fails" {
  let value_schema = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("value"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("max"),
        @lenitain/kdl.KdlValue::Integer(2L),
      ),
    ],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [value_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("items"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("items"),
      [
        @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("a")),
        @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("b")),
        @lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("c")),
      ],
    ),
  )
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "children validation - missing required child" {
  let child_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("name"),
        @lenitain/kdl.KdlValue::String("item"),
      ),
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("min"),
        @lenitain/kdl.KdlValue::Integer(1L),
      ),
    ],
  )
  let children_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("children"),
    [child_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [children_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("container"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::new(@lenitain/kdl.KdlIdentifier::new("container")),
  )
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "children validation - passes with required child" {
  let child_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("name"),
        @lenitain/kdl.KdlValue::String("item"),
      ),
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("min"),
        @lenitain/kdl.KdlValue::Integer(1L),
      ),
    ],
  )
  let children_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("children"),
    [child_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [children_schema],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("container"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_children(
      @lenitain/kdl.KdlIdentifier::new("container"),
      [@lenitain/kdl.KdlNode::new(@lenitain/kdl.KdlIdentifier::new("item"))],
    ),
  )
  assert_true(validate(doc, schema) is Ok(_))
}

///|
test "tag validation fails" {
  let type_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("type"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("string"))],
  )
  let enum_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("enum"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("my-tag"))],
  )
  let tag_val = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("tag"),
    [type_node, enum_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [tag_val],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("tagged"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  let tagged_node = @lenitain/kdl.KdlNode::full(
    Some(@lenitain/kdl.KdlIdentifier::new("wrong-tag")),
    @lenitain/kdl.KdlIdentifier::new("tagged"),
    [],
    None,
  )
  doc.push(tagged_node)
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "tag validation passes" {
  let type_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("type"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("string"))],
  )
  let enum_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("enum"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("my-tag"))],
  )
  let tag_val = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("tag"),
    [type_node, enum_node],
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [tag_val],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("tagged"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  let tagged_node = @lenitain/kdl.KdlNode::full(
    Some(@lenitain/kdl.KdlIdentifier::new("my-tag")),
    @lenitain/kdl.KdlIdentifier::new("tagged"),
    [],
    None,
  )
  doc.push(tagged_node)
  assert_true(validate(doc, schema) is Ok(_))
}

///|
test "node count max fails" {
  let node_schema = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("name"),
        @lenitain/kdl.KdlValue::String("item"),
      ),
      @lenitain/kdl.KdlEntry::new_prop(
        @lenitain/kdl.KdlIdentifier::new("max"),
        @lenitain/kdl.KdlValue::Integer(2L),
      ),
    ],
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(@lenitain/kdl.KdlNode::new(@lenitain/kdl.KdlIdentifier::new("item")))
  doc.push(@lenitain/kdl.KdlNode::new(@lenitain/kdl.KdlIdentifier::new("item")))
  doc.push(@lenitain/kdl.KdlNode::new(@lenitain/kdl.KdlIdentifier::new("item")))
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "prop value validation passes" {
  let type_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("type"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("string"))],
  )
  let prop = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("prop"),
    [type_node],
  )
  prop.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("key"),
      @lenitain/kdl.KdlValue::String("name"),
    ),
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [prop],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("person"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("person"),
      [
        @lenitain/kdl.KdlEntry::new_prop(
          @lenitain/kdl.KdlIdentifier::new("name"),
          @lenitain/kdl.KdlValue::String("Alice"),
        ),
      ],
    ),
  )
  assert_true(validate(doc, schema) is Ok(_))
}

///|
test "prop value validation fails on type mismatch" {
  let type_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("type"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("string"))],
  )
  let prop = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("prop"),
    [type_node],
  )
  prop.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("key"),
      @lenitain/kdl.KdlValue::String("name"),
    ),
  )
  let node_schema = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node"),
    [prop],
  )
  node_schema.entries.push(
    @lenitain/kdl.KdlEntry::new_prop(
      @lenitain/kdl.KdlIdentifier::new("name"),
      @lenitain/kdl.KdlValue::String("person"),
    ),
  )
  let schema_doc = make_schema_doc([node_schema])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::with_entries(
      @lenitain/kdl.KdlIdentifier::new("person"),
      [
        @lenitain/kdl.KdlEntry::new_prop(
          @lenitain/kdl.KdlIdentifier::new("name"),
          @lenitain/kdl.KdlValue::Integer(42L),
        ),
      ],
    ),
  )
  assert_true(validate(doc, schema) is Err(_))
}

///|
test "node-names validation" {
  let pattern_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("pattern"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("^[a-z]+$"))],
  )
  let nn = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node-names"),
    [pattern_node],
  )
  let schema_doc = make_schema_doc([nn])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(@lenitain/kdl.KdlNode::new(@lenitain/kdl.KdlIdentifier::new("abc")))
  assert_true(validate(doc, schema) is Ok(_))
}

///|
test "node-names validation fails" {
  let pattern_node = @lenitain/kdl.KdlNode::with_entries(
    @lenitain/kdl.KdlIdentifier::new("pattern"),
    [@lenitain/kdl.KdlEntry::new(@lenitain/kdl.KdlValue::String("^[a-z]+$"))],
  )
  let nn = @lenitain/kdl.KdlNode::with_children(
    @lenitain/kdl.KdlIdentifier::new("node-names"),
    [pattern_node],
  )
  let schema_doc = make_schema_doc([nn])
  let schema = match parse_schema(schema_doc) {
    Ok(s) => s
    Err(_) => abort("schema parse failed")
  }
  let doc = @lenitain/kdl.KdlDocument::new()
  doc.push(
    @lenitain/kdl.KdlNode::new(@lenitain/kdl.KdlIdentifier::new("ABC123")),
  )
  assert_true(validate(doc, schema) is Err(_))
}
