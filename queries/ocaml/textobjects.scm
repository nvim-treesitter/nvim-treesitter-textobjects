(value_definition
  (let_binding
    ; let f x = 1 but not let x = 1
    (parameter)+
    body: (_) @function.inner)) @function.outer

(value_definition
  (let_binding
    ; let f = function | A | B -> body
    body: (function_expression) @function.inner)) @function.outer

(value_definition
  (let_binding
    ; let f = fun x -> body
    body: (fun_expression) @function.inner)) @function.outer

; standalone function expression, e.g. List.iter ~f:(function | A | B -> body)
(parenthesized_expression
  (function_expression) @function.inner) @function.outer

; standalone function expression, e.g. List.iter ~f:(fun x -> body)
(parenthesized_expression
  (fun_expression) @function.inner) @function.outer

(method_definition
  body: (_) @function.inner) @function.outer

; let pattern = body (also matches let f x = expr due to grammar limits)
; Since we want @assignment.inner to match both pattern and body we have to split it into two:
(value_definition
  (let_binding
    pattern: (_) @assignment.lhs @assignment.inner)) @assignment.outer

(value_definition
  (let_binding
    body: (_) @assignment.rhs @assignment.inner))

; module M = struct ... end
(module_definition
  (module_binding
    body: (structure) @class.inner)) @class.outer

; struct ... end
(structure
  (_structure_item)+ @block.inner) @block.outer

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

; parenthesized selections are handled well by vi(
