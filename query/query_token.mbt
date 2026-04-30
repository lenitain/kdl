///|
pub(all) enum KqlToken {
  Ident(String)
  String(String)
  Integer(Int64)
  Float(Double)
  Bool(Bool)
  Null
  Inf
  NegInf
  Nan
  Gt
  GtGt
  Plus
  PlusPlus
  PipePipe
  LBracket
  RBracket
  LParen
  RParen
  Eq
  Neq
  Lt
  Gte
  Lte
  CaretEq
  DollarEq
  StarEq
  Eof
} derive(Eq)

///|
pub impl Show for KqlToken with output(self, logger) {
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
    Gt => logger.write_string("Gt")
    GtGt => logger.write_string("GtGt")
    Plus => logger.write_string("Plus")
    PlusPlus => logger.write_string("PlusPlus")
    PipePipe => logger.write_string("PipePipe")
    LBracket => logger.write_string("LBracket")
    RBracket => logger.write_string("RBracket")
    LParen => logger.write_string("LParen")
    RParen => logger.write_string("RParen")
    Eq => logger.write_string("Eq")
    Neq => logger.write_string("Neq")
    Lt => logger.write_string("Lt")
    Gte => logger.write_string("Gte")
    Lte => logger.write_string("Lte")
    CaretEq => logger.write_string("CaretEq")
    DollarEq => logger.write_string("DollarEq")
    StarEq => logger.write_string("StarEq")
    Eof => logger.write_string("Eof")
  }
}

///|
pub struct KqlSourceSpan {
  start : Int
  end : Int
} derive(Eq)

///|
pub impl Show for KqlSourceSpan with output(self, logger) {
  logger.write_string("KqlSourceSpan { start: ")
  logger.write_object(self.start)
  logger.write_string(", end: ")
  logger.write_object(self.end)
  logger.write_string(" }")
}

///|
pub fn KqlSourceSpan::new(start : Int, end : Int) -> KqlSourceSpan {
  { start, end }
}

///|
pub struct KqlSpannedToken {
  token : KqlToken
  span : KqlSourceSpan
} derive(Eq)

///|
pub impl Show for KqlSpannedToken with output(self, logger) {
  logger.write_string("KqlSpannedToken { token: ")
  logger.write_object(self.token)
  logger.write_string(", span: ")
  logger.write_object(self.span)
  logger.write_string(" }")
}

///|
pub fn KqlSpannedToken::new(
  token : KqlToken,
  span : KqlSourceSpan,
) -> KqlSpannedToken {
  { token, span }
}
