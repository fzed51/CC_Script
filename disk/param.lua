--[[
+----------------------------------------------------------------------------+
| param
| version : 0.3
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
| param.addOpt('o2', 'int')
| param.addOpt('o3')
| param.addOpt('o4', 'string', 'def')
| param.add('param1', 'string')
| param.add('param2', 'string', 'val def')
| param.add('param3', 'int')
| param.isLimited(true)
| param.addHelp('Message en plus pour aide.')
| args, opt = param.get({...})
| args => { 'p1', 'p2', 'val def' }
| opt => { ['o1'] = true,
|		   ['o2'] = 45,
|		   ['o3'] = false,
|		   ['o4'] = 'def'}
| param.usage()
| > <param1> <param3> [<param2>] [-o1] [-o2 <[int]>] [-o3] [-o4 <[string]>]
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
paramsSupl {
	name,		-- [string]
	strValid,	-- [string] 'int' / 'string' / 'mix'
	valid,		-- [fonction]
	defaut		-- [mix] 
}
options {
	name,		-- [string]
	strValid,	-- [string] 'int' / 'string' / 'mix'
	valid,		-- [fonction]
	param,		-- [boolean] option avec parametre
	defaut		-- [mix] 
}
]]--

local function isInt( val )
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
		if valid == 'int' then
			_strValid = valid
			_valid = isInt
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
			print('Option : '.. _name, 'Le 2eme argument de la fonction addOpt doit être \'int\' / \'string\' / une fonction de test avec 1 argument et renvoyer true / false.')
			error()
		end
	end
	local test, erreur = _valid( _defaut )
	if not test then
		print('Option : '.. _name, 'La valeur par defaut n\'est pas valide!', erreur)
		error()
	end
	options[#options + 1] = {
		name = _name,
		strValid = _strValid,
		valid = valid,
		param = _param,
		defaut = defaut
	}
end
function add(nom, valid, default)
	-- TODO :
end
function addHelp( msg )
	helpMsg = msg
end
function isLimited( _limit )
	limit = _limit
end
function usage()
	local out = ''
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
	error()
end
function get(args)
	-- TODO :
end

--addOpt('option1')
--addOpt('option2', 'int')
--addOpt('option3', 'int',5)
--addOpt('option4', 'string')
--addOpt('option5', 'string','abc')
--addOpt('option6', function(a)
--		a = tonumber(a)
--		if a >= 0 and a < 10 then
--			return true
--		else
--			return false, 'erreur'
--		end
--	end, 1)
--usage()