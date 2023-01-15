# SH59_Keysystem
This FiveM resource allows players to manage their vehicle keys.

## Overview
#### Showcase Video
[SOON]

#### Features
- Transfer master-keys to other players
- Create new keys at the locksmith
- Exchanging vehicle lock at the locksmith (invalidates all keys of the vehicle)
- Transfer keys to other players
- Easy Configuration (config.lua)
- Discord Logging (Optional)
- Ecallbacks and events to implement in other scripts (e.g. carlock, garage, etc.)


#### Requirements
- ESX (should work with every version)
- mysql-async

## Documentation
### ESX Server Callbacks

#### sh59_KeySystem:GetSharedCars
- *Gets LUA-Table of all vehicles to which the player has a key.*
- **args:** none (gets source ID automatic)
- **callback:** result table of owned keys from Database (key_id / user / plate / amount)

#### sh59_KeySystem:GetOwnedVehicles
- *Gets LUA-Table of all vehicles, that the player owns.*
- **args:** none (gets source ID automatic)
- **callback:** result table of owned vehicles from Database ("owned_vehicles" Table)

#### sh59_KeySystem:CheckIfShared
- *Checks if player has a key to a vehicle.*
- **args:** plate + (source ID (automatic))
- **callback:** true / false

### FiveM Server Events

#### sh59_KeySystem:GiveKey
- *Gives a Key to a Player.*
- **args:** playerID + plate

#### sh59_KeySystem:RemoveKey
- *Removes a Key from a Player.*
- **args:** playerID + plate

#### sh59_KeySystem:RemoveMoney
- *Removes money from a Player.*
- **args:** playerID + amount

#### sh59_KeySystem:RemoveAllKeys
- *Removes/invalidates all keys of a Vehicle (does not affect the master key).*
- **args:** plate

#### sh59_KeySystem:giveawayVehicle
- *Transfers Vehicle ownership to an other player (target).*
- **args:** targetID + plate
