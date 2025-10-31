; inherits: ecma

(interface_declaration) @class.outer

(interface_declaration
  body: (interface_body
    .
    "{"
    _+ @class.inner
    "}"))

(type_alias_declaration) @class.outer

(type_alias_declaration
  value: (object_type
    .
    "{"
    _+ @class.inner
    "}"))

(enum_declaration) @class.outer

(enum_declaration
  body: (enum_body
    .
    "{"
    _+ @class.inner
    "}"))

; type, interface items as @parameter
; 1. parameter.inner
(property_signature) @parameter.inner

; 2. parameter.outer: Only one element, no comma
(object_type
  .
  (property_signature) @parameter.outer .)

(interface_body
  .
  (property_signature) @parameter.outer .)

; 3. parameter.outer: Comma/semicolon before or after
[
  (object_type
    [
      ","
      ";"
    ] @parameter.outer
    .
    (property_signature) @parameter.outer)
  (interface_body
    [
      ","
      ";"
    ] @parameter.outer
    .
    (property_signature) @parameter.outer)
]

[
  (object_type
    .
    (property_signature) @parameter.outer
    .
    [
      ","
      ";"
    ] @parameter.outer)
  (interface_body
    .
    (property_signature) @parameter.outer
    .
    [
      ","
      ";"
    ] @parameter.outer)
]

; last element with trailing comma/semicolon
[
  (object_type
    (property_signature) @parameter.outer
    .
    [
      ","
      ";"
    ] @parameter.outer .)
  (interface_body
    (property_signature) @parameter.outer
    .
    [
      ","
      ";"
    ] @parameter.outer .)
]
