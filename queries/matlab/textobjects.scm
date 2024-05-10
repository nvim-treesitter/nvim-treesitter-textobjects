(_
  (block) @block.inner) @block.outer

(block
  (_) @statement.outer)

(source_file
  (_) @statement.outer)

(function_call
  (arguments)? @call.inner) @call.outer

(arguments
  ","? @parameter.outer
  .
  (_) @parameter.inner @parameter.outer .)

(arguments
  (_) @parameter.inner @parameter.outer
  .
  "," @parameter.outer)

(command) @call.outer

(command
  (command_argument) @parameter.inner @parameter.outer)

(command
  (command_argument)+ @call.inner)

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

(function_arguments
  ","? @parameter.outer
  .
  (_) @parameter.inner @parameter.outer .)

(function_arguments
  (_) @parameter.inner @parameter.outer
  .
  "," @parameter.outer)

(multioutput_variable
  ","? @parameter.outer
  .
  (_) @parameter.inner @parameter.outer .)

(multioutput_variable
  (_) @parameter.inner @parameter.outer
  .
  "," @parameter.outer)

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

(superclasses
  "&"? @parameter.outer
  .
  (_) @parameter.inner @parameter.outer .)

(superclasses
  (_) @parameter.inner @parameter.outer
  .
  "&" @parameter.outer)

(enum
  (identifier) @parameter.inner @parameter.outer)

(property
  name: (_) @parameter.outer @parameter.inner)

(enum
  ","? @parameter.outer
  .
  (_) @parameter.inner @parameter.outer .)

(enum
  (_) @parameter.inner @parameter.outer
  .
  "," @parameter.outer)

(validation_functions
  ","? @parameter.outer
  .
  (_) @parameter.inner @parameter.outer .)

(validation_functions
  (_) @parameter.inner @parameter.outer
  .
  "," @parameter.outer)

(dimensions
  ","? @parameter.outer
  .
  (_) @parameter.inner @parameter.outer .)

(dimensions
  (_) @parameter.inner @parameter.outer
  .
  "," @parameter.outer)

(attributes
  ","? @parameter.outer
  .
  (_) @parameter.inner @parameter.outer .)

(attributes
  (_) @parameter.inner @parameter.outer
  .
  "," @parameter.outer)
