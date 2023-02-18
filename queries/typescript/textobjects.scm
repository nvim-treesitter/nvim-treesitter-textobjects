; inherits: ecma


;; interface declaration as class textobject
(interface_declaration) @class.outer

(interface_declaration
  body: _ @class.inner) @class.outer

(interface_declaration
  body: (object_type . "{" . _ @_start @_end _? @_end . "}"
 (#make-range! "class.inner" @_start @_end)))

;; type alias declaration as class textobject
(type_alias_declaration) @class.outer

(type_alias_declaration
  value: _ @class.inner) @class.outer

(type_alias_declaration
  value: (object_type . "{" . _ @_start @_end _? @_end . "}"
 (#make-range! "class.inner" @_start @_end)))

;; enum declaration as class text object
(enum_declaration) @class.outer

(enum_declaration
  body: (enum_body (_) @class.inner)) @class.outer

(enum_declaration
  body: (enum_body . "{" . _ @_start @_end _? @_end . "}"
 (#make-range! "class.inner" @_start @_end)))
