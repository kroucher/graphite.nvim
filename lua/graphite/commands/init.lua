local Windows = require('graphite.windows')
local Job = require('plenary.job')
local Input = require('nui.input')
local Menu = require('nui.menu')
local dashboard = require('graphite.dashboard')
local utils = require('graphite.utils')

local Commands = {}

-- Define the commands table
local gt = {
  changelog = { 'changelog' },
  log = { 'log' },
  log_short = { 'log', 'short' },
  log_long = { 'log', 'long' },
  branch_info = { 'branch', 'info' },
  branch_create = { 'branch', 'create' },
  branch_top = { 'branch', 'top' },
  branch_bottom = { 'branch', 'bottom' },
  branch_up = { 'branch', 'up' },
  branch_down = { 'branch', 'down' },
  commit_create = { 'commit', 'create' },
  commit_amend = { 'commit', 'amend' },
  status = { 'status' },
  upstack_onto = { 'upstack', 'onto' },
  upstack_restack = { 'upstack', 'restack' },
  downstack_get = { 'downstack', 'get' },
}

-- Define a function for each Graphite CLI command
function Commands:open_docs()
  utils:get_url('https://graphite.dev/docs/getting-started-with-graphite')
end

function Commands:gt_status()
  Commands:run_command(gt.status, {}, true)
end

function Commands:gt_log()
  Commands:run_command(gt.log, {}, true)
end

function Commands:gt_log_short()
  Commands:run_command(gt.log_short, {}, true)
end

function Commands:gt_log_long()
  Commands:run_command(gt.log_long, {}, true)
end

function Commands:gt_branch_bottom()
  Commands:run_command(gt.branch_bottom, {}, false)
end

function Commands:gt_branch_top()
  Commands:run_command(gt.branch_top, {}, false)
end

function Commands:gt_branch_down()
  Commands:run_command(gt.branch_down, {}, false)
end

function Commands:gt_branch_up()
  local branches = {}
  local error_message = 'ERROR: Cannot get upstack branch in non-interactive mode; multiple choices available:'
  local current_branch = vim.fn.system('git rev-parse --abbrev-ref HEAD'):gsub('\n', '')
  local job = Job:new({
    command = 'gt',
    args = { 'branch', 'up', '--no-interactive' },
  })

  job:sync()

  local output = job:result()
  if vim.tbl_contains(output, 'Checked out') then
    vim.notify(output, vim.log.levels.INFO, {})
  elseif vim.tbl_contains(output, error_message) then
    print('found error')
    for _, line in ipairs(output) do
      -- if line is not the current branch and not the error message, add it to the branches table
      if line ~= current_branch and line ~= error_message then
        table.insert(branches, Menu.item(line))
      end
    end

    if #branches > 0 then
      vim.notify('Multiple branches found at the same level. Select a branch to guide the navigation', vim.log.levels.INFO, {})
      -- Create a menu containing the branch names
      local menu = Menu({
        relative = 'editor',
        border = {
          style = 'rounded',
          text = {
            top = '[Select a branch to move up to:]',
            top_align = 'center',
          },
        },
        size = {
          width = '30%',
          height = '20%',
        },
        position = '50%',
      }, {
        lines = branches,
        on_close = function()
          print('Menu closed')
        end,
        on_submit = function(item)
          local output_inner = vim.fn.system('gt branch checkout ' .. item.text)
          local exit_code = vim.v.shell_error
          if exit_code == 0 then
            vim.notify('Checked out branch: ' .. item.text, vim.log.levels.INFO, {})
            -- focus the dashboard window
            vim.api.nvim_set_current_win(dashboard.winid)
          else
            vim.notify('Error checking out branch: ' .. item.text .. '\nOutput: ' .. output_inner, vim.log.levels.ERROR, {})
          end
        end,
      })
      -- Open the menu
      menu:mount()
    end
  end
end

function Commands:gt_branch_info()
  Commands:run_command(gt.branch_info, {}, true)
end

function Commands:gt_changelog()
  Commands:run_command(gt.changelog, {}, true)
end

function Commands:gt_upstack_restack()
  Commands:run_command(gt.upstack_restack)
end

function Commands:gt_downstack_get(branch_name, force)
  local args = gt.downstack_get
  if branch_name then
    table.insert(args, branch_name)
  end
  if force then
    table.insert(args, '--force')
  end

  local error_messages = {
    ['ERROR: There are tracked changes that have not been committed. Please resolve and then retry.'] = 'Error: You have uncommitted changes\nthat would be overwritten by\nchecking out this branch.\nPlease commit your changes or stash\nthem before you switch branches.',
  }

  Commands:run_command(args, error_messages, false)
end

