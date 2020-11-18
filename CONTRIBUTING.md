
### Text objects

You can define text objects based on nodes of the grammar by adding queries in `textobjects.scm`.
Each capture group can be declared as `inner` or `outer`.

```
@function.inner
@function.outer
@class.inner
@class.outer
@conditional.inner
@conditional.outer
@loop.inner
@loop.outer
@call.inner
@call.outer
@block.inner
@block.outer
@parameter.inner
@parameter.outer
```

Some nodes only have one type:

```
@comment.outer
@statement.outer
```

