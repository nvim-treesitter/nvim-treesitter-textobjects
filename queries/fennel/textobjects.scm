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
] @function.outer
  (#make-range! "function.inner" @_start @_end))

; function arguments
(sequence_arguments
  .
  item: (_) @parameter.inner @parameter.outer
  (#offset! @parameter.outer 0 0 0 1))

(sequence_arguments
  .
  item: (_)
  item: (_) @parameter.inner @parameter.outer
  (#offset! @parameter.outer 0 0 0 -1))

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

(case_pair
  lhs: (_) @assignment.lhs
  rhs: (_) @assignment.rhs) @assignment.outer

; conditionals
(if_form
  (if_pair
    expression: (_) @conditional.inner)) @conditional.outer

(list
  call: (symbol) @_cond
  .
  item: (_)
  item: (_)* @conditional.inner
  (#eq? @_cond "when")) @conditional.outer

[
  (case_form
    (case_pair
      rhs: (_) @conditional.inner))
  (match_form
    (case_pair
      rhs: (_) @conditional.inner))
  (case_try_form
    (case_pair
      rhs: (_) @conditional.inner))
  (match_try_form
    (case_pair
      rhs: (_) @conditional.inner))
] @conditional.outer

; loops
(each_form
  (iter_body)
  .
  (_) @_start
  (_) @_end
  .
  close: _
  (#make-range! "loop.inner" @_start @_end)) @loop.outer

(collect_form
  (iter_body)
  .
  (_) @_start
  (_) @_end
  .
  close: _
  (#make-range! "loop.inner" @_start @_end)) @loop.outer

(icollect_form
  (iter_body)
  .
  (_) @_start
  (_) @_end
  .
  close: _
  (#make-range! "loop.inner" @_start @_end)) @loop.outer

(accumulate_form
  (iter_body)
  .
  (_) @_start
  (_) @_end
  .
  close: _
  (#make-range! "loop.inner" @_start @_end)) @loop.outer

(for_form
  (for_iter_body)
  .
  (_) @_start
  (_) @_end
  .
  close: _
  (#make-range! "loop.inner" @_start @_end)) @loop.outer

(fcollect_form
  (for_iter_body)
  .
  (_) @_start
  (_) @_end
  .
  close: _
  (#make-range! "loop.inner" @_start @_end)) @loop.outer

(faccumulate_form
  (for_iter_body)
  .
  (_) @_start
  (_) @_end
  .
  close: _
  (#make-range! "loop.inner" @_start @_end)) @loop.outer

(list
  call: (symbol) @_sym
  .
  item: (_)
  item: (_)* @loop.inner
  (#any-of? @_sym "while")) @loop.outer
