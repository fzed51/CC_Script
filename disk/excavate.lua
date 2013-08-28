t = dofile('turtleAPI.lua')

local tArgs =  { ... }
if #tArgs > 1 then
	print( "Usage: excavate [<diameter>]" )
	return
end
if #tArgs == 0 then
	tArgs =  {1}
end

-- Mine in a quarry pattern until we hit something we can't dig
local size = tonumber( tArgs[1] )
if size < 1 then
	print( "Le diamètre d'excavation doit être positif" )
	return
end

local depth = 0
local unloaded = 0
local collected = 0

local xPos,zPos = 0,0
local xDir,zDir = 0,1

local goTo -- Filled in further down
local refuel -- Filled in further down

local function unload()
	print( "Unloading items..." )
	for n=1,16 do
		unloaded = unloaded + turtle.getItemCount(n)
		turtle.select(n)
		turtle.drop()
	end
	collected = 0
	turtle.select(1)
end

local function returnSupplies()
	local x,y,z,xd,zd = xPos,depth,zPos,xDir,zDir
	print( "Returning to surface..." )
	goTo( 0,0,0,0,-1 )

	local fuelNeeded = x+y+z + x+y+z + 1
	if not refuel( fuelNeeded ) then
		unload()
		print( "Waiting for fuel" )
		while not refuel( fuelNeeded ) do
			sleep(1)
		end
	else
		unload()
	end

	print( "Resuming mining..." )
	goTo( x,y,z,xd,zd )
end

-- Réécriture du select.
local nativSelect = turtle.select
local activSlot = 1
local function select( numSlot )
	activSlot = numSlot
	nativSelect( numSlot )
end

local function transfer( from, to)
	local nQte = turtle.getItemSpace(to)
	local nQte2 = turtle.getItemCount(from)
	local nMemoSlot = turtle.activSlot
	local bRetourOk = false
	if nQte2 < nQte then
		nQte = nQte2
	end
	turtle.select( from )
	if turtle.compareTo( to ) then
		bRetourOk = turtle.transferTo(to, nQte)
	end
	turtle.select( nMemoSlot )
	return bRetourOk
end

local function orderSpace()
	local nSelectSlot = 1
	local nLastSlot = 16

	while nSelectSlot<nLastSlot do
		local bRechLast = true
		turtle.select(nSelectSlot)
		for n=nLastSlot, (nSelectSlot+1),-1 do
			if turtle.getItemSpace(nSelectSlot) == 0 then
				bRechLast = false
				break
			end
			if turtle.getItemCount(n) > 0 then
				bRechLast = false
				if turtle.compareTo(n) then
					transfert(n, nSelectSlot)
				end
			else
				if bRechLast then
					nLastSlot = n-1
				end
			end
		end
		nSelectSlot = nSelectSlot + 1
	end

end

local function collect()
	local bFull = true
	local nTotalItems = 0
	orderSpace()
	for n=1,16 do
		local nCount = turtle.getItemCount(n)
		if nCount == 0 then
			bFull = false
		end
		nTotalItems = nTotalItems + nCount
	end

	if nTotalItems > collected then
		collected = nTotalItems
		if math.fmod(collected + unloaded, 50) == 0 then
			print( "Mined "..(collected + unloaded).." items." )
		end
	end

	if bFull then
		print( "No empty slots left." )
		return false
	end
	return true
end

function refuel( ammount )
	local fuelLevel = turtle.getFuelLevel()
	if fuelLevel == "unlimited" then
		return true
	end

	local needed = ammount or (xPos + zPos + depth + 1)
	if turtle.getFuelLevel() < needed then
		local fueled = false
		for n=1,16 do
			if turtle.getItemCount(n) > 0 then
				turtle.select(n)
				if turtle.refuel(1) then
					while turtle.getItemCount(n) > 0 and turtle.getFuelLevel() < needed do
						turtle.refuel(1)
					end
					if turtle.getFuelLevel() >= needed then
						turtle.select(1)
						return true
					end
				end
			end
		end
		turtle.select(1)
		return false
	end

	return true
end

