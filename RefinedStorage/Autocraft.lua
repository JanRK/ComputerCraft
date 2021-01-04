-- Refined Storage Autocraft for Computercraft/CC Tweaked 1.0
--
-- Run the program with the pathname of the crafts' listing file 
-- Crafts file (a craft per line): [item_name] [count]
-- File example: https://pastebin.com/aYEFe7ic
--
-- Needs the following mod, since CC cannot natively talk to RS
-- Refined Storage for ComputerCraft
-- https://github.com/uecasm/rs4cc
--
-- Created by SuperZorro
-- Inspired and borrowed code from Nyhillius and thraaawn

-- How long to wait between crafts.
local waittime = 300


local function load_file(fileName)
    local crafts = {}

    local craftfile = fs.open(fileName, "r" )
    for line in craftfile.readLine do
        local n, c, l, f = line:match "(%S+)%s+(%d+)"
        l = n:match "(%u%S+)"
        f = n:match("(%l+:%l+)")
        if (l) then
            table.insert(crafts, { name = f, label = l, count = c, fullName = n })
        else
            table.insert(crafts, { name = f, count = c, fullName = n })
        end
    end
    return crafts
end

local function file_exist(path)
    if (not (fs.exists(path))) then
        print("[ERROR]: No such file: " .. path .. ".")
        error()
        return false
    end
    return true
end


args = {...}
fileName = args[1]

file_exist(fileName)

local rs = peripheral.find("refinedstorage4computercraft:peripheral")

if (not rs) then
    print("[ERROR]: No refined storage Peripheral found. Place computer next to an refinedstorage4computercraft:peripheral.")
    error()
    return false
end


while(true) do
    local crafts = load_file(fileName)
    -- print(textutils.serialize(crafts))
    for i,craft in ipairs(crafts) do
        a = {}
        k = "name"
        a[k] = craft["fullName"]
        if(rs.hasPattern(a)) then
            local rsStack = rs.getItem(a)
            local rsStackCount = tonumber(rsStack["count"])
            local toCraft = tonumber(craft["count"])

            if(rsStack["count"]) then
                toCraft = toCraft - rsStackCount
            end

            if(toCraft ~= 0) then
                if(toCraft > 0) then

                    AlreadyCrafting = false
                    local currentTasks = rs.getTasks()
                    for k,v in pairs(currentTasks) do
                        -- print(v.stack.item.name)
                        if v.stack.item.name == craft["fullName"] then
                            print(v.stack.item.name)
                            AlreadyCrafting = true
                        end
                    end

                    if AlreadyCrafting == false do
                        print("Crafting: " .. toCraft, craft["fullName"] .. "\n")
                        rs.scheduleTask(a, toCraft)
                    else
                        print("Skipping crafting: " .. craft["fullName"] .. "\n")
                    end
                end
            end
        else
            print("Missing pattern for: " .. craft.name)
        end
    end
    sleep(waittime)
end