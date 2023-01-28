local Runner = require("tests.repeatable_move.common").Runner

local run = Runner:new(it, "tests/repeatable_move/python", {
  tabstop = 4,
  shiftwidth = 4,
  softtabstop = 0,
  expandtab = true,
})

describe("builtin find Python:", function()
  describe("repeat:", function()
    run:builtin_find("aligned_indent.py", { row = 1, char = "n" })
  end)
end)
