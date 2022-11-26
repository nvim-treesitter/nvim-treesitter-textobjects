(comments) @comment.outer

(pattern_matcher (regex_pattern) @regex.inner) @regex.outer

((patter_matcher_m
   (start_delimiter) @_start
   (end_delimiter) @_end) @regex.outer
 (#make-range! "regex.inner" @_start @_end))

((regex_pattern_qr
   (start_delimiter) @_start
   (end_delimiter) @_end) @regex.outer
 (#make-range! "regex.inner" @_start @_end))
