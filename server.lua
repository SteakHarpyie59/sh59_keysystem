
ESX.RegisterServerCallback('sh59_KeySystem:GetSharedCars', function(playerId, cb)
    local xPlayer       = ESX.GetPlayerFromId(playerId)
    local PlayerIdent = xPlayer.getIdentifier()

    MySQL.Async.fetchAll('SELECT * FROM sh59_keysystem WHERE user = @ident', {
            ['@ident'] = PlayerIdent
        }, function(result)
            cb(result)
    end)
end)

ESX.RegisterServerCallback('sh59_KeySystem:GetOwnedVehicles', function(playerId, cb)
    local xPlayer       = ESX.GetPlayerFromId(playerId)
    local PlayerIdent = xPlayer.getIdentifier()

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @ident', {
            ['@ident'] = PlayerIdent
        }, function(result)
            cb(result)
    end)
end)

ESX.RegisterServerCallback('sh59_KeySystem:CheckIfShared', function(playerId, cb, plate)
    local xPlayer       = ESX.GetPlayerFromId(playerId)
    local PlayerIdent   = xPlayer.getIdentifier()

    MySQL.Async.fetchAll('SELECT * FROM sh59_keysystem WHERE user = @ident AND plate = @plate', {  
            ['@ident'] = PlayerIdent,
            ['@plate'] = plate
        }, function(result)
            for _,v in pairs(result) do
					
		if next(result) == nil then
                	cb(false)
            	end
					
                if v.user == PlayerIdent and v.plate == plate then
                    cb(true)
                else
                    cb(false)
                end
            end
    end)
end)

RegisterNetEvent('sh59_KeySystem:GiveKey')
AddEventHandler('sh59_KeySystem:GiveKey', function(playerId, plate)
    local xPlayer       = ESX.GetPlayerFromId(playerId)
    local PlayerIdent   = xPlayer.getIdentifier()
    local alreadyhas    = false
    local alreadyhasnum = 0
    local key_id        = -1

    MySQL.Async.fetchAll('SELECT * FROM sh59_keysystem WHERE user = @ident AND plate = @plate', {  
        ['@ident'] = PlayerIdent,
        ['@plate'] = plate
    }, function(result)
    
        for _,v in pairs(result) do
            if v.user == PlayerIdent and v.plate == plate then
                alreadyhas      = true
                alreadyhasnum   = v.amount
                key_id          = v.key_id
            else
                alreadyhas      = false
            end
        end

        if alreadyhas then
            MySQL.Async.execute("UPDATE sh59_keysystem SET amount = @amount WHERE key_id = @keyid",{	
                ['@ident'] = PlayerIdent,
                ['@plate'] = plate,
                ['@amount'] = alreadyhasnum + 1,
                ['@keyid']  = key_id
            })
        else
            MySQL.Async.insert("INSERT INTO sh59_keysystem (user, plate, amount) VALUES (@ident, @plate, @amount)",{	
                ['@ident'] = PlayerIdent,
                ['@plate'] = plate,
                ['@amount'] = 1
            })
        end
    
        xPlayer.showNotification("You have received a key for the vehicle with the Plate: ~y~"..plate.."~s~")
    
        -- Optional Dirscord Logging (Config.LogEveryAction)
        DiscordLog("1x Key added to Player", "Server", xPlayer.getIdentifier(), plate)
    end)   

end)

RegisterNetEvent('sh59_KeySystem:RemoveMoney')
AddEventHandler('sh59_KeySystem:RemoveMoney', function(playerId, money)
    local xPlayer       = ESX.GetPlayerFromId(playerId)
    xPlayer.removeAccountMoney('money', money)
    xPlayer.showNotification("You paid ~g~"..money.."$~s~.")
end)

