local Runner = require('tests.select.common').Runner

local run = Runner:new(it, 'tests/select/xml', {
  tabstop = 2,
  shiftwidth = 2,
  softtabstop = 0,
  expandtab = true,
})

describe('XML textobjects:', function()
  -- @function.outer: whole element (linewise)
  -- cursor on <name>Hello</name>
  run:compare_cmds('elements.xml', { row = 4, col = 4, cmds = { 'dam', 'dVam', 'vamd', 'Vamd' } })

  -- @function.inner: content between tags
  -- cursor on <name>, inner selects "Hello"
  run:compare_cmds('elements.xml', { row = 4, col = 4, cmds = { 'dim', 'vimd' } })

  -- @attribute.outer: whole name="value" pair
  -- ursor on "id" in id="1"
  run:compare_cmds('elements.xml', { row = 3, col = 8, cmds = { 'dat', 'vatd', 'cat' } })

  -- @attribute.inner: the attribute value (including quotes)
  -- cursor on the opening quote of "1"
  run:compare_cmds('elements.xml', { row = 3, col = 11, cmds = { 'dit', 'vitd', 'cit' } })

  -- @comment.outer: the whole comment
  -- ursor on <!-- a comment -->
  run:compare_cmds('elements.xml', { row = 7, col = 2, cmds = { 'dac', 'vacd', 'cac' } })

  -- hyphenated element and attribute names
  -- cursor on <child-name>World</child-name>
  run:compare_cmds('elements.xml', { row = 10, col = 4, cmds = { 'dam', 'dVam', 'vamd', 'Vamd' } })
  run:compare_cmds('elements.xml', { row = 10, col = 4, cmds = { 'dim', 'vimd' } })

  -- cursor on "data-id" in data-id="2"
  run:compare_cmds('elements.xml', { row = 9, col = 18, cmds = { 'dat', 'vatd', 'cat' } })

  -- cursor on opening quote of "2"
  run:compare_cmds('elements.xml', { row = 9, col = 26, cmds = { 'dit', 'vitd', 'cit' } })
end)
