--[[
--======================================================================--
	Phantom Forces Net Logger by Artemking4#2531
	
	made in a few minutes, so its pretty simple
	logs sends, fetches and receieves (only when in autoexec)
	has a blacklist
--======================================================================--
]]--

local blacklist = {
    ["ping"] = true, ["repupdate"] = true, ["bulkplayerupdate"] = true, ["stance"] = true, ["equip"] = true, ["sprint"] = true
}

local inspect = loadstring(game:HttpGet("https://raw.githubusercontent.com/kikito/inspect.lua/master/inspect.lua"))()

local Modules = {}

do
    local function GetModule(name)
        for k, v in ipairs(getloadedmodules()) do
            if tostring(v) == name then return require(v) end
        end

        return error("Module " .. name .. " not found!")
    end
    
    while not pcall(GetModule, "network") and wait(0.1) do end
    Modules.Network = GetModule("network")
    Modules.OrgNetwork = { }
    for k,v in pairs(Modules.Network) do 
        Modules.OrgNetwork[k] = v
    end
end

local netRecv = 0
local netSend = 1
local netFetch = 2

local function processMessage(type, name, args, retn)
    if blacklist[name] then return end
    
    local typestring
    if type == netRecv then typestring = "Received" 
    elseif type == netSend then typestring = "Sent"
    elseif type == netFetch then typestring = "Fetched" end

    local color
    if type == netRecv then color = "@@LIGHT_GREEN@@" 
    elseif type == netSend then color = "@@LIGHT_BLUE@@"
    elseif type == netFetch then color = "@@YELLOW@@" end

    rconsoleprint("@@LIGHT_CYAN@@")
    rconsoleprint("\t" .. typestring .. " " .. name .. "\n")
    rconsoleprint(color)
    rconsoleprint("Data:\t" .. inspect(args) .. "\n")
    if retn then
        rconsoleprint("Return:\t" .. inspect(retn) .. "\n")
    end
end

function Modules.Network:add(name, fn)
    local proxy = function(...)
        processMessage(netRecv, name, {...})
        fn(...)
    end
    
    return Modules.OrgNetwork.add(self, name, proxy)
end

function Modules.Network:send(name, ...)
    processMessage(netSend, name, {...})
    
    return Modules.OrgNetwork.send(self, name, ...)
end

function Modules.Network:fetch(name, ...)
    local r = { Modules.OrgNetwork.fetch(self, name, ...) }
    processMessage(netFetch, name, {...}, r)
    
    return unpack(r)
end