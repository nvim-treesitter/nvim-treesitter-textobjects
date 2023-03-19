; inherits: ecma

;; interface declaration as class textobject
(interface_declaration
  body: (object_type)) @class.outer

(interface_declaration
  body: (object_type . "{" . (_) @_start @_end _? @_end . "}"
 (#make-range! "class.inner" @_start @_end)))

;; type alias declaration as class textobject
(type_alias_declaration
  value: (object_type)) @class.outer

(type_alias_declaration
  value: (object_type . "{" . (_) @_start @_end _? @_end . "}"
 (#make-range! "class.inner" @_start @_end)))

;; enum declaration as class textobject
(enum_declaration
  body: (enum_body)) @class.outer

(enum_declaration
  body: (enum_body . "{" . (_) @_start @_end _? @_end . "}"
 (#make-range! "class.inner" @_start @_end)))
