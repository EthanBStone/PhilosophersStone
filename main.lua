local PStone = RegisterMod("PhilosopherStoneMod", 1)
local game = Game()
--local json = require("json")
--local sound = SFXManager()

local GameState = {}


PStone.COLLECTIBLE_P_STONE = Isaac.GetItemIdByName("The Philosopher's Stone")

--[[
*Add troll bombs support
*Add poop support
*Add chests support
*Fix it with void, void instantly uses it unlike other 1 use items


]]--

PStone.pStoneCap = {

	4,		--Cap for hearts, set a cap to prevent too much coin generation
	2,		--Cap for coins,	
	1, 		--Cap for keys, should be 1 since multiple gold keys are useless
	1,		--Cap for bombs, should be 1 since multiple gold keys are useless
	3, 		--Cap for pills, 3 should be ok since you might not want to fully use them anyway
	1,		--Cap for batteries, should be 1 since the battery moves to a different room and hurts you, higher than 1 could 
			--accidentally make softlocks and force you to take dmg
	TRINKETS = 999,	--Cap for trinkets, I made it infinite since you can only hold 1 trinket anyway

	ENEMIES = 10,	--Cap for enemies


}
function PStone:onUpdate()
	--print("Num trinkets = " .. TrinketType.NUM_TRINKETS)
	if game:GetFrameCount()  == 5 then
		player:AddCollectible(PStone.COLLECTIBLE_P_STONE, 12)
		Isaac.ExecuteCommand("debug 8")
		player:AddCard(7) --Lovers card
		--player:UseCard(10) --Use hermit
		Isaac.Spawn(EntityType.ENTITY_PICKUP, 100, 439, Vector(380,300), Vector(0,0), nil) -- Moms box
		for cnt = 1, 3 do
			Isaac.Spawn(EntityType.ENTITY_PICKUP, 40, 1, Vector(0,0), Vector(0,0), nil) -- Bomb
			Isaac.Spawn(EntityType.ENTITY_PICKUP, 30, 1, Vector(150,0), Vector(0,0), nil) -- Key
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 1, Vector(300,0), Vector(0,0), nil) -- Battery
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 1, Vector(450,0), Vector(0,0), nil) -- Pills
		end

	end
	if game:GetFrameCount() % 30 == 1 then
		player = game:GetPlayer(0)
		
		
		if trinket ~= nil then
			--print("Sucessfully generated trinket!")
			
		end
	end
end


function PStone:onPStoneUse(item, rmg, player, useFlags, slot, customData)
	--print("Philosopher's Stone used!")
	--print("Use flags: " .. useFlags)


	local convertedCount = {
		0, --heartsConverted
		0, --coinsConverted
		0, --keysConverted
		0, --bombsConverted
		0, --pillsConverted
		0, --batteryConverted
	}	
	local convertedVariant = {
		PickupVariant.PICKUP_HEART,
		PickupVariant.PICKUP_COIN,
		PickupVariant.PICKUP_KEY,
		PickupVariant.PICKUP_BOMB,
		PickupVariant.PICKUP_PILL,
		PickupVariant.PICKUP_LIL_BATTERY,
	}
	
	local goldSubtype = {
		HeartSubType.HEART_GOLDEN,
		CoinSubType.COIN_GOLDEN,
		KeySubType.KEY_GOLDEN,
		BombSubType.BOMB_GOLDEN,
		PillColor.PILL_GOLD,
		BatterySubType.BATTERY_GOLDEN,	
	}
	
	local trinketsConverted = 0
	--Convert Pickups
	for _, pickup in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
		variant = pickup.Variant
		subtype = pickup.SubType
		pickup = pickup:ToPickup()
		
		if variant == PickupVariant.PICKUP_TRINKET and subtype < 32768 and trinketsConverted < PStone.pStoneCap.TRINKETS then
			trinketsConverted = trinketsConverted + 1
			pickup:Morph(EntityType.ENTITY_PICKUP, variant, subtype + 32768, true, true)
		else
			for i = 1, 6 do
				if variant == convertedVariant[i] and subtype ~= goldSubtype[i] and  convertedCount[i] < PStone.pStoneCap[i] then
					convertedCount[i] = convertedCount[i] + 1
					pickup:Morph(EntityType.ENTITY_PICKUP, variant, goldSubtype[i], true, true)
				end		
				
			end
		end	
	end
	
	local enemiesConverted = 0
	--Convert Enemies
	for _, enemy in pairs(Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 1500, EntityPartition.ENEMY)) do
		enemy = enemy:ToNPC()
		if enemiesConverted < PStone.pStoneCap.ENEMIES and not enemy:IsBoss() then
			enemy:AddMidasFreeze(EntityRef(player), 8 * 30)
		end
		
	
	end
	
	--Item is 1 use
	local infoTable = {
		Remove = true,
		ShowAnim = true,
	
	}	
	
	return infoTable
