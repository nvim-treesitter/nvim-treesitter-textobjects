;; functions
(function_declaration
  body: (block) @function.inner) @function.outer

;; loops
(for_expression
  body: (block) @loop.inner) @loop.outer

(while_expression
  body: (block) @loop.inner) @loop.outer

;; blocks
(_ (block) @block.inner) @block.outer

;; comments
(doc_comment) @comment.outer
(line_comment) @comment.outer

;; conditionals
(if_expression
  consequence: (_ (block) @conditional.inner)
  alternative: (block)? @conditional.inner) @conditional.outer

(switch_expression 
  body: (_) @conditional.inner) @conditional.outer

;; calls
(call_expression (arguments) @call.inner) @call.outer
