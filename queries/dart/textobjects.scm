; class
((annotation)? @class.outer
  .
  (class_definition
    body: (class_body) @class.inner) @class.outer)

(mixin_declaration
  (class_body) @class.inner) @class.outer

(enum_declaration
  body: (enum_body) @class.inner) @class.outer

(extension_declaration
  body: (extension_body) @class.inner) @class.outer

; function/method
((annotation)? @function.outer
  .
  [
    (method_signature)
    (function_signature)
  ] @function.outer
  .
  (function_body) @function.outer)

(function_body
  (block
    .
    "{"
    _+ @function.inner
    "}"))

(type_alias
  (function_type)? @function.inner) @function.outer

; parameter
[
  (formal_parameter)
  (normal_parameter_type)
  (type_parameter)
] @parameter.inner

("," @parameter.outer
  .
  [
    (formal_parameter)
    (normal_parameter_type)
    (type_parameter)
  ] @parameter.outer)

([
  (formal_parameter)
  (normal_parameter_type)
  (type_parameter)
] @parameter.outer
  .
  "," @parameter.outer)

; TODO: (_)* not supported yet -> for now this works correctly only with simple arguments
(arguments
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(arguments
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

; call
((identifier) @call.outer
  .
  (selector
    (argument_part) @call.outer))

((identifier)
  .
  (selector
    (argument_part
      (arguments
        .
        "("
        _+ @call.inner
        ")"))))

; block
(block) @block.outer

; conditional
(if_statement
  [
    condition: (_)
    consequence: (_)
    alternative: (_)?
  ] @conditional.inner) @conditional.outer

(switch_statement
  body: (switch_block) @conditional.inner) @conditional.outer

(conditional_expression
  [
    consequence: (_)
    alternative: (_)
  ] @conditional.inner) @conditional.outer

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
  ;(labeled_statement)
  (yield_statement)
  (yield_each_statement)
  (continue_statement)
  (try_statement)
] @statement.outer
