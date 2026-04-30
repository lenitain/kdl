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
  let (parser, _ty) = self.parse_type_annotation()
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
            KdlEntry::new_prop(KdlIdentifier::new(name), prop_value),
          )
        }
        _ => (next_parser, KdlEntry::new(KdlValue::String(name)))
      }
    }
    String(s) => {
      let next_parser = parser.advance()
      match next_parser.peek() {
        Eq => {
          let prop_parser = next_parser.advance()
          let (prop_parser, prop_value) = prop_parser.parse_value()
          (prop_parser, KdlEntry::new_prop(KdlIdentifier::new(s), prop_value))
        }
        _ => (next_parser, KdlEntry::new(KdlValue::String(s)))
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
          (parser, KdlEntry::new_prop(name, prop_value))
        }
        _ => (parser, KdlEntry::new(value))
      }
    }
  }
}

///|
fn Parser::parse_node(self : Parser) -> (Parser, KdlNode) {
  let (parser, _ty) = self.parse_type_annotation()
  let (parser, name) = parser.parse_identifier()
  let mut current_parser = parser
  let entries = []
  while true {
    let current = current_parser.current()
    match current.token {
      Eof | RBrace | Newline | Semicolon => break
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
        entries.push(entry)
        current_parser = new_parser
      }
      _ => break
    }
  }
  let skipped = current_parser.skip_newlines()
  match skipped.peek() {
    LBrace => {
      let parser = skipped.advance()
      let (new_parser, nodes) = parser.parse_children()
      current_parser = new_parser
      (current_parser, KdlNode::full(None, name, entries, Some(nodes)))
    }
    _ => {
      current_parser = skipped
      (current_parser, KdlNode::with_entries(name, entries))
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
fn Parser::parse_document(self : Parser) -> (Parser, KdlDocument) {
  let mut current_parser = self.skip_newlines()
  let doc = KdlDocument::new()
  while true {
    let current = current_parser.current()
    match current.token {
      Eof => break
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
