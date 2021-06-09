(method
    name: (_)) @function.outer

(class
    name: (_)*) @class.outer

(module
    name: (_)*) @class.outer

(if) @conditional.outer
(unless) @conditional.outer
(case) @conditional.outer

(while) @loop.outer
(while_modifier) @loop.outer
(until) @loop.outer
(while_modifier) @loop.outer
(for) @loop.outer

(call) @call.outer

(call
    block: (_)) @block.outer
