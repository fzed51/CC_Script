local direction = 0 					-- direction
local drapeauBedrock = false 			-- indicateur pour savoir si on est arrivé à la bedrock
local profondeur = 0 					-- indique de combien on a creusé
local longueur = 9						-- indique la longueur (x) de la zone à miner
local largeur = 9						-- indique la largeur (y) de la zone à miner
local xPosition = 0						-- indique la position courante en x
local zPosition = 0						-- indique la position courante en z
local niveauFuelMini = 5 				-- niveau de déplacements auquel on doit refaire le plein de fuel
local niveauCharbonMini = 5				-- quantité de charbons restants à laquelle on doit refaire le plein de charbon

local premierSlot = 4 					-- premier slot où se trouve le minerai ramassé
local dernierSlot = 13 					-- dernier slot à surveiller pour enclencher le vidage de l'inventaire
local enderchestSlot = 14 				-- slot où se trouve l'enderchest pour les minerais
local enderchestCharbonSlot = 15 		-- slot où se trouve l'enderchest pour les minerais
local charbonSlot = 16					-- slot ou est stocké le charbon

local plan = {}							-- tableau pour stocker les coordonnées relatives des puits de minage.

local idAffichage = 22					-- id du computer vers lequel on envoie les infos par rednet

function compare_mine() 				-- fonction qui compare et mine, tourne à droite et direction++

	local slot = 0
	local resultat = false
	
	for slot=1,3 do
		turtle.select(slot)
		if turtle.compare() or resultat then
			resultat = true
		end
	end
	
	if resultat == false then
		turtle.dig()
		if turtle.getItemCount(dernierSlot) > 0 then  -- on vérifie si on doit vider l'inventaire de la tortue
			print("vidage inventaire comp_mine; prof "..profondeur.." ; nbitem ds slot "..dernierSlot.." : "..turtle.getItemCount(dernierSlot).." ; ")
			videInventaire()
		end
	end
	
	turtle.turnRight()
	direction=direction+1
	
end

function verifFuel() 					-- vérifie si on a assez de fuel (déplacements) en réserve.
  -- 1 charbon = 96 deplacements
  -- On vérifie le niveau de fuel
	local niveauFuel = turtle.getFuelLevel()
	if (niveauFuel ~= "unlimited") then
		if (niveauFuel < niveauFuelMini) then
			-- On a besoin de faire le plein
			if turtle.getItemCount(charbonSlot) < niveauCharbonMini then
				rechargeCharbon() -- on refait le plein de charbon
			end
			turtle.select(charbonSlot)
			turtle.refuel(1) -- on recharge pour 96 deplacements
		end
	end
end 

function rechargeCharbon() 				-- permet de refaire le plein en charbon
	
	turtle.dig()
	
	if turtle.getItemCount(dernierSlot-1) > 0 then  -- on vérifie si on doit vider l'inventaire de la tortue
			print("vidage inventaire rech_charbon1; prof "..profondeur.." ; nbitem ds slot "..dernierSlot.." : "..turtle.getItemCount(dernierSlot).." ; ")
			videInventaire()
	end
	
	turtle.select(enderchestCharbonSlot)
	turtle.placeUp()
	turtle.select(charbonSlot)
	turtle.suckUp()
	
	turtle.select(enderchestCharbonSlot)
	turtle.digUp()
	
end

function videInventaire() 				-- vide l'inventaire de la tortue dans l'enderchest dédié à ça

	local slot
	turtle.select(enderchestSlot)
	turtle.placeUp()
	for slot=premierSlot,dernierSlot do
		turtle.select(slot)
		while turtle.getItemCount(slot) > 0 do
			turtle.dropUp(turtle.getItemCount(slot))
			if turtle.getItemCount(slot) > 0 then
				sleep(0.5)
			end
		end
	end

	turtle.select(enderchestSlot)
	turtle.digUp()
	
end

function calcPlan() 					-- calcule les emplacements des puits de minage

	local x, z, temp, xTemp
	temp = 1
	-- pour forcer à miner le point de départ
	plan[temp] = {}
	plan[temp][1] = 0
	plan[temp][2] = 0
	temp = temp + 1
	
	-- on boucle sur les colonnes
	for z=0,largeur do
		x = 0
		print("z : "..z)
		
		--on calcule le x du 1er premier puit de minage pour la colonne z
		x = 5 - (z*2) +x
		while x < 0 do
			x = x + 5
		end
		plan[temp] = {}
		plan[temp][1] = x
		plan[temp][2] = z
		temp = temp + 1
		print("x : "..x)

		-- et ensuite on trouve automatiquement les autres emplacements de la colonne z
		while x <= longueur do
			x = x + 5
			if x <= longueur then
				plan[temp] = {}
				plan[temp][1] = x
				plan[temp][2] = z
				temp = temp + 1
				print("x : "..x)
			end
		end
		z = z + 1
	end
end

function deplacement(r,s) 				-- pour aller à des coordonnées précises

	local nbX
	local nbZ
	local function dirTo (dir)
		local dif = (direction - dir)
		if dif == 1 or dif == -3 then
			turtle.turnLeft()
			direction = direction - 1
		elseif dif == -1 or dif == 3 then
			turtle.turnRight()
			direction = direction + 1
		elseif math.abs(dif) == 2 then
			turtle.turnRight()
			turtle.turnRight()
			direction = direction + 2
		end
		direction = direction % 4
	end
