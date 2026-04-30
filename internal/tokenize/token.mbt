///|
pub(all) enum KdlToken {
  Ident(String)
  String(String)
  Integer(Int64)
  Float(Double)
  Bool(Bool)
  Null
  Inf
  NegInf
  Nan
  LBrace
  RBrace
  LParen
  RParen
  Eq
  Slashdash
  Semicolon
  Newline
  Eof
} derive(Eq)

///|
pub impl Show for KdlToken with output(self, logger) {
  match self {
    Ident(s) => {
      logger.write_string("Ident(")
      logger.write_object(s)
      logger.write_string(")")
    }
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
    LBrace => logger.write_string("LBrace")
    RBrace => logger.write_string("RBrace")
    LParen => logger.write_string("LParen")
    RParen => logger.write_string("RParen")
    Eq => logger.write_string("Eq")
    Slashdash => logger.write_string("Slashdash")
    Semicolon => logger.write_string("Semicolon")
    Newline => logger.write_string("Newline")
    Eof => logger.write_string("Eof")
  }
}

///|
pub struct SourceSpan {
  start : Int
  end : Int
  line : Int
  col : Int
} derive(Eq)

///|
pub impl Show for SourceSpan with output(self, logger) {
  logger.write_string("SourceSpan { start: ")
  logger.write_object(self.start)
  logger.write_string(", end: ")
  logger.write_object(self.end)
  logger.write_string(", line: ")
  logger.write_object(self.line)
  logger.write_string(", col: ")
  logger.write_object(self.col)
  logger.write_string(" }")
}

///|
pub fn SourceSpan::new(start : Int, end : Int, line : Int, col : Int) -> SourceSpan {
  { start, end, line, col }
}

///|
pub struct SpannedToken {
  token : KdlToken
  span : SourceSpan
} derive(Eq)

///|
pub impl Show for SpannedToken with output(self, logger) {
  logger.write_string("SpannedToken { token: ")
  logger.write_object(self.token)
  logger.write_string(", span: ")
  logger.write_object(self.span)
  logger.write_string(" }")
}

///|
pub fn SpannedToken::new(token : KdlToken, span : SourceSpan) -> SpannedToken {
  { token, span }
}
