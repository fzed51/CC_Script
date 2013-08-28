--[[--
------	optiMine
------	Mine optimisée
------	Fabien "fzed51" SANCHEZ
------	@2013
------	version : 0.1A
--]]--

t = dofile('turtleAPI.lua')
giro = loadfile('giro.lua')

avancer()

--[[	Classe	]]--

-- Inventaire (singleton)
Inventaire = {
	initStart = {},
	qteMemo   = {},
	typeItem  = {}
}
Inventaire.__index = Inventaire
Inventaire.init = function(self)
	local tInventaire = {}
	for slot=1, 16 do
		if turtle.getItemCount(slot) > 0 then
			tInventaire[slot] = true
		else
			tInventaire[slot] = false
		end
	end
	self.initStart = tInventaire
	self:memo()
end

Inventaire.memo = function (self)
	local tInventaire = {}
	for slot=1, 16 do
		tInventaire[slot] = turtle.getItemCount(slot)
	end
	self.qteMemo = tInventaire
end

Inventaire.setType = function(self)
	local tInventaire = {"", "", "", "",
						 "", "", "", "",
						 "", "", "", "",
						 "", "", "", ""}
	local lstType = {"A", "B", "C", "D",
					 "E", "F", "G", "H",
					 "I", "J", "K", "L",
					 "M", "N", "O", "P"}
	local activType = 1
	for slot=1, 16 do
		if tInventaire[slot] == "" and turtle.getItemCount(slot) > 0 then
			tInventaire[slot] = lstType[activType]
			for slotSuiv = slot, 16 do
				turtle.select(slot)
				if tInventaire[slot] == "" and turtle.getItemCount(slot) > 0 and turtle.compareTo(slotSuiv) == true then
					tInventaire[slotSuiv] = lstType[activType]
				end
			end
		end
		activType = activType + 1
	end
	self.typeItem = tInventaire
end

--[[	Constante	]]--

--[[ Variable 		]]--
local pas
local largeur
local hauteur
local posX
local posY
local profond
local dirX
local dirY
local store
local modemInit

--[[	Fonction	]]--
--	switch
function switch(case)
  return function(codetable)
    local f
    f = codetable[case] or codetable.default
    if f then
      if type(f)=="function" then
        return f(case)
      else
        error("case "..tostring(case).." not a function")
      end
    end
  end
end

-- sleep
function sleep(n)  -- seconds
  local t0 = os.clock()
  while os.clock() - t0 <= n do end
end

-- message
function message(text)
	if modemInit ~= false then
		initModem()
	end
	print(text)
	rednet.broadcast(text)
end

-- erreur
function erreur(text)
	printError("ERREUR : " .. text)
	rednet.broadcast("ERREUR : ")
	message(text)
end

-- initModem
function initModem()
	cote = {"front", "back", "top", "bottom", "left", "right"}
	for n=1,#cote do
		rednet.open(cote[n])
	end
	rednet.announce()
	modemInit = true
end

--	usage
local function usage()
	print( "Usage : optiMine.lua")
	print( "ou    : optiMine.lua <carre>" )
	print( "ou    : optiMine.lua <largeur> <hauteur>" )
	return
end

-- 	prepareInventaire
local function prepareInventaire()
	local inventairePret = 0
	print("Placez dans les emplacement les element que vous considérez comme commun.")
	print("Terminez en placant un item dans l'emplacement numero 1.")
	while inventairePret < 2 do
		sleep(5)
		if turtle.getItemCount(1) > 0 then
			inventairePret = inventairePret + 1
		else
			inventairePret = 0
		end
	end
end

--	initInventaire
local function initInventaire()
	local tInventaire = {}
	for slot=1, 16 do
		if turtle.getItemCount(slot) > 0 then
			tInventaire[slot] = true
		else
			tInventaire[slot] = false
		end
	end
	return tInventaire
end

--[[	Programme	]]--

-- Paramètres
local Param = {...}
if #Param < 0 and #Param > 2 then
	usage()
	return
end
largeur = Param[1] or 1
hauteur = Param[2] or Param[1] or 1
pas = 0

prepareInventaire()
--store = initInventaire()
Inventaire:init()

--	Boucle principale
for posX=1,largeur do
	for posY=1,hauteur do
		if pas % 2 == 0 then
			--forer()
		end
		pas = pas + 1
	end
	
end
