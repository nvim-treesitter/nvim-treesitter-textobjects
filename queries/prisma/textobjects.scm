[
  (comment)
  (developer_comment)
] @comment.outer

[
  (statement_block)
  (enum_block)
] @block.outer

(enum_declaration) @class.outer

(enum_block) @class.inner

(enumeral) @parameter.inner @parameter.outer

(model_declaration) @class.outer

(model_declaration
  (statement_block) @class.inner)

(column_declaration) @parameter.inner @parameter.outer
