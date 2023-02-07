local Runner = require("tests.select.common").Runner

local run = Runner:new(it, "tests/select/python", {
  tabstop = 4,
  shiftwidth = 4,
  softtabstop = 0,
  expandtab = true,
})

describe("command equality Python:", function()
  run:equal_cmds("aligned_indent.py", { row = 1, col = 0, cmds = { "daa", "vaad", "caa" } })
  run:equal_cmds("aligned_indent.py", { row = 1, col = 10, cmds = { "dia", "viad", "cia" } })
  run:equal_cmds("aligned_indent.py", {
    row = 1,
    col = 0,
    cmds = {
      "diahx",
      "viadhx",
      "cia<bs>",
    },
  })
  -- select using built-in finds (f, F, t, T)
  run:equal_cmds("aligned_indent.py", { row = 1, col = 0, cmds = { "dfi", "vfid", "cfi" } })
  -- select using move
  run:equal_cmds("aligned_indent.py", { row = 1, col = 0, cmds = { "d]a", "v]ad", "c]a" } })
end)
