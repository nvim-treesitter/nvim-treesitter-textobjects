(compound_expression) @block.outer    ;; begin blocks
(let_statement)       @block.outer

(call_expression) @call.outer

(comment) @comment.outer

(if_statement) @conditional.outer

(function_definition) @function.outer
(function_expression) @function.outer    ;; lambdas

(for_statement)    @loop.outer
(while_statement)  @loop.outer

(argument_list) @parameter.outer
