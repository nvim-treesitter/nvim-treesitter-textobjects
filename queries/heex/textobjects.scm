(tag) @function.outer

(tag
  (start_tag)
  .
  (_) @function.inner
  .
  (end_tag))

(attribute_value) @attribute.inner

(attribute) @attribute.outer

((tag
  (start_tag)
  .
  (_) @_start
  (_) @_end
  .
  (end_tag))
  (#make-range! "function.inner" @_start @_end))
