(value_definition
  (let_binding
    ; let f x = 1 but not let x = 1
    (parameter)+
    body: (_) @function.inner)) @function.outer

(value_definition
  (let_binding
    ; let f = fun x -> body
    body: (function_expression) @function.inner)) @function.outer

(value_definition
  (let_binding
    ; let f = function | A | B -> body
    body: (fun_expression) @function.inner)) @function.outer

; standalone function expression, e.g. List.iter ~f:(function | A | B -> body)
(parenthesized_expression
  (function_expression) @function.inner) @function.outer

; standalone function expression, e.g. List.iter ~f:(fun x -> body)
(parenthesized_expression
  (fun_expression) @function.inner) @function.outer

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
