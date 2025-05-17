local liquidTransposer = {
    name = "",
    transposer = nil,
    sourceSide = nil,
    sinkSide = nil,
    logActions = true
}

function liquidTransposer:new(name, transposer, sourceSide, sinkSide, logActions, obj)
    obj = obj or {}
    self.__index = self
    setmetatable(obj, self)
    self.name = name
    self.transposer = transposer
    self.sourceSide = sourceSide
    self.sinkSide = sinkSide
    self.logActions = logActions
    return obj
end

function liquidTransposer:addFluid(amount)
    local res, _ = self.transferFluid(self.sourceSide, self.sinkSide, amount)
    if self.logActions and not res then print(self.name .. " -- Error when adding fluid.") end
    return res
end

function liquidTransposer:getSinkLevel()
    return self.transposer.getTankLevel(self.sinkSide)
end

return liquidTransposer
