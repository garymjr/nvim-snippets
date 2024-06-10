# nvim-snippets

Allow vscode style snippets to be used with native neovim snippets `vim.snippet`. Also comes with support for [friendly-snippets](https://github.com/rafamadriz/friendly-snippets).

## Features

- Supports vscode style snippets
- Has builtin support for [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
- Uses `vim.snippet` under the hood for snippet expansion

## Requirements
- Requires neovim >= 0.10 (with commit [f1775da](https://github.com/neovim/neovim/commit/f1775da07fe48da629468bcfcc2a8a6c4c3f40ed) or later)
- (optional) [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) for completion support
- (optional) [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) for pre-built snippets

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "garymjr/nvim-snippets",
  keys = {
    {
      "<Tab>",
      function()
        if vim.snippet.active({ direction = 1 }) then
          vim.schedule(function()
            vim.snippet.jump(1)
          end)
          return
        end
        return "<Tab>"
      end,
      expr = true,
      silent = true,
      mode = "i",
    },
    {
      "<Tab>",
      function()
        vim.schedule(function()
          vim.snippet.jump(1)
        end)
      end,
      expr = true,
      silent = true,
      mode = "s",
    },
    {
      "<S-Tab>",
      function()
        if vim.snippet.active({ direction = -1 }) then
          vim.schedule(function()
            vim.snippet.jump(-1)
          end)
          return
        end
        return "<S-Tab>"
      end,
      expr = true,
      silent = true,
      mode = { "i", "s" },
    },
  },
}
```

## Configuration

| Option           | Type      | Default                                   | Description           |
-------------------|-----------|-------------------------------------------|------------------------
create_autocmd     | `boolean?`  | `false`                                     | Optionally load all snippets when opening a file. Only needed if not using [nvim-cmp](https://github.com/hrsh7th/nvim-cmp).
create_cmp_source  | `boolean?`  | `true`                                      | Optionally create a [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) source. Source name will be `snippets`.
friendly_snippets  | `boolean?`  | `false`                                     | Set to true if using [friendly-snippets](https://github.com/rafamadriz/friendly-snippets).
ignored_filetypes  | `string[]?` | `nil`                                       | Filetypes to ignore when loading snippets.
extended_filetypes | `table?`    | `nil`                                       | Filetypes to load snippets for in addition to the default ones. `ex: {typescript = {'javascript'}}`
global_snippets    | `string[]?` | `{'all'}`                                   | Snippets to load for all filetypes.
search_paths       | `string[]`  | `{vim.fn.stdpath('config') .. '/snippets'}` | Paths to search for snippets.

## Example Snippet

```json
{
  "Say hello to the world": {
    "prefix": ["hw", "hello"],
    "body": "Hello, ${1:world}!$0"
  }
}
```

## TODO
- [ ] Automatically detect if friendly-snippets is installed
- [X] Add support for friendly-snippets `package.json` definitions (#31)
