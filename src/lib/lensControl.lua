local event = require("event")
local itemTransposerClass = require("itemTransposer")

local LensControl = {
    name = "LensControl - ",
    itemTransposer = itemTransposerClass
}

LensControl.__index = LensControl

local lensOrder = {
    [1] = { label = "Orundum Lens", available = false },
    [2] = { label = "Amber Lens", available = false },
    [3] = { label = "Aer Lens", available = false },
    [4] = { label = "Emerald Lens", available = false },
    [5] = { label = "Mana Diamond Lens", available = false },
    [6] = { label = "Blue Topaz Lens", available = false },
    [7] = { label = "Amethyst Lens", available = false },
    [8] = { label = "Fluor-Buergerite Lens", available = false },
    [9] = { label = "Dilithium Lens", available = false },
}

local lensLookup = {}
for i = 1, #lensOrder do lensLookup[lensOrder[i].label] = i end

function LensControl:new(itemTransposer, gtController, rstIO, rsSide, logActions, signalTimeout, machineTimeout)
    local lensControl = {
        itemTransposer = itemTransposer,
        gtController = gtController,
        rstIO = rstIO,
        rsSide = rsSide,
        logActions = logActions or false,
        currentLens = 1,
        lastLens = 0,
        lensOrder = lensOrder,
        lensLookup = lensLookup,
        signalTimeout = signalTimeout or 15,
        machineTimeout = machineTimeout or 10
    }
    setmetatable(lensControl, self)
    return lensControl
end

-- Swap current lens with the next one
function LensControl:nextLens()
    if self.currentLens == 9 then error(self.name .. "next lens called on last lens") end

    local res, _, msg = self.itemTransposer:sourceDepositByLabel(self:getCurrentLens().label, 1)
    if not res then error(self.name .. "failed to remove lens " .. msg) end

    self.currentLens = self.currentLens + 1
    res, _, msg = self.itemTransposer:sinkDepositByLabel(self:getCurrentLens().label, 1)
    if not res then error(self.name .. "failed to deposit new lens " .. msg) end

    local ticks = self.gtController.getWorkProgress()
    if self.logActions then
        print(self.name .. ticks / 20 .. " sec(s) -  swapped lenses: " ..
            self.lensOrder[self.currentLens - 1].label .. " -> " .. self.lensOrder[self.currentLens].label)
    end
end

-- Empty lens sink and set current lens to 1
function LensControl:resetLens()
    if not self.itemTransposer:isSinkEmpty() then
        local res, msg = self.itemTransposer:emptySink()
        if not res then error(self.name .. "error when resetting lens: " .. msg) end
    end

    self.currentLens = 1
    local res, _, msg = self.itemTransposer:sinkDepositByLabel(self:getCurrentLens().label, 1)
    if not res then error(self.name .. "resetting lens error: failed to insert lens " .. msg) end

    if self.logActions then print(self.name .. "reset lens") end
end

-- Get current lens {label, available}
function LensControl:getCurrentLens()
    return self.lensOrder[self.currentLens]
end

-- Check if we are on last available lens
function LensControl:isLastLens()
    return self.lastLens == self.currentLens
end

-- Detect maximum consequtive available lenses
function LensControl:lensInit()
    for item in self.itemTransposer:sourceItemsIt() do
        if self.lensLookup[item.label] ~= nil then
            self.lensOrder[self.lensLookup[item.label]].available = true
        end
    end
    for i = 1, #self.lensOrder do if self.lensOrder[i].available then self.lastLens = math.max(self.lastLens, i) end end

    if self.lastLens == 0 then error(self.name .. "no lenses available in item source.") end

    if self.logActions then
        print("Lenses available: " .. self.lastLens)
        for i = 1, #lensOrder do
            if lensOrder[i].available then print(lensOrder[i].label) end
        end
    end
end

-- Sleep until next machine cycle
function LensControl:wainUntilNextCycle()
    if self.gtController.getWorkProgress() < 3 * 20 then return end -- if main loop finished on last work tick and we could not check it in time

    local ticks = self.gtController.getWorkMaxProgress() - self.gtController.getWorkProgress()
    if self.logActions then print(self.name .. "sleeping until next work cycle(ticks): " .. tostring(ticks)) end
    ---@diagnostic disable-next-line undefined-field
    os.sleep(ticks / 20)
end

-- Check if we are NOT on last available lens and there is enough time to swap and wait max possible lens signal timeout
function LensControl:isEnoughTimeForLensCycle()
    local ticks = self.gtController.getWorkMaxProgress() - self.gtController.getWorkProgress()
    return ticks > self.signalTimeout * 20 and not self:isLastLens()
end

-- Main process loop
function LensControl:workLoop(term)
    while true do
        if self.gtController.isMachineActive() then
            term.clear()

            if self.logActions then
                print(self.name ..
                    "started main loop on tick: " .. self.gtController.getWorkProgress())
            end

            self:resetLens()
            ---@diagnostic disable-next-line undefined-field
            os.sleep(1) -- sleep a bit so we dont pull redstone event triggered by incorrect lens at startup

            local lastSwap = 0
            -- inner loop, waits for signal from hatch
            while self:isEnoughTimeForLensCycle() do
                if self.logActions then print(self.name .. "waiting for lens swap signal...") end

                local res, _, _ = event.pull(self.signalTimeout, "redstone_changed", self.rstIO.address, self.rsSide)
                if res ~= nil then
                    self:nextLens()

                    local ticks = self.gtController.getWorkProgress()
                    if self.logActions then
                        print(self.name .. (ticks - lastSwap) / 20 .. " sec(s) since last lens swap")
                    end
                    lastSwap = ticks

                    ---@diagnostic disable-next-line undefined-field
                    os.sleep(1) -- sleep a bit so we dont pull redstone change on signal deactivation (?)
                else
                    if self.logActions then print(self.name .. "lens swap signal timeout") end
                    break
                end
            end
            self:wainUntilNextCycle()
        else
            if self.logActions then print(self.name .. "waiting for machine activity...") end
            ---@diagnostic disable-next-line undefined-field
            os.sleep(self.machineTimeout)
        end
    end
end

return LensControl
