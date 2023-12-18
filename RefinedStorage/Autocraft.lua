-- Refined Storage Autocraft for Computercraft/CC Tweaked 1.0
--
-- Run the program with the pathname of the crafts' listing file 
-- Crafts file (a craft per line): [item_name] [count]
-- File example: https://pastebin.com/aYEFe7ic
--
-- Needs the following mod, since CC cannot natively talk to RS
-- Advanced Peripherals
-- https://www.curseforge.com/minecraft/mc-mods/advanced-peripherals
-- https://docs.advanced-peripherals.de/peripherals/rs_bridge/
--
-- Created by SuperZorro
-- Inspired and borrowed code from Nyhillius and thraaawn

-- How long to wait between crafts.
local waittime = 60


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

local rs4cc = peripheral.find("refinedstorage")
local advperi = peripheral.find("rsBridge")

if (rs4cc) then
    print("Bridge from Storage for ComputerCraft (rs4cc) found!")
    print("[ERROR]: This version of the code no longer supports rs4cc, but uses Advanced Peripherals insted.")
    error()
    return false
end

if (advperi) then
    rs = advperi
    print("Bridge from Advanced Peripherals found!")
end

if (not rs) then
    print("[ERROR]: No Refined Storage Peripheral found. Place computer next to an advancedperipherals:rs_bridge.")
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
        -- rs.getPattern({ ["name"] = "minecraft:charcoal"})
        -- if(rs.hasPattern(a)) then
        if(rs.getPattern({ ["name"] = a})) then
            -- local rsStack = rs.getItem(a)
            local rsStack = rs.getItem({ ["name"] = a})
            -- local rsStackCount = tonumber(rsStack["count"])
            local rsStackCount = tonumber(rsStack["amount"])
            local toCraft = tonumber(craft["count"])

            if(rsStack["count"]) then
                toCraft = toCraft - rsStackCount
            end

            if(toCraft ~= 0) then
                if(toCraft > 0) then

                    AlreadyCrafting = rs.isItemCrafting({ ["name"] = a})
                    -- local currentTasks = rs.isItemCrafting({ ["name"] = a})
                    -- for k,v in pairs(currentTasks) do
                    --     -- print(v.stack.item.name)
                    --     if v.stack.item.name == craft["fullName"] then
                    --         -- print(v.stack.item.name)
                    --         AlreadyCrafting = true
                    --     end
                    -- end

                    if AlreadyCrafting == false then
                        print("Crafting: " .. toCraft, craft["fullName"] .. "\n")
                        rs.scheduleTask(a, toCraft)
                    else
                        print(craft["fullName"] .. " already crafting, skipping " .. "\n")
                    end
                end
            end
        else
            print("Missing pattern for: " .. craft.name)
        end
    end
    sleep(waittime)
end