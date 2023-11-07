;; TODO: supported by official Tree-sitter  if (_)* is more than one node
;; Neovim: will only match if (_) is exactly one node
;(function_definition
  ;body:  (compound_statement
                          ;("{" (_)* @function.inner "}"))?) @function.outer
(declaration
  declarator: (function_declarator)) @function.outer

(function_definition
  body:  (compound_statement)) @function.outer

(function_definition
  body: (compound_statement . "{" . (_) @_start @_end (_)? @_end . "}"
 (#make-range! "function.inner" @_start @_end)))

(struct_specifier
  body: (_) @class.inner) @class.outer

(enum_specifier
  body: (_) @class.inner) @class.outer

; conditionals
(if_statement
  consequence: (compound_statement . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "conditional.inner" @_start @_end))) @conditional.outer

(if_statement
  alternative: (else_clause (compound_statement . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "conditional.inner" @_start @_end)))) @conditional.outer

(if_statement) @conditional.outer

; loops
(while_statement) @loop.outer
(while_statement
  body: (compound_statement . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "loop.inner" @_start @_end))) @loop.outer

(for_statement) @loop.outer
(for_statement
  body: (compound_statement . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "loop.inner" @_start @_end))) @loop.outer

(do_statement) @loop.outer
(do_statement
  body: (compound_statement . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "loop.inner" @_start @_end))) @loop.outer

(compound_statement) @block.outer
(comment) @comment.outer

(call_expression) @call.outer
(call_expression
  arguments: (argument_list . "(" . (_) @_start (_)? @_end . ")"
  (#make-range! "call.inner" @_start @_end)))

(return_statement
  (_)? @return.inner) @return.outer

; Statements

;(expression_statement ;; this is what we actually want to capture in most cases (";" is missing) probably
  ;(_) @statement.inner) ;; the other statement like node type is declaration but declaration has a ";"

(compound_statement
  (_) @statement.outer)

(field_declaration_list
  (_) @statement.outer)

(preproc_if
  (_) @statement.outer)

(preproc_elif
  (_) @statement.outer)

(preproc_else
  (_) @statement.outer)

((parameter_list
  "," @_start . (parameter_declaration) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner))
((parameter_list
  . (parameter_declaration) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

((argument_list
  "," @_start . (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner))
((argument_list
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

(number_literal) @number.inner
