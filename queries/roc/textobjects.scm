(anon_fun_expr
  (expr_body) @function.inner) @function.outer

(argument_patterns
  ((_) @parameter.inner
    .
    ","? @parameter.outer) @parameter.outer)

(function_type
  ((_) @parameter.inner
    .
    ","? @parameter.outer) @parameter.outer
  (#not-eq? @parameter.inner "->"))

(function_call_expr
  .
  (_)
  (parenthesized_expr
    (expr_body) @parameter.inner) @parameter.outer)

(function_call_expr
  .
  (_) @parameter.inner @parameter.outer)

[
  (annotation_type_def)
  (alias_type_def)
  (opaque_type_def)
] @class.inner @class.outer

(apply_type_arg) @parameter.inner

((#offset! line_comment 0 1 0 -1)) @comment.inner

(line_comment) @comment.outer

((#offset! doc_comment 0 1 0 -2)) @comment.inner

(doc_comment) @comment.outer
