--- For overriding Common version in custom scripts directory
local prev = package.path

package.path = _G.SCRIPT_PATH .. "?.lua;" .. prev

require("ModernUOL")

package.path = prev
