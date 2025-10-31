(value_definition
  (let_binding
    body: (_) @function.inner)) @function.outer

(method_definition
  body: (_) @function.inner) @function.outer

(class_definition
  (class_binding
    body: (_) @class.inner)) @class.outer

(for_expression
  (do_clause
    (_) @loop.inner)) @loop.outer

(while_expression
  (do_clause
    (_) @loop.inner)) @loop.outer

(if_expression
  condition: (_)
  (then_clause
    (_) @conditional.inner)
  (else_clause
    (_) @conditional.inner)) @conditional.outer

(if_expression
  condition: (_)
  (then_clause
    (_) @conditional.inner)) @conditional.outer

(function_expression
  (match_case)+ @conditional.inner) @conditional.outer

(match_expression
  (match_case)+ @conditional.inner) @conditional.outer

(comment) @comment.outer

(parameter) @parameter.outer

(application_expression
  argument: (_) @parameter.outer) @call.outer

(application_expression
  argument: (_)+ @call.inner)

(parenthesized_expression
  _+ @block.inner) @block.outer
