-- logging v0.1
-- fzed51

-- setup :
-- d = dirt
-- w = water
-- T = turtle
-- s = sapling
-- _ = vide
-- niv 0
-- |d|d|d|d|d|d|d|
-- |d|_|_|_|_|w|d|
-- |d|_|_|_|_|_|d|
-- |d|_|_|d|_|_|d|
-- |d|_|_|_|_|_|d|
-- |d|_|_|_|_|_|d|
-- |d|d|d|d|d|d|d|
-- niv 1
-- |_|_|_|_|_|_|_|
-- |_|_|_|_|_|_|_|
-- |_|_|_|_|_|_|_|
-- |_|_|_|s|_|_|_|
-- |_|_|_|_|_|_|_|
-- |_|T|_|_|_|_|_|
-- |_|_|_|_|_|_|_|   

-- item slot
coal = 1
sapling = 2

local function logging()
	turtle.forward()
	turtle.forward()
	turtle.turnRight()
	turtle.forward()
	if not turtle.detect() then
		-- tryPlace(sapling)
	end
	turtle.up()
	if turtle.detect() then
		local elevation = 0
		tryForward()
		tryDigDown()
		while turtle.detectUp() do
			if tryUp() then elevation = elevation + 1 end
		end
		while elevation > 0 do
			if tryDown() then elevation = elevation - 1 end
		end
		turtle.back()
	end
	
	if not turtle.detect() then
		-- tryPlace(sapling)
	end
	turtle.back()
	turtle.turnLeft()
	turtle.back()
	turtle.back()
end

while true do
	logging()
	for _ = 1, 60 do
		turtle.suckDown()
		os.sleep(1)
	end
end