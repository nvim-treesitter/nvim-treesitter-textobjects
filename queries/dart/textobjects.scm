; class
(class_definition
  body: (class_body) @class.inner) @class.outer
(mixin_declaration (class_body) @class.inner) @class.outer
(enum_declaration
  body: (enum_body) @class.inner) @class.outer
(extension_declaration
  body: (extension_body) @class.inner) @class.outer

; function/method
(( 
  (marker_annotation)? @function.outer.start .
  [(method_signature) (function_signature)] @_start
  .
  (function_body) @_end
)
(make-range! "function.outer" @_start @_end))

(function_body) @function.inner
(type_alias (function_type) @function.inner) @function.outer

; parameter
(formal_parameter) @parameter.inner
(arguments (_) @parameter.inner)
(normal_parameter_type) @parameter.inner
(type_parameter) @parameter.inner

; call
(expression_statement
  (selector) @call.inner) @call.outer

; block
(block) @block.outer

; conditional
(if_statement
  condition: (_) @condition.inner
  consequence: (_)? @condition.inner
  alternative: (_)? @condition.inner
  ) @condition.outer
(switch_statement
  body: (switch_block) @condition.inner) @condition.outer
(conditional_expression
  consequence: (_)? @condition.inner
  alternative: (_)? @condition.inner
) @condition.outer

; loop
(for_statement
  body: (block) @loop.inner) @loop.outer
(while_statement
  body: (block) @loop.inner) @loop.outer
(do_statement
  body: (block) @loop.inner) @loop.outer

; comment
[
  (comment)
  (documentation_comment)
] @comment.outer

; statement
[
  (break_statement)
  (do_statement)
  (expression_statement)
  (for_statement)
  (if_statement)
  (return_statement)
  (switch_statement)
  (while_statement)
  (assert_statement)
  (labeled_statement)
  (yield_statement)
  (yield_each_statement)
  (continue_statement)
  (try_statement)
] @statement.outer
