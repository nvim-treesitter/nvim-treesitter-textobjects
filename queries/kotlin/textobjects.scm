(class_declaration
  [
    (class_body)
    (enum_class_body)
  ] @class.inner
) @class.outer

[
  (function_declaration (function_body) @function.inner)
  (getter (function_body) @function.inner)
  (setter (function_body) @function.inner)
  (primary_constructor)
] @function.outer

(primary_constructor) @function.inner

[
  (parameter (simple_identifier) @parameter.inner)
  (class_parameter (simple_identifier) @parameter.inner)
] @parameter.outer

[
  (line_comment)
  (multiline_comment)
] @comment.outer

(if_expression (control_structure_body) @conditional.inner) @conditional.outer

(when_expression (when_entry) @conditional.inner) @conditional.outer

[
  (for_statement (control_structure_body) @loop.inner)
  (while_statement (control_structure_body) @loop.inner)
] @loop.outer

[
  (integer_literal)
  (real_literal)
] @number.inner
