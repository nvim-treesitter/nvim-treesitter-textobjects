(function_definition) @function.outer

(function_definition
  body: (compound_statement . "{" . (_) @_start @_end (_)? @_end . "}"
 (#make-range! "function.inner" @_start @_end)))

(case_statement) @conditional.outer

(if_statement
  (_) @conditional.inner ) @conditional.outer

(for_statement
 (_) @loop.inner ) @loop.outer
(while_statement
  (_) @loop.inner ) @loop.outer

(comment) @comment.outer
