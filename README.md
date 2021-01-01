# nvim-treesitter-textobjects

Create your own textobjects using tree-sitter queries!

## Installation

You can install nvim-treesitter-textobjects with your favorite package manager, or using the default pack feature of Neovim!

### Using a package manager

If you are using vim-plug, put this in your init.vim file:

```vim
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
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
## Built-in Textobjects

<!--textobjectinfo-->
1. @block.inner
2. @block.outer
3. @call.inner
4. @call.outer
5. @class.inner
6. @class.outer
7. @comment.outer
8. @conditional.inner
9. @conditional.outer
10. @function.inner
11. @function.outer
12. @loop.inner
13. @loop.outer
14. @parameter.inner
15. @parameter.outer
16. @statement.outer
<table>
<th>
<td>1</td> <td>2</td> <td>3</td> <td>4</td> <td>5</td> <td>6</td> <td>7</td> <td>8</td> <td>9</td> <td>10</td> <td>11</td> <td>12</td> <td>13</td> <td>14</td> <td>15</td> <td>16</td> </th>
<tr>
<td>bash</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>c</td><td> </td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td>👍</td> </tr>
<tr>
<td>c_sharp</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td>👍</td> <td>👍</td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>clojure</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>cpp</td><td> </td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td>👍</td> </tr>
<tr>
<td>css</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>dart</td><td> </td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td>👍</td> </tr>
<tr>
<td>elm</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>erlang</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>fennel</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>Godot (gdscript)</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>go</td><td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td>👍</td> </tr>
<tr>
<td>graphql</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>haskell</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>html</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>java</td><td> </td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td> </td> </tr>
<tr>
<td>javascript</td><td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td> </td> </tr>
<tr>
<td>jsdoc</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>json</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>julia</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>kotlin</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>lua</td><td> </td> <td> </td> <td>👍</td> <td>👍</td> <td> </td> <td> </td> <td>👍</td> <td> </td> <td>👍</td> <td> </td> <td>👍</td> <td> </td> <td>👍</td> <td>👍</td> <td> </td> <td> </td> </tr>
<tr>
<td>nix</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>ocaml</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>ocaml_interface</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>ocamllex</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>php</td><td>👍</td> <td>👍</td> <td> </td> <td> </td> <td>👍</td> <td>👍</td> <td> </td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td> </td> </tr>
<tr>
<td>python</td><td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td>👍</td> </tr>
<tr>
<td>ql</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td>👍</td> <td> </td> <td> </td> <td> </td> <td>👍</td> <td>👍</td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>Tree-sitter query language</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>regex</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>rst</td><td>👍</td> <td>👍</td> <td> </td> <td> </td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td> </td> <td>👍</td> <td>👍</td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>ruby</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>rust</td><td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td>👍</td> </tr>
<tr>
<td>scala</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>sparql</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>swift</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>teal</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>toml</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>tsx</td><td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td> </td> </tr>
<tr>
<td>typescript</td><td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td>👍</td> <td> </td> <td> </td> </tr>
<tr>
<td>verilog</td><td> </td> <td>👍</td> <td> </td> <td> </td> <td> </td> <td>👍</td> <td>👍</td> <td> </td> <td>👍</td> <td> </td> <td>👍</td> <td> </td> <td>👍</td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>vue</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
<tr>
<td>yaml</td><td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> <td> </td> </tr>
</table>
<!--textobjectinfo-->
