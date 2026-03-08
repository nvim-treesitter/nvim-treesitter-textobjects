; anonymous functions (it => ...)
(lambda
  value: (block
    .
    "{"
    _+ @function.inner
    "}")) @function.outer

(lambda
  value: (_
    .
    "{"?
    _+ @function.inner
    "}"?)) @function.outer

; named functions (#let fn(x) = { ... })
(let
  pattern: (call)
  value: (block
    .
    "{"
    _+ @function.inner
    "}")) @function.outer

(let
  pattern: (call)
  value: (_
    .
    "{"?
    _+ @function.inner
    "}"?)) @function.outer

; conditionals
(while
  condition: (_) @conditional.inner)

(branch
  condition: (_) @conditional.inner) @conditional.outer

; loops
(for
  (block) @loop.inner) @loop.outer

(while
  (block) @loop.inner) @loop.outer

; calls & parameters
(call
  (group
    "," @parameter.outer
    .
    (_) @parameter.inner @parameter.outer) @call.inner) @call.outer

(call
  (group
    .
    (_) @parameter.inner @parameter.outer
    .
    ","? @parameter.outer) @call.inner) @call.outer

; let it => { ... }
(lambda
  pattern: (ident) @parameter.inner @parameter.outer)

; let (x, y) => { ... }
(lambda
  pattern: (group
    "," @parameter.outer
    .
    (_) @parameter.inner @parameter.outer))

(lambda
  pattern: (group
    .
    (_) @parameter.inner @parameter.outer
    .
    ","? @parameter.outer))

; blocks
(_
  (block
    .
    "{"
    _+ @block.inner
    "}")) @block.outer

; regexes
((call
  item: (ident) @_regex
  (group
    (_) @regex.inner)) @regex.outer
  (#eq? @_regex "regex"))

; assignments
(assign) @assignment.inner @assignment.outer

(let
  .
  "let"
  _+ @assignment.inner) @assignment.outer

(_
  pattern: (_) @assignment.lhs
  value: (_) @assignment.rhs)

; others
(comment) @comment.outer

(return) @return.outer

(return
  (_) @return.inner)

(number) @number.inner