RegisterNetEvent('sh59_KeySystem:RemoveKey')
AddEventHandler('sh59_KeySystem:RemoveKey', function(playerId, plate)
    local xPlayer       = ESX.GetPlayerFromId(playerId)
    local PlayerIdent   = xPlayer.getIdentifier()
    local alreadyhas    = false
    local alreadyhasnum = 0
    local key_id        = -1

    MySQL.Async.fetchAll('SELECT * FROM sh59_keysystem WHERE user = @ident AND plate = @plate', {  
        ['@ident'] = PlayerIdent,
        ['@plate'] = plate
    }, function(result)
    
        for _,v in pairs(result) do
            if v.user == PlayerIdent and v.plate == plate and v.amount > 1 then
                alreadyhas      = true
                alreadyhasnum   = v.amount
                key_id          = v.key_id
            else
                alreadyhas      = false
                key_id          = v.key_id
            end
        end

        if alreadyhas then
            MySQL.Async.execute("UPDATE sh59_keysystem SET amount = @amount WHERE key_id = @keyid",{	
                ['@ident'] = PlayerIdent,
                ['@plate'] = plate,
                ['@amount'] = alreadyhasnum - 1,
                ['@keyid']  = key_id
            })
        else
            MySQL.Async.execute("DELETE FROM sh59_keysystem WHERE key_id = @key_id",{
                ['@ident'] = PlayerIdent,
                ['@plate'] = plate,
                ['@keyid']  = key_id
            })
        end
    
        xPlayer.showNotification("You given away a key for the vehicle with the Plate: ~y~"..plate.."~s~")
    
        -- Optional Dirscord Logging (Config.LogEveryAction)
        DiscordLog("1x Key Removed From Player", "Server", xPlayer.getIdentifier(), plate)

    end)
end)

RegisterNetEvent('sh59_KeySystem:RemoveAllKeys')
AddEventHandler('sh59_KeySystem:RemoveAllKeys', function(plate)

        MySQL.Async.execute("DELETE FROM sh59_keysystem WHERE plate = @plate",{
            ['@plate'] = plate
        })

        -- Optional Dirscord Logging (Config.LogEveryAction)
        DiscordLog("All Vehicle Keys Deletet", "Server", "Database", plate)
end)


-- Give Away Vehicle (Main Key)
RegisterServerEvent('sh59_KeySystem:giveawayVehicle')
AddEventHandler('sh59_KeySystem:giveawayVehicle', function(target, plate)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local _target = target
	local tPlayer = ESX.GetPlayerFromId(_target)
	local result = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @identifier AND plate = @plate', {
			['@identifier'] = xPlayer.identifier,
			['@plate'] = plate
		})
	if result[1] ~= nil then
		MySQL.Async.execute('UPDATE owned_vehicles SET owner = @target WHERE owner = @owner AND plate = @plate', {
			['@owner'] = xPlayer.identifier,
			['@plate'] = plate,
			['@target'] = tPlayer.identifier
		}, function (rowsChanged)
			if rowsChanged ~= 0 then
				TriggerClientEvent('esx:showNotification', _source, "You gave away the master key for the vehicle with the Plate: ~y~"..plate.."~s~")
				TriggerClientEvent('esx:showNotification', _target, "You have got the master key for the vehicle with the Plate: ~y~"..plate.."~s~")
                
                -- Optional Dirscord Logging (Config.LogEveryAction)
                DiscordLog("Vehice Owner Changed", xPlayer.getIdentifier(), tPlayer.getIdentifier(), plate)
			end
		end)
	else
		TriggerClientEvent('esx:showNotification', _source, "An error has occurred. Please contact ~y~Support~s~.")
	end
end)

function DiscordLog(title, source, target, plate)
    if Config.LogEveryAction then
        PerformHttpRequest(Config.WebhookLink, function(err, text, headers) end, 'POST', json.encode({
			embeds ={
			  {
				["title"] = title,
				["color"] = 16760904,
                ["description"] = "Source: "..source.."\nTarget: "..target.."\nPlate: "..plate,
			  }
			},
			username = "SH59 Keychain - Log",
			avatar_url = Config.WebhookAvatar,
			attachments = {}
		  }), { ['Content-Type'] = 'application/json' })

    end
end
