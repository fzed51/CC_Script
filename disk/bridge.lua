dofile('disk/turtleTools.lua')

local modeDebug = true
fileDebug = 'debuglog.txt'

local function myDebug( message )
	if modeDebug then
		print ( '|> ', message )
	end
	if modeDebug and fileDebug or false then
		local file = io.open(fileDebug ,'a')
		file:write(message.."\r\n")
		file:close()
	end
end

local longueur = 0
local position = 0
local pierre = {1,2,3,4,5,6,7,8,9,10,11,12,13,14}

local function round(num)
  return math.floor(num + 0.5)
end
local function corrigeLongueurPosition( longueur )
	myDebug( 'corrigeLongueurPosition('..longueur..')' )
	local position = 0
	local nbPont = math.floor( longueur / 16 ) + 1
	if longueur > 16 and longueur % 16 > 0 then
		if nbPont % 2 = 0 then
			nbPont = nbPont + 1
		end
		position = math.floor((( nbPont * 16 ) - longueur ) / 2 )
		longueur = nbPont * 16
	end
	
	myDebug( 'corrigeLongueurPosition = '..longueur .. ', ' .. position )
	return longueur, position
end

local function calculLongueurPosition()
	myDebug( 'calculLongueurPosition()' )
	
	local longueur = 0
	local position = 0
	
	repeat
		tryDig()
		if tryForward() == true then
			longueur = longueur + 1
		end
		tryDigUp()
	until detectDown() == true
	
	turnBack()
	
	longueur, position = corrigeLongueurPosition( longueur )
	
	myDebug('calculLongueurPosition = '..longueur..', '..position)
	return longueur, position
	
end

local function construitSection( epaisseur )
	myDebug('construitSection( '..epaisseur..' )')
	
	local alt  = 0
	local dig  = 0
	local stop = false
	while not stop and ( alt > -2 or dig < 2 ) and epaisseur + alt > 0 do
		if detectDown() then
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
			tryPlace(pierre)
			turnBack()
			tryDig()
			tryPlace(pierre)
			turnLeft()
		end
		tryUp()
		alt = alt + 1
		tryPlaceDown(pierre)
	end
end

local function calculEpaisseur( longArche, position )
	myDebug('calculEpaisseur( '..longArche..', '..position..' )')
	
	local epaisseur
	local posArche = position % longArche
	if posArche < 2 then
		epaisseur = 256
	else
		local rayArche = ( longArche - 2 ) / 2
		local pos
		posArche = posArche - 2
		if rayArche > posArche then
			pos = rayArche - posArche
		else
			pos = posArche - rayArche			
		end
		epaisseur = 2 + ( rayArche - round(( rayArche^2 - pos^2 )^0.5 ))
	end
	
	myDebug('calculEpaisseur = '..epaisseur)
	return epaisseur
end

local function construitPont( longueur, position )
	myDebug ( 'construitPont( '..longueur..', '..position..' )' )
	
	local epaisseur
	local longArche = 8
	if longueur > longArche then
		longArche = longueur
	end
	if longArche > 18 then
		longArche = 18
	end
	
	if tryForward() then
		position = position + 1
	end
	repeat
		epaisseur = calculEpaisseur( longArche, position)
		construitSection( epaisseur )
		if tryForward() then
			position = position + 1
		end
	until detectDown()
end

longueur, position = calculLongueurPosition()
construitPont(longueur, position)