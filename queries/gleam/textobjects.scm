; assignments
(let
  pattern: (_) @assignment.lhs @assignment.inner
  value: (_) @assignment.rhs) @assignment.outer

(let
  value: (_) @assignment.inner)

(let_assert
  pattern: (_) @assignment.lhs @assignment.inner
  value: (_) @assignment.rhs) @assignment.outer

(let_assert
  value: (_) @assignment.inner)

(use
  assignments: (use_assignments) @assignment.lhs @assignment.inner
  value: (_) @assignment.rhs) @assignment.outer

(use
  value: (_) @assignment.inner)

; block
(block
  "{"
  .
  _+ @block.inner
  .
  "}") @block.outer

; calls
(function_call
  arguments: (arguments
    .
    "("
    _+ @call.inner
    ")")) @call.outer

(record
  arguments: (arguments
    .
    "("
    _+ @call.inner
    ")")) @call.outer

(record_update
  ".." @call.inner
  .
  spread: (_) @call.inner
  .
  "," @call.inner
  arguments: (record_update_arguments) @call.inner) @call.outer

; class
(type_definition
  (data_constructors) @class.inner) @class.outer

; comment
(comment) @comment.outer

; conditionals
(case
  clauses: (case_clauses
    (case_clause) @conditional.inner)) @conditional.outer

; numbers
[
  (integer)
  (float)
] @number.inner

; parameters in functions declarations
(function_parameters
  "," @parameter.outer
  .
  (function_parameter) @parameter.inner @parameter.outer)

(function_parameters
  .
  ; first parameter
  (function_parameter) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(function_parameters
  (function_parameter) @parameter.inner @parameter.outer
  .
  ; trailing comma
  "," @parameter.outer .)

; parameters in calls
(arguments
  "," @parameter.outer
  .
  (argument) @parameter.inner @parameter.outer)

(arguments
  .
  ; first parameter
  (argument) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(arguments
  (argument) @parameter.inner @parameter.outer
  .
  ; trailing comma
  "," @parameter.outer .)

; parameters for types and records
(data_constructor_arguments
  "," @parameter.outer
  .
  (data_constructor_argument) @parameter.inner @parameter.outer)

(data_constructor_arguments
  .
  ; first parameter
  (data_constructor_argument) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(data_constructor_arguments
  (data_constructor_argument) @parameter.inner @parameter.outer
  .
  ; trailing comma
  "," @parameter.outer .)

(type_parameters
  "," @parameter.outer
  .
  (type_parameter) @parameter.inner @parameter.outer)

(type_parameters
  .
  ; first parameter
  (type_parameter) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(type_parameters
  (type_parameter) @parameter.inner @parameter.outer
  .
  ; trailing comma
  "," @parameter.outer .)

(type_arguments
  "," @parameter.outer
  .
  (type_argument) @parameter.inner @parameter.outer)

(type_arguments
  .
  ; first parameter
  (type_argument) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(type_arguments
  (type_argument) @parameter.inner @parameter.outer
  .
  ; trailing comma
  "," @parameter.outer .)

(record_pattern_arguments
  "," @parameter.outer
  .
  (record_pattern_argument) @parameter.inner @parameter.outer)

(record_pattern_arguments
  .
  ; first parameter
  (record_pattern_argument) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(record_pattern_arguments
  (record_pattern_argument) @parameter.inner @parameter.outer
  .
  ; trailing comma
  "," @parameter.outer .)

(record_update
  ".." @parameter.inner @parameter.outer
  .
  spread: (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(record_update
  "," @parameter.outer
  arguments: (record_update_arguments
    .
    ; first parameter after spread
    (record_update_argument) @parameter.inner @parameter.outer))

(record_update
  arguments: (record_update_arguments
    "," @parameter.outer
    .
    (record_update_argument) @parameter.inner @parameter.outer))

(record_update
  arguments: (record_update_arguments
    (record_update_argument) @parameter.inner @parameter.outer
    . ; trailing comma
    "," @parameter.outer .))

; parameters in lists
(list
  "," @parameter.outer
  (_) @parameter.inner @parameter.outer)

(list
  .
  ; first parameter
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(list
  (_) @parameter.inner @parameter.outer
  .
  ;trailing comma
  "," @parameter.outer .)

(list_pattern
  "," @parameter.outer
  (_) @parameter.inner @parameter.outer)

(list_pattern
  .
  ; first parameter
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(list_pattern
  (_) @parameter.inner @parameter.outer
  .
  ;trailing comma
  "," @parameter.outer .)

; parameters in tuples
(tuple
  "," @parameter.outer
  (_) @parameter.inner @parameter.outer)

(tuple
  .
  ; first parameter
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(tuple
  (_) @parameter.inner @parameter.outer
  .
  ;trailing comma
  "," @parameter.outer .)

; parameters in bit arrays
(bit_array
  "," @parameter.outer
  (_) @parameter.inner @parameter.outer)

(bit_array
  .
  ; first parameter
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(bit_array
  (_) @parameter.inner @parameter.outer
  .
  ;trailing comma
  "," @parameter.outer .)

; functions
(function
  body: (block
    "{"
    .
    _+ @function.inner
    .
    "}")) @function.outer

(anonymous_function
  body: (block
    "{"
    .
    _+ @function.inner
    .
    "}")) @function.outer

; returns
(function
  body: (block
    (_) @return.inner @return.outer .))

(anonymous_function
  body: (block
    (_) @return.inner @return.outer .))

; statements
(block
  (_) @statement.outer)
