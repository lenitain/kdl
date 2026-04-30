///|
priv struct Cursor {
  input : String
  pos : Int
}

///|
fn Cursor::new(input : String) -> Cursor {
  { input, pos: 0 }
}

///|
fn Cursor::peek(self : Cursor) -> String? {
  if self.pos < self.input.length() {
    Some(self.input[self.pos:self.pos + 1].to_string())
  } else {
    None
  }
}

///|
fn Cursor::peek_at(self : Cursor, offset : Int) -> String? {
  let idx = self.pos + offset
  if idx + 1 <= self.input.length() {
    Some(self.input[idx:idx + 1].to_string())
  } else {
    None
  }
}

///|
fn Cursor::advance(self : Cursor) -> (String?, Cursor) {
  match self.peek() {
    Some(ch) => (Some(ch), { input: self.input, pos: self.pos + 1 })
    None => (None, self)
  }
}

///|
fn Cursor::current_span(self : Cursor, start : Int) -> KqlSourceSpan {
  KqlSourceSpan::new(start, self.pos)
}

///|
fn is_kql_whitespace(ch : String) -> Bool {
  ch == "\t" || ch == " "
}

///|
fn is_digit(ch : String) -> Bool {
  ch >= "0" && ch <= "9"
}

///|
fn is_sign(ch : String) -> Bool {
  ch == "+" || ch == "-"
}

///|
fn is_hex_digit(ch : String) -> Bool {
  is_digit(ch) || (ch >= "a" && ch <= "f") || (ch >= "A" && ch <= "F")
}

///|
fn is_kql_ident_char(ch : String) -> Bool {
  if is_kql_whitespace(ch) {
    return false
  }
  if ch == "\"" ||
    ch == "(" ||
    ch == ")" ||
    ch == "[" ||
    ch == "]" ||
    ch == "=" ||
    ch == "!" ||
    ch == "<" ||
    ch == ">" ||
    ch == "^" ||
    ch == "$" ||
    ch == "*" ||
    ch == "|" ||
    ch == "+" {
    return false
  }
  true
}

///|
priv struct Lexer {
  cursor : Cursor
  errors : Array[String]
}

///|
fn Lexer::new(input : String) -> Lexer {
  { cursor: Cursor::new(input), errors: [] }
}

///|
fn Lexer::add_error(self : Lexer, message : String) -> Lexer {
  let new_errors = self.errors
  new_errors.push(message)
  { cursor: self.cursor, errors: new_errors }
}

///|
fn Lexer::skip_whitespace(self : Lexer) -> Lexer {
  let mut current = self
  while true {
    match current.cursor.peek() {
      Some(ch) =>
        if is_kql_whitespace(ch) {
          let (_, new_cursor) = current.cursor.advance()
          current = { cursor: new_cursor, errors: current.errors }
        } else {
          break
        }
      None => break
    }
  }
  current
}

///|
fn Lexer::read_string(self : Lexer) -> (Result[KqlToken, String], Lexer) {
  let (_, new_cursor) = self.cursor.advance() // skip opening quote
  let mut current = { cursor: new_cursor, errors: self.errors }
  let buf = @buffer.new()
  let mut result : Result[KqlToken, String] = Err("Unterminated string")
  while true {
    match current.cursor.peek() {
      Some(ch) =>
        if ch == "\"" {
          let (_, new_cursor) = current.cursor.advance()
          result = Ok(String(buf.to_string()))
          current = { cursor: new_cursor, errors: current.errors }
          break
        } else if ch == "\\" {
          let (_, new_cursor) = current.cursor.advance()
          current = { cursor: new_cursor, errors: current.errors }
          match current.cursor.peek() {
            Some(esc) => {
              if esc == "\"" {
                buf.write_string("\"")
              } else if esc == "\\" {
                buf.write_string("\\")
              } else if esc == "b" {
                buf.write_string("\b")
              } else if esc == "f" {
                buf.write_string("\f")
              } else if esc == "n" {
                buf.write_string("\n")
              } else if esc == "r" {
                buf.write_string("\r")
              } else if esc == "t" {
                buf.write_string("\t")
              } else if esc == "/" {
                buf.write_string("/")
              } else if esc == "u" {
                let (_, new_cursor) = current.cursor.advance()
                current = { cursor: new_cursor, errors: current.errors }
                if current.cursor.peek() != Some("{") {
                  result = Err("Expected '{' after \\u")
                  break
                }
                let (_, new_cursor) = current.cursor.advance()
                current = { cursor: new_cursor, errors: current.errors }
                let hex_buf = @buffer.new()
                while true {
                  match current.cursor.peek() {
                    Some(h) =>
                      if h == "}" {
                        let (_, new_cursor) = current.cursor.advance()
                        current = { cursor: new_cursor, errors: current.errors }
                        break
                      } else if is_hex_digit(h) {
                        hex_buf.write_string(h)
                        let (_, new_cursor) = current.cursor.advance()
                        current = { cursor: new_cursor, errors: current.errors }
                      } else {
                        result = Err("Invalid hex digit in unicode escape")
                        break
                      }
                    None => {
                      result = Err("Unterminated unicode escape")
                      break
                    }
                  }
                }
                buf.write_string("?")
              } else {
                result = Err("Invalid escape character")
                break
              }
              let (_, new_cursor) = current.cursor.advance()
              current = { cursor: new_cursor, errors: current.errors }
            }
            None => {
              result = Err("Unterminated string escape")
              break
            }
          }
        } else {
          buf.write_string(ch)
          let (_, new_cursor) = current.cursor.advance()
          current = { cursor: new_cursor, errors: current.errors }
        }
      None => {
        result = Err("Unterminated string")
        break
      }
    }
  }
  (result, current)
}

///|
fn Lexer::read_number(self : Lexer) -> (Result[KqlToken, String], Lexer) {
  let mut is_negative = false
  let mut current = self
  if current.cursor.peek() == Some("-") {
    is_negative = true
    let (_, new_cursor) = current.cursor.advance()
    current = { cursor: new_cursor, errors: current.errors }
  } else if current.cursor.peek() == Some("+") {
    let (_, new_cursor) = current.cursor.advance()
    current = { cursor: new_cursor, errors: current.errors }
  }
  let num_buf = @buffer.new()
  let mut has_dot = false
  let mut has_exp = false
  while true {
    match current.cursor.peek() {
      Some(d) =>
        if is_digit(d) {
          num_buf.write_string(d)
          let (_, new_cursor) = current.cursor.advance()
          current = { cursor: new_cursor, errors: current.errors }
        } else if d == "_" {
          let (_, new_cursor) = current.cursor.advance()
          current = { cursor: new_cursor, errors: current.errors }
        } else if d == "." && !has_dot && !has_exp {
          match current.cursor.peek_at(1) {
            Some(next) =>
              if is_digit(next) {
                has_dot = true
                num_buf.write_string(d)
                let (_, new_cursor) = current.cursor.advance()
                current = { cursor: new_cursor, errors: current.errors }
              } else {
                break
              }
            None => break
          }
        } else if (d == "e" || d == "E") && !has_exp {
          has_exp = true
          num_buf.write_string(d)
          let (_, new_cursor) = current.cursor.advance()
          current = { cursor: new_cursor, errors: current.errors }
          match current.cursor.peek() {
            Some(s) =>
              if is_sign(s) {
                num_buf.write_string(s)
                let (_, new_cursor) = current.cursor.advance()
                current = { cursor: new_cursor, errors: current.errors }
              }
            None => ()
          }
          match current.cursor.peek() {
            Some(d) =>
              if !is_digit(d) {
                return (Err("Expected digit after exponent sign"), current)
              }
            None => return (Err("Expected digit after exponent sign"), current)
          }
        } else {
          break
        }
      None => break
    }
  }
  let num_str = num_buf.to_string()
  if num_str.length() == 0 {
    return (Err("Expected digits"), current)
  }
  if has_dot || has_exp {
    let mut int_part = 0L
    let mut frac_part = 0.0
    let mut frac_divisor = 1.0
    let mut exp_part = 0
    let mut exp_negative = false
    let mut phase = 0 // 0=int, 1=frac, 2=exp
    for ch in num_str {
      if ch == '.' {
        phase = 1
      } else if ch == 'e' || ch == 'E' {
        phase = 2
      } else if ch == '-' && phase == 2 {
        exp_negative = true
      } else if ch == '+' && phase == 2 {
        // do nothing
      } else {
        let digit = (ch.to_int() - '0'.to_int()).to_double()
        if phase == 0 {
          int_part = int_part * 10L + digit.to_int64()
        } else if phase == 1 {
          frac_divisor = frac_divisor * 10.0
          frac_part = frac_part + digit / frac_divisor
        } else {
          exp_part = exp_part * 10 + digit.to_int()
        }
      }
    }
    let mut result = int_part.to_double() + frac_part
    let exp_val = if exp_negative { -exp_part } else { exp_part }
    if exp_val > 0 {
      for _ in 0..<exp_val {
        result = result * 10.0
      }
    } else if exp_val < 0 {
      for _ in 0..<-exp_val {
        result = result / 10.0
      }
    }
    if is_negative {
      result = -result
    }
    (Ok(Float(result)), current)
  } else {
    let mut result = 0L
    for ch in num_str {
      result = result * 10L + (ch.to_int() - '0'.to_int()).to_int64()
    }
    if is_negative {
      result = -result
    }
    (Ok(Integer(result)), current)
  }
}

