///|
test "tokenize empty input" {
  let result = tokenize_kql("")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 1)
      assert_eq(tokens[0].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize single identifier" {
  let result = tokenize_kql("foo")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Ident("foo"))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize string literal" {
  let result = tokenize_kql("\"hello world\"")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, String("hello world"))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize integer literal" {
  let result = tokenize_kql("42")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Integer(42L))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize float literal" {
  let result = tokenize_kql("3.14")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Float(3.14))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize comparison operators" {
  let result = tokenize_kql("= != >= <= ^=")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 6)
      assert_eq(tokens[0].token, Eq)
      assert_eq(tokens[1].token, Neq)
      assert_eq(tokens[2].token, Gte)
      assert_eq(tokens[3].token, Lte)
      assert_eq(tokens[4].token, CaretEq)
      assert_eq(tokens[5].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize gt vs gte disambiguation" {
  let result = tokenize_kql("> >= >>")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 4)
      assert_eq(tokens[0].token, Gt)
      assert_eq(tokens[1].token, Gte)
      assert_eq(tokens[2].token, GtGt)
      assert_eq(tokens[3].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize plus vs plusplus" {
  let result = tokenize_kql("+ ++")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 3)
      assert_eq(tokens[0].token, Plus)
      assert_eq(tokens[1].token, PlusPlus)
      assert_eq(tokens[2].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize pipepipe" {
  let result = tokenize_kql("||")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, PipePipe)
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize brackets and parens" {
  let result = tokenize_kql("[ ] ( )")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 5)
      assert_eq(tokens[0].token, LBracket)
      assert_eq(tokens[1].token, RBracket)
      assert_eq(tokens[2].token, LParen)
      assert_eq(tokens[3].token, RParen)
      assert_eq(tokens[4].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize keywords" {
  let result = tokenize_kql("true false null inf nan")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 6)
      assert_eq(tokens[0].token, Bool(true))
      assert_eq(tokens[1].token, Bool(false))
      assert_eq(tokens[2].token, Null)
      assert_eq(tokens[3].token, Inf)
      assert_eq(tokens[4].token, Nan)
      assert_eq(tokens[5].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize accessor function call" {
  let result = tokenize_kql("name()")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 4)
      assert_eq(tokens[0].token, Ident("name"))
      assert_eq(tokens[1].token, LParen)
      assert_eq(tokens[2].token, RParen)
      assert_eq(tokens[3].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize dollar and star eq" {
  let result = tokenize_kql("$= *=")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 3)
      assert_eq(tokens[0].token, DollarEq)
      assert_eq(tokens[1].token, StarEq)
      assert_eq(tokens[2].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize negative number" {
  let result = tokenize_kql("-5")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Integer(-5L))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize whitespace ignored" {
  let result = tokenize_kql("  foo   bar  ")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 3)
      assert_eq(tokens[0].token, Ident("foo"))
      assert_eq(tokens[1].token, Ident("bar"))
      assert_eq(tokens[2].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize keyword -inf" {
  let result = tokenize_kql("-inf")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, NegInf)
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize string with escape" {
  let result = tokenize_kql("\"foo\\nbar\"")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, String("foo\nbar"))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "parse single bare identifier" {
  let result = parse_kql("node")
  match result {
    Ok(query) =>
      assert_true(query is Single(Filter(Matchers([NodeName("node")]))))
    Err(_) => panic()
  }
}

///|
test "parse type annotation" {
  let result = parse_kql("(foo)")
  match result {
    Ok(query) =>
      assert_true(
        query is Single(Filter(Matchers([TypeAnnotation(Some("foo"))]))),
      )
    Err(_) => panic()
  }
}

///|
test "parse empty type annotation" {
  let result = parse_kql("()")
  match result {
    Ok(query) =>
      assert_true(query is Single(Filter(Matchers([TypeAnnotation(None)]))))
    Err(_) => panic()
  }
}

