local Runner = require('tests.select.common').Runner

local run = Runner:new(it, 'tests/select/lua', {
  tabstop = 2,
  shiftwidth = 2,
  softtabstop = 0,
  expandtab = true,
})

describe('Look back if within @function.outer range (Lua):', function()
  run:compare_cmds('lookback.lua', { row = 4, col = 0, cmds = { 'dim', 'k^D' } })
end)

describe('Look forward if outside @function.outer range (Lua):', function()
  run:compare_cmds('lookback.lua', { row = 5, col = 0, cmds = { 'dim', '2j^D' } })
end)
