--[[
    * MoonF4 *
    GitHub: https://github.com/darkfated/moonf4
    Author's discord: darkfated
]]

local function run_scripts()
    local cl = SERVER and AddCSLuaFile or include
    local sv = SERVER and include or function() end
    
    cl('menu.lua')
    cl('hud.lua')
end

local function init()
    if SERVER then
        resource.AddFile('materials/moonf4/infinity.png')
        resource.AddFile('materials/moonf4/limit.png')
        resource.AddFile('materials/moonf4/arrow_down.png')
    end

    run_scripts()
end

init()