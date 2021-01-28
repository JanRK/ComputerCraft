args = {...}
local gpsRole = args[1]
os.loadAPI("/jk/SharedFunctions.lua")
local settingsFile = "/settings/gpsHost.lua"

if gpsRole == "host" then
    local settingsFileExists = SharedFunctions.testFileExists(settingsFile)
    if settingsFileExists == false then
        print("No Host settings found, enter location")
        print("X")
        xHost = read()
        print("Y")
        yHost = read()
        print("Z")
        zHost = read()
        local gpsTable = { xHost = xHost, yHost = yHost, zHost = zHost}
        local gpsJson = SharedFunctions.toJSON(gpsTable)
        print(gpsJson)
        SharedFunctions.writeToFile(settingsFile,gpsJson)
    end
    local gpsCoordsJSON = SharedFunctions.readSettingFromFile(settingsFile)
    -- print(gpsCoordsJSON)
    local coords = SharedFunctions.fromJSON(gpsCoordsJSON)
    print("Starting GPS host on coords: " .. coords.xHost .. " " .. coords.yHost .. " " .. coords.zHost)
    shell.run("gps host " .. coords.xHost .. " " .. coords.yHost .. " " .. coords.zHost)
end
