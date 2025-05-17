local component = require("component")
local term = require("term")
local event = require("event")
local sides = require("sides")

local targetAmount = 900000
local transposer = component.transposer

local function supplyCatalyst(source, sink, amount)
	local transferred = 0

	while transferred < amount do
		-- seems to transfer ~ 1k per operation ?
		local res, val = transposer.transferFluid(source, sink, 10000)

		if res ~= true then
			print("Fluid transfer error.")
			return
		end

		transferred = transferred + val
		if transferred % 100000 == 0 then print("Transferred " .. transferred .. " catalyst") end
	end
end

while true do
	local _, _, _, oldValue, newValue = event.pull("redstone_changed")
	if oldValue == 0 and newValue == 1 then
		term.clear()
		print("Supplying catalyst...")

		if transposer.getTankLevel(sides.east) > 0 and transposer.getTankLevel(sides.top) == 0 then
			supplyCatalyst(sides.east, sides.top, targetAmount)
			print("Finished supplying catalyst.")
		else
			print("No catalyst available or Input Hatch already filled.")
		end
	end
end
