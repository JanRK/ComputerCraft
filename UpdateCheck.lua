local UpdateFile = "localVersion"
local StartupFile ="startup.lua"

function setLocalVersion(sha)
    if (fs.exists(UpdateFile)) then
        fs.delete(UpdateFile)
    end
    local setLocalVersionInFile = fs.open(UpdateFile, "w" )
    setLocalVersionInFile.write(sha)
    setLocalVersionInFile.close()
end

function testFileExists(filename)
    if (fs.exists(filename)) then
        return true
    end
    return false
end

local lastCommit = textutils.unserialiseJSON(http.get("https://api.github.com/repos/JanRK/ComputerCraft/git/refs/heads/master").readAll())
local lastCommitSHA = lastCommit["object"]["sha"]
-- print(lastCommitSHA)
local updateFileExists = testFileExists(UpdateFile)
-- print(needsUpdate)

if updateFileExists then
    local versionInFile = fs.open(UpdateFile, "r" )
    local versionFromFile = versionInFile.readLine()
    versionInFile.close()
    -- print("Progress in file is "..tostring(versionFromFile))
    if versionFromFile == lastCommitSHA then
        local commitInfo = textutils.unserialiseJSON(http.get(lastCommit["object"]["url"]).readAll())
        local commitInfoName = commitInfo["committer"]["name"]
        local commitInfoDate = commitInfo["committer"]["date"]
        print( "Already on latest commit! " .. commitInfoName .. " " .. commitInfoDate )
        NeedsUpdate = false
    end
else
    print("update time")
    NeedsUpdate = true
end

if NeedsUpdate then
    if (not fs.exists("github")) then
        shell.run("pastebin run p8PJVxC4")
    end
    shell.run("github clone JanRK/ComputerCraft jk")
    setLocalVersion(lastCommitSHA)
end


local startupExists = testFileExists("startup.lua")
if startupExists then
    -- print("Update Done")
else
    print("Enter Startup Program")
    print("Digger,Powermon,Nothing")
    local userInput = read("*")

    if userInput == "Digger" then
        startupCommand = 'shell.run("jk/Quarry/digger.lua")'
    elseif userInput == "Powermon" then
        startupCommand = 'shell.run("jk/Powermon/powermon.lua")'
    elseif userInput == "Nothing" then
        startupCommand = 'print("Welcome")'
    end

    local setStartupFile = fs.open(StartupFile, "w" )
    setStartupFile.write(startupCommand)
    setStartupFile.close()
end