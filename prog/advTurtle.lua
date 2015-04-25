--[[
+----------------------------------------------------------------------------+
| advTurtle
| version : 3
| Auteur : fzed51
| git : https://github.com/fzed51/CC_Script/blob/master/disk/advTurtle.lua
| pastebin : http://pastebin.com/????????
+----------------------------------------------------------------------------+
| tag : [lua] [MC] [MineCraft] [CC] [ComputerCraft] [Turtle]
| Description :
| bibliotèque de fonction pour la turtle.
+----------------------------------------------------------------------------+
]]--

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
		if o then oStr = oStr .. 'O' else oStr = oStr .. 'N' end
	elseif type(o) == "string" then
		oStr = '(s) ' .. string.format("%q", o)
	elseif type(o) == "table" then
		local first = true
		oStr = "{\n" .. indent(niveau+1)
		for k,v in pairs(o) do
			if first then first = false else  oStr = oStr .. ",\n" .. indent(niveau+1) end
			oStr = oStr .. ' '
			oStr = oStr .. debugVal(k,niveau+1)
			oStr = oStr .. ' = '
			oStr = oStr .. debugVal(v,niveau+1)
		end
		oStr = "\n" .. indent(niveau) .. oStr .. "}"
	else
		oStr = '('..type(o)..')'
	end 
	return oStr
end
--[[ Fonction diverses ]]--
function Set (list)
  local set = {}
  for _, item in ipairs(list) do set[item] = true end
  return set
