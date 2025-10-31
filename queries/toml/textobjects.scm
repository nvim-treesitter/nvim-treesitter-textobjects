[
  (integer)
  (float)
] @number.inner

(table
  (pair) @parameter.inner @parameter.outer)

(inline_table
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(inline_table
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(array
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(array
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(comment) @comment.outer