-- On commence par se déplacer en x
	print("r : "..r.." ; s : "..s)
	print("xPosition : "..xPosition.." ; zPosition : "..zPosition)
	
	r = tonumber(r)
	s = tonumber(s)
	
	if r > xPosition then
		nbX = r - xPosition
		print("dans r>= xposition")
		dirTo(0)
	elseif r < xPosition then
		nbX = xPosition - r
		print("dans xposition > r")
		dirTo(2)
	end
	
	if r ~= xPosition then
		print("nbX : "..nbX)
		while nbX > 0 do
			if not turtle.forward() then
				turtle.dig() -- ici, on n'a pas réussi à avancer, donc on creuse devant soit pour dégager le passage
				if turtle.getItemCount(dernierSlot) > 0 then  -- on vérifie si on doit vider l'inventaire de la tortue
					print("vidage inventaire comp_mine; prof "..profondeur.." ; nbitem ds slot "..dernierSlot.." : "..turtle.getItemCount(dernierSlot).." ; ")
					videInventaire()
				end
				turtle.forward()
			end
			if direction == 0 then xPosition = xPosition + 1 else xPosition = xPosition - 1 end
			verifFuel()
			nbX = nbX - 1
		end
	end

-- Ensuite on fait le déplacement en z
	
	if s > zPosition then
		nbZ = s - zPosition
		
		dirTo(1)
	elseif s < zPosition then
		nbZ = zPosition - s
		
		dirTo(3)
	end
	
	if s ~= zPosition then
		while nbZ > 0 do
			if not turtle.forward() then
				turtle.dig() -- ici, on n'a pas réussi à avancer, donc on creuse devant soit pour dégager le passage
				if turtle.getItemCount(dernierSlot) > 0 then  -- on vérifie si on doit vider l'inventaire de la tortue
					print("vidage inventaire comp_mine; prof "..profondeur.." ; nbitem ds slot "..dernierSlot.." : "..turtle.getItemCount(dernierSlot).." ; ")
					videInventaire()
				end
				turtle.forward()
			end
			if direction == 1 then zPosition = zPosition + 1 else zPosition = zPosition - 1 end
			verifFuel()
			nbZ = nbZ - 1
		end
	end
	
	--on se remet en direction "zéro"
	dirTo(0)

end

--********************************************--
--********** Programme principal *************--
--********************************************--

print("Entrez les dimensions de la zone à miner.")
print("")
print("Largeur (vers la droite) : ")
largeur = tonumber(read())
print("Longueur (en face) : ")
longueur = tonumber(read())

calcPlan() -- on calcule les emplacements des puits de forage

local p, pmax = 1, #plan

-- ici, affichage du nombre de puits à creuser et attente confirmation pour commencer
-- puis à chaque down ou up, affichage de la profondeur et màj du "puit en cours/nb puits total"
-- et affichage lorsqu'on vide l'inventaire ou que l'on reprend du charbon

rednet.open("right")
rednet.send(idAffichage,"etat:attente")
print("")
print("Nombre de puits à creuser : "..#plan)
rednet.send(idAffichage,"nbPuitsTotal:"..#plan)
rednet.send(idAffichage,"profondeur:"..profondeur)
print("Appuyez sur [ENTREE] pour commencer !")
read()
rednet.send(idAffichage,"etat:encours")
read()

while p <= pmax do
	
	rednet.send(idAffichage,"nbPuits:"..p)
	drapeauBedrock = false --avant tout, on reset ce flag
	deplacement(plan[p][1],plan[p][2]) -- puis on se déplace sur le 1er puit à forer
	turtle.digDown() --creuse le bloc dessous
	sleep(0.2)
	turtle.down() --descend d'un cran
	profondeur = profondeur+1
	rednet.send(idAffichage,"profondeur:"..profondeur)
	verifFuel()

	while drapeauBedrock == false do

		-- ici, direction = 0
		while direction~=4 do
			--compare et mine, tourne à droite et direction++
			compare_mine()
		end
		direction=0
		
		if turtle.detectDown() == true then   -- on vérifie si il y a un bloc en dessous
			if turtle.digDown() == false then -- si on n'arrive pas à creuser en dessous, alors c'est la bedrock
				drapeauBedrock = true		  -- donc je met le drapeau à true pour sortir de la boucle
				print("bedrock !")
			else
				if turtle.getItemCount(dernierSlot) > 0 then  -- on vérifie si on doit vider l'inventaire de la tortue
					print("vidage inventaire princ1; prof "..profondeur.." ; nbitem ds slot "..dernierSlot.." : "..turtle.getItemCount(dernierSlot).." ; ")
					videInventaire()
				end
				turtle.down()
				profondeur = profondeur+1
				rednet.send(idAffichage,"profondeur:"..profondeur)
				verifFuel()
			end
		else					-- si il n'y a pas de bloc alors c'est de l'air, de l'eau ou de la lave
			turtle.down()		-- alors on descend simplement (la tortue ne craint pas la lave ou l'eau) et on continue à miner
			profondeur = profondeur+1
			rednet.send(idAffichage,"profondeur:"..profondeur)
			verifFuel()
		end
		
	end
	
	print("fin de la boucle "..profondeur)
	-- ici je remonte à la surface
	while profondeur ~= 0 do
		if turtle.detectUp() then turtle.digUp() end
		turtle.up()
		profondeur = profondeur-1
		rednet.send(idAffichage,"profondeur:"..profondeur)
		verifFuel()
	end
	
	p = p + 1
end

rednet.send(idAffichage,"etat:retour")
deplacement(0,0) -- retour au point de départ
rednet.send(idAffichage,"etat:fin")
rednet.close(right)