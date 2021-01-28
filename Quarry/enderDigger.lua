function setProgress()
    location()
    -- print("Setting progress to "..tostring(x))
    fs.delete("progress")
    local setProgressInFile = fs.open(miningProgressFile, "w" )
    setProgressInFile.write(x)
    setProgressInFile.close()
end

function getProgress()
    local progressInFile = fs.open(miningProgressFile, "r" )
    local progressFromFile = tonumber(progressInFile.readLine())
    progressInFile.close()
    -- print("Progress in file is "..tostring(progressFromFile))
    location()
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
            print("No fuel!")
            return false
        end
    end
    checkIfInvIsFull()
    -- print("ending loop")
    return true
end

function goUp()
    digForward()
    digUp()
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
    if fuel > 5000 then
        -- print("Fuel Level: "..tostring(fuel))
        return true
    else
        print("Fuel Level: Low")
        print("Fuel level is " .. tostring(turtle.getFuelLevel()))
        print("Going home to refuel Turtle!!")
        reportRednet("GoRefuel")
        refuel()
        -- error()
        return false
    end
end

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
        reportRednet("GoEmptyInv")
        goToHome()
        emptyInventory()
        goToProgress()
    end
end


function location()
    -- Getting current location
    -- Original x (ox)...
    x, y, z = gps.locate(5)
    if not x then
        print("Sleep to make sure GPS are ready")
        reportRednet("GPSNotFound")
        while not x do
            shell.run("/jk/SharedFunctions countDown " .. math.random(10,20))
            x, y, z = gps.locate(5)
        end
    end

    -- Solving for distance by subtracting new location from current location
    -- Distance x (disx)...
    getHomeCoords()
    disx = x - startX
    disy = y - startY
    disz = z - startZ
end


