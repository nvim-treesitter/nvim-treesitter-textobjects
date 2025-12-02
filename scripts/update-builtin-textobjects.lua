-- Execute as `nvim --headless -c "luafile ./scripts/update-readme.lua"`
local test_root = '.test-deps'
for _, name in ipairs({ 'config', 'data', 'state', 'cache' }) do
  vim.env[('XDG_%s_HOME'):format(name:upper())] = test_root .. '/' .. name
end
vim.opt.runtimepath:append(os.getenv('NVIM_TS') or (test_root .. '/nvim-treesitter'))
vim.opt.runtimepath:append('.')

local parsers = require('nvim-treesitter.parsers')
local shared = require('nvim-treesitter-textobjects.shared')
local sorted_parsers = {}

for k, v in pairs(parsers) do
  table.insert(sorted_parsers, { name = k, parser = v })
end

table.sort(sorted_parsers, function(a, b)
  return a.name < b.name
end)

local textobjects = {}
for m in table.concat(vim.fn.readfile('CONTRIBUTING.md'), '\n'):gmatch('@[%w.]*') do
  table.insert(textobjects, m)
end
table.sort(textobjects)

local generated_text = ''
for i, o in ipairs(textobjects) do
  generated_text = generated_text .. i .. '. ' .. o .. '\n'
end

generated_text = generated_text .. '<table>\n'

generated_text = generated_text .. '<th>\n'
for i, _ in ipairs(textobjects) do
  generated_text = generated_text .. '<td>' .. i .. '</td> '
end
generated_text = generated_text .. '</th>\n'

for _, v in ipairs(sorted_parsers) do
  local lang = (v.parser.readme_name or v.name)
  local found_textobjects = shared.available_textobjects(lang)

  local none_found = true
  for _, o in ipairs(textobjects) do
    local found = vim.tbl_contains(found_textobjects, o:sub(2))
    if found then
      none_found = false
      break
    end
  end

  if not none_found then
    generated_text = generated_text .. '<tr>\n'
    generated_text = generated_text .. '<td>' .. lang .. '</td>'

    for _, o in ipairs(textobjects) do
      local found = vim.tbl_contains(found_textobjects, o:sub(2))
      local status = found and '🟩' or '⬜'
      generated_text = generated_text
        .. '<td>'
        .. '<span title="'
        .. o
        .. '">'
        .. status
        .. '</span>'
        .. '</td> '
    end
    generated_text = generated_text .. '</tr>\n'
  end
end
generated_text = generated_text .. '</table>\n'

local prev_builtin_textobjects_text = table.concat(vim.fn.readfile('BUILTIN_TEXTOBJECTS.md'), '\n')
vim.fn.writefile(vim.fn.split(generated_text, '\n'), 'BUILTIN_TEXTOBJECTS.md')

if string.find(prev_builtin_textobjects_text, generated_text, 1, true) then
  print('BUILTIN_TEXTOBJECTS.md is up-to-date\n')
else
  print('New BUILTIN_TEXTOBJECTS.md was written\n')
end
