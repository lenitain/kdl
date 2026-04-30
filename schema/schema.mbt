///|
using @lenitain/kdl {
  type KdlDocument,
  type KdlNode,
  type KdlValue,
  type KdlError,
  type KdlDiagnostic,
}

///|
pub struct SchemaValidation {
  mut type_constraint : String?
  mut enum_values : Array[KdlValue]?
  mut pattern : String?
  mut min_length : Int?
  mut max_length : Int?
  mut format : String?
  mut gt : Double?
  mut gte : Double?
  mut lt : Double?
  mut lte : Double?
  mut modulus_divisor : Double?
  mut modulus_remainder : Double?
  mut tag : SchemaValidation?
}

///|
pub struct SchemaProp {
  key : String?
  description : String?
  id : String?
  ref_ : String?
  required : Bool
  validation : SchemaValidation
}

///|
pub struct SchemaValue {
  description : String?
  id : String?
  ref_ : String?
  min : Int?
  max : Int?
  validation : SchemaValidation
}

///|
pub struct SchemaChildren {
  description : String?
  id : String?
  ref_ : String?
  nodes : Array[SchemaNode]
  node_names_validation : SchemaValidation?
  other_nodes_allowed : Bool
}

///|
pub struct SchemaNode {
  name : String?
  description : String?
  id : String?
  ref_ : String?
  min : Int?
  max : Int?
  props : Array[SchemaProp]
  values : Array[SchemaValue]
  children : SchemaChildren?
  prop_names_validation : SchemaValidation?
  other_props_allowed : Bool
  tag_validation : SchemaValidation?
}

///|
pub struct SchemaTag {
  name : String?
  description : String?
  id : String?
  ref_ : String?
  nodes : Array[SchemaNode]
  node_names_validation : SchemaValidation?
  other_nodes_allowed : Bool
}

///|
pub struct SchemaInfo {
  title : String?
  description : String?
  version : String?
  author : String?
  license : String?
  url : String?
}

///|
pub struct SchemaDefinitions {
  nodes : Array[SchemaNode]
  props : Array[SchemaProp]
  values : Array[SchemaValue]
  children : Array[SchemaChildren]
  tags : Array[SchemaTag]
}

///|
pub struct SchemaDocument {
  info : SchemaInfo
  nodes : Array[SchemaNode]
  tags : Array[SchemaTag]
  definitions : SchemaDefinitions
  node_names_validation : SchemaValidation?
  other_nodes_allowed : Bool
  tag_names_validation : SchemaValidation?
  other_tags_allowed : Bool
}

///|
fn empty_validation() -> SchemaValidation {
  {
    type_constraint: None,
    enum_values: None,
    pattern: None,
    min_length: None,
    max_length: None,
    format: None,
    gt: None,
    gte: None,
    lt: None,
    lte: None,
    modulus_divisor: None,
    modulus_remainder: None,
    tag: None,
  }
}

///|
fn[T] pick(a : T?, b : T?) -> T? {
  match a {
    Some(_) => a
    None => b
  }
}

///|
fn[T] concat_arrays(a : Array[T]?, b : Array[T]?) -> Array[T]? {
  match a {
    Some(av) =>
      match b {
        Some(bv) => {
          let result : Array[T] = []
          for v in av {
            result.push(v)
          }
          for v in bv {
            result.push(v)
          }
          Some(result)
        }
        None => a
      }
    None => b
  }
}

///|
fn merge_validations(
  base : SchemaValidation,
  extra : SchemaValidation,
) -> SchemaValidation {
  {
    type_constraint: pick(extra.type_constraint, base.type_constraint),
    enum_values: concat_arrays(extra.enum_values, base.enum_values),
    pattern: pick(extra.pattern, base.pattern),
    min_length: pick(extra.min_length, base.min_length),
    max_length: pick(extra.max_length, base.max_length),
    format: pick(extra.format, base.format),
    gt: pick(extra.gt, base.gt),
    gte: pick(extra.gte, base.gte),
    lt: pick(extra.lt, base.lt),
    lte: pick(extra.lte, base.lte),
    modulus_divisor: pick(extra.modulus_divisor, base.modulus_divisor),
    modulus_remainder: pick(extra.modulus_remainder, base.modulus_remainder),
    tag: pick(extra.tag, base.tag),
  }
}

///|
priv struct SchemaParser {
  errors : Array[KdlDiagnostic]
}

///|
fn SchemaParser::new() -> SchemaParser {
  { errors: [] }
}

///|
fn SchemaParser::add_error(self : SchemaParser, message : String) -> Unit {
  self.errors.push(
    KdlDiagnostic::new("", 0, 0, Some(message), None, None, Error),
  )
}

