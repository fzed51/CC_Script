-- Class Inventaire

Inventaire = {}
Inventaire.__index = Inventaire

function Inventaire.New()
	local inv = {}
	setmetatable(inv, Inventaire)
	inv.nbSlotMax = 16
	inv.nom = {}
	inv.qte = {}
	return inv
end

function Inventaire:lit (preSetNom)
	for
end