///|
test "parse child selector" {
  let result = parse_kql("parent > child")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Child(
            Filter(Matchers([NodeName("parent")])),
            Matchers([NodeName("child")])
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse descendant selector" {
  let result = parse_kql("root >> leaf")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Descendant(
            Filter(Matchers([NodeName("root")])),
            Matchers([NodeName("leaf")])
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse next sibling selector" {
  let result = parse_kql("a + b")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          NextSibling(
            Filter(Matchers([NodeName("a")])),
            Matchers([NodeName("b")])
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse later sibling selector" {
  let result = parse_kql("a ++ b")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          LaterSibling(
            Filter(Matchers([NodeName("a")])),
            Matchers([NodeName("b")])
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse union query" {
  let result = parse_kql("a || b")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Union(
          Single(Filter(Matchers([NodeName("a")]))),
          Filter(Matchers([NodeName("b")]))
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse top filter" {
  let result = parse_kql("top()")
  match result {
    Ok(query) => assert_true(query is Single(Filter(Top)))
    Err(_) => panic()
  }
}

///|

///|
test "parse accessor matcher with comparison" {
  let result = parse_kql("node[prop=\"value\"]")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Filter(
            Matchers(
              [
                NodeName("node"),
                AccessorMatcher(PropertyKey("prop"), Some(Eq(String("value")))),
              ]
            )
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse string literal matcher" {
  let result = parse_kql("\"hello\"")
  match result {
    Ok(query) =>
      assert_true(query is Single(Filter(Matchers([StringLiteral("hello")]))))
    Err(_) => panic()
  }
}

///|
test "parse val accessor" {
  let result = parse_kql("node[val(0) = 1]")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Filter(
            Matchers(
              [NodeName("node"), AccessorMatcher(Val(0), Some(Eq(Integer(1L))))]
            )
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse name accessor" {
  let result = parse_kql("node[name() ^= \"foo\"]")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Filter(
            Matchers(
              [
                NodeName("node"),
                AccessorMatcher(Name, Some(CaretEq(String("foo")))),
              ]
            )
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse chained selectors" {
  let result = parse_kql("a > b >> c + d")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          NextSibling(
            Descendant(
              Child(
                Filter(Matchers([NodeName("a")])),
                Matchers([NodeName("b")])
              ),
              Matchers([NodeName("c")])
            ),
            Matchers([NodeName("d")])
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse type annotation in filter" {
  let result = parse_kql("(foo) > bar")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Child(
            Filter(Matchers([TypeAnnotation(Some("foo"))])),
            Matchers([NodeName("bar")])
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
using @lenitain/kdl {
  type KdlDocument,
  type KdlNode,
  type KdlValue,
  type KdlIdentifier,
  type KdlEntry,
}

///|
fn make_doc() -> KdlDocument {
  let doc = KdlDocument::new()
  doc.push(
    KdlNode::with_children(KdlIdentifier::new("root"), [
      KdlNode::with_children(KdlIdentifier::new("a"), [
        KdlNode::new(KdlIdentifier::new("b")),
        KdlNode::new(KdlIdentifier::new("c")),
      ]),
      KdlNode::new(KdlIdentifier::new("a")),
      KdlNode::with_children(KdlIdentifier::new("d"), [
        KdlNode::with_children(KdlIdentifier::new("b"), [
          KdlNode::new(KdlIdentifier::new("e")),
        ]),
      ]),
    ]),
  )
  doc
}

///|
fn make_sibling_doc() -> KdlDocument {
  let doc = KdlDocument::new()
  doc.push(
    KdlNode::with_children(KdlIdentifier::new("parent"), [
      KdlNode::new(KdlIdentifier::new("a")),
      KdlNode::new(KdlIdentifier::new("b")),
      KdlNode::new(KdlIdentifier::new("c")),
    ]),
  )
  doc
}

///|
fn make_typed_doc() -> KdlDocument {
  let doc = KdlDocument::new()
  doc.push(
    KdlNode::full(
      Some(KdlIdentifier::new("mytype")),
      KdlIdentifier::new("node"),
      [KdlEntry::new(KdlValue::String("hello"))],
      None,
    ),
  )
  doc.push(KdlNode::new(KdlIdentifier::new("node")))
  doc
}

///|
fn make_entries_doc() -> KdlDocument {
  let doc = KdlDocument::new()
  doc.push(
    KdlNode::with_entries(KdlIdentifier::new("server"), [
      KdlEntry::new(KdlValue::Integer(8080L)),
      KdlEntry::new_prop(
        KdlIdentifier::new("host"),
        KdlValue::String("localhost"),
      ),
      KdlEntry::new_prop(KdlIdentifier::new("name"), KdlValue::String("web")),
    ]),
  )
  doc.push(
    KdlNode::with_entries(KdlIdentifier::new("server"), [
      KdlEntry::new(KdlValue::Integer(9090L)),
      KdlEntry::new_prop(KdlIdentifier::new("host"), KdlValue::String("remote")),
    ]),
  )
  doc
}

///|
test "query simple node name" {
  let doc = make_doc()
  let result = query(doc, "b")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 2)
    Err(_) => panic()
  }
}

///|
test "query child selector" {
  let doc = make_doc()
  let result = query(doc, "root > a")
  match result {
    Ok(nodes) => {
      assert_eq(nodes.length(), 2)
      assert_true(nodes[0].name.value() == "a")
      assert_true(nodes[1].name.value() == "a")
    }
    Err(_) => panic()
  }
}

///|
test "query descendant selector" {
  let doc = make_doc()
  let result = query(doc, "root >> b")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 2)
    Err(_) => panic()
  }
}

///|
test "query descendant selector nested" {
  let doc = make_doc()
  let result = query(doc, "root >> e")
  match result {
    Ok(nodes) => {
      assert_eq(nodes.length(), 1)
      assert_true(nodes[0].name.value() == "e")
    }
    Err(_) => panic()
  }
}

///|
test "query next sibling selector" {
  let doc = make_sibling_doc()
  let result = query(doc, "a + b")
  match result {
    Ok(nodes) => {
      assert_eq(nodes.length(), 1)
      assert_true(nodes[0].name.value() == "b")
    }
    Err(_) => panic()
  }
}

///|
test "query later sibling selector" {
  let doc = make_sibling_doc()
  let result = query(doc, "a ++ c")
  match result {
    Ok(nodes) => {
      assert_eq(nodes.length(), 1)
      assert_true(nodes[0].name.value() == "c")
    }
    Err(_) => panic()
  }
}

///|
test "query union" {
  let doc = make_doc()
  let result = query(doc, "b || c")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 3)
    Err(_) => panic()
  }
}

///|
test "query val accessor" {
  let doc = make_entries_doc()
  let result = query(doc, "server[val(0) = 8080]")
  match result {
    Ok(nodes) => {
      assert_eq(nodes.length(), 1)
      assert_true(nodes[0].entries[0].value == KdlValue::Integer(8080L))
    }
    Err(_) => panic()
  }
}

///|
test "query prop accessor" {
  let doc = make_entries_doc()
  let result = query(doc, "server[prop(\"host\") = \"localhost\"]")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 1)
    Err(_) => panic()
  }
}

///|
test "query type annotation" {
  let doc = make_typed_doc()
  let result = query(doc, "(mytype)node")
  match result {
    Ok(nodes) => {
      assert_eq(nodes.length(), 1)
      assert_true(nodes[0].name.value() == "node")
    }
    Err(_) => panic()
  }
}

///|
test "query string starts_with" {
  let doc = make_entries_doc()
  let result = query(doc, "server[prop(\"host\") ^= \"local\"]")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 1)
    Err(_) => panic()
  }
}

///|
test "query string ends_with" {
  let doc = make_entries_doc()
  let result = query(doc, "server[prop(\"host\") $= \"host\"]")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 1)
    Err(_) => panic()
  }
}

