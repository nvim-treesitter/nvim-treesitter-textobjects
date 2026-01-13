; inherits: html

; Svelte-specific text objects
; based on grammar defined at
; https://github.com/tree-sitter-grammars/tree-sitter-svelte
; if block
(if_statement) @block.outer @conditional.outer

(if_statement
  (if_start)
  .
  _+ @block.inner @conditional.inner
  .
  (if_end))

; each block
(each_statement) @block.outer @loop.outer

(each_statement
  (each_start)
  .
  _+ @block.inner @loop.inner
  .
  (each_end))

; key block
(key_statement) @block.outer

(key_statement
  (key_start)
  .
  _+ @block.inner
  .
  (key_end))

; await block
(await_statement) @block.outer

(await_statement
  (await_start)
  .
  _+ @block.inner
  .
  (await_end))

; snippet block
(snippet_statement) @block.outer

(snippet_statement
  (snippet_start)
  .
  _+ @block.inner
  .
  (snippet_end))
