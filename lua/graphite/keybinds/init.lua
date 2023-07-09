local Windows = require('graphite.windows')
local Commands = require('graphite.commands')
local Input = require('nui.input')

local Keybinds = {}

function Keybinds:create_keybinds_window(title, keybinds)
  local popup = Windows:keybinds_window(title)
  -- Set the buffer contents to the keybinds
  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, keybinds)

  return popup
end

function Keybinds:open_log_keybinds_window()
  local keybinds = {
    'Log keybinds:',
    '[<CR>] log',
    '[s] log short',
    '[l] log long',
  }

  local log_window = Windows:keybinds_window('gt log keybinds')
  vim.api.nvim_buf_set_lines(log_window.bufnr, 0, -1, false, keybinds)

  local opts = { noremap = true, silent = true }

  log_window:map('n', '<CR>', function()
    Commands:gt_log()
    log_window:unmount()
  end, opts)

  log_window:map('n', 's', function()
    Commands:gt_log_short()
    log_window:unmount()
  end, opts)

  log_window:map('n', 'l', function()
    Commands:gt_log_long()
    log_window:unmount()
  end, opts)

  log_window:map('n', 'q', function()
    if vim.fn.tabpagenr('$') == 1 and vim.fn.winnr('$') == 1 then
      vim.cmd('quit')
    else
      log_window:unmount()
    end
  end, opts)
end

function Keybinds:open_branch_keybinds_window()
  local keybinds = {
    'Branch keybinds:',
    '[<CR>] branch checkout',
    '[c] branch create',
    '[i] branch info',
    '[b] branch bottom',
    '[t] branch top',
    '[d] branch down',
    '[u] branch up',
  }

  local branch_window = Windows:keybinds_window('gt branch')
  vim.api.nvim_buf_set_lines(branch_window.bufnr, 0, -1, false, keybinds)
  local opts = { noremap = true, silent = true }

  branch_window:map('n', '<CR>', function()
    Commands:gt_branch_checkout()
    branch_window:unmount()
  end, opts)

  branch_window:map('n', 'c', function()
    branch_window:unmount()
    Commands:gt_branch_create()
  end, opts)

  branch_window:map('n', 'i', function()
    Commands:gt_branch_info()
    branch_window:unmount()
  end, opts)

  branch_window:map('n', 'b', function()
    Commands:gt_branch_bottom()
    branch_window:unmount()
  end, opts)

  branch_window:map('n', 't', function()
    Commands:gt_branch_top()
    branch_window:unmount()
  end, opts)

  branch_window:map('n', 'd', function()
    Commands:gt_branch_down()
    branch_window:unmount()
  end, opts)

  branch_window:map('n', 'u', function()
    Commands:gt_branch_up()
    branch_window:unmount()
  end, opts)

  branch_window:map('n', 'q', function()
    if vim.fn.tabpagenr('$') == 1 and vim.fn.winnr('$') == 1 then
      vim.cmd('quit')
    else
      branch_window:unmount()
    end
  end, opts)
end

function Keybinds:open_upstack_keybinds_window()
  local keybinds = {
    'Upstack keybinds:',
    '[r] restack',
    '[o] upstack onto',
  }

  local upstack_window = Windows:keybinds_window('gt upstack')
  vim.api.nvim_buf_set_lines(upstack_window.bufnr, 0, -1, false, keybinds)

  local opts = { noremap = true, silent = true }

  upstack_window:map('n', 'r', function()
    Commands:gt_upstack_restack()
    upstack_window:unmount()
  end, opts)

  upstack_window:map('n', 'o', function()
    Commands:gt_upstack_onto()
    upstack_window:unmount()
  end, opts)

  upstack_window:map('n', 'q', function()
    if vim.fn.tabpagenr('$') == 1 and vim.fn.winnr('$') == 1 then
      vim.cmd('quit')
    else
      upstack_window:unmount()
    end
  end, opts)
end

function Keybinds:open_downstack_keybinds_window()
  local keybinds = {
    'Downstack keybinds:',
    '[g] downstack get',
    '[b] downstack get with branch name',
    -- Add more downstack commands here
  }

  local downstack_window = Windows:keybinds_window('gt downstack')
  vim.api.nvim_buf_set_lines(downstack_window.bufnr, 0, -1, false, keybinds)
  local opts = { noremap = true, silent = true }

  downstack_window:map('n', 'g', function()
    Commands:gt_downstack_get()
    downstack_window:unmount()
  end, opts)

  downstack_window:map('n', 'b', function()
    downstack_window:unmount()
    local input = Input(Windows:create_input('Enter Branch Name'), {
      prompt = '> ',
      on_submit = function(value)
        Commands:gt_downstack_get(value)
      end,
    })
    input:mount()
  end, opts)

  downstack_window:map('n', 'q', function()
    if vim.fn.tabpagenr('$') == 1 and vim.fn.winnr('$') == 1 then
      vim.cmd('quit')
    else
      downstack_window:unmount()
    end
  end, opts)
end

return Keybinds
