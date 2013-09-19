--[[
+----------------------------------------------------------------------------+
| param
| version : 0.1
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