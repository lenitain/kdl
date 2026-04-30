///|
pub enum KqlQuery {
  Single(KqlSelector)
  Union(KqlQuery, KqlSelector)
} derive(Eq)

///|
pub impl Show for KqlQuery with output(self, logger) {
  match self {
    Single(sel) => {
      logger.write_string("Single(")
      logger.write_object(sel)
      logger.write_string(")")
    }
    Union(q, sel) => {
      logger.write_string("Union(")
      logger.write_object(q)
      logger.write_string(", ")
      logger.write_object(sel)
      logger.write_string(")")
    }
  }
}

///|
pub enum KqlSelector {
  Filter(KqlFilter)
  Child(KqlSelector, KqlFilter)
  Descendant(KqlSelector, KqlFilter)
  NextSibling(KqlSelector, KqlFilter)
  LaterSibling(KqlSelector, KqlFilter)
} derive(Eq)

///|
pub impl Show for KqlSelector with output(self, logger) {
  match self {
    Filter(f) => {
      logger.write_string("Filter(")
      logger.write_object(f)
      logger.write_string(")")
    }
    Child(sel, f) => {
      logger.write_string("Child(")
      logger.write_object(sel)
      logger.write_string(", ")
      logger.write_object(f)
      logger.write_string(")")
    }
    Descendant(sel, f) => {
      logger.write_string("Descendant(")
      logger.write_object(sel)
      logger.write_string(", ")
      logger.write_object(f)
      logger.write_string(")")
    }
    NextSibling(sel, f) => {
      logger.write_string("NextSibling(")
      logger.write_object(sel)
      logger.write_string(", ")
      logger.write_object(f)
      logger.write_string(")")
    }
    LaterSibling(sel, f) => {
      logger.write_string("LaterSibling(")
      logger.write_object(sel)
      logger.write_string(", ")
      logger.write_object(f)
      logger.write_string(")")
    }
  }
}

///|
pub enum KqlFilter {
  Top
  Matchers(Array[KqlMatcher])
} derive(Eq)

///|
pub impl Show for KqlFilter with output(self, logger) {
  match self {
    Top => logger.write_string("Top")
    Matchers(m) => {
      logger.write_string("Matchers(")
      logger.write_object(m)
      logger.write_string(")")
    }
  }
}

///|
pub enum KqlMatcher {
  TypeAnnotation(String?)
  NodeName(String)
  StringLiteral(String)
  AccessorMatcher(KqlAccessor, KqlComparison?)
} derive(Eq)

///|
pub impl Show for KqlMatcher with output(self, logger) {
  match self {
    TypeAnnotation(opt) => {
      logger.write_string("TypeAnnotation(")
      logger.write_object(opt)
      logger.write_string(")")
    }
    NodeName(s) => {
      logger.write_string("NodeName(")
      logger.write_object(s)
      logger.write_string(")")
    }
    StringLiteral(s) => {
      logger.write_string("StringLiteral(")
      logger.write_object(s)
      logger.write_string(")")
    }
    AccessorMatcher(acc, cmp) => {
      logger.write_string("AccessorMatcher(")
      logger.write_object(acc)
      logger.write_string(", ")
      logger.write_object(cmp)
      logger.write_string(")")
    }
  }
}

///|
pub enum KqlAccessor {
  Val(Int)
  Prop(String)
  Name
  Tag
  Values
  Props
  PropertyKey(String)
} derive(Eq)

///|
pub impl Show for KqlAccessor with output(self, logger) {
  match self {
    Val(i) => {
      logger.write_string("Val(")
      logger.write_object(i)
      logger.write_string(")")
    }
    Prop(s) => {
      logger.write_string("Prop(")
      logger.write_object(s)
      logger.write_string(")")
    }
    Name => logger.write_string("Name")
    Tag => logger.write_string("Tag")
    Values => logger.write_string("Values")
    Props => logger.write_string("Props")
    PropertyKey(s) => {
      logger.write_string("PropertyKey(")
      logger.write_object(s)
      logger.write_string(")")
    }
  }
}

///|
pub enum KqlComparison {
  Eq(KqlValue)
  Neq(KqlValue)
  Gt(KqlValue)
  Lt(KqlValue)
  Gte(KqlValue)
  Lte(KqlValue)
  CaretEq(KqlValue)
  DollarEq(KqlValue)
  StarEq(KqlValue)
} derive(Eq)

///|
pub impl Show for KqlComparison with output(self, logger) {
  match self {
    Eq(v) => {
      logger.write_string("Eq(")
      logger.write_object(v)
      logger.write_string(")")
    }
    Neq(v) => {
      logger.write_string("Neq(")
      logger.write_object(v)
      logger.write_string(")")
    }
    Gt(v) => {
      logger.write_string("Gt(")
      logger.write_object(v)
      logger.write_string(")")
    }
    Lt(v) => {
      logger.write_string("Lt(")
      logger.write_object(v)
      logger.write_string(")")
    }
    Gte(v) => {
      logger.write_string("Gte(")
      logger.write_object(v)
      logger.write_string(")")
    }
    Lte(v) => {
      logger.write_string("Lte(")
      logger.write_object(v)
      logger.write_string(")")
    }
    CaretEq(v) => {
      logger.write_string("CaretEq(")
      logger.write_object(v)
      logger.write_string(")")
    }
    DollarEq(v) => {
      logger.write_string("DollarEq(")
      logger.write_object(v)
      logger.write_string(")")
    }
    StarEq(v) => {
      logger.write_string("StarEq(")
      logger.write_object(v)
      logger.write_string(")")
    }
  }
}

///|
pub enum KqlValue {
  String(String)
  Integer(Int64)
  Float(Double)
  Bool(Bool)
  Null
  Inf
  NegInf
  Nan
  TypeAnnotation(String)
} derive(Eq)

///|
pub impl Show for KqlValue with output(self, logger) {
  match self {
    String(s) => {
      logger.write_string("String(")
      logger.write_object(s)
      logger.write_string(")")
    }
    Integer(i) => {
      logger.write_string("Integer(")
      logger.write_object(i)
      logger.write_string("L)")
    }
    Float(f) => {
      logger.write_string("Float(")
      logger.write_object(f)
      logger.write_string(")")
    }
    Bool(b) => {
      logger.write_string("Bool(")
      logger.write_object(b)
      logger.write_string(")")
    }
    Null => logger.write_string("Null")
    Inf => logger.write_string("Inf")
    NegInf => logger.write_string("NegInf")
    Nan => logger.write_string("Nan")
    TypeAnnotation(s) => {
      logger.write_string("TypeAnnotation(")
      logger.write_object(s)
      logger.write_string(")")
    }
  }
}

///|
priv struct KqlParser {
  tokens : Array[KqlSpannedToken]
  pos : Int
}

///|
fn KqlParser::new(tokens : Array[KqlSpannedToken]) -> KqlParser {
  { tokens, pos: 0 }
}

///|
fn KqlParser::current(self : KqlParser) -> KqlSpannedToken {
  if self.pos < self.tokens.length() {
    self.tokens[self.pos]
  } else {
    KqlSpannedToken::new(Eof, KqlSourceSpan::new(0, 0))
  }
}

///|
fn KqlParser::peek(self : KqlParser) -> KqlToken {
  self.current().token
}

///|
fn KqlParser::advance(self : KqlParser) -> KqlParser {
  { tokens: self.tokens, pos: self.pos + 1 }
}

///|
fn KqlParser::parse_kql_value(
  self : KqlParser,
) -> (KqlParser, Result[KqlValue, String]) {
  match self.peek() {
    String(s) => (self.advance(), Ok(KqlValue::String(s)))
    Integer(i) => (self.advance(), Ok(KqlValue::Integer(i)))
    Float(f) => (self.advance(), Ok(KqlValue::Float(f)))
    Bool(b) => (self.advance(), Ok(KqlValue::Bool(b)))
    Null => (self.advance(), Ok(KqlValue::Null))
    Inf => (self.advance(), Ok(KqlValue::Inf))
    NegInf => (self.advance(), Ok(KqlValue::NegInf))
    Nan => (self.advance(), Ok(KqlValue::Nan))
    LParen => {
      let parser = self.advance()
      match parser.peek() {
        Ident(name) => {
          let parser = parser.advance()
          match parser.peek() {
            RParen => (parser.advance(), Ok(KqlValue::TypeAnnotation(name)))
            _ => (parser.advance(), Ok(KqlValue::TypeAnnotation(name)))
          }
        }
        token =>
          (
            parser,
            Err("Expected identifier after ( in type annotation, got \{token}"),
          )
      }
    }
    token => (self, Err("Expected value, got \{token}"))
  }
}

