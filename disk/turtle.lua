--Classe Turtle
Turtle = {}
Turtle.__index = Turtle

--Constructeur
function Turtle.new()
	local turtle = {}
	setmetatable(turtle, Turtle)
	turtle.store = Store.new()
	return turtle
end

--Méthodes
function Turtle:forward()
	print( 'forward()' )
	return true
end

function Turtle:back()
	print( 'back()' )
	return true
end

function Turtle:up()
	print( 'up()' )
	return true
end

function Turtle:down()
	print( 'down()' )
	return true
end

function Turtle:turnLeft()
	print( 'turnLeft()' )
	return true
end

function Turtle:turnRight()
	print( 'turnRight()' )
	return true
end

function Turtle:attack()
	print( 'attack()' )
	return true
end
function Turtle:attackUp()
	print( 'attackUp()' )
	return true
end
function Turtle:attackDown()
	print( 'attackDown()' )
	return true
end
function Turtle:select( numSlot )
	print( 'select('.. numSlot ..')' )
	return self.store:select(numSlot)
end

function Turtle:getItemCount( numSlot )
	print( 'getItemCount('.. numSlot ..')' )
	return self.store:getItemCount(numSlot)
end

function Turtle:getItemSpace( numSlot )
	print( 'getItemSpace('.. numSlot ..')' )
	return self.store:getItemSpace(numSlot)
end

--Classe Store
Store = {}
Store.__index = Store

--Constructeur
function Store.new()
	local store = {}
	setmetatable(store, Store)
	store.slotSelect = 1
	store.slots = {	Slot.new(), Slot.new(), Slot.new(), Slot.new(),
					Slot.new(), Slot.new(), Slot.new(), Slot.new(),
					Slot.new(), Slot.new(), Slot.new(), Slot.new(),
					Slot.new(), Slot.new(), Slot.new(), Slot.new() }
	return store
end

--Méthodes
function Store:select( numSlot )
	if numSlot >= 1 and numSlot <= 16 then
		self.slotSelect = numSlot
		return true
	else
		return false
	end
end

function Store:getItemCount( numSlot )
	if numSlot >= 1 and numSlot <= 16 then
		local slot = self.slots[numSlot]
		return slot.qte
	else
		return 0
	end
end

function Store:getItemSpace( numSlot )
	if numSlot >= 1 and numSlot <= 16 then
		local slot = self.slots[numSlot]
		return 64 - slot.qte
	else
		return 0
	end
end

function Store:add( Element, qte )
	if qte == nil then qte = 1 end
	for n=1,16 do

	end
end

--Classe Slot
Slot = {}
Slot.__index = Slot

--Constructeur
function Slot.new()
	local slot = {}
	setmetatable(slot, Slot)
	slot.type = ''
	slot.qte = 0
	return slot
end

local turtle = Turtle.new()
print(turtle:getItemSpace(1))
