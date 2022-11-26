; @functions
(method
  body: (body_statement) @function.inner)
(method) @function.outer
(singleton_method
  body: (body_statement) @function.inner)
(singleton_method) @function.outer

; @blocks
(block
  body: (block_body) @block.inner)
(block) @block.outer
(do_block
  body: (body_statement) @block.inner)
(do_block) @block.outer

; @classes
(class
  body: (body_statement) @class.inner)
(class) @class.outer
(module
  body: (body_statement) @class.inner)
(module) @class.outer
(singleton_class
  body: (body_statement) @class.inner)
(singleton_class) @class.outer

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

; @comment
(comment) @comment.outer

; @regex
(regex (string_content) @regex.inner) @regex.outer
