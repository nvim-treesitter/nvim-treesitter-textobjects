; Functions
; top level function with type annotation and doc comment
((module_declaration)
  (block_comment) @function.outer
  .
  (type_annotation)
  .
  (value_declaration
    body: (_)? @function.inner) @function.outer)

; top level function with type annotation
((module_declaration)
  (type_annotation) @function.outer
  .
  (value_declaration
    body: (_)? @function.inner) @function.outer)

; top level function without type annotation
((module_declaration)
  (value_declaration
    body: (_)? @function.inner) @function.outer)

; Comments
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

; Parameters
; type annotations
(type_expression
  (arrow) @parameter.outer
  .
  (type_ref) @parameter.inner @parameter.outer)

(type_expression
  .
  (type_ref) @parameter.inner @parameter.outer
  .
  (arrow)? @parameter.outer)

; list items
(list_expr
  "," @parameter.outer
  .
  exprList: (_) @parameter.inner @parameter.outer)

(list_expr
  .
  exprList: (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; tuple items
(tuple_expr
  "," @parameter.outer
  .
  expr: (_) @parameter.inner @parameter.outer)

(tuple_expr
  .
  expr: (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)