///|
fn SchemaParser::to_error(self : SchemaParser) -> KdlError {
  let err = KdlError::new("")
  for diag in self.errors {
    err.push(diag)
  }
  err
}

///|
fn get_bool_value(node : KdlNode) -> Bool? {
  for entry in node.entries {
    if entry.name is None {
      match entry.value {
        KdlValue::Bool(b) => return Some(b)
        _ => return None
      }
    }
  }
  None
}

///|
fn get_prop_string(node : KdlNode, key : String) -> String? {
  for entry in node.entries {
    match entry.name {
      Some(ident) =>
        if ident.value() == key {
          match entry.value {
            KdlValue::String(s) => return Some(s)
            _ => return None
          }
        }
      _ => continue
    }
  }
  None
}

///|
fn get_prop_bool(node : KdlNode, key : String) -> Bool? {
  for entry in node.entries {
    match entry.name {
      Some(ident) =>
        if ident.value() == key {
          match entry.value {
            KdlValue::Bool(b) => return Some(b)
            _ => return None
          }
        }
      _ => continue
    }
  }
  None
}

///|
fn get_prop_int(node : KdlNode, key : String) -> Int? {
  for entry in node.entries {
    match entry.name {
      Some(ident) =>
        if ident.value() == key {
          match entry.value {
            KdlValue::Integer(i) => return Some(i.to_int())
            _ => return None
          }
        }
      _ => continue
    }
  }
  None
}

///|
fn get_first_string(node : KdlNode) -> String? {
  for entry in node.entries {
    if entry.name is None {
      match entry.value {
        KdlValue::String(s) => return Some(s)
        _ => return None
      }
    }
  }
  None
}

///|
fn get_first_int(node : KdlNode) -> Int? {
  for entry in node.entries {
    if entry.name is None {
      match entry.value {
        KdlValue::Integer(i) => return Some(i.to_int())
        _ => return None
      }
    }
  }
  None
}

///|
fn get_nth_double(node : KdlNode, n : Int) -> Double? {
  let mut idx = 0
  for entry in node.entries {
    if entry.name is None {
      if idx == n {
        match entry.value {
          KdlValue::Float(f) => return Some(f)
          KdlValue::Integer(i) => return Some(i.to_double())
          _ => return None
        }
      }
      idx = idx + 1
    }
  }
  None
}

///|
fn find_child(node : KdlNode, name : String) -> KdlNode? {
  match node.children {
    Some(children) => {
      for child in children {
        if child.name.value() == name {
          return Some(child)
        }
      }
      None
    }
    None => None
  }
}

///|
fn find_children(node : KdlNode, name : String) -> Array[KdlNode] {
  let result : Array[KdlNode] = []
  match node.children {
    Some(children) =>
      for child in children {
        if child.name.value() == name {
          result.push(child)
        }
      }
    None => ()
  }
  result
}

///|
fn all_children(node : KdlNode) -> Array[KdlNode] {
  match node.children {
    Some(c) => c
    None => []
  }
}

///|
fn SchemaParser::collect_child_validations(
  self : SchemaParser,
  node : KdlNode,
) -> SchemaValidation {
  let mut result = empty_validation()
  for child in all_children(node) {
    let cname = child.name.value()
    match cname {
      "type"
      | "enum"
      | "pattern"
      | "min-length"
      | "max-length"
      | "format"
      | ">"
      | ">="
      | "<"
      | "<="
      | "%"
      | "tag" => {
        let child_val = self.parse_validation(child)
        result = merge_validations(result, child_val)
      }
      _ => ()
    }
  }
  result
}

///|
fn SchemaParser::parse_validation(
  self : SchemaParser,
  node : KdlNode,
) -> SchemaValidation {
  let name = node.name.value()
  let v = empty_validation()
  match name {
    "type" => v.type_constraint = get_first_string(node)
    "enum" => {
      let values : Array[KdlValue] = []
      for entry in node.entries {
        if entry.name is None {
          values.push(entry.value)
        }
      }
      if values.length() > 0 {
        v.enum_values = Some(values)
      }
    }
    "pattern" => v.pattern = get_first_string(node)
    "min-length" => v.min_length = get_first_int(node)
    "max-length" => v.max_length = get_first_int(node)
    "format" => v.format = get_first_string(node)
    ">" => v.gt = get_nth_double(node, 0)
    ">=" => v.gte = get_nth_double(node, 0)
    "<" => v.lt = get_nth_double(node, 0)
    "<=" => v.lte = get_nth_double(node, 0)
    "%" => {
      v.modulus_divisor = get_nth_double(node, 0)
      v.modulus_remainder = get_nth_double(node, 1)
    }
    "tag" => v.tag = Some(self.collect_child_validations(node))
    "node-names" | "tag-names" | "prop-names" =>
      return self.collect_child_validations(node)
    _ => ()
  }
  v
}

