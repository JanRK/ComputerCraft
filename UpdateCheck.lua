-- pastebin run 55aPr7CG

local UpdateFile = "/localVersion"
local StartupFile = "/startup.lua"
local startProgram = "/startProgram.lua"

-- settings.set("motd.enable",false) -- Not working?
shell.run("set motd.enable false")

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



local computerName = os.getComputerLabel()
if (not computerName) then
    print("No name detected, type new name:")
    newComputerName = read()
    shell.run("label set " .. newComputerName)
    local nameFile = "/host.lua"
    local nameFileExists = testFileExists(nameFile)
    if nameFileExists then
        fs.delete(nameFile)
    end
    local setNameFile = fs.open(nameFile, "w" )
    setNameFile.write(newComputerName)
    setNameFile.close()
end



local manuelUpdating = testFileExists("/manualupdate.lua")
if manuelUpdating then
    print("Not updating from GitHub, since /manualupdate.lua exists!")
else
    -- Try to fix Github Rate limit
    local rateLimited = 0
    local waitForRateLimit = true
    while waitForRateLimit == true do
        local checkRateLimit = http.get("https://api.github.com/rate_limit").readAll()
        if checkRateLimit then
            local currentRateLimit = textutils.unserialiseJSON(checkRateLimit).rate.remaining
            print("Rate limit is at " .. currentRateLimit)
            if currentRateLimit < 30 then
                local sleepSecs = math.random(60,120)
                countDown(sleepSecs)
            else
                waitForRateLimit = false
            end
        else
            print("Rate limit is unavailiable!?")
            local sleepSecs = math.random(60,120)
            countDown(sleepSecs)
        end
    end

    local lastCommit = textutils.unserialiseJSON(http.get("https://api.github.com/repos/JanRK/ComputerCraft/git/refs/heads/master").readAll())
    local lastCommitSHA = lastCommit["object"]["sha"]
    print("Latest commit SHA " .. lastCommitSHA)
    local updateFileExists = testFileExists(UpdateFile)
    -- print(needsUpdate)

    if updateFileExists then
        local versionInFile = fs.open(UpdateFile, "r" )
        local versionFromFile = versionInFile.readLine()
        versionInFile.close()
        print("Local commit SHA is "..tostring(versionFromFile))
        if versionFromFile == lastCommitSHA then
            local commitInfo = textutils.unserialiseJSON(http.get(lastCommit["object"]["url"]).readAll())
            local commitInfoName = commitInfo["committer"]["name"]
            local commitInfoDate = commitInfo["committer"]["date"]
            print( "Already on latest commit! " .. commitInfoName .. " " .. commitInfoDate )
            NeedsUpdate = false
        else
            print("New commit found.")
            NeedsUpdate = true
        end
    else
        print("No update file found!")
        NeedsUpdate = true
    end

    if NeedsUpdate then
        print("Running update!")
        if (not fs.exists("/github")) then
            shell.run("pastebin run p8PJVxC4")
        end

        cloneTry = shell.run("/github clone JanRK/ComputerCraft jk")
        if cloneTry == false then
            print("Github rate limit, retrying!")
            local sleepSecs = math.random(60,180)
            countDown(sleepSecs)
            os.reboot()
        end
        setLocalVersion(lastCommitSHA)
    end
end

local startupExists = testFileExists(StartupFile)
if startupExists then
    fs.delete(StartupFile)
end
local setStartupFile = fs.open(StartupFile, "w" )
setStartupFile.write('if redstone.getInput("back") then\n')
setStartupFile.write('if (not fs.exists("/manualupdate.lua")) then\n')
setStartupFile.write('shell.run("/jk/SharedFunctions countDown " .. math.random(1,60))\n')
setStartupFile.write('end\n')
if manuelUpdating then
    setStartupFile.write('shell.run("/jk/UpdateCheck.lua")\n')
else
    setStartupFile.write('shell.run("pastebin run 55aPr7CG")\n')
end
setStartupFile.write('end\n')
setStartupFile.write('shell.run("/startProgram.lua")\n')
setStartupFile.close()


local startProgramExists = testFileExists(startProgram)
if startProgramExists then
    print("Update Done")
else
    print("Enter Startup Program")
    print("Digger,Powermon,RSAutoCraft,Pressuremon,GPSHost,Nothing")
    local userInput = read()

    if userInput == "Digger" then
        startupCommand = 'shell.run("fg /jk/Quarry/digger.lua")'
    elseif userInput == "MiningWell" then
        startupCommand = 'shell.run("fg /jk/MiningWellQuarry/miningWellQuarry.lua")'
    elseif userInput == "Powermon" then
        startupCommand = 'shell.run("fg /jk/Powermon/powermon.lua")'
    elseif userInput == "Pressuremon" then
        startupCommand = 'shell.run("fg /jk/PneumaticCraft/pressureMon.lua")'
    elseif userInput == "RSAutoCraft" then
        startupCommand = 'shell.run("fg /jk/RefinedStorage/Autocraft.lua /CraftList")'
    elseif userInput == "GPSHost" then
        startupCommand = 'shell.run("fg /jk/GPS/gps.lua host")'
    else
        startupCommand = 'print("Welcome")'
    end

    local setStartProgramFile = fs.open(startProgram, "w" )
    setStartProgramFile.write(startupCommand)
    setStartProgramFile.close()
end

