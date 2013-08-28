local _posX
local _posY
local _alti
local _dirX
local _dirY
local _azimut = {
	set = function(x, y)
		if x == 0 then
			if y > 0 then
				return 0
			else
				return 2
			end
		else
			if x > 0 then
				return 1
			else
				return 3
			end
		end
	end,
	get = function(dir)
		if dir == 'N' or dir == 'n' then
			return { 0,  1}
		elseif dir == 'S' or dir == 's' then
			return { 0, -1}
		elseif dir == 'E' or dir == 'e' then
			return { 1,  0}
		elseif dir == 'O' or dir == 'o' then
			return {-1,  0}
		elseif tonumber(a) ~= nil then
			dir = dir % 4
			if dir == 0 then
				return { 0, 1}
			elseif dir == 1 then
				return { 1, 0}
			elseif dir == 2 then
				return { 0,-1}
			elseif dir == 3 then
				return {-1, 0}
			else
				return {nil,nil}
			end
		else
			return {nil,nil}
		end
	end
}
local function init(posX, posY, alti, dir)
	_posX = posX
	_posY = posY
	_alti = alti
	_dirX, _dirY = _azimut.get(dir)
	if _dirX == nil then
		print('La direction est incorect')
		print('elle doit correspondre à : N, S, E, O')
		return false
	end
	return true
end

local function avancer()
	_posX = _posX + _dirX
	_posY = _posY + _dirY
end

local function reculer()
	_posX = _posX - _dirX
	_posY = _posY - _dirY
end

local function monter()
	_alti = _alti + 1
end

local function descendre()
	_alti = _alti + 1
end

local function gauche()
	local az = _azimut.set(_dirX, _dirY)
	az = az - 1
	_dirX, _dirY = _azimut.get(az)
end

local function droite()
	local az = _azimut.set(_dirX, _dirY)
	az = az + 1
	_dirX, _dirY = _azimut.get(az)
end