///|
fn make_comparison(
  token : KqlToken,
  value : KqlValue,
) -> Result[KqlComparison, String] {
  match token {
    Eq => Ok(KqlComparison::Eq(value))
    Neq => Ok(KqlComparison::Neq(value))
    Gt => Ok(KqlComparison::Gt(value))
    Lt => Ok(KqlComparison::Lt(value))
    Gte => Ok(KqlComparison::Gte(value))
    Lte => Ok(KqlComparison::Lte(value))
    CaretEq => Ok(KqlComparison::CaretEq(value))
    DollarEq => Ok(KqlComparison::DollarEq(value))
    StarEq => Ok(KqlComparison::StarEq(value))
    _ => Err("Unexpected comparison operator: \{token}")
  }
}

///|
fn KqlParser::parse_function_call(
  self : KqlParser,
  name : String,
) -> (KqlParser, KqlAccessor?) {
  match self.peek() {
    LParen => {
      let after_lparen = self.advance()
      if name == "val" {
        match after_lparen.peek() {
          Integer(i) => {
            let after_int = after_lparen.advance()
            match after_int.peek() {
              RParen =>
                (after_int.advance(), Some(KqlAccessor::Val(i.to_int())))
              _ => (after_lparen, None)
            }
          }
          _ => (after_lparen, None)
        }
      } else if name == "prop" {
        match after_lparen.peek() {
          String(s) => {
            let after_str = after_lparen.advance()
            match after_str.peek() {
              RParen => (after_str.advance(), Some(KqlAccessor::Prop(s)))
              _ => (after_lparen, None)
            }
          }
          _ => (after_lparen, None)
        }
      } else if name == "name" {
        match after_lparen.peek() {
          RParen => (after_lparen.advance(), Some(KqlAccessor::Name))
          _ => (after_lparen, None)
        }
      } else if name == "tag" {
        match after_lparen.peek() {
          RParen => (after_lparen.advance(), Some(KqlAccessor::Tag))
          _ => (after_lparen, None)
        }
      } else if name == "values" {
        match after_lparen.peek() {
          RParen => (after_lparen.advance(), Some(KqlAccessor::Values))
          _ => (after_lparen, None)
        }
      } else if name == "props" {
        match after_lparen.peek() {
          RParen => (after_lparen.advance(), Some(KqlAccessor::Props))
          _ => (after_lparen, None)
        }
      } else {
        (after_lparen, None)
      }
    }
    _ => (self, None)
  }
}

///|
fn KqlParser::parse_accessor(self : KqlParser) -> (KqlParser, KqlAccessor) {
  match self.peek() {
    Ident(name) => {
      let after_name = self.advance()
      let (after_call, result) = after_name.parse_function_call(name)
      match result {
        Some(accessor) => (after_call, accessor)
        None => (after_name, KqlAccessor::PropertyKey(name))
      }
    }
    String(s) => (self.advance(), KqlAccessor::PropertyKey(s))
    _ => (self, KqlAccessor::PropertyKey(""))
  }
}

///|
fn KqlParser::parse_bracket_content(
  self : KqlParser,
) -> (KqlParser, Result[KqlMatcher, String]) {
  match self.peek() {
    Ident(name) => {
      let after_name = self.advance()
      let (after_call, func_result) = after_name.parse_function_call(name)
      match func_result {
        Some(accessor) =>
          match after_call.peek() {
            Eq | Neq | Gt | Lt | Gte | Lte | CaretEq | DollarEq | StarEq => {
              let op_token = after_call.peek()
              let after_op = after_call.advance()
              let (after_val, value_result) = after_op.parse_kql_value()
              match value_result {
                Err(e) => (after_val, Err(e))
                Ok(value) =>
                  match make_comparison(op_token, value) {
                    Err(e) => (after_val, Err(e))
                    Ok(cmp) =>
                      (
                        after_val,
                        Ok(KqlMatcher::AccessorMatcher(accessor, Some(cmp))),
                      )
                  }
              }
            }
            _ => (after_call, Ok(KqlMatcher::AccessorMatcher(accessor, None)))
          }
        None => {
          let accessor = KqlAccessor::PropertyKey(name)
          match after_name.peek() {
            Eq | Neq | Gt | Lt | Gte | Lte | CaretEq | DollarEq | StarEq => {
              let op_token = after_name.peek()
              let after_op = after_name.advance()
              let (after_val, value_result) = after_op.parse_kql_value()
              match value_result {
                Err(e) => (after_val, Err(e))
                Ok(value) =>
                  match make_comparison(op_token, value) {
                    Err(e) => (after_val, Err(e))
                    Ok(cmp) =>
                      (
                        after_val,
                        Ok(KqlMatcher::AccessorMatcher(accessor, Some(cmp))),
                      )
                  }
              }
            }
            _ => (after_name, Ok(KqlMatcher::AccessorMatcher(accessor, None)))
          }
        }
      }
    }
    _ => {
      let (parser, accessor) = self.parse_accessor()
      match parser.peek() {
        Eq | Neq | Gt | Lt | Gte | Lte | CaretEq | DollarEq | StarEq => {
          let op_token = parser.peek()
          let after_op = parser.advance()
          let (after_val, value_result) = after_op.parse_kql_value()
          match value_result {
            Err(e) => (after_val, Err(e))
            Ok(value) =>
              match make_comparison(op_token, value) {
                Err(e) => (after_val, Err(e))
                Ok(cmp) =>
                  (
                    after_val,
                    Ok(KqlMatcher::AccessorMatcher(accessor, Some(cmp))),
                  )
              }
          }
        }
        _ => (parser, Ok(KqlMatcher::AccessorMatcher(accessor, None)))
      }
    }
  }
}

