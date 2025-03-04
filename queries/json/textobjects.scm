(pair) @assignment.outer

(pair
  key: (string) @assignment.lhs)

(pair
  value: (_) @assignment.rhs)

(object
  "," @_comma
  .
  (pair) @parameter.inner
  (#make-range! "parameter.outer" @_comma @parameter.inner))

(object
  (pair) @parameter.inner
  .
  ","? @_comma
  (#make-range! "parameter.outer" @parameter.inner @_comma))

(array
  "," @_comma
  .
  [
    (object)
    (array)
    (string)
    (number)
    (true)
    (false)
    (null)
  ] @parameter.inner
  (#make-range! "parameter.outer" @_comma @parameter.inner))

(array
  [
    (object)
    (array)
    (string)
    (number)
    (true)
    (false)
    (null)
  ] @parameter.inner
  .
  ","? @_comma
  (#make-range! "parameter.outer" @parameter.inner @_comma))
