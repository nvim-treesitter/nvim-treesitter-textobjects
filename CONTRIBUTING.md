# Contributing

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
Or, you can manually change according to the CI output.

### Query file format

To automatically format and check queries, run `make query` (Linux and macOS).

## Tree-sitter Basics

### Designing Queries

You can design your queries by inspecting the syntax tree of your target language.

1. open `:InspectTree` on a buffer with the target language
2. press `o` to open the query editor
3. write your query and test it interactively
