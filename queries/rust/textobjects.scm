;; functions
(function_item
  body: (block . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "function.inner" @_start @_end))) @function.outer

;; quantifies as class(es)
(struct_item
  body: (field_declaration_list . "{" . (_) @_start [(_)","]? @_end . "}"
  (#make-range! "class.inner" @_start @_end))) @class.outer

(enum_item
  body: (enum_variant_list . "{" . (_) @_start [(_)","]? @_end . "}"
  (#make-range! "class.inner" @_start @_end))) @class.outer

(union_item
  body: (field_declaration_list . "{" . (_) @_start [(_)","]? @_end . "}"
  (#make-range! "class.inner" @_start @_end))) @class.outer

(trait_item
  body: (declaration_list . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "class.inner" @_start @_end))) @class.outer

(impl_item
  body: (declaration_list . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "class.inner" @_start @_end))) @class.outer

(mod_item
  body: (declaration_list . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "class.inner" @_start @_end))) @class.outer

;; conditionals
(if_expression
  alternative: (_ (_) @conditional.inner)?
  ) @conditional.outer

(if_expression
  alternative: (else_clause (block) @conditional.inner))

(if_expression
  condition: (_) @conditional.inner)

(if_expression
  consequence: (block) @conditional.inner)

(match_arm
  (_)) @conditional.inner

(match_expression) @conditional.outer

;; loops
(loop_expression
  (_)? @loop.inner) @loop.outer

(while_expression
  (_)? @loop.inner) @loop.outer

(for_expression
  body: (block)? @loop.inner) @loop.outer

;; blocks
(_ (block) @block.inner) @block.outer
(unsafe_block (_)? @block.inner) @block.outer

;; calls
(call_expression) @call.outer
(call_expression
  arguments: (arguments . "(" . (_) @_start (_)? @_end . ")"
  (#make-range! "call.inner" @_start @_end)))

;; statements
(block (_) @statement.outer)

;; comments
(line_comment) @comment.outer
(block_comment) @comment.outer

;; parameter

((parameters
  "," @_start . (parameter) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner))
((parameters
  . (parameter) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

((type_parameters
  "," @_start . (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner))
((type_parameters
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

((tuple_pattern
  "," @_start . (identifier) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner))
((tuple_pattern
  . (identifier) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

((tuple_struct_pattern
  "," @_start . (identifier) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner))
((tuple_struct_pattern
  . (identifier) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

((closure_parameters
  "," @_start . (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner))
((closure_parameters
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

((arguments
  "," @_start . (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner))
((arguments
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

((type_arguments
  "," @_start . (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner))
((type_arguments
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))