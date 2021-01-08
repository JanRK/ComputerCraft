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
        local receivedMessage = message
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