local function tryForwards()
	if not refuel() then
		print( "Not enough Fuel" )
		returnSupplies()
	end

	while not turtle.forward() do
		if turtle.detect() then
			if turtle.dig() then
				if not collect() then
					returnSupplies()
				end
			else
				return false
			end
		elseif turtle.attack() then
			if not collect() then
				returnSupplies()
			end
		else
			sleep( 0.5 )
		end
	end

	xPos = xPos + xDir
	zPos = zPos + zDir
	return true
end

local function tryDown()
	if not refuel() then
		print( "Not enough Fuel" )
		returnSupplies()
	end

	while not turtle.down() do
		if turtle.detectDown() then
			if turtle.digDown() then
				if not collect() then
					returnSupplies()
				end
			else
				return false
			end
		elseif turtle.attackDown() then
			if not collect() then
				returnSupplies()
			end
		else
			sleep( 0.5 )
		end
	end

	depth = depth + 1
	if math.fmod( depth, 10 ) == 0 then
		print( "Descended "..depth.." metres." )
	end

	return true
end

local function turnLeft()
	turtle.turnLeft()
	xDir, zDir = -zDir, xDir
end

local function turnRight()
	turtle.turnRight()
	xDir, zDir = zDir, -xDir
end

function goTo( x, y, z, xd, zd )
	while depth > y do
		if turtle.up() then
			depth = depth - 1
		elseif turtle.digUp() or turtle.attackUp() then
			collect()
		else
			sleep( 0.5 )
		end
	end

	if xPos > x then
		while xDir ~= -1 do
			turnLeft()
		end
		while xPos > x do
			if turtle.forward() then
				xPos = xPos - 1
			elseif turtle.dig() or turtle.attack() then
				collect()
			else
				sleep( 0.5 )
			end
		end
	elseif xPos < x then
		while xDir ~= 1 do
			turnLeft()
		end
		while xPos < x do
			if turtle.forward() then
				xPos = xPos + 1
			elseif turtle.dig() or turtle.attack() then
				collect()
			else
				sleep( 0.5 )
			end
		end
	end

	if zPos > z then
		while zDir ~= -1 do
			turnLeft()
		end
		while zPos > z do
			if turtle.forward() then
				zPos = zPos - 1
			elseif turtle.dig() or turtle.attack() then
				collect()
			else
				sleep( 0.5 )
			end
		end
	elseif zPos < z then
		while zDir ~= 1 do
			turnLeft()
		end
		while zPos < z do
			if turtle.forward() then
				zPos = zPos + 1
			elseif turtle.dig() or turtle.attack() then
				collect()
			else
				sleep( 0.5 )
			end
		end
	end

	while depth < y do
		if turtle.down() then
			depth = depth + 1
		elseif turtle.digDown() or turtle.attackDown() then
			collect()
		else
			sleep( 0.5 )
		end
	end

	while zDir ~= zd or xDir ~= xd do
		turnLeft()
	end
end

if not refuel() then
	print( "Out of Fuel" )
	return
end

print( "Excavating..." )

local reseal = false
turtle.select(1)
if turtle.digDown() then
	reseal = true
end

local alternate = 0
local done = false
while not done do
	for n=1,size do
		for m=1,size-1 do
			if not tryForwards() then
				done = true
				break
			end
		end
		if done then
			break
		end
		if n<size then
			if math.fmod(n + alternate,2) == 0 then
				turnLeft()
				if not tryForwards() then
					done = true
					break
				end
				turnLeft()
			else
				turnRight()
				if not tryForwards() then
					done = true
					break
				end
				turnRight()
			end
		end
	end
	if done then
		break
	end

	if size > 1 then
		if math.fmod(size,2) == 0 then
			turnRight()
		else
			if alternate == 0 then
				turnLeft()
			else
				turnRight()
			end
			alternate = 1 - alternate
		end
	end

	if not tryDown() then
		done = true
		break
	end
end

print( "Returning to surface..." )

-- Return to where we started
goTo( 0,0,0,0,-1 )
unload()
goTo( 0,0,0,0,1 )

-- Seal the hole
if reseal then
	turtle.placeDown()
end

print( "Mined "..(collected + unloaded).." items total." )
