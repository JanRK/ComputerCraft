function getHomeCoords()
    os.loadAPI('/jk/Quarry/configuration')
    local startGPS = configuration.new('Location', '/', 'Location information used by turtle')
    -- local exampleString = hidden:getString('exampleStr', 'category', 'defaultValue', 'Element Comments', {'validValues', 'defaultValue'})
    -- Configuration:getNumber(name, category, defaultValue, comment, min, max)
    startX = startGPS:getNumber('startX', 'coords',0)
    startY = startGPS:getNumber('startY', 'coords',0)
    startZ = startGPS:getNumber('startZ', 'coords',0)
    if startX == 0 then
        if startY == 0 then
            if startZ == 0 then
                shell.run ("/jk/Quarry/SetStart.lua")
            end
        end
    end

    os.unloadAPI('configuration')
end

function setProgress()
    location()
    -- print("Setting progress to "..tostring(x))
    fs.delete("progress")
    local setProgressInFile = fs.open("progress", "w" )
    setProgressInFile.write(x)
    setProgressInFile.close()
end

function getProgress()
    local progressInFile = fs.open("progress", "r" )
    local progressFromFile = progressInFile.readLine()
    progressInFile.close()
    -- print("Progress in file is "..tostring(progressFromFile))
    disProgress = x - progressFromFile
    return progressFromFile
end

function digForward()
    if turtle.detect() then
        turtle.dig()
        sleep(0.2)
        turtle.suck()
        checkIfInvIsFull()
    end
end

function digDown()
    if turtle.detectDown() then
        turtle.digDown()
        sleep(0.2)
        turtle.suckDown()
        checkIfInvIsFull()
    end
end

function digUp()
    if turtle.detectUp() then
        turtle.digUp()
        sleep(0.2)
        turtle.suckUp()
        checkIfInvIsFull()
    end
end

function goDown()
    -- print("starting dig")
    digForward()
    digDown()
    digForward()
    digDown()

    -- print("starting loop")
    while not turtle.down() do
        -- print("going down")
        if turtle.detectDown() then --# it couldn't move because of a block
            -- print("detectdown")
            if not turtle.digDown() then --# it couldn't dig a block, assume it is a diamond axe, and a the only thing that cannot be dug is bedrock.
                print("bedrock")
                return false
            end
        elseif turtle.attackDown() then --# it couldn't move because of a mob
            print("attack down")
            while turtle.attackDown() do
                return true
            end
            print("Attacking something")
        elseif turtle.getFuelLevel() == 0 then --# it couldn't move because of no fuel
            print("fuel")
            return false
        end
    end
    checkIfInvIsFull()
    -- print("ending loop")
    return true
end

function goUp()
    -- digForward()
    -- digUp()
    while not turtle.up() do
        if turtle.detectUp() then --# it couldn't move because of a block
        elseif turtle.attackUp() then --# it couldn't move because of a mob
            while turtle.attackUp() do
                return true
            end
        elseif turtle.getFuelLevel() == 0 then --# it couldn't move because of no fuel
            return false
        end
    end
end


function fuellevel()
    fuel = turtle.getFuelLevel()
    if fuel == "unlimited" then
        print("Fuel Level: Unlimited")
        return true
    end
        if fuel > 500 then
        -- print("Fuel Level: "..tostring(fuel))
        return true
    else
        print("Fuel Level: Low")
        print("Going home - Please refuel Turtle!!")
        goToHome()
        error()
        return false
    end
end

-- fuellevel()

function isInvFull()
    for i = 1,16 do
        if turtle.getItemCount(i) == 0 then
        return false
        end
    end
    return true
end

function checkIfInvIsFull()
    if isInvFull() then
        print("Inventory full, returning to empty chest.")
        goToHome()
        emptyInventory()
        goToProgress()
    end
end

function goToHome()
    location()
    gotoYLevel(disy)
    gotoXLevel(disx)
end

function goToProgress()
    location()
    getProgress()
    gotoYLevel(disy)
    gotoXLevel(disProgress)
end

function location()
    -- Getting current location
    -- Original x (ox)...
    x, y, z = gps.locate(3)
    -- Solving for distance by subtracting new location from current location
    -- Distance x (disx)...
    disx = x - startX
    disy = y - startY
    disz = z - startZ
    getHomeCoords()
end

function gotoYLevel(yCoord)
    location()
    if yCoord < 0 then
        goUpAmount = yCoord * -1
        print("Going up "..tostring(goUpAmount))
        for i=1,goUpAmount do
            goUp()
        end
    end
    if yCoord > 0 then
        goUpAmount = yCoord
        print("Going down "..tostring(goUpAmount))
        for i=1,goUpAmount do
            goDown()
        end
    end
end

function gotoXLevel(xCoord)
    location()
    if xCoord < 0 then
        goBackAmount = xCoord * -1
        print("Going back "..tostring(goBackAmount))
        for i=1,goBackAmount do
            turtle.back()
        end
    end
    if xCoord > 0 then
        goBackAmount = xCoord
        print("Going forward "..tostring(goBackAmount))
        for i=1,goBackAmount do
            turtle.forward()
        end
    end
end

function emptyInventory()
    print("Emptying inventory")
    for i = 1,16 do
        turtle.select(i)
        turtle.dropUp()
    end
    pauseOnRedstone()
end

function pauseOnRedstone()
    while redstone.getInput("back") do
        sleep(5)
    end
end

-- Getting coordinates for home
getHomeCoords()
if startX == 0 then
    if startY == 0 then
        if startZ == 0 then
            print("Start coords not found, running SetStart.lua")
            shell.run ("/jk/Quarry/SetStart.lua")
            getHomeCoords()
        end
    end
end


-- Going to start, go check if turtles need to stop/update/refuel.
goToHome()
emptyInventory()


-- Checking if we are ready!
fuellevel()
checkIfInvIsFull()
location()
getProgress()
gotoYLevel(disy)
gotoXLevel(disProgress)

while true do
    while goDown() do end
    location()
    gotoYLevel(disy)
    for i = 1,2 do
        digForward()
        turtle.forward()
    end
    setProgress()
    fuellevel()
    -- getProgress()
end

print("Done")