///|
fn Lexer::read_identifier(self : Lexer) -> (Result[KqlToken, String], Lexer) {
  let buf = @buffer.new()
  let mut current = self
  while true {
    match current.cursor.peek() {
      Some(ch) =>
        if is_kql_ident_char(ch) {
          buf.write_string(ch)
          let (_, new_cursor) = current.cursor.advance()
          current = { cursor: new_cursor, errors: current.errors }
        } else {
          break
        }
      None => break
    }
  }
  let ident = buf.to_string()
  if ident == "true" {
    (Ok(Bool(true)), current)
  } else if ident == "false" {
    (Ok(Bool(false)), current)
  } else if ident == "null" {
    (Ok(Null), current)
  } else if ident == "inf" {
    (Ok(Inf), current)
  } else if ident == "nan" {
    (Ok(Nan), current)
  } else {
    (Ok(Ident(ident)), current)
  }
}

///|
fn Lexer::next_token(self : Lexer) -> (Result[KqlSpannedToken, String], Lexer) {
  let current = self.skip_whitespace()
  let start = current.cursor.pos
  match current.cursor.peek() {
    Some(ch) =>
      if ch == "\"" {
        let (token_result, new_lexer) = current.read_string()
        match token_result {
          Ok(token) =>
            (
              Ok(
                KqlSpannedToken::new(
                  token,
                  new_lexer.cursor.current_span(start),
                ),
              ),
              new_lexer,
            )
          Err(e) => (Err(e), new_lexer)
        }
      } else if ch == "-" &&
        ({
          let c1 = current.cursor.peek_at(1)
          let c2 = current.cursor.peek_at(2)
          let c3 = current.cursor.peek_at(3)
          c1 == Some("i") && c2 == Some("n") && c3 == Some("f")
        }) {
        let (_, c1) = current.cursor.advance()
        let (_, c2) = c1.advance()
        let (_, c3) = c2.advance()
        let (_, c4) = c3.advance()
        let new_lexer = { cursor: c4, errors: current.errors }
        (
          Ok(KqlSpannedToken::new(NegInf, new_lexer.cursor.current_span(start))),
          new_lexer,
        )
      } else if is_digit(ch) ||
        (
          is_sign(ch) &&
          ({
            let next = current.cursor.peek_at(1)
            is_digit(
              match next {
                Some(c) => c
                None => "0"
              },
            )
          })
        ) {
        let (token_result, new_lexer) = current.read_number()
        match token_result {
          Ok(token) =>
            (
              Ok(
                KqlSpannedToken::new(
                  token,
                  new_lexer.cursor.current_span(start),
                ),
              ),
              new_lexer,
            )
          Err(e) => (Err(e), new_lexer)
        }
      } else if ch == "." &&
        ({
          let next = current.cursor.peek_at(1)
          is_digit(
            match next {
              Some(c) => c
              None => "0"
            },
          )
        }) {
        let (token_result, new_lexer) = current.read_number()
        match token_result {
          Ok(token) =>
            (
              Ok(
                KqlSpannedToken::new(
                  token,
                  new_lexer.cursor.current_span(start),
                ),
              ),
              new_lexer,
            )
          Err(e) => (Err(e), new_lexer)
        }
      } else if ch == ">" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        match new_lexer.cursor.peek() {
          Some(">") => {
            let (_, new_cursor2) = new_lexer.cursor.advance()
            let new_lexer2 = { cursor: new_cursor2, errors: new_lexer.errors }
            (
              Ok(
                KqlSpannedToken::new(
                  GtGt,
                  new_lexer2.cursor.current_span(start),
                ),
              ),
              new_lexer2,
            )
          }
          Some("=") => {
            let (_, new_cursor2) = new_lexer.cursor.advance()
            let new_lexer2 = { cursor: new_cursor2, errors: new_lexer.errors }
            (
              Ok(
                KqlSpannedToken::new(Gte, new_lexer2.cursor.current_span(start)),
              ),
              new_lexer2,
            )
          }
          _ =>
            (
              Ok(KqlSpannedToken::new(Gt, new_lexer.cursor.current_span(start))),
              new_lexer,
            )
        }
      } else if ch == "<" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        match new_lexer.cursor.peek() {
          Some("=") => {
            let (_, new_cursor2) = new_lexer.cursor.advance()
            let new_lexer2 = { cursor: new_cursor2, errors: new_lexer.errors }
            (
              Ok(
                KqlSpannedToken::new(Lte, new_lexer2.cursor.current_span(start)),
              ),
              new_lexer2,
            )
          }
          _ =>
            (
              Ok(KqlSpannedToken::new(Lt, new_lexer.cursor.current_span(start))),
              new_lexer,
            )
        }
      } else if ch == "!" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        match new_lexer.cursor.peek() {
          Some("=") => {
            let (_, new_cursor2) = new_lexer.cursor.advance()
            let new_lexer2 = { cursor: new_cursor2, errors: new_lexer.errors }
            (
              Ok(
                KqlSpannedToken::new(Neq, new_lexer2.cursor.current_span(start)),
              ),
              new_lexer2,
            )
          }
          _ => (Err("Unexpected character: !"), new_lexer)
        }
      } else if ch == "^" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        match new_lexer.cursor.peek() {
          Some("=") => {
            let (_, new_cursor2) = new_lexer.cursor.advance()
            let new_lexer2 = { cursor: new_cursor2, errors: new_lexer.errors }
            (
              Ok(
                KqlSpannedToken::new(
                  CaretEq,
                  new_lexer2.cursor.current_span(start),
                ),
              ),
              new_lexer2,
            )
          }
          _ => (Err("Unexpected character: ^"), new_lexer)
        }
      } else if ch == "$" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        match new_lexer.cursor.peek() {
          Some("=") => {
            let (_, new_cursor2) = new_lexer.cursor.advance()
            let new_lexer2 = { cursor: new_cursor2, errors: new_lexer.errors }
            (
              Ok(
                KqlSpannedToken::new(
                  DollarEq,
                  new_lexer2.cursor.current_span(start),
                ),
              ),
              new_lexer2,
            )
          }
          _ => (Err("Unexpected character: $"), new_lexer)
        }
      } else if ch == "*" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        match new_lexer.cursor.peek() {
          Some("=") => {
            let (_, new_cursor2) = new_lexer.cursor.advance()
            let new_lexer2 = { cursor: new_cursor2, errors: new_lexer.errors }
            (
              Ok(
                KqlSpannedToken::new(
                  StarEq,
                  new_lexer2.cursor.current_span(start),
                ),
              ),
              new_lexer2,
            )
          }
          _ => (Err("Unexpected character: *"), new_lexer)
        }
      } else if ch == "+" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        match new_lexer.cursor.peek() {
          Some("+") => {
            let (_, new_cursor2) = new_lexer.cursor.advance()
            let new_lexer2 = { cursor: new_cursor2, errors: new_lexer.errors }
            (
              Ok(
                KqlSpannedToken::new(
                  PlusPlus,
                  new_lexer2.cursor.current_span(start),
                ),
              ),
              new_lexer2,
            )
          }
          _ =>
            (
              Ok(
                KqlSpannedToken::new(Plus, new_lexer.cursor.current_span(start)),
              ),
              new_lexer,
            )
        }
      } else if ch == "|" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        match new_lexer.cursor.peek() {
          Some("|") => {
            let (_, new_cursor2) = new_lexer.cursor.advance()
            let new_lexer2 = { cursor: new_cursor2, errors: new_lexer.errors }
            (
              Ok(
                KqlSpannedToken::new(
                  PipePipe,
                  new_lexer2.cursor.current_span(start),
                ),
              ),
              new_lexer2,
            )
          }
          _ => (Err("Unexpected character: |"), new_lexer)
        }
      } else if ch == "[" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        (
          Ok(
            KqlSpannedToken::new(LBracket, new_lexer.cursor.current_span(start)),
          ),
          new_lexer,
        )
      } else if ch == "]" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        (
          Ok(
            KqlSpannedToken::new(RBracket, new_lexer.cursor.current_span(start)),
          ),
          new_lexer,
        )
      } else if ch == "(" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        (
          Ok(KqlSpannedToken::new(LParen, new_lexer.cursor.current_span(start))),
          new_lexer,
        )
      } else if ch == ")" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        (
          Ok(KqlSpannedToken::new(RParen, new_lexer.cursor.current_span(start))),
          new_lexer,
        )
      } else if ch == "=" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        (
          Ok(KqlSpannedToken::new(Eq, new_lexer.cursor.current_span(start))),
          new_lexer,
        )
      } else if is_kql_ident_char(ch) {
        let (token_result, new_lexer) = current.read_identifier()
        match token_result {
          Ok(token) =>
            (
              Ok(
                KqlSpannedToken::new(
                  token,
                  new_lexer.cursor.current_span(start),
                ),
              ),
              new_lexer,
            )
          Err(e) => (Err(e), new_lexer)
        }
      } else {
        (Err("Unexpected character: " + ch), current)
      }
    None =>
      (
        Ok(KqlSpannedToken::new(Eof, current.cursor.current_span(start))),
        current,
      )
  }
}

///|
pub fn tokenize_kql(
  input : String,
) -> Result[Array[KqlSpannedToken], Array[String]] {
  let mut lexer = Lexer::new(input)
  let tokens = Array::new()
  while true {
    let (token_result, new_lexer) = lexer.next_token()
    lexer = new_lexer
    match token_result {
      Ok(st) => {
        tokens.push(st)
        if st.token == Eof {
          break
        }
      }
      Err(msg) => {
        lexer = lexer.add_error(msg)
        break
      }
    }
  }
  if lexer.errors.length() > 0 {
    Err(lexer.errors)
  } else {
    Ok(tokens)
  }
}
