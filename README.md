# nvim-treesitter-textobjects

Create your own textobjects using tree-sitter queries!

## Text objects: select

Define your own text objects mappings
similar to `ip` (inner paragraph) and `ap` (a paragraph).

```lua
lua <<EOF
require'nvim-treesitter.configs'.setup {
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",

        -- Or you can define your own textobjects like this
        ["iF"] = {
          python = "(function_definition) @function",
          cpp = "(function_definition) @function",
          c = "(function_definition) @function",
          java = "(method_declaration) @function",
        },
      },
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
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
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
    },
  },
}
EOF
```

## Textobjects: LSP interop

- peek_definition_code: show textobject surrounding definition as determined
  using Neovim's built-in LSP in a floating window. Press the shortcut twice
  to enter the floating window (when https://github.com/neovim/neovim/pull/12720
  or its successor is merged)

```lua
lua <<EOF
require'nvim-treesitter.configs'.setup {
  textobjects = {
    lsp_interop = {
      enable = true,
      peek_definition_code = {
        ["df"] = "@function.outer",
        ["dF"] = "@class.outer",
      },
    },
  },
}
EOF
```
