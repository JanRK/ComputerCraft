os.loadAPI('/configuration')

start_x, start_y, start_z = gps.locate(3)
local startGPS = configuration.new('Location', '/', 'Location information used by turtle')
local startX = startGPS:getNumber('startX', 'coords', start_x, 'Home x coord')
local startY = startGPS:getNumber('startY', 'coords', start_y, 'Home y coord')
local startZ = startGPS:getNumber('startZ', 'coords', start_z, 'Home z coord')

fs.delete("progress")
local setProgressInFile = fs.open("progress", "w" )
setProgressInFile.write(start_x)
setProgressInFile.close()

print("x: "..tostring(startX))
print("y: "..tostring(startY))
print("z: "..tostring(startZ))

startGPS:save()

os.unloadAPI('configuration')
