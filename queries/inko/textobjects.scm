; Classes
(class) @class.outer

(class
  body: (class_body
    .
    "{"
    _+ @class.inner
    "}"))

; Traits
(trait) @class.outer

(trait
  body: (trait_body
    .
    "{"
    _+ @class.inner
    "}"))

; Implementations
(implement_trait) @class.outer

(implement_trait
  body: (implement_trait_body
    .
    "{"
    _+ @class.inner
    "}"))

(reopen_class) @class.outer

(reopen_class
  body: (reopen_class_body
    .
    "{"
    _+ @class.inner
    "}"))

; Methods and closures
(method) @function.outer

(method
  body: (block
    .
    "{"
    _+ @function.inner
    "}"))

(closure) @function.outer

(closure
  body: (block
    .
    "{"
    _+ @function.inner
    "}"))

; Loops
(while
  body: (block
    .
    "{"
    _+ @loop.inner
    "}")) @loop.outer

(while
  condition: (_) @conditional.inner)

(loop
  body: (block
    .
    "{"
    _+ @loop.inner
    "}")) @loop.outer

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
    _+ @call.inner
    ")"))

(return
  (_)? @return.inner) @return.outer

; Call and type arguments
(arguments
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(arguments
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(type_arguments
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(type_arguments
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; Patterns
(class_pattern
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(class_pattern
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(tuple_pattern
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(tuple_pattern
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; Sequence types
(tuple
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(tuple
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
(identifier_pattern
  name: (_) @assignment.lhs
  type: (_) @assignment.inner @assignment.rhs) @assignment.outer

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
