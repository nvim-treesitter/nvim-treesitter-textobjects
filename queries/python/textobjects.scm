(decorated_definition
  (function_definition)) @function.outer

(function_definition
  body: (block)? @function.inner) @function.outer

(decorated_definition
  (class_definition)) @class.outer

(class_definition
  body: (block)? @class.inner) @class.outer

(while_statement
  body: (block)? @loop.inner) @loop.outer

(for_statement
  body: (block)? @loop.inner) @loop.outer

(if_statement
  alternative: (_
    (_) @conditional.inner)?) @conditional.outer

(if_statement
  consequence: (block)? @conditional.inner)

(if_statement
  condition: (_) @conditional.inner)

(_
  (block) @block.inner) @block.outer

; leave space after comment marker if there is one
((comment) @comment.inner @comment.outer
  (#offset! @comment.inner 0 2 0 0)
  (#lua-match? @comment.outer "# .*"))

; else remove everything accept comment marker
((comment) @comment.inner @comment.outer
  (#offset! @comment.inner 0 1 0 0))

(block
  (_) @statement.outer)

(module
  (_) @statement.outer)

(call) @call.outer

(call
  arguments: (argument_list
    .
    "("
    _+ @call.inner
    ")"))

(return_statement
  (_)? @return.inner) @return.outer

; Parameters
(parameters
  "," @parameter.outer
  .
  [
    (identifier)
    (tuple)
    (typed_parameter)
    (default_parameter)
    (typed_default_parameter)
    (dictionary_splat_pattern)
    (list_splat_pattern)
  ] @parameter.inner @parameter.outer)

(parameters
  .
  [
    (identifier)
    (tuple)
    (typed_parameter)
    (default_parameter)
    (typed_default_parameter)
    (dictionary_splat_pattern)
    (list_splat_pattern)
  ] @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(lambda_parameters
  "," @parameter.outer
  .
  [
    (identifier)
    (tuple)
    (typed_parameter)
    (default_parameter)
    (typed_default_parameter)
    (dictionary_splat_pattern)
    (list_splat_pattern)
  ] @parameter.inner @parameter.outer)

(lambda_parameters
  .
  [
    (identifier)
    (tuple)
    (typed_parameter)
    (default_parameter)
    (typed_default_parameter)
    (dictionary_splat_pattern)
    (list_splat_pattern)
  ] @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(tuple
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(tuple
  "("
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(list
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(dictionary
  .
  (pair) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(dictionary
  "," @parameter.outer
  .
  (pair) @parameter.inner @parameter.outer)

(argument_list
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(argument_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(subscript
  "["
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(subscript
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(import_statement
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(import_statement
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(import_from_statement
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(import_from_statement
  "import"
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

[
  (integer)
  (float)
] @number.inner

(assignment
  left: (_) @assignment.lhs
  right: (_) @assignment.inner @assignment.rhs) @assignment.outer

(assignment
  left: (_) @assignment.inner)

(augmented_assignment
  left: (_) @assignment.lhs
  right: (_) @assignment.inner @assignment.rhs) @assignment.outer

(augmented_assignment
  left: (_) @assignment.inner)

; TODO: exclude comments using the future negate syntax from tree-sitter
