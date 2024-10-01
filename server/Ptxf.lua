RegisterNetEvent("rpemotes:ptfx:sync", function(asset, name, offset, rot, bone, scale, color)
    if type(asset) ~= "string" or type(name) ~= "string" or type(offset) ~= "vector3" or type(rot) ~= "vector3" then
        print("[rpemotes] ptfx:sync: invalid arguments for source:", source)
        return
    end

    local srcPlayerState = Player(source).state

    srcPlayerState:set('ptfxAsset', asset, true)
    srcPlayerState:set('ptfxName', name, true)
    srcPlayerState:set('ptfxOffset', offset, true)
    srcPlayerState:set('ptfxRot', rot, true)
    srcPlayerState:set('ptfxBone', bone, true)
    srcPlayerState:set('ptfxScale', scale, true)
    srcPlayerState:set('ptfxColor', color, true)
    srcPlayerState:set('ptfxPropNet', false, true)
    srcPlayerState:set('ptfx', false, true)
end)

RegisterNetEvent("rpemotes:ptfx:syncProp", function(propNet)
    local srcPlayerState = Player(source).state
    if propNet then
        -- Prevent infinite loop to get entity
        local waitForEntityToExistCount = 0
        while waitForEntityToExistCount <= 100 and not DoesEntityExist(NetworkGetEntityFromNetworkId(propNet)) do
            Wait(10)
            waitForEntityToExistCount = waitForEntityToExistCount + 1
        end

        -- If below 100 then we could find the loaded entity
        if waitForEntityToExistCount < 100 then
            srcPlayerState:set('ptfxPropNet', propNet, true)
            return
        end
    end
    -- If we reach this point then we couldn't find the entity
    srcPlayerState:set('ptfxPropNet', false, true)
end)