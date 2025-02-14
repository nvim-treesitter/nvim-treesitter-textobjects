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

(decl_class) @class.outer

(decl_method) @function.outer

(decl_method
  (block) @function.inner) @function.outer

(for
  (block) @loop.inner) @loop.outer

(while
  (block) @loop.inner) @loop.outer

; blocks
(block) @block.outer

(invokation) @call.outer

(formal_parameters
  "," @_start
  .
  (formal_parameter) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))

(formal_parameters
  .
  (formal_parameter) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

(actual_parameters
  "," @_start
  .
  (actual_parameter) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))

(actual_parameters
  .
  (actual_parameter) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))
