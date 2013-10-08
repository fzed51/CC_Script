--[[
+----------------------------------------------------------------------------+
| param
| version : 0.9
| Auteur : fzed51
| git : https://github.com/fzed51/CC_Script/blob/master/disk/param.lua
| pastebin : http://pastebin.com/
+----------------------------------------------------------------------------+
| tag : [lua] [MC] [MineCraft] [CC] [ComputerCraft]
| Descript :
| API permetant de récupérer les paramètre donné dans la ligne de commande
| d'exécution d'un script.
| exemple :
| > script p1 -o1 -o2 45 p2
| donne dans le code :
| os.loadAPI('param')
| param.addOpt('o1')
| param.addOpt('o2', 'number')
| param.addOpt('o3')
| param.addOpt('o4', 'string', 'def')
| param.add('param1', 'string')
| param.add('param2', 'string', 'val def')
| param.add('param3', 'number')
| param.isLimited(true)
| param.addHelp('Message en plus pour aide.')
| args, opt = param.get({...})
| args => { 'p1', 'p2', 'val def' }
| opt => { ['o1'] = true,
|		   ['o2'] = 45,
|		   ['o3'] = false,
|		   ['o4'] = 'def'}
| param.usage()
| > <param1> <param3> [<param2>] [-o1] [-o2 <[number]>] [-o3] [-o4 <[string]>]
| > Message en plus pour aide.
+----------------------------------------------------------------------------+
]]--

local parametres, paramsSupl, options, helpMsg, limit = {}, {}, {}, '', true
--[[
structure :
parametre {
	name,		-- [string]
	strValid,	-- [string] 'int' / 'string' / 'mix'
	valid		-- [fonction]
}
paramSupl {
	name,		-- [string]
	strValid,	-- [string] 'int' / 'string' / 'mix'
	valid,		-- [fonction]
	defaut		-- [mix]
}
option {
	name,		-- [string]
	strValid,	-- [string] 'int' / 'string' / 'mix'
	valid,		-- [fonction]
	param,		-- [boolean] option avec parametre
	defaut		-- [mix]
}
]]--

local function dba(a)
	for k,v in pairs(a) do
		print(k,' : ', v)
	end
end
local function traceDebug()
	local level = 2
	while true do
		local info = debug.getinfo(level, "Sl")
		if not info then break end
		if info.what == "C" then   -- is a C function?
			print(level, "C function")
		else   -- a Lua function
			print('============================')
			print(string.format("[%s]:%d", info.short_src, info.currentline))
			print('----------------------------')
			local v = 1
			while true do
				local name, value = debug.getlocal(level, v)
				if not name then break end
				print(name, value)
				v = v + 1
			end
		end
		level = level + 1
	end
end

local function isNumber( val )
	if type( val ) == 'number' or tonumber( val ) ~= nil then
		return true
	else
		return false, 'L\'argument n\'est pas un nombre.'
	end
end
local function isString( val )
	if type( val ) == 'string' or tostring( val ) ~= nil then
		return true
	else
		return false, 'L\'argument n\'est pas une chaine.'
	end
end
local function isBool( val )
	if type ( val ) == 'boolean' then
		return true
	else
		return false, 'L\'argument n\'est pas une valeur logique.'
	end
end
local function isOption( nom )
	for n = 1, #options do
		if options[n].name == nom then
			return true, n
		end
	end
	return false
end

function addOpt(nom, valid, default)
	local _name, _param, _strValid, _valid, _defaut
	_name = nom
	if valid == nil then
		_param = false
		_strValid = ''
		_valid = isBool
		_defaut = false
	else
		_param = true
		if valid == 'number' then
			_strValid = valid
			_valid = isNumber
			_defaut = default or 0
		elseif valid == 'string' then
			_strValid = valid
			_valid = isString
			_defaut = default or ''
		elseif type(valid) == 'function' then
			_strValid = 'mix'
			_valid = valid
			_defaut = default
		else
			print('Option : '.. _name, 'Le 2eme argument de la fonction addOpt doit être \'number\' / \'string\' / une fonction de test avec 1\'argument et renvoyer true / false.')
			error()
		end
	end
	local test, erreur = _valid( _defaut )
	if not( test or ( _defaut == nil )) then
		print('Option : '.. _name, 'La valeur par defaut n\'est pas valide!', erreur)
		error()
	end
	options[#options + 1] = {
		name = _name,
		strValid = _strValid,
		valid = _valid,
		param = _param,
		defaut = _defaut
	}
