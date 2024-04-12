; inherits: hlsl

(template_declaration
  (interface_specifier)) @class.outer

(template_declaration
  (extension_specifier)) @class.outer

(extension_specifier
  body: (_) @class.inner) @class.outer

(interface_specifier
  body: (_) @class.inner) @class.outer
