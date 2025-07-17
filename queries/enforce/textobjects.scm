[
  (comment_line)
  (comment_block)
  (doc_line)
  (doc_block)
] @comment.outer

[
  (literal_int)
  (literal_float)
] @number.inner

; TODO: capture inside braces
(decl_class
  body: (_) @class.inner) @class.outer

(decl_method
  body: (_) @function.inner) @function.outer

(for
  body: (_) @loop.inner) @loop.outer

(while
  body: (_) @loop.inner) @loop.outer

(return
  (_)? @return.inner) @return.outer

; blocks
(block) @block.outer

(invokation) @call.outer

; parameters
(formal_parameters
  "," @parameter.outer
  .
  (formal_parameter) @parameter.inner @parameter.outer)

(formal_parameters
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(actual_parameters
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(actual_parameters
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)
