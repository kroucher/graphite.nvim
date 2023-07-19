local utils = {}

-- Attempts to open a given URL in the system default browser, regardless of Operating System.
local open_cmd -- this needs to stay outside the function, or it'll re-sniff every time...
function utils:get_url(url)
  if not open_cmd then
    if package.config:sub(1, 1) == '\\' then -- windows
      print('windows')
      open_cmd = function(windows_url)
        os.execute(string.format('start "%s"', windows_url))
      end
    elseif vim.fn.system('uname'):find('Darwin') then -- mac
      open_cmd = function(osx_url)
        os.execute(string.format('open "%s"', osx_url))
      end
    else
      open_cmd = function(nix_url)
        os.execute(string.format('xdg-open "%s"', nix_url))
      end
    end
  end

  open_cmd(url)
end

return utils
