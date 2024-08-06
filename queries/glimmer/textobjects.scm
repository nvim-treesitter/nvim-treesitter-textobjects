[
  (element_node)
  (block_statement)
] @function.outer

[
  (mustache_statement)
  (block_statement_start)
] @block.outer

(attribute_node) @attribute.outer

(attribute_node
  [
    (concat_statement)
    (mustache_statement)
  ] @attribute.inner)

(element_node
  (element_node_start)
  .
  (_) @function.inner
  .
  (element_node_end))

(block_statement
  (block_statement_start)
  .
  (_) @function.inner
  .
  (block_statement_end))

(element_node
  (element_node_start)
  _+ @function.inner
  (element_node_end))

(block_statement
  (block_statement_start)
  _+ @function.inner
  (block_statement_end))

(mustache_statement
  .
  "{{"
  (_) @block.inner
  .
  "}}")

(block_statement_start
  .
  "{{#"
  (_) @block.inner
  .
  "}}")

(comment_statement) @comment.outer
