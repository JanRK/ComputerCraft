function setLocalVersion(sha)
    if (fs.exists("localVersion")) then
        fs.delete("localVersion")
    end
    local setLocalVersionInFile = fs.open("localVersion", "w" )
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
local updateFileExists = testFileExists("localVersion")
-- print(needsUpdate)

if updateFileExists then
    local versionInFile = fs.open("localVersion", "r" )
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
    return versionFromFile
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
