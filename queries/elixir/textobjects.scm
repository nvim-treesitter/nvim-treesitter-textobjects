[
  (call function: (function_identifier) (call) (do_block (_) @function.inner))
  (call function: (function_identifier) (call) (keyword_list (keyword) (_)
  @function.inner))
  (call function: (function_identifier) (binary_op) (do_block (_) @function.inner))
  (call function: (function_identifier) (binary_op) (keyword_list (keyword) (_)
  @function.inner))
  (anonymous_function (_) @function.inner)
] @function.outer

(call function: (function_identifier) (module) (do_block (_) @class.inner)) @class.outer

((unary_op (call function: (function_identifier) @_annotator (heredoc (heredoc_start)
 (heredoc_content) @comment.inner (heredoc_end)))) @comment.outer
 (#match? @_annotator "doc$"))

(comment) @comment.outer

(call 
  function: (function_identifier) @_call 
  (do_block) @conditional.inner
  (#any-of? @_call "if" "case" "cond")
) @conditional.outer

(arguments
  "," @_start .
  (_) @parameter.inner
 (#make-range! "parameter.outer" @_start @parameter.inner))
(arguments
  . (_) @parameter.inner
  . ","? @_end
 (#make-range! "parameter.outer" @parameter.inner @_end))


