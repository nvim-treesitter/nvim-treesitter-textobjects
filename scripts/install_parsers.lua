#!/usr/bin/env -S nvim -l

vim.opt.runtimepath:append(vim.fn.expand "~/.local/share/nvim/site/pack/nvim-treesitter/start")

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
