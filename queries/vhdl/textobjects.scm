;; Comments
; leave space after comment marker if there is one
((comment) @comment.inner @comment.outer
           (#offset! @comment.inner 0 3 0)
           (#lua-match? @comment.outer "-- "))

; else remove everything accept comment marker
((comment) @comment.inner @comment.outer
           (#offset! @comment.inner 0 2 0))


;; Conditional constructs
(if
  (sequence_of_statements) @conditional.inner
  ) @conditional.outer

(elsif
  (sequence_of_statements) @conditional.inner
  ) @conditional.outer

(else
  (sequence_of_statements) @conditional.inner
  ) @conditional.outer

(case_statement
  "is"
  .
  (_) @_start
  (_) @_end
  .
  "end"
  (#make-range! "conditional.inner" @_start @_end)
  ) @conditional.outer

(case_statement_alternative
  (sequence_of_statements) @conditional.inner
  ) @conditional.outer

;; Class
(architecture_body
  "is"
  .
  (_)? @_start
  (_) @_end
  .
  "begin"
  (#make-range! "class.inner" @_start @_end)
  ) @class.outer

(architecture_body
  "begin"
  .
  (_)? @_start
  (_) @_end
  .
  "end"
  (#make-range! "class.inner" @_start @_end)
  ) @class.outer

(entity_declaration
  (entity_header) @class.inner
  ) @class.outer

(component_instantiation_statement
  (component_map_aspect) @class.inner
  ) @class.outer

(configuration_declaration
  (block_configuration) @class.inner
  ) @class.outer

(package_declaration
  (declarative_part) @class.inner
  ) @class.outer

;; Blocks
(block_statement
  (concurrent_statement_part) @block.inner
  ) @block.outer

(if_generate_statement) @block.outer

(if_generate
  (generate_statement_body) @block.inner
  ) @block.outer

(else_generate
  (generate_statement_body) @block.inner
  ) @block.outer

(elsif_generate
  (generate_statement_body) @block.inner
  ) @block.outer

(for_generate_statement
  (generate_statement_body) @block.inner
  ) @block.outer

(case_generate_statement
  "generate"
  .
  (_)? @_start
  (_) @_end
  .
  "end"
  (#make-range! "block.inner" @_start @_end)
  ) @block.outer

(case_generate_alternative
  (generate_statement_body) @block.inner
  ) @block.outer

;; Loops
(loop_statement
  (sequence_of_statements) @loop.inner
  ) @loop.outer

;; Functions and Procedures
(function_body
  (sequence_of_statements) @function.inner
  ) @function.outer

(procedure_body
  (sequence_of_statements) @function.inner
  ) @function.outer

(function_call
  (association_list) @call.inner
  ) @call.outer

(procedure_call_statement
  (association_list) @call.inner
  ) @call.outer

;; Attributes
(signal_declaration
  (subtype_indication) @attribute.inner
  ) @attribute.outer

(constant_declaration
  (default_expression) @attribute.inner
  ) @attribute.outer

(attribute_declaration
  (type_mark) @attribute.inner
  ) @attribute.outer

(attribute_specification
  (entity_specification) @attribute.inner
  ) @attribute.outer

(signal_interface_declaration
  (subtype_indication) @attribute.inner
  ) @attribute.outer

(constant_interface_declaration
  (subtype_indication) @attribute.inner
  ) @attribute.outer

(variable_declaration
  (subtype_indication) @attribute.inner
  ) @attribute.outer

(element_declaration
  (subtype_indication) @attribute.inner
  ) @attribute.outer

;; Assignments
(simple_waveform_assignment
  target: (simple_name) @assignment.lhs
  (waveforms) @assignment.rhs @assignment.inner
  ) @assignment.outer

(named_association_element
  formal_part: (simple_name) @assignment.lhs
  actual_part: (expression) @assignment.rhs @assignment.inner
  ) @assignment.outer

(named_element_association
  (_) @assignment.lhs
  "=>"
  (_) @assignment.rhs @assignment.inner
  ) @assignment.outer

(constant_declaration
  (identifier_list) @assignment.lhs
  (subtype_indication) @assignment.rhs @assignment.inner
  ) @assignment.outer

(attribute_specification
  name: (simple_name) @assignment.lhs
  (expression) @assignment.inner @assignment.rhs
  ) @assignment.outer

(simple_variable_assignment
  target: (simple_name) @assignment.lhs
  (expression) @assignment.rhs @assignment.inner
  ) @assignment.outer

(full_type_declaration
  name: (identifier) @assignment.lhs
  (enumeration_type_definition
    "("
    .
    (_)? @_start
    (_) @_end
    .
    ")"
    (#make-range! "assignment.inner" @_start @_end)
    ) @assignment.rhs
  ) @assignment.outer

(simple_concurrent_signal_assignment
  target: (simple_name) @assignment.lhs
  (waveforms) @assignment.rhs @assignment.inner
  ) @assignment.outer

;; Numbers
[
 (integer_decimal)
 (real_decimal)
 (bit_string_literal) ; maybe
 (character_literal) ; maybe
 (physical_literal)
 ] @number.inner

;; Returns
(return
  (type_mark) @return.inner
  ) @return.outer

(return_statement
  (expression) @return.inner
  ) @return.outer

;; Parameters
[
 (generic_clause)
 (port_clause)
 ] @parameter.outer

(generic_clause
  "("
  .
  (_)? @_start
  (_) @_end
  .
  ")"
  (#make-range! "parameter.inner" @_start @_end)
  ) @parameter.outer

(port_clause
  "("
  .
  (_)? @_start
  (_) @_end
  .
  ")"
  (#make-range! "parameter.inner" @_start @_end)
  ) @parameter.outer

(generic_map_aspect
  (association_list) @parameter.inner
  ) @parameter.outer

(port_map_aspect
  (association_list) @parameter.inner
  ) @parameter.outer

;; Scope names
(library_clause
  (logical_name_list) @scopename.inner
  )

(use_clause
  (selected_name) @scopename.inner
  )

(entity_declaration
  name: (identifier) @scopename.inner
  )

(configuration_declaration
  name: (identifier) @scopename.inner
  )

(package_declaration
  name: (identifier) @scopename.inner
  )

(entity_instantiation
  entity: (selected_name) @scopename.inner
  )

; Use :InspectTree to find the best categorization for these