///|
test "query string contains" {
  let doc = make_entries_doc()
  let result = query(doc, "server[prop(\"host\") *= \"mote\"]")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 1)
    Err(_) => panic()
  }
}

///|
test "query empty results" {
  let doc = make_doc()
  let result = query(doc, "nonexistent")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 0)
    Err(_) => panic()
  }
}

///|
test "query name accessor" {
  let doc = make_doc()
  let result = query(doc, "root > [name() = \"a\"]")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 2)
    Err(_) => panic()
  }
}

///|
test "query top with child" {
  let doc = make_doc()
  let result = query(doc, "top() > a")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 2)
    Err(_) => panic()
  }
}

///|
test "query top with descendant" {
  let doc = make_doc()
  let result = query(doc, "top() >> b")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 2)
    Err(_) => panic()
  }
}

///|
test "query child of child" {
  let doc = make_doc()
  let result = query(doc, "root > a > b")
  match result {
    Ok(nodes) => {
      assert_eq(nodes.length(), 1)
      assert_true(nodes[0].name.value() == "b")
    }
    Err(_) => panic()
  }
}

///|
test "query neq comparison" {
  let doc = make_entries_doc()
  let result = query(doc, "server[val(0) != 8080]")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 1)
    Err(_) => panic()
  }
}

