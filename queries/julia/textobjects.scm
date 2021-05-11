(compound_expression) @block.outer    ; begin blocks
(let_statement)       @block.outer

(struct_definition) @class.outer    ; not classes, but close enough
(call_expression) @call.outer

(comment) @comment.outer

(if_statement) @conditional.outer

(function_definition) @function.outer
(assignment_expression
  (call_expression) (_)) @function.outer    ; math functions
(function_expression)    @function.outer    ; lambdas
(macro_definition)       @function.outer

(for_statement)    @loop.outer
(while_statement)  @loop.outer

(argument_list) @parameter.outer
(parameter_list) @parameter.outer
