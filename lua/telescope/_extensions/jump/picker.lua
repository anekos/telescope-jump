local actions = require('telescope.actions')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local previewers = require('telescope.previewers')
local sorters = require('telescope.sorters')
local state = require('telescope.actions.state')

return function(opts)
  opts = opts or {}

  local results = {}
  for _, dir in pairs(vim.fn.systemlist('jump top')) do
    table.insert(results, vim.fn.fnamemodify(dir, ':~'))
  end

  local entry_maker = function(dir)
    return {
      value = dir,
      display = dir,
      ordinal = dir,
      path = dir,
    }
  end

  pickers
    .new(opts, {
      prompt_title = 'jump',
      finder = finders.new_table {
        results = results,
        entry_maker = entry_maker,
      },
      sorter = sorters.fuzzy_with_index_bias(),
      previewer = previewers.cat.new {},
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = state.get_selected_entry()
          vim.cmd('cd ' .. selection.value)
        end)

        map('n', 'dd', function()
          local current_picker = state.get_current_picker(prompt_bufnr)
          current_picker:delete_selection(function(_)
            local path = state.get_selected_entry().value
            vim.fn.system('jump forget ' .. vim.fn.fnameescape(path))
            print('Forget item: ' .. path)
          end)
        end)
        return true
      end,
    })
    :find()
end
