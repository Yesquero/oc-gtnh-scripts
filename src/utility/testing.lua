local arr = {}
for i = 0, 15,1 do
    arr[i+1] = i
end

for k,v in pairs(arr) do
    local report = tostring(v)
    if 0x8 & v ~= 0 then report = report .. "; 4th bit is set" end
    if 0x4 & v ~= 0 then report = report .. "; 3rd bit is set" end
    if 0x2 & v ~= 0 then report = report .. "; 2nd bit is set" end
    if 0x1 & v ~= 0 then
        report = report .. "; 1st bit is set, "
        local supercondustor = v
        supercondustor = supercondustor >> 1
        supercondustor = supercondustor & 0x3
        report = report .. "interpreted " .. tostring(supercondustor) .. '\n'
    end
    print(report)
end
