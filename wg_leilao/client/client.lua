local display = false
local auctionBlip = nil -- Variável para armazenar o blip
RegisterNetEvent('auction:showUI')
AddEventHandler('auction:showUI', function()
    SetDisplay(true)
end)

RegisterNetEvent('auction:hideUI')
AddEventHandler('auction:hideUI', function()
    SetDisplay(false)
end)

RegisterNetEvent('auction:updateData')
AddEventHandler('auction:updateData', function(auctionData)
    SendNUIMessage({
        type = 'updateAuction',
        auction = auctionData
    })
end)

RegisterNetEvent('auction:notificao')
AddEventHandler('auction:notificao', function(auctionData)
    SendNUIMessage({
        type = 'StarNotificacao',
        auction = auctionData
    })
end)


RegisterNetEvent('auction:stop')
AddEventHandler('auction:stop', function(auctionData)
    SendNUIMessage({
        type = 'StopSorteio',
    })

    if DoesBlipExist(auctionBlip) then
        RemoveBlip(auctionBlip)
        auctionBlip = nil
        print("Blip do leilão removido.")
    end
end)





RegisterNetEvent('auction:showNotification')
AddEventHandler('auction:showNotification', function(message, status)
    SendNUIMessage({
        type = 'showToast',
        message = message,
        status = status
    })
end)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = bool and "showUI" or "hideUI"
    })
end

RegisterNUICallback('closeUI', function(data, cb)
    SetDisplay(false)
    cb('ok')
end)

RegisterNUICallback('placeBid', function(data, cb)
    TriggerServerEvent('auction:placeBid', data.amount)
    cb('ok')
end)

-- Command to open auction UI (for testing)
RegisterCommand(Config.CommandParticiar, function()
    TriggerServerEvent('auction:requestUI')
end)

-- Admin command to start auction
RegisterCommand(Config.CommandStart, function(source, args)
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'showUICad',
        typesLeilao = Config.typesLeilao,
     
    })
   
end)

RegisterNUICallback('StartLeilao', function(data, cb)
    local participantes = data.type
    local x, y, z = data.coords:match("vector3%(([^,]+),%s*([^,]+),%s*([^,]+)%)")

    -- Converte os valores extraídos para números e retorna um `vector3`
    local coords = vector3(tonumber(x), tonumber(y), tonumber(z))
    TriggerServerEvent('auction:startAuction', data.name, data.valor, data.time,coords,participantes)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('markActionLocationOnRegisterLeilao', function(data, cb)

    SetNuiFocus(false, false)
    ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_MP_PAUSE"), 0, -1)
    BlipLoc()

    cb('ok')
end)


local markingLocation = false
local markedCoords = nil

function BlipLoc()

    if IsWaypointActive() then
        DeleteWaypoint() -- Remove a marcação no mapa
    end
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5)
          
             
                    local blip = GetFirstBlipInfoId(8) -- Pegamos a localização do marcador do mapa
                    if DoesBlipExist(blip) then
                        local coords = GetBlipCoords(blip)
                        markedCoords = tostring(coords)
                    
                        SendNUIMessage({
                            type = "UPDATE_PENDING_LOC",
                            coords = markedCoords
                        })
                        SetNuiFocus(true, true)
                        ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_MP_PAUSE"), 0, -1)
                        break
    
                       
                    else
                      
                    end
                end
            
      
    end)
    
end





RegisterNetEvent('auction:createBlip')
AddEventHandler('auction:createBlip', function(coords,mapa)
 
     -- Extrai os números de dentro do formato "vector3(x, y, z)"
      
    -- Se já houver um blip, remove antes de criar outro
    if DoesBlipExist(auctionBlip) then
        RemoveBlip(auctionBlip)
    end

    -- Criando o blip no mapa
    auctionBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(auctionBlip, 431) -- Ícone de martelo (auction gavel)
    SetBlipDisplay(auctionBlip, 4)
    SetBlipScale(auctionBlip, 1.0) -- Tamanho do blip
    SetBlipColour(auctionBlip, 2) -- Cor vermelha
    SetBlipAsShortRange(auctionBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Leilão")
    EndTextCommandSetBlipName(auctionBlip)
    if mapa then
        SetNewWaypoint(coords.x, coords.y)
    end
  
end)





