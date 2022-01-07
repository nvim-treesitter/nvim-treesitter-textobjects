(atx_heading (heading_content) @class.inner) @class.outer
(setext_heading (heading_content) @class.inner) @class.outer
(thematic_break) @class.outer

(fenced_code_block (code_fence_content) @block.inner) @block.outer

[
  (paragraph)
  (list)
] @block.outer
