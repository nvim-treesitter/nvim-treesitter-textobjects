;; class textobject
(dataclass (typeExpr) (_) @class.inner) @class.outer

;; predicate textobject
(charpred (className) (_) @function.inner) @function.outer
(memberPredicate (body) @function.inner) @function.outer
(classlessPredicate (body) @function.inner) @function.outer

;; identifier textobject
(dataclass name: (className) @identifier.outer)
(classlessPredicate name: (predicateName) @identifier.outer)
(memberPredicate name: (predicateName) @identifier.outer)
(charpred (className) @identifier.outer)
