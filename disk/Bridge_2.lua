--[[
+----------------------------------------------------------------------------+
| Bridge
| version : 2
| Auteur : fzed51
| git : https://github.com/fzed51/CC_Script/blob/master/disk/Bridge_2.lua
| pastebin : http://pastebin.com/4DZfqyQ6
+----------------------------------------------------------------------------+
| tag : [lua] [MC] [MineCraft] [CC] [ComputerCraft] [Turtle]
| Descript :
| construit un pont avec arche
+----------------------------------------------------------------------------+
]]--

dofile('advTurtle') -- http://pastebin.com/7mLzefhQ

-- inventaire
item.add('coal',1,64)
item.add('cobblestone',2,64)

--fonctions
local function round(num)
  return math.floor(num + 0.5)
end
local function makePlan( l )
	print("Creation d'un plan pour un pont de "..l.."m.")
	local plan = {}
	-- calcul hauteur max d'un pilier
	local hMax = 63
	if l*2 > hMax then hMax = l*2 end
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
		plan[#plan+1] = hMax
		for position = -1*((lArche-3)/2), ((lArche-3)/2) do
			local pos, rArche =math.abs(position), (lArche-2)/2
			plan[#plan+1] = 2 + ( rArche - round(( rArche^2 - pos^2 )^0.5 ))
		end
		plan[#plan+1] = hMax
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
local function construitSection( epaisseur )	
	local alt  = 0
	local dig  = 0
	local stop = false
	while not stop and ( alt > -2 or dig < 2 ) and epaisseur + alt > 0 do
		if turtle.detectDown() then
			dig = dig + 1
		else 
			dig = 0
		end
		if tryDown() then
			alt = alt - 1
		else
			stop = true
		end
	end
	while alt < 0 do
		if alt >= -2 then
			turnLeft()
			tryDig()
			tryPlace(item.cobblestone)
			turnBack()
			tryDig()
			tryPlace(item.cobblestone)
			turnLeft()
		end
		tryUp()
		alt = alt + 1
		tryPlaceDown(item.cobblestone)
	end
end
local function countBlock( plan, idx )
	local nbBlock = 0
	if idx == nil or idx > #plan then idx = #plan end
	for i = 1, idx do
		nbBlock = nbBlock + plan[i]
	end
	return nbBlock
end
local function refeelInv( position )
	local p = position
	while p>0 do
		tryForward()
		p=p-1
	end
	print('Rechargez mon inventaire!')
	print('Appuyez sur une touche pour continuer.')
	os.pullEvent('key')
	turnBack()
	while p<position do
		tryForward()
		p=p+1
	end
	turnBack()
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
		tryForward()
		longueurPont = longueurPont + 1
		tryDigUp()
	until turtle.detectDown()
	turnBack()
	local plan = makePlan( longueurPont )
	local nbBlockTotal = countBlock( plan )
	print ('Début de la construction du pont')
	for p = longueurPont, 1, -1 do
		local nbBlock = countBlock( plan, p )
		print ('avancement : '..tostring(round((nbBlockTotal-nbBlock)*100/nbBlockTotal))..'%')
		if itemCount( item.cobblestone ) < (plan[p]+4) then
			refeelInv(p)
		end
		tryForward()
		construitSection(plan[p])
	end		
end
--main
term.clear()
term.setCursorPos(1,1)
local head = 
[[
"""""""""""                                                         """"""""
"""""""""""""""#################+---------------+#################"""""""""" 
""""""""""""""""################|  bridge v2.0  |################""""""""""" 
"""""""""""""""""###############+---------------+###############""""""""""""
"""""""""""""""""""###########   ################   ##########""""""""""""""
""""""""""""""""""""""#####         ##########         ######"""""""""""""""
"""""""""""""""""""""""""#           ########           ####""""""""""""""""
""""""""""""""""""""""""""""          ######             ##"""""""""""""""""
"""""""""""""""""""""""""""""""        ####               """"""""""""""""""
"""""""""""""""""""""""""""""""""""""""""~~~~~~~~~~~~~~"""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""~~~~~~~~~~~~""""""""""""""""""""""""]]
print (head)
bridge()