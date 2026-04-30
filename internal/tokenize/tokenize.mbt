///|
using @lenitain/kdl {type KdlDiagnostic, type KdlSeverity}

///|
priv struct Cursor {
  input : String
  pos : Int
  line : Int
  col : Int
}

///|
fn Cursor::new(input : String) -> Cursor {
  { input, pos: 0, line: 1, col: 1 }
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
    Some(ch) => {
      let new_line = if ch == "\n" { self.line + 1 } else { self.line }
      let new_col = if ch == "\n" { 1 } else { self.col + 1 }
      (
        Some(ch),
        { input: self.input, pos: self.pos + 1, line: new_line, col: new_col },
      )
    }
    None => (None, self)
  }
}

///|
fn Cursor::is_eof(self : Cursor) -> Bool {
  self.pos >= self.input.length()
}

///|
fn Cursor::current_span(self : Cursor, start : Int) -> SourceSpan {
  SourceSpan::new(start, self.pos, self.line, self.col)
}

///|
fn is_newline(ch : String) -> Bool {
  ch == "\n" ||
  ch == "\r" ||
  ch == "\u{85}" ||
  ch == "\u{0B}" ||
  ch == "\u{0C}" ||
  ch == "\u{2028}" ||
  ch == "\u{2029}"
}

///|
fn is_whitespace(ch : String) -> Bool {
  ch == "\t" ||
  ch == " " ||
  ch == "\u{00A0}" ||
  ch == "\u{1680}" ||
  ch == "\u{2000}" ||
  ch == "\u{2001}" ||
  ch == "\u{2002}" ||
  ch == "\u{2003}" ||
  ch == "\u{2004}" ||
  ch == "\u{2005}" ||
  ch == "\u{2006}" ||
  ch == "\u{2007}" ||
  ch == "\u{2008}" ||
  ch == "\u{2009}" ||
  ch == "\u{200A}" ||
  ch == "\u{202F}" ||
  ch == "\u{205F}" ||
  ch == "\u{3000}"
}

///|
fn is_disallowed_literal(ch : String) -> Bool {
  ch == "\u{00}" ||
  ch == "\u{01}" ||
  ch == "\u{02}" ||
  ch == "\u{03}" ||
  ch == "\u{04}" ||
  ch == "\u{05}" ||
  ch == "\u{06}" ||
  ch == "\u{07}" ||
  ch == "\u{08}" ||
  ch == "\u{0E}" ||
  ch == "\u{0F}" ||
  ch == "\u{10}" ||
  ch == "\u{11}" ||
  ch == "\u{12}" ||
  ch == "\u{13}" ||
  ch == "\u{14}" ||
  ch == "\u{15}" ||
  ch == "\u{16}" ||
  ch == "\u{17}" ||
  ch == "\u{18}" ||
  ch == "\u{19}" ||
  ch == "\u{1A}" ||
  ch == "\u{1B}" ||
  ch == "\u{1C}" ||
  ch == "\u{1D}" ||
  ch == "\u{1E}" ||
  ch == "\u{1F}" ||
  ch == "\u{7F}"
}

///|
fn is_identifier_char(ch : String) -> Bool {
  if is_whitespace(ch) || is_newline(ch) {
    return false
  }
  if ch == "\\" ||
    ch == "/" ||
    ch == "(" ||
    ch == ")" ||
    ch == "{" ||
    ch == "}" ||
    ch == ";" ||
    ch == "[" ||
    ch == "]" ||
    ch == "\"" ||
    ch == "#" ||
    ch == "=" {
    return false
  }
  if is_disallowed_literal(ch) {
    return false
  }
  true
}

///|
fn is_digit(ch : String) -> Bool {
  ch >= "0" && ch <= "9"
}

///|
fn is_hex_digit(ch : String) -> Bool {
  is_digit(ch) || (ch >= "a" && ch <= "f") || (ch >= "A" && ch <= "F")
}

///|
fn is_sign(ch : String) -> Bool {
  ch == "+" || ch == "-"
}

///|
priv struct Lexer {
  cursor : Cursor
  errors : Array[KdlDiagnostic]
}

///|
fn Lexer::new(input : String) -> Lexer {
  { cursor: Cursor::new(input), errors: [] }
}

///|
fn Lexer::add_error(self : Lexer, start : Int, message : String) -> Lexer {
  let span = self.cursor.current_span(start)
  let new_errors = self.errors
  new_errors.push(
    KdlDiagnostic::new(
      self.cursor.input,
      span.start,
      span.end - span.start,
      Some(message),
      None,
      None,
      Error,
    ),
  )
  { cursor: self.cursor, errors: new_errors }
}

///|
fn Lexer::skip_whitespace(self : Lexer) -> Lexer {
  let mut current = self
  while true {
    match current.cursor.peek() {
      Some(ch) =>
        if is_whitespace(ch) {
          let (_, new_cursor) = current.cursor.advance()
          current = { cursor: new_cursor, errors: current.errors }
        } else if ch == "/" {
          match current.cursor.peek_at(1) {
            Some("/") => {
              let (_, new_cursor) = current.cursor.advance()
              let (_, new_cursor2) = new_cursor.advance()
              current = { cursor: new_cursor2, errors: current.errors }
              current = current.skip_single_line_comment()
            }
            Some("*") => {
              let (_, new_cursor) = current.cursor.advance()
              let (_, new_cursor2) = new_cursor.advance()
              current = { cursor: new_cursor2, errors: current.errors }
              current = current.skip_multi_line_comment()
            }
            _ => break
          }
        } else {
          break
        }
      None => break
    }
  }
  current
}

///|
fn Lexer::skip_single_line_comment(self : Lexer) -> Lexer {
  let mut current = self
  while true {
    match current.cursor.peek() {
      Some(ch) => {
        if is_newline(ch) {
          break
        }
        let (_, new_cursor) = current.cursor.advance()
        current = { cursor: new_cursor, errors: current.errors }
      }
      None => break
    }
  }
  current
}

///|
fn Lexer::skip_multi_line_comment(self : Lexer) -> Lexer {
  let mut depth = 1
  let mut current = self
  while depth > 0 {
    match current.cursor.peek() {
      Some(ch) =>
        if ch == "/" {
          match current.cursor.peek_at(1) {
            Some("*") => {
              let (_, new_cursor) = current.cursor.advance()
              let (_, new_cursor2) = new_cursor.advance()
              current = { cursor: new_cursor2, errors: current.errors }
              depth = depth + 1
            }
            _ => {
              let (_, new_cursor) = current.cursor.advance()
              current = { cursor: new_cursor, errors: current.errors }
            }
          }
        } else if ch == "*" {
          match current.cursor.peek_at(1) {
            Some("/") => {
              let (_, new_cursor) = current.cursor.advance()
              let (_, new_cursor2) = new_cursor.advance()
              current = { cursor: new_cursor2, errors: current.errors }
              depth = depth - 1
            }
            _ => {
              let (_, new_cursor) = current.cursor.advance()
              current = { cursor: new_cursor, errors: current.errors }
            }
          }
        } else {
          let (_, new_cursor) = current.cursor.advance()
          current = { cursor: new_cursor, errors: current.errors }
        }
      None => break
    }
  }
  current
}

