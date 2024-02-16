(_
  (block) @block.inner) @block.outer

(block
  (_) @statement.outer)

(source_file
  (_) @statement.outer)

(function_call
  (arguments)? @call.inner) @call.outer

((arguments
  ","? @_start
  .
  (_) @parameter.inner .)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((arguments
  (_) @parameter.inner
  .
  "," @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

(command) @call.outer

(command
  (command_argument) @parameter.inner @parameter.outer)

(command
  (command_argument) @_start
  (command_argument)* @_end
  .
  (#make-range! "call.inner" @_start @_end))

(if_statement
  (block) @conditional.inner) @conditional.outer

(if_statement
  (elseif_clause
    (block) @conditional.inner))

(if_statement
  (else_clause
    (block) @conditional.inner))

(switch_statement
  (case_clause
    (block) @conditional.inner)) @conditional.outer

(switch_statement
  (otherwise_clause
    (block) @conditional.inner))

(for_statement
  (block) @loop.inner) @loop.outer

(while_statement
  (block) @loop.inner) @loop.outer

(lambda
  expression: (_) @function.inner) @function.outer

(global_operator
  (identifier) @parameter.inner)

(persistent_operator
  (identifier) @parameter.inner)

(function_definition
  (block) @function.inner) @function.outer

(function_output
  (identifier) @parameter.inner @parameter.outer)

((function_arguments
  ","? @_start
  .
  (_) @parameter.inner .)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((function_arguments
  (_) @parameter.inner
  .
  "," @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

((multioutput_variable
  ","? @_start
  .
  (_) @parameter.inner .)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((multioutput_variable
  (_) @parameter.inner
  .
  "," @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

(try_statement
  (block) @conditional.inner) @conditional.outer

(catch_clause
  (identifier) @parameter.inner @parameter.outer)

(catch_clause
  (block) @conditional.inner)

(class_definition) @class.outer

(number) @number.inner

(_
  (return_statement) @return.inner @return.outer)

(comment) @comment.outer

(matrix
  (row) @parameter.outer)

(cell
  (row) @parameter.outer)

(row
  (_) @parameter.inner)

(assignment
  left: (_) @assignment.lhs
  (_) @assignment.rhs) @assignment.outer

((superclasses
  "&"? @_start
  .
  (_) @parameter.inner .)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((superclasses
  (_) @parameter.inner
  .
  "&" @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

(enum
  (identifier) @parameter.inner @parameter.outer)

(property
  name: (_) @parameter.outer @parameter.inner)

((enum
  ","? @_start
  .
  (_) @parameter.inner .)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((enum
  (_) @parameter.inner
  .
  "," @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

((validation_functions
  ","? @_start
  .
  (_) @parameter.inner .)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((validation_functions
  (_) @parameter.inner
  .
  "," @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

((dimensions
  ","? @_start
  .
  (_) @parameter.inner .)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((dimensions
  (_) @parameter.inner
  .
  "," @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

((attributes
  ","? @_start
  .
  (_) @parameter.inner .)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((attributes
  (_) @parameter.inner
  .
  "," @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))
