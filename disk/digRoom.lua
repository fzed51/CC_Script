--[[
+----------------------------------------------------------------------------+
| digRoom
| version : 1.2
| Auteur : fzed51
| git : https://github.com/fzed51/CC_Script/blob/master/disk/digRoom.lua
| pastebin : http://pastebin.com/nDpbk312
+----------------------------------------------------------------------------+
| tag : [lua] [MC] [MineCraft] [CC] [ComputerCraft] [Turtle]
| Description :
| script permetant de creuser une pièce dans un sous-sol
| les differante pièce sons stockées dans un plan ( room, couloir, bigRoom )
+----------------------------------------------------------------------------+
]]--

dofile('advTurtle') -- http://pastebin.com/7mLzefhQ

local arg = {...}
local room = arg[1]

item.add('coal', 1, 64)
item.add('cobblestone', 2, 64)

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

local patern = {}
patern.room = {
{l = 3, h = 3, p = 1},
{l = 1, h = 2, p = 1},
{l = 3, h = 3, p = 1},
{l = 7, h = 4, p = 7}}
patern.bigroom = {
{l = 3, h = 3,  p = 1},
{l = 1, h = 2,  p = 1},
{l = 3, h = 3,  p = 1},
{l = 7, h = 11, p = 7}}
patern.couloir = {
{l = 3, h = 3, p = 1},
{l = 1, h = 2, p = 1},
{l = 3, h = 3, p = 8}}

-- control du paramètre et usage
if patern[room] == nil then
	local str, v = "Usage :\n digRoom [", ''
	for k in pairs(patern) do
		str = str .. v .. k
		v = '|'
	end
	str = str .. ']'
	print(str)
	os.exit(1)
end

for _,v in pairs(patern[room]) do
	for __ = 1, v.p do
		section(v.l, v.h)
	end
end
