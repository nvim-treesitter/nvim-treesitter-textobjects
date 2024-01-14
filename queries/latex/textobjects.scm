((generic_environment
  . (_)
  . (_) @_start
  (_) @_end . (_) .
) @block.outer
(#make-range! "block.inner" @_start @_end))

((generic_environment
  (begin
   name: (curly_group_text
           (text) @_frame))
  . (_) @_start
  (_) @_end . (_) .) @frame.outer
 (#eq? @_frame "frame")
 (#make-range! "frame.inner" @_start @_end)) 

[
  (generic_command)
  (text_mode)
] @call.outer

(text_mode
  (curly_group
    "{"
    .
    (_) @_start
    (_)? @_end
    .
    "}")
  (#make-range! "call.inner" @_start @_end))

(generic_command
  (curly_group
    "{"
    .
    (_) @_start
    (_)? @_end
    .
    "}")
  (#make-range! "call.inner" @_start @_end))

[
  (chapter)
  (part)
  (section)
  (subsection)
  (subsubsection)
  (paragraph)
  (subparagraph)
] @class.outer
