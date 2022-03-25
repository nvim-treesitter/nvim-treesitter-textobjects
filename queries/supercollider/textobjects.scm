; conditional
(if
true:(function_block)? @conditional.inner
false:(function_block)? @conditional.inner
) @conditional.outer

(if
(_)? @conditional.inner
) @conditional.outer

; loops
(for
(function_block)? @loop.inner) @loop.outer
(while
(function_block)? @loop.inner) @loop.outer



(code_block
(_) @block.inner
) @block.outer

(class
) @class.outer

(parameter_call_list
(_)? 
) @class.inner

(line_comment) @comment.outer
(block_comment) @comment.outer

(function_block
(_) @function.inner
) @function.outer

;parameters
((parameter_call_list
"," @_start . (_) @parameter.inner)
(#make-range! "parameter.outer" @_start @parameter.inner))
((parameter_call_list
. (_) @parameter.inner . ","? @_end)
(#make-range! "parameter.outer" @parameter.inner @_end))


(((symbol)?(identifier)
"," @_start . ((method_name)(function_call(_))) @parameter.inner)
(#make-range! "parameter.outer" @_start @parameter.inner))
(((symbol)?(identifier)
. ((method_name)(function_call(_)))  @parameter.inner . ","? @_end)
(#make-range! "parameter.outer" @parameter.inner @_end))
