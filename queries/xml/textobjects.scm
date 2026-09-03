(element) @function.outer

(element
  (STag)
  .
  (_) @function.inner
  .
  (ETag))

(element
  (STag)
  _+ @function.inner
  (ETag))

(EmptyElemTag) @function.outer

(Attribute) @attribute.outer

(AttValue) @attribute.inner

(Comment) @comment.outer

(Comment) @comment.inner
