
local functin menu(operation)
	shell.run("clear")
	print("+-------------------------------------------------+")
	print("|  QUICK INSTALL v1.0                             |")
	print("+-------------------------------------------------+")
	print("|                                                 |")
	print("|  ?? - ????????????????????????????????????????  |")
	print("|                                                 |")
	print("+-------------------------------------------------+")
	print("|  No d'installation :  __                        |")
	print("+-------------------------------------------------+")
	os.pullEvent("mouse_click")
	
	term.setCursorPos(24, (7+#operation))
end

function download(code, filename, force)
	if type(force) == 'nil' then force = false end
	print('file : ' .. filename)
	if folse or not fs.exists(filename) then
		print('download start ...')
		shell.run("pastebin", "get", code, filename)
		print('download done !')
	else
		print('... already exists.')
	end
end

local operations = {
	minning = {
		'minning', functin(){
			shell.run('clear')
			download("????????", "advTurtle.lua")
			download("????????", "minning.lua")
			print('minning install complete !')
		}
	}
}

sleep(5)
os.reboot()
