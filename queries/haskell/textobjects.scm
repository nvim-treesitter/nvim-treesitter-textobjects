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
