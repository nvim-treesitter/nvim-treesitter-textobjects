(function_definition) @function.outer

(for_statement
  (_) @loop.inner) @loop.outer

(while_statement
  condition: (command)
  (command) @loop.inner) @loop.outer

(if_statement
  (command) @conditional.inner) @conditional.outer

(switch_statement 
  (_) @conditional.inner) @conditional.outer

(comment) @comment.outer
