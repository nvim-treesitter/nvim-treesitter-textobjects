;; blocks
(call
  block: (_) @block.inner) @block.outer

;; calls
(call
  method: (_) @call.inner ) @call.outer

;; classes
[
  (class
    name: (constant)
    superclass: (_)
    (_) @class.inner)

  (module
    name: (constant)
    (_) @class.inner)
] @class.outer

;; comments
(comment) @comment.outer

;; conditionals
[
  (if
   consequence: (_) @conditional.inner
   alternative: (_) @conditional.inner)

  (if_modifier
    condition: (_) @conditional.inner)

  (until_modifier
     condition: (_) @conditional.inner)

  (unless
   consequence: (_) @conditional.inner
   alternative: (_) @conditional.inner)

  (case
    value: (_)
    (_) @conditional.inner)
]  @conditional.outer

;; functions
[
  (method
    (identifier)
    (_) @function.inner)

  (singleton_method
    (identifier)
    (_) @function.inner)
] @function.outer

;; loops
[
  (while
    body: (_) @loop.inner)

  (while_modifier
    condition: (_) @loop.inner)

  (until
    body: (_) @loop.inner)

  (until_modifier
    condition: (_) @loop.inner)

  (for
    body: (_) @loop.inner)
] @loop.outer

;; parameters

[
 (block_parameters (_) @parameter.inner)

 (method_parameters (_) @parameters.inner )
] @parameters.outer
