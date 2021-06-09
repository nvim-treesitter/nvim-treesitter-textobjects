[
  (method)
  (singleton_method)
] @function.outer

[
  (class)
  (module)
] @class.outer

[
  (if)
  (unless)
  (case)
] @conditional.outer

[
  (while)
  (while_modifier)
  (until)
  (until_modifier)
  (for)
] @loop.outer

(call) @call.outer

(call
  block: (_)) @block.outer
