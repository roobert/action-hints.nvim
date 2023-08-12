# :zap: Action Hints

![action-hints screenshot](https://user-images.githubusercontent.com/226654/217480442-ae97682d-c2e1-4dc3-a9d6-7d646ca4d025.gif)

A Neovim plugin to show information about the word under the cursor.

Available hints:

- go-to-definition (`gd`) is available
- reference list (`gr`) available / number of references

## Installation

### Lazy

```lua
{
  "roobert/action-hints.nvim",
  config = function()
    require("action-hints").setup()
  end,
},
```

### Packer

```lua
use({
  "roobert/action-hints.nvim",
  config = function()
    require("action-hints").setup()
  end,
})
```

## Configuration

```lua
{
  "roobert/action-hints.nvim",
  config = function()
    require("action-hints").setup({
      template = {
        { " ⊛", "ActionHintsDefinition" },
        { " ↱%s", "ActionHintsReferences" },
      },
      use_virtual_text = true,
    })
  end,
},
```

Adjust highlight colours for virtual text:

```
highlight ActionHintsDefinition guifg=#add8e6
highlight ActionHintsReferences guifg=#ff6666
```

## Usage

Note that for now the component must be included in the lualine for the virtual text to
be updated.

As a lualine component:

```lua
require('lualine').setup {
  sections = {
    lualine_x = { require("action-hints").statusline },
  }
}
```
