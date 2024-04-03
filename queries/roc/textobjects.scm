(anon_fun_expr
  (expr_body) @function.inner
) @function.outer

(argument_patterns
  ((_) @parameter.inner . ","? @parameter.outer) @parameter.outer
)

(function_type
  ((_) @parameter.inner . ","? @parameter.outer) @parameter.outer(#not-eq? @parameter.inner "->")
)

(function_call_expr
  .
  (_)
  (parenthesized_expr (expr_body) @parameter.inner) @parameter.outer
)

(function_call_expr
  .
  (_) ((_) @parameter.inner) @parameter.outer
)

[
  (annotation_type_def ) @class.inner
  (alias_type_def ) @class.inner
  (opaque_type_def ) @class.inner
] @class.outer

(apply_type_arg) @parameter.inner

(line_comment) @comment.outer
(doc_comment) @comment.outer


