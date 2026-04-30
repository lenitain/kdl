///|
test "tokenize empty input" {
  let result = tokenize("")
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
  let result = tokenize("foo")
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
test "tokenize multiple identifiers" {
  let result = tokenize("foo bar baz")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 4)
      assert_eq(tokens[0].token, Ident("foo"))
      assert_eq(tokens[1].token, Ident("bar"))
      assert_eq(tokens[2].token, Ident("baz"))
      assert_eq(tokens[3].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize string" {
  let result = tokenize("\"hello world\"")
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
test "tokenize string with escapes" {
  let result = tokenize("\"hello\\nworld\"")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, String("hello\nworld"))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize integer" {
  let result = tokenize("42")
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
test "tokenize negative integer" {
  let result = tokenize("-42")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Integer(-42L))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize float" {
  let result = tokenize("3.14")
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
test "tokenize boolean true" {
  let result = tokenize("#true")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Bool(true))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize boolean false" {
  let result = tokenize("#false")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Bool(false))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize null" {
  let result = tokenize("#null")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Null)
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize braces" {
  let result = tokenize("{ }")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 3)
      assert_eq(tokens[0].token, LBrace)
      assert_eq(tokens[1].token, RBrace)
      assert_eq(tokens[2].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize parens" {
  let result = tokenize("( )")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 3)
      assert_eq(tokens[0].token, LParen)
      assert_eq(tokens[1].token, RParen)
      assert_eq(tokens[2].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize equals" {
  let result = tokenize("=")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Eq)
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize semicolon" {
  let result = tokenize(";")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Semicolon)
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize slashdash" {
  let result = tokenize("/-")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Slashdash)
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize single-line comment" {
  let result = tokenize("// this is a comment\nfoo")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 3)
      assert_eq(tokens[0].token, Newline)
      assert_eq(tokens[1].token, Ident("foo"))
      assert_eq(tokens[2].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize multi-line comment" {
  let result = tokenize("/* this is a\nmulti-line comment */foo")
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
test "tokenize nested multi-line comment" {
  let result = tokenize("/* outer /* inner */ comment */foo")
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
test "tokenize property" {
  let result = tokenize("key=value")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 4)
      assert_eq(tokens[0].token, Ident("key"))
      assert_eq(tokens[1].token, Eq)
      assert_eq(tokens[2].token, Ident("value"))
      assert_eq(tokens[3].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize node with children" {
  let result = tokenize("parent {\n  child\n}")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 7)
      assert_eq(tokens[0].token, Ident("parent"))
      assert_eq(tokens[1].token, LBrace)
      assert_eq(tokens[2].token, Newline)
      assert_eq(tokens[3].token, Ident("child"))
      assert_eq(tokens[4].token, Newline)
      assert_eq(tokens[5].token, RBrace)
      assert_eq(tokens[6].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize hex number" {
  let result = tokenize("0xFF")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Integer(255L))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize octal number" {
  let result = tokenize("0o77")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Integer(63L))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize binary number" {
  let result = tokenize("0b1010")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Integer(10L))
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize keyword inf" {
  let result = tokenize("#inf")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Inf)
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize keyword -inf" {
  let result = tokenize("#-inf")
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
test "tokenize keyword nan" {
  let result = tokenize("#nan")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 2)
      assert_eq(tokens[0].token, Nan)
      assert_eq(tokens[1].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "disallowed bare inf identifier" {
  let result = tokenize("inf")
  match result {
    Ok(_) => panic()
    Err(_) => ()
  }
}

///|
test "disallowed bare nan identifier" {
  let result = tokenize("nan")
  match result {
    Ok(_) => panic()
    Err(_) => ()
  }
}

///|
test "tokenize type annotation" {
  let result = tokenize("(string)node")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 5)
      assert_eq(tokens[0].token, LParen)
      assert_eq(tokens[1].token, Ident("string"))
      assert_eq(tokens[2].token, RParen)
      assert_eq(tokens[3].token, Ident("node"))
      assert_eq(tokens[4].token, Eof)
    }
    Err(_) => panic()
  }
}

///|
test "tokenize line continuation" {
  let result = tokenize("node 1 2 \\\n  3 4")
  match result {
    Ok(tokens) => {
      assert_eq(tokens.length(), 6)
      assert_eq(tokens[0].token, Ident("node"))
      assert_eq(tokens[1].token, Integer(1L))
      assert_eq(tokens[2].token, Integer(2L))
      assert_eq(tokens[3].token, Integer(3L))
      assert_eq(tokens[4].token, Integer(4L))
      assert_eq(tokens[5].token, Eof)
    }
    Err(_) => panic()
  }
}
