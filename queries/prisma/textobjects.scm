[
  (comment)
  (developer_comment)
] @comment.outer

[
  (statement_block)
  (enum_block)
] @block.outer

[
  (enum_declaration)
  (model_declaration)
  (type_declaration)
] @class.outer

(enum_block) @class.inner

(model_declaration
  (statement_block) @class.inner)

(type_declaration
  (statement_block) @class.inner)

(enumeral) @parameter.inner @parameter.outer

(column_declaration) @parameter.inner @parameter.outer

(block_attribute_declaration) @parameter.outer
