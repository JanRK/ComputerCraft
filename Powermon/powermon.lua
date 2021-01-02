local powerside = "back"
local redsside = "left"
local powerhigh = 40
local powerlow = 20
local sleeptime = 30

redstone.setOutput(redsside, false)

while true do
        local powerlevel = peripheral.call(powerside, "getEnergy")
		local maxpower = peripheral.call(powerside, "getEnergyCapacity")
        local power100 =  ( powerlevel / maxpower ) * 100
        local powerpercent =  math.floor(power100 + 0.5)
        term.clear()
        term.setCursorPos( 1, 1 )
        print("Power Level: " ..powerpercent.. "%")
        print(" ")
        print("Power turns off at over " ..powerhigh.. "%")
        print("Power turns on at under " ..powerlow.. "%")
        if power100 > powerhigh then
                redstone.setOutput(redsside, false)
                print("Power high!")
        end
        if power100 < powerlow then
                redstone.setOutput(redsside, true)
                print("Power low!")
        end
        sleep(sleeptime)
end