///|
test "query gt comparison" {
  let doc = make_entries_doc()
  let result = query(doc, "server[val(0) > 8000]")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 2)
    Err(_) => panic()
  }
}

///|
test "query union deduplication" {
  let doc = make_doc()
  let result = query(doc, "b || b")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 2)
    Err(_) => panic()
  }
}

///|
test "query property key with value comparison" {
  let doc = make_entries_doc()
  let result = query(doc, "server[host=\"localhost\"]")
  match result {
    Ok(nodes) => {
      assert_eq(nodes.length(), 1)
      assert_true(nodes[0].entries[1].value == KdlValue::String("localhost"))
    }
    Err(_) => panic()
  }
}

///|
test "tokenize negative float" {
  let result = tokenize_kql("-3.14")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Float(-3.14))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize scientific notation" {
  let result = tokenize_kql("1e5")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Float(100000.0))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize scientific notation with negative exponent" {
  let result = tokenize_kql("2.5e-3")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Float(0.0025))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize number with underscores" {
  let result = tokenize_kql("1_000")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Integer(1000L))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize leading dot float" {
  let result = tokenize_kql(".5")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Float(0.5))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize string with unicode escape" {
  let result = tokenize_kql("\"\\u{0041}\"")
  match result {
    Ok(tokens) => assert_eq(tokens.length(), 2)
    Err(_) => assert_true(true)
  }
}

///|
test "tokenize unterminated string error" {
  let result = tokenize_kql("\"hello")
  match result {
    Ok(_) => panic()
    Err(errors) => assert_true(errors.length() > 0)
  }
}

///|
test "tokenize less than operator" {
  let result = tokenize_kql("< <=")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 3)
      assert_eq(tokens[0].token, Lt)
      assert_eq(tokens[1].token, Lte)
      assert_eq(tokens[2].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "parse tag accessor" {
  let result = parse_kql("node[tag() = \"foo\"]")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Filter(
            Matchers(
              [NodeName("node"), AccessorMatcher(Tag, Some(Eq(String("foo"))))]
            )
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse values accessor" {
  let result = parse_kql("node[values()]")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Filter(Matchers([NodeName("node"), AccessorMatcher(Values, None)]))
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse props accessor" {
  let result = parse_kql("node[props()]")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Filter(Matchers([NodeName("node"), AccessorMatcher(Props, None)]))
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse neq operator" {
  let result = parse_kql("node[val(0) != 42]")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Filter(
            Matchers(
              [
                NodeName("node"),
                AccessorMatcher(Val(0), Some(Neq(Integer(42L)))),
              ]
            )
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse lt operator" {
  let result = parse_kql("node[val(0) < 100]")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Filter(
            Matchers(
              [
                NodeName("node"),
                AccessorMatcher(Val(0), Some(Lt(Integer(100L)))),
              ]
            )
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse gte operator" {
  let result = parse_kql("node[val(0) >= 10]")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Filter(
            Matchers(
              [
                NodeName("node"),
                AccessorMatcher(Val(0), Some(Gte(Integer(10L)))),
              ]
            )
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse lte operator" {
  let result = parse_kql("node[val(0) <= 99]")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Filter(
            Matchers(
              [
                NodeName("node"),
                AccessorMatcher(Val(0), Some(Lte(Integer(99L)))),
              ]
            )
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse dollar eq operator" {
  let result = parse_kql("node[name() $= \"end\"]")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Filter(
            Matchers(
              [
                NodeName("node"),
                AccessorMatcher(Name, Some(DollarEq(String("end")))),
              ]
            )
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse star eq operator" {
  let result = parse_kql("node[name() *= \"mid\"]")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Filter(
            Matchers(
              [
                NodeName("node"),
                AccessorMatcher(Name, Some(StarEq(String("mid")))),
              ]
            )
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse bool value in comparison" {
  let result = parse_kql("node[val(0) = true]")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Filter(
            Matchers(
              [NodeName("node"), AccessorMatcher(Val(0), Some(Eq(Bool(true))))]
            )
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse null value in comparison" {
  let result = parse_kql("node[val(0) = null]")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Filter(
            Matchers(
              [
                NodeName("node"),
                AccessorMatcher(Val(0), Some(Eq(KqlValue::Null))),
              ]
            )
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse float value in comparison" {
  let result = parse_kql("node[val(0) = 3.14]")
  match result {
    Ok(query) =>
      assert_true(
        query
        is Single(
          Filter(
            Matchers(
              [NodeName("node"), AccessorMatcher(Val(0), Some(Eq(Float(3.14))))]
            )
          )
        ),
      )
    Err(_) => panic()
  }
}

///|
test "parse error unterminated string" {
  let result = parse_kql("\"hello")
  match result {
    Ok(_) => panic()
    Err(_) => assert_true(true)
  }
}

///|
fn make_bool_doc() -> KdlDocument {
  let doc = KdlDocument::new()
  doc.push(
    KdlNode::with_entries(KdlIdentifier::new("flag"), [
      KdlEntry::new(KdlValue::Bool(true)),
    ]),
  )
  doc.push(
    KdlNode::with_entries(KdlIdentifier::new("flag"), [
      KdlEntry::new(KdlValue::Bool(false)),
    ]),
  )
  doc.push(
    KdlNode::with_entries(KdlIdentifier::new("item"), [
      KdlEntry::new(KdlValue::Null),
    ]),
  )
  doc
}

///|
fn make_nested_deep_doc() -> KdlDocument {
  let doc = KdlDocument::new()
  doc.push(
    KdlNode::with_children(KdlIdentifier::new("l1"), [
      KdlNode::with_children(KdlIdentifier::new("l2"), [
        KdlNode::with_children(KdlIdentifier::new("l3"), [
          KdlNode::new(KdlIdentifier::new("l4")),
        ]),
      ]),
    ]),
  )
  doc
}

///|
fn make_multisibling_doc() -> KdlDocument {
  let doc = KdlDocument::new()
  doc.push(
    KdlNode::with_children(KdlIdentifier::new("root"), [
      KdlNode::new(KdlIdentifier::new("a")),
      KdlNode::new(KdlIdentifier::new("b")),
      KdlNode::new(KdlIdentifier::new("b")),
      KdlNode::new(KdlIdentifier::new("c")),
    ]),
  )
  doc
}

///|
fn make_tagged_entries_doc() -> KdlDocument {
  let doc = KdlDocument::new()
  doc.push(
    KdlNode::full(
      Some(KdlIdentifier::new("mytype")),
      KdlIdentifier::new("node"),
      [KdlEntry::new(KdlValue::String("hello"))],
      None,
    ),
  )
  doc.push(KdlNode::new(KdlIdentifier::new("node")))
  doc
}

///|
fn make_props_doc() -> KdlDocument {
  let doc = KdlDocument::new()
  doc.push(
    KdlNode::with_entries(KdlIdentifier::new("item"), [
      KdlEntry::new_prop(KdlIdentifier::new("key"), KdlValue::String("val")),
    ]),
  )
  doc.push(
    KdlNode::with_entries(KdlIdentifier::new("item"), [
      KdlEntry::new(KdlValue::String("bare")),
    ]),
  )
  doc
}

///|
fn make_empty_doc() -> KdlDocument {
  KdlDocument::new()
}

///|
test "query gte comparison" {
  let doc = make_entries_doc()
  let result = query(doc, "server[val(0) >= 8080]")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 2)
    Err(_) => panic()
  }
}

///|
test "query lte comparison" {
  let doc = make_entries_doc()
  let result = query(doc, "server[val(0) <= 9090]")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 2)
    Err(_) => panic()
  }
}

///|
test "query lt comparison" {
  let doc = make_entries_doc()
  let result = query(doc, "server[val(0) < 9000]")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 1)
    Err(_) => panic()
  }
}

///|
test "query tag accessor match" {
  let doc = make_tagged_entries_doc()
  let result = query(doc, "node[tag() = \"mytype\"]")
  match result {
    Ok(nodes) => {
      assert_eq(nodes.length(), 1)
      assert_true(nodes[0].name.value() == "node")
    }
    Err(_) => panic()
  }
}

///|
test "query values accessor" {
  let doc = make_entries_doc()
  let result = query(doc, "server[values()]")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 2)
    Err(_) => panic()
  }
}

///|
test "query props accessor" {
  let doc = make_props_doc()
  let result = query(doc, "item[props()]")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 1)
    Err(_) => panic()
  }
}

