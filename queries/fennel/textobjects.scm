
; https://fennel-lang.org/reference

(comment) @comment.outer

(_ . "(" ")" .) @statement.outer

; functions
((fn . name: (_)? . (parameters) . docstring: (_)? . (_) @_start . (_)* . (_)? @_end .)
 (#make-range! "function.inner" @_start @_end)) @function.outer

((lambda . name: (_)? . (parameters) . docstring: (_)? . (_) @_start . (_)* . (_)? @_end .)
 (#make-range! "function.inner" @_start @_end)) @function.outer

(hashfn ["#" "hashfn"] @function.outer.start (_) @function.inner) @function.outer

; parameters
(parameters (_) @parameter.inner)
(parameters (_) @parameter.outer)

; call
((list . [(multi_symbol) (symbol)] @call.inner) @call.outer
 (#not-any-of? @call.inner "if" "do" "while" "for" "let" "when"))


; conditionals
((list . ((symbol) @_if (#any-of? @_if "if" "when")) . (_) .
  (_) @_start .
  (_)* .
  (_)? @_end .)
 (#make-range! "conditional.inner" @_start @_end)) @conditional.outer


; loops
((for . (for_clause) .
  (_) @_start .
  (_)* .
  (_)? @_end .)
 (#make-range! "loop.inner" @_start @_end)) @loop.outer

((each . (each_clause) .
  (_) @_start .
  (_)* .
  (_)? @_end .)
 (#make-range! "loop.inner" @_start @_end)) @loop.outer

((list . ((symbol) @_while (#eq? @_while "while")) . (_) .
  (_) @_start .
  (_)* .
  (_)? @_end .)
 (#make-range! "loop.inner" @_start @_end)) @loop.outer

