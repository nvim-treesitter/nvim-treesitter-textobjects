; Block Objects
([
  (do_block "do" . (_) @_do (_) @_end . "end")
  (do_block "do" . ((_) @_do) @_end . "end")
] (#make-range! "block.inner" @_do @_end)) @block.outer

; Class Objects (Modules, Protocols)
; multiple children
(call
  target: ((identifier) @_identifier (#any-of? @_identifier 
    "defmodule" 
    "defprotocol" 
    "defimpl"
  ))
  (arguments (alias))
  (do_block "do" . (_) @_do (_) @_end . "end")
  (#make-range! "class.inner" @_do @_end)
) @class.outer

; single child match
(call
  target: ((identifier) @_identifier (#any-of? @_identifier 
    "defmodule" 
    "defprotocol" 
    "defimpl"
  ))
  (arguments (alias))
  (do_block "do" . (_) @class.inner . "end")
) @class.outer

; Parameters
(call 
  target: ((identifier) @_identifier (#any-of? @_identifier 
    "def" 
    "defmacro" 
    "defmacrop" 
    "defn" 
    "defnp" 
    "defp"
  ))
  (arguments (call [
    (arguments (_) @parameter.inner . "," @_delimiter)
    (arguments ((_) @parameter.inner) @_delimiter .) 
  ] (#make-range! "parameter.outer" @parameter.inner @_delimiter)))
) @function.outer

; Function and Call Objects
(anonymous_function
  (stab_clause 
    right: (body) @function.inner)
) @function.outer

; single child
(call 
  target: ((identifier) @_identifier (#any-of? @_identifier 
    "def" 
    "defmacro" 
    "defmacrop" 
    "defn" 
    "defnp" 
    "defp"
  ))
  (arguments (call))
  (do_block "do" . (_) @function.inner . "end")
) @function.outer

; multi child
(call 
  target: ((identifier) @_identifier (#any-of? @_identifier 
    "def" 
    "defmacro" 
    "defmacrop" 
    "defn" 
    "defnp" 
    "defp"
  ))
  (arguments (call))
  (do_block "do" . (_) @_do (_) @_end . "end")
  (#make-range! "function.inner" @_do @_end)
) @function.outer

; def function(), do: ....
(call 
  target: ((identifier) @_identifier (#any-of? @_identifier 
    "def" 
    "defmacro" 
    "defmacrop" 
    "defn" 
    "defnp" 
    "defp"
  ))
  (arguments
    (call)
    (keywords
      (pair
        value: (_) @function.inner))
  )
) @function.outer

; Comment Objects
(comment) @comment.outer

; Documentation Objects
(unary_operator 
  operator: "@"
  operand: (call target: ((identifier) @_identifier (#any-of? @_identifier
    "moduledoc" 
    "typedoc" 
    "shortdoc" 
    "doc"
  )))
) @comment.outer

; Regex Objects
(sigil (quoted_content) @regex.inner) @regex.outer
