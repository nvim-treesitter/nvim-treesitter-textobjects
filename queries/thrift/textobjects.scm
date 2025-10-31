; Assignments

(namespace_uri
  (uri_def) @assignment.lhs
  "="
  (uri) @assignment.inner @assignment.rhs) @assignment.outer

(const
  (
    "const"
    (_) @assignment.lhs
    "="
    (const_value) @assignment.inner @assignment.rhs
  ) @assignment.outer)

(enum
  (
    (enum_member) @assignment.lhs
    "="
    (number) @assignment.inner @assignment.rhs
  ) @assignment.outer)

(field
  (
    (_) @assignment.lhs
    "="
    (const_value) @assignment.inner @assignment.rhs
  ) @assignment.outer)

(function_parameter
  (fb_annotation)? ; don't catch this under @assignment.lhs
  (
    (_) @assignment.lhs
    "="
    (const_value) @assignment.inner @assignment.rhs
  ) @assignment.outer) 

(exception_parameter
  (
    (_) @assignment.lhs
    "="
    (const_value) @assignment.inner @assignment.rhs
  ) @assignment.outer)

(annotation
  (
    (annotation_definition) @assignment.lhs
    "="
    (annotation_value) @assignment.inner @assignment.rhs
  ) @assignment.outer)

((field_identifier) @assignment.lhs
  "="
  (const_value) @assignment.inner @assignment.rhs) @assignment.outer

; Attributes

(xsd_attrs) @attribute.outer
(xsd_attrs
  "{" (_) @attribute.inner "}")

(annotation) @attribute.outer
(annotation
  "(" (_) @attribute.inner ")")

(fb_annotation) @attribute.outer
(fb_annotation
  (fb_annotation_definition
    "{" (_) @attribute.inner "}"))

; Blocks

("{" (_) @block.inner "}") @block.outer

; Classes

(enum) @class.outer
(enum
    "{" (_) @class.inner "}")

(senum) @class.outer
(senum
    "{" (_) @class.inner "}")

(struct) @class.outer
(struct
    "{" (_) @class.inner "}")

(union) @class.outer
(union
    "{" (_) @class.inner "}")

(exception) @class.outer
(exception
    "{" (_) @class.inner "}")

(service) @class.outer
(service
    "{" (_) @class.inner "}")

(interaction) @class.outer
(interaction
    "{" (_) @class.inner "}")

; Comments

(comment) @comment.outer

; Functions

(function) @function.outer

; Numbers

[
  (number)
  (double)
] @number.inner

; Parameters

(function_parameter
    (param_identifier) @parameter.inner) @parameter.outer

; Statements

[
  (header)
  (typedef)
] @statement.outer
