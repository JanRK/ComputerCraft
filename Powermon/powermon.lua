os.loadAPI("/jk/SharedFunctions.lua")
local settingsFile = "/settings/power.lua"
local settingsFileExists = SharedFunctions.testFileExists(settingsFile)


function reportRednet(powerLevel,charging)
    shell.run("/jk/Rednet/rednet.lua client powermon " .. powerLevel .. " " .. charging)
end


if settingsFileExists == false then
    print("No settings found, enter settings")
    local periList = peripheral.getNames()
    for i in ipairs(periList) do
        local periSide = periList[i]
        local periName = peripheral.getType(periSide)
        print("I have a "..periName.." attached as \"".. periSide .."\".")
    end
    print("Enter purpose")
    purpose = read()
    print("Enter Battery side")
    batterySide = read()
    print("Enter Redstone side")
    redstoneSide = read()
    print("Enter Power high level")
    powerHigh = read()
    print("Enter Power low level")
    powerLow = read()
    print("Enter how long sleep between checks")
    sleepTime = read()
    local powerTable = { purpose = purpose, batterySide = batterySide, redstoneSide = redstoneSide, powerHigh = powerHigh, powerLow = powerLow, sleepTime = sleepTime}
    local powerJson = SharedFunctions.toJSON(powerTable)
    print(powerJson)
    SharedFunctions.writeToFile(settingsFile,powerJson)
end

local powerJSON = SharedFunctions.readSettingFromFile(settingsFile)
print(powerJSON)
local powerSettings = SharedFunctions.fromJSON(powerJSON)

local powerside = powerSettings.batterySide
local redsside = powerSettings.redstoneSide
local powerhigh = powerSettings.powerHigh
local powerlow = powerSettings.powerLow
local sleeptime = tonumber(powerSettings.sleepTime)

local charging = "false"
redstone.setOutput(redsside, false)

while true do
        local powerlevel = peripheral.call(powerside, "getEnergy")
		local maxpower = peripheral.call(powerside, "getEnergyCapacity")
        local power100 =  ( powerlevel / maxpower ) * 100
        local powerpercent =  math.floor(power100 + 0.5)
        term.clear()
        term.setCursorPos( 1, 1 )
        print("Power Level: " ..powerpercent.. "%")
        print(" ")
        print("Power turns off when over " ..powerhigh.. "%")
        print("Power turns on when under " ..powerlow.. "%")
        if (tonumber(power100) > tonumber(powerhigh)) then
                redstone.setOutput(redsside, false)
                print("Power high!")
                charging = "false"
        end
        if (tonumber(power100) < tonumber(powerhigh)) then
                redstone.setOutput(redsside, true)
                print("Power low!")
                charging = "true"
        end
        reportRednet(powerpercent.. "%",charging)
        sleep(sleeptime)
end
