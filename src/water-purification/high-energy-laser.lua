--[[
    lens order
    orundum -> amber -> aer -> emerald -> mana diamond -> blue topaz -> amethyst -> fluor-bergerite -> dilithium
]]
local component = require("component")
local sides = require("sides")
local term = require("term")

local ItemTransposer = require("itemTransposer")
local LensControl = require("lensControl")

local transposer = component.proxy("id")
local source, sink = sides.down, sides.top
local controller = component.gt_machine
local rsHatch = component.proxy("id")
local rsSide = sides.down

local itemTransposer = ItemTransposer:new(transposer, source, sink)
local lensControl = LensControl:new(itemTransposer, controller, rsHatch, rsSide, true)

lensControl:lensInit()
lensControl:workLoop(term)
