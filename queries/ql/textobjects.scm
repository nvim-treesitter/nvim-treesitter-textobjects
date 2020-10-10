;; class textobject
(dataclass) @class.outer

;; function textobject
(classMember) @function.outer
(memberPredicate (body) @function.inner)
(classlessPredicate (body) @function.inner) @function.outer
