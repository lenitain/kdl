///|
using @lenitain/kdl {
  type KdlDocument,
  type KdlNode,
  type KdlValue,
  type KdlEntry,
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
priv struct Validator {
  errors : Array[KdlDiagnostic]
}

///|
fn Validator::new() -> Validator {
  { errors: [] }
}

///|
fn Validator::add_error(self : Validator, message : String) -> Unit {
  self.errors.push(
    KdlDiagnostic::new("", 0, 0, Some(message), None, None, Error),
  )
}

///|
fn Validator::to_error(self : Validator) -> KdlError {
  let err = KdlError::new("")
  for diag in self.errors {
    err.push(diag)
  }
  err
}

///|
fn value_to_double(value : KdlValue) -> Double? {
  match value {
    KdlValue::Integer(i) => Some(i.to_double())
    KdlValue::Float(f) => Some(f)
    _ => None
  }
}

///|
fn check_date(s : String) -> Bool {
  if s.length() != 10 {
    return false
  }
  for i in 0..<10 {
    let c = s.code_unit_at(i).unsafe_to_char()
    if i == 4 || i == 7 {
      if c != '-' {
        return false
      }
    } else if !c.is_ascii_digit() {
      return false
    }
  }
  true
}

///|
fn check_time(s : String) -> Bool {
  if s.length() < 8 {
    return false
  }
  for i in 0..<8 {
    let c = s.code_unit_at(i).unsafe_to_char()
    if i == 2 || i == 5 {
      if c != ':' {
        return false
      }
    } else if !c.is_ascii_digit() {
      return false
    }
  }
  true
}

///|
fn check_datetime(s : String) -> Bool {
  if s.length() < 19 {
    return false
  }
  let t_pos = s.find("T")
  if t_pos is Some(pos) {
    pos >= 10 &&
    check_date(s.view(end_offset=pos).data()) &&
    check_time(s.view(start_offset=pos + 1).data())
  } else {
    false
  }
}

///|
fn check_email(s : String) -> Bool {
  let at_pos = s.find("@")
  if at_pos is Some(pos) {
    if pos > 0 && pos < s.length() - 1 {
      let domain = s.view(start_offset=pos + 1).data()
      domain.find(".") is Some(_)
    } else {
      false
    }
  } else {
    false
  }
}

///|
fn check_hostname(s : String) -> Bool {
  if s.length() == 0 || s.length() > 253 {
    return false
  }
  for i in 0..<s.length() {
    let c = s.code_unit_at(i).unsafe_to_char()
    if !c.is_ascii_digit() && !c.is_ascii_alphabetic() && c != '-' && c != '.' {
      return false
    }
  }
  true
}

///|
fn check_ipv4(s : String) -> Bool {
  let mut dots = 0
  let mut digits = 0
  for i in 0..<s.length() {
    let c = s.code_unit_at(i).unsafe_to_char()
    if c == '.' {
      if digits == 0 {
        return false
      }
      dots = dots + 1
      digits = 0
    } else if c.is_ascii_digit() {
      digits = digits + 1
      if digits > 3 {
        return false
      }
    } else {
      return false
    }
  }
  dots == 3 && digits > 0
}

///|
fn check_ipv6(s : String) -> Bool {
  let mut colons = 0
  for i in 0..<s.length() {
    let c = s.code_unit_at(i).unsafe_to_char()
    if c == ':' {
      colons = colons + 1
    } else if !c.is_ascii_hexdigit() {
      return false
    }
  }
  colons >= 2 && colons <= 7
}

///|
fn check_uri(s : String) -> Bool {
  let colon_pos = s.find(":")
  if colon_pos is Some(pos) {
    pos < s.length() - 2 &&
    s.code_unit_at(pos + 1).unsafe_to_char() == '/' &&
    s.code_unit_at(pos + 2).unsafe_to_char() == '/'
  } else {
    false
  }
}

///|
fn check_format(s : String, fmt : String) -> Bool {
  match fmt {
    "date-time" => check_datetime(s)
    "date" => check_date(s)
    "time" => check_time(s)
    "email" => check_email(s)
    "hostname" => check_hostname(s)
    "ipv4" => check_ipv4(s)
    "ipv6" => check_ipv6(s)
    "uri" | "url" => check_uri(s)
    _ => true
  }
}

///|
fn string_contains(arr : Array[String], value : String) -> Bool {
  for v in arr {
    if v == value {
      return true
    }
  }
  false
}

///|
fn Validator::validate_value(
  self : Validator,
  value : KdlValue,
  validation : SchemaValidation,
  path : String,
) -> Unit {
  match validation.type_constraint {
    Some(tc) => {
      let valid = match tc {
        "string" => value.is_string()
        "number" => value.is_integer() || value.is_float()
        "boolean" => value.is_bool()
        "null" => value.is_null()
        "integer" => value.is_integer()
        "float" => value.is_float()
        _ => true
      }
      if !valid {
        self.add_error("\{path}: expected type \{tc}, got \{value}")
      }
    }
    None => ()
  }
  match validation.enum_values {
    Some(vals) => {
      let found = vals.any(fn(v) { v == value })
      if !found {
        self.add_error("\{path}: value \{value} not in allowed values")
      }
    }
    None => ()
  }
  match validation.pattern {
    Some(pat) =>
      match value {
        KdlValue::String(s) =>
          try {
            let regex = @string.Regex::new(pat[:])
            if regex.execute(s[:]) is None {
              self.add_error("\{path}: string does not match pattern \{pat}")
            }
          } catch {
            _ => self.add_error("\{path}: invalid regex pattern \{pat}")
          }
        _ => ()
      }
    None => ()
  }
  match validation.min_length {
    Some(min) =>
      match value {
        KdlValue::String(s) =>
          if s.length() < min {
            self.add_error(
              "\{path}: string length \{s.length()} < minimum \{min}",
            )
          }
        _ => ()
      }
    None => ()
  }
  match validation.max_length {
    Some(max) =>
      match value {
        KdlValue::String(s) =>
          if s.length() > max {
            self.add_error(
              "\{path}: string length \{s.length()} > maximum \{max}",
            )
          }
        _ => ()
      }
    None => ()
  }
  match validation.format {
    Some(fmt) =>
      match value {
        KdlValue::String(s) =>
          if !check_format(s, fmt) {
            self.add_error("\{path}: string does not match format \{fmt}")
          }
        _ => ()
      }
    None => ()
  }
  match value_to_double(value) {
    Some(num) => {
      match validation.gt {
        Some(limit) =>
          if num <= limit {
            self.add_error("\{path}: \{num} is not > \{limit}")
          }
        None => ()
      }
      match validation.gte {
        Some(limit) =>
          if num < limit {
            self.add_error("\{path}: \{num} is not >= \{limit}")
          }
        None => ()
      }
      match validation.lt {
        Some(limit) =>
          if num >= limit {
            self.add_error("\{path}: \{num} is not < \{limit}")
          }
        None => ()
      }
      match validation.lte {
        Some(limit) =>
          if num > limit {
            self.add_error("\{path}: \{num} is not <= \{limit}")
          }
        None => ()
      }
      match validation.modulus_divisor {
        Some(divisor) =>
          if divisor != 0.0 {
            let remainder = num - (num / divisor).floor() * divisor
            match validation.modulus_remainder {
              Some(expected) =>
                if remainder != expected {
                  self.add_error(
                    "\{path}: \{num} mod \{divisor} = \{remainder}, expected \{expected}",
                  )
                }
              None =>
                if remainder != 0.0 {
                  self.add_error(
                    "\{path}: \{num} is not divisible by \{divisor}",
                  )
                }
            }
          }
        None => ()
      }
    }
    None => ()
  }
  match validation.tag {
    Some(tag_val) =>
      match value {
        KdlValue::Null => ()
        KdlValue::String(s) =>
          self.validate_value(KdlValue::String(s), tag_val, "\{path}~tag")
        _ => ()
      }
    None => ()
  }
}

///|
fn Validator::validate_node(
  self : Validator,
  node : KdlNode,
  schema : SchemaNode,
  path : String,
) -> Unit {
  let node_path = "\{path}/\{node.name.value()}"
  match schema.tag_validation {
    Some(tv) => {
      let tag_value = match node.ty {
        Some(t) => KdlValue::String(t.value())
        None => KdlValue::Null
      }
      self.validate_value(tag_value, tv, "\{node_path}~tag")
    }
    None => ()
  }
  let schema_prop_keys : Array[String] = []
  for sp in schema.props {
    match sp.key {
      Some(k) => schema_prop_keys.push(k)
      None => ()
    }
  }
  for sp in schema.props {
    if sp.required {
      match sp.key {
        Some(k) => {
          let found = node.entries.any(fn(e) {
            match e.name {
              Some(ident) => ident.value() == k
              None => false
            }
          })
          if !found {
            self.add_error("\{node_path}: missing required property '\{k}'")
          }
        }
        None => ()
      }
    }
  }
  if !schema.other_props_allowed {
    for entry in node.entries {
      match entry.name {
        Some(ident) => {
          let key = ident.value()
          if !string_contains(schema_prop_keys, key) {
            match schema.prop_names_validation {
              Some(pnv) =>
                self.validate_value(
                  KdlValue::String(key),
                  pnv,
                  "\{node_path}~prop-name",
                )
              None =>
                self.add_error("\{node_path}: unexpected property '\{key}'")
            }
          }
        }
        None => ()
      }
    }
  }
  for sp in schema.props {
    match sp.key {
      Some(k) =>
        for entry in node.entries {
          match entry.name {
            Some(ident) =>
              if ident.value() == k {
                self.validate_value(
                  entry.value,
                  sp.validation,
                  "\{node_path}.\{k}",
                )
              }
            None => ()
          }
        }
      None => ()
    }
  }
  let positional : Array[KdlEntry] = []
  for entry in node.entries {
    if entry.name is None {
      positional.push(entry)
    }
  }
  for sv in schema.values {
    match sv.min {
      Some(min) =>
        if positional.length() < min {
          self.add_error(
            "\{node_path}: expected at least \{min} values, got \{positional.length()}",
          )
        }
      None => ()
    }
    match sv.max {
      Some(max) =>
        if positional.length() > max {
          self.add_error(
            "\{node_path}: expected at most \{max} values, got \{positional.length()}",
          )
        }
      None => ()
    }
    for i in 0..<positional.length() {
      self.validate_value(
        positional[i].value,
        sv.validation,
        "\{node_path}[\{i}]",
      )
    }
  }
  match schema.children {
    Some(ch_schema) => {
      let children = match node.children {
        Some(c) => c
        None => []
      }
      self.validate_children(children, ch_schema, node_path)
    }
    None => ()
  }
}

///|
fn Validator::validate_children(
  self : Validator,
  children : Array[KdlNode],
  schema : SchemaChildren,
  path : String,
) -> Unit {
  for sn in schema.nodes {
    match sn.name {
      Some(name) => {
        let mut count = 0
        for c in children {
          if c.name.value() == name {
            count = count + 1
          }
        }
        match sn.min {
          Some(min) =>
            if count < min {
              self.add_error(
                "\{path}: expected at least \{min} '\{name}' nodes, got \{count}",
              )
            }
          None => ()
        }
        match sn.max {
          Some(max) =>
            if count > max {
              self.add_error(
                "\{path}: expected at most \{max} '\{name}' nodes, got \{count}",
              )
            }
          None => ()
        }
      }
      None => ()
    }
  }
  if !schema.other_nodes_allowed {
    for child in children {
      let name = child.name.value()
      let matched = schema.nodes.any(fn(sn) {
        match sn.name {
          Some(n) => n == name
          None => true
        }
      })
      if !matched {
        match schema.node_names_validation {
          Some(nnv) =>
            self.validate_value(
              KdlValue::String(name),
              nnv,
              "\{path}~node-name",
            )
          None => self.add_error("\{path}: unexpected node '\{name}'")
        }
      }
    }
  }
  for child in children {
    let name = child.name.value()
    for sn in schema.nodes {
      match sn.name {
        Some(n) => if n == name { self.validate_node(child, sn, path) }
        None => ()
      }
    }
  }
}

///|
pub fn validate(
  doc : KdlDocument,
  schema : SchemaDocument,
) -> Result[Unit, KdlError] {
  let v = Validator::new()
  match schema.node_names_validation {
    Some(nnv) =>
      for node in doc.nodes {
        v.validate_value(
          KdlValue::String(node.name.value()),
          nnv,
          "document~node-name",
        )
      }
    None => ()
  }
  if !schema.other_nodes_allowed && schema.node_names_validation is None {
    for node in doc.nodes {
      let name = node.name.value()
      let matched = schema.nodes.any(fn(sn) {
        match sn.name {
          Some(n) => n == name
          None => true
        }
      })
      if !matched {
        v.add_error("document: unexpected node '\{name}'")
      }
    }
  }
  for sn in schema.nodes {
    match sn.name {
      Some(name) => {
        let mut count = 0
        for n in doc.nodes {
          if n.name.value() == name {
            count = count + 1
          }
        }
        match sn.min {
          Some(min) =>
            if count < min {
              v.add_error(
                "document: expected at least \{min} '\{name}' nodes, got \{count}",
              )
            }
          None => ()
        }
        match sn.max {
          Some(max) =>
            if count > max {
              v.add_error(
                "document: expected at most \{max} '\{name}' nodes, got \{count}",
              )
            }
          None => ()
        }
      }
      None => ()
    }
  }
  for node in doc.nodes {
    let name = node.name.value()
    for sn in schema.nodes {
      match sn.name {
        Some(n) => if n == name { v.validate_node(node, sn, "document") }
        None => ()
      }
    }
  }
  match schema.tag_names_validation {
    Some(tnv) =>
      for node in doc.nodes {
        match node.ty {
          Some(tag) =>
            v.validate_value(
              KdlValue::String(tag.value()),
              tnv,
              "document~tag-name",
            )
          None => ()
        }
      }
    None => ()
  }
  if !schema.other_tags_allowed {
    for node in doc.nodes {
      match node.ty {
        Some(tag) => {
          let tag_name = tag.value()
          let matched = schema.tags.any(fn(st) {
            match st.name {
              Some(n) => n == tag_name
              None => true
            }
          })
          if !matched {
            let node_name = node.name.value()
            let has_tag_validation = schema.nodes.any(fn(sn) {
              match sn.name {
                Some(n) => n == node_name && sn.tag_validation is Some(_)
                None => false
              }
            })
            if !has_tag_validation {
              v.add_error("document: unexpected tag '\{tag_name}'")
            }
          }
        }
        None => ()
      }
    }
  }
  if v.errors.length() > 0 {
    Err(v.to_error())
  } else {
    Ok(())
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
