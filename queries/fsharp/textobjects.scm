(type_definition
  (anon_type_defn
    block: (_)? @class.inner)) @class.outer

(type_definition
  (record_type_defn
    block: (_)? @class.inner)) @class.outer

(type_definition
  (union_type_defn
    block: (_)? @class.inner)) @class.outer

(function_or_value_defn
  (function_declaration_left)
  body: (_)? @function.inner) @function.outer

(member_defn
  (method_or_prop_defn
    name: (property_or_ident)
    args: (paren_pattern)
    (_)? @function.inner)) @function.outer

(fun_expression
  (argument_patterns)
  (_)? @function.inner) @function.outer

(block_comment
  (block_comment_content) @comment.inner) @comment.outer

(line_comment) @comment.inner @comment.outer

(argument_patterns
  (_) @parameter.inner)