-- Define a function to run a Graphite command
function Commands:run_command(args, error_messages, output_to_buffer)
  local job = Job:new({
    command = 'gt',
    args = args,
    on_exit = function(j)
      local output = j:result()
      local exit_code = j.code
      vim.schedule(function()
        if exit_code == 0 then
          -- The command succeeded
          if output_to_buffer then
            -- Create a new window for the buffer
            local command = Windows:create_window('gt_' .. table.concat(args, '_'), '[q] Return to Dashboard')

            -- Set the buffer's lines to the output of the command
            vim.api.nvim_buf_set_lines(command.bufnr, 0, -1, false, output)

            -- Set the buffer's options
            vim.api.nvim_buf_set_option(command.bufnr, 'modifiable', false)
            vim.api.nvim_buf_set_option(command.bufnr, 'bufhidden', 'hide')

            -- Key mappings
            command:map('n', 'q', function()
              if vim.fn.tabpagenr('$') == 1 and vim.fn.winnr('$') == 1 then
                vim.cmd('quit')
              else
                command:unmount()
              end
            end)
          else
            -- Print a success message
            vim.notify(output, vim.log.levels.INFO, {})
          end
        else
          -- The command failed
          local output_str = table.concat(output, '\n')
          for error_output, error_message in pairs(error_messages) do
            if string.find(output_str, error_output) then
              -- The output contains a known error message, display the corresponding notification
              vim.notify(error_message, vim.log.levels.ERROR, {})
              return
            end
          end
          -- The output contains an unknown error message, display a generic notification
          vim.notify('Error executing: gt ' .. table.concat(args, ' ') .. '\nOutput: ' .. output_str, vim.log.levels.ERROR, {})
        end
      end)
    end,
  })

  job:start()
end

function Commands:gt_branch_checkout()
  local job = Job:new({
    command = 'gt',
    args = gt.log_short,
    on_exit = function(j)
      local output = j:result()
      vim.schedule(function()
        -- Parse the output to extract the branch names
        local branches = {}
        for _, line in ipairs(output) do
          local branch = line:match('[◯│◉─┘%s]+(.*)')
          if branch and #branch > 0 then
            -- Add the line to the branches table
            table.insert(branches, line)
          end
        end

        -- Add instructions to the branches table
        table.insert(branches, '')
        table.insert(branches, '')
        table.insert(branches, 'Use the arrow keys to navigate, press Enter to select a branch, and press q to close this window.')

        -- Create a new buffer
        local branch_checkout_buf = Windows:create_window('gt branch checkout')

        -- Set the buffer's lines to the branch names
        vim.api.nvim_buf_set_lines(branch_checkout_buf.bufnr, 0, -1, false, branches)

        -- Set the buffer's options
        vim.api.nvim_buf_set_option(branch_checkout_buf.bufnr, 'modifiable', false)
        vim.api.nvim_buf_set_option(branch_checkout_buf.bufnr, 'bufhidden', 'hide')

        -- Key mappings
        branch_checkout_buf:map('n', 'q', function()
          branch_checkout_buf:unmount()
          vim.api.nvim_set_current_win(self.dashboard_win)
        end)
        branch_checkout_buf:map('n', '<CR>', ":lua require('graphite.commands'):checkout_selected_branch()<CR>")
      end)
    end,
  })

  job:start()
end

function Commands:checkout_selected_branch()
  -- Get the current line in the buffer
  local line = vim.api.nvim_get_current_line()

  -- Extract the branch name from the line
  local branch = line:match('[◯│◉─┘%s]+(.*)')

  -- Store the "(needs restack)" string if it exists
  local needs_restack = branch:match('%s*(%(needs restack%))')

  -- Remove the "(needs restack)" string from the branch name
  branch = branch:gsub('%s*%(needs restack%)', '')

  -- Run the gt branch checkout command with the branch name and capture its output and exit code
  local output = vim.fn.system('gt branch checkout ' .. branch)
  local exit_code = vim.v.shell_error

  -- Check the exit code
  if exit_code == 0 then
    -- The command succeeded, print a message to the console
    vim.notify('Checked out branch: ' .. branch .. ' ' .. (needs_restack or ''), vim.log.levels.INFO, {})
  else
    -- The command failed, check if the output contains the error message about uncommitted changes
    if string.find(output, 'Your local changes to the following files would be overwritten by checkout') then
      -- The error is about uncommitted changes, handle it gracefully
      vim.notify('Error: You have uncommitted changes\nthat would be overwritten by\nchecking out this branch.\nPlease commit your changes or stash\nthem before you switch branches.', vim.log.levels.ERROR, {})
    else
      -- The error is something else, print the output
      vim.notify('Error checking out branch: ' .. branch .. '\nOutput: ' .. output, vim.log.levels.ERROR, {})
    end
  end

  -- Close the window
  vim.api.nvim_win_close(0, true)
end

function Commands:handle_branch_create(input)
  -- Run the gt branch create command with the branch name
  local job = Job:new({
    command = 'gt',
    args = { 'branch', 'create', input },
    on_exit = function(j)
      local output = j:result()
      local exit_code = j.code
      vim.schedule(function()
        if exit_code == 0 then
          -- The command succeeded, print a success message
          vim.notify('Successfully created branch: ' .. input, vim.log.levels.INFO, {})
        else
          -- The command failed, print an error message
          vim.notify('Error creating branch: ' .. input .. '\nOutput: ' .. table.concat(output, '\n'), vim.log.levels.ERROR, {})
        end
      end)
    end,
  })

  job:start()
end

function Commands:gt_branch_create()
  local input = Input(Windows:create_input('Create Branch'), {
    prompt = '> ',
    on_submit = function(value)
      self:handle_branch_create(value)
    end,
  })

  input:mount()
end

-- Return the commands table
return Commands
