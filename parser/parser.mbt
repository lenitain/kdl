///|
using @lenitain/kdl {
  type KdlValue,
  type KdlIdentifier,
  type KdlEntry,
  type KdlNode,
  type KdlDocument,
  type KdlError,
  type KdlDiagnostic,
}

///|
using @lenitain/kdl/internal/tokenize {
  type KdlToken,
  type SpannedToken,
  type SourceSpan,
  tokenize,
}

///|
priv struct Parser {
  tokens : Array[SpannedToken]
  pos : Int
  input : String
}

///|
fn Parser::new(input : String) -> Result[Parser, Array[KdlDiagnostic]] {
  match tokenize(input) {
    Ok(tokens) => Ok({ tokens, pos: 0, input })
    Err(diags) => Err(diags)
  }
}

///|
fn Parser::current(self : Parser) -> SpannedToken {
  if self.pos < self.tokens.length() {
    self.tokens[self.pos]
  } else {
    SpannedToken::new(Eof, SourceSpan::new(0, 0, 0, 0))
  }
}

///|
fn Parser::peek(self : Parser) -> KdlToken {
  self.current().token
}

///|
fn Parser::advance(self : Parser) -> Parser {
  { tokens: self.tokens, pos: self.pos + 1, input: self.input }
}

///|
fn Parser::skip_newlines(self : Parser) -> Parser {
  let mut current = self
  while true {
    match current.peek() {
      Newline => current = current.advance()
      _ => break
    }
  }
  current
}

///|
fn Parser::parse_identifier(self : Parser) -> (Parser, KdlIdentifier) {
  let current = self.current()
  match current.token {
    Ident(name) => (self.advance(), KdlIdentifier::new(name))
    String(s) => (self.advance(), KdlIdentifier::with_repr(s, "\"" + s + "\""))
    _ => (self.advance(), KdlIdentifier::new(""))
  }
}

///|
fn Parser::parse_value(self : Parser) -> (Parser, KdlValue) {
  let current = self.current()
  match current.token {
    String(s) => (self.advance(), KdlValue::String(s))
    Integer(i) => (self.advance(), KdlValue::Integer(i))
    Float(f) => (self.advance(), KdlValue::Float(f))
    Bool(b) => (self.advance(), KdlValue::Bool(b))
    Null => (self.advance(), KdlValue::Null)
    Inf => (self.advance(), KdlValue::Float(1.0 / 0.0))
    NegInf => (self.advance(), KdlValue::Float(-1.0 / 0.0))
    Nan => (self.advance(), KdlValue::Float(0.0 / 0.0))
    _ => (self.advance(), KdlValue::Null)
  }
}

///|
fn Parser::parse_type_annotation(self : Parser) -> (Parser, KdlIdentifier?) {
  let current = self.current()
  match current.token {
    LParen => {
      let parser = self.advance()
      let (parser, ident) = parser.parse_identifier()
      match parser.peek() {
        RParen => (parser.advance(), Some(ident))
        _ => (parser, None)
      }
    }
    _ => (self, None)
  }
}

///|
fn Parser::parse_entry(self : Parser) -> (Parser, KdlEntry) {
  let (parser, ty) = self.parse_type_annotation()
  let current = parser.current()
  match current.token {
    Ident(name) => {
      let next_parser = parser.advance()
      match next_parser.peek() {
        Eq => {
          let prop_parser = next_parser.advance()
          let (prop_parser, prop_value) = prop_parser.parse_value()
          (
            prop_parser,
            KdlEntry::new_prop_with_ty(ty, KdlIdentifier::new(name), prop_value),
          )
        }
        _ => (next_parser, KdlEntry::with_ty(ty, KdlValue::String(name)))
      }
    }
    String(s) => {
      let next_parser = parser.advance()
      match next_parser.peek() {
        Eq => {
          let prop_parser = next_parser.advance()
          let (prop_parser, prop_value) = prop_parser.parse_value()
          (
            prop_parser,
            KdlEntry::new_prop_with_ty(ty, KdlIdentifier::new(s), prop_value),
          )
        }
        _ => (next_parser, KdlEntry::with_ty(ty, KdlValue::String(s)))
      }
    }
    _ => {
      let (parser, value) = parser.parse_value()
      let current = parser.current()
      match current.token {
        Eq => {
          let parser = parser.advance()
          let (parser, prop_value) = parser.parse_value()
          let name = match value {
            KdlValue::String(s) => KdlIdentifier::new(s)
            _ => KdlIdentifier::new("")
          }
          (parser, KdlEntry::new_prop_with_ty(ty, name, prop_value))
        }
        _ => (parser, KdlEntry::with_ty(ty, value))
      }
    }
  }
}

