;-------------------------------------------------------------------------------
;
; Maintainer: superzanti
; Feature Reference: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
;-------------------------------------------------------------------------------
;
; Comments
(line_comment
  (comment_content) @comment.inner) @comment.outer

(block_comment
  (comment_content) @comment.inner) @comment.outer

; Conditional constructs
(if_statement_block
  (if_statement
    (if_statement_body) @_start @_end
    (_)? @_end .)
  (_)? @_end
  .
  (end_if)
  (#make-range! "conditional.inner" @_start @_end)) @conditional.outer

(if_statement
  (simple_expression) @_start
  (if_statement_body) @_end @conditional.inner
  (#make-range! "conditional.outer" @_start @_end)) @conditional.outer

(elsif_statement
  (if_statement_body) @conditional.inner) @conditional.outer

(else_statement
  (if_statement_body) @conditional.inner) @conditional.outer

(case_statement
  (case_body) @conditional.inner) @conditional.outer

(case_statement_alternative
  (when_element)
  .
  (_) @_start @_end
  (_)? @_end
  .
  (#make-range! "conditional.inner" @_start @_end)) @conditional.outer

; Class
(architecture_definition
  (architecture_head
    "is"
    .
    (_) @_start)
  (_) @_end
  .
  (end_architecture)
  (#make-range! "class.inner" @_start @_end)) @class.outer

(architecture_definition
  (architecture_head)
  .
  (_) @_start @_end
  (_)? @_end
  .
  (end_architecture)
  (#make-range! "class.inner" @_start @_end)) @class.outer

(concurrent_block
  "begin"
  .
  (_) @_start @_end
  (_)? @_end
  .
  (#make-range! "class.inner" @_start @_end)) @class.outer

(entity_declaration
  (entity_head
    "is"
    .
    (_) @_start @_end
    (_)? @_end .)
  (_)? @_end
  .
  (end_entity)
  (#make-range! "class.inner" @_start @_end)) @class.outer

(entity_declaration
  (entity_head)
  .
  (_) @_start @_end
  (_)? @_end
  .
  (end_entity)
  (#make-range! "class.inner" @_start @_end)) @class.outer

(entity_body
  "begin"
  .
  (_) @_start @_end
  (_)? @_end
  .
  (#make-range! "class.inner" @_start @_end)) @class.outer

(process_statement
  (process_head
    "is"
    .
    (_) @_start @_end
    (_)? @_end
    .
    (#make-range! "class.inner" @_start @_end))) @class.outer

(process_statement
  (sequential_block
    "begin"
    .
    (_) @_start @_end
    (_)? @_end
    .
    (#make-range! "class.inner" @_start @_end))) @class.outer

(configuration_declaration
  (configuration_head)
  .
  (_) @_start @_end
  (_)? @_end
  .
  (end_configuration)
  (#make-range! "class.inner" @_start @_end)) @class.outer

(package_declaration
  (package_declaration_body
    "is"
    .
    (_) @_start @_end
    (_)? @_end
    .
    (#make-range! "class.inner" @_start @_end))) @class.outer

(package_definition
  (package_definition_body
    "is"
    .
    (_) @_start @_end
    (_)? @_end
    .
    (#make-range! "class.inner" @_start @_end))) @class.outer

; Blocks
(component_instantiation_statement
  (instantiated_unit)
  .
  (_) @_start @_end
  (_)? @_end
  .
  ";"? @_end
  .
  (#make-range! "block.inner" @_start @_end)) @block.outer

(block_statement
  (block_head) @block.inner) @block.outer

(block_statement
  (concurrent_block
    "begin"
    .
    (_) @_start @_end
    (_)? @_end
    .
    (#make-range! "block.inner" @_start @_end))) @block.outer

(component_declaration
  (component_body
    "is"
    .
    (_) @_start @_end
    (_)? @_end
    .
    (#make-range! "block.inner" @_start @_end))) @block.outer

(if_generate_statement
  (if_generate
    (generate_body
      "generate"
      (generate_block
        .
        (_) @_start @_end
        (_)? @_end .)))
  (_)? @_end
  .
  (end_generate)
  (#make-range! "block.inner" @_start @_end)) @block.outer

(if_generate
  (generate_body
    "generate"
    (generate_block
      .
      (_) @_start @_end
      (_)? @_end
      .
      (#make-range! "block.inner" @_start @_end)))) @block.outer

(elsif_generate
  (generate_body
    "generate"
    (generate_block
      .
      (_) @_start @_end
      (_)? @_end
      .
      (#make-range! "block.inner" @_start @_end)))) @block.outer

(else_generate
  (generate_body
    "generate"
    (generate_block
      .
      (_) @_start @_end
      (_)? @_end
      .
      (#make-range! "block.inner" @_start @_end)))) @block.outer

(for_generate_statement
  (generate_body
    "generate"
    (generate_block
      .
      (_) @_start @_end
      (_)? @_end
      .
      (#make-range! "block.inner" @_start @_end)))) @block.outer

(case_generate_statement
  "generate"
  (case_generate_block
    .
    (_) @_start @_end
    (_)? @_end
    .
    (#make-range! "block.inner" @_start @_end))) @block.outer

(case_generate_alternative
  (case_generate_body
    "=>"
    (generate_block
      .
      (_) @_start @_end
      (_)? @_end
      .
      ";"? @_end
      .
      (#make-range! "block.inner" @_start @_end)))) @block.outer

; Loops
(loop_statement
  (loop_body
    "loop"
    .
    (_) @_start @_end
    (_)? @_end
    .
    (#make-range! "loop.inner" @_start @_end))) @loop.outer

; Functions and Procedures
(subprogram_definition
  (sequential_block
    "begin"
    .
    (_) @_start @_end
    (_)? @_end
    .
    (#make-range! "function.inner" @_start @_end))) @function.outer

(subprogram_declaration
  (function_specification
    (parameter_list_specification) @_start) @_end
  (#make-range! "call.inner" @_start @_end)) @call.outer

(procedure_call_statement
  (name
    (parenthesis_group
      (association_or_range_list) @call.inner))) @call.outer

; Parameters
(generic_clause
  (interface_list) @parameter.inner) @parameter.outer

(port_clause
  (interface_list) @parameter.inner) @parameter.outer

(generic_map_aspect
  (association_list
    "("
    .
    (_) @_start @_end
    (_)? @_end
    .
    ")"
    (#make-range! "parameter.inner" @_start @_end))) @parameter.outer

(port_map_aspect
  (association_list
    "("
    .
    (_) @_start @_end
    (_)? @_end
    .
    ")"
    (#make-range! "parameter.inner" @_start @_end))) @parameter.outer

; Returns
(_
  "return" @_start1
  .
  (_) @_start2 @_end2 @_end1
  (_)? @_end2 @_end1
  .
  ";"? @_end1
  (#make-range! "return.inner" @_start2 @_end2)
  (#make-range! "return.outer" @_start1 @_end1))

; Numbers
[
  (bit_string_value)
  (string_literal_std_logic)
  (library_constant_std_logic)
  (decimal_float)
  (decimal_integer)
] @number.inner

; Attributes
(signal_declaration
  (subtype_indication) @attribute.inner) @attribute.outer

(constant_declaration
  (subtype_indication) @attribute.inner) @attribute.outer

(variable_declaration
  (subtype_indication) @attribute.inner) @attribute.outer

(attribute_declaration
  (name) @attribute.inner) @attribute.outer

(attribute_specification
  (entity_specification) @attribute.inner) @attribute.outer

(interface_declaration
  (simple_mode_indication) @attribute.inner) @attribute.outer

(interface_signal_declaration
  (simple_mode_indication) @attribute.inner) @attribute.outer

(interface_constant_declaration
  (simple_mode_indication) @attribute.inner) @attribute.outer

(interface_variable_declaration
  (simple_mode_indication) @attribute.inner) @attribute.outer

(element_declaration
  (subtype_indication) @attribute.inner) @attribute.outer

; Assignments
(simple_variable_assignment
  (name) @assignment.lhs
  (conditional_or_unaffected_expression) @assignment.rhs @assignment.inner) @assignment.outer

(simple_waveform_assignment
  (name) @assignment.lhs
  (waveform) @assignment.rhs @assignment.inner) @assignment.outer

; constant declaration, interface signal declaration, interface declaration
(_
  (identifier_list) @assignment.lhs
  (_
    (subtype_indication) @assignment.rhs @assignment.inner
    (initialiser
      (conditional_expression) @assignment.rhs)?)) @assignment.outer

(concurrent_simple_signal_assignment
  (name) @assignment.lhs
  (waveform) @assignment.rhs @assignment.inner) @assignment.outer

(association_element
  (name) @assignment.lhs
  (conditional_expression) @assignment.rhs @assignment.inner) @assignment.outer

(element_association
  (_) @assignment.lhs
  (conditional_expression) @assignment.rhs @assignment.inner) @assignment.outer

(type_declaration
  (identifier) @assignment.lhs
  (enumeration_type_definition) @assignment.rhs @assignment.inner) @assignment.outer

(type_declaration
  (identifier) @assignment.lhs
  (record_type_definition
    .
    (_) @_start
    (_) @_end
    .
    (end_record)
    (#make-range! "assignment.inner" @_start @_end)) @assignment.rhs) @assignment.outer

; Attributes
(attribute_declaration
  (identifier)
  (name) @attribute.inner) @attribute.outer

(attribute_specification
  (attribute_identifier)
  (entity_specification) @attribute.inner
  (conditional_expression)) @attribute.outer

; Scope names
(package_declaration
  (identifier) @scopename.inner)

(package_definition
  (identifier) @scopename.inner)

(entity_declaration
  (identifier) @scopename.inner)

(architecture_definition
  (identifier) @scopename.inner)

(configuration_declaration
  (identifier) @scopename.inner)

(library_clause
  (logical_name_list) @scopename.inner)

(use_clause
  (selected_name_list) @scopename.inner)

(component_instantiation_statement
  (instantiated_unit) @scopename.inner)
