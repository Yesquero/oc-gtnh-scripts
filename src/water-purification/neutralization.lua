local component = require("component")
local term = require("term")
local sides = require("sides")

local function lowerPh(transposer, sourceSide, sinkSide)
	-- insert 50L HCl if input is empty
	if transposer.getTankLevel(sinkSide) == 0 then
		local res, _ = transposer.transferFluid(sourceSide, sinkSide, 50)
		if not res then print("Error when transfering HCl") end
	else
		print("Input hatch already filled with HCl")
	end
end

local function raisePh(transposer, sourceSide, sinkSide, sourceSlot, sinkSlot)
	-- insert 5 sodium hydroxide if input is empty
	local inputStack = transposer.getStackInSlot(sides.down, 1)
	if inputStack ~= nil and inputStack.size ~= 0 then
		print("Input bus already contains Sodium Hydroxide")
	else
		local res = transposer.transferItem(sourceSide, sinkSide, 5, sourceSlot, sinkSlot)
		if not res then print("Error when transfering Sodium Hydroxide") end
	end
end

local rstPhLower = component.proxy("id")
local rstPhHighier = component.proxy("id")
local hclTransposer = component.proxy("id")
local sodiumTransposer = component.proxy("id")

while true do
	term.clear()
	if rstPhLower.getInput(sides.top) ~= 0 then
		print("raising pH...")
		raisePh(sodiumTransposer, sides.north, sides.down, 1, 1)
	elseif rstPhHighier.getInput(sides.top) ~= 0 then
		print("lowering pH...")
		lowerPh(hclTransposer, sides.north, sides.down)
	else
		print("pH within target range")
	end
	---@diagnostic disable-next-line undefined-field
	os.sleep(1)
end
