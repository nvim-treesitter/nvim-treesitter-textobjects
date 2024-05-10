(generic_environment
  .
  (_)
  _+ @block.inner
  (_) .) @block.outer

((generic_environment
  (begin
    name: (curly_group_text
      (text) @_frame))
  _+ @frame.inner
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

(part
  text: (_)
  _+ @class.inner)

(part
  text: (_)) @class.outer

(chapter
  text: (_)
  _+ @class.inner)

(chapter
  text: (_)) @class.outer

(section
  text: (_)
  _+ @class.inner)

(section
  text: (_)) @class.outer

(subsection
  text: (_)
  _+ @class.inner)

(subsection
  text: (_)) @class.outer

(subsubsection
  text: (_)
  _+ @class.inner)

(subsubsection
  text: (_)) @class.outer

(paragraph
  text: (_)
  _+ @class.inner)

(paragraph
  text: (_)) @class.outer

(subparagraph
  text: (_)
  _+ @class.inner)

(subparagraph
  text: (_)) @class.outer
