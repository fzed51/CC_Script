turtle.posX = 0
turtle.posY = 0
turtle.posZ = 0
turtle.dir  = 0
turtle.mouv = {{1,0},{0,1},{-1,0},{0,-1}}

function tryForward( force )
	local function _go()
		local function __go()
			if turtle.forward() then
				mouvX, mouvY = turtle.mouv[turtle.dir]
				turtle.posX = turtle.posX + mouvX
				turtle.posY = turtle.posY + mouvY
				return true
			else
				return false
			end
		end
		-- gestion du fuel
		return __go()
	end
	-- gestion du minage
	return _go()
end

function goBack( force )
	local function _goBack()
		local function _goBack()
			if turtle.back() then
				mouvX, mouvY = turtle.mouv[turtle.dir]
				turtle.posX = turtle.posX - mouvX
				turtle.posY = turtle.posY - mouvY
				return true
			else
				return false
			end
		end
		-- gestion du fuel
		return __goBack()
	end
	-- gestion du minage
	return _goBack()
end

function goUp( force )
	local function _goUp()
		local function __goUp()
			if turtle.up() then
				turtle.posZ = turtle.posZ + 1
				return true
			else
				return false
			end
		end
		-- gestion du fuel
		return __goUp()
	end
	-- gestion du minage
	return _goUp()
end

function goDown( force )
	local function _goDown()
		local function __goDown()
			if turtle.down() then
				turtle.posZ = turtle.posZ - 1
				return true
			else
				return false
			end
		end
		-- gestion du fuel
		return __goUp()
	end
	-- gestion du minage
	return _goUp()
end

function turnRight()
	turtle.turnRight()
	turtle.dir = (turtle.dir + 1) % 4
end

function turnLeft()
	turtle.turnLeft()
	turtle.dir = (turtle.dir - 1) % 4
end

function goTo( destination, ordres )
	ordres = ordres or 'xyz'
	destX, destY, destZ, destD = destination
	for n = 1,3 do
		ordre = string.sub(ordres, n, 1)
		if ordre == 'x' then
			if destX ~= turtle.posX then
				if destX < turtle.posX then
					while turtle.dir ~= 2 do
						turnRight()
					end
				else
					while turtle.dir ~= 0 do
						turnRight()
					end
				end
			end
			while destX ~= turtle.posX do
				go()
			end
		end
		if ordre == 'y' then
			if destY != turtle.posY then
				if destY < turtle.posY then
					while turtle.dir ~= 3 do
						turnRight()
					end
				else
					while turtle.dir ~= 1 do
						turnRight()
					end
				end
			end
			while destY ~= turtle.posY do
				go()
			end
		end
		if ordre == 'z' then
			if destZ ~= turtle.posZ then
				if destZ < turtle.posZ then
					while destZ ~= turtle.posZ do
						goDown()
					end
				else
					while destZ ~= turtle.posZ do
						goUp()
					end
				end
			end
		end
	end
end

go()
goBack()
goUp()
goDown()
turnRight()
turnLeft()