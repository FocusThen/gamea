local tableUtils = require("src.core.utils.table")
local fsUtils = require("src.core.utils.fs")

return {
	table = tableUtils,
	fs = fsUtils,
	deepCopy = tableUtils.deepCopy,
	countLevels = fsUtils.countLevels,
}