end
function add(nom, valid, defaut)
	local _name, _strValid, _valid, _defaut
	_name = nom
	if valid == 'number' then
		_strValid = valid
		_valid = isNumber
		_defaut = defaut or 0
	elseif valid == 'string' then
		_strValid = valid
		_valid = isString
		_defaut = defaut or ''
	elseif type(valid) == 'function' then
		_strValid = 'mix'
		_valid = valid
		_defaut = defaut
	else
		print('Option : '.. _name, "Le 2eme argument de la fonction add doit être 'number' / 'string' / une fonction de test avec 1'argument et renvoyer true / false.")
		error()
	end
	local test, erreur = _valid( _defaut )
	if not( test or ( _defaut == nil )) then
		print('Option : '.. _name, "La valeur par defaut n'est pas valide!", erreur)
		error()
	end
	if defaut ~= nil then
		paramsSupl[#paramsSupl + 1] = {
			name = _name,
			strValid = _strValid,
			valid = _valid,
			defaut = defaut
		}
	else
		parametres[#parametres + 1] = {
			name = _name,
			strValid = _strValid,
			valid = _valid
		}
	end
end
function addHelp( msg )
	helpMsg = msg
end
function isLimited( _limit )
	limit = _limit
end
function usage(script)
	script = script or 'script'
	local out = script .. ' '
	for n = 1, #parametres do
		out = out .. '<' .. parametres[n].name .. '> '
	end
	for n = 1, #paramsSupl do
		out = out .. '[<' .. paramsSupl[n].name .. '>] '
	end
	for n = 1, #options do
		out = out .. '[-' .. options[n].name
		if options[n].param then
			out = out .. ' <[' .. options[n].strValid .. ']>'
		end
		out = out .. '] '
	end
	if #helpMsg > 0 then
		out = out .. "\n" .. helpMsg
	end
	print(out)
	-- traceDebug()
	error()
end
function get(...)
	local args = {...}
	-- dba(args)
	local param, ops = {}, {}
	local pos, nbArgs = 1, #args
	-- boucle principale qui lit les arguments
	while pos <= nbArgs do
		local arg = args[pos]
		if (arg:sub(1,1) == '-') and (tonumber(arg) == nil) then
			local opsName = arg:sub(2)
			local trouve, idx = isOption(opsName)
			if trouve then
				if options[idx].param then
					pos = pos + 1
					local val = args[pos]
					if options[idx].valid(val) then
						ops[opsName] = val
					else
						print("Le type de l'option n'est pas : " .. options[idx].strValid)
						usage()
					end
				else
					ops[opsName] = true
				end
			elseif arg == '-?' or '-help' then
				usage()
			else
				print ("L'option "..opsName.." n'existe pas!")
				usage()
			end
		else
			if (#param + 1) > #parametres then
				local indParSup = (#param + 1 - #parametres)
				if indParSup > #paramsSupl then
					if limit then
						print("Il y a trop de paramêtres !")
						usage()
					else
						param[#param + 1] = arg
					end
				else
					if paramsSupl[indParSup].valid(arg) then
						param[#param + 1] = arg
					else
						print("Le type du "..tostring(#param + 1).." parametre n'est pas : " .. paramsSupl[indParSup].strValid)
						usage()
					end
				end
			else
				if parametres[#param + 1].valid(arg) then
					param[#param + 1] = arg
				else
					print("Le type du "..tostring(#param + 1).." parametre n'est pas : " .. parametres[#param + 1].strValid)
					usage()
				end
			end
			
		end
		pos = pos + 1
	end
	-- verification des parametres
	if (#param < (#parametres)) then
		print('Il manque des paramètres!')
		usage()
	elseif limit and (#param>(#parametres+#paramsSupl)) then
		print('Le nombre de paramètres est trop important!')
		usage()
	end
	-- Ajout des paramètres suplémentaires
	for p = 1, #paramsSupl do
		if param[(#parametres + p)] == nil then
			param[(#parametres + p)] = paramsSupl[p].defaut
		end
	end
	-- Ajout des options
	for o = 1, #options do
		if ops[options[o].name] == nil then
			print(o, options[o].param)
			if options[o].param then
				ops[options[o].name] = options[o].defaut
				print(ops[options[o].name])
			else
				ops[options[o].name] = false
			end
		end
	end
	return param, ops
end

if false then -- Partie test de l'API
	addOpt('o1')
	addOpt('o2', 'number')
	addOpt('o3', 'number',5)
	addOpt('o4', 'string')
	addOpt('o5', 'string','abc')
	addOpt('o6', function(a)
			a = tonumber(a)
			if a >= 0 and a < 10 then
				return true
			else
				return false, 'erreur'
			end
		end, 1)
	add('longueur','string')
	add('largeur','number',5)
	p,o = get('90','-o1','-o2','4')
	print('parametre : ')
	for k,v in pairs(p) do
		print(k,':',v)
	end
	print('option : ')
	for k,v in pairs(o) do
		print(k,':',v)
	end
	usage('param')
end