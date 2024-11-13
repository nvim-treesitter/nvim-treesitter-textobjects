; function
(function
  body: (_) @function.inner) @function.outer

(anonymous_function
  body: (_) @function.inner) @function.outer

; parameter
(function_parameters
  (_) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

(arguments
  (_) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

(data_constructor_arguments
  (_) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))
