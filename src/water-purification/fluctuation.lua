local sides = require("sides")
local component = require("component")
local term = require("term")

local LiquidTransposer = require("liquidTransposer")

local function canDoCycle(controller)
    return controller.getWorkMaxProgress() - controller.getWorkProgress() > 30 * 20
end

-- init variables
local plasmaTs = LiquidTransposer:new("Plasma TS", component.proxy("id"), sides.down, sides.top)
local coolantTs = LiquidTransposer:new("Coolant TS", component.proxy("id"), sides.down, sides.top)
local controller = component.gt_machine

-- main loop
while true do
    term.clear()
    if controller.isMachineActive() then
        if canDoCycle(controller) then
            print("Started work on tick: " .. tostring(controller.getWorkProgress()))

            -- TODO: sleep for 5-10 ticks less than needed and the wait by checking tank level directly, else cant fit 4 cycles in 120s

            print("Adding plasma...")
            plasmaTs:addFluid(100)
            ---@diagnostic disable-next-line undefined-field
            os.sleep(10)

            print("Adding coolant...")
            coolantTs:addFluid(2000)
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
