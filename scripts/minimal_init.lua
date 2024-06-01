require("nvim-treesitter").setup {
  -- A list of parser names, or "all"
  ensure_installed = { "python" },

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!
  -- parser_install_dir = "/some/path/to/store/parsers",
}

vim.cmd [[
packadd nvim-treesitter
packadd nvim-treesitter-textobjects
packadd plenary.nvim
TSUpdate
]]

require("nvim-treesitter-textobjects").setup {
  select = {
    lookahead = true,
    include_surrounding_whitespace = false,
  },
  move = {
    set_jumps = true,
  },
}

local select = require "nvim-treesitter-textobjects.select"
for _, mode in ipairs { "x", "o" } do
  vim.keymap.set(mode, "am", function()
    select.select_textobject("@function.outer", "textobjects", mode)
  end)
  vim.keymap.set(mode, "im", function()
    select.select_textobject("@function.inner", "textobjects", mode)
  end)
  vim.keymap.set(mode, "al", function()
    select.select_textobject("@class.outer", "textobjects", mode)
  end)
  vim.keymap.set(mode, "il", function()
    select.select_textobject("@class.inner", "textobjects", mode)
  end)
  vim.keymap.set(mode, "ab", function()
    select.select_textobject("@block.outer", "textobjects", mode)
  end)
  vim.keymap.set(mode, "ib", function()
    select.select_textobject("@block.inner", "textobjects", mode)
  end)
  vim.keymap.set(mode, "ad", function()
    select.select_textobject("@conditional.outer", "textobjects", mode)
  end)
  vim.keymap.set(mode, "id", function()
    select.select_textobject("@conditional.inner", "textobjects", mode)
  end)
  vim.keymap.set(mode, "ao", function()
    select.select_textobject("@loop.outer", "textobjects", mode)
  end)
  vim.keymap.set(mode, "io", function()
    select.select_textobject("@loop.inner", "textobjects", mode)
  end)
  vim.keymap.set(mode, "aa", function()
    select.select_textobject("@parameter.outer", "textobjects", mode)
  end)
  vim.keymap.set(mode, "ia", function()
    select.select_textobject("@parameter.inner", "textobjects", mode)
  end)
  vim.keymap.set(mode, "af", function()
    select.select_textobject("@call.outer", "textobjects", mode)
  end)
  vim.keymap.set(mode, "if", function()
    select.select_textobject("@call.inner", "textobjects", mode)
  end)
  vim.keymap.set(mode, "ac", function()
    select.select_textobject("@comment.outer", "textobjects", mode)
  end)
  vim.keymap.set(mode, "ar", function()
    select.select_textobject("@frame.outer", "textobjects", mode)
  end)
  vim.keymap.set(mode, "ir", function()
    select.select_textobject("@frame.inner", "textobjects", mode)
  end)
  vim.keymap.set(mode, "at", function()
    select.select_textobject("@attribute.outer", "textobjects", mode)
  end)
  vim.keymap.set(mode, "it", function()
    select.select_textobject("@attribute.inner", "textobjects", mode)
  end)
  vim.keymap.set(mode, "ae", function()
    select.select_textobject("@scopename.inner", "textobjects", mode)
  end)
  vim.keymap.set(mode, "ie", function()
    select.select_textobject("@scopename.inner", "textobjects", mode)
  end)
  vim.keymap.set(mode, "as", function()
    select.select_textobject("@statement.outer", "textobjects", mode)
  end)
  vim.keymap.set(mode, "is", function()
    select.select_textobject("@statement.outer", "textobjects", mode)
  end)
end

vim.keymap.set("n", ")m", require("nvim-treesitter-textobjects.swap").swap_next "@function.outer")
vim.keymap.set("n", ")c", require("nvim-treesitter-textobjects.swap").swap_next "@comment.outer")
vim.keymap.set("n", ")a", require("nvim-treesitter-textobjects.swap").swap_next "@parameter.inner")
vim.keymap.set("n", ")b", require("nvim-treesitter-textobjects.swap").swap_next "@block.outer")
vim.keymap.set("n", ")C", require("nvim-treesitter-textobjects.swap").swap_next "@class.outer")

vim.keymap.set("n", "(m", require("nvim-treesitter-textobjects.swap").swap_previous "@function.outer")
vim.keymap.set("n", "(c", require("nvim-treesitter-textobjects.swap").swap_previous "@comment.outer")
vim.keymap.set("n", "(a", require("nvim-treesitter-textobjects.swap").swap_previous "@parameter.inner")
vim.keymap.set("n", "(b", require("nvim-treesitter-textobjects.swap").swap_previous "@block.outer")
vim.keymap.set("n", "(C", require("nvim-treesitter-textobjects.swap").swap_previous "@class.outer")

vim.keymap.set({ "n", "x", "o" }, "]m", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@function.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]f", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@call.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]d", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@conditional.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]o", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@loop.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]s", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@statement.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]a", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@parameter.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]c", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@comment.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]b", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@block.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]l", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@class.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]r", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@frame.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]t", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@attribute.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]e", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@scopename.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]]m", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@function.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]f", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@call.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]d", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@conditional.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]o", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@loop.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]a", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@parameter.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]b", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@block.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]l", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@class.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]r", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@frame.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]t", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@attribute.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]e", function()
  require("nvim-treesitter-textobjects.move").goto_next_start "@scopename.inner"
end)

vim.keymap.set({ "n", "x", "o" }, "]M", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@function.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]F", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@call.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]D", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@conditional.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]O", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@loop.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]S", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@statement.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]A", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@parameter.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]C", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@comment.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]B", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@block.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]L", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@class.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]R", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@frame.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]T", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@attribute.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]E", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@scopename.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "]]M", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@function.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]F", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@call.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]D", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@conditional.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]O", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@loop.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]A", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@parameter.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]B", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@block.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]L", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@class.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]R", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@frame.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]T", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@attribute.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "]]E", function()
  require("nvim-treesitter-textobjects.move").goto_next_end "@scopename.inner"
end)

vim.keymap.set({ "n", "x", "o" }, "[m", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@function.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[f", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@call.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[d", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@conditional.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[o", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@loop.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[s", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@statement.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[a", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@parameter.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[c", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@comment.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[b", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@block.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[l", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@class.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[r", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@frame.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[t", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@attribute.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[e", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@scopename.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[[m", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@function.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[f", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@call.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[d", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@conditional.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[o", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@loop.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[a", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@parameter.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[b", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@block.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[l", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@class.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[r", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@frame.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[t", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@attribute.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[e", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start "@scopename.inner"
end)

vim.keymap.set({ "n", "x", "o" }, "[M", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@function.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[F", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@call.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[D", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@conditional.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[O", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@loop.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[S", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@statement.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[A", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@parameter.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[C", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@comment.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[B", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@block.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[L", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@class.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[R", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@frame.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[T", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@attribute.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[E", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@scopename.outer"
end)
vim.keymap.set({ "n", "x", "o" }, "[[M", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@function.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[F", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@call.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[D", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@conditional.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[O", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@loop.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[A", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@parameter.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[B", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@block.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[L", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@class.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[R", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@frame.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[T", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@attribute.inner"
end)
vim.keymap.set({ "n", "x", "o" }, "[[E", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end "@scopename.inner"
end)

local ts_repeat_move = require "nvim-treesitter-textobjects.repeatable_move"

-- Repeat movement with ; and ,
-- ensure ; goes forward and , goes backward regardless of the last direction
-- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
-- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

-- vim way: ; goes to the direction you were moving.
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
