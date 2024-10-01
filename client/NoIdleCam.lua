RegisterCommand('idlecamoff', function()
    SimpleNotify('Idle Cam Is Now Off')
    DisableIdleCamera(true)
    SetPedCanPlayAmbientAnims(playerPed, false)
    SetResourceKvp("idleCam", "off")
end, false)

RegisterCommand('idlecamon', function()
    SimpleNotify('Idle Cam Is Now On')
    DisableIdleCamera(false)
    SetPedCanPlayAmbientAnims(playerPed, true)
    SetResourceKvp("idleCam", "on")
end, false)

CreateThread(function()
    TriggerEvent("chat:addSuggestion", "/idlecamon", "Re-enables the idle cam")
    TriggerEvent("chat:addSuggestion", "/idlecamoff", "Disables the idle cam")

    local idleCamDisabled = GetResourceKvpString("idleCam") == "off"
    DisableIdleCamera(idleCamDisabled)
end)
