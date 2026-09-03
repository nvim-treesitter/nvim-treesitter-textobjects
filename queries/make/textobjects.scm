; leave space after comment marker if there is one
((comment) @comment.inner @comment.outer
  (#offset! @comment.inner 0 2 0 0)
  (#lua-match? @comment.outer "# .*"))

; else remove everything accept comment marker
((comment) @comment.inner @comment.outer
  (#offset! @comment.inner 0 1 0 0))

(rule
  (recipe) @class.inner) @class.outer

(define_directive
  value: (raw_text) @function.inner) @function.outer

(condition
  (_)
  (_)+ @loop.inner) @loop.outer

(else_directive
  (_)+ @loop.inner) @loop.outer
