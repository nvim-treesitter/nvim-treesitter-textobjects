(generic_environment
  .
  (_)
  .
  _+ @block.inner
  .
  (_) .) @block.outer

((generic_environment
  (begin
    name: (curly_group_text
      (text) @_frame))
  .
  _+ @frame.inner
  .
  (_) .) @frame.outer
  (#eq? @_frame "frame"))

[
  (generic_command)
  (text_mode)
] @call.outer

(text_mode
  (curly_group
    "{"
    _+ @call.inner
    "}"))

(generic_command
  (curly_group
    "{"
    _+ @call.inner
    "}"))

[
  (chapter)
  (part)
  (section)
  (subsection)
  (subsubsection)
  (paragraph)
  (subparagraph)
] @class.outer
