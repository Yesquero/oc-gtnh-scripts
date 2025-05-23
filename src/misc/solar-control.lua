local component = require("component")
local term = require("term")
local sides = require("sides")

local heatLevel = 0
local pollingInterval = 10
local signalSide = sides.west
local minHeatLevel = 50000

while true do
term.clear()

heatLevel = tonumber(string.match(component.gt_machine.getSensorInformation()[2], '%S+$'))
print("Heat level: ".. heatLevel)

if heatLevel >= minHeatLevel then
  print("Heat level >= 50k, redstone ON")
  component.redstone.setOutput(signalSide, 16)
else
  print("Heat level < 50k, redstone OFF")
  component.redstone.setOutput(signalSide, 0)
end

os.sleep(pollingInterval)
end