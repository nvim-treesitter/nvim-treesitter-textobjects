(function_def) @function.outer
(function_def
  . (function_command)
  . (_)? @_start
  (_) @_end
  . (endfunction_command) .
  (#make-range! "function.inner" @_start @_end))

(if_condition) @conditional.outer
(if_condition
  . (if_command)
  . (_)? @_start
  (_) @_end
  . (endif_command) .
  (#make-range! "conditional.inner" @_start @_end))

(foreach_loop) @loop.outer
(foreach_loop
  . (foreach_command)
  . (_)? @_start
  (_) @_end
  . (endforeach_command) .
  (#make-range! "loop.inner" @_start @_end))


(normal_command) @call.outer
(normal_command
  "(" . (_) @_start
  (_)? @_end . ")"
  (#make-range! "call.inner" @_start @_end))

(line_comment) @comment.outer
