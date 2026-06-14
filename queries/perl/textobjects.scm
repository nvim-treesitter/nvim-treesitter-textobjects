; attribute
(attribute) @attribute.inner @attribute.outer

; assignment
(assignment_expression
  left: (_) @assignment.lhs
  right: (_) @assignment.inner @assignment.rhs) @assignment.outer

; block
(block) @block.outer

; call
(function_call_expression) @call.outer

(method_call_expression) @call.outer

(ambiguous_function_call_expression) @call.outer

(coderef_call_expression) @call.outer

(function_call_expression
  arguments: (list_expression) @call.inner)

(method_call_expression
  arguments: (list_expression) @call.inner)

(ambiguous_function_call_expression
  arguments: (list_expression) @call.inner)

; class
(package_statement
  (block) @class.inner) @class.outer

(class_statement
  (block) @class.inner) @class.outer

(role_statement
  (block) @class.inner) @class.outer

; comment
(comment) @comment.outer

; conditional
(conditional_statement
  block: (block) @conditional.inner) @conditional.outer

(elsif
  block: (block) @conditional.inner) @conditional.outer

(else
  block: (block) @conditional.inner) @conditional.outer

; function
(subroutine_declaration_statement
  body: (block) @function.inner) @function.outer

(method_declaration_statement
  body: (block) @function.inner) @function.outer

(anonymous_subroutine_expression
  body: (block) @function.inner) @function.outer

; loop
(loop_statement
  block: (block) @loop.inner) @loop.outer

(for_statement
  block: (block) @loop.inner) @loop.outer

(cstyle_for_statement
  block: (block) @loop.inner) @loop.outer

; parameter
(signature
  (_) @parameter.inner @parameter.outer)

(function_call_expression
  arguments: (list_expression
    (_) @parameter.inner @parameter.outer))

(method_call_expression
  arguments: (list_expression
    (_) @parameter.inner @parameter.outer))

(ambiguous_function_call_expression
  arguments: (list_expression
    (_) @parameter.inner @parameter.outer))

; regex
(quoted_regexp) @regex.outer

(match_regexp) @regex.outer

; return
(return_expression) @return.outer

(return_expression
  (_) @return.inner)
