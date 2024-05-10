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