///|
fn KqlParser::parse_accessor_matcher(
  self : KqlParser,
) -> (KqlParser, Result[KqlMatcher, String]) {
  let (parser, accessor) = self.parse_accessor()
  match parser.peek() {
    Eq | Neq | Gt | Lt | Gte | Lte | CaretEq | DollarEq | StarEq => {
      let op_token = parser.peek()
      let parser = parser.advance()
      let (parser, value_result) = parser.parse_kql_value()
      match value_result {
        Err(e) => (parser, Err(e))
        Ok(value) =>
          match make_comparison(op_token, value) {
            Err(e) => (parser, Err(e))
            Ok(cmp) =>
              (parser, Ok(KqlMatcher::AccessorMatcher(accessor, Some(cmp))))
          }
      }
    }
    _ =>
      match accessor {
        KqlAccessor::PropertyKey(name) =>
          (parser, Ok(KqlMatcher::NodeName(name)))
        _ => (parser, Ok(KqlMatcher::AccessorMatcher(accessor, None)))
      }
  }
}

///|
fn KqlParser::parse_type_annotation_matcher(
  self : KqlParser,
) -> (KqlParser, KqlMatcher) {
  let parser = self.advance() // skip LParen
  match parser.peek() {
    RParen => (parser.advance(), KqlMatcher::TypeAnnotation(None))
    Ident(name) => {
      let parser = parser.advance()
      match parser.peek() {
        RParen => (parser.advance(), KqlMatcher::TypeAnnotation(Some(name)))
        _ => (parser, KqlMatcher::TypeAnnotation(Some(name)))
      }
    }
    _ => (parser, KqlMatcher::TypeAnnotation(None))
  }
}

///|
fn KqlParser::parse_matchers(
  self : KqlParser,
) -> (KqlParser, Result[Array[KqlMatcher], String]) {
  let mut current_parser = self
  let matchers : Array[KqlMatcher] = []
  while true {
    match current_parser.peek() {
      LParen => {
        let (p, m) = current_parser.parse_type_annotation_matcher()
        matchers.push(m)
        current_parser = p
      }
      LBracket => {
        let p = current_parser.advance()
        match p.peek() {
          RBracket => current_parser = p.advance()
          _ => {
            let (p2, m_result) = p.parse_bracket_content()
            match m_result {
              Err(e) => return (p2, Err(e))
              Ok(m) =>
                match p2.peek() {
                  RBracket => {
                    matchers.push(m)
                    current_parser = p2.advance()
                  }
                  _ => current_parser = p2
                }
            }
          }
        }
      }
      Ident(name) => {
        let next_pos = current_parser.pos + 1
        let has_paren = if next_pos < current_parser.tokens.length() {
          match current_parser.tokens[next_pos].token {
            LParen => true
            _ => false
          }
        } else {
          false
        }
        if has_paren {
          let (p, m_result) = current_parser.parse_accessor_matcher()
          match m_result {
            Err(e) => return (p, Err(e))
            Ok(m) => {
              matchers.push(m)
              current_parser = p
            }
          }
        } else {
          matchers.push(KqlMatcher::NodeName(name))
          current_parser = current_parser.advance()
        }
      }
      String(s) => {
        matchers.push(KqlMatcher::StringLiteral(s))
        current_parser = current_parser.advance()
      }
      _ => break
    }
  }
  (current_parser, Ok(matchers))
}

///|
fn KqlParser::parse_filter(
  self : KqlParser,
) -> (KqlParser, Result[KqlFilter, String]) {
  match self.peek() {
    Ident(name) =>
      if name == "top" {
        let parser = self.advance()
        match parser.peek() {
          LParen => {
            let parser = parser.advance()
            match parser.peek() {
              RParen => (parser.advance(), Ok(KqlFilter::Top))
              _ => (parser, Ok(KqlFilter::Top))
            }
          }
          _ => {
            let (p, matchers_result) = self.parse_matchers()
            match matchers_result {
              Err(e) => (p, Err(e))
              Ok(matchers) =>
                if matchers.length() == 0 {
                  (p, Ok(KqlFilter::Matchers([])))
                } else {
                  (p, Ok(KqlFilter::Matchers(matchers)))
                }
            }
          }
        }
      } else {
        let (p, matchers_result) = self.parse_matchers()
        match matchers_result {
          Err(e) => (p, Err(e))
          Ok(matchers) =>
            if matchers.length() == 0 {
              (p, Ok(KqlFilter::Matchers([])))
            } else {
              (p, Ok(KqlFilter::Matchers(matchers)))
            }
        }
      }
    _ => {
      let (p, matchers_result) = self.parse_matchers()
      match matchers_result {
        Err(e) => (p, Err(e))
        Ok(matchers) =>
          if matchers.length() == 0 {
            (p, Ok(KqlFilter::Matchers([])))
          } else {
            (p, Ok(KqlFilter::Matchers(matchers)))
          }
      }
    }
  }
}

///|
fn KqlParser::parse_selector(
  self : KqlParser,
) -> (KqlParser, Result[KqlSelector, String]) {
  let (initial_parser, filter_result) = self.parse_filter()
  match filter_result {
    Err(e) => (initial_parser, Err(e))
    Ok(filter) => {
      let mut current_parser = initial_parser
      let mut selector = KqlSelector::Filter(filter)
      while true {
        match current_parser.peek() {
          GtGt | Gt | PlusPlus | Plus => {
            let op = current_parser.peek()
            current_parser = current_parser.advance()
            let (p, next_filter_result) = current_parser.parse_filter()
            match next_filter_result {
              Err(e) => return (p, Err(e))
              Ok(next_filter) => {
                selector = match op {
                  GtGt => KqlSelector::Descendant(selector, next_filter)
                  Gt => KqlSelector::Child(selector, next_filter)
                  PlusPlus => KqlSelector::LaterSibling(selector, next_filter)
                  Plus => KqlSelector::NextSibling(selector, next_filter)
                  _ => KqlSelector::Child(selector, next_filter)
                }
                current_parser = p
              }
            }
          }
          _ => break
        }
      }
      (current_parser, Ok(selector))
    }
  }
}

///|
fn KqlParser::parse_query(
  self : KqlParser,
) -> (KqlParser, Result[KqlQuery, String]) {
  let (initial_parser, selector_result) = self.parse_selector()
  match selector_result {
    Err(e) => (initial_parser, Err(e))
    Ok(selector) => {
      let mut current_parser = initial_parser
      let mut query = KqlQuery::Single(selector)
      while true {
        match current_parser.peek() {
          PipePipe => {
            current_parser = current_parser.advance()
            let (p, next_selector_result) = current_parser.parse_selector()
            match next_selector_result {
              Err(e) => return (p, Err(e))
              Ok(next_selector) => {
                query = KqlQuery::Union(query, next_selector)
                current_parser = p
              }
            }
          }
          _ => break
        }
      }
      (current_parser, Ok(query))
    }
  }
}

///|
pub fn parse_kql(input : String) -> Result[KqlQuery, String] {
  match tokenize_kql(input) {
    Ok(tokens) => {
      let parser = KqlParser::new(tokens)
      let (remaining_parser, query_result) = parser.parse_query()
      match query_result {
        Err(e) => Err(e)
        Ok(query) => {
          let remaining = remaining_parser.peek()
          match remaining {
            Eof => Ok(query)
            _ => Err("Unexpected trailing tokens after query: \{remaining}")
          }
        }
      }
    }
    Err(errors) => Err(errors[0])
  }
}
