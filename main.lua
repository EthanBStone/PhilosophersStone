local PStone = RegisterMod("PhilosopherStoneMod", 1)
local game = Game()
--local json = require("json")
--local sound = SFXManager()

local GameState = {}


PStone.COLLECTIBLE_P_STONE_THREE = Isaac.GetItemIdByName("The Philosopher's Stone  ")
PStone.COLLECTIBLE_P_STONE_TWO = Isaac.GetItemIdByName("The Philosopher's Stone ")
PStone.COLLECTIBLE_P_STONE_ONE = Isaac.GetItemIdByName("The Philosopher's Stone")
PStone.CHALLENGEID = Isaac.GetChallengeIdByName("Philosopher Stone: Gold Rush!")
--[[
*Add poop support
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
	CHESTS = 4,
	TRINKETS = 50,	--Cap for trinkets, I made it nearly infinite since you can only hold 1 trinket anyway

	ENEMIES = 10,	--Cap for enemies
	TROLLBOMBS = 4,
}
--Convert certain item pedestal into their golden variant
PStone.ItemConversions = {
	{Target = CollectibleType.COLLECTIBLE_IRON_BAR, 
	ConvertTo = CollectibleType.COLLECTIBLE_MIDAS_TOUCH}, --iron bar to midas touch

	{Target = CollectibleType.COLLECTIBLE_RAZOR_BLADE, 
	ConvertTo = CollectibleType.COLLECTIBLE_GOLDEN_RAZOR}, --razor to golden razor
	
	{Target = CollectibleType.COLLECTIBLE_TELEPORT, 
	ConvertTo = CollectibleType.COLLECTIBLE_TELEPORT_2}, --teleport to teleport 2.0

	{Target = CollectibleType.COLLECTIBLE_CIRCLE_OF_PROTECTION, 
	ConvertTo = CollectibleType.COLLECTIBLE_DADS_RING}, --circle of protection to dads ring
	
	{Target = CollectibleType.COLLECTIBLE_BROTHER_BOBBY, 
	ConvertTo = CollectibleType.COLLECTIBLE_KING_BABY}, --brother bobby to king baby

	{Target = CollectibleType.COLLECTIBLE_LATCH_KEY, 
	ConvertTo = CollectibleType.COLLECTIBLE_MOMS_KEY}, --latch key to moms key

	{Target = CollectibleType.COLLECTIBLE_THERES_OPTIONS, 
	ConvertTo = CollectibleType.COLLECTIBLE_MORE_OPTIONS}, --Theres options to more options

	{Target = CollectibleType.COLLECTIBLE_OPTIONS, 
	ConvertTo = CollectibleType.COLLECTIBLE_MORE_OPTIONS}, --options? to more options				
}


local DEBUG_MODE = 0
function PStone:onUpdate()
	

	if game:GetFrameCount()  == 5 then
		if Isaac.GetChallenge() == PStone.CHALLENGEID  then
			--print("Challenge started!")
			player:AddCollectible(PStone.COLLECTIBLE_P_STONE_THREE, 6, false, 0)
		end
		--DEBUG ONLY
		if DEBUG_MODE == 1 then
			player:AddCollectible(PStone.COLLECTIBLE_P_STONE_THREE, 12)
			--Isaac.ExecuteCommand("debug 8")
			Isaac.ExecuteCommand("debug 3")
			player:AddCard(7) --Lovers card
			--player:UseCard(10) --Use hermit
			player:AddCollectible(534) --Schoolbag
			Isaac.Spawn(EntityType.ENTITY_PICKUP, 100, 439, Vector(380,300), Vector(0,0), nil) -- Moms box
			for cnt = 1, 3 do
				player:AddCollectible(603) --Battery pack
				Isaac.Spawn(EntityType.ENTITY_PICKUP, 40, 1, Vector(0,0), Vector(0,0), nil) -- Bomb
				Isaac.Spawn(EntityType.ENTITY_PICKUP, 30, 1, Vector(150,0), Vector(0,0), nil) -- Key
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 1, Vector(300,0), Vector(0,0), nil) -- Battery
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 1, Vector(450,0), Vector(0,0), nil) -- Pills
			end
			Isaac.Spawn(EntityType.ENTITY_PICKUP, 100, CollectibleType.COLLECTIBLE_IRON_BAR, Vector(400,330), Vector(0,0), nil) -- Iron bar
			
			player:AddCollectible(65, 12) --Anarchist cookbook		
		end

	end
	
	
