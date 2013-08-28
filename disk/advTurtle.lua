--[[ Fonction de Debug ]]--
local modeDebug, fileDebug = false, nil
function setDebug(activ, file)
	modeDebug = activ
	fileDebug = file
end
function myDebug( message )
	if modeDebug then
		print ( '|> ', message )
	end
	if fileDebug or false then
		file = io.open(fileDebug ,'a')
		file:write(message.."\r\n")
		file:close()
	end
end
function debugVal( o , niveau)
	niveau = niveau or 0
	local function indent(x)
		local ind = ''
		while x>0 do ind=ind.."\t"; x=x-1 end
		return ind
	end
	local oStr = ''
	if type(o) == "number" then
		oStr = '(n) ' .. tostring(o)
	elseif type(o) == "boolean" then
		oStr = '(b) '
		if o then oStr = oStr .. '1' else oStr = oStr .. '0' end
	elseif type(o) == "string" then
		oStr = '(s) ' .. string.format("%q", o)
	elseif type(o) == "table" then
		local first = true
		oStr = "{\n" .. indent(niveau+1)
		for k,v in pairs(o) do
			if first then first = false else  oStr = oStr .. ",\n" .. indent(niveau+1) end
			oStr = oStr .. ' '
			oStr = oStr .. debugVal(k)
			oStr = oStr .. ' = '
			oStr = oStr .. debugVal(v)
		end
		oStr = oStr .. "}"
	else
		oStr = '('..type(o)..')'
	end 
	return oStr
end

--[[ Paramètes & fonction de l'inventaire ]]--
item = {
	['safe'] = {},
	['add'] = function(nom, slot, minQte)
		if item[slot] ~= nil or item[nom] ~= nil then
			error("Impossible d'enregistrer cet item!")
		else
			item[slot] = nom
			item[nom] = slot
			item.safe[slot] = minQte
		end
	end
}
function inventaireIsFull()
	local slotVide = 16
	for slot = 1,16 do
		if turtle.getItemCount(slot) > 0 then
			slotVide = slotVide - 1
		end
	end
	return not (slotVide > 0)
end
function rangeInventaire()
	local oldSlot, selectlot, lastSlot = turtle.activeSlot, 1, 16
	while selectSlot < lastSlot do
		if turtle.getItemCount(selectSlot) > 0 then
			turtle.select(selectSlot)			
			local espaceLibre = turtle.getItemSpace(selectSlot)
			local compareSlot = 16
			while espaceLibre > 0 and compareSlot > selectSlot do
				if turtle.compareTo(compareSlot) then
					turtle.select(compareSlot)
					turtle.transferTo(selectSlot, math.min(espaceLibre, turtle.getItemCount(compareSlot)))
					turtle.select(selectSlot)
					espaceLibre = turtle.getItemSpace(selectSlot)
				end
				compareSlot = compareSlot - 1
			end
		end
		selectSlot = selectSlot + 1
	end
	turtle.select(oldSlot)
end
local collected = 0
function collect()
	collected = collected + 1
	if math.fmod(collected, 25) == 0 then
		print( collected.." items miné(s)." )
	end
end
local activSlot = 1
function select( slot )
	turtle.select(slot)
	activSlot = slot
end
function trySelect( slot )
	myDebug('trySelect( '..slot..' )')
	local slots = {}
	local nbItem = 0
	turtle.select(slot)
	for s = 16, 1, -1 do
		if (s ~= slot) then
			if turtle.compareTo(s) then
				slots[#slots+1] = s
				nbItem = nbItem + turtle.getItemCount(s)
			end
		end
	end
	slots[#slots+1] = slot
	nbItem = nbItem + turtle.getItemCount(slot)
	
	if nbItem > 1 then
		select(slots[1])
		return true
	else 
		print("plus de "..(item[slot] or slot))
		return false
	end
end
function drop( slot )
	
end
function tryDropAll()

end

--[[ fonction d'utilisation de l'inventaire ]]--
function tryPlace( slot )
	myDebug('tryPlace( '..slot..' )')
	if not turtle.detect() and  trySelect(slot) then
		return turtle.place()
	else
		return false
	end
end
function tryPlaceUp( slot )
	myDebug('tryPlaceUp( '..slot..' )')
	if not turtle.detectUp() and trySelect(slot) then
		return turtle.placeUp()
	else
		return false
	end
end
function tryPlaceDown( slot )
	myDebug('tryPlaceDown( '..slot..' )')
	if not turtle.detectDown() and trySelect(slot) then
		return turtle.placeDown()
	else
		return false
	end
end

--[[ fonctions de minage ]]--
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
function DigAround(materials, reverse)
	reverse = reverse or false
	local function multiCompare(dir, materials, reverse)
		local compareAction, detectAction = nil, nil
		if dir == 'up' then
			compareAction = turtle.compareUp
			detectAction = turtle.detectUp
		elseif dir == 'down' then
			compareAction = turtle.compareDown
			detectAction = turtle.detectDown
		elseif dir == 'front' then
			compareAction = turtle.compare
			detectAction = turtle.detect
		else
			errot ('direction incorrecte')
		end
		local compareTrue = false
		for material = 1, #materials do
			if material == nil then
				compareTrue = compareTrue or compareAction()
			else
				compareTrue = compareTrue or compareAction(material)
			end
		end
		if reverse then compareTrue =  not compareTrue end
		return compareTrue
	end
	local function _Forward()
		if multicompare('front', materials, reverse) then
			tryForward()
			DigAround(materials, reverse)
		else
			tryForward()
		end
	end
	local function _Up()
		if multicompare('up', materials, reverse) then
			tryUp()
			DigAround(materials, reverse)
		else
			tryUp()
		end
	end
	local function _Down()
		if multicompare('down', materials, reverse) then
			tryDown()
			DigAround(materials, reverse)
		else
			tryDown()
		end
	end
	local function _Level()
		for _ = 1,4 do
			_Forward()
			turnRight()
			_Forward()
		end
	end
	_Up()
	_Forward()
	turnRight()
	_Level()
	_Down()
	_Level()
	_Down()
	_Level()
	turnRight()
	_Forward()
	_Up()
	turnBack()
end

--[[ fonctions dedéplacement ]]--
function refuel()
	myDebug('refuel()')
	local fuelLevel = turtle.getFuelLevel()
	if fuelLevel == "unlimited" or fuelLevel > 0 then
		return
	end
	
	local function tryRefuel()
		local oldSlot = activSlot
		local function rf(slot)
			if trySelect(slot) then
				if turtle.refuel(1) then
					trySelect(oldSlot)
					return true
				end
			else
				trySelect(oldSlot)
				return false
			end
		end
		if item.coal ~= nil then
			return rf(item.coal)
		else
			for s = 1,16 do
				if rf(s) then return true end
			end
		end
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
function tryDown()
	myDebug('tryDown()')
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
function tryForward()
	myDebug('tryForward()')
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
function turnLeft()
	myDebug('turnLeft()')
	turtle.turnLeft()
end
function turnRight()
	myDebug('turnRight()')
	turtle.turnRight()
end
function turnBack()
	myDebug('turnBack()')
	turtle.turnLeft()
	turtle.turnLeft()
end