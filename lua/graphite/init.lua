local Graphite = {}
local Notify = require('notify')
-- Import the modules
Graphite.Commands = require('graphite.commands')
Graphite.Keybinds = require('graphite.keybinds')
Graphite.Windows = require('graphite.windows')
Graphite.Dashboard = require('graphite.dashboard')

Notify.setup({
  background_colour = '#000000',
})

-- Define the notification plugin
vim.notify = Notify

-- Define a function to handle the Graphite command
function Graphite:graphite_command(arg)
  if arg == nil then
    -- If no argument is passed, open the Graphite dashboard
    Graphite.Dashboard:launch_dashboard()
  else
    -- If an argument is passed, run the corresponding Graphite command
    local command = 'gt_' .. arg
    if Graphite[command] then
      Graphite[command]()
    else
      print('Unknown command: ' .. arg)
    end
  end
end

-- Return the plugin namespace

return Graphite
