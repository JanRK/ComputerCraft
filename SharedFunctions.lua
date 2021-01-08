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