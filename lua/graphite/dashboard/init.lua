local Dashboard = {}
local Windows = require('graphite.windows')
local Job = require('plenary.job')

function Dashboard:launch_dashboard()
  -- Create a new window for the buffer
  local dashboard = Windows:create_window('Graphite Dashboard', 'Hint: [b]ranch | [C]hangelog | [d]ownstack | [l]og | [s]tatus | [u]pstack | [q]uit')
  Dashboard.dashboard_bufnr = dashboard.bufnr
  Dashboard.winid = dashboard.winid

  vim.cmd('autocmd BufEnter <buffer=' .. self.dashboard_bufnr .. '> lua require("graphite.dashboard"):refresh_dashboard()')

  -- Get the currently checked out branch
  local current_branch_job = Job:new({
    command = 'git',
    args = { 'rev-parse', '--abbrev-ref', 'HEAD' },
    on_exit = function(j)
      local output = j:result()
      vim.schedule(function()
        -- Set the buffer's lines to the keybind hints
        vim.api.nvim_buf_set_lines(dashboard.bufnr, 0, -1, false, {
          'v.0.1 Currently checked out branch: ' .. output[1],
        })
      end)
    end,
  })

  current_branch_job:start()

  -- Get the recently checked out branches
  local recent_branches_job = Job:new({
    command = 'git',
    args = { 'for-each-ref', '--sort=-committerdate', '--format=%(refname:short)', 'refs/heads/' },
    on_exit = function(j)
      local output = j:result()
      vim.schedule(function()
        -- Parse the output to extract the branch names
        local branches = {}
        for _, branch in ipairs(output) do
          if branch then
            table.insert(branches, branch)
          end
        end

        -- Add the recently checked out branches to the buffer's lines
        vim.api.nvim_buf_set_lines(dashboard.bufnr, -1, -1, false, {
          'Recently checked out branches:',
        })
        vim.api.nvim_buf_set_lines(dashboard.bufnr, -1, -1, false, branches)
      end)
    end,
  })

  recent_branches_job:start()

  -- Key mappings
  dashboard:map('n', 'b', ":lua require('graphite.keybinds'):open_branch_keybinds_window()<CR>")
  dashboard:map('n', 'C', ":lua require('graphite.commands'):gt_changelog()<CR>")
  dashboard:map('n', 'l', ":lua require('graphite.keybinds'):open_log_keybinds_window()<CR>")
  dashboard:map('n', 's', ":lua require('graphite.commands'):gt_status()<CR>")
  dashboard:map('n', 'u', ":lua require('graphite.keybinds'):open_upstack_keybinds_window()<CR>")
  dashboard:map('n', 'q', function()
    Dashboard:close_dashboard_window()
  end)
  dashboard:map('n', 'd', ":lua require('graphite.keybinds').open_downstack_keybinds_window()<CR>")
end

-- Define a function to close the dashboard window
function Dashboard:close_dashboard_window()
  -- Check if the current window is the last window
  local is_last_window = vim.fn.tabpagenr('$') == 1 and vim.fn.winnr('$') == 1

  -- Close the window if it's not the last window, otherwise close the tab
  if not is_last_window then
    vim.api.nvim_win_close(0, false)
  else
    vim.cmd('tabclose')
  end
  vim.cmd('autocmd! BufEnter <buffer=' .. self.dashboard_bufnr .. '>')
end

-- Define a function to launch the Graphite dashboard
vim.cmd('command! -nargs=? Graphite lua require("graphite").graphite_command(<f-args>)')

function Dashboard:refresh_dashboard()
  -- Clear the buffer
  vim.api.nvim_buf_set_lines(self.dashboard_bufnr, 0, -1, false, {})

  -- Get the currently checked out branch
  local current_branch_job = Job:new({
    command = 'git',
    args = { 'rev-parse', '--abbrev-ref', 'HEAD' },
    on_exit = function(j)
      local output = j:result()
      vim.schedule(function()
        -- Set the buffer's lines to the keybind hints
        vim.api.nvim_buf_set_lines(self.dashboard_bufnr, 0, -1, false, {
          'Currently checked out branch: ' .. output[1],
        })
      end)
    end,
  })

  current_branch_job:start()

  -- Get the recently checked out branches
  local recent_branches_job = Job:new({
    command = 'git',
    args = { 'for-each-ref', '--sort=-committerdate', '--format=%(refname:short)', 'refs/heads/' },
    on_exit = function(j)
      local output = j:result()
      vim.schedule(function()
        -- Parse the output to extract the branch names
        local branches = {}
        for _, branch in ipairs(output) do
          if branch then
            table.insert(branches, branch)
          end
        end

        -- Add the recently checked out branches to the buffer's lines
        vim.api.nvim_buf_set_lines(self.dashboard_bufnr, -1, -1, false, {
          'Recently checked out branches:',
        })
        vim.api.nvim_buf_set_lines(self.dashboard_bufnr, -1, -1, false, branches)
      end)
    end,
  })

  recent_branches_job:start()
end

return Dashboard
