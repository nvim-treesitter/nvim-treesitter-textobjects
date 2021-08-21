(class_declaration 
  body: (declaration_list) @class.inner) @class.outer

(struct_declaration
  body: (declaration_list) @class.inner) @class.outer

(method_declaration
  body: (block) ? @function.inner) @function.outer

(lambda_expression 
  body: (_) @function.inner) @function.outer

;; loops
(for_statement
  body: (_) @loop.inner) @loop.outer

(for_each_statement
  body: (_) @loop.inner) @loop.outer

(do_statement
  (block) @loop.inner) @loop.outer

(while_statement
  (block) @loop.inner) @loop.outer

;; conditionals
(if_statement
  consequence: (_)? @conditional.inner
  alternative: (_)? @conditional.inner) @conditional.outer

(switch_statement
  body: (switch_body) @conditional.inner) @conditional.outer

;; calls
(invocation_expression) @call.outer

(invocation_expression 
  (argument_list) @call.inner)

;; blocks
(_ (block) @block.inner) @block.outer

;; arguments
(argument_list 
  (_) @call.inner)

;; parameters
(parameter_list
  (_) @parameter.inner) @parameter.outer
