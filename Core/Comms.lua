local ADDON, ns = ...

local Comms = {}
ns.Comms = Comms

local COMM_PREFIX = "AWK_COMP"
local listeners = {}

-- =========================================================================
-- INICIALIZACIÓN DE COMUNICACIONES (C_ChatInfo)
-- =========================================================================
local commFrame = CreateFrame("Frame")
commFrame:RegisterEvent("PLAYER_LOGIN")
commFrame:RegisterEvent("CHAT_MSG_ADDON")

commFrame:SetScript("OnEvent", function(self, event, prefix, text, channel, sender)
    if event == "PLAYER_LOGIN" then
        if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
            C_ChatInfo.RegisterAddonMessagePrefix(COMM_PREFIX)
        end
    elseif event == "CHAT_MSG_ADDON" then
        if prefix ~= COMM_PREFIX then return end
        
        -- Separar emisor de reino
        local senderShort = (sender or ""):gsub("%-.*$", "")
        local myName = UnitName("player")
        if senderShort == myName then return end -- Ignorar mensajes propios

        local command, payload = (text or ""):match("^([^:]+):?(.*)$")
        if not command then return end

        -- Notificar a oyentes registrados
        if listeners[command] then
            for _, callback in ipairs(listeners[command]) do
                pcall(callback, senderShort, payload, channel)
            end
        end
    end
end)

-- =========================================================================
-- ENVÍO DE MENSAJES DE HERMANDAD
-- =========================================================================
function Comms:SendGuild(command, payload)
    if not IsInGuild() then return false end
    
    local message = command .. (payload and (":" .. payload) or "")
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(COMM_PREFIX, message, "GUILD")
        return true
    end
    return false
end

-- Registrar callbacks para módulos (ej. RaidPrep, GuildRoster)
function Comms:RegisterCallback(command, callback)
    listeners[command] = listeners[command] or {}
    table.insert(listeners[command], callback)
end

-- =========================================================================
-- ACCIONES DE ALTO NIVEL
-- =========================================================================
function Comms:BroadcastPrepStatus(readyCount, totalCount)
    local payload = string.format("%d/%d", readyCount, totalCount)
    return self:SendGuild("PREP_STATUS", payload)
end

function Comms:RequestRosterSync()
    return self:SendGuild("SYNC_REQ", ns.VERSION)
end
