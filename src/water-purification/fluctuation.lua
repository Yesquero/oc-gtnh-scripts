local sides = require("sides")
local component = require("component")
local term = require("term")

local plasmaTs = component.proxy("id")
local coolantTs = component.proxy("id")
local controller = component.gt_machine

local function doStuff()

end

-- main loop
while true do
    if controller.isMachineActive() then
        doStuff()
    else
---@diagnostic disable-next-line: undefined-field
        os.sleep(10)
    end
end