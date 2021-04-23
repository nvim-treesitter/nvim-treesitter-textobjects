;; class textobject
(dataclass (typeExpr) (_) @class.inner) @class.outer

;; function textobject
(charpred (className) (_) @function.inner) @function.outer
(memberPredicate (body) @function.inner) @function.outer
(classlessPredicate (body) @function.inner) @function.outer

;; block textobject
(classlessPredicate name: (predicateName) @block.outer)
(memberPredicate name: (predicateName) @block.outer)
(charpred (className) @block.outer)
