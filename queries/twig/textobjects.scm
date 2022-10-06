;; comments
(comment) @comment.outer

;; statement
(statement_directive) @statement.outer

;; @parameter
(arguments
  "," @_start .
  (_) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))
(arguments
  . (_) @parameter.inner
  . ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

(parameters
  "," @_start .
  (_) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))
(parameters
  . (_) @parameter.inner
  . ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