///|
fn SchemaParser::parse_prop(self : SchemaParser, node : KdlNode) -> SchemaProp {
  let key = get_prop_string(node, "key")
  let description = get_prop_string(node, "description")
  let id = get_prop_string(node, "id")
  let ref_ = get_prop_string(node, "ref")
  let required = match get_prop_bool(node, "required") {
    Some(r) => r
    None => false
  }
  let validation = self.collect_child_validations(node)
  { key, description, id, ref_, required, validation }
}

///|
fn SchemaParser::parse_value(
  self : SchemaParser,
  node : KdlNode,
) -> SchemaValue {
  let description = get_prop_string(node, "description")
  let id = get_prop_string(node, "id")
  let ref_ = get_prop_string(node, "ref")
  let min = get_prop_int(node, "min")
  let max = get_prop_int(node, "max")
  let validation = self.collect_child_validations(node)
  { description, id, ref_, min, max, validation }
}

///|
fn SchemaParser::parse_children_or_tag(
  self : SchemaParser,
  node : KdlNode,
) -> (Array[SchemaNode], SchemaValidation?, Bool) {
  let nodes : Array[SchemaNode] = []
  let mut node_names_val : SchemaValidation? = None
  let mut other_allowed = false
  for child in all_children(node) {
    let cname = child.name.value()
    match cname {
      "node" => nodes.push(self.parse_node(child))
      "node-names" => node_names_val = Some(self.parse_validation(child))
      "other-nodes-allowed" =>
        other_allowed = match get_bool_value(child) {
          Some(b) => b
          None => true
        }
      _ => ()
    }
  }
  (nodes, node_names_val, other_allowed)
}

///|
fn SchemaParser::parse_children(
  self : SchemaParser,
  node : KdlNode,
) -> SchemaChildren {
  let description = get_prop_string(node, "description")
  let id = get_prop_string(node, "id")
  let ref_ = get_prop_string(node, "ref")
  let (nodes, node_names_val, other_allowed) = self.parse_children_or_tag(node)
  {
    description,
    id,
    ref_,
    nodes,
    node_names_validation: node_names_val,
    other_nodes_allowed: other_allowed,
  }
}

///|
fn SchemaParser::parse_node(self : SchemaParser, node : KdlNode) -> SchemaNode {
  let name = get_prop_string(node, "name")
  let description = get_prop_string(node, "description")
  let id = get_prop_string(node, "id")
  let ref_ = get_prop_string(node, "ref")
  let min = get_prop_int(node, "min")
  let max = get_prop_int(node, "max")
  let props : Array[SchemaProp] = []
  let values : Array[SchemaValue] = []
  let mut children : SchemaChildren? = None
  let mut prop_names_val : SchemaValidation? = None
  let mut other_props = false
  let mut tag_val : SchemaValidation? = None
  for child in all_children(node) {
    let cname = child.name.value()
    match cname {
      "prop" => props.push(self.parse_prop(child))
      "value" => values.push(self.parse_value(child))
      "children" => children = Some(self.parse_children(child))
      "prop-names" => prop_names_val = Some(self.parse_validation(child))
      "other-props-allowed" =>
        other_props = match get_bool_value(child) {
          Some(b) => b
          None => true
        }
      "tag" => tag_val = Some(self.parse_validation(child))
      _ => ()
    }
  }
  {
    name,
    description,
    id,
    ref_,
    min,
    max,
    props,
    values,
    children,
    prop_names_validation: prop_names_val,
    other_props_allowed: other_props,
    tag_validation: tag_val,
  }
}

///|
fn SchemaParser::parse_tag(self : SchemaParser, node : KdlNode) -> SchemaTag {
  let name = get_prop_string(node, "name")
  let description = get_prop_string(node, "description")
  let id = get_prop_string(node, "id")
  let ref_ = get_prop_string(node, "ref")
  let (nodes, node_names_val, other_allowed) = self.parse_children_or_tag(node)
  {
    name,
    description,
    id,
    ref_,
    nodes,
    node_names_validation: node_names_val,
    other_nodes_allowed: other_allowed,
  }
}

///|
fn SchemaParser::parse_info(_self : SchemaParser, node : KdlNode) -> SchemaInfo {
  let title = get_prop_string(node, "title")
  let description = get_prop_string(node, "description")
  let version = get_prop_string(node, "version")
  let author = get_prop_string(node, "author")
  let license = get_prop_string(node, "license")
  let url = get_prop_string(node, "url")
  { title, description, version, author, license, url }
}

