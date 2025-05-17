local sides = require("sides")
local component = require("component")
local term = require("term")

local utility = require("utility")

local function canDoCycle(controller)
    return controller.getWorkMaxProgress() - controller.getWorkProgress() > 30 * 20
end

-- init variables
local plasmaTs = utility.liquidTransposer:new("Plasma TS", component.proxy("id"), sides.down, sides.top)
local coolantTs = utility.liquidTransposer:new("Coolant TS", component.proxy("id"), sides.down, sides.top)
local controller = component.gt_machine

-- main loop
while true do
    term.clear()
    if controller.isMachineActive() then
        if canDoCycle(controller) then
            print("Adding plasma...")
            plasmaTs.addFluid(100)
            ---@diagnostic disable-next-line undefined-field
            os.sleep(10)

            print("Adding coolant...")
            coolantTs.addFluid(2000)
            ---@diagnostic disable-next-line undefined-field
            os.sleep(20)
        else
            local ticksUntilnewCycle = controller.getWorkMaxProgress() - controller.getWorkProgress()
            print("Not enough time for heating/cooling cycle, skipping; (" .. tostring(ticksUntilnewCycle) .. " ticks)")
            ---@diagnostic disable-next-line undefined-field
            os.sleep(ticksUntilnewCycle / 20)
        end
    else
        print("Waiting for machine activity...")
        ---@diagnostic disable-next-line: undefined-field
        os.sleep(10)
    end
end
