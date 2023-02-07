# Statusline Action Hints

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
        require("statusline-action-hints").setup()
    end,
}
```

### Packer

``` lua
use({
    "roobert/statusline-action-hints.nvim",
    config = function()
        require("statusline-action-hints").setup()
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
