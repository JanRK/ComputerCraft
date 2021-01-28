os.loadAPI("/jk/SharedFunctions.lua")
local settingsFile = "/settings/pressure.lua"
local settingsFileExists = SharedFunctions.testFileExists(settingsFile)
local peripheralName = {"pneumaticcraft:pressure_tube","pneumaticcraft:advanced_pressure_tube","pneumaticcraft:flux_localPeripheral"}



local periList = peripheral.getNames()
for i in ipairs(periList) do
	local periSide = periList[i]
    for key,value in pairs(peripheralName) do
        if peripheral.getType(periSide) == value then
            localPeripheral = peripheral.wrap(periSide)
        end
    end
end

function reportRednet(powerLevel,charging)
    shell.run("/jk/Rednet/rednet.lua client pressure " .. powerLevel .. " " .. charging)
end


if settingsFileExists == false then
    print("No settings found, enter settings")
    print("Enter purpose")
    purpose = read()
    print("Enter Pressure high level")
    pressureHigh = read()
    print("Enter Pressure low level")
    pressureLow = read()
    print("Enter how long sleep between checks")
    sleepTime = read()
    print("Redstone side")
    redSide = read()
    local settingsTable = { purpose = purpose, pressureHigh = pressureHigh, pressureLow = pressureLow, sleepTime = sleepTime, redSide = redSide}
    local settingsJson = SharedFunctions.toJSON(settingsTable)
    print(settingsJson)
    SharedFunctions.writeToFile(settingsFile,settingsJson)
end

local settingsJSON = SharedFunctions.readSettingFromFile(settingsFile)
print(settingsJSON)
local pressureSettings = SharedFunctions.fromJSON(settingsJSON)

local pressureHigh = pressureSettings.pressureHigh
local pressureLow = pressureSettings.pressureLow
local sleeptime = tonumber(pressureSettings.sleepTime)
local redSide = pressureSettings.redSide


function setRedstone(level)
    redstone.setAnalogOutput(redSide,level)
end

setRedstone(0)

while true do
    local currentPressureRaw = localPeripheral.getPressure()
    local currentPressure = math.floor(currentPressureRaw * 100) / 100
    local currentTemperature = localPeripheral.getTemperature()
    term.clear()
    term.setCursorPos( 1, 1 )
    print("Pressure Level: " .. currentPressure )
    print(" ")
    print("Pressure turns off when over " ..pressureHigh)
    print("Pressure turns on when under " ..pressureLow)
    if currentTemperature > 330 then
        setRedstone(15)
        print("Temperature high!")
        sleep(60)
    elseif (tonumber(currentPressure) > tonumber(pressureHigh)) then
        setRedstone(15)
        print("Pressure high!")
    elseif (tonumber(currentPressure) < tonumber(pressureLow)) then
        setRedstone(0)
        print("Pressure low!")
    elseif (tonumber(currentPressure) > tonumber(pressureLow)) then
        local pressureLeveled = currentPressure - pressureLow
        local pressure100 =  ( pressureLeveled / ( pressureHigh - pressureLow ) ) * 100
        local redstoneLevel =  15 * ( pressure100 / 100 )
        print("Setting redstone to " .. redstoneLevel)
        setRedstone(redstoneLevel)
    end
    -- reportRednet(powerpercent.. "%",charging)
    sleep(sleeptime)
end
