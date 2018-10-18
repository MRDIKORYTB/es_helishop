--
--
-- Created by MR_DIKOR_YTB
-- 
--

RegisterServerEvent('helishop:checkMoney')
AddEventHandler('helishop:checkMoney', function(heli)
    local currentSource = source
    TriggerEvent('es:getPlayerFromId', currentSource, function(user)
        if (tonumber(user.getMoney()) >= tonumber(heli.price)) then
            TriggerClientEvent('helishop:writePlaque', currentSource, heli)
        else
            TriggerClientEvent('helishop:notifs', currentSource, "Vous n'avez pas assez d'argent !")
        end

    end)
end)

RegisterServerEvent('helishop:checkPrice')
AddEventHandler('helishop:checkPrice', function(heli)
    local player = GetPlayerIdentifiers(source)
    local currentSource = source
    local spawnable = spawnable
    local plate = string.gsub(heli.plate, "^%s*(.-)%s*$", "%1")

    MySQL.Async.fetchAll("SELECT * FROM user_heli WHERE owner=@owner AND model=@model AND plate=@plate ORDER BY name ASC LIMIT 1", {['@owner'] = player[1], ['@model'] =  heli.model, ['@plate'] = plate }, function(result)
       if result[1] then
        local prePrice = ( result[1].price  * 75 ) / 100
        local dmgPrice  = prePrice -  ( ( prePrice * ( heli.damage / 10 ) ) / 100 )
        local selPrice = prePrice - dmgPrice
        
        TriggerClientEvent('helishop:printPrice', currentSource, {name = result[1].name, plate = result[1].plate, buyed = result[1].price, prePrice = prePrice, damage = heli.damage, dmgPrice = dmgPrice, selPrice = selPrice})
         
       else
        TriggerClientEvent('helishop:notifs', currentSource, "Le ~r~meme heli~r~ est déjà enregistré avec cette ~r~meme plaque~r~ !")
       end
        

    end)
end)

RegisterServerEvent('helishop:sell')
AddEventHandler('helishop:sell', function(heli)
    local player = GetPlayerIdentifiers(source)
    local currentSource = source
    local spawnable = spawnable
    local plate = string.gsub(heli.plate, "^%s*(.-)%s*$", "%1")
    TriggerEvent('es:getPlayerFromId', currentSource, function(user)
        MySQL.Async.fetchAll("SELECT * FROM user_heli WHERE owner=@owner AND model=@model AND plate=@plate ORDER BY name ASC LIMIT 1", {['@owner'] = player[1], ['@model'] =  heli.model, ['@plate'] = plate }, function(result)
            

            
            if result[1] ~= nil then
                local prePrice = (result[1].price  * 75) / 100
                local dmgPrice = prePrice - ( ( prePrice * ( heli.damage / 10 ) ) / 100 ) 
                local selPrice = prePrice - dmgPrice
                MySQL.Async.execute("DELETE FROM user_heli WHERE owner=@owner AND model=@model AND plate=@plate",{
                        ['@owner'] =result[1].owner,
                        ['@model'] = result[1].model,
                        ['@plate'] = result[1].plate,
                    }, function(result2)
                        if result2 == 1 then
                            user.addMoney((selPrice))
                            TriggerClientEvent('helishop:heli_selled', currentSource)
							TriggerEvent("lg",";" ..  user.getIdentifier() .. ";vente heli;" .. selPrice .. ";")
                        else
                           TriggerClientEvent('helishop:notifs', currentSource, "Une erreur est survenue merci de contacter le staff !") 
                        end
                        
                    end)
            else
            end
        
        end)
    end)

end)

RegisterServerEvent('helishop:buyit')
AddEventHandler('helishop:buyit', function(heli)
    local currentSource = source
    TriggerEvent('es:getPlayerFromId', currentSource, function(user)
        local player = GetPlayerIdentifiers(currentSource)
        local name = heli.name
        local price = heli.price
        local plate = string.gsub(heli.plate, "^%s*(.-)%s*$", "%1")
        local heli = heli.model
        local type = heli.type
        local state = 1
        local customs = {
            color = {
                primary = { type= 0, red = heli.primary_red,green= heli.primary_green, blue = heli.primary_blue},
                secondary = { type= 0, red = heli.secondary_red,green= heli.secondary_green, blue = heli.secondary_blue},
                pearlescent = heli.extra,
                windows = 0
            },
            wheels = {
                type = 0,
                color = heli.wheelcolor,
            },
            neons = { enabled= 0, red = 255,green= 255, blue = 255},

            tyreburst = {enabled=0, red = 255,green= 255, blue = 255},
            mods = {},
        }
        heli.customs = json.encode(customs)
        MySQL.Async.fetchAll("SELECT * FROM user_heli WHERE heli_model=@heli_model AND heli_plate=@heli_plate ORDER BY name ASC LIMIT 1", {['@owner'] = player[1], ['@heli_model'] =  heli, ['@heli_plate'] = heli_plate }, function(result)

            if not result[1] then
                MySQL.Async.execute("INSERT INTO user_heli ('heli_model', 'heli_plate', 'heli_state', 'heli_colorprimary', 'heli_colorsecondary', 'heli_pearlescentcolor', 'heli_wheelcolor')",{
                    ['@username'] = player[1],
                    ['@name'] = name,
                    ['@heli'] = heli,
                    ['@price'] = price,
                    ['@heli_plate'] = heli_plate,
                    ['@state'] = state,
                    ['@type'] = type,
                    ['@customs'] = json.encode(customs)
                }, function()
                    user.removeMoney((heli.price))
					TriggerEvent("coffregouverneur:ajoutTaxe", tonumber(heli.price))
					TriggerEvent("lg",";" ..  user.getIdentifier() .. ";Achat heli;" .. heli.model)
                    TriggerClientEvent('helishop:closeGui', currentSource)
                    TriggerClientEvent('helishop:spawnnewheli', currentSource, heli)
                end)
            else
                TriggerClientEvent('helishop:notifs', currentSource, "Le ~r~meme heli~r~ est déjà enregistré avec cette ~r~meme plaque~r~ !")
                TriggerClientEvent('helishop:writePlaque', currentSource, heli)
            end


        end)

    end)
end)
