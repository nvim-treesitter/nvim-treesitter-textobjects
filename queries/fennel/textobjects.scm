; https://fennel-lang.org/reference
(comment
  body: (comment_body) @comment.inner) @comment.outer

(_
  .
  "("
  ")" .) @statement.outer

; functions
; NOTE: Doesn't capture the comments before the first `item` field
([
  (fn_form
    [
      (table_metadata)
      (docstring)
    ]
    .
    item: (_) @_start
    (_)? @_end
    .
    close: _ .)
  (fn_form
    args: (_)
    .
    item: (_) @_start
    (_)? @_end
    .
    close: _ .)
  (lambda_form
    [
      (table_metadata)
      (docstring)
    ]
    .
    item: (_) @_start
    (_)? @_end
    .
    close: _ .)
  (lambda_form
    args: (_)
    .
    item: (_) @_start
    (_)? @_end
    .
    close: _ .)
  (macro_form
    [
      (table_metadata)
      (docstring)
    ]
    .
    item: (_) @_start
    (_)? @_end
    .
    close: _ .)
  (macro_form
    args: (_)
    .
    item: (_) @_start
    (_)? @_end
    .
    close: _ .)
]
  (#make-range! "function.inner" @_start @_end))

[
  (fn_form)
  (lambda_form)
  (macro_form)
] @function.outer

; function arguments
(sequence_arguments
  item: (_) @parameter.inner) @parameter.outer

; call
(list
  call: (symbol) @_fn_name
  item: (_) @_start
  (_) @_end
  .
  close: _
  (#not-any-of? @_fn_name "do" "while" "when")
  (#make-range! "call.inner" @_start @_end)) @call.outer

; assignment
(local_form
  (binding_pair
    lhs: (_) @assignment.lhs
    rhs: (_) @assignment.rhs) @assignment.inner) @assignment.outer

(var_form
  (binding_pair
    lhs: (_) @assignment.lhs
    rhs: (_) @assignment.rhs) @assignment.inner) @assignment.outer

(global_form
  (binding_pair
    lhs: (_) @assignment.lhs
    rhs: (_) @assignment.rhs) @assignment.inner) @assignment.outer

(set_form
  (binding_pair
    lhs: (_) @assignment.lhs
    rhs: (_) @assignment.rhs) @assignment.inner) @assignment.outer

(let_vars
  (binding_pair
    lhs: (_) @assignment.lhs
    rhs: (_) @assignment.rhs) @assignment.inner) @assignment.outer

; conditionals
(if_form
  (if_pair
    expression: (_) @conditional.inner)) @conditional.outer

(if_form
  else: (_) @conditional.inner) @conditional.outer

(list
  call: (symbol) @_cond
  .
  item: (_)
  item: (_)* @conditional.inner
  (#eq? @_cond "when")) @conditional.outer

; loops
(each_form
  iter_body: (_)
  .
  (_) @_start
  (_)? @_end
  .
  close: _
  (#make-range! "loop.inner" @_start @_end))

(each_form) @loop.outer

(collect_form
  iter_body: (_)
  .
  (_) @_start
  (_)? @_end
  .
  close: _
  (#make-range! "loop.inner" @_start @_end))

(collect_form) @loop.outer

(icollect_form
  iter_body: (_)
  .
  (_) @_start
  (_)? @_end
  .
  close: _
  (#make-range! "loop.inner" @_start @_end))

(icollect_form) @loop.outer

(accumulate_form
  iter_body: (_)
  .
  (_) @_start
  (_)? @_end
  .
  close: _
  (#make-range! "loop.inner" @_start @_end))

(accumulate_form) @loop.outer

(for_form
  iter_body: (_)
  .
  (_) @_start
  (_)? @_end
  .
  close: _
  (#make-range! "loop.inner" @_start @_end))

(for_form) @loop.outer

(fcollect_form
  iter_body: (_)
  .
  (_) @_start
  (_)? @_end
  .
  close: _
  (#make-range! "loop.inner" @_start @_end))

(fcollect_form) @loop.outer

(faccumulate_form
  iter_body: (_)
  .
  (_) @_start
  (_)? @_end
  .
  close: _
  (#make-range! "loop.inner" @_start @_end))

(faccumulate_form) @loop.outer

(list
  call: (symbol) @_sym
  .
  item: (_)
  item: (_)* @loop.inner
  (#any-of? @_sym "while"))

(list
  call: (symbol) @_sym
  (#eq? @_sym "while")) @loop.outer
