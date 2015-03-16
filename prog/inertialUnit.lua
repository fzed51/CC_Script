inertialUnit = {
	['x'] = 0,
	['y'] = 0,
	['z'] = 0,
	['d'] = 0,
	['mouv'] = { 
		[0]   = { 0, 0, 1},
		[1]   = { 1, 0, 0},
		[2]   = { 0, 0,-1},
		[3]   = {-1, 0, 0},
		['u'] = { 0, 1, 0},
		['d'] = { 0,-1, 0}
	}
}
function inertialUnit:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end
function inertialUnit.__tostring(self)
	return "[ Object inertialUnit {x : ".. self.x ..", y : ".. self.y ..", z : ".. self.z ..", delta : ".. self.d .."} ]"
end
function inertialUnit:getPos()
  return self.x, self.y, self.z, self.d
end
function inertialUnit:setPos(x, y, z, d)
  self.x = x
  self.y = y
  self.z = z
  self.d = d
end
function inertialUnit:deplace (mouv)
	self.x = self.x + mouv[1]
	self.y = self.y + mouv[2]
	self.z = self.z + mouv[3]
end
function inertialUnit:tourne (angle)
	self.d = ( self.d + angle ) % 4
end
function inertialUnit:forward()
	self:deplace( self.mouv[ self.d ] )
end
function inertialUnit:back()
	self:deplace( self.mouv[ ( self.d + 2 ) % 4 ] )
end
function inertialUnit:up()
	self:deplace( self.mouv[ 'u' ] )
end
function inertialUnit:down()
	self:deplace( self.mouv[ 'd' ] )
end
function inertialUnit:right()
	self:tourne( 1 )
end
function inertialUnit:left()
	self:tourne( -1 )
end

a = inertialUnit:new()
b = inertialUnit:new()
print(a)
a:forward()
print(a)
a:forward()
print(a)
a:left()
print(a)
a:forward()
print(a)
a:up()
print(a)
a:right()
print(a)
a:back()
print(a)
a:down()
print(a)
print(b)