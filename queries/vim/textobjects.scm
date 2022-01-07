(comment) @comment.outer

(function_definition (body) @function.inner) @function.outer

(parameters (identifier) @parameter.inner)

((parameters "," @_start . (identifier) @_end)
 (#make-range! "parameter.outer" @_start @_end))

((parameters . (identifier) @_start . "," @_end)
 (#make-range! "parameter.outer" @_start @_end))

(if_statement (body) @conditional.inner) @conditional.outer
(for_loop (body) @loop.inner) @loop.outer
(while_loop (body) @loop.inner) @loop.outer

(call_expression) @call.outer

(_ (body) @block.inner) @block.outer
(body (_) @statement.outer)