end


function PStone:onPStoneUse(item, rmg, player, useFlags, slot, customData)

	--print("Use flags: " .. useFlags)
	if useFlags & UseFlag.USE_CARBATTERY > 0 then
		local infoTable = {
			Remove = false,
			ShowAnim = false,
			}	
		return tableInfo
	end
	local convertedData = {
		{Count = 0, Variant = PickupVariant.PICKUP_HEART, 		SubType = HeartSubType.HEART_GOLDEN},
		{Count = 0, Variant = PickupVariant.PICKUP_COIN, 		SubType = CoinSubType.COIN_GOLDEN},
		{Count = 0, Variant = PickupVariant.PICKUP_KEY, 		SubType = KeySubType.KEY_GOLDEN},
		{Count = 0, Variant = PickupVariant.PICKUP_BOMB, 		SubType = BombSubType.BOMB_GOLDEN},
		{Count = 0, Variant = PickupVariant.PICKUP_PILL, 		SubType = PillColor.PILL_GOLD},
		{Count = 0, Variant = PickupVariant.PICKUP_LIL_BATTERY, SubType = BatterySubType.BATTERY_GOLDEN},
	}	

	--Set to 1 if no car battery, otherwise 2. This is the cap multiplier
	local carBatteryMult = 1
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
		carBatteryMult = 2
	end
	local trinketsConverted = 0
	local chestsConverted = 0
	local trollBombsConverted = 0
	--Convert Pickups
	for _, pickup in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
		variant = pickup.Variant
		subtype = pickup.SubType
		pickup = pickup:ToPickup()
		--Check to see if its a chest
		local isChest = (variant == PickupVariant.PICKUP_CHEST or variant == PickupVariant.PICKUP_BOMBCHEST or variant == PickupVariant.PICKUP_SPIKEDCHEST or variant == PickupVariant.PICKUP_MIMICCHEST or variant == PickupVariant.PICKUP_OLDCHEST or variant == PickupVariant.PICKUP_WOODENCHEST or variant == PickupVariant.PICKUP_HAUNTEDCHEST)
	
		--Trinket conversion
		if variant == PickupVariant.PICKUP_TRINKET and subtype < 32768 and trinketsConverted < PStone.pStoneCap.TRINKETS * carBatteryMult then
			trinketsConverted = trinketsConverted + 1
			pickup:Morph(EntityType.ENTITY_PICKUP, variant, subtype + 32768, true, true)
		--Chest conversion
		elseif isChest and subtype == ChestSubType.CHEST_CLOSED and chestsConverted < PStone.pStoneCap.CHESTS * carBatteryMult then
			chestsConverted = chestsConverted + 1
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, subtype, true, true)
				
		else
			for i = 1, 6 do
				--For item conversions
				if variant == PickupVariant.PICKUP_COLLECTIBLE then
					for ind, items in pairs(PStone.ItemConversions) do
						if subtype == items.Target then
							pickup:Morph(EntityType.ENTITY_PICKUP, variant, items.ConvertTo, true, true)
						end
					end
				--For normal pickups
				elseif variant == convertedData[i].Variant and subtype ~= convertedData[i].SubType and  convertedData[i].Count < (PStone.pStoneCap[i] * carBatteryMult) then
					convertedData[i].Count = convertedData[i].Count + 1
					pickup:Morph(EntityType.ENTITY_PICKUP, variant, convertedData[i].SubType, true, true)
				end		
			end
		end	
	end
	
	local enemiesConverted = 0
	--Convert Enemies
	for _, enemy in pairs(Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 1500, EntityPartition.ENEMY)) do
		if enemy:ToNPC() ~= nil then
			enemy = enemy:ToNPC()
			if enemiesConverted < (PStone.pStoneCap.ENEMIES * carBatteryMult) and not enemy:IsBoss() then
				enemy:AddMidasFreeze(EntityRef(player), 8 * 30)
			end
		--Check for trollbomb
		elseif enemy.Type == EntityType.ENTITY_BOMBDROP and (enemy.Variant == BombVariant.BOMB_TROLL or enemy.Variant == BombVariant.BOMB_SUPERTROLL) and trollBombsConverted < PStone.pStoneCap.TROLLBOMBS  then
			trollBombsConverted = trollBombsConverted + 1
			enemy:Kill()
			Isaac.Spawn(enemy.Type, BombVariant.BOMB_GOLDENTROLL, enemy.SubType, enemy.Position, enemy.Velocity, nil)
		end
		

		
	
	end
	
	--Item is 1 use
	local infoTable = {
		Remove = false,
		ShowAnim = true,
	
	}	
	

	if useFlags & UseFlag.USE_VOID > 0 then
		if PStone.CHALLENGEID ~= Isaac.GetChallenge() then
			infoTable.Remove = true
			return infoTable
		end
	elseif useFlags & UseFlag.USE_CARBATTERY  == 0 then
		if item == PStone.COLLECTIBLE_P_STONE_ONE then
			infoTable.Remove = true
		elseif item == PStone.COLLECTIBLE_P_STONE_TWO then
			player:RemoveCollectible(PStone.COLLECTIBLE_P_STONE_TWO, true, slot)
			player:AddCollectible(PStone.COLLECTIBLE_P_STONE_ONE, 0, false, slot)
			--print("1 charges left!")
		elseif item == PStone.COLLECTIBLE_P_STONE_THREE then
			if PStone.CHALLENGEID ~= Isaac.GetChallenge() then
				player:RemoveCollectible(PStone.COLLECTIBLE_P_STONE_THREE, true, slot)
				player:AddCollectible(PStone.COLLECTIBLE_P_STONE_TWO, 0, false, slot)		
			end

		end	
	end

	
	
	
	
	return infoTable
