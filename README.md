# :zap: Statusline Action Hints

![statusline-action-hints screenshot](https://user-images.githubusercontent.com/226654/217480442-ae97682d-c2e1-4dc3-a9d6-7d646ca4d025.gif)

A Neovim plugin to show statusline information about the word under the cursor.

Available statusline hints:

- go-to-definition (`gd`) is available
- reference list (`gr`) available / number of references

## Installation

### Lazy

```lua
{
  "roobert/statusline-action-hints.nvim",
  config = function()
    require("statusline-action-hints").setup()
  end,
},
```

### Packer

```lua
use({
  "roobert/statusline-action-hints.nvim",
  config = function()
    require("statusline-action-hints").setup()
  end,
})
```

## Configuration

```lua
{
  "roobert/statusline-action-hints.nvim",
  config = function()
    require("statusline-action-hints").setup({
      template = {
        { " ⊛", "StatuslineActionHintsDefinition" },
        { " ↱%s", "StatuslineActionHintsReferences" },
      },
      use_virtual_text = true,
    })
  end,
},
```

Adjust highlight colours for virtual text:

```
highlight StatuslineActionHintsDefinition guifg=#add8e6
highlight StatuslineActionHintsReferences guifg=#ff6666
```

## Usage

As a lualine statusline component:

```lua
require('lualine').setup {
  sections = {
    lualine_x = { require("statusline-action-hints").statusline },
  }
}
```
