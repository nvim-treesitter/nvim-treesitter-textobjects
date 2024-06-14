[
  (if_statement)
  (elsif)
  (case_statement)
] @conditional.outer

(comment) @comment.outer

[
  (function_body)
  (procedure_body)
] @function.outer

[
  (process_statement)
  (generic_clause)
  (port_clause)
  (architecture_body)
  (generic_map_aspect)
  (port_map_aspect)
] @block.outer

[
  (entity_declaration)
  (entity_instantiation)
  (component_declaration)
  (component_instantiation)
] @class.outer

(signal_declaration) @parameter.outer

;  TODO: Use :InspectTree to find the best categorization for these
;  @assignment.inner
;  @assignment.lhs
;  @assignment.outer
;  @assignment.rhs
;  @attribute.inner
;  @attribute.outer
;  @block.inner
;  @call.inner
;  @call.outer
;  @class.inner
;  @comment.inner
;  @conditional.inner
;  @frame.inner
;  @frame.outer
;  @function.inner
;  @loop.inner
;  @loop.outer
;  @number.inner
;  @parameter.inner
;  @regex.inner
;  @regex.outer
;  @return.inner
;  @return.outer
;  @scopename.inner
;  @statement.outer
