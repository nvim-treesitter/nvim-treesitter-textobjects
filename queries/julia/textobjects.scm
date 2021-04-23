(compound_expression) @block.outer    ; begin blocks
(let_statement)       @block.outer

(call_expression
  (identifier)
  (argument_list) @parameter.outer) @call.outer

(struct_definition) @class.outer    ; not classes, but close enough

(comment) @comment.outer

(if_statement) @conditional.outer

(function_definition
  name: (identifier)
  parametere: (parameter_list) @parameter.outer) @function.outer

(assignment_expression
  (call_expression) (_)) @function.outer    ; math functions
(function_expression)    @function.outer    ; lambdas
(macro_definition)       @function.outer

(for_statement)    @loop.outer
(while_statement)  @loop.outer
