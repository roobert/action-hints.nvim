# :zap: Statusline Action Hints

![statusline-action-hints screenshot](https://user-images.githubusercontent.com/226654/217480442-ae97682d-c2e1-4dc3-a9d6-7d646ca4d025.gif)

A Neovim plugin to show statusline information about the word under the cursor.

Available statusline hints:
* go-to-definition is available
* reference list available
* number of references

## Installation

### Lazy

``` lua
{
  "roobert/statusline-action-hints.nvim",
  config = function()
    require("statusline-action-hints").setup({
      definition_identifier = "gd",
      template = "%s ref:%s",
    })
  end,
}
```

### Packer

``` lua
use({
  "roobert/statusline-action-hints.nvim",
  config = function()
    require("statusline-action-hints").setup({
      definition_identifier = "gd",
      template = "%s ref:%s",
    })
  end,
})
```

## Usage

As a lualine statusline component:

``` lua
require('lualine').setup {
  sections = {
    lualine_x = { require("statusline-action-hints").statusline }
  }
}
```
