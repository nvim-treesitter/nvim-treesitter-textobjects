; class textobject
(dataclass
  (typeExpr)
  (_) @class.inner) @class.outer

; function textobject
(charpred
  (className)
  (_) @function.inner) @function.outer

(memberPredicate
  (body) @function.inner) @function.outer

(classlessPredicate
  (body) @function.inner) @function.outer

; scope name textobject
(dataclass
  name: (className) @scopename.inner)

(classlessPredicate
  name: (predicateName) @scopename.inner)

(memberPredicate
  name: (predicateName) @scopename.inner)

(charpred
  (className) @scopename.inner)
