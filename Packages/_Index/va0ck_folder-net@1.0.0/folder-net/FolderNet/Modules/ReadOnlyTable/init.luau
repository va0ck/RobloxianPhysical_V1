--[[Module]]
local function errorOnIndex(_, index)
	error(string.format("Bad index %q", tostring(index)), 2)
end

local READ_ONLY_METATABLE = {
	__index = errorOnIndex;
	__newindex = errorOnIndex;
}

return function(target)
	return setmetatable(target, READ_ONLY_METATABLE)
end