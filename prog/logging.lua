dofile('advTurtle')

item.add('coal', 1, 64)
item.add('sapling', 2, 64)
item.add('wood', 3, 1)

local function timber()
	local hauteur = 0
	trySelect(item.wood)
	while turtle.compare(item.wood) do
		tryDig()
		if tryUp() then hauteur = hauteur + 1 end
	end
	while hauteur > 0 do
		if tryDown() then hauteur = hauteur - 1 end		
	end
end

local function control()
	turnLeft()
	if not turtle.detect() then
		tryPlace(item.sapling)
	end
	timber()
	turnBack()
	if not turtle.detect() then
		tryPlace(item.sapling)
	end
	timber()
	turnLeft()
end

local function recuperreSapling()
	turnRight()
	turtle.suck()
	turnBack()
	turtle.suck()
	turnRight()
end

local function isOn()
	local on = false
	for _,side in pairs(redstone.getSides()) do
		on = on or redstone.getInput(side)
	end
	return on
end

local n, nb = 0, 4

while true do
	if isOn() then
		for _ = 1,4 do
			while n < nb do
				tryForward()
				tryForward()
				control()
				n=n+1
			end
			turnBack()
			while n > 0 do
				tryForward()
				recuperreSapling()
				tryForward()
				n=n-1
			end
			turnRight()
		end
	else
		print('Pause ...')
	end
	os.sleep(200)
end