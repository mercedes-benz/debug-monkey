-- (c) 2023 Mercedes-Benz Tech Innovation GmbH
-- SPDX-License-Identifier: MIT

local socket = require('socket')

local kong = kong
local plugin = {
  PRIORITY = 100000, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}

-- handles more initialization, but AFTER the worker process has been forked/created.
-- It runs in the 'init_worker_by_lua_block'
function plugin:init_worker(self)
  kong.log.debug("preparing emmy debugger: loading shared object")
  package.cpath = package.cpath .. ';/usr/local/emmy/?.so'
  local dbg = require('emmy_core')

  local config
  for plugin, err in kong.db.plugins:each(nil, { show_ws_id = false }) do
    if err then return nil, err end -- TODO error handling
    if plugin.name == 'debug-monkey' then
      config = plugin.config
    end
  end

  _G.emmy = {}
  _G.emmy.fixPath = function(path)
    oldPath = path
    for _, replacement in ipairs(config.path_replacements) do
      path = string.gsub(path, replacement.container_path, replacement.host_path)
    end
    return path
  end

  kong.log.debug("preparing emmy debugger: connecting to IDE on "..config.host..":"..config.port)
  local ip, err = socket.dns.toip(config.host)
  if not ip and err then
    kong.log.err("preparing emmy debugger: could not resolve hostname "..config.host..": "..err)
    return
  end
  dbg.tcpConnect(ip, config.port)
  kong.log.debug("preparing emmy debugger: finished")
end

-- return our plugin object
return plugin