///|
fn Parser::parse_node(self : Parser) -> (Parser, KdlNode) {
  // Check for slashdash (comment out entire node)
  let is_slashdash = self.peek() == Slashdash
  let parser = if is_slashdash { self.advance() } else { self }
  let (parser, ty) = parser.parse_type_annotation()
  let (parser, name) = parser.parse_identifier()
  let mut current_parser = parser
  let entries = []
  while true {
    let current = current_parser.current()
    match current.token {
      Eof | RBrace | Newline | Semicolon => break
      Slashdash => {
        // Check if slashdash is before a children block
        let skip_parser = current_parser.advance()
        match skip_parser.peek() {
          LBrace => {
            // Slashdash before children - skip the entire children block
            let parser = skip_parser.advance()
            let (new_parser, _nodes) = parser.parse_children()
            current_parser = new_parser
          }
          _ => {
            // Slashdash before argument/property - skip next entry
            let (new_parser, _entry) = skip_parser.parse_entry()
            current_parser = new_parser
          }
        }
      }
      Ident(_)
      | String(_)
      | Integer(_)
      | Float(_)
      | Bool(_)
      | Null
      | Inf
      | NegInf
      | Nan
      | LParen => {
        let (new_parser, entry) = current_parser.parse_entry()
        if !is_slashdash {
          entries.push(entry)
        }
        current_parser = new_parser
      }
      _ => break
    }
  }
  let skipped = current_parser.skip_newlines()
  match skipped.peek() {
    Slashdash => {
      // Slashdash before children block - skip the children
      let parser = skipped.advance()
      match parser.peek() {
        LBrace => {
          let parser = parser.advance()
          let (new_parser, _nodes) = parser.parse_children()
          current_parser = new_parser
          if is_slashdash {
            (current_parser, KdlNode::full(None, name, entries, None))
          } else {
            (current_parser, KdlNode::full(ty, name, entries, None))
          }
        }
        _ => {
          current_parser = parser
          if is_slashdash {
            (current_parser, KdlNode::full(None, name, entries, None))
          } else {
            (current_parser, KdlNode::full(ty, name, entries, None))
          }
        }
      }
    }
    LBrace => {
      let parser = skipped.advance()
      let (new_parser, nodes) = parser.parse_children()
      current_parser = new_parser
      if is_slashdash {
        // Node was slashdashed - return empty node
        (current_parser, KdlNode::full(None, name, entries, None))
      } else {
        (current_parser, KdlNode::full(ty, name, entries, Some(nodes)))
      }
    }
    _ => {
      current_parser = skipped
      if is_slashdash {
        (current_parser, KdlNode::full(None, name, entries, None))
      } else {
        (current_parser, KdlNode::full(ty, name, entries, None))
      }
    }
  }
}

///|
fn Parser::parse_children(self : Parser) -> (Parser, Array[KdlNode]) {
  let mut current_parser = self.skip_newlines()
  let nodes = []
  while true {
    let current = current_parser.current()
    match current.token {
      RBrace => {
        current_parser = current_parser.advance()
        break
      }
      Eof => break
      Slashdash => {
        // Slashdash before node in children - skip the node
        let (new_parser, _node) = current_parser.parse_node()
        current_parser = new_parser.skip_newlines()
      }
      _ => {
        let (new_parser, node) = current_parser.parse_node()
        nodes.push(node)
        current_parser = new_parser.skip_newlines()
      }
    }
  }
  (current_parser, nodes)
}

///|
fn Parser::parse_version_marker(self : Parser) -> (Parser, Int?) {
  let current = self.current()
  match current.token {
    Slashdash => {
      let parser = self.advance()
      match parser.peek() {
        Ident(name) =>
          if name == "kdl-version" {
            let parser = parser.advance()
            // Skip whitespace
            let mut p = parser
            while true {
              match p.peek() {
                Newline => p = p.advance()
                _ => break
              }
            }
            match p.peek() {
              Integer(v) => {
                let parser = p.advance()
                // Skip to end of line
                let mut p2 = parser
                while true {
                  match p2.peek() {
                    Newline => {
                      p2 = p2.advance()
                      break
                    }
                    Eof => break
                    _ => p2 = p2.advance()
                  }
                }
                (p2, Some(v.to_int()))
              }
              _ => (self, None)
            }
          } else {
            (self, None)
          }
        _ => (self, None)
      }
    }
    _ => (self, None)
  }
}

///|
fn Parser::parse_document(self : Parser) -> (Parser, KdlDocument) {
  let parser = self.skip_newlines()
  let doc = KdlDocument::new()
  // Try to parse version marker
  let (parser, version) = parser.parse_version_marker()
  match version {
    Some(v) => doc.set_version(v)
    None => ()
  }
  let mut current_parser = parser.skip_newlines()
  while true {
    let current = current_parser.current()
    match current.token {
      Eof => break
      Slashdash => {
        // Slashdash before node at document level - skip the entire node
        let skip_parser = current_parser.advance()
        let (new_parser, _node) = skip_parser.parse_node()
        current_parser = new_parser.skip_newlines()
      }
      _ => {
        let (new_parser, node) = current_parser.parse_node()
        doc.push(node)
        current_parser = new_parser.skip_newlines()
      }
    }
  }
  (current_parser, doc)
}

///|
pub fn parse(input : String) -> Result[KdlDocument, KdlError] {
  match Parser::new(input) {
    Ok(parser) => {
      let (_parser, doc) = parser.parse_document()
      Ok(doc)
    }
    Err(diags) => {
      let error = KdlError::new(input)
      for diag in diags {
        error.push(diag)
      }
      Err(error)
    }
  }
}

///|
pub fn parse_v1(input : String) -> Result[KdlDocument, KdlError] {
  parse(input)
}

///|
pub fn parse_v2(input : String) -> Result[KdlDocument, KdlError] {
  parse(input)
}

///|
pub fn detect_version(input : String) -> Int {
  // Check for version marker at the beginning
  let trimmed = input.trim_start()
  if trimmed.has_prefix("/-") {
    // Check for kdl-version marker
    let after_slashdash = trimmed[2:].trim_start()
    if after_slashdash.has_prefix("kdl-version") {
      let after_keyword = after_slashdash[11:].trim_start()
      if after_keyword.has_prefix("2") {
        return 2
      } else if after_keyword.has_prefix("1") {
        return 1
      }
    }
  }
  // Heuristic detection: check for v2-specific patterns
  // v2 uses #true, #false, #null, #inf, #-inf, #nan
  if input.contains("#true") ||
    input.contains("#false") ||
    input.contains("#null") ||
    input.contains("#inf") ||
    input.contains("#-inf") ||
    input.contains("#nan") {
    return 2
  }
  // v2 uses """ for multiline strings
  if input.contains("\"\"\"") {
    return 2
  }
  // Default to v1
  1
}