end
--[[ Paramètes & fonction de l'inventaire ]]--
function getItemNameInSlot( slot )
	myDebug('getItemNameInSlot( '..slot..' )')
	d = turtle.getItemDetail(slot)
	if d then
		return d.name
	end
	return nil
end
function itemCount( items )
	myDebug('itemCount( '..'items'..' )')
	local nbItem = 0
	typeItem = type(items)
	for s = 1, 16 do
		if ('table' == typeItem and items[getItemNameInSlot(s)]) or('table' ~= typeItem and getItemNameInSlot(s) == items) then
			nbItem = nbItem + turtle.getItemCount(s)
		end
	end
	return nbItem
end
local collected = 0
function collect()
	collected = collected + 1
	if math.fmod(collected, 25) == 0 then
		print( collected.." items miné(s)." )
	end
end
function activSlot( ... )
	return turtle.getSelectedSlot()
end
function select( slot )
	turtle.select(slot)
end
function trySelect( items )
	myDebug('trySelect( '..'items'..' )')
	typeItem = type(items)
	for s = 16, 1, -1 do
		if ('table' == typeItem and items[getItemNameInSlot(s)]) or('table' ~= typeItem and getItemNameInSlot(s) == items) then
			select(s)
			return true
		end
	end
	print("plus de ".. 'items' )
	return false
end
function inventaireIsFull() 
	myDebug('inventaireIsFull()')
	local slotVide = 16
	for slot = 1,16 do
		if turtle.getItemCount(slot) > 0 then
			slotVide = slotVide - 1
		end
	end
	return not (slotVide > 0)
end
function rangeInventaire()
	myDebug('rangeInventaire()')
	local oldSlot, selectSlot, lastSlot = activSlot, 1, 16
	while selectSlot < lastSlot do
		if turtle.getItemCount(selectSlot) > 0 then
			select(selectSlot)			
			local espaceLibre = turtle.getItemSpace(selectSlot)
			local compareSlot = 16
			while espaceLibre > 0 and compareSlot > selectSlot do
				if turtle.compareTo(compareSlot) then
					select(compareSlot)
					turtle.transferTo(selectSlot, math.min(espaceLibre, turtle.getItemCount(compareSlot)))
					select(selectSlot)
					espaceLibre = turtle.getItemSpace(selectSlot)
				end
				compareSlot = compareSlot - 1
			end
		end
		while turtle.getItemCount(lastSlot) == 0 do
			lastSlot = lastSlot - 1
		end
		selectSlot = selectSlot + 1
	end
	select(oldSlot)
end

--[[ fonction d'utilisation de l'inventaire ]]--
function tryPlace( item )
	myDebug('tryPlace( '..'item'..' )')
	if not turtle.detect() and  trySelect(item) then
		return turtle.place()
	else
		return false
	end
end
function tryPlaceUp( item )
	myDebug('tryPlaceUp( '..'item'..' )')
	if not turtle.detectUp() and trySelect(item) then
		return turtle.placeUp()
	else
		return false
	end
end
function tryPlaceDown( item )
	myDebug('tryPlaceDown( '..'item'..' )')
	if not turtle.detectDown() and trySelect(item) then
		return turtle.placeDown()
	else
		return false
	end
end
function drop( slot )
	myDebug('drop()')
end
function tryDropAll()
	myDebug('tryDropAll()')
end

--[[ fonctions de minage ]]--
function tryDig()
	myDebug('tryDig()')
	while turtle.detect() do
		if turtle.dig() then
			turtle.suck()
			collect()
			sleep(0.1)
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
			turtle.suckUp()
			collect()
			sleep(0.1)
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
			sleep(0.1)
		else
			return false
		end
	end
	return true
end
function DigAround(materials, reverse)
	myDebug('DigAround('..tostring(materials)..', '..tostring(reverse)..')')
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
local fuel = Set {
	'minecraft:sapling',
	'minecraft:coal',
	'minecraft:coal_block',
	'minecraft:log'
}
function setFuelItem(newFuelItem)
	myDebug('setFuelItem('..newFuel..')')
	fuel[newFuelItem] = true
end
function refuel(reserve)
	if type(reserve) == 'nil' then reserve = 0 end
	myDebug('refuel('.. reserve ..')')
	local fuelLevel = turtle.getFuelLevel()
	local oldSlot = activSlot()
	local function tryRefuel()
		if trySelect( fuel ) then
			return turtle.refuel(1)
		end
		return false
	end

	if fuelLevel == "unlimited" or fuelLevel > reserve then
		return
	end
	while fuelLevel <= reserve do
		if not tryRefuel() then
			print( "Ajout plus de fuel pour continuer." )
			while not tryRefuel() do
				sleep(1)
			end
		end
		fuelLevel = turtle.getFuelLevel()
	end
	select(oldSlot)
end
-- Iniertial unit
inertialUnit = {
	['x'] = 0,
	['y'] = 0,
	['z'] = 0,
	['d'] = 0,
	['mouv'] = { 
		[0]   = { 0, 0, 1},
		[1]   = { 1, 0, 0},
		[2]   = { 0, 0,-1},
		[3]   = {-1, 0, 0},
		['u'] = { 0, 1, 0},
		['d'] = { 0,-1, 0}
	}
}
function inertialUnit:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end
function inertialUnit.__tostring(self)
	return "[ Object inertialUnit {x : ".. self.x ..", y : ".. self.y ..", z : ".. self.z ..", delta : ".. self.d .."} ]"
end
function inertialUnit:getPos()
  return self.x, self.y, self.z, self.d
end
function inertialUnit:setPos(x, y, z, d)
  self.x = x
  self.y = y
  self.z = z
  self.d = d
end
function inertialUnit:deplace (mouv)
	self.x = self.x + mouv[1]
	self.y = self.y + mouv[2]
	self.z = self.z + mouv[3]
end
function inertialUnit:tourne (angle)
	self.d = ( self.d + angle ) % 4
end
function inertialUnit:forward()
	self:deplace( self.mouv[ self.d ] )
end
function inertialUnit:back()
	self:deplace( self.mouv[ ( self.d + 2 ) % 4 ] )
end
function inertialUnit:up()
	self:deplace( self.mouv[ 'u' ] )
end
function inertialUnit:down()
	self:deplace( self.mouv[ 'd' ] )
end
function inertialUnit:right()
	self:tourne( 1 )
end
function inertialUnit:left()
	self:tourne( -1 )
end
turtle.IU = inertialUnit:new()

function tryUp(autoDig)
	if autoDig == nil then autoDig = true end
	myDebug('tryUp()')
	refuel()
	local try = 10
	while not turtle.up() do
		if (not autoDig) or try < 0 then return false end
		if autoDig and turtle.detectUp() then
			if not tryDigUp() then
				return false
			end
		elseif turtle.attackUp() then
			collect()
			try=try-1
		else
			sleep( 0.5 )
			try=try-1
		end
	end
	turtle.IU:up()
	return true
end
function tryDown(autoDig)
	if autoDig == nil then autoDig = true end
	myDebug('tryDown()')
	refuel()
	local try = 10
	while not turtle.down() do
		if (not autoDig) or try < 0 then return false end
		if autoDig and turtle.detectDown() then
			if not tryDigDown() then
				return false
			end
		elseif turtle.attackDown() then
			collect()
			try=try-1
		else
			sleep( 0.5 )
			try=try-1
		end
	end
	turtle.IU:down()
	return true
end
function tryForward(autoDig)
	if autoDig == nil then autoDig = true end
	myDebug('tryForward()')
	refuel()
	local try = 10
	while not turtle.forward() do
		if (not autoDig) or try < 0 then return false end
		if autoDig and turtle.detect() then
			if not tryDig() then
				return false
			end
		elseif turtle.attack() then
			collect()
			try=try-1
		else
			sleep( 0.5 )
			try=try-1
		end
	end
	turtle.IU:forward()
	return true
end
function turnLeft()
	myDebug('turnLeft()')
	turtle.IU:left()
	turtle.turnLeft()
end
function turnRight()
	myDebug('turnRight()')
	turtle.IU:right()
	turtle.turnRight()
end
function turnBack()
	myDebug('turnBack()')
	turtle.IU:left()
	turtle.turnLeft()
	turtle.IU:left()
	turtle.turnLeft()
end
