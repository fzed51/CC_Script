local function round(num)
  return math.floor(num + 0.5)
end

local longueur = 128
local milieu = round(longueur / 2)
local block = 0

for n = 0,(milieu-1) do
	local total = milieu - round((milieu^2 - n^2)^0.5)
	block = block + total
	print(total)
end

block = block + longueur*2

print(block)