# Markdown Linker for Neovim

This Neovim plugin integrates with Telescope to enable the insertion of Markdown links to files within a specified base directory, streamlining the linking process similar to the functionality seen in Obsidian, but specifically tailored for Markdown files within Neovim.

## Features

- Insert Markdown links using Telescope picker.
- Customizable base directory for Markdown file searches.
- Trigger link insertion directly in insert mode with a key sequence.

## Requirements

- Neovim (0.5 or later)
- `telescope.nvim`

## Installation

### Using Lazy.nvim

If you haven't already, install `lazy.nvim` following the instructions on its [GitHub page](https://github.com/folke/lazy.nvim). Then, configure your `init.lua` to include `markdown-linker` and its dependencies:

```lua
require('lazy').setup({
  {'nvim-telescope/telescope.nvim'},
  {
    'm-c-frank/markdown-linker',
    config = function()
      require('markdown_linker').setup({
        base_dir = "/home/mcfrank/notes" -- Customize this path
      })
    end
  }
})
```

## Configuration

After installing the plugin, configure it by calling the `setup` function. You can specify the base directory where the plugin will search for Markdown files:

```lua
require('markdown_linker').setup({
  base_dir = "/home/mcfrank/notes" -- Adjust to your Markdown files directory
})
```

## Usage

To use the plugin, ensure you're in insert mode within a Markdown file and type `<leader>[[`. This will trigger the Telescope picker, allowing you to search for a Markdown file to link.

### Insert Mode Trigger Setup

To automatically trigger the link insertion in insert mode with `<leader>[[`, add this to your Neovim configuration:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.api.nvim_buf_set_keymap(0, 'i', '\\[[', "<cmd>lua require('markdown_linker').insert_markdown_link()<CR>", {noremap = true, silent = true})
  end
})
```

## Plugin Code (`lua/markdown_linker/init.lua`)

Below is the Lua code for the plugin. Create a directory structure as described earlier and add this code to `init.lua` under `lua/markdown_linker/` directory.

```lua
local M = {}

M.config = {
  base_dir = "." -- Default base directory
}

function M.setup(opts)
  M.config = vim.tbl_extend('force', M.config, opts or {})
end

function M.insert_markdown_link()
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values

  pickers.new({}, {
    prompt_title = "Link Markdown File",
    finder = finders.new_oneshot_job({'find', M.config.base_dir, '-type', 'f', '-name', '*.md'}),
    sorter = conf.file_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local link_path = selection[1]
        local link_text = action_state.get_current_line()
        local markdown_link = string.format("[%s](%s)", link_text, link_path)
        vim.api.nvim_put({markdown_link}, 'c', false, true)
      end)
      return true
    end,
  }):find()
end

return M
```

## Directory Structure

Ensure your plugin follows this directory structure:

```
markdown-linker/
├── lua/
│   ├── markdown_linker/
│   │   └── init.lua
└── README.md
```

## Conclusion

This plugin enhances your Markdown editing experience in Neovim by simplifying the process of linking to other Markdown files, leveraging the powerful Telescope plugin for file searching. Customize the base directory as needed to fit your project structure or personal workflow.
