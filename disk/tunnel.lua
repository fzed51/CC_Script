--[[
+----------------------------------------------------------------------------+
| tunnel
| version : 2.0
| Auteur : fzed51
| git : https://github.com/fzed51/CC_Script/blob/master/disk/tunnel.lua
| pastebin : http://pastebin.com/Q6S02tau
+----------------------------------------------------------------------------+
| tag : [lua] [MC] [MineCraft] [CC] [ComputerCraft] [Turtle]
| Description :
| script pour creuser un tunnel de minage
+----------------------------------------------------------------------------+
]]--

dofile('advTurtle') -- http://pastebin.com/7mLzefhQ

--[[ Paramètes du script ]]--
local tArgs = { ... }
if not (#tArgs == 1) then
	print( "Usage:\ntunnel <longueur>" )
	return
end
local length = tonumber( tArgs[1] )
if length < 1 then
	print( "Le tunnel doit avoir une longueur positive!" )
	return
end

--[[ Paramètes de l'inventaire ]]--
item.add('coal',1,64)
setFuelItem(item.coal)
item.add('cobblestone',2,32)
item.add('torch',3,64)

local function goStart( l )
	turnBack()
	for _=1,l do tryForward() end
	print ('')
	print ('Videz mon inventaire !!!')
	os.pullEvent('key')
	turnBack()
	for _=1,l do tryForward() end
end

local depth = 0
print( "Creuser un tunnel..." )

for n=1,length do
	if n<length then
		tryDig()
		if tryForward() then
			depth = depth + 1
		else
			print("ERREUR FATALE")
			print( "Abandon du Tunnel." )
			break
		end	
		tryPlaceDown(item.cobblestone)
		tryUp()
		tryPlaceUp(item.cobblestone)
		turnLeft()
		if tryForward() then
			tryPlaceUp(item.cobblestone)
			tryPlace(item.cobblestone)
			if not tryDown() then
				print("ERREUR FATALE")
				print("Abandon du Tunnel.")
				break
			end
			tryPlace(item.cobblestone)
			tryPlaceDown(item.cobblestone)
			turnBack()
			tryForward()
			tryUp()
		else
			turnBack()
		end
		if tryForward() then
			tryPlaceUp(item.cobblestone)
			tryPlace(item.cobblestone)
			if (n % 7) == 4 then
				turnRight()
				tryPlace(item.torch)
				turnLeft()
			end
			if not tryDown() then
				print("ERREUR FATALE")
				print("Abandon du Tunnel.")
				break
			end
			tryPlace(item.cobblestone)
			tryPlaceDown(item.cobblestone)
			turnBack()
			tryForward()
			turnRight()
		else
			turnLeft()
			tryDown()			
		end
		if inventaireIsFull() then
			rangeInventaire()
			if inventaireIsFull() then
				goStart(n)
			end
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