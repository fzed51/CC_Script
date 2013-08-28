dofile('advTurtle') -- http://pastebin.com/7mLzefhQ

setDebug(false, 'trace')
item.add('coal', 1, 64)
item.add('cobblestone', 2, 64)

print(debugVal(item))

function section(largeur, hauteur)
	
	-- Control des paramètres --
	if largeur < 1 or hauteur < 1 then
		error('La largeur et la hauteur de la section doivent être superieur à 1.')
	end
	if (largeur % 2) == 0 then
		error('La largeur doit être impaire.')
	end	
	
	-- Préparation des variables --
	local demi = math.floor(largeur/2) + 1
	local tX, tY = demi, 1
	local function etanche()
		if tX == 1 or tX == largeur then
			if tX == demi then
				turnLeft()
				tryPlace(item.cobblestone)
				turnBack()
				tryPlace(item.cobblestone)
				turnLeft()
			else
				tryPlace(item.cobblestone)
			end
		end
		if tY == 1 then
			tryPlaceDown(item.cobblestone)
		end
		if tY == hauteur then
			tryPlaceUp(item.cobblestone)
		end
	end
	local function calcDest (val, maxi)
		if val == 1 then
			return maxi, 1
		else
			return 1, -1
		end
	end
	
	-- Construction
	tryForward()
	etanche()
	
	-- centre
	while tY < hauteur do
		tryUp()
		tY = tY + 1
		etanche()
	end
	myDebug('----------> x: '.. tX ..', y: '.. tY)
	
	if largeur > 1 then
		-- gauche
		turnLeft()
		while tX > 1 do
			tryForward()
			tX = tX - 1
			myDebug('----------> x: '.. tX ..', y: '.. tY)
			etanche()
			local dest, step = calcDest(tY, hauteur)
			while tY ~= dest do
				if step > 0 then
					tryUp()
				else
					tryDown()
				end
				tY = tY + step
				etanche()
			end
		end
		-- retour au milieu
		turnBack()
		while tX < demi do
			tryForward()
			tX = tX + 1
		end
		-- droite
		while tX < largeur do
			tryForward()
			tX = tX + 1
			myDebug('----------> x: '.. tX ..', y: '.. tY)
			etanche()
			local dest, step = calcDest(tY, hauteur)
			while tY ~= dest do
				if step > 0 then
					tryUp()
				else
					tryDown()
				end
				tY = tY + step
				etanche()
			end
		end
		-- retour au milieu
		turnBack()
		while tX > demi do
			tryForward()
			tX = tX - 1
		end
		turnRight()
		
	end
	while tY > 1 do
		tryDown()
		tY = tY - 1
	end
end

local room = {
{l = 3, h = 3, p = 1},
{l = 1, h = 2, p = 1},
{l = 3, h = 3, p = 1},
{l = 7, h = 4, p = 7}}

local couloir = {
{l = 3, h = 3, p = 1},
{l = 1, h = 2, p = 1},
{l = 3, h = 3, p = 8}}

for _,v in pairs(couloir) do
	for __ = 1, v.p do
		section(v.l, v.h)
	end
end