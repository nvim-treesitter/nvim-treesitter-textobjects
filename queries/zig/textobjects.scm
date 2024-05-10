; "Classes"
(VarDecl
  (_
    (_
      (ContainerDecl) @class.inner))) @class.outer

; functions
(_
  (FnProto)
  (Block) @function.inner) @function.outer

; loops
(_
  (ForPrefix)
  (_) @loop.inner) @loop.outer

(_
  (WhilePrefix)
  (_) @loop.inner) @loop.outer

; blocks
(_
  (Block) @block.inner) @block.outer

; statements
(Statement) @statement.outer

; parameters
(ParamDeclList
  "," @parameter.outer
  .
  (ParamDecl) @parameter.inner @parameter.outer)

(ParamDeclList
  .
  (ParamDecl) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; arguments
(FnCallArguments
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(FnCallArguments
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; comments
(doc_comment) @comment.outer

(line_comment) @comment.outer

; conditionals
(_
  (IfPrefix)
  (_) @conditional.inner) @conditional.outer

(SwitchExpr
  "{" @conditional.inner
  "}" @conditional.inner) @conditional.outer

; calls
(_
  (FnCallArguments)) @call.outer

(_
  (FnCallArguments
    .
    "("
    _+ @call.inner
    ")"))
