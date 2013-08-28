-- dofile('turtleAPI.lua')
local modeDebug = false
fileDebug = nil

local function myDebug( message )
	if modeDebug then
		print ( '|> ', message )
	end
	if modeDebug and fileDebug or false then
		file = io.open(fileDebug ,'a')
		file:write(message.."\r\n")
		file:close()
	end
end

function valDebug(var)

	local function tableToChaine (t)
		local chaine = '{'
		local deb = true
		for k,v in pairs(t) do
			if deb then deb = false else chaine = chaine .. ', ' end
			chaine = chaine .. '['.. k ..'] = '.. valDebug(v)
		end
		chaine = chaine .. '}'
		return chaine
	end
	
	local typeVar = type(var)
	if     typeVar == 'string' then 
		return string.format("%q", v)
	elseif typeVar == 'number' then 
		return var
	elseif typeVar == 'nil' then 
		return 'nil'
	elseif typeVar == 'function' then 
		return 'function'
	elseif typeVar == 'boolean' then
		if var then 
			return 'true' 
		else 
			return 'false' 
		end
	elseif typeVar == 'table' then 
		return tableToChaine(var)
	else 
		return '#erreur#'
	end 
end

local unloaded = 0
local collected = 0

local depth = 0
local xPos,zPos = 0,0
local xDir,zDir = 0,1

local goTo -- Filled in further down
local refuel -- Filled in further down

-- Réécriture du select.
local nativSelect = turtle.select
local activSlot = 1

function unload()
	myDebug('unload()')
	
	print( "Unloading items..." )
	for n=1,16 do
		unloaded = unloaded + turtle.getItemCount(n)
		select(n)
		turtle.drop()
	end
	collected = 0
	select(1)
end

function returnSupplies()
	myDebug('returnSupplies()')
	
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

function select( numSlot )
	myDebug('select( '..numSlot..' )')
	
	activSlot = numSlot
	nativSelect( numSlot )
end

function transfer( from, to)
	myDebug('transfer( from = '..from..', to = '..to..' )')
	local nQteTo = turtle.getItemSpace(to)
	local nQteFrom = turtle.getItemCount(from)
	local nMemoSlot = activSlot
	local bRetourOk = false
	if nQteFrom < nQteTo then
		nQteTo = nQteFrom
	end
	nativSelect( from )
	if turtle.compareTo( to ) then
		bRetourOk = turtle.transferTo(to, nQteTo)
	end
	nativSelect( nMemoSlot )
	return bRetourOk
end

function orderSpace()
	myDebug('orderSpace()')
	
	local nSelectSlot = 1
	local nLastSlot = 16
	local n = 0
	
	while nSelectSlot<nLastSlot do
		local bRechLast = true
		select(nSelectSlot)
		for n=nLastSlot, (nSelectSlot+1),-1 do
			if turtle.getItemSpace(nSelectSlot) == 0 then
				bRechLast = false
				break
			end
			if turtle.getItemCount(n) > 0 then
				bRechLast = false
				if turtle.compareTo(n) then
					transfer(n, nSelectSlot)
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

function collect()
	myDebug('collect()')
	
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
	myDebug('refuel( '.. ( ammount or '' )..' )')
	
	local fuelLevel = turtle.getFuelLevel()
	if fuelLevel == "unlimited" then
		return true
	end

	local needed = ammount or (xPos + zPos + depth + 1)
	if turtle.getFuelLevel() < needed then
		local fueled = false
		for n=1,16 do
			if turtle.getItemCount(n) > 0 then
				select(n)
				if turtle.refuel(1) then
					while turtle.getItemCount(n) > 0 and turtle.getFuelLevel() < needed do
						turtle.refuel(1)
					end
					if turtle.getFuelLevel() >= needed then
						select(1)
						return true
					end
				end
			end
		end
		select(1)
		return false
	end

	return true
end

function tryDig()
	myDebug('tryDig()')
	
	while turtle.detect() do
		if turtle.dig() then
			collect()
			sleep(0.5)
		else
			return false
		end
	end
	return true
end

function tryDigUp()
	myDebug('tryDigUp()')
	
	while turtle.detectUp() do
		if turtle.digUp() then
			collect()
			sleep(0.5)
		else
			return false
		end
	end
	return true
end

function tryDigDown()
	myDebug('tryDigDown()')
	
	while turtle.detectDown() do
		if turtle.digDown() then
			turtle.suckDown()
			collect()
			sleep(0.5)
		else
			return false
		end
	end
	return true
end

function tryUp()
	myDebug('tryUp()')
	
	refuel()
	while not turtle.up() do
		if turtle.detectUp() then
			if not tryDigUp() then
				return false
			end
		elseif turtle.attackUp() then
			collect()
		else
			sleep( 0.5 )
		end
	end
	return true
end

function trySelect( slot )
	myDebug('trySelect( '..' )')
	
	local slots = {}
	local n = 1
	local s
	
	if not type(slot) == 'table' then
		slots[1] = slot
	else
		slots = slot
	end
	
	while n<= #slots do
		s = slots[n]
		if s >= 1 and s <= 16 then
			if turtle.getItemCount(s) > 0 then
				select( s )
				return true
			end
		end
	end
	
	print("Le(s) slot(s) selectionné(s) est(sont) vide(s).")
	return false
	
end

function tryPlace( slot )
	myDebug('tryPlace( '..' )')
	
	if trySelect(slot) then
		return turtle.place()
	else
		return false
	end
end

function tryPlaceUp( slot )
	myDebug('tryPlaceUp( '..' )')
	
	if trySelect(slot) then
		return turtle.placeUp()
	else
		return false
	end
end

function tryPlaceDown( slot )
	myDebug('tryPlaceDown( '..' )')
	
	if trySelect(slot) then
		return turtle.placeDown()
	else
		return false
	end
end

function turnBack()
	myDebug('turnBack()')
	
	turnLeft()
	turnLeft()
end

function tryForward()
	myDebug('tryForward()')
	
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

function tryDown( option )
	force = option or true
	myDebug('tryDown( '.. (force and 'true' or 'false') ..')')
	
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

function turnLeft()
	myDebug('turnLeft()')
	
	turtle.turnLeft()
	xDir, zDir = -zDir, xDir
end

function turnRight()
	myDebug('turnRight()')
	
	turtle.turnRight()
	xDir, zDir = zDir, -xDir
end

function detectDown()
	myDebug('detectDown()')
	
	return turtle.detectDown()
end

function detect()
	myDebug('detect()')
	
	return turtle.detect()
end

function detectUp()
	myDebug('detectUp()')
	
	return turtle.detectUp()
end

function goTo( x, y, z, xd, zd )
	myDebug('goTo( '..x..', '..y..', '..z..', '..xd..', '..zd..' )')
	
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
