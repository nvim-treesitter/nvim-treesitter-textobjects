; comments
(comment) @comment.outer

; statement
(statement_directive) @statement.outer

; @parameter
(arguments
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(arguments
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(parameters
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(parameters
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)
