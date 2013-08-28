
local tArgs = { ... }
if not (#tArgs == 1 ou #tArgs == 2) then
	print( "Usage: tunnel <longueur>" )
	print( "Usage: tunnel <longueur> <{largeur, hauteur}>" )
	return
end

-- Mine in a quarry pattern until we hit something we can't dig
local length = tonumber( tArgs[1] )
if length < 1 then
	print( "Le tunnel doit avoir une longueur positive!" )
	return
end
	
local depth = 0
local collected = 0

local function collect()
	collected = collected + 1
	if math.fmod(collected, 25) == 0 then
		print( collected.." items miné(s)." )
	end
end

local function tryDig()
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

local function tryDigUp()
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

local function tryDigDown()
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

local function refuel()
	local fuelLevel = turtle.getFuelLevel()
	if fuelLevel == "unlimited" or fuelLevel > 0 then
		return
	end
	
	local function tryRefuel()
		for n=1,16 do
			if turtle.getItemCount(n) > 0 then
				turtle.select(n)
				if turtle.refuel(1) then
					turtle.select(1)
					return true
				end
			end
		end
		turtle.select(1)
		return false
	end
	
	if not tryRefuel() then
		print( "Ajout plus de fuel pour continuer." )
		while not tryRefuel() do
			sleep(1)
		end
		print( "Retour au tunnel." )
	end
end

local function tryUp()
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

local function tryDown()
	refuel()
	while not turtle.down() do
		if turtle.detectDown() then
			if not tryDigDown() then
				return false
			end
		elseif turtle.attackDown() then
			collect()
		else
			sleep( 0.5 )
		end
	end
	return true
end

local function tryForward()
	refuel()
	while not turtle.forward() do
		if turtle.detect() then
			if not tryDig() then
				return false
			end
		elseif turtle.attack() then
			collect()
		else
			sleep( 0.5 )
		end
	end
	return true
end

local function trySelect( slot )
	if slot >= 1 and slot <= 16 then
		if turtle.getItemCount(slot) > 0 then
			turtle.select(slot)
			return true
		else
			print("Le slot " .. slot .. " est vide")
			return false
		end
	end
end

local function tryPlace( slot )
	if trySelect(slot) then
		return turtle.place()
	else
		return false
	end
end

local function tryPlaceUp( slot )
	if trySelect(slot) then
		return turtle.placeUp()
	else
		return false
	end
end

local function tryPlaceDown( slot )
	if trySelect(slot) then
		return turtle.placeDown()
	else
		return false
	end
end

local function turnLeft()
	turtle.turnLeft()
end

local function turnRight()
	turtle.turnRight()
end

local function turnBack()
	turtle.turnLeft()
	turtle.turnLeft()
end

print( "Tunnelling..." )

for n=1,length do

	if n<length then
		tryDig()
		if not tryForward() then
			print("ERREUR FATALE")
			print( "Abandon du Tunnel." )
			break
		end	
		tryPlaceDown(1)
		tryUp()
		tryPlaceUp(1)
		turnLeft()
		if tryForward() then
			tryPlaceUp(1)
			tryPlace(1)
			if tryDown() then
				print("ERREUR FATALE")
				print("Abandon du Tunnel."")
				break
			end
			tryPlace()
			tryPlaceDown()
			turnBack()
			tryForward()
			tryUp()
		else
			turnBack()
		end
		if tryForward() then
			tryPlaceUp(1)
			tryPlace(1)
			if tryDown() then
				print("ERREUR FATALE")
				print("Abandon du Tunnel."")
				break
			end
			tryPlace()
			tryPlaceDown()
			turnBack()
			tryForward()
			turnRight()
		else
			turnLeft()
			tryDown()			
		end
	else
		print( "Tunnel complete." )
	end

end

print( "Retour au début..." )

-- Return to where we started
turnBack()
while depth > 0 do
	if tryForward() then
		depth = depth - 1
	end
end
turnBack()

print( "Tunnel fini." )
print( "Un total de " ..collected.." items miné(s)." )
