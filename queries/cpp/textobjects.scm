; inherits: c
(class_specifier
  body: (_) @class.inner) @class.outer

(field_declaration
  type: (enum_specifier)
  default_value: (initializer_list) @class.inner) @class.outer

(for_range_loop 
  (_)? @loop.inner) @loop.outer

(template_declaration
  (function_definition) @function.outer) @function.outer.start

(template_declaration
  (struct_specifier) @class.outer) @class.outer.start

(template_declaration
  (class_specifier) @class.outer) @class.outer.start

((parameter_list
  (optional_parameter_declaration) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

((initializer_list
  (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

(new_expression
  (argument_list) @call.inner) @call.outer
