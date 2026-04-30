///|
using @lenitain/kdl {
  type KdlDocument,
  type KdlNode,
  type KdlEntry,
  type KdlValue,
}

///|
pub fn query(
  doc : KdlDocument,
  query_str : String,
) -> Result[Array[KdlNode], String] {
  match parse_kql(query_str) {
    Ok(q) => Ok(execute_query(q, doc))
    Err(e) => Err(e)
  }
}

///|
fn execute_query(qql_query : KqlQuery, doc : KdlDocument) -> Array[KdlNode] {
  match qql_query {
    Single(sel) => execute_selector_top(sel, doc.nodes(), doc)
    Union(left, sel) => {
      let left_results = execute_query(left, doc)
      let right_results = execute_selector_top(sel, doc.nodes(), doc)
      union_nodes(left_results, right_results)
    }
  }
}

///|
fn is_simple_filter(selector : KqlSelector) -> Bool {
  match selector {
    Filter(f) =>
      match f {
        Top => false
        Matchers(_) => true
      }
    _ => false
  }
}

///|
fn execute_selector_top(
  selector : KqlSelector,
  top_nodes : Array[KdlNode],
  _doc : KdlDocument,
) -> Array[KdlNode] {
  if is_simple_filter(selector) {
    let all_nodes = collect_all_nodes_from(top_nodes)
    execute_selector(selector, all_nodes)
  } else {
    execute_selector(selector, top_nodes)
  }
}

///|
fn collect_all_nodes_from(nodes : Array[KdlNode]) -> Array[KdlNode] {
  let result : Array[KdlNode] = []
  for node in nodes {
    result.push(node)
    collect_descendants(node, result)
  }
  result
}

///|
fn execute_selector(
  selector : KqlSelector,
  nodes : Array[KdlNode],
) -> Array[KdlNode] {
  match selector {
    Filter(f) => execute_filter(f, nodes)
    Child(sel, f) => {
      let parents = execute_selector(sel, nodes)
      let all_children : Array[KdlNode] = []
      for parent in parents {
        match parent.children {
          Some(ch) =>
            for c in ch {
              all_children.push(c)
            }
          None => ()
        }
      }
      execute_filter(f, all_children)
    }
    Descendant(sel, f) => {
      let ancestors = execute_selector(sel, nodes)
      let all_descendants : Array[KdlNode] = []
      for ancestor in ancestors {
        collect_descendants(ancestor, all_descendants)
      }
      execute_filter(f, all_descendants)
    }
    NextSibling(sel, f) => {
      let results : Array[KdlNode] = []
      scan_siblings(nodes, sel, f, true, results)
      results
    }
    LaterSibling(sel, f) => {
      let results : Array[KdlNode] = []
      scan_siblings(nodes, sel, f, false, results)
      results
    }
  }
}

///|
fn scan_siblings(
  nodes : Array[KdlNode],
  sel : KqlSelector,
  f : KqlFilter,
  only_next : Bool,
  results : Array[KdlNode],
) -> Unit {
  for node in nodes {
    match node.children {
      Some(children) => {
        let len = children.length()
        for i in 0..<len {
          if selector_matches(children[i], sel) {
            let start = i + 1
            let end = if only_next { start + 1 } else { len }
            for j in start..<end {
              if match_filter(f, children[j]) {
                results.push(children[j])
              }
            }
          }
        }
        scan_siblings(children, sel, f, only_next, results)
      }
      None => ()
    }
  }
}

///|
fn selector_matches(node : KdlNode, selector : KqlSelector) -> Bool {
  match selector {
    Filter(f) => match_filter(f, node)
    Child(sel, f) => {
      if !selector_matches(node, sel) {
        return false
      }
      match node.children {
        Some(ch) => {
          for c in ch {
            if match_filter(f, c) {
              return true
            }
          }
          false
        }
        None => false
      }
    }
    Descendant(sel, f) => {
      if !selector_matches(node, sel) {
        return false
      }
      has_descendant_matching(node, f)
    }
    NextSibling(_, _) => false
    LaterSibling(_, _) => false
  }
}

///|
fn has_descendant_matching(node : KdlNode, f : KqlFilter) -> Bool {
  match node.children {
    Some(ch) => {
      for c in ch {
        if match_filter(f, c) {
          return true
        }
        if has_descendant_matching(c, f) {
          return true
        }
      }
      false
    }
    None => false
  }
}

///|
fn collect_descendants(node : KdlNode, result : Array[KdlNode]) -> Unit {
  match node.children {
    Some(ch) =>
      for c in ch {
        result.push(c)
        collect_descendants(c, result)
      }
    None => ()
  }
}

///|
fn execute_filter(f : KqlFilter, nodes : Array[KdlNode]) -> Array[KdlNode] {
  match f {
    Top => nodes
    Matchers(matchers) => {
      let results : Array[KdlNode] = []
      for node in nodes {
        if match_all_matchers(matchers, node) {
          results.push(node)
        }
      }
      results
    }
  }
}

///|
fn match_filter(f : KqlFilter, node : KdlNode) -> Bool {
  match f {
    Top => true
    Matchers(matchers) => match_all_matchers(matchers, node)
  }
}

///|
fn match_all_matchers(matchers : Array[KqlMatcher], node : KdlNode) -> Bool {
  for m in matchers {
    if !match_node(m, node) {
      return false
    }
  }
  true
}

