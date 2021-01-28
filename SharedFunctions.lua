-- os.loadAPI("/jk/SharedFunctions.lua")

args = {...}
local functionToRun = args[1]

function countDown(secs)
    local x,y = term.getCursorPos(x,y)
    for i = secs,0,-1 do
        term.setCursorPos(1,y)
        term.clearLine()
        term.write(i)
        sleep(1)
    end
    print(" ")
end

if functionToRun == "countDown" then
    countDown(args[2])
end

function testFileExists(filename)
    if (fs.exists(filename)) then
        return true
    end
    return false
end

if functionToRun == "testFileExists" then
    testFileExists(args[2])
end


function writeToFile(filename,filecontent)
    local setfilename = fs.open(filename, "w" )
    setfilename.write(filecontent)
    setfilename.close()
end

function readSettingFromFile(filename)
    local openFile = fs.open(filename, "r" )
    local contentInFile = openFile.readLine()
    openFile.close()
    return contentInFile
end

function toJSON(content)
    local myTableJSON = textutils.serializeJSON( content )
    return myTableJSON
end

function fromJSON(content)
    local myTableJSON = textutils.unserializeJSON( content )
    return myTableJSON
end


function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

-- split_string = Split("Hello World!", " ")
-- split_string = SharedFunctions.Split(textutils.formatTime(os.time(), true ), ":")
-- split_string[1] = "Hello"
-- split_string[2] = "World!"
-- print(split_string[1])
-- print(split_string[2])