# nvim-snippets

Allow vscode style snippets to be used with native neovim snippets `vim.snippet`. Also comes with support for [friendly-snippets](https://github.com/rafamadriz/friendly-snippets).

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "garymjr/nvim-snippets",
  keys = {
    {
      "<Tab>",
      function()
        return vim.snippet.jumpable(1) and vim.snippet.jump(1) or "<Tab>"
      end,
      expr = true,
      silent = true,
      mode = "i",
    },
    {
      "<Tab>",
      function()
        return vim.snippet.jump(1)
      end,
      expr = true,
      silent = true,
      mode = "s",
    },
    {
      "<S-Tab>",
      function()
        return vim.snippet.jumpable(-1) and vim.snippet.jump(-1) or "<S-Tab>"
      end,
      expr = true,
      silent = true,
      mode = {"i", "s"},
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
