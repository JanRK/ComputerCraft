os.loadAPI("/jk/SharedFunctions.lua")
-- os.loadAPI("/jk/MiningWellQuarry/miningWellQuarry.lua")

redstone.setOutput("left", false)
redstone.setOutput("right", false)

fuelType = "thermal:charcoal_block"

fuelChestName = "enderstorage:ender_chest"
minerName = "quarryplus:miningwellplus"
itemChestName = "dimstorage:dimensional_chest"
batteryName = "mekanism:basic_energy_cube"
batteryPeriName = "basicEnergyCube"


local miningProgressFile = "/settings/miningProgress.lua"
local miningSettingsFile = "/settings/miningSettings.txt"

if SharedFunctions.testFileExists(miningSettingsFile) then
    miningSettings = SharedFunctions.fromJSON(SharedFunctions.readSettingFromFile(miningSettingsFile))
    turtleOrder = miningSettings.order
    turtleDimension = miningSettings.dimension
else
    print("No Host settings found, enter order [first,last,center]")
    print("Order")
    turtleOrder = read()
    print("Enter dimension [overworld,mining,nether,etc]")
    turtleDimension = read()
    local miningSettings = { dimension = turtleDimension, order = turtleOrder}
    local miningSettingsJson = SharedFunctions.toJSON(miningSettings)
    print(miningSettingsJson)
    SharedFunctions.writeToFile(miningSettingsFile,miningSettingsJson)
    error()
end

function getHomeCoords()
    os.loadAPI('/jk/Quarry/configuration')
    local startGPS = configuration.new('MiningStartLocation', '/settings', 'Location information used by turtle')
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

function reportRednet(rednetMessage)
    shell.run("/jk/Rednet/rednet.lua client miner " .. rednetMessage)
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




function refuel()
  print("refuel")
  if (turtle.getFuelLevel() < 10000) then
    for i = 1, 16 do
      turtle.select(i)
      if turtle.refuel(0) then -- if it's valid fuel
          turtle.refuel()
      end
    end

    if (SharedFunctions.findDeviceSide(fuelChestName)) then
      print("Fuel chest found!")
    else
      local fuelChestLocation = SharedFunctions.findItem(fuelChestName)
      if (fuelChestLocation == -1) then
        print("Fuel Chest not found!")
        if (turtle.detectUp()) then
          turtle.digUp()
        end
      end
      print("Placing Fuel chest")
      turtle.select(fuelChestLocation)
      turtle.placeUp()
      sleep(0.5)
    end
    
    fuelChestSideLocation = SharedFunctions.findDeviceSide(fuelChestName)
    while turtle.getFuelLevel() < 50000 do
      doRefuel()
      SharedFunctions.countDown(math.random(5,10))
    end

    print("Refuel done, fuel level is " .. tostring(turtle.getFuelLevel()))
    print("Picking up Fuel chest.")
    turtle.digUp()
  else
    if (turtle.detectUp()) then
      turtle.digUp()
    end
  end
end


-- local turlteSideLocation = oppositeSide(chestSideLocation)

function doRefuel()
  print("doRefuel")
  local chest = peripheral.find(fuelChestName)
  if chest then
          local chestSize = chest.size()
          for i = 1,chestSize do
              local itemDetail = chest.getItemDetail(i)
              if itemDetail then
                  if i == 1 then
                      if itemDetail.name == fuelType then
                          turtle.suckUp()
                          -- chest.pullItems(i)
                      else
                          chest.pullItems(fuelChestSideLocation,i,itemDetail.count,54)
                      end
                  else
                      if itemDetail.name == fuelType then
                          chest.pullItems(fuelChestSideLocation,i,itemDetail.count,1)
                      end
                  end
              end
          end
          for i = 1, 16 do
              turtle.select(i)
              if turtle.refuel(0) then -- if it's valid fuel
                  turtle.refuel()
              end
          end
  else
      print("Chest not found, where am I?")
      reportRednet("WTFAmI")
      error()
  end
end


function digForward()
  if turtle.detect() then
      turtle.dig()
      sleep(0.2)
      turtle.suck()
  end
end

function digDown()
  if turtle.detectDown() then
      turtle.digDown()
      sleep(0.2)
      turtle.suckDown()
  end
end

function digUp()
  if turtle.detectUp() then
      turtle.digUp()
      sleep(0.2)
      turtle.suckUp()
  end
end

function goUp()
  print("goUp")
  digUp()
  while not turtle.up() do
      if turtle.detectUp() then --# it couldn't move because of a block
      elseif turtle.attackUp() then --# it couldn't move because of a mob
          while turtle.attackUp() do
              return true
          end
      elseif turtle.getFuelLevel() == 0 then --# it couldn't move because of no fuel
        refuel()
      end
  end
end

function goDown()
  digDown()
  while not turtle.down() do
      if turtle.detectDown() then --# it couldn't move because of a block
      elseif turtle.attackDown() then --# it couldn't move because of a mob
          while turtle.attackDown() do
              return true
          end
      elseif turtle.getFuelLevel() == 0 then --# it couldn't move because of no fuel
        refuel()
      end
  end
end

function goForward()
  digForward()
  while not turtle.forward() do
      if turtle.detect() then --# it couldn't move because of a block
      elseif turtle.attack() then --# it couldn't move because of a mob
          while turtle.attack() do
              return true
          end
      elseif turtle.getFuelLevel() == 0 then --# it couldn't move because of no fuel
        refuel()
      end
  end
end


function placeForward(itemName)
  print("placeForward")
  while turtle.detect() do
    digForward()
    sleep(0.2)
  end
  local placeItemLocation = SharedFunctions.findItem(itemName)
  if (placeItemLocation == -1) then
    print("Item " .. itemName .. " not found!")
    error()
  end
  turtle.select(placeItemLocation)
  turtle.place()
  sleep(0.5)
end

function placeDown(itemName)
  print("placeDown")
  while turtle.detectDown() do
    digDown()
    sleep(0.2)
  end
  local placeItemLocation = SharedFunctions.findItem(itemName)
  if (placeItemLocation == -1) then
    print("Item " .. itemName .. " not found!")
    error()
  end
  turtle.select(placeItemLocation)
  turtle.placeDown()
  sleep(0.5)
end

function checkBatteryLevel()
    local powerpercent = (peripheral.call("bottom", "getEnergyFilledPercentage")) * 100
    if powerpercent < 20 then
        digDown()
        sleep(0.5)
        local batteryLocation = SharedFunctions.findItem(batteryName)
        turtle.select(batteryLocation)
        if turtle.detect() then
            turtle.drop()
        end
        return -1
    end
end


function checkInventory()
    if SharedFunctions.findItem(fuelChestName) == -1 then
        return -1
    end
    if SharedFunctions.findItem(minerName) == -1 then
        return -1
    end
    if SharedFunctions.findItem(itemChestName) == -1 then
        return -1
    end
    if SharedFunctions.findItem(batteryName) == -1 then
        -- reportRednet("WaitingForBattery")
        local fuelChestLocation = SharedFunctions.findItem(fuelChestName)
        turtle.select(fuelChestLocation)
        turtle.placeUp()
        sleep(0.5)
        local fuelChestSideLocation = SharedFunctions.findDeviceSide(fuelChestName)
        local chest = peripheral.find(fuelChestName)
        if chest then
            local chestSize = chest.size()
            while (SharedFunctions.findItem(batteryName) == -1) do
                for i = 1,chestSize do
                    local itemDetail = chest.getItemDetail(i)
                    if itemDetail then
                        if i == 1 then
                            if itemDetail.name == batteryName then
                                turtle.suckUp()
                                -- chest.pullItems(i)
                            else
                                chest.pullItems(fuelChestSideLocation,i,itemDetail.count,chestSize)
                            end
                        else
                            if itemDetail.name == batteryName then
                                chest.pullItems(fuelChestSideLocation,i,itemDetail.count,1)
                            end
                        end
                    end
                end
                SharedFunctions.countDown(math.random(40,60))
            end
        end
        digUp()
    end
    return 1
end

function configureBattery(batterySide)
    listSides = {"left","right","front","back","top","bottom"}; 
    for i, side in pairs(listSides) do 
        peripheral.call(batterySide, "setMode", "ENERGY", side, "output") 
    end
end

function checkStartup()
    if checkInventory() == -1 then
        digDown()
        digUp()
        digForward()
        location()
        gotoYLevel(disy)
    end
    if checkInventory() == -1 then
        location()
        digDown()
        digUp()
        digForward()
    end
    if checkInventory() == -1 then
        print("Cannot find inventory, failing!")
        error()
    end
    location()
    gotoYLevel(disy)
end


-- turtleOrder = miningSettings.order
-- turtleDimension = miningSettings.dimension

function readyToMove()
    if turtleOrder == "first" then
        redstone.setOutput("right", true)
        -- print("first setting right red")
    else
        -- print("listen for left red")
        while not (redstone.getInput("left")) do
            SharedFunctions.countDown(2)
        end
    end
    -- print("setting right red")
    redstone.setOutput("right", true)
    if turtleOrder == "last" then
        -- print("last setting left red")
        redstone.setOutput("left", true)
        SharedFunctions.countDown(10)
        redstone.setOutput("right", false)
    else
        -- print("listen for right red")
        while not (redstone.getInput("right")) do
            SharedFunctions.countDown(2)
        end
        -- print("setting left red")
        redstone.setOutput("left", true)
        SharedFunctions.countDown(10)
    end
    redstone.setOutput("left", false)
    redstone.setOutput("right", false)
end

checkStartup()

--while true do
for i = 1, 16 do
    
    refuel()
    placeForward(minerName)
    goUp()
    placeForward(itemChestName)
    placeDown(batteryName)
    configureBattery("bottom")
    SharedFunctions.countDown(30)
    digForward()
    checkBatteryLevel()
    digDown()
    goDown()
    digForward()
    readyToMove()
    goForward()
    if checkInventory() == -1 then
        print("Cannot find inventory, failing!")
        error()
    end
end

-- SharedFunctions.findItem(fuelChestName)
-- SharedFunctions.findItem(minerName)
-- SharedFunctions.findItem(itemChestName)
-- SharedFunctions.findItem(batteryName)
