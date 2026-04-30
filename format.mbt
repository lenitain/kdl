///|
fn escape_kdl_string(s : String) -> String {
  let buf = StringBuilder::new()
  buf.write_char('"')
  for ch in s.iter() {
    match ch {
      '\n' => buf.write_string("\\n")
      '\r' => buf.write_string("\\r")
      '\t' => buf.write_string("\\t")
      '\\' => buf.write_string("\\\\")
      '"' => buf.write_string("\\\"")
      '\b' => buf.write_string("\\b")
      '\f' => buf.write_string("\\f")
      '/' => buf.write_string("\\/")
      _ => buf.write_char(ch)
    }
  }
  buf.write_char('"')
  buf.to_string()
}

///|
pub fn KdlValue::to_kdl_string(self : KdlValue) -> String {
  match self {
    String(s) => escape_kdl_string(s)
    Integer(i) => i.to_string()
    Float(f) =>
      if f == 1.0 / 0.0 {
        "#inf"
      } else if f == -1.0 / 0.0 {
        "#-inf"
      } else if f != f {
        "#nan"
      } else {
        let s = f.to_string()
        if s.contains(".") {
          s
        } else {
          s + ".0"
        }
      }
    Bool(b) => if b { "true" } else { "false" }
    Null => "null"
  }
}

///|
fn format_type_annotation(ty : KdlIdentifier?) -> String {
  match ty {
    Some(id) => "(" + id.to_string() + ")"
    None => ""
  }
}

///|
pub fn KdlEntry::to_kdl_string(self : KdlEntry) -> String {
  let ty_prefix = format_type_annotation(self.ty)
  match self.name {
    Some(key) => ty_prefix + key.to_string() + "=" + self.value.to_kdl_string()
    None => ty_prefix + self.value.to_kdl_string()
  }
}

///|
fn indent_str(level : Int, indent : Int) -> String {
  let buf = StringBuilder::new()
  for _ in 0..<(level * indent) {
    buf.write_char(' ')
  }
  buf.to_string()
}

///|
fn format_node_inner(
  node : KdlNode,
  level : Int,
  indent : Int,
  prefix : String,
  suffix : String,
) -> String {
  let buf = StringBuilder::new()
  buf.write_string(prefix)
  buf.write_string(format_type_annotation(node.ty))
  buf.write_string(node.name.to_string())
  for entry in node.entries {
    buf.write_char(' ')
    buf.write_string(entry.to_kdl_string())
  }
  match node.children {
    Some(children) =>
      if children.length() == 0 {
        buf.write_string(" {}")
      } else {
        buf.write_string(" {\n")
        for child in children {
          buf.write_string(
            format_node_inner(
              child,
              level + 1,
              indent,
              indent_str(level + 1, indent),
              "\n",
            ),
          )
        }
        buf.write_string(indent_str(level, indent))
        buf.write_string("}")
      }
    None => ()
  }
  buf.write_string(suffix)
  buf.to_string()
}

///|
pub fn KdlNode::to_kdl_string(self : KdlNode) -> String {
  format_node_inner(self, 0, 2, "", "")
}

///|
pub fn KdlNode::to_kdl_string_formatted(self : KdlNode, indent : Int) -> String {
  format_node_inner(self, 0, indent, "", "")
}

///|
fn format_doc_inner(doc : KdlDocument, indent : Int) -> String {
  let buf = StringBuilder::new()
  let mut first = true
  for node in doc.nodes {
    if !first {
      buf.write_string("\n")
    }
    buf.write_string(format_node_inner(node, 0, indent, "", ""))
    first = false
  }
  buf.to_string()
}

///|
pub fn KdlDocument::to_kdl_string(self : KdlDocument) -> String {
  format_doc_inner(self, 2)
}

///|
pub fn KdlDocument::to_kdl_string_formatted(
  self : KdlDocument,
  indent : Int,
) -> String {
  format_doc_inner(self, indent)
}
