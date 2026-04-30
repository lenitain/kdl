///|
using @lenitain/kdl {
  type KdlDocument,
  type KdlNode,
  type KdlError,
  type KdlDiagnostic,
}

///|
fn find_substring(haystack : String, needle : String) -> Int? {
  let h_arr = haystack.to_array()
  let n_arr = needle.to_array()
  let h_len = h_arr.length()
  let n_len = n_arr.length()
  if n_len == 0 || n_len > h_len {
    return None
  }
  let limit = h_len - n_len + 1
  for i in 0..<limit {
    let mut found = true
    for j in 0..<n_len {
      if h_arr[i + j] != n_arr[j] {
        found = false
        break
      }
    }
    if found {
      return Some(i)
    }
  }
  None
}

///|
fn read_version() -> String {
  let content = @fs.read_file_to_string("moon.mod.json") catch {
    _ => return "unknown"
  }
  let marker = "\"version\": \""
  match find_substring(content, marker) {
    None => return "unknown"
    Some(idx) => {
      let value_start = idx + marker.length()
      let rest = string_sub(
        content,
        value_start,
        content.length() - value_start,
      )
      match find_substring(rest, "\"") {
        None => return "unknown"
        Some(end_idx) => return string_sub(rest, 0, end_idx)
      }
    }
  }
}

///|
fn string_sub(s : String, start : Int, len : Int) -> String {
  let arr = s.to_array()
  let end = if start + len > arr.length() { arr.length() } else { start + len }
  let mut result = ""
  for i in start..<end {
    result = result + arr[i].to_string()
  }
  result
}

///|
fn show_usage(program : String) -> Unit {
  println("KDL CLI - Parse, validate, and format KDL files")
  println("")
  println("Usage:")
  println(
    "  " +
    program +
    " parse <file>          Parse a KDL file and print the document",
  )
  println(
    "  " +
    program +
    " check <file> [schema]  Validate a KDL file, optionally against a schema",
  )
  println(
    "  " +
    program +
    " format <file>         Format a KDL file and print to stdout",
  )
  println("  " + program + " version               Show version information")
  println("  " + program + " help                  Show this help message")
}

///|
fn format_diagnostic(diag : KdlDiagnostic) -> String {
  let severity = diag.severity.to_string()
  let msg = match diag.message {
    Some(m) => m
    None => "(no message)"
  }
  "[" + severity + "] " + msg
}

///|
fn format_error(err : KdlError) -> String {
  let mut result = ""
  for diag in err.diagnostics {
    if result != "" {
      result = result + "\n"
    }
    result = result + format_diagnostic(diag)
  }
  result
}

///|
fn node_summary(node : KdlNode, indent : Int) -> String {
  let prefix = repeat_str("  ", indent)
  let name = node.name.value()
  let entry_count = node.entries.length()
  let children = match node.children {
    Some(c) => Some(c)
    None => None
  }
  let child_count = match children {
    Some(c) => c.length()
    None => 0
  }
  let entry_label = if entry_count == 1 { "entry" } else { "entries" }
  let child_label = if child_count == 1 { "child" } else { "children" }
  let mut result = prefix + name
  if entry_count > 0 {
    result = result + " (" + entry_count.to_string() + " " + entry_label
    if child_count > 0 {
      result = result + ", " + child_count.to_string() + " " + child_label
    }
    result = result + ")"
  } else if child_count > 0 {
    result = result + " (" + child_count.to_string() + " " + child_label + ")"
  }
  if child_count > 0 {
    match children {
      Some(cs) =>
        for child in cs {
          result = result + "\n" + node_summary(child, indent + 1)
        }
      None => ()
    }
  }
  result
}

///|
fn document_summary(doc : KdlDocument) -> String {
  let count = doc.nodes.length()
  let mut result = "Document with " + count.to_string() + " node(s):"
  for node in doc.nodes {
    result = result + "\n" + node_summary(node, 1)
  }
  result
}

///|
fn repeat_str(s : String, n : Int) -> String {
  let mut result = ""
  for _ in 0..<n {
    result = result + s
  }
  result
}

///|
fn cmd_parse(file : String) -> Unit {
  let input = @fs.read_file_to_string(file) catch {
    _ => {
      println("Error: Failed to read file: " + file)
      @sys.exit(1)
      return
    }
  }
  match @parser.parse(input) {
    Ok(doc) => {
      println(document_summary(doc))
      println("")
      println("Formatted output:")
      println(doc.to_kdl_string_formatted(2))
    }
    Err(err) => {
      println("Parse errors:")
      println(format_error(err))
      @sys.exit(1)
    }
  }
}

///|
fn cmd_check(file : String, schema_file : String?) -> Unit {
  let input = @fs.read_file_to_string(file) catch {
    _ => {
      println("Error: Failed to read file: " + file)
      @sys.exit(1)
      return
    }
  }
  let doc = match @parser.parse(input) {
    Ok(d) => d
    Err(err) => {
      println("Parse errors:")
      println(format_error(err))
      @sys.exit(1)
      return
    }
  }
  match schema_file {
    Some(sf) => {
      let schema_input = @fs.read_file_to_string(sf) catch {
        _ => {
          println("Error: Failed to read schema file: " + sf)
          @sys.exit(1)
          return
        }
      }
      let schema_doc = match @parser.parse(schema_input) {
        Ok(sd) => sd
        Err(err) => {
          println("Schema parse errors:")
          println(format_error(err))
          @sys.exit(1)
          return
        }
      }
      let schema = match @schema.parse_schema(schema_doc) {
        Ok(s) => s
        Err(err) => {
          println("Schema errors:")
          println(format_error(err))
          @sys.exit(1)
          return
        }
      }
      match @schema.validate(doc, schema) {
        Ok(_) => println("OK - Document is valid against schema")
        Err(err) => {
          println("Validation errors:")
          println(format_error(err))
          @sys.exit(1)
        }
      }
    }
    None => println("OK - Document parsed successfully")
  }
}

///|
fn cmd_format(file : String) -> Unit {
  let input = @fs.read_file_to_string(file) catch {
    _ => {
      println("Error: Failed to read file: " + file)
      @sys.exit(1)
      return
    }
  }
  match @parser.parse(input) {
    Ok(doc) => println(doc.to_kdl_string_formatted(2))
    Err(err) => {
      println("Parse errors:")
      println(format_error(err))
      @sys.exit(1)
    }
  }
}

///|
fn main {
  let args = @sys.get_cli_args()
  let program = if args.length() > 0 { args[0] } else { "kdl" }
  if args.length() < 2 {
    show_usage(program)
    @sys.exit(1)
    return
  }
  let cmd = args[1]
  match cmd {
    "help" | "--help" | "-h" => show_usage(program)
    "version" | "--version" | "-v" => println(read_version())
    "parse" =>
      if args.length() < 3 {
        println("Error: parse requires a file argument")
        show_usage(program)
        @sys.exit(1)
      } else {
        cmd_parse(args[2])
      }
    "check" =>
      if args.length() < 3 {
        println("Error: check requires a file argument")
        show_usage(program)
        @sys.exit(1)
      } else if args.length() >= 4 {
        cmd_check(args[2], Some(args[3]))
      } else {
        cmd_check(args[2], None)
      }
    "format" =>
      if args.length() < 3 {
        println("Error: format requires a file argument")
        show_usage(program)
        @sys.exit(1)
      } else {
        cmd_format(args[2])
      }
    _ => {
      println("Error: Unknown command: " + cmd)
      show_usage(program)
      @sys.exit(1)
    }
  }
}
