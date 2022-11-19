(
 (exp_apply . (exp_name) . (_) @_start . (_)* . (_)? @_end .)
 (#make-range! "call.inner" @_start @_end)
) @call.outer

(function rhs: (_) @function.inner) @function.outer
;; also treat function signature as @function.outer
(signature) @function.outer

(class) @class.outer
(class (class_body (where) _ @class.inner))
(instance (where)? . _ @class.inner) @class.outer

(comment) @comment.outer

(exp_cond) @conditional.outer

(exp_cond
  (_) @conditional.inner
  ) 

;; e.g. forM [1..10] $ \i -> do...
(exp_infix
  (exp_apply
    (exp_name)@_name
    (#any-of? @_name "for" "forM" "forM")
  ) 
  (operator) @_op
  (#eq? @_op "$")
  (exp_lambda
    (_)
    (_) @loop.inner
  )
) @loop.outer
;; e.g. forM [1..10] print
(exp_apply
  (exp_name)@_name
  (#any-of? @_name "for" "forM" "forM")
  (_)
  (_) @loop.inner
) @loop.outer
