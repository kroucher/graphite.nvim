local Windows = {}
local Popup = require('nui.popup')

-- @param title string
-- @param hint string
-- @return Popup
-- @example Windows:create_keybinds_window('gt keybinds', 'press q to quit')
function Windows:create_window(title, hint)
  local popup = Popup({
    zindex = 10,
    border = {
      padding = { 1, 1, 1, 1 }, -- optional
      style = 'rounded',
      text = { top = title, top_align = 'center', bottom = hint, bottom_align = 'center' },
    },
    relative = 'editor',
    position = '50%',
    size = {
      width = '70%',
      height = '70%',
    },
    enter = true,
    focusable = true,
    buf_options = {
      modifiable = true,
      readonly = false,
    },
  })

  popup:mount()

  return popup
end

-- @param title string
-- @return Popup
-- @example Windows:keybinds_window('gt keybinds')
function Windows:keybinds_window(title)
  local popup = Popup({
    border = {
      padding = { 1, 1, 1, 1 }, -- optional
      style = 'rounded',
      text = { top = title, top_align = 'center' },
    },
    relative = 'editor',
    position = {
      row = '80%',
      col = '0%',
    },
    size = {
      width = '30%',
      height = '20%',
    },
    enter = true,
    focusable = true,
    buf_options = {
      modifiable = true,
      readonly = false,
    },
  })

  popup:mount()

  return popup
end

function Windows:create_input(title)
  print('create_input' .. title)
  local input = {
    border = {
      style = 'rounded',
      text = {
        top = title,
        top_align = 'center',
      },
    },
    relative = 'editor',
    position = '50%',
    size = {
      width = 40,
      height = 2,
    },
  }

  return input
end

return Windows