///|
fn Lexer::read_string(self : Lexer) -> (Result[KdlToken, String], Lexer) {
  let start = self.cursor.pos
  let (_, new_cursor) = self.cursor.advance() // skip opening quote
  let mut current = { cursor: new_cursor, errors: self.errors }
  let buf = @buffer.new()
  let mut result : Result[KdlToken, String] = Err("Unterminated string")
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
              } else if esc == "s" {
                buf.write_string(" ")
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
                // For now, just write a placeholder
                buf.write_string("?")
              } else if is_whitespace(esc) || is_newline(esc) {
                // ws-escape: skip whitespace until newline
                while true {
                  match current.cursor.peek() {
                    Some(ws) =>
                      if is_whitespace(ws) || is_newline(ws) {
                        let (_, new_cursor) = current.cursor.advance()
                        current = { cursor: new_cursor, errors: current.errors }
                      } else {
                        break
                      }
                    None => break
                  }
                }
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
        } else if is_newline(ch) {
          result = Err("Newline in single-line string")
          break
        } else if is_disallowed_literal(ch) {
          result = Err("Disallowed character in string")
          break
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
fn Lexer::read_multiline_string(
  self : Lexer,
) -> (Result[KdlToken, String], Lexer) {
  let start = self.cursor.pos
  let (_, new_cursor) = self.cursor.advance() // skip first "
  let (_, new_cursor2) = new_cursor.advance() // skip second "
  let (_, new_cursor3) = new_cursor2.advance() // skip third "
  let mut current = { cursor: new_cursor3, errors: self.errors }
  // Expect newline after opening """
  match current.cursor.peek() {
    Some(ch) =>
      if !is_newline(ch) {
        return (Err("Expected newline after opening \"\"\""), current)
      }
    None => return (Err("Unterminated multiline string"), current)
  }
  // Skip the newline after opening """
  let (_, new_cursor) = current.cursor.advance()
  current = { cursor: new_cursor, errors: current.errors }
  // Collect all lines
  let lines : Array[String] = []
  let mut current_line = @buffer.new()
  let mut found_close = false
  while true {
    match current.cursor.peek() {
      Some(ch) =>
        if ch == "\"" {
          // Check for closing """
          if current.cursor.peek_at(1) == Some("\"") &&
            current.cursor.peek_at(2) == Some("\"") {
            // Found closing """
            // Current line is the last line (whitespace only)
            let last_line = current_line.to_string()
            // Verify last line is whitespace only
            let mut is_ws_only = true
            for c in last_line {
              if !is_whitespace(c.to_string()) && !is_newline(c.to_string()) {
                is_ws_only = false
                break
              }
            }
            if !is_ws_only {
              return (
                Err("Closing \"\"\" must be on a line with only whitespace"),
                current,
              )
            }
            // Skip closing """
            let (_, new_cursor) = current.cursor.advance()
            let (_, new_cursor2) = new_cursor.advance()
            let (_, new_cursor3) = new_cursor2.advance()
            current = { cursor: new_cursor3, errors: current.errors }
            found_close = true
            break
          } else {
            current_line.write_string(ch)
            let (_, new_cursor) = current.cursor.advance()
            current = { cursor: new_cursor, errors: current.errors }
          }
        } else if is_newline(ch) {
          // End of line
          lines.push(current_line.to_string())
          // Create a new buffer for the next line
          current_line = @buffer.new()
          let (_, new_cursor) = current.cursor.advance()
          current = { cursor: new_cursor, errors: current.errors }
        } else {
          current_line.write_string(ch)
          let (_, new_cursor) = current.cursor.advance()
          current = { cursor: new_cursor, errors: current.errors }
        }
      None => break
    }
  }
  if !found_close {
    return (Err("Unterminated multiline string"), current)
  }
  // Dedent: find the common prefix from the last line (before closing """)
  // The last line specifies the whitespace prefix to remove
  // Note: current_line contains the whitespace before closing """
  let last_line = current_line.to_string()
  // Find the prefix (whitespace from last line)
  let prefix = @buffer.new()
  for c in last_line {
    if is_whitespace(c.to_string()) {
      prefix.write_string(c.to_string())
    } else {
      break
    }
  }
  let prefix_str = prefix.to_string()
  let prefix_len = prefix_str.length()
  // Build the result by removing prefix from each line
  let result_buf = @buffer.new()
  let mut first = true
  let line_count = lines.length()
  let mut idx = 0
  while idx < line_count {
    let line = lines[idx]
    if !first {
      result_buf.write_string("\n")
    }
    first = false
    // Check if line starts with prefix
    let mut has_prefix = true
    if line.length() < prefix_len {
      has_prefix = false
    } else {
      let mut j = 0
      while j < prefix_len {
        if line[j:j + 1] != prefix_str[j:j + 1] {
          has_prefix = false
          break
        }
        j = j + 1
      }
    }
    if has_prefix {
      // Remove prefix
      if line.length() > prefix_len {
        let view = line[prefix_len:]
        result_buf.write_string(view.to_string())
      }
    } else if line.length() == 0 {
      // Empty line is ok
      ()
    } else {
      // Line doesn't have the required prefix - but if it's whitespace only, treat as empty
      let mut is_ws = true
      for c in line {
        if !is_whitespace(c.to_string()) {
          is_ws = false
          break
        }
      }
      if !is_ws {
        return (
          Err("Line does not have the required whitespace prefix"),
          current,
        )
      }
    }
    idx = idx + 1
  }
  (Ok(String(result_buf.to_string())), current)
}

///|
fn Lexer::read_raw_string(self : Lexer) -> (Result[KdlToken, String], Lexer) {
  let start = self.cursor.pos
  let mut hash_count = 0
  let mut current = self
  // Count opening hashes
  while current.cursor.peek() == Some("#") {
    let (_, new_cursor) = current.cursor.advance()
    current = { cursor: new_cursor, errors: current.errors }
    hash_count = hash_count + 1
  }
  if current.cursor.peek() != Some("\"") {
    return (Err("Expected '\"' after raw string hashes"), current)
  }
  let (_, new_cursor) = current.cursor.advance() // skip opening quote
  current = { cursor: new_cursor, errors: current.errors }
  let buf = @buffer.new()
  // Check for multiline
  if current.cursor.peek() == Some("\"") &&
    current.cursor.peek_at(1) == Some("\"") {
    let (_, new_cursor) = current.cursor.advance()
    let (_, new_cursor2) = new_cursor.advance()
    current = { cursor: new_cursor2, errors: current.errors }
    // Multiline raw string
    let mut result : Result[KdlToken, String] = Err("Unterminated raw string")
    while true {
      match current.cursor.peek() {
        Some(ch) => {
          if ch == "\"" {
            if current.cursor.peek_at(1) == Some("\"") &&
              current.cursor.peek_at(2) == Some("\"") {
              let (_, new_cursor) = current.cursor.advance()
              let (_, new_cursor2) = new_cursor.advance()
              let (_, new_cursor3) = new_cursor2.advance()
              current = { cursor: new_cursor3, errors: current.errors }
              // Check closing hashes
              let mut close_hash = 0
              while current.cursor.peek() == Some("#") &&
                    close_hash < hash_count {
                let (_, new_cursor) = current.cursor.advance()
                current = { cursor: new_cursor, errors: current.errors }
                close_hash = close_hash + 1
              }
              if close_hash != hash_count {
                result = Err("Mismatched raw string hashes")
                break
              }
              result = Ok(String(buf.to_string()))
              break
            }
          }
          buf.write_string(ch)
          let (_, new_cursor) = current.cursor.advance()
          current = { cursor: new_cursor, errors: current.errors }
        }
        None => break
      }
    }
    (result, current)
  } else {
    // Single-line raw string
    let mut result : Result[KdlToken, String] = Err("Unterminated raw string")
    while true {
      match current.cursor.peek() {
        Some(ch) => {
          if ch == "\"" {
            let (_, new_cursor) = current.cursor.advance()
            current = { cursor: new_cursor, errors: current.errors }
            // Check closing hashes
            let mut close_hash = 0
            while current.cursor.peek() == Some("#") && close_hash < hash_count {
              let (_, new_cursor) = current.cursor.advance()
              current = { cursor: new_cursor, errors: current.errors }
              close_hash = close_hash + 1
            }
            if close_hash != hash_count {
              result = Err("Mismatched raw string hashes")
              break
            }
            result = Ok(String(buf.to_string()))
            break
          } else if is_newline(ch) {
            result = Err("Newline in single-line raw string")
            break
          } else if is_disallowed_literal(ch) {
            result = Err("Disallowed character in raw string")
            break
          }
          buf.write_string(ch)
          let (_, new_cursor) = current.cursor.advance()
          current = { cursor: new_cursor, errors: current.errors }
        }
        None => break
      }
    }
    (result, current)
  }
}

///|
fn Lexer::read_number(
  self : Lexer,
  start : Int,
) -> (Result[KdlToken, String], Lexer) {
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
  // Check for hex, octal, binary
  if current.cursor.peek() == Some("0") {
    match current.cursor.peek_at(1) {
      Some("x") | Some("X") => {
        let (_, new_cursor) = current.cursor.advance()
        let (_, new_cursor2) = new_cursor.advance()
        current = { cursor: new_cursor2, errors: current.errors }
        let num_buf = @buffer.new()
        while true {
          match current.cursor.peek() {
            Some(h) =>
              if is_hex_digit(h) {
                num_buf.write_string(h)
                let (_, new_cursor) = current.cursor.advance()
                current = { cursor: new_cursor, errors: current.errors }
              } else if h == "_" {
                let (_, new_cursor) = current.cursor.advance()
                current = { cursor: new_cursor, errors: current.errors }
              } else {
                break
              }
            None => break
          }
        }
        let num_str = num_buf.to_string()
        if num_str.length() == 0 {
          return (Err("Expected hex digits after 0x"), current)
        }
        let mut result = 0L
        for ch in num_str {
          result = result * 16L
          if ch >= '0' && ch <= '9' {
            result = result + (ch.to_int() - '0'.to_int()).to_int64()
          } else if ch >= 'a' && ch <= 'f' {
            result = result + (ch.to_int() - 'a'.to_int() + 10).to_int64()
          } else if ch >= 'A' && ch <= 'F' {
            result = result + (ch.to_int() - 'A'.to_int() + 10).to_int64()
          }
        }
        if is_negative {
          result = -result
        }
        return (Ok(Integer(result)), current)
      }
      Some("o") | Some("O") => {
        let (_, new_cursor) = current.cursor.advance()
        let (_, new_cursor2) = new_cursor.advance()
        current = { cursor: new_cursor2, errors: current.errors }
        let num_buf = @buffer.new()
        while true {
          match current.cursor.peek() {
            Some(o) =>
              if o >= "0" && o <= "7" {
                num_buf.write_string(o)
                let (_, new_cursor) = current.cursor.advance()
                current = { cursor: new_cursor, errors: current.errors }
              } else if o == "_" {
                let (_, new_cursor) = current.cursor.advance()
                current = { cursor: new_cursor, errors: current.errors }
              } else {
                break
              }
            None => break
          }
        }
        let num_str = num_buf.to_string()
        if num_str.length() == 0 {
          return (Err("Expected octal digits after 0o"), current)
        }
        let mut result = 0L
        for ch in num_str {
          result = result * 8L
          result = result + (ch.to_int() - '0'.to_int()).to_int64()
        }
        if is_negative {
          result = -result
        }
        return (Ok(Integer(result)), current)
      }
      Some("b") | Some("B") => {
        let (_, new_cursor) = current.cursor.advance()
        let (_, new_cursor2) = new_cursor.advance()
        current = { cursor: new_cursor2, errors: current.errors }
        let num_buf = @buffer.new()
        while true {
          match current.cursor.peek() {
            Some(b) =>
              if b == "0" || b == "1" {
                num_buf.write_string(b)
                let (_, new_cursor) = current.cursor.advance()
                current = { cursor: new_cursor, errors: current.errors }
              } else if b == "_" {
                let (_, new_cursor) = current.cursor.advance()
                current = { cursor: new_cursor, errors: current.errors }
              } else {
                break
              }
            None => break
          }
        }
        let num_str = num_buf.to_string()
        if num_str.length() == 0 {
          return (Err("Expected binary digits after 0b"), current)
        }
        let mut result = 0L
        for ch in num_str {
          result = result * 2L
          result = result + (ch.to_int() - '0'.to_int()).to_int64()
        }
        if is_negative {
          result = -result
        }
        return (Ok(Integer(result)), current)
      }
      _ =>
        // Decimal number
        ignore({})
    }
  }
  // Read decimal number
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
          // Check if next char is digit (not another dot)
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
          // Optional sign
          match current.cursor.peek() {
            Some(s) =>
              if is_sign(s) {
                num_buf.write_string(s)
                let (_, new_cursor) = current.cursor.advance()
                current = { cursor: new_cursor, errors: current.errors }
              }
            None => ()
          }
          // Must have at least one digit after exponent sign
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
    // Parse as float
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
fn Lexer::read_identifier(
  self : Lexer,
  start : Int,
) -> (Result[KdlToken, String], Lexer) {
  let buf = @buffer.new()
  let mut current = self
  while true {
    match current.cursor.peek() {
      Some(ch) =>
        if is_identifier_char(ch) {
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
  // Check for keywords
  if ident == "true" {
    (Ok(Bool(true)), current)
  } else if ident == "false" {
    (Ok(Bool(false)), current)
  } else if ident == "null" {
    (Ok(Null), current)
  } else if ident == "inf" {
    (
      Err("'inf' is not allowed as an identifier; use #inf for infinity"),
      current,
    )
  } else if ident == "-inf" {
    (
      Err(
        "'-inf' is not allowed as an identifier; use #-inf for negative infinity",
      ),
      current,
    )
  } else if ident == "nan" {
    (Err("'nan' is not allowed as an identifier; use #nan for NaN"), current)
  } else {
    (Ok(Ident(ident)), current)
  }
}

///|
fn Lexer::read_keyword(
  self : Lexer,
  start : Int,
) -> (Result[KdlToken, String], Lexer) {
  let (_, new_cursor) = self.cursor.advance() // skip #
  let mut current = { cursor: new_cursor, errors: self.errors }
  let buf = @buffer.new()
  while true {
    match current.cursor.peek() {
      Some(ch) =>
        if is_identifier_char(ch) {
          buf.write_string(ch)
          let (_, new_cursor) = current.cursor.advance()
          current = { cursor: new_cursor, errors: current.errors }
        } else {
          break
        }
      None => break
    }
  }
  let keyword = buf.to_string()
  if keyword == "true" {
    (Ok(Bool(true)), current)
  } else if keyword == "false" {
    (Ok(Bool(false)), current)
  } else if keyword == "null" {
    (Ok(Null), current)
  } else if keyword == "inf" {
    (Ok(Inf), current)
  } else if keyword == "-inf" {
    (Ok(NegInf), current)
  } else if keyword == "nan" {
    (Ok(Nan), current)
  } else {
    (Err("Unknown keyword: #" + keyword), current)
  }
}

///|
fn Lexer::next_token(self : Lexer) -> (Result[SpannedToken, String], Lexer) {
  let current = self.skip_whitespace()
  let start = current.cursor.pos
  match current.cursor.peek() {
    Some(ch) =>
      if ch == "\"" {
        // Check for multiline string """
        if current.cursor.peek_at(1) == Some("\"") &&
          current.cursor.peek_at(2) == Some("\"") {
          let (token_result, new_lexer) = current.read_multiline_string()
          match token_result {
            Ok(token) =>
              (
                Ok(
                  SpannedToken::new(token, new_lexer.cursor.current_span(start)),
                ),
                new_lexer,
              )
            Err(e) => (Err(e), new_lexer)
          }
        } else {
          let (token_result, new_lexer) = current.read_string()
          match token_result {
            Ok(token) =>
              (
                Ok(
                  SpannedToken::new(token, new_lexer.cursor.current_span(start)),
                ),
                new_lexer,
              )
            Err(e) => (Err(e), new_lexer)
          }
        }
      } else if ch == "r" &&
        (
          current.cursor.peek_at(1) == Some("#") ||
          current.cursor.peek_at(1) == Some("\"")
        ) {
        let (token_result, new_lexer) = current.read_raw_string()
        match token_result {
          Ok(token) =>
            (
              Ok(SpannedToken::new(token, new_lexer.cursor.current_span(start))),
              new_lexer,
            )
          Err(e) => (Err(e), new_lexer)
        }
      } else if ch == "#" {
        let (token_result, new_lexer) = current.read_keyword(start)
        match token_result {
          Ok(token) =>
            (
              Ok(SpannedToken::new(token, new_lexer.cursor.current_span(start))),
              new_lexer,
            )
          Err(e) => (Err(e), new_lexer)
        }
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
        let (token_result, new_lexer) = current.read_number(start)
        match token_result {
          Ok(token) =>
            (
              Ok(SpannedToken::new(token, new_lexer.cursor.current_span(start))),
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
        let (token_result, new_lexer) = current.read_number(start)
        match token_result {
          Ok(token) =>
            (
              Ok(SpannedToken::new(token, new_lexer.cursor.current_span(start))),
              new_lexer,
            )
          Err(e) => (Err(e), new_lexer)
        }
      } else if is_identifier_char(ch) {
        let (token_result, new_lexer) = current.read_identifier(start)
        match token_result {
          Ok(token) =>
            (
              Ok(SpannedToken::new(token, new_lexer.cursor.current_span(start))),
              new_lexer,
            )
          Err(e) => (Err(e), new_lexer)
        }
      } else if ch == "{" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        (
          Ok(SpannedToken::new(LBrace, new_lexer.cursor.current_span(start))),
          new_lexer,
        )
      } else if ch == "}" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        (
          Ok(SpannedToken::new(RBrace, new_lexer.cursor.current_span(start))),
          new_lexer,
        )
      } else if ch == "(" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        (
          Ok(SpannedToken::new(LParen, new_lexer.cursor.current_span(start))),
          new_lexer,
        )
      } else if ch == ")" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        (
          Ok(SpannedToken::new(RParen, new_lexer.cursor.current_span(start))),
          new_lexer,
        )
      } else if ch == "=" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        (
          Ok(SpannedToken::new(Eq, new_lexer.cursor.current_span(start))),
          new_lexer,
        )
      } else if ch == ";" {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        (
          Ok(SpannedToken::new(Semicolon, new_lexer.cursor.current_span(start))),
          new_lexer,
        )
      } else if ch == "/" {
        match current.cursor.peek_at(1) {
          Some("-") => {
            let (_, new_cursor) = current.cursor.advance()
            let (_, new_cursor2) = new_cursor.advance()
            let new_lexer = { cursor: new_cursor2, errors: current.errors }
            (
              Ok(
                SpannedToken::new(
                  Slashdash,
                  new_lexer.cursor.current_span(start),
                ),
              ),
              new_lexer,
            )
          }
          Some("/") => {
            let (_, new_cursor) = current.cursor.advance()
            let (_, new_cursor2) = new_cursor.advance()
            let new_lexer = { cursor: new_cursor2, errors: current.errors }
            new_lexer.skip_single_line_comment().next_token()
          }
          Some("*") => {
            let (_, new_cursor) = current.cursor.advance()
            let (_, new_cursor2) = new_cursor.advance()
            let new_lexer = { cursor: new_cursor2, errors: current.errors }
            new_lexer.skip_multi_line_comment().next_token()
          }
          _ => (Err("Unexpected character: /"), current)
        }
      } else if ch == "\\" {
        // Line continuation
        let (_, new_cursor) = current.cursor.advance()
        let mut new_lexer = { cursor: new_cursor, errors: current.errors }
        // Skip whitespace
        while true {
          match new_lexer.cursor.peek() {
            Some(ws) =>
              if is_whitespace(ws) {
                let (_, new_cursor) = new_lexer.cursor.advance()
                new_lexer = { cursor: new_cursor, errors: new_lexer.errors }
              } else if ws == "/" && new_lexer.cursor.peek_at(1) == Some("*") {
                let (_, new_cursor) = new_lexer.cursor.advance()
                let (_, new_cursor2) = new_cursor.advance()
                new_lexer = { cursor: new_cursor2, errors: new_lexer.errors }
                new_lexer = new_lexer.skip_multi_line_comment()
              } else {
                break
              }
            None => break
          }
        }
        // Expect newline or EOF
        match new_lexer.cursor.peek() {
          Some(nl) =>
            if is_newline(nl) {
              let (_, new_cursor) = new_lexer.cursor.advance()
              new_lexer = { cursor: new_cursor, errors: new_lexer.errors }
            } else {
              return (
                Err("Expected newline after line continuation"),
                new_lexer,
              )
            }
          None => ()
        }
        new_lexer.next_token()
      } else if is_newline(ch) {
        let (_, new_cursor) = current.cursor.advance()
        let new_lexer = { cursor: new_cursor, errors: current.errors }
        (
          Ok(SpannedToken::new(Newline, new_lexer.cursor.current_span(start))),
          new_lexer,
        )
      } else {
        (Err("Unexpected character: " + ch), current)
      }
    None =>
      (Ok(SpannedToken::new(Eof, current.cursor.current_span(start))), current)
  }
}

///|
pub fn tokenize(
  input : String,
) -> Result[Array[SpannedToken], Array[KdlDiagnostic]] {
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
        lexer = lexer.add_error(lexer.cursor.pos, msg)
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
