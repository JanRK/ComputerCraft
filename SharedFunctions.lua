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

function listItems()
  local result = {}
  for i=1,16 do
    local item = turtle.getItemDetail(i)
    if item then
      local itemName = item["name"]
      local itemCount = turtle.getItemCount(i)
      result[i] = itemCount .. " " .. itemName
    end
  end
  return result
end

function findItem(itemName)
  for i=1,16 do
    local item = turtle.getItemDetail(i)
    if item then
      if (turtle.getItemDetail(i)["name"] == string.lower(itemName)) then
        return i
      end
    end
  end
  return -1
end

function findDeviceSide(deviceType)
  local listSides = {"left","right","up","down","front","back","top","bottom"};
  for i, side in pairs(listSides) do
    if (peripheral.isPresent(side)) then
      if (peripheral.getType(side) == string.lower(deviceType)) then
        return side;
      end
    end
  end -- for-do
  return nil;
end

function oppositeSide(side)
  if (side == "left") then
    return "right"
  elseif (side == "right") then
    return "left"
  elseif (side == "up") then
    return "down"
  elseif (side == "down") then
    return "up"
  elseif (side == "front") then
    return "back"
  elseif (side == "back") then
    return "front"
  else
    return nil
  end
end
