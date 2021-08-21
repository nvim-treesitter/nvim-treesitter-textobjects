;; functions
(function_declaration
  body: (block) @function.inner) @function.outer

;; loops
(for_expression
  body: (block) @loop.inner) @loop.outer

(while_expression
  body: (block) @loop.inner) @loop.outer

;; comments
(doc_comment) @comment.outer
(line_comment) @comment.outer
