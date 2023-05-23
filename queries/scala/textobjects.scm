(class_definition
  body: (template_body)? @class.inner) @class.outer

(object_definition
  body: (template_body)? @class.inner) @class.outer

(function_definition
  body: [(indented_block) (expression) (indented_cases) (block)] @function.inner) @function.outer

(parameter
  name: (identifier) @parameter.inner) @parameter.outer

(class_parameter
  name: (identifier) @parameter.inner) @parameter.outer

(comment) @comment.outer
