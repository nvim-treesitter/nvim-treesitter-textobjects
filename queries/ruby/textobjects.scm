;; @functions
(
  [
    (method
      . name: (identifier)
      !parameters
      . (_) @_start (_) @_end .)

    (method
      . name: (identifier)
      . parameters: (method_parameters)
      . (_) @_start (_) @_end .)

    (singleton_method
      . object: (_)
      . name: (identifier)
      !parameters
      . (_) @_start (_) @_end .)

    (singleton_method
      . object: (_)
      . name: (identifier)
      . parameters: (method_parameters)
      . (_) @_start (_) @_end .)
  ] @function.outer
   (#make-range! "function.inner" @_start @_end))

[
  (method
    . name: (identifier)
    !parameters
    . (_) @function.inner .)

  (method
    . name: (identifier)
    . parameters: (method_parameters)
    . (_) @function.inner .)

  (singleton_method
    . object: (_)
    . name: (identifier)
    !parameters
    . (_) @function.inner .)

  (singleton_method
    . object: (_)
    . name: (identifier)
    . parameters: (method_parameters)
    . (_) @function.inner .)
] @function.outer

;; @blocks
(
  [
    (call
      block: (_
        !parameters
        . (_) @_start (_) @_end .)
      )

    (call
      block: (_
        . parameters: (block_parameters)
        . (_) @_start (_) @_end .)
      )
  ]
   (#make-range! "block.inner" @_start @_end))

[
  (call
    block: (_
      !parameters
      . (_) @block.inner .))

  (call
    block: (_
      . parameters: (block_parameters)
      . (_) @block.inner .))
]

[
  (do_block)
  (block)
] @block.outer

((lambda
  body: (_
    . (_) @_start (_) @_end .)
  ) @block.outer
 (#make-range! "block.inner" @_start @_end))

(lambda
  body: (_
    . (_) @block.inner .) @block.outer)

;; calls
(call
  method: (_) @call.inner ) @call.outer

;; classes
(
  [
    (class
      . name: (_)
      . superclass: (_)
      . (_) @_start (_) @_end .)

    (class
      . name: (_)
      !superclass
      . (_) @_start (_) @_end .)

    (module
      . name: (_)
      . (_) @_start (_) @_end .)

    (singleton_class
      . value: (_)
      . (_) @_start (_) @_end .)
  ] @class.outer
 (#make-range! "class.inner" @_start @_end))

[
  ;; match against classes with and without parrents
  (class
    . name: (_)
    . superclass: (_)
    . (_) @class.inner .)

  (class
    . name: (_)
    !superclass
    . (_) @class.inner .)

  (module
    . name: (_)
    . (_) @class.inner .)

  (singleton_class
    . value: (_)
    . (_) @class.inner .)
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

 (method_parameters (_) @parameter.inner)

 (lambda_parameters (_) @parameter.inner)
] @parameter.outer
