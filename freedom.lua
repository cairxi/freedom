addon.name      = 'freedom'
addon.author    = 'cair'
addon.version   = '1.0'

local imgui = require('imgui')
local settings = require('settings')

local defaults = T{
    ui = { true },
}

local config = settings.load(defaults)

local freedom = function (id, index)
    local interact = struct.pack('IIHHIIII', 0, id, index, 0, 0, 0, 0, 0)
    AshitaCore:GetPacketManager():AddOutgoingPacket(0x1A, interact:totable())
end

local validate = function(e)

    if not e then return false end
    if e.Type == 0 then return false end
    if e.Distance > 64 then return false end

    return true
end

local visible = config.ui
local gui_flags = bit.bor(ImGuiWindowFlags_NoSavedSettings, ImGuiWindowFlags_NoFocusOnAppearing)

ashita.events.register('d3d_present', 'present_cb', function ()
    
    if not visible[1] then return end 

    imgui.SetNextWindowBgAlpha(0.8)
    imgui.SetNextWindowSizeConstraints({ 200, 200, }, { 800, 800, })
    if(imgui.Begin('Freedom', visible, gui_flags)) then
        local mgr = AshitaCore:GetMemoryManager():GetEntity()
        for i = 0, 0x700 do
            local e = mgr:GetRawEntity(i)
            if validate(e) then
                if imgui.Button('Click' ..'##' .. i) then
                    freedom(e.ServerId, i)
                end
                imgui.SameLine()
                imgui.Text('[' .. i .. '] '.. (e.Name or ""))
            end
        end
        imgui.End()
    end
end)

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args()
    if (#args == 0 or not args[1]:any('/freedom')) then
        return
    end

    e.blocked = true
    visible[1] = not visible[1]
end)

