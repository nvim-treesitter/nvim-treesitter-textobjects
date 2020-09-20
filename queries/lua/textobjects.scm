(function) @function.outer

(local_function) @function.outer

(for_in_statement) @loop.outer
(for_statement) @loop.outer

(if_statement) @conditional.outer

(function_call
  (arguments) @call.inner)
(function_call) @call.outer

(arguments
 (_) @parameter.inner)
