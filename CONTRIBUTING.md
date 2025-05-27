### Textobjects

You can define text objects based on nodes of the grammar by adding queries in
`textobjects.scm`. Each capture group can be declared as `inner` or `outer`.

```
@attribute.inner
@attribute.outer
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
@regex.inner
@regex.outer
@comment.inner
@comment.outer
@assignment.inner
@assignment.outer
@return.inner
@return.outer

# For LaTeX frames
@frame.inner
@frame.outer
```

Some nodes only have one type:

```
@statement.outer
@scopename.inner
@number.inner
```

Some nodes have more captures available:

```
@assignment.lhs
@assignment.rhs
```

### Automatic README Generation

To update the README after adding new textobjects, run `make docs`.

### Query file format

To automatically format and check queries, run `make query` (Linux and macOS).
