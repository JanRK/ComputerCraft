os.loadAPI('/jk/Quarry/configuration')
local miningProgressFile = "/settings/miningProgress.lua"

start_x, start_y, start_z = gps.locate(3)
local startGPS = configuration.new('MiningStartLocation', '/settings', 'Location information used by turtle')
local startX = startGPS:getNumber('startX', 'coords', start_x, 'Home x coord')
local startY = startGPS:getNumber('startY', 'coords', start_y, 'Home y coord')
local startZ = startGPS:getNumber('startZ', 'coords', start_z, 'Home z coord')

fs.delete(miningProgressFile)
local setProgressInFile = fs.open(miningProgressFile, "w" )
setProgressInFile.write(start_x)
setProgressInFile.close()

print("x: "..tostring(startX))
print("y: "..tostring(startY))
print("z: "..tostring(startZ))

startGPS:save()

os.unloadAPI('configuration')
