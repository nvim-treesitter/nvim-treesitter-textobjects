; inherits: html

; Svelte-specific text objects
; based on grammar defined at
; https://github.com/tree-sitter-grammars/tree-sitter-svelte
; if block
(if_statement) @block.outer @conditional.outer

(if_statement
  (if_start)
  .
  (_) @_start
  (_)? @_end
  .
  (if_end)
  (#make-range! "block.inner" @_start @_end)
  (#make-range! "conditional.inner" @_start @_end))

; each block
(each_statement) @block.outer @loop.outer

(each_statement
  (each_start)
  .
  (_) @_start
  (_)? @_end
  .
  (each_end)
  (#make-range! "block.inner" @_start @_end)
  (#make-range! "loop.inner" @_start @_end))

; key block
(key_statement) @block.outer

(key_statement
  (key_start)
  .
  (_) @_start
  (_)? @_end
  .
  (key_end)
  (#make-range! "block.inner" @_start @_end))

; await block
(await_statement) @block.outer

(await_statement
  (await_start)
  .
  (_) @_start
  (_)? @_end
  .
  (await_end)
  (#make-range! "block.inner" @_start @_end))

; snippet block
(snippet_statement) @block.outer

(snippet_statement
  (snippet_start)
  .
  (_) @_start
  (_)? @_end
  .
  (snippet_end)
  (#make-range! "block.inner" @_start @_end))
