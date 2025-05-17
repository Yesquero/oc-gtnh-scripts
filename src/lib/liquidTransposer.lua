local LiquidTransposer = {}

LiquidTransposer.__index = LiquidTransposer

function LiquidTransposer:new(name, transposer, sourceSide, sinkSide, logActions)
    local instance = {
        name = name or "",
        transposer = transposer,
        sourceSide = sourceSide,
        sinkSide = sinkSide,
        logActions = logActions or true
    }
    setmetatable(instance, self)
    return instance
end

function LiquidTransposer:addFluid(amount)
    local res, _ = self.transposer.transferFluid(self.sourceSide, self.sinkSide, amount)
    if self.logActions and not res then print(self.name .. " -- Error when adding fluid.") end
    return res
end

function LiquidTransposer:getSinkLevel()
    return self.transposer.getTankLevel(self.sinkSide)
end

return LiquidTransposer
