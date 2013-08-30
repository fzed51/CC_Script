--[[
+----------------------------------------------------------------------------+
| Bridge
| version : 2
| Auteur : fzed51
| git : https://github.com/fzed51/CC_Script/blob/master/disk/Bridge_2.lua
| pastebin : 
+----------------------------------------------------------------------------+
| tag : [lua] [MC] [MineCraft] [CC] [ComputerCraft] [Turtle]
| Descript :
| construit un pont avec arche
+----------------------------------------------------------------------------+
]]--

--dofile('advTurtle') -- http://pastebin.com/7mLzefhQ

--inventaire
--item.add('coal',1,64)
--item.add('cobblestone',2,64)

--fonctions
local function round(num)
  return math.floor(num + 0.5)
end
local function makePlan( l )
	print("Creation d'un plan pour un pont de "..l.."m.")
	local plan = {}
	-- calcul longueur d'une arche
	local tailles,lArche = {19,18,17,16,15,14,13,12,11,10},0
	local r = tailles[1]
	for _,v in ipairs(tailles) do
		if r < (l-(l%v)) then 
			r = (l-(l%v))
			lArche = v
		end
	end
	print('Le pont aura des arches de '..lArche..'m de long.')
	local nbArche = math.ceil(l/lArche)
	for arche = 1, nbArche do
		plan[#plan+1] = 77
		for position = -1*((lArche-3)/2), ((lArche-3)/2) do
			local pos, rArche =math.abs(position), (lArche-2)/2
			plan[#plan+1] = 2 + ( rArche - round(( rArche^2 - pos^2 )^0.5 ))
		end
		plan[#plan+1] = 77
	end
	while #plan > l do
		if #plan%2 == 0 then
			table.remove(plan)
		else
			table.remove(plan, 1)
		end
	end
	return plan
end

local function printPlan( p )
	print('Plan pour un pont de '..#p..'m de long.')
	for _, n in ipairs( p ) do
		local nN, sP = n, '##'
		while nN > 0 do
			nN = nN - 1
			sP = sP .. '+'
		end
		print(sP)
	end
end

--main function
local function bridge()
	local longueurPont, plan = 0, {}
	repeat
		--tryForward()
		longueurPont = longueurPont + 1
		--tryDigUp()
	until false--turtle.detectDown()
	--turnBack()
end

--main
math.randomseed( os.time() )
for _=1,10 do math.random() end
printPlan(makePlan(math.random(128)))
