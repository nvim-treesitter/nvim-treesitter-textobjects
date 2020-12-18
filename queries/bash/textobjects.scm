(function_definition
  (_) @function.inner ) @function.outer

(case_statement) @conditional.outer

(if_statement
  (_) @conditional.inner ) @conditional.outer

(for_statement
 (_) @loop.inner ) @loop.outer
(while_statement
  (_) @loop.inner ) @loop.outer

(comment) @comment.outer
