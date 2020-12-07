(function_definition 
 body: (compound_statement) @function.inner) @function.outer

(method_declaration
  body: (compound_statement) @function.inner) @function.outer

(class_declaration
  body: (declaration_list) @class.inner) @class.outer

(foreach_statement
  body: (_)? @loop.inner) @loop.outer

(while_statement
  body: (_)? @loop.inner) @loop.outer

(do_statement
  body: (_)? @loop.inner) @loop.outer

(switch_statement
  body: (_)? @conditional.inner) @conditional.outer

;;blocks
(_ (switch_block) @block.inner) @block.outer

;; parameters
(formal_parameters
  (simple_parameter) @parameter.inner)
