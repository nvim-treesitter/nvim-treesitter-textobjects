(function_definition) @function.outer

(function_definition
  body: (compound_statement
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "function.inner" @_start @_end)))

(case_statement) @conditional.outer

(if_statement
  (_) @conditional.inner) @conditional.outer

(for_statement
  (_) @loop.inner) @loop.outer

(while_statement
  (_) @loop.inner) @loop.outer

(comment) @comment.outer

(regex) @regex.inner

((word) @number.inner
  (#lua-match? @number.inner "^[0-9]+$"))

(variable_assignment) @assignment.outer

(variable_assignment
  name: (_) @assignment.inner @assignment.lhs)

(variable_assignment
  value: (_) @assignment.inner @assignment.rhs)

(command
  argument: (word) @parameter.inner)
