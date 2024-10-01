local isRequestAnim = false
local requestedemote = ''
local targetPlayerId

if Config.SharedEmotesEnabled then
    RegisterCommand('nearby', function(source, args, raw)
        if not LocalPlayer.state.canEmote then return end
        if IsPedInAnyVehicle(PlayerPedId(), true) then
            return SimpleNotify(Translate('not_in_a_vehicle'))
        end

        if #args > 0 then
            local emotename = string.lower(args[1])
            target, distance = GetClosestPlayer()
            if (distance ~= -1 and distance < 3) then
                if RP.Shared[emotename] ~= nil then
                    dict, anim, ename = table.unpack(RP.Shared[emotename])
                    TriggerServerEvent("ServerEmoteRequest", GetPlayerServerId(target), emotename)
                    SimpleNotify(Translate('sentrequestto') .. GetPlayerName(target) .. " ~w~(~g~" .. ename .. "~w~)")
                else
                    SimpleNotify("'" .. emotename .. "' " .. Translate('notvalidsharedemote') .. "")
                end
            else
                SimpleNotify(Translate('nobodyclose'))
            end
        else
            NearbysOnCommand()
        end
    end, false)
end

RegisterNetEvent("SyncPlayEmote", function(emote, player)
    EmoteCancel()
    Wait(300)
    targetPlayerId = player
    local plyServerId = GetPlayerFromServerId(player)

    if IsPedInAnyVehicle(GetPlayerPed(plyServerId ~= 0 and plyServerId or GetClosestPlayer()), true) then
        return SimpleNotify(Translate('not_in_a_vehicle'))
    end

    -- wait a little to make sure animation shows up right on both clients after canceling any previous emote
    if RP.Shared[emote] ~= nil then
        local cfg = RP.Shared[emote].AnimationOptions
        if cfg and cfg.Attachto then
            -- We do not want to attach the player if the target emote already is attached to player
            -- this would cause issue where both player would be attached to each other and fall under the map
            local targetEmote = RP.Shared[emote][4]
            if not targetEmote or not RP.Shared[targetEmote] then
                local ply = PlayerPedId()
                local pedInFront = GetPlayerPed(plyServerId ~= 0 and plyServerId or GetClosestPlayer())
                local bone = cfg.bone or -1 -- No bone
                local xPos = cfg.xPos or 0.0
                local yPos = cfg.yPos or 0.0
                local zPos = cfg.zPos or 0.0
                local xRot = cfg.xRot or 0.0
                local yRot = cfg.yRot or 0.0
                local zRot = cfg.zRot or 0.0
                AttachEntityToEntity(ply, pedInFront, GetPedBoneIndex(pedInFront, bone), xPos, yPos, zPos, xRot, yRot, zRot, false, false, false, true, 1, true)
            end
        end

        OnEmotePlay(RP.Shared[emote])
        return
    elseif RP.Dances[emote] ~= nil then
        OnEmotePlay(RP.Dances[emote])
        return
    else
        DebugPrint("SyncPlayEmote : Emote not found")
    end
end)

RegisterNetEvent("SyncPlayEmoteSource", function(emote, player)
    local ply = PlayerPedId()
    local plyServerId = GetPlayerFromServerId(player)
    local pedInFront = GetPlayerPed(plyServerId ~= 0 and plyServerId or GetClosestPlayer())

    if IsPedInAnyVehicle(ply, true) or IsPedInAnyVehicle(pedInFront, true) then
        return SimpleNotify(Translate('not_in_a_vehicle'))
    end

    local SyncOffsetFront = 1.0
    local SyncOffsetSide = 0.0
    local SyncOffsetHeight = 0.0
    local SyncOffsetHeading = 180.1

    local cfg = RP.Shared[emote] and RP.Shared[emote].AnimationOptions
    if cfg then
        SyncOffsetFront = cfg.SyncOffsetFront + 0.0 or 0.0
        SyncOffsetSide = cfg.SyncOffsetSide + 0.0 or 0.0
        SyncOffsetHeight = cfg.SyncOffsetHeight + 0.0 or 0.0
        SyncOffsetHeading = cfg.SyncOffsetHeading + 0.0 or 0.0

        if (cfg.Attachto) then
            local bone = cfg.bone or -1
            local xPos = cfg.xPos or 0.0
            local yPos = cfg.yPos or 0.0
            local zPos = cfg.zPos or 0.0
            local xRot = cfg.xRot or 0.0
            local yRot = cfg.yRot or 0.0
            local zRot = cfg.zRot or 0.0
            AttachEntityToEntity(ply, pedInFront, GetPedBoneIndex(pedInFront, bone), xPos, yPos, zPos, xRot, yRot, zRot, false, false, false, true, 1, true)
        end
    end

    local coords = GetOffsetFromEntityInWorldCoords(pedInFront, SyncOffsetSide, SyncOffsetFront, SyncOffsetHeight)
    local heading = GetEntityHeading(pedInFront)
    SetEntityHeading(ply, heading - SyncOffsetHeading)
    SetEntityCoordsNoOffset(ply, coords.x, coords.y, coords.z, 0)
    EmoteCancel()
    Wait(300)
    targetPlayerId = player
    if RP.Shared[emote] ~= nil then
        OnEmotePlay(RP.Shared[emote])
        return
    elseif RP.Dances[emote] ~= nil then
        OnEmotePlay(RP.Dances[emote])
        return
    end
end)

RegisterNetEvent("SyncCancelEmote", function(player)
    if targetPlayerId and targetPlayerId == player then
        targetPlayerId = nil
        EmoteCancel()
    end
end)

function CancelSharedEmote()
    if targetPlayerId then
        TriggerServerEvent("ServerEmoteCancel", targetPlayerId)
        targetPlayerId = nil
    end
end

RegisterNetEvent("ClientEmoteRequestReceive", function(emotename, etype, target)
    isRequestAnim = true
    requestedemote = emotename

    if etype == 'Dances' then
        _, _, remote = table.unpack(RP.Dances[requestedemote])
    else
        _, _, remote = table.unpack(RP.Shared[requestedemote])
    end

    PlaySound(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 0, 0, 1)
    SimpleNotify(Translate('doyouwanna') .. remote .. "~w~)")
    local timer = 10 * 1000
    while isRequestAnim do
        Wait(5)
        timer = timer - 5
        if timer <= 0 then
            isRequestAnim = false
            SimpleNotify(Translate('refuseemote'))
        end

        if IsControlJustPressed(1, 246) then
            isRequestAnim = false

            if RP.Shared[requestedemote] ~= nil then
                _, _, _, otheremote = table.unpack(RP.Shared[requestedemote])
            elseif RP.Dances[requestedemote] ~= nil then
                _, _, _, otheremote = table.unpack(RP.Dances[requestedemote])
            end
            if otheremote == nil then otheremote = requestedemote end
            TriggerServerEvent("ServerValidEmote", target, requestedemote, otheremote)
        elseif IsControlJustPressed(1, 182) then
            isRequestAnim = false
            SimpleNotify(Translate('refuseemote'))
        end
    end
end)
