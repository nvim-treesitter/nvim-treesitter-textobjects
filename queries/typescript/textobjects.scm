; inherits: ecma

(interface_declaration) @class.outer

(interface_declaration
  body: (interface_body
    .
    "{"
    .
    (_) @_start @_end
    _? @_end
    .
    "}"
    (#make-range! "class.inner" @_start @_end)))

(type_alias_declaration) @class.outer

(type_alias_declaration
  value: (object_type
    .
    "{"
    .
    (_) @_start @_end
    _? @_end
    .
    "}"
    (#make-range! "class.inner" @_start @_end)))

(enum_declaration) @class.outer

(enum_declaration
  body: (enum_body
    .
    "{"
    .
    (_) @_start @_end
    _? @_end
    .
    "}"
    (#make-range! "class.inner" @_start @_end)))

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
([
  (object_type
    "," @_start
    .
    (property_signature) @_end)
  (interface_body
    "," @_start
    .
    (property_signature) @_end)
]
  (#make-range! "parameter.outer" @_start @_end))

([
  (object_type
    (property_signature) @_start
    .
    "," @_end)
  (interface_body
    (property_signature) @_start
    .
    "," @_end)
]
  (#make-range! "parameter.outer" @_start @_end))

([
  (object_type
    ";" @_start
    .
    (property_signature) @_end)
  (interface_body
    ";" @_start
    .
    (property_signature) @_end)
]
  (#make-range! "parameter.outer" @_start @_end))

([
  (object_type
    (property_signature) @_start
    .
    ";" @_end)
  (interface_body
    (property_signature) @_start
    .
    ";" @_end)
]
  (#make-range! "parameter.outer" @_start @_end))
