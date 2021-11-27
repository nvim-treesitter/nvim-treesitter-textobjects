;; Functions
; top level function with type annotation and doc comment
(
  (module_declaration)
  (block_comment) @function.outer.start
  .
  (type_annotation)
  .
  (value_declaration
    body: (_)? @function.inner) @function.outer
)

; top level function with type annotation
(
  (module_declaration)
  (type_annotation) @function.outer.start
  .
  (value_declaration
    body: (_)? @function.inner) @function.outer
)

; top level function without type annotation
(
  (module_declaration)
  (value_declaration
    body: (_)? @function.inner) @function.outer
)

;; Comments
[
  (block_comment)
  (line_comment)
] @comment.outer

; Conditionals
(if_else_expr
    exprList: (_)
    exprList: (_) @conditional.inner) @conditional.outer

(case_of_expr
    branch: (case_of_branch) @conditional.inner) @conditional.outer

;; Parameters
; type annotations
((type_expression
    (arrow) @_start .
    (type_ref) @parameter.inner
  )
  (#make-range! "parameter.outer" @_start @parameter.inner))

((type_expression
    .
    (type_ref) @parameter.inner
    . (arrow)? @_end
  )
  (#make-range! "parameter.outer" @parameter.inner @_end))

; list items
((list_expr
    "," @_start .
    exprList: (_) @parameter.inner
  )
  (#make-range! "parameter.outer" @_start @parameter.inner))

((list_expr
    .
    exprList: (_) @parameter.inner
    . ","? @_end
  )
  (#make-range! "parameter.outer" @parameter.inner @_end))

; tuple items
((tuple_expr
    "," @_start .
    expr: (_) @parameter.inner
  )
  (#make-range! "parameter.outer" @_start @parameter.inner))

((tuple_expr
    .
    expr: (_) @parameter.inner
    . ","? @_end
  )
  (#make-range! "parameter.outer" @parameter.inner @_end))
