(function_declaration
  body: (statement_block)) @function.outer

(generator_function_declaration
  body: (statement_block)) @function.outer

(function_expression
  body: (statement_block)) @function.outer

(function_declaration
  body: (statement_block
    .
    "{"
    _+ @function.inner
    "}"))

(generator_function_declaration
  body: (statement_block
    .
    "{"
    _+ @function.inner
    "}"))

(function_expression
  body: (statement_block
    .
    "{"
    _+ @function.inner
    "}"))

(export_statement
  (function_declaration)) @function.outer

(arrow_function
  body: (_) @function.inner) @function.outer

(arrow_function
  body: (statement_block
    .
    "{"
    _+ @function.inner
    "}"))

(method_definition
  body: (statement_block)) @function.outer

(method_definition
  body: (statement_block
    .
    "{"
    _+ @function.inner
    "}"))

(class_declaration
  body: (class_body)) @class.outer

(class_declaration
  body: (class_body
    .
    "{"
    _+ @class.inner
    "}"))

(export_statement
  (class_declaration)) @class.outer

(for_in_statement
  body: (statement_block
    .
    "{"
    _+ @loop.inner
    "}")) @loop.outer

(for_statement
  body: (statement_block
    .
    "{"
    _+ @loop.inner
    "}")) @loop.outer

(while_statement
  body: (statement_block
    .
    "{"
    _+ @loop.inner
    "}")) @loop.outer

(do_statement
  body: (statement_block
    .
    "{"
    _+ @loop.inner
    "}")) @loop.outer

(if_statement
  consequence: (statement_block
    .
    "{"
    _+ @conditional.inner
    "}")) @conditional.outer

(if_statement
  alternative: (else_clause
    (statement_block
      .
      "{"
      _+ @conditional.inner
      "}"))) @conditional.outer

(if_statement) @conditional.outer

(switch_statement
  body: (_)? @conditional.inner) @conditional.outer

(call_expression) @call.outer

(call_expression
  arguments: (arguments
    .
    "("
    _+ @call.inner
    ")"))

(new_expression
  constructor: (identifier) @call.outer
  arguments: (arguments
    .
    "("
    _+ @call.inner
    ")") @call.outer)

; blocks
(statement_block
  (_)* @block.inner) @block.outer

; parameters
; function ({ x }) ...
; function ([ x ]) ...
; function (v = default_value)
(formal_parameters
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(formal_parameters
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; last element with trailing comma
(formal_parameters
  (_) @parameter.outer
  .
  "," @parameter.outer .)

; If the array/object pattern is the first parameter, treat its elements as the argument list
(formal_parameters
  .
  (_
    [
      (object_pattern
        "," @parameter.outer
        .
        (_) @parameter.inner @parameter.outer)
      (array_pattern
        "," @parameter.outer
        .
        (_) @parameter.inner @parameter.outer)
    ]))

(formal_parameters
  .
  (_
    [
      (object_pattern
        .
        (_) @parameter.inner @parameter.outer
        .
        ","? @parameter.outer)
      (array_pattern
        .
        (_) @parameter.inner @parameter.outer
        .
        ","? @parameter.outer)
    ]))

; last element with trailing comma
(formal_parameters
  .
  (_
    [
      (object_pattern
        (_) @parameter.outer
        .
        "," @parameter.outer .)
      (array_pattern
        (_) @parameter.outer
        .
        "," @parameter.outer .)
    ]))

; arguments
(arguments
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(arguments
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; last element with trailing comma
(arguments
  (_) @parameter.outer
  .
  "," @parameter.outer .)

; comment
(comment) @comment.outer

; regex
(regex
  (regex_pattern) @regex.inner) @regex.outer

; number
(number) @number.inner

(lexical_declaration
  (variable_declarator
    name: (_) @assignment.lhs
    value: (_) @assignment.inner @assignment.rhs)) @assignment.outer

(variable_declarator
  name: (_) @assignment.inner)

(object
  (pair
    key: (_) @assignment.lhs
    value: (_) @assignment.inner @assignment.rhs) @assignment.outer)

(return_statement
  (_) @return.inner) @return.outer

(return_statement) @statement.outer

[
  (if_statement)
  (expression_statement)
  (for_statement)
  (while_statement)
  (do_statement)
  (for_in_statement)
  (export_statement)
  (lexical_declaration)
] @statement.outer

; 1.  default import
(import_statement
  (import_clause
    (identifier) @parameter.inner @parameter.outer))

; 2.  namespace import  e.g. `* as React`
(import_statement
  (import_clause
    (namespace_import
      (identifier) @parameter.inner) @parameter.outer))

; 3.  named import  e.g. `import { Bar, Baz } from ...`
(import_statement
  (import_clause
    (named_imports
      (import_specifier) @parameter.inner)))

; 3‑A.  named import followed by a comma
(import_statement
  (import_clause
    (named_imports
      (import_specifier) @parameter.outer
      .
      "," @parameter.outer)))

; 3‑B.  comma followed by named import
(import_statement
  (import_clause
    (named_imports
      "," @parameter.outer
      .
      (import_specifier) @parameter.outer)))

; 3-C.  only one named import without a comma
(import_statement
  (import_clause
    (named_imports
      .
      (import_specifier) @parameter.outer .)))

; Treat list or object elements as @parameter
; 1. parameter.inner
(object
  (_) @parameter.inner)

(array
  (_) @parameter.inner)

(object_pattern
  (_) @parameter.inner)

(array_pattern
  (_) @parameter.inner)

; 2. parameter.outer: Only one element, no comma
(object
  .
  (_) @parameter.outer .)

(array
  .
  (_) @parameter.outer .)

(object_pattern
  .
  (_) @parameter.outer .)

(array_pattern
  .
  (_) @parameter.outer .)

; 3. parameter.outer: Comma before or after
[
  (object
    "," @parameter.outer
    .
    (_) @parameter.outer)
  (array
    "," @parameter.outer
    .
    (_) @parameter.outer)
  (object_pattern
    "," @parameter.outer
    .
    (_) @parameter.outer)
  (array_pattern
    "," @parameter.outer
    .
    (_) @parameter.outer)
]

[
  (object
    .
    (_) @parameter.outer
    .
    "," @parameter.outer)
  (array
    .
    (_) @parameter.outer
    .
    "," @parameter.outer)
  (object_pattern
    .
    (_) @parameter.outer
    .
    "," @parameter.outer)
  (array_pattern
    .
    (_) @parameter.outer
    .
    "," @parameter.outer)
]
