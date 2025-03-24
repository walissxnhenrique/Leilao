local currentAuction = nil
local isAdmin = {} -- Store admin status
local auctionEndTime = 0

local permissao = nil
local org = nil

RegisterNetEvent('auction:requestUI')
AddEventHandler('auction:requestUI', function()
    local source = source
    if currentAuction then

        local user_id = Framework.Functions:GetUserId(source)
        if permissao ~= nil then
            if not Framework.Functions:VerifyPermission(user_id,permissao)  then
        
                TriggerClientEvent('auction:showNotification', source, 'Você não tem permissao para participar desse leilão', 'error')
                return
            end
         end
        
        TriggerClientEvent('auction:showUI', source)
        -- currentAuction.remainingTime = math.max(0, math.floor((auctionEndTime - os.time()) / 60))
        TriggerClientEvent('auction:updateData', source, currentAuction)
    else
        TriggerClientEvent('auction:showNotification', source, 'Não há leilão em andamento', 'error')
    end
end)

RegisterNetEvent('auction:startAuction')
AddEventHandler('auction:startAuction', function(itemName, startingBid, duration,coords,type)
    local source = source
    local user_id = Framework.Functions:GetUserId(source)
    local identity = Framework.Functions:GetUserName(user_id)
       
    if not Framework.Functions:VerifyPermission(user_id, Config.PermStart) then 
        TriggerClientEvent('auction:showNotification', source, 'Você não tem permissão para iniciar leilões', 'error')
        return
    end
    
    if currentAuction then
        TriggerClientEvent('auction:showNotification', source, 'Já existe um leilão em andamento', 'error')
        return
    end
    permissao = nil
    org = nil
    for k,v in pairs(Config.typesLeilao) do 
        if k == type then
          permissao = v.perm
          org = k
          
        end
  
      end

    
    currentAuction = {
        itemName = itemName,
        currentBid = parseInt(startingBid),
        status = 'Leilão em andamento',
        highestBidder = nil,
        winnerId = nil,
        remainingTime = parseInt(duration),
        duration = parseInt(duration),
        command = Config.CommandParticiar,
        timeaviso = Config.TimeAnuncio,
        coords = coords
    }

    
    if permissao ~= nil then
        local participantes = Framework.Functions.getUsersByPermission(permissao)
        TriggerClientEvent('auction:updateData', source, currentAuction)
        TriggerClientEvent('auction:notificao', source, currentAuction)
        TriggerClientEvent('auction:createBlip', source, coords,false)
        for l,w in pairs(participantes) do

            local player = Framework.Functions.getUserSource(parseInt(w))
                if player  then
                    async(function()
                     
                        TriggerClientEvent('auction:updateData', player, currentAuction)
                        TriggerClientEvent('auction:notificao', player, currentAuction)
                        TriggerClientEvent('auction:createBlip', player, coords,false)
              
                        
                    end)
                end

        end

    else
        -- Broadcast to all players
        TriggerClientEvent('auction:updateData', -1, currentAuction)
        TriggerClientEvent('auction:notificao', -1, currentAuction)
        TriggerClientEvent('auction:createBlip', -1, coords,false)
    end
 
 
    -- TriggerClientEvent('auction:showNotification', -1, 'Novo leilão iniciado!', 'success')


    local embed = {
        {
            title = 'Início do Leilão', 
            
            description = 'Um Leilão foi iniciado na cidade.', 

            fields = { 
                {
                    name = 'Item', 
                    value = tostring(itemName)
                },
                {
                    name = 'ID QUE INICIOU', 
                    value = ""..user_id.." - "..identity.." "
                },
                {
                    name = 'Lance Inicial', 
                    value = "R$ "..formatMoney(startingBid)
                },
                {
                    name = 'Quem pode participar?', 
                    value = tostring(org)
                },
            }, 

            footer = { 
                text = 'Leilão - '..os.date('%d/%m/%Y | %H:%M:%S'), 
                icon_url = Config.Logocidade
            }, 

            color = 15158332, 
        }
    }
    
    local webhook = Config.Logs.StartLeilao
    
    PerformHttpRequest(webhook, function(error, text, headers) end, 'POST', json.encode(
        {
            username = ''..Config.Nomecidade..' - Leilão', 
            avatar_url = Config.Logocidade, 
            embeds = embed
        }
    ), { ['Content-Type'] = 'application/json' })

   
    -- Start timer to update remaining time
    Citizen.CreateThread(function()
        
        while currentAuction do
         
            Citizen.Wait(60000) -- Update every minute
            if currentAuction then
               
                currentAuction.remainingTime = currentAuction.remainingTime - 1
              
                
                
                if currentAuction.remainingTime == 0 then
                    TriggerClientEvent('auction:updateData', -1, currentAuction)
              
                    -- End auction when time runs out
                    local winner = currentAuction.highestBidder
                    local finalBid = currentAuction.currentBid
                    
                    if winner then
                      
                        if Framework.Functions:tryFullPayment(currentAuction.winnerId,parseInt(finalBid)) then
                            if permissao ~= nil then
                                local participantes = Framework.Functions.getUsersByPermission(permissao)
                                if source then
                                    TriggerClientEvent('auction:showNotification', source, 'Leilão encerrado! Vencedor: ' .. winner .. ' com lance de R$' .. formatMoney(finalBid).. ' e arrematou o item: ' ..currentAuction.itemName, 'success')
                                end
                                for l,w in pairs(participantes) do
                        
                                    local player = Framework.Functions.getUserSource(parseInt(w))
                                        if player  then
                                            async(function()
                                             
                                                TriggerClientEvent('auction:showNotification', player, 'Leilão encerrado! Vencedor: ' .. winner .. ' com lance de R$' .. formatMoney(finalBid).. ' e arrematou o item: ' ..currentAuction.itemName, 'success')

                                      
                                                
                                            end)
                                        end
                        
                                end
                        
                            else
                                TriggerClientEvent('auction:showNotification', -1, 'Leilão encerrado! Vencedor: ' .. winner .. ' com lance de R$' .. formatMoney(finalBid).. ' e arrematou o item: ' ..currentAuction.itemName, 'success')
                            end
                            TriggerClientEvent('auction:stop', -1)
                               
                            local embed = {
                                {
                                    title = 'Ganhador do Leilão', 
                                    
                                    description = 'O Leilão foi encerrado na cidade.', 
                        
                                    fields = { 
                                        {
                                            name = 'Item', 
                                            value = tostring(currentAuction.itemName)
                                        },
                                        {
                                            name = 'ID QUE GANHOU', 
                                            value = ""..currentAuction.winnerId.." - "..winner.." "
                                        },
                                        {
                                            name = 'Lance Dado', 
                                            value = "R$ "..formatMoney(finalBid)
                                        },
                                        {
                                            name = 'Quem participou?', 
                                            value = tostring(org)
                                        },
                                    }, 
                        
                                    footer = { 
                                        text = 'Leilão - '..os.date('%d/%m/%Y | %H:%M:%S'), 
                                        icon_url = Config.Logocidade
                                    }, 
                        
                                    color = 15158332, 
                                }
                            }
                            
                            local webhook = Config.Logs.WinLeilao
                            
                            PerformHttpRequest(webhook, function(error, text, headers) end, 'POST', json.encode(
                                {
                                    username = ''..Config.Nomecidade..' - Leilão', 
                                    avatar_url = Config.Logocidade, 
                                    embeds = embed
                                }
                            ), { ['Content-Type'] = 'application/json' })
                            

                        else
               
                            TriggerClientEvent('auction:showNotification', Framework.Functions.getUserSource(parseInt(finalBid)), 'Dinheiro insuficiente', 'error')
                            if permissao ~= nil then
                                local participantes = Framework.Functions.getUsersByPermission(permissao)
                                if source then
                                    TriggerClientEvent('auction:showNotification', source, 'O item não pode ser entregue pois o morador nao esta mais com dinheiro em mãos', 'error')
                                end
                                for l,w in pairs(participantes) do
                        
                                    local player = Framework.Functions.getUserSource(parseInt(w))
                                        if player  then
                                            async(function()
                                             
                                                TriggerClientEvent('auction:showNotification', player, 'O item não pode ser entregue pois o morador nao esta mais com dinheiro em mãos', 'error')

                                      
                                                
                                            end)
                                        end
                        
                                end
                        
                            else
                                 TriggerClientEvent('auction:showNotification', -1, 'O item não pode ser entregue pois o morador nao esta mais com dinheiro em mãos', 'error')
                            end
                            TriggerClientEvent('auction:stop', -1)
                  

                        end
                        
                    else
                        if permissao ~= nil then
                            local participantes = Framework.Functions.getUsersByPermission(permissao)
                            if source then
                                TriggerClientEvent('auction:showNotification', source, 'Leilão encerrado sem lances', 'error')
                                  
                            end
                            for l,w in pairs(participantes) do
                    
                                local player = Framework.Functions.getUserSource(parseInt(w))
                                    if player  then
                                        async(function()
                                         
                                            TriggerClientEvent('auction:showNotification', player, 'Leilão encerrado sem lances', 'error')
                                  
                                            
                                        end)
                                    end
                    
                            end
                    
                        else
                        TriggerClientEvent('auction:showNotification', -1, 'Leilão encerrado sem lances', 'error')
                        end
                        TriggerClientEvent('auction:stop', -1)
                    end
                    
                    currentAuction = nil
                    TriggerClientEvent('auction:hideUI', -1)
                    break
                else
                    TriggerClientEvent('auction:updateData', -1, currentAuction)
                end
            end
        end
    end)
end)

