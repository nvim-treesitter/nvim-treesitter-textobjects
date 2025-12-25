local Runner = require('tests.select.common').Runner

local run = Runner:new(it, 'tests/select/lua', {
  tabstop = 2,
  shiftwidth = 2,
  softtabstop = 0,
  expandtab = true,
})

describe('command equality Lua:', function()
  run:compare_cmds('selection_mode.lua', { row = 3, col = 0, cmds = { 'dim', 'k_D' } })
end)
