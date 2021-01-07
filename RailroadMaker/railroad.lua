local supportMaterial = "minecraft:glass"
-- local supportMaterial = "minecraft:cobblestone"

print("How many chunks to build?")
print("Enter inf for infinite")
local chunksNumber = read()

function findItemLocation(itemName)
    for i = 1,16 do
        -- print("Looking for ".. itemName .. " in location " .. i)
        local itemDetail = turtle.getItemDetail(i)
        if itemDetail then
            if itemDetail["name"] == itemName then
                -- if turtle.getItemDetail(i)["name"] == itemName then
                return i
            end
        end
    end
    return false
end

function findItem(itemName)
    local itemLocation = findItemLocation(itemName)
    while itemLocation == false do
        print(itemName .. " not found! Manually refill!")
        read()
        itemLocation = findItemLocation(itemName)
    end
    turtle.select(itemLocation)
end

-- local railLocation = findItem("minecraft:rail")
-- local poweredRailLocation = findItem("minecraft:powered_rail")
-- local leverLocation = findItem("minecraft:lever")
-- local supportMaterialLocation = findItem(supportMaterial)

-- print(supportMaterialLocation)

function goForward()
    while turtle.detect() do
        turtle.dig()
        sleep(0.5)
    end
    while turtle.detectUp() do
        turtle.digUp()
        sleep(0.5)
    end
    turtle.forward()
end

function goDown()
    while turtle.detectDown() do
        turtle.digDown()
        sleep(0.5)
    end
    turtle.down()
end

function buildSupport()
    findItem(supportMaterial)
    if turtle.detectDown() then
        turtle.digDown()
    end
    turtle.placeDown()
end

function buildLever()
    findItem("minecraft:lever")
    if turtle.detectDown() then
        turtle.digDown()
    end
    turtle.placeDown()
end

function buildRail()
    findItem("minecraft:rail")
    if turtle.detectDown() then
        turtle.digDown()
    end
    turtle.placeDown()
end

function buildPoweredRail()
    findItem("minecraft:powered_rail")
    if turtle.detectDown() then
        turtle.digDown()
    end
    turtle.placeDown()
end


function buildSupportChunk()
    goDown()
    for i = 1,15 do
        buildSupport()
        goForward()
    end
    buildSupport()
    turtle.up()
end

function buildRailChunk()
    for i = 1,2 do
        for i = 1,7 do
            buildRail()
            -- digForward()
            turtle.back()
        end
        buildPoweredRail()
        if i == 1 then
            turtle.back()
        end
    end
end

function buildLeverChunk()
    turtle.turnRight()
    goForward()
    turtle.turnLeft()

    for i = 1,2 do
        goDown()
        buildSupport()
        turtle.up()
        buildLever()
        if i == 1 then
            goForward()
        end
        for i = 1,7 do
            goForward()
        end
    end

    turtle.turnLeft()
    goForward()
    turtle.turnRight()
end

function buildChunk()
    buildSupportChunk()
    buildRailChunk()
    buildLeverChunk()
    goForward()
end

if chunksNumber == "inf" then
    while true do
        buildChunk()
    end
else
    for i = 1,chunksNumber do
        buildChunk()
    end
end
buildSupport()