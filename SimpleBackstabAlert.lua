-- ==========================================================
-- Simple Backstab Alert para Turtle WoW
-- Versión Final: 3 Colores, Escala, Sonido con Anti-Spam y Ayuda
-- ==========================================================

local RUTA_BASE = "Interface\\AddOns\\SimpleBackstabAlert\\media\\"
local TEXTURAS = {
    verde = RUTA_BASE .. "verde.tga",
    amarillo = RUTA_BASE .. "amarillo.tga",
    rojo = RUTA_BASE .. "rojo.tga"
}
local SONIDO_ALERTA = RUTA_BASE .. "alerta.wav"

-- Variables de control interno
local ultimoSonido = 0 -- Control para el anti-spam
local tiempoRojo = 0
local INTERVALO_ALERTA = 0.7 -- Tiempo en segundos para el "respiro"


-- Crear el Frame
local frame = CreateFrame("Frame", "BackstabCheckFrame", UIParent)
frame:SetMovable(true)
frame:EnableMouse(false)
frame:RegisterForDrag("LeftButton")

local texture = frame:CreateTexture(nil, "BACKGROUND")
texture:SetAllPoints(frame)

-- Registro de Eventos
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("UI_ERROR_MESSAGE")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

-- 4. Manejo de Eventos (Lógica de Colores y Sonido CORREGIDA)
frame:SetScript("OnEvent", function()
    -- Carga de configuración inicial
    if event == "VARIABLES_LOADED" then
        if not SimpleBackstabDB then
            SimpleBackstabDB = { x = 0, y = -100, point = "CENTER", size = 64, soundOn = true }
        end
        this:ClearAllPoints()
        this:SetPoint(SimpleBackstabDB.point, UIParent, SimpleBackstabDB.point, SimpleBackstabDB.x, SimpleBackstabDB.y)
        this:SetWidth(SimpleBackstabDB.size)
        this:SetHeight(SimpleBackstabDB.size)
        texture:SetTexture(TEXTURAS.verde)

    -- Fuera de combate -> VERDE
    elseif event == "PLAYER_REGEN_ENABLED" then
        texture:SetTexture(TEXTURAS.verde)

    -- Entra en combate -> AMARILLO
    elseif event == "PLAYER_REGEN_DISABLED" then
        texture:SetTexture(TEXTURAS.amarillo)

    -- Detección del Error -> ROJO + SONIDO (Ajustado para detectar Shred/Backstab/etc)
   elseif event == "UI_ERROR_MESSAGE" then
        if arg1 and (string.find(arg1, "must be behind your target") or 
           string.find(arg1, "Debes estar detrás del objetivo")) then
            
            -- Activar estado rojo y cargar tiempo
            texture:SetTexture(TEXTURAS.rojo)
            tiempoRojo = INTERVALO_ALERTA 
            
            -- Lógica Anti-Spam Sonora (0.7s)
            if SimpleBackstabDB.soundOn then
                local tiempoActual = GetTime()
                if (tiempoActual - ultimoSonido) >= INTERVALO_ALERTA then
                    PlaySoundFile(SONIDO_ALERTA)
                    ultimoSonido = tiempoActual
                end
            end
        end

    -- Ataque exitoso -> Volver a AMARILLO
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        if arg1 == "player" and UnitAffectingCombat("player") then
            texture:SetTexture(TEXTURAS.amarillo)
        end
    end
end)


-- NUEVO: Lógica de actualización constante (Temporizador)
frame:SetScript("OnUpdate", function()
    -- Solo restamos tiempo si el icono está en modo "error" (tiempoRojo > 0)
    if tiempoRojo > 0 then
        tiempoRojo = tiempoRojo - arg1 -- arg1 en OnUpdate es el tiempo pasado desde el último frame
        
        -- Cuando el tiempo se agota, volvemos a Amarillo (si seguimos en combate)
        if tiempoRojo <= 0 then
            if UnitAffectingCombat("player") then
                texture:SetTexture(TEXTURAS.amarillo)
            else
                texture:SetTexture(TEXTURAS.verde)
            end
        end
    end
end)




-- Lógica de Arrastre
frame:SetScript("OnDragStart", function() this:StartMoving() end)
frame:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
    local point, _, _, x, y = this:GetPoint()
    SimpleBackstabDB.point = point
    SimpleBackstabDB.x = x
    SimpleBackstabDB.y = y
end)

-- ==========================================================
-- SISTEMA DE COMANDOS Y AYUDA
-- ==========================================================
SLASH_BACKSTABALERT1 = "/bsa"
SlashCmdList["BACKSTABALERT"] = function(msg)
    local args = {}
    for word in string.gfind(msg, "%S+") do table.insert(args, word) end
    
    local cmd = args[1]
    
    if cmd == "edit" then
        if not frame:IsMouseEnabled() then
            frame:EnableMouse(true)
            frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background"})
            frame:SetBackdropColor(0, 0, 0, 0.6)
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BSA:|r Modo Edición ACTIVADO. Arrastra el icono.")
        else
            frame:EnableMouse(false)
            frame:SetBackdrop(nil)
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000BSA:|r Modo Edición DESACTIVADO. Posición guardada.")
        end

    elseif cmd == "size" and args[2] then
        local newSize = tonumber(args[2])
        if newSize and newSize >= 20 and newSize <= 400 then
            SimpleBackstabDB.size = newSize
            frame:SetWidth(newSize)
            frame:SetHeight(newSize)
            DEFAULT_CHAT_FRAME:AddMessage("|cff00dbffBSA:|r Tamaño cambiado a " .. newSize)
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000BSA:|r Usa un valor entre 20 y 400.")
        end

    elseif cmd == "sound" then
        SimpleBackstabDB.soundOn = not SimpleBackstabDB.soundOn
        local estado = SimpleBackstabDB.soundOn and "|cff00ff00ACTIVADO|r" or "|cffff0000DESACTIVADO|r"
        DEFAULT_CHAT_FRAME:AddMessage("|cff00dbffBSA:|r Sonido de alerta: " .. estado)

    else
        -- MENÚ DE AYUDA (Help)
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00--- Simple Backstab Alert (BSA) Ayuda ---|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00dbff/bsa edit|r - Bloquea o desbloquea el icono para moverlo con el ratón.")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00dbff/bsa size [N]|r - Ajusta el tamaño del icono (Ej: /bsa size 80).")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00dbff/bsa sound|r - Activa o desactiva la alerta sonora.")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00dbffEstados:|r Verde (Libre), Amarillo (Combate OK), Rojo (Error Posición).")
        DEFAULT_CHAT_FRAME:AddMessage("|cffaaaaaa* Sonido limitado a 1 vez por segundo para evitar spam.|r")
    end
end
