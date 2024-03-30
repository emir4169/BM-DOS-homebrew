--BLOCK MESA BIOS
--Used for all Block Mesa bootable computers
--inject code stolen from https://pastebin.com/yzfDMjwf
os.pullEvent = os.pullEventRaw
--internal flag things
local version = "1.00"
local isDiskBooted = false
local baseDirectory = ""
local directory = "/"
local driveLetter = "C"
local function setupTerm()
	term.redirect(term.native())
	term.setPaletteColour(colors.white, 0xE9A226)
	term.setPaletteColour(colors.red, 0xE9A226)
	term.setPaletteColour(colors.black, 0x43422C)
	term.setCursorBlink(false)
	term.clear()
	term.setCursorPos(1,1)
	print("BLOCK MESA BIOS v"..version)
end
setupTerm()
if not settings.get("dos.hasFinishedSetup") then
	settings.set("bios.use_multishell",false)
	settings.set("shell.allow_disk_startup",false)
	settings.set("dos.hasFinishedSetup",true)
	settings.save()
	print("Rebooting...")
	os.reboot()
end
_G.bios = {
	getBootedDrive = function()
		return baseDirectory
	end,
	isDiskBooted = function()
		return isDiskBooted
	end,
	getDir = function()
		return directory
	end,
	setDir = function(dir)
		shell.setDir(dir)
		directory = dir
	end,
	getDrive = function()
		return driveLetter
	end,
	setDrive = function(a)
		driveLetter = a
	end,
	updateFile = function(file,url)
		a = http.get(url,nil,true)
		a1 = io.open(file,"wb")
		a1.write(a.readAll())
		a1.close()
		a.close()
	end
}
local function boot(prefix)
	print("Booting from drive "..driveLetter)
	baseDirectory = prefix
	directory = prefix
	local success, response = pcall(os.run,{['shell']=shell},prefix..".BOOT")
	if not success then
		print(response)
		while true do os.sleep() end
	end
end
local function findBootableDevice()
	if fs.exists("disk") and fs.exists("/disk/.BOOT") then
		bios.setDrive("A")
		isDiskBooted = true
		boot("/disk/")

	elseif fs.exists("/.BOOT") then
		bios.setDrive("C")
		boot("/")
	else
		print("NO BOOT DEVICE FOUND!")
		while true do os.sleep() end
	end
end
local oldErr = printError
local oldPull = os.pullEvent
local function overwrite()
    _G.printError = oldErr
	_G.os.pullEvent = oldPull
    _G['rednet'] = nil
    --os.loadAPI("/rom/apis/rednet.lua")
	setupTerm()
	--local success, err = pcall(parallel.waitForAny, boot, rednet.run)
	local success, err = pcall(findBootableDevice)
	if not success then
		print(err)
		print("Press any key to continue.")
		os.pullEvent("key")
	end
end

_G.printError = overwrite
_G.os.pullEvent = nil
--os.queueEvent("key")