///|
fn SchemaParser::parse_definitions(
  self : SchemaParser,
  node : KdlNode,
) -> SchemaDefinitions {
  let nodes : Array[SchemaNode] = []
  let props : Array[SchemaProp] = []
  let values : Array[SchemaValue] = []
  let children : Array[SchemaChildren] = []
  let tags : Array[SchemaTag] = []
  for child in all_children(node) {
    let cname = child.name.value()
    match cname {
      "node" => nodes.push(self.parse_node(child))
      "prop" => props.push(self.parse_prop(child))
      "value" => values.push(self.parse_value(child))
      "children" => children.push(self.parse_children(child))
      "tag" => tags.push(self.parse_tag(child))
      _ => ()
    }
  }
  { nodes, props, values, children, tags }
}

///|
pub fn parse_schema(doc : KdlDocument) -> Result[SchemaDocument, KdlError] {
  let parser = SchemaParser::new()
  let document_node = match doc.get("document") {
    Some(n) => n
    None => {
      parser.add_error("missing 'document' root node")
      return Err(parser.to_error())
    }
  }
  let info = match find_child(document_node, "info") {
    Some(info_node) => parser.parse_info(info_node)
    None =>
      {
        title: None,
        description: None,
        version: None,
        author: None,
        license: None,
        url: None,
      }
  }
  let nodes : Array[SchemaNode] = []
  for child in find_children(document_node, "node") {
    nodes.push(parser.parse_node(child))
  }
  let tags : Array[SchemaTag] = []
  for child in find_children(document_node, "tag") {
    tags.push(parser.parse_tag(child))
  }
  let definitions = match find_child(document_node, "definitions") {
    Some(defs_node) => parser.parse_definitions(defs_node)
    None => { nodes: [], props: [], values: [], children: [], tags: [] }
  }
  let node_names_validation = match find_child(document_node, "node-names") {
    Some(nn) => Some(parser.parse_validation(nn))
    None => None
  }
  let other_nodes_allowed = match
    find_child(document_node, "other-nodes-allowed") {
    Some(on) =>
      match get_bool_value(on) {
        Some(b) => b
        None => true
      }
    None => false
  }
  let tag_names_validation = match find_child(document_node, "tag-names") {
    Some(tn) => Some(parser.parse_validation(tn))
    None => None
  }
  let other_tags_allowed = match
    find_child(document_node, "other-tags-allowed") {
    Some(ot) =>
      match get_bool_value(ot) {
        Some(b) => b
        None => true
      }
    None => false
  }
  if parser.errors.length() > 0 {
    Err(parser.to_error())
  } else {
    Ok({
      info,
      nodes,
      tags,
      definitions,
      node_names_validation,
      other_nodes_allowed,
      tag_names_validation,
      other_tags_allowed,
    })
  }
}

///|
pub impl Show for SchemaValidation with output(self, logger) {
  logger.write_string("SchemaValidation { type: ")
  logger.write_object(self.type_constraint)
  logger.write_string(" }")
}

///|
pub impl Show for SchemaProp with output(self, logger) {
  logger.write_string("SchemaProp { key: ")
  logger.write_object(self.key)
  logger.write_string(", required: ")
  logger.write_object(self.required)
  logger.write_string(" }")
}

///|
pub impl Show for SchemaValue with output(self, logger) {
  logger.write_string("SchemaValue { min: ")
  logger.write_object(self.min)
  logger.write_string(", max: ")
  logger.write_object(self.max)
  logger.write_string(" }")
}

///|
pub impl Show for SchemaChildren with output(self, logger) {
  logger.write_string("SchemaChildren { nodes: ")
  logger.write_object(self.nodes.length())
  logger.write_string(" }")
}

///|
pub impl Show for SchemaNode with output(self, logger) {
  logger.write_string("SchemaNode { name: ")
  logger.write_object(self.name)
  logger.write_string(" }")
}

///|
pub impl Show for SchemaTag with output(self, logger) {
  logger.write_string("SchemaTag { name: ")
  logger.write_object(self.name)
  logger.write_string(" }")
}

///|
pub impl Show for SchemaInfo with output(self, logger) {
  logger.write_string("SchemaInfo { title: ")
  logger.write_object(self.title)
  logger.write_string(" }")
}

///|
pub impl Show for SchemaDefinitions with output(self, logger) {
  logger.write_string("SchemaDefinitions { nodes: ")
  logger.write_object(self.nodes.length())
  logger.write_string(" }")
}

///|
pub impl Show for SchemaDocument with output(self, logger) {
  logger.write_string("SchemaDocument { nodes: ")
  logger.write_object(self.nodes.length())
  logger.write_string(" }")
}
