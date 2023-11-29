; inherits: hlsl

(template_declaration
  (interface_specifier)) @class.outer.start

(template_declaration
  (extension_specifier)) @class.outer.start

(extension_specifier
  body: (_) @class.inner) @class.outer

(interface_specifier
  body: (_) @class.inner) @class.outer
