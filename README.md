# nvim-treesitter-textobjects

Syntax aware text-objects, select, move, swap, and peek support.

**Warning: tree-sitter and nvim-treesitter are an experimental feature of nightly versions of Neovim.
Please consider the experience with this plug-in as experimental until tree-sitter support in Neovim is stable!
We recommend using the nightly builds of Neovim or the latest stable version.**

## Installation

You can install nvim-treesitter-textobjects with your favorite package manager, or using the default pack feature of Neovim!

### Using a package manager

If you are using [vim-plug](https://github.com/junegunn/vim-plug), put this in your init.vim file:

```vim
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
```

If you are using [Packer](https://github.com/wbthomason/packer.nvim), put it in your init.lua file:

```lua
use({
  "nvim-treesitter/nvim-treesitter-textobjects",
  after = "nvim-treesitter",
  requires = "nvim-treesitter/nvim-treesitter",
})
```

## Text objects: select

Define your own text objects mappings
similar to `ip` (inner paragraph) and `ap` (a paragraph).

```lua
lua <<EOF
require'nvim-treesitter.configs'.setup {
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        -- You can optionally set descriptions to the mappings (used in the desc parameter of
        -- nvim_buf_set_keymap) which plugins like which-key display
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
        -- You can also use captures from other query groups like `locals.scm`
        ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
      },
      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V', -- linewise
        ['@class.outer'] = '<c-v>', -- blockwise
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true of false
      include_surrounding_whitespace = true,
    },
  },
}
EOF
```

## Text objects: swap

Define your own mappings to swap the node under the cursor with the next or previous one,
like function parameters or arguments.

```lua
lua <<EOF
require'nvim-treesitter.configs'.setup {
  textobjects = {
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },
  },
}
EOF
```

## Text objects: move

Define your own mappings to jump to the next or previous text object.
This is similar to `]m`, `[m`, `]M`, `[M` Neovim's mappings to jump to the next
or previous function.

```lua
lua <<EOF
require'nvim-treesitter.configs'.setup {
  textobjects = {
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = { query = "@class.outer", desc = "Next class start" },
        --
        -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
        ["]o"] = "@loop.*",
        -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
        --
        -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
        -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
        ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
        ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
      -- Below will go to either the start or the end, whichever is closer.
      -- Use if you want more granular movements
      -- Make it even more gradual by adding multiple queries and regex.
      goto_next = {
        ["]d"] = "@conditional.outer",
      },
      goto_previous = {
        ["[d"] = "@conditional.outer",
      }
    },
  },
}
EOF
```

You can make the movements repeatable like `;` and `,`.

```lua
local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"

-- Repeat movement with ; and ,
-- ensure ; goes forward and , goes backward regardless of the last direction
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

-- vim way: ; goes to the direction you were moving.
-- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
-- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
```

You can even make a custom repeat behaviour.

```lua
-- This repeats the last query with always previous direction and to the start of the range.
vim.keymap.set({ "n", "x", "o" }, "<home>", function()
  ts_repeat_move.repeat_last_move({forward = false, start = true})
end)

-- This repeats the last query with always next direction and to the end of the range.
vim.keymap.set({ "n", "x", "o" }, "<end>", function()
  ts_repeat_move.repeat_last_move({forward = true, start = false})
end)
```

Furthermore, you can make any custom movements (e.g. from another plugin) repeatable with the same keys.
This doesn't need to be treesitter-related.

```lua
-- example: make gitsigns.nvim movement repeatable with ; and , keys.
local gs = require("gitsigns")

-- make sure forward function comes first
local next_hunk_repeat, prev_hunk_repeat = ts_repeat_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
-- Or, use `make_repeatable_move` or `set_last_move` functions for more control. See the code for instructions.

vim.keymap.set({ "n", "x", "o" }, "]h", next_hunk_repeat)
vim.keymap.set({ "n", "x", "o" }, "[h", prev_hunk_repeat)
```

Alternative way is to use a repeatable movement managing plugin such as [nvim-next](https://github.com/ghostbuster91/nvim-next).

## Textobjects: LSP interop

- peek_definition_code: show textobject surrounding definition as determined
  using Neovim's built-in LSP in a floating window. Press the shortcut twice
  to enter the floating window.

```lua
lua <<EOF
require'nvim-treesitter.configs'.setup {
  textobjects = {
    lsp_interop = {
      enable = true,
      border = 'none',
      floating_preview_opts = {},
      peek_definition_code = {
        ["<leader>df"] = "@function.outer",
        ["<leader>dF"] = "@class.outer",
      },
    },
  },
}
EOF
```

# Overriding or extending textobjects

Textobjects are defined in the `textobjects.scm` files.
You can extend or override those files by following the instructions at
<https://github.com/nvim-treesitter/nvim-treesitter#adding-queries>.
You can also use a custom capture for your own textobjects,
and use it in any of the textobject modules, for example:

```scm
-- after/queries/python/textobjects.scm
; extends
(function_definition) @custom_capture
```

```lua
lua <<EOF
require'nvim-treesitter.configs'.setup {
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        -- Your custom capture.
        ["aF"] = "@custom_capture",

        -- Built-in captures.
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
      },
    },
  },
}
EOF
```

Here are some rules about the query names that should be noted.  

1. Avoid using special characters in the query name, because in `move` module the names are read as regex (lua) patterns.
  - `@custom-capture.inner` (X)
  - `@custom_capture.inner` (O)
2. In `select` module, it will be preferred to select within the `@*.outer` matches. For example,
  - `@assignment.inner`, `@assignment.lhs`, and even `@assignment` will be selected within the `@assignment.outer` range if available. This means it will sometimes look behind.
  - You can write something like `@function.name` or `@call.name` and make sure `@function.outer` and `@call.outer` covers the range.

## Built-in Textobjects

<!--textobjectinfo-->
1. @assignment.inner
2. @assignment.lhs
3. @assignment.outer
4. @assignment.rhs
5. @attribute.inner
6. @attribute.outer
7. @block.inner
8. @block.outer
9. @call.inner
10. @call.outer
11. @class.inner
12. @class.outer
13. @comment.inner
14. @comment.outer
15. @conditional.inner
16. @conditional.outer
17. @frame.inner
18. @frame.outer
19. @function.inner
20. @function.outer
21. @loop.inner
22. @loop.outer
23. @number.inner
24. @parameter.inner
25. @parameter.outer
26. @regex.inner
27. @regex.outer
28. @return.inner
29. @return.outer
30. @scopename.inner
31. @statement.outer
<table>
<th>
<td>1</td> <td>2</td> <td>3</td> <td>4</td> <td>5</td> <td>6</td> <td>7</td> <td>8</td> <td>9</td> <td>10</td> <td>11</td> <td>12</td> <td>13</td> <td>14</td> <td>15</td> <td>16</td> <td>17</td> <td>18</td> <td>19</td> <td>20</td> <td>21</td> <td>22</td> <td>23</td> <td>24</td> <td>25</td> <td>26</td> <td>27</td> <td>28</td> <td>29</td> <td>30</td> <td>31</td> </th>
</table>
<!--textobjectinfo-->
