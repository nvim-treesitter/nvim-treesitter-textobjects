;; "Classes"
(VarDecl 
  (_ (_ (ContainerDecl) @class.inner))) @class.outer

;; functions
(_ 
  (FnProto)
  (Block) @function.inner) @function.outer

;; loops
(_
  (ForPrefix)
  (_) @loop.inner) @loop.outer

(_
  (WhilePrefix)
  (_) @loop.inner) @loop.outer

;; blocks
(_ (Block) @block.inner) @block.outer

;; statements
(Statement) @statement.outer

;; parameters
((ParamDeclList 
  "," @_start . (ParamDecl) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 
((ParamDeclList
  . (ParamDecl) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end)) 

;; arguments
((FnCallArguments
  "," @_start . (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 
((FnCallArguments
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end)) 

;; comments
(doc_comment) @comment.outer
(line_comment) @comment.outer

;; conditionals
(_
  (IfPrefix)
  (_) @conditional.inner) @conditional.outer

((SwitchExpr
  "{" @_start "}" @_end)
  (#make-range! "conditional.inner" @_start @_end))  @conditional.outer

;; calls
(_ (FnCallArguments)) @call.outer
(_
  (FnCallArguments . "(" . (_) @_start (_)? @_end . ")"
  (#make-range! "call.inner" @_start @_end)))
