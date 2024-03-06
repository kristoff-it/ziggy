# Ziggy support for Neovim

## Tree Sitter grammar and queries

### 1. Add the following lines to your `nvim-treesitter` config

The following lines should be pasted inside of your config file.

```lua
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.ziggy = {
  install_info = {
    url = "https://github.com/kristoff-it/ziggy", -- local path or git repo
    includes = {"tree-sitter-ziggy/src"},
    files = {"tree-sitter-ziggy/src/parser.c"}, -- note that some parsers also require src/scanner.c or src/scanner.cc
    -- optional entries:
    branch = "main", -- default branch in case of git repo if different from master
    generate_requires_npm = false, -- if stand-alone parser without npm dependencies
    requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
  },
}

parser_config.ziggy_schema = {
  install_info = {
    url = "https://github.com/kristoff-it/ziggy", -- local path or git repo
    files = {"tree-sitter-ziggy-schema/src/parser.c"}, -- note that some parsers also require src/scanner.c or src/scanner.cc
    -- optional entries:
    branch = "main", -- default branch in case of git repo if different from master
    generate_requires_npm = false, -- if stand-alone parser without npm dependencies
    requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
  },
  filetype = "ziggy-schema",
}

vim.filetype.add({
  extension = {
    ziggy = 'ziggy',
    ["ziggy-schema"] = "ziggy_schema",
  }
})
```

### 2. Copy the queries into your runtime path

NOTE: '-T' makes it so you can run the command multiple times without nesting new copies of `queries` more deeply than intended. Also macOS doesn't support it.

- `cp -rT tree-sitter-ziggy/queries NVIM_RUNTIME_PATH/queries/ziggy`
- `cp -rT tree-sitter-ziggy-schema/queries NVIM_RUNTIME_PATH/queries/ziggy_schema`

### 3. Open Neovim and compile the grammars

- `:TSInstall ziggy`
- `:TSInstall ziggy_schema`

## Autoformatting
By using the `ziggy` CLI tool.

In your conform.nvim config add two new formatter definitions and map them
to their corresponding filetype:
```lua
formatters = {
  ziggy = {
    inherit = false,
    command = "ziggy",
    stdin = true,
    args = { 'fmt', '--stdin' },
  },
  ziggy_schema = {
    inherit = false,
    command = "ziggy",
    stdin = true,
    args = { 'fmt', '--stdin-schema' },
  },
},

formatters_by_ft = {
  ziggy = { 'ziggy' },
  ziggy_schema = { 'ziggy_schema' },
},
```

## LSP
Add the following to your Neovim config:

```lua
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("ziggy", {}),
	pattern = "ziggy",
	callback = function()
		vim.lsp.start({
			name = "Ziggy LSP",
			cmd = { "ziggy", "lsp" },
			root_dir = vim.loop.cwd(),
			flags = { exit_timeout = 1000 },
		})
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("ziggy_schema", {}),
	pattern = "ziggy_schema",
	callback = function()
		vim.lsp.start({
			name = "Ziggy LSP",
			cmd = { "ziggy", "lsp", "--schema" },
			root_dir = vim.loop.cwd(),
			flags = { exit_timeout = 1000 },
		})
	end,
})
```