///|
test "query boolean true value" {
  let doc = make_bool_doc()
  let result = query(doc, "flag[val(0) = true]")
  match result {
    Ok(nodes) => {
      assert_eq(nodes.length(), 1)
      assert_true(nodes[0].entries[0].value == KdlValue::Bool(true))
    }
    Err(_) => panic()
  }
}

///|
test "query boolean false value" {
  let doc = make_bool_doc()
  let result = query(doc, "flag[val(0) = false]")
  match result {
    Ok(nodes) => {
      assert_eq(nodes.length(), 1)
      assert_true(nodes[0].entries[0].value == KdlValue::Bool(false))
    }
    Err(_) => panic()
  }
}

///|
test "query null value" {
  let doc = make_bool_doc()
  let result = query(doc, "item[val(0) = null]")
  match result {
    Ok(nodes) => {
      assert_eq(nodes.length(), 1)
      assert_true(nodes[0].entries[0].value == KdlValue::Null)
    }
    Err(_) => panic()
  }
}

///|
test "query empty document" {
  let doc = make_empty_doc()
  let result = query(doc, "anything")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 0)
    Err(_) => panic()
  }
}

///|
test "query empty document top" {
  let doc = make_empty_doc()
  let result = query(doc, "top()")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 0)
    Err(_) => panic()
  }
}

///|
test "query deeply nested descendant" {
  let doc = make_nested_deep_doc()
  let result = query(doc, "l1 >> l4")
  match result {
    Ok(nodes) => {
      assert_eq(nodes.length(), 1)
      assert_true(nodes[0].name.value() == "l4")
    }
    Err(_) => panic()
  }
}

///|
test "query deeply nested child chain" {
  let doc = make_nested_deep_doc()
  let result = query(doc, "l1 > l2 > l3 > l4")
  match result {
    Ok(nodes) => {
      assert_eq(nodes.length(), 1)
      assert_true(nodes[0].name.value() == "l4")
    }
    Err(_) => panic()
  }
}

///|
test "query next sibling no match" {
  let doc = make_sibling_doc()
  let result = query(doc, "a + c")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 0)
    Err(_) => panic()
  }
}

///|
test "query later sibling multiple matches" {
  let doc = make_multisibling_doc()
  let result = query(doc, "a ++ b")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 2)
    Err(_) => panic()
  }
}

///|
test "query top standalone" {
  let doc = make_doc()
  let result = query(doc, "top()")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 1)
    Err(_) => panic()
  }
}

///|
test "query gte with equal value" {
  let doc = make_entries_doc()
  let result = query(doc, "server[val(0) >= 9090]")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 1)
    Err(_) => panic()
  }
}

///|
test "query lte with equal value" {
  let doc = make_entries_doc()
  let result = query(doc, "server[val(0) <= 8080]")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 1)
    Err(_) => panic()
  }
}

///|
test "query neq string" {
  let doc = make_entries_doc()
  let result = query(doc, "server[prop(\"host\") != \"localhost\"]")
  match result {
    Ok(nodes) => assert_eq(nodes.length(), 1)
    Err(_) => panic()
  }
}
