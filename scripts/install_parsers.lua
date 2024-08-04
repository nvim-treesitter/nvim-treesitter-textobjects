#!/usr/bin/env -S nvim -l

local languages = _G.arg
languages[0] = nil

-- needed on CI
vim.fn.mkdir(vim.fn.stdpath "cache", "p")

local done = false
require("nvim-treesitter.install").install(languages, { force = true }, function()
  done = true
end)

vim.wait(6000000, function()
  return done
end)
