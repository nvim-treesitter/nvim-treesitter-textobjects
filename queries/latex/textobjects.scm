((generic_environment
  begin: (_)
  .
  (_) @_start
  (_)? @_end
  .
  end: (_)) @block.outer
  (#make-range! "block.inner" @_start @_end))

((math_environment
  begin: (_)
  .
  (_) @_start
  (_)? @_end
  .
  end: (_)) @block.outer
  (#make-range! "block.inner" @_start @_end))

(generic_environment
  begin: (begin
    name: (curly_group_text
      text: (text) @frame.inner))) @frame.outer

(math_environment
  begin: (begin
    name: (curly_group_text
      text: (text) @frame.inner))) @frame.outer

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

((part
  text: (_)
  .
  (_) @_start
  (_)? @_end .) @class.outer
  (#make-range! "class.inner" @_start @_end))

((chapter
  text: (_)
  .
  (_) @_start
  (_)? @_end .) @class.outer
  (#make-range! "class.inner" @_start @_end))

((section
  text: (_)
  .
  (_) @_start
  (_)? @_end .) @class.outer
  (#make-range! "class.inner" @_start @_end))

((subsection
  text: (_)
  .
  (_) @_start
  (_)? @_end .) @class.outer
  (#make-range! "class.inner" @_start @_end))

((subsubsection
  text: (_)
  .
  (_) @_start
  (_)? @_end .) @class.outer
  (#make-range! "class.inner" @_start @_end))

((paragraph
  text: (_)
  .
  (_) @_start
  (_)? @_end .) @class.outer
  (#make-range! "class.inner" @_start @_end))

((subparagraph
  text: (_)
  .
  (_) @_start
  (_)? @_end .) @class.outer
  (#make-range! "class.inner" @_start @_end))