///|
fn match_node(matcher : KqlMatcher, node : KdlNode) -> Bool {
  match matcher {
    TypeAnnotation(opt) =>
      match (opt, node.ty) {
        (Some(expected), Some(ty)) => ty.value() == expected
        (None, None) => true
        _ => false
      }
    NodeName(name) => node.name.value() == name
    StringLiteral(s) => node.name.value() == s
    AccessorMatcher(acc, cmp) => {
      let actual = evaluate_accessor(acc, node)
      match cmp {
        Some(c) => compare_values(c, actual)
        None => actual is Some(_)
      }
    }
  }
}

///|
fn evaluate_accessor(accessor : KqlAccessor, node : KdlNode) -> KdlValue? {
  match accessor {
    Val(i) => {
      let args = get_args(node)
      if i < args.length() {
        Some(args[i].value)
      } else {
        None
      }
    }
    Prop(key) => {
      for entry in node.entries {
        match entry.name {
          Some(n) => if n.value() == key { return Some(entry.value) }
          None => ()
        }
      }
      None
    }
    Name => Some(KdlValue::String(node.name.value()))
    Tag =>
      match node.ty {
        Some(ty) => Some(KdlValue::String(ty.value()))
        None => None
      }
    Values => {
      for entry in node.entries {
        if entry.name is None {
          return Some(KdlValue::Null)
        }
      }
      None
    }
    Props => {
      for entry in node.entries {
        if entry.name is Some(_) {
          return Some(KdlValue::Null)
        }
      }
      None
    }
    PropertyKey(key) => {
      for entry in node.entries {
        match entry.name {
          Some(n) => if n.value() == key { return Some(entry.value) }
          None => ()
        }
      }
      None
    }
  }
}

///|
fn compare_values(comparison : KqlComparison, actual : KdlValue?) -> Bool {
  match comparison {
    Eq(expected) =>
      match actual {
        Some(a) => values_equal(a, expected)
        None => false
      }
    Neq(expected) =>
      match actual {
        Some(a) => !values_equal(a, expected)
        None => true
      }
    Gt(expected) =>
      match actual {
        Some(a) => compare_gt(a, expected)
        None => false
      }
    Lt(expected) =>
      match actual {
        Some(a) => compare_lt(a, expected)
        None => false
      }
    Gte(expected) =>
      match actual {
        Some(a) => compare_gt(a, expected) || values_equal(a, expected)
        None => false
      }
    Lte(expected) =>
      match actual {
        Some(a) => compare_lt(a, expected) || values_equal(a, expected)
        None => false
      }
    CaretEq(expected) =>
      match (actual, expected) {
        (Some(KdlValue::String(a)), KqlValue::String(e)) => a.has_prefix(e)
        _ => false
      }
    DollarEq(expected) =>
      match (actual, expected) {
        (Some(KdlValue::String(a)), KqlValue::String(e)) => a.has_suffix(e)
        _ => false
      }
    StarEq(expected) =>
      match (actual, expected) {
        (Some(KdlValue::String(a)), KqlValue::String(e)) => a.contains(e)
        _ => false
      }
  }
}

///|
fn values_equal(actual : KdlValue, expected : KqlValue) -> Bool {
  match (actual, expected) {
    (KdlValue::String(a), KqlValue::String(e)) => a == e
    (KdlValue::Integer(a), KqlValue::Integer(e)) => a == e
    (KdlValue::Float(a), KqlValue::Float(e)) => a == e
    (KdlValue::Bool(a), KqlValue::Bool(e)) => a == e
    (KdlValue::Null, KqlValue::Null) => true
    (KdlValue::Integer(a), KqlValue::Float(e)) => a.to_double() == e
    (KdlValue::Float(a), KqlValue::Integer(e)) => a == e.to_double()
    _ => false
  }
}

///|
fn compare_gt(actual : KdlValue, expected : KqlValue) -> Bool {
  match (actual, expected) {
    (KdlValue::String(a), KqlValue::String(e)) => a > e
    (KdlValue::Integer(a), KqlValue::Integer(e)) => a > e
    (KdlValue::Float(a), KqlValue::Float(e)) => a > e
    (KdlValue::Bool(a), KqlValue::Bool(e)) => a && !e
    (KdlValue::Integer(a), KqlValue::Float(e)) => a.to_double() > e
    (KdlValue::Float(a), KqlValue::Integer(e)) => a > e.to_double()
    _ => false
  }
}

///|
fn compare_lt(actual : KdlValue, expected : KqlValue) -> Bool {
  match (actual, expected) {
    (KdlValue::String(a), KqlValue::String(e)) => a < e
    (KdlValue::Integer(a), KqlValue::Integer(e)) => a < e
    (KdlValue::Float(a), KqlValue::Float(e)) => a < e
    (KdlValue::Bool(a), KqlValue::Bool(e)) => !a && e
    (KdlValue::Integer(a), KqlValue::Float(e)) => a.to_double() < e
    (KdlValue::Float(a), KqlValue::Integer(e)) => a < e.to_double()
    _ => false
  }
}

///|
fn get_args(node : KdlNode) -> Array[KdlEntry] {
  let args : Array[KdlEntry] = []
  for entry in node.entries {
    if entry.name is None {
      args.push(entry)
    }
  }
  args
}

///|
fn union_nodes(a : Array[KdlNode], b : Array[KdlNode]) -> Array[KdlNode] {
  let result : Array[KdlNode] = []
  for node in a {
    result.push(node)
  }
  for node in b {
    if !contains_node(result, node) {
      result.push(node)
    }
  }
  result
}

///|
fn contains_node(arr : Array[KdlNode], target : KdlNode) -> Bool {
  for node in arr {
    if node == target {
      return true
    }
  }
  false
}
