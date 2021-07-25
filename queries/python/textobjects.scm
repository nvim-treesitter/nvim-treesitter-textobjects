(function_definition
  body: (block)? @function.inner) @function.outer

(decorated_definition
  (function_definition) @function.outer) @function.outer.start

(class_definition
  body: (block)? @class.inner) @class.outer

(decorated_definition
  (class_definition) @class.outer) @class.outer.start

(while_statement
  body: (block)? @loop.inner) @loop.outer

(for_statement
  body: (block)? @loop.inner) @loop.outer

(if_statement
  alternative: (_ (_) @conditional.inner)?) @conditional.outer

(if_statement
  consequence: (block)? @conditional.inner)

(if_statement
  condition: (_) @conditional.inner)

(_ (block) @block.inner) @block.outer
(comment) @comment.outer

(block (_) @statement.outer)

(call) @call.outer
(call (_) @call.inner)

;; Parameters

((parameters
    "," @_start .
    [
      (identifier)
      (tuple)
      (typed_parameter)
      (default_parameter)
      (typed_default_parameter)
      (dictionary_splat_pattern)
      (list_splat_pattern)
    ] @parameter.inner
  )
  (#make-range! "parameter.outer" @_start @parameter.inner))

((parameters
    . [
      (identifier)
      (tuple)
      (typed_parameter)
      (default_parameter)
      (typed_default_parameter)
      (dictionary_splat_pattern)
      (list_splat_pattern)
    ] @parameter.inner
    . ","? @_end
  )
  (#make-range! "parameter.outer" @parameter.inner @_end)
)

((lambda_parameters
    "," @_start .
    [
      (identifier)
      (tuple)
      (typed_parameter)
      (default_parameter)
      (typed_default_parameter)
      (dictionary_splat_pattern)
      (list_splat_pattern)
    ] @parameter.inner
  )
  (#make-range! "parameter.outer" @_start @parameter.inner))

((lambda_parameters
    . [
      (identifier)
      (tuple)
      (typed_parameter)
      (default_parameter)
      (typed_default_parameter)
      (dictionary_splat_pattern)
      (list_splat_pattern)
    ] @parameter.inner
    . ","? @_end
  )
  (#make-range! "parameter.outer" @parameter.inner @_end))

((tuple
    "," @_start .
    [
      (identifier)
      (tuple)
      (typed_parameter)
      (default_parameter)
      (typed_default_parameter)
      (dictionary_splat_pattern)
      (list_splat_pattern)
    ] @parameter.inner
  )
  (#make-range! "parameter.outer" @_start @parameter.inner)
)

((tuple
    "(" .
    [
      (identifier)
      (tuple)
      (typed_parameter)
      (default_parameter)
      (typed_default_parameter)
      (dictionary_splat_pattern)
      (list_splat_pattern)
    ] @parameter.inner
    . ","? @_end
  )
  (#make-range! "parameter.outer" @parameter.inner @_end)
)

((list
    "," @_start .
    [
      (identifier)
      (tuple)
      (typed_parameter)
      (default_parameter)
      (typed_default_parameter)
      (dictionary_splat_pattern)
      (list_splat_pattern)
    ] @parameter.inner
  )
  (#make-range! "parameter.outer" @_start @parameter.inner)
)

((list
    . [
      (identifier)
      (tuple)
      (typed_parameter)
      (default_parameter)
      (typed_default_parameter)
      (dictionary_splat_pattern)
      (list_splat_pattern)
    ] @parameter.inner
    . ","? @_end
  )
  (#make-range! "parameter.outer" @parameter.inner @_end))

((dictionary
    . (pair) @parameter.inner
    . ","? @_end
  )
  (#make-range! "parameter.outer" @parameter.inner @_end))

((dictionary
    "," @_start . 
    (pair) @parameter.inner
  )
  (#make-range! "parameter.outer" @_start @parameter.inner))

((argument_list
    . (_) @parameter.inner
    . ","? @_end
  )
  (#make-range! "parameter.outer" @parameter.inner @_end))

((argument_list
    "," @_start .
    (_) @parameter.inner
  )
  (#make-range! "parameter.outer" @_start @parameter.inner))

((subscript
    "[" . (_) @parameter.inner
    . ","? @_end
  )
  (#make-range! "parameter.outer" @parameter.inner @_end))

((subscript
    "," @_start .
    (_) @parameter.inner
  )
  (#make-range! "parameter.outer" @_start @parameter.inner))

; TODO: exclude comments using the future negate syntax from tree-sitter
