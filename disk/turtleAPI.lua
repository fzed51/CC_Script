--Classe Turtle
turtle = {}
turtle.__index = turtle

--Méthodes
turtle.craft=function( quantity )
	print('turtle.craft(' .. quantity ..')')
	return true
end

turtle.forward = function()
	print('turtle.forward('..')')
	return true
end

turtle.back = function()
	print('turtle.back('..')')
	return true
end

turtle.up = function()
	print('turtle.up('..')')
	return true
end

turtle.down = function()
	print('turtle.down('..')')
	return true
end

turtle.turnLeft = function()
	print('turtle.turnLeft('..')')
	return true
end

turtle.turnRight = function()
	print('turtle.turnRight('..')')
	return true
end

turtle.select = function(slotNum)
	print('turtle.select('..slotNum..')')
	return true
end

turtle.getItemCount = function(slotNum)
	print('turtle.getItemCount('..slotNum..')')
	return 1
end

turtle.getItemSpace = function(slotNum)
	print('turtle.getItemSpace('..slotNum..')')
	return 1
end

turtle.attack = function()
	print('turtle.attack('..')')
	return true
end

turtle.attackUp = function()
	print('turtle.attackUp('..')')
	return true
end

turtle.attackDown = function()
	print('turtle.attackDown('..')')
	return true
end

turtle.dig = function()
	print('turtle.dig('..')')
	return true
end

turtle.digUp = function()
	print('turtle.digUp('..')')
	return true
end

turtle.digDown = function()
	print('turtle.digDown('..')')
	return true
end

turtle.place = function(signText)
	if signText == nil then
		signText = ''
	end
	print('turtle.place('..signText..')')
	return true
end

turtle.placeUp = function()
	print('turtle.placeUp('..')')
	return true
end

turtle.placeDown = function()
	print('turtle.placeDown('..')')
	return true
end

turtle.detect = function()
	print('turtle.detect('..')')
	return truefalse()
end

turtle.detectUp = function()
	print('turtle.detectUp('..')')
	return truefalse()
end

turtle.detectDown = function()
	print('turtle.detectDown('..')')
	return truefalse()
end

turtle.compare = function()
	print('turtle.compare('..')')
	return true
end

turtle.compareUp = function()
	print('turtle.compareUp('..')')
	return true
end

turtle.compareDown = function()
	print('turtle.compareDown('..')')
	return true
end

turtle.compareTo = function(slot)
	print('turtle.compareTo('..slot..')')
	return true
end

turtle.drop = function(count)
	print('turtle.drop('..count..')')
	return true
end

turtle.dropUp = function(count)
	print('turtle.dropUp('..count..')')
	return true
end

turtle.dropDown = function(count)
	print('turtle.dropDown('..count..')')
	return true
end

turtle.suck = function()
	print('turtle.suck('..')')
	return true
end

turtle.suckUp = function()
	print('turtle.suckUp('..')')
	return true
end

turtle.suckDown = function()
	print('turtle.suckDown('..')')
	return true
end

turtle.refuel = function(quantity)
	print('turtle.refuel('..quantity..')')
	return true
end

turtle.getFuelLevel = function()
	print('turtle.getFuelLevel('..')')
	return 1
end

turtle.transferTo = function(slot, quantity)
	print('turtle.('..slot..', '..quantity..')')
	return true
end

sleep = function(temps)
	print('sleep(..temps..)')
end

truefalse = function()
	if math.random() > 0.5 then
		return true
	else
		return false
	end
end