RegisterNetEvent('auction:placeBid')
AddEventHandler('auction:placeBid', function(amount)
    local source = source
    
    if not currentAuction then
        TriggerClientEvent('auction:showNotification', source, 'Não há leilão em andamento', 'error')
        return
    end
   
    if amount <= currentAuction.currentBid then
        TriggerClientEvent('auction:showNotification', source, 'O lance deve ser maior que o lance atual', 'error')
        return
    end

 
    

    local playerPed = GetPlayerPed(source) -- Obtém o Ped (entidade) do jogador
        local playerCoords = GetEntityCoords(playerPed) -- Obtém a posição do jogador
        
        local distance = #(playerCoords - currentAuction.coords) -- Calcula a distância entre o jogador e o local
            print(distance)
        if distance > Config.RaioSorteio then
            TriggerClientEvent('auction:showNotification', source, 'Você esta muito longe do local do evento, a localização foi marcada no seu mapa', 'error') 
            TriggerClientEvent('auction:createBlip', source,currentAuction.coords,true) 

                return
        end
        
    -- Get player name (integrate with your existing system)
    local user_id = Framework.Functions:GetUserId(source)
    local playerName = Framework.Functions:GetUserName(user_id)
    local playerId = user_id
    if permissao ~= nil then
        if not Framework.Functions:VerifyPermission(user_id,permissao)  then

            TriggerClientEvent('auction:showNotification', source, 'Você não tem permissao para participar desse leilão', 'error')
            return
        end
    end

   
    if Framework.Functions:getBankMoney(user_id) >=   parseInt(amount) or Framework.Functions:getMoney(user_id) >=   parseInt(amount) then


    
        
        currentAuction.currentBid = amount
        currentAuction.highestBidder = playerName
        currentAuction.winnerId = playerId
        if currentAuction.remainingTime < 2 then
            
            currentAuction.remainingTime = currentAuction.remainingTime + 1
        end
        
        -- Broadcast update to all players
        TriggerClientEvent('auction:updateData', -1, currentAuction)
        if permissao ~= nil then
            local participantes = Framework.Functions.getUsersByPermission(permissao)
            if source then
                TriggerClientEvent('auction:showNotification', source, playerName .. ' deu um lance de R$ ' .. formatMoney(amount), 'success')

                  
            end
            for l,w in pairs(participantes) do
    
                local player = Framework.Functions.getUserSource(parseInt(w))
                    if player  then
                        async(function()
                         
                            TriggerClientEvent('auction:showNotification', player, playerName .. ' deu um lance de R$ ' .. formatMoney(amount), 'success')

                            
                        end)
                    end
    
            end
    
        else
            TriggerClientEvent('auction:showNotification', -1, playerName .. ' deu um lance de R$ ' .. formatMoney(amount), 'success')
        end

        local embed = {
            {
                title = 'Lance Leilão', 
                
                description = 'Um Lance foi dado no Leilão.', 
    
                fields = { 
                    {
                        name = 'ID', 
                        value = ""..playerId.." - "..playerName.." "
                    },
                    {
                        name = 'Lance', 
                        value = "R$ "..formatMoney(amount)
                    },
                    {
                        name = 'Quem pode participar?', 
                        value = tostring(org)
                    },
                }, 
    
                footer = { 
                    text = 'Leilão - '..os.date('%d/%m/%Y | %H:%M:%S'), 
                    icon_url = Config.Logocidade
                }, 
    
                color = 15158332, 
            }
        }
        
        local webhook = Config.Logs.LanceLeilao
        
        PerformHttpRequest(webhook, function(error, text, headers) end, 'POST', json.encode(
            {
                username = ''..Config.Nomecidade..' - Leilão', 
                avatar_url = Config.Logocidade, 
                embeds = embed
            }
        ), { ['Content-Type'] = 'application/json' })
    

        
    else
        TriggerClientEvent('auction:showNotification', source, 'Dinheiro Insuficiente', 'error')
    end

end)


function formatMoney(value)
    local formatted = string.format("%.2f", value) -- Mantém 2 casas decimais
    local left, right = formatted:match("^(.-)%.(.-)$") -- Separa parte inteira da decimal
    left = left:reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.", "") -- Adiciona pontos como separador de milhar
    return left .. "," .. right -- Junta novamente usando vírgula para os centavos
end