end

PStone:AddCallback(ModCallbacks.MC_POST_UPDATE, PStone.onUpdate)
PStone:AddCallback(ModCallbacks.MC_USE_ITEM, PStone.onPStoneUse, PStone.COLLECTIBLE_P_STONE_ONE)
PStone:AddCallback(ModCallbacks.MC_USE_ITEM, PStone.onPStoneUse, PStone.COLLECTIBLE_P_STONE_TWO)
PStone:AddCallback(ModCallbacks.MC_USE_ITEM, PStone.onPStoneUse, PStone.COLLECTIBLE_P_STONE_THREE)
if EID then
	EID:addCollectible(PStone.COLLECTIBLE_P_STONE_THREE, "#Three uses.#Turns some pickups(ie keys, trinkets, ect) on the ground into their golden version.#Temporarily turns some non-boss enemies in the room into golden statues.#Also converts some item pedestals like Teleport into their golden version")
	EID:addCollectible(PStone.COLLECTIBLE_P_STONE_TWO, "#Two uses left.#Turns some pickups(ie keys, trinkets, ect) on the ground into their golden version.#Temporarily turns some non-boss enemies in the room into golden statues.#Also converts some item pedestals like Teleport into their golden version")
	EID:addCollectible(PStone.COLLECTIBLE_P_STONE_ONE, "#One use left.#Turns some pickups(ie keys, trinkets, ect) on the ground into their golden version.#Temporarily turns some non-boss enemies in the room into golden statues.#Also converts some item pedestals like Teleport into their golden version")
end
