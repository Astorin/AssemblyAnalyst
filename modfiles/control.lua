math2d = require("math2d")  -- base game lualib

require("scripts.data")
require("scripts.handler")
require("scripts.events")
require("scripts.gui")

require("scripts.Zone")
require("scripts.Schedule")
require("scripts.Entity")

DEVMODE = true  -- Enables certain conveniences for development
REDRAW_CYCLE_RATE = 120

if DEVMODE then
    require("lualib.llog")
    LLOG_EXCLUDES = {}
end