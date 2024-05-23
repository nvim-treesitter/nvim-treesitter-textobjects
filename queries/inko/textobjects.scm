; Classes
(class) @class.outer

(class
  body: (class_body
    .
    "{"
    .
    (_) @_start
    (_)? @_end
    .
    "}"
    (#make-range! "class.inner" @_start @_end)))

; Traits
(trait) @class.outer

(trait
  body: (trait_body
    .
    "{"
    .
    (_) @_start
    (_)? @_end
    .
    "}"
    (#make-range! "class.inner" @_start @_end)))

; Implementations
(implement_trait) @class.outer

(implement_trait
  body: (implement_trait_body
    .
    "{"
    .
    (_) @_start
    (_)? @_end
    .
    "}"
    (#make-range! "class.inner" @_start @_end)))

(reopen_class) @class.outer

(reopen_class
  body: (reopen_class_body
    .
    "{"
    .
    (_) @_start
    (_)? @_end
    .
    "}"
    (#make-range! "class.inner" @_start @_end)))

; Methods and closures
(method) @function.outer

(method
  body: (block
    .
    "{"
    .
    (_) @_start
    (_)? @_end
    .
    "}"
    (#make-range! "function.inner" @_start @_end)))

(closure) @function.outer

(closure
  body: (block
    .
    "{"
    .
    (_) @_start
    (_)? @_end
    .
    "}"
    (#make-range! "function.inner" @_start @_end)))

; Loops
(while
  body: (block
    .
    "{"
    .
    (_) @_start
    (_)? @_end
    .
    "}"
    (#make-range! "loop.inner" @_start @_end))) @loop.outer

(while
  condition: (_) @conditional.inner)

(loop
  body: (block
    .
    "{"
    .
    (_) @_start
    (_)? @_end
    .
    "}"
    (#make-range! "loop.inner" @_start @_end))) @loop.outer

; Conditionals
(if
  alternative: (_
    (_) @conditional.inner)?) @conditional.outer

(if
  alternative: (else
    (block) @conditional.inner))

(if
  consequence: (block)? @conditional.inner)

(if
  condition: (_) @conditional.inner)

(case) @conditional.inner

(match) @conditional.outer

; Method calls
(call) @call.outer

(call
  arguments: (arguments
    .
    "("
    .
    (_) @_start
    (_)? @_end
    .
    ")"
    (#make-range! "call.inner" @_start @_end)))

(return
  (_)? @return.inner) @return.outer

; Call and type arguments
((arguments
  "," @_start
  .
  (_) @parameter.inner)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((arguments
  .
  (_) @parameter.inner
  .
  ","? @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

((type_arguments
  "," @_start
  .
  (_) @parameter.inner)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((type_arguments
  .
  (_) @parameter.inner
  .
  ","? @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

; Patterns
((class_pattern
  "," @_start
  .
  (_) @parameter.inner)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((class_pattern
  .
  (_) @parameter.inner
  .
  ","? @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

((tuple_pattern
  "," @_start
  .
  (_) @parameter.inner)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((tuple_pattern
  .
  (_) @parameter.inner
  .
  ","? @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

; Sequence types
(tuple
  "," @_start
  .
  (_) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))

(tuple
  .
  (_) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

(array
  "," @_start
  .
  (_) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))

(array
  .
  (_) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

; Blocks
(block
  (_)? @block.inner) @block.outer

; Comments
(line_comment) @comment.outer

; Numbers
[
  (integer)
  (float)
] @number.inner

; Variable definitions and assignments
(define_variable
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(define_constant
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(assign_local
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(assign_field
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(assign_receiver_field
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(replace_local
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(replace_field
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(compound_assign_local
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(compound_assign_field
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(compound_assign_receiver_field
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer
