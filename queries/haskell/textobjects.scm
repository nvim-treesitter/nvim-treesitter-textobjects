((apply
  .
  (name)
  .
  (_) @_start
  .
  (_)*
  .
  (_)? @_end .)
  (#make-range! "call.inner" @_start @_end)) @call.outer

(infix
  (_)
  (variable)
  (_)) @call.outer

(decl/function) @function.outer

(decl/function
  patterns: (_)
  .
  match: (_) @_start
  match: (_)? @_end
  .
  (#make-range! "function.inner" @_start @_end))

; also treat function signature as @function.outer
(signature) @function.outer

(class) @class.outer

(class
  "where"
  _ @class.inner)

(instance
  "where"?
  .
  _ @class.inner) @class.outer

(comment) @comment.outer

(expression/conditional) @conditional.outer

(expression/conditional
  (_) @conditional.inner)

; e.g. forM [1..10] $ \i -> do...
(infix
  (apply
    (name) @_name
    (#any-of? @_name "for" "for_" "forM" "forM_"))
  (operator) @_op
  (#eq? @_op "$")
  (lambda
    (_)
    (_) @loop.inner)) @loop.outer

; e.g. forM [1..10] print
(apply
  (name) @_name
  (#any-of? @_name "for" "for_" "forM" "forM_")
  (_)
  (_) @loop.inner) @loop.outer

; e.g. func x
(function
  (patterns
    (_) @parameter.outer))

; e.g. func mb@(Just x)
(function
  (patterns
    (parens
      (_) @parameter.inner)))

(function
  (patterns
    (as
      (parens
        (_) @parameter.inner))))

(signature
  (context
    (function
      (type/apply) @parameter.inner)))

(signature
  (context
    (function
      (type/name) @parameter.inner)))

(signature
  (function
    (type/apply) @parameter.inner))

(signature
  (function
    (type/name) @parameter.inner))

(signature
  (type/apply) @parameter.inner)

(signature
  (type/name) @parameter.inner)
