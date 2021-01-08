local periList = peripheral.getNames()
local modemSide = "Not Found"
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
    while true do
        local senderId, message, protocol = rednet.receive(rednetProtocol)
        local receivedMessage = textutils.unserialiseJSON(message)
        print("ID: " .. senderId .. " Message: " .. message)
    end
elseif rednetRole == "client" then
    -- shell.run("/rednet client " .. textutils.urlEncode( textutils.serializeJSON( myTable ) ))
    -- shell.run("/rednet client " .. textutils.serializeJSON( myTable ))
    print("Starting RedNet client")
    local MainServerID = rednet.lookup(rednetProtocol,rednetHostname)
    x, y, z = gps.locate(3)

    local messageToSend = "Ping"

    if args[2] then
        messageToSend = args[2]
        if args[2] == "miner" then
            local progressInFile = fs.open("/progress", "r" )
            local progressFromFile = progressInFile.readLine()
            progressInFile.close()
            messageToSend = {
                Function = "Miner",
                MiningProgress = progressFromFile,
                Fuel = tostring(turtle.getFuelLevel())
            }
    end

    local myTable = {
        name = os.getComputerLabel(),
        location = x .. "," .. y .. "," .. z,
        time = os.day().. " - " .. textutils.formatTime( os.time(), true ),
        message = messageToSend
    }

    local myTableJSON = textutils.serializeJSON( myTable )
    print( myTableJSON )
    rednet.send(MainServerID,myTableJSON,rednetProtocol)
else
    print("No role set, call with server or client param")
end
end

--table1 = { test1 = "test1", test2 = "test2"}
--table2 = { test3 = "test3", test4 = "test4"}
--table3 = { test5 = "test5", test6 = table2}