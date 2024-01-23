local M = {}

M.config = {
  base_dir = "/home/mcfrank/notes" -- Default base directory
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

