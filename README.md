# :zap: Action Hints

![action-hints Screenshot](https://github.com/roobert/action-hints.nvim/assets/226654/41d2e228-0991-41bc-ac0e-bc20aa5ca54a)

A Neovim plugin that displays available actions like 'Go to Definition' and 'Go to Reference(s)' for the highlighted word, presented in the statusline or inline as virtual text.






Available hints:

- `⊛` - go-to-definition (`gd`) is available
- `↱` reference list (`gr`) available / number of references

## Installation

```lua
{
  "roobert/action-hints.nvim",
  config = function()
    require("action-hints").setup()
  end,
},
```

## Configuration

```lua
{
  "roobert/action-hints.nvim",
  config = function()
    require("action-hints").setup({
      template = {
        definition = { text = " ⊛", color = "#add8e6" },
        references = { text = " ↱%s", color = "#ff6666" },
      },
      use_virtual_text = true,
    })
  end,
},
```

## Usage

As a lualine component:

```lua
require("lualine").setup({
  sections = {
    lualine_x = { require("action-hints").statusline },
  },
})
```
