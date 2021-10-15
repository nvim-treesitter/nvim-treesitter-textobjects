; Block Objects
([
  (do_block "do" . (_) @_do (_) @_end . "end")
  (do_block "do" . ((_) @_do) @_end . "end")
] (#make-range! "block.inner" @_do @_end)) @block.outer

; Class Objects (Modules, Protocols)
(call
  target: ((identifier) @_identifier (#any-of? @_identifier 
    "defmodule" 
    "defprotocol" 
    "defimpl"
  ))
  (arguments (alias))
  [
    (do_block "do" . (_) @_do (_) @_end . "end")
    (do_block "do" . ((_) @_do) @_end . "end")
  ]
  (#make-range! "class.inner" @_do @_end)
) @class.outer

; Function, Parameter, and Call Objects
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
  [
    (do_block "do" . (_) @_do (_) @_end . "end")
    (do_block "do" . ((_) @_do) @_end . "end")
  ]
  (#make-range! "function.inner" @_do @_end)
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
