; class
(((annotation)? @class.outer
  .
  (class_definition
    body: (class_body) @_end @class.inner) @_start)
  (#make-range! "class.outer" @_start @_end))

(mixin_declaration
  (class_body) @class.inner) @class.outer

(enum_declaration
  body: (enum_body) @class.inner) @class.outer

(extension_declaration
  body: (extension_body) @class.inner) @class.outer

; function/method
(((annotation)? @function.outer
  .
  [
    (method_signature)
    (function_signature)
  ] @_start
  .
  (function_body) @_end)
  (#make-range! "function.outer" @_start @_end))

(function_body
  (block
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "function.inner" @_start @_end)))

(type_alias
  (function_type)? @function.inner) @function.outer

; parameter
[
  (formal_parameter)
  (normal_parameter_type)
  (type_parameter)
] @parameter.inner

("," @_start
  .
  [
    (formal_parameter)
    (normal_parameter_type)
    (type_parameter)
  ] @_par
  (#make-range! "parameter.outer" @_start @_par))

([
  (formal_parameter)
  (normal_parameter_type)
  (type_parameter)
] @_par
  .
  "," @_end
  (#make-range! "parameter.outer" @_par @_end))

; TODO: (_)* not supported yet -> for now this works correctly only with simple arguments
((arguments
  .
  (_) @parameter.inner
  .
  ","? @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

((arguments
  "," @_start
  .
  (_) @parameter.inner)
  (#make-range! "parameter.outer" @_start @parameter.inner))

; call
((identifier) @_start
  .
  (selector
    (argument_part) @_end)
  (#make-range! "call.outer" @_start @_end))

((identifier)
  .
  (selector
    (argument_part
      (arguments
        .
        "("
        .
        (_) @_start
        (_)? @_end
        .
        ")"
        (#make-range! "call.inner" @_start @_end)))))

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
