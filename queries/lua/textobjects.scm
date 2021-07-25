(function) @function.outer
(local_function) @function.outer
(function_definition) @function.outer

(for_in_statement) @loop.outer
(for_statement) @loop.outer
(while_statement) @loop.outer
(repeat_statement) @loop.outer

(if_statement) @conditional.outer

(function_call
  (arguments) @call.inner)
(function_call) @call.outer

(arguments
  "," @_start .
  (_) @parameter.inner
 (#make-range! "parameter.outer" @_start @parameter.inner))
(arguments
  . (_) @parameter.inner
  . ","? @_end
 (#make-range! "parameter.outer" @parameter.inner @_end))

(parameters
  "," @_start .
  (_) @parameter.inner
 (#make-range! "parameter.outer" @_start @parameter.inner))
(parameters
  . (_) @parameter.inner
  . ","? @_end
 (#make-range! "parameter.outer" @parameter.inner @_end))

(arguments 
  . (table
    "," @_start .
    (_) @parameter.inner
   (#make-range! "parameter.outer" @_start @parameter.inner))
  . ) 
(arguments 
  . (table
    . (_) @parameter.inner
    . ","? @_end
   (#make-range! "parameter.outer" @parameter.inner @_end))
  . ) 

(comment) @comment.outer

((function
  . (function_name) . (parameters) . (_) @_start
  (_) @_end .)
 (#make-range! "function.inner" @_start @_end))
((local_function
  . (identifier) . (parameters) . (_) @_start
  (_) @_end .)
 (#make-range! "function.inner" @_start @_end))
((function_definition
  . (parameters) . (_) @_start
  (_) @_end .)
 (#make-range! "function.inner" @_start @_end))

((function
  . (function_name) . (parameters) . (_) @function.inner .))
((local_function
  . (identifier) . (parameters) . (_) @function.inner .))
((function_definition
  . (parameters) . (_) @function.inner .))
