# Statusline Action Hints

![statusline-action-hints](https://user-images.githubusercontent.com/226654/217479758-e711b989-90be-4d27-b5bc-aed5ea058d74.gif)

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
