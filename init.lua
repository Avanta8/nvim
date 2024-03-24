require("core.options")
require("core.autocmds")
require("core.keymaps")
require("core.lazy")

RELOAD = function(...)
  return require("plenary.reload").reload_module(...)
end

R = function(name)
  RELOAD(name)
  return require(name)
end
