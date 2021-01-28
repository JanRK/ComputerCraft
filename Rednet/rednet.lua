os.loadAPI("/jk/SharedFunctions.lua")
local periList = peripheral.getNames()
local modemSide = "Not Found"
local monitorSide = "Not Found"
local rednetProtocol = "jkRedNet"
local rednetHostname = "MainServer"

for i in ipairs(periList) do
	local periSide = periList[i]
    local periName = peripheral.getType(periSide)
    if periName == "modem" then
        modemSide = periSide
    end
end

rednet.open(modemSide)



args = {...}
local rednetRole = args[1]

if rednetRole == "server" then
    print("Starting RedNet Server")
    rednet.host(rednetProtocol,rednetHostname)
    local monitor = peripheral.find("monitor")
    if monitor then
        monitor.setTextScale(0.5)
    end
    while true do
        local senderId, message, protocol = rednet.receive(rednetProtocol)
        local receivedMessage = textutils.unserialiseJSON(message)
        print("ID: " .. senderId .. " Message: " .. message)
        if monitor then
            monitor.setCursorPos(1,senderId)
            monitor.clearLine()
            local receivedName = receivedMessage.name
            while receivedName:len() < 8 do receivedName = receivedName .." " end
            local receivedTime = receivedMessage.day .. "-" .. receivedMessage.hour .. ":" .. receivedMessage.minute
            if receivedMessage.message.Function == "Miner" then 
                monitor.write(receivedName .. " " .. receivedTime .. " " .. math.floor(receivedMessage.message.MiningProgress + 0.5) .. " " .. receivedMessage.message.Order .. " Fuel " .. receivedMessage.message.Fuel)
            elseif receivedMessage.message.Function == "Powermon" then 
                monitor.write(receivedName .. " " .. receivedTime .. " " .. receivedMessage.message.PowerLevel .. " " .. receivedMessage.message.Charging .. " " .. receivedMessage.message.Purpose)
            end
        end
    end
elseif rednetRole == "client" then
    -- shell.run("/rednet client " .. textutils.urlEncode( textutils.serializeJSON( myTable ) ))
    -- shell.run("/rednet client " .. textutils.serializeJSON( myTable ))
    print("Starting RedNet client")
    local MainServerID = rednet.lookup(rednetProtocol,rednetHostname)

    local messageToSend = "Ping"

    if args[2] then
        messageToSend = args[2]
        if args[2] == "miner" then
            local miningProgressFile = "/settings/miningProgress.lua"
            local progressInFile = fs.open(miningProgressFile, "r" )
            local progressFromFile = progressInFile.readLine()
            progressInFile.close()
            x, y, z = gps.locate(3)
            messageToSend = {
                Function = "Miner",
                MiningProgress = progressFromFile,
                Fuel = string.format("%02d",math.floor(((turtle.getFuelLevel() / turtle.getFuelLimit()) * 100) + 0.5 )) .. "%",
                location = x .. "," .. y .. "," .. z,
                Order = args[3]
            }
        end
        if args[2] == "powermon" then
            local settingsFile = "/settings/power.lua"
            local powerJSON = SharedFunctions.readSettingFromFile(settingsFile)
            local powerSettings = SharedFunctions.fromJSON(powerJSON)

            messageToSend = {
                Function = "Powermon",
                PowerLevel = args[3],
                Charging = args[4],
                Purpose = powerSettings.purpose
            }
        end
    end


    local time = SharedFunctions.Split(textutils.formatTime(os.time(), true ), ":")

    local myTable = {
        name = os.getComputerLabel(),
        day = os.day(),
        hour = string.format("%02d",time[1]),
        minute = string.format("%02d",time[2]),
        message = messageToSend
    }

    -- %02d
    local myTableJSON = textutils.serializeJSON( myTable )
    print( myTableJSON )
    rednet.send(MainServerID,myTableJSON,rednetProtocol)
else
    print("No role set, call with server or client param")
end

--table1 = { test1 = "test1", test2 = "test2"}
--table2 = { test3 = "test3", test4 = "test4"}
--table3 = { test5 = "test5", test6 = table2}