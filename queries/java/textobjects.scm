(class_declaration
  body: (class_body) @class.inner) @class.outer

(method_declaration
  body: (_) @function.inner) @function.outer

(constructor_declaration) @function.outer
(constructor_body) @function.inner

(for_statement
  body: (_)? @loop.inner) @loop.outer

(enhanced_for_statement
  body: (_)? @loop.inner) @loop.outer

(while_statement
  body: (_)? @loop.inner) @loop.outer

(do_statement
  body: (_)? @loop.inner) @loop.outer

(if_statement
  condition: (_ (parenthesized_expression) @conditional.inner)  @conditional.outer)

(if_statement
  consequence: (_)? @conditional.inner
  alternative: (_)? @conditional.inner
  ) @conditional.outer

(switch_expression
  body: (_)? @conditional.inner) @conditional.outer

;; blocks
(block) @block.outer


(method_invocation) @call.outer
(method_invocation (argument_list) @call.inner)

;; parameters
(formal_parameters
  "," @_start .
  (formal_parameter) @parameter.inner
 (#make-range! "parameter.outer" @_start @parameter.inner))
(formal_parameters
  . (formal_parameter) @parameter.inner
  . ","? @_end
 (#make-range! "parameter.outer" @_end @parameter.inner))

[
  (line_comment)
  (block_comment)
] @comment.outer
