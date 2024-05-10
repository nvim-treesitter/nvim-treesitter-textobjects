(dict) @class.outer

(dict_core) @class.inner

(key_value
  value: _? @function.inner
  (_)* @function.inner
  _? @parameter.inner @function.inner) @function.outer

(code
  (_)* @class.inner) @class.outer

(comment)+ @comment.outer

(comment) @comment.inner
