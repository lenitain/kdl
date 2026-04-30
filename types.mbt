///|
pub(all) enum KdlValue {
  String(String)
  Integer(Int64)
  Float(Double)
  Bool(Bool)
  Null
}

///|
pub impl Show for KdlValue with output(self, logger) {
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
  }
}

///|
pub fn KdlValue::is_string(self : KdlValue) -> Bool {
  match self {
    String(_) => true
    _ => false
  }
}

///|
pub fn KdlValue::is_integer(self : KdlValue) -> Bool {
  match self {
    Integer(_) => true
    _ => false
  }
}

///|
pub fn KdlValue::is_float(self : KdlValue) -> Bool {
  match self {
    Float(_) => true
    _ => false
  }
}

///|
pub fn KdlValue::is_bool(self : KdlValue) -> Bool {
  match self {
    Bool(_) => true
    _ => false
  }
}

///|
pub fn KdlValue::is_null(self : KdlValue) -> Bool {
  match self {
    Null => true
    _ => false
  }
}

///|
pub fn KdlValue::as_string(self : KdlValue) -> String? {
  match self {
    String(s) => Some(s)
    _ => None
  }
}

///|
pub fn KdlValue::as_integer(self : KdlValue) -> Int64? {
  match self {
    Integer(i) => Some(i)
    _ => None
  }
}

///|
pub fn KdlValue::as_float(self : KdlValue) -> Double? {
  match self {
    Float(f) => Some(f)
    _ => None
  }
}

///|
pub fn KdlValue::as_bool(self : KdlValue) -> Bool? {
  match self {
    Bool(b) => Some(b)
    _ => None
  }
}

///|
pub struct KdlIdentifier {
  value : String
  repr : String?
} derive(Eq)

///|
pub impl Show for KdlIdentifier with output(self, logger) {
  logger.write_string("{value: ")
  logger.write_object(self.value)
  logger.write_string(", repr: ")
  logger.write_object(self.repr)
  logger.write_string("}")
}

///|
pub fn KdlIdentifier::new(value : String) -> KdlIdentifier {
  { value, repr: None }
}

///|
pub fn KdlIdentifier::with_repr(value : String, repr : String) -> KdlIdentifier {
  { value, repr: Some(repr) }
}

///|
pub fn KdlIdentifier::to_string(self : KdlIdentifier) -> String {
  match self.repr {
    Some(r) => r
    None => self.value
  }
}

///|
pub fn KdlIdentifier::value(self : KdlIdentifier) -> String {
  self.value
}

///|
pub fn KdlIdentifier::repr(self : KdlIdentifier) -> String? {
  self.repr
}

///|
pub impl Eq for KdlValue with equal(self, other) -> Bool {
  match (self, other) {
    (String(a), String(b)) => a == b
    (Integer(a), Integer(b)) => a == b
    (Float(a), Float(b)) => a == b
    (Bool(a), Bool(b)) => a == b
    (Null, Null) => true
    _ => false
  }
}

///|
pub struct KdlEntry {
  ty : KdlIdentifier?
  value : KdlValue
  name : KdlIdentifier?
} derive(Eq)

///|
pub impl Show for KdlEntry with output(self, logger) {
  logger.write_string("KdlEntry { ty: ")
  logger.write_object(self.ty)
  logger.write_string(", value: ")
  logger.write_object(self.value)
  logger.write_string(", name: ")
  logger.write_object(self.name)
  logger.write_string(" }")
}

///|
pub fn KdlEntry::new(value : KdlValue) -> KdlEntry {
  { ty: None, value, name: None }
}

///|
pub fn KdlEntry::with_ty(ty : KdlIdentifier?, value : KdlValue) -> KdlEntry {
  { ty, value, name: None }
}

///|
pub fn KdlEntry::new_prop(name : KdlIdentifier, value : KdlValue) -> KdlEntry {
  { ty: None, value, name: Some(name) }
}

///|
pub fn KdlEntry::new_prop_with_ty(
  ty : KdlIdentifier?,
  name : KdlIdentifier,
  value : KdlValue,
) -> KdlEntry {
  { ty, value, name: Some(name) }
}

///|
pub fn KdlEntry::is_prop(self : KdlEntry) -> Bool {
  self.name is Some(_)
}

///|
pub struct KdlNode {
  ty : KdlIdentifier?
  name : KdlIdentifier
  entries : Array[KdlEntry]
  children : Array[KdlNode]?
}

///|
pub impl Eq for KdlNode with equal(self, other) -> Bool {
  if self.ty != other.ty {
    return false
  }
  if self.name != other.name {
    return false
  }
  if !entries_eq(self.entries, other.entries) {
    return false
  }
  if !children_eq(self.children, other.children) {
    return false
  }
  return true
}

///|
fn entries_eq(a : Array[KdlEntry], b : Array[KdlEntry]) -> Bool {
  if a.length() != b.length() {
    return false
  }
  for i in 0..<a.length() {
    if a[i] != b[i] {
      return false
    }
  }
  return true
}

///|
fn children_eq(a : Array[KdlNode]?, b : Array[KdlNode]?) -> Bool {
  match (a, b) {
    (None, None) => true
    (Some(a), Some(b)) => nodes_eq(a, b)
    _ => false
  }
}

///|
fn nodes_eq(a : Array[KdlNode], b : Array[KdlNode]) -> Bool {
  if a.length() != b.length() {
    return false
  }
  for i in 0..<a.length() {
    if a[i] != b[i] {
      return false
    }
  }
  return true
}

///|
pub impl Show for KdlNode with output(self, logger) {
  logger.write_string("KdlNode { ty: ")
  logger.write_object(self.ty)
  logger.write_string(", name: ")
  logger.write_object(self.name)
  logger.write_string(", entries: ")
  logger.write_object(self.entries)
  logger.write_string(", children: ")
  logger.write_object(self.children)
  logger.write_string(" }")
}

///|
pub fn KdlNode::new(name : KdlIdentifier) -> KdlNode {
  { ty: None, name, entries: [], children: None }
}

///|
pub fn KdlNode::with_children(
  name : KdlIdentifier,
  children : Array[KdlNode],
) -> KdlNode {
  { ty: None, name, entries: [], children: Some(children) }
}

///|
pub fn KdlNode::with_entries(
  name : KdlIdentifier,
  entries : Array[KdlEntry],
) -> KdlNode {
  { ty: None, name, entries, children: None }
}

///|
pub fn KdlNode::full(
  ty : KdlIdentifier?,
  name : KdlIdentifier,
  entries : Array[KdlEntry],
  children : Array[KdlNode]?,
) -> KdlNode {
  { ty, name, entries, children }
}

///|
pub struct KdlDocument {
  nodes : Array[KdlNode]
}

///|
pub impl Eq for KdlDocument with equal(self, other) -> Bool {
  nodes_eq(self.nodes, other.nodes)
}

///|
pub impl Show for KdlDocument with output(self, logger) {
  logger.write_string("KdlDocument { nodes: ")
  logger.write_object(self.nodes)
  logger.write_string(" }")
}

///|
pub fn KdlDocument::new() -> KdlDocument {
  { nodes: [] }
}

///|
pub fn KdlDocument::get(self : KdlDocument, name : String) -> KdlNode? {
  for node in self.nodes {
    if node.name.value() == name {
      return Some(node)
    }
  }
  None
}

///|
pub fn KdlDocument::push(self : KdlDocument, node : KdlNode) -> Unit {
  self.nodes.push(node)
}

///|
pub fn KdlDocument::nodes(self : KdlDocument) -> Array[KdlNode] {
  self.nodes
}
