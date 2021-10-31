; @functions
 ((method . name: (identifier) (method_parameters)? . (_) @function.inner (_)? @function.end .)
   (#make-range! "function.inner" @function.inner @function.end)) @function.outer
 ((singleton_method . name: (identifier) (method_parameters)? . (_) @function.inner (_)? @function.end .)
   (#make-range! "function.inner" @function.inner @function.end)) @function.outer

; @blocks
((block (block_parameters)? . (_) @block.inner (_)? @block.inner.end .)
  (#make-range! "block.inner" @block.inner @block.inner.end)) @block.outer
((do_block (block_parameters)? . (_) @block.inner (_)? @block.inner.end .)
  (#make-range! "block.inner" @block.inner @block.inner.end)) @block.outer

; @classes
(
  (class . name: (constant) (superclass) . (_) @class.inner (_)? @class.end .)
  (#make-range! "class.inner" @class.inner @class.end)
 ) @class.outer
(
  (class . name: (constant) !superclass . (_) @class.inner (_)? @class.end .)
  (#make-range! "class.inner" @class.inner @class.end)
 ) @class.outer

((module name: (constant) . (_) @class.inner (_)? @class.inner.end .)
 (#make-range! "class.inner" @class.inner @class.inner.end)) @class.outer

((singleton_class value: (self) . (_) @class.inner (_)? @class.inner.end .)
 (#make-range! "class.inner" @class.inner @class.inner.end)) @class.outer

; @parameters
(block_parameters (_) @parameter.inner)
(method_parameters (_) @parameter.inner)
(lambda_parameters (_) @parameter.inner)
(argument_list (_) @parameter.inner)

[
  (block_parameters)
  (method_parameters)
  (lambda_parameters)
  (argument_list)
] @parameter.outer