end
--Old function that works
--[[
function PStone:onPStoneUse(item, rmg, player, useFlags, slot, customData)
	--print("Philosopher's Stone used!")
	--print("Use flags: " .. useFlags)


	local convertedCount = {
		0, --heartsConverted
		0, --coinsConverted
		0, --keysConverted
		0, --bombsConverted
		0, --pillsConverted
		0, --batteryConverted
	}	
	local convertedVariant = {
		PickupVariant.PICKUP_HEART,
		PickupVariant.PICKUP_COIN,
		PickupVariant.PICKUP_KEY,
		PickupVariant.PICKUP_BOMB,
		PickupVariant.PICKUP_PILL,
		PickupVariant.PICKUP_LIL_BATTERY,
	}
	
	local goldSubtype = {
		HeartSubType.HEART_GOLDEN,
		CoinSubType.COIN_GOLDEN,
		KeySubType.KEY_GOLDEN,
		BombSubType.BOMB_GOLDEN,
		PillColor.PILL_GOLD,
		BatterySubType.BATTERY_GOLDEN,	
	}
	
	local trinketsConverted = 0
	--Convert Pickups
	for _, pickup in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
		variant = pickup.Variant
		subtype = pickup.SubType
		pickup = pickup:ToPickup()
		
		if variant == PickupVariant.PICKUP_TRINKET and subtype < 32768 and trinketsConverted < PStone.pStoneCap.TRINKETS then
			trinketsConverted = trinketsConverted + 1
			pickup:Morph(EntityType.ENTITY_PICKUP, variant, subtype + 32768, true, true)
		else
			for i = 1, 6 do
				if variant == convertedVariant[i] and subtype ~= goldSubtype[i] and  convertedCount[i] < PStone.pStoneCap[i] then
					convertedCount[i] = convertedCount[i] + 1
					pickup:Morph(EntityType.ENTITY_PICKUP, variant, goldSubtype[i], true, true)
				end		
				
			end
		end	
	end
	
	local enemiesConverted = 0
	--Convert Enemies
	for _, enemy in pairs(Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 1500, EntityPartition.ENEMY)) do
		enemy = enemy:ToNPC()
		if enemiesConverted < PStone.pStoneCap.ENEMIES and not enemy:IsBoss() then
			enemy:AddMidasFreeze(EntityRef(player), 8 * 30)
		end
		
	
	end
	
	--Item is 1 use
	local infoTable = {
		Remove = true,
		ShowAnim = true,
	
	}	
	
	return infoTable
end
]]--

PStone:AddCallback(ModCallbacks.MC_POST_UPDATE, PStone.onUpdate)
PStone:AddCallback(ModCallbacks.MC_USE_ITEM, PStone.onPStoneUse, PStone.COLLECTIBLE_P_STONE)

if EID then
	EID:addCollectible(PStone.COLLECTIBLE_P_STONE, "Turns coins, bombs, keys, pills, hearts, batteries, and trikets on the ground into their golden version. Also temporarily turns some non-boss enemies in the room into golden statues.")
end
