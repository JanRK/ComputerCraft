local periList = peripheral.getNames()

for i in ipairs(periList) do
	local periSide = periList[i]
	local periName = peripheral.getType(periSide)
	print("I have a "..periName.." attached as \"".. periSide .."\".")
	print("Methods found:")
	for i,v in ipairs(peripheral.getMethods(periSide)) do 
		print(i..". "..v) 
	end
	read()
end
