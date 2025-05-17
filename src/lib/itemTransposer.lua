local ItemTransposer = {
    name = "ItemTransposer - "
}

ItemTransposer.__index = ItemTransposer

local function isItemStackEmpty(itemStack)
    return itemStack and itemStack.name == nil
end

function ItemTransposer:new(transposer, source, sink, logActions)
    local itemTransposer = {
        transposer = transposer,
        source = source,
        sink = sink,
        logActions = logActions or false
    }
    setmetatable(itemTransposer, self)
    return itemTransposer
end

function ItemTransposer:sourceItemsIt()
    return self.transposer.getAllStacks(self.source)
end

function ItemTransposer:sinkItemsIt()
    return self.transposer.getAllStacks(self.sink)
end

function ItemTransposer:isSinkEmpty()
    for elem in self.transposer.getAllStacks(self.sink) do
        if not isItemStackEmpty(elem) then return false end
    end
    return true
end

function ItemTransposer:firstMatch(side, comparator)
    if side ~= self.source and side ~= self.sink then error("Invalid side", 2) end

    local index = -1; local ctr = 1
    for elem in self.transposer.getAllStacks(side) do
        if comparator(elem) then
            index = ctr; break
        end
        ctr = ctr + 1
    end
    return index, self.transposer.getAllStacks(side)[index]
end

-- Transfer amount of item with given label to either sink or source, denoted by first argumnet
function ItemTransposer:transferToByLabel(side, label, amount)
    if type(side) ~= "number" then error("Expected number", 2) end

    local src, dst
    if side == self.source then
        src = self.sink; dst = self.source
    elseif side == self.sink then
        src = self.source; dst = self.sink
    else
        error("Invalid side: " .. tostring(side), 2)
    end

    local cmp = function(elem) return elem and elem.label == label end

    local srcInd, _ = self:firstMatch(src, cmp)
    if srcInd == -1 then return false, 0, "Item with given label not found" end

    local dstInd, _ = self:firstMatch(dst, isItemStackEmpty)
    if dstInd == -1 then return false, 0, "No free slots available in destinatin" end

    local res = self.transposer.transferItem(src, dst, amount, srcInd, dstInd)
    return res == amount, res, ""
end

-- Move item with given label from sink to source to first available free slot
function ItemTransposer:sourceDepositByLabel(label, amount)
    if self.logActions then print(self.name .. "deposit into source: " .. label .. amount) end
    return self:transferToByLabel(self.source, label, amount)
end

-- Move item with given label from source to sink to first availabel free slot
function ItemTransposer:sinkDepositByLabel(label, amount)
    if self.logActions then print(self.name .. "deposit into sink: " .. label .. amount) end
    return self:transferToByLabel(self.sink, label, amount)
end

function ItemTransposer:emptySink()
    for elem in self.transposer.getAllStacks(self.sink) do
        if not isItemStackEmpty(elem) then
            local res, _, msg = self:sourceDepositByLabel(elem.label, elem.size)
            if not res then return res, msg end
        end
    end
    return true, ""
end

return ItemTransposer
