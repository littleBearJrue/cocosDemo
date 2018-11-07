

local XGFakeDBStorage = class("XGFakeDBStorage")

function XGFakeDBStorage.getInstance()
	if not XGFakeDBStorage.s_instance then
		XGFakeDBStorage.s_instance = XGFakeDBStorage:create()
	end
	return XGFakeDBStorage.s_instance
end


function XGFakeDBStorage:ctor()

end

function XGFakeDBStorage:dtor()

end


function XGFakeDBStorage:getPlayerData(id)

	local path = cc.FileUtils:getInstance():getWritablePath().."/"..id.index

  --print("XGFakeDBStorage:getPlayerData="..path)
	local f = io.open(path,"rb")
  if f then
    local data = f:read("*a")
    local responseData = protobuf.decode("NFMsg.PlayerCompletionData", data) 

    f:close()

    return responseData
   else

      local playerData = self:createPlayerCompletionData(id) --xg.Int64:new(os.time())})
      self:savePlayerData(playerData)
      return playerData
   end
end




function XGFakeDBStorage:savePlayerData(playerCompletionData)



	 --[[local playerData = playerCompletionData.playerData
    local playerEquipData = playerCompletionData.playerEquipData

    local temp = playerEquipData.weaponId
    local p = playerData.position.x
     p =  playerData.characterValues.maxHp
     p =  playerCompletionData.stagedata.stagedatas[1].stageid]]


    local path = cc.FileUtils:getInstance():getWritablePath().."/"..playerCompletionData.playerData.id.index
	local data = protobuf.encode("NFMsg.PlayerCompletionData", playerCompletionData) 
    local fw = io.open(path,"wb")
    if fw and data then
      fw:write(data)
      fw:close()
     else
     	print("XGFakeDBStorage:saveFakeServerData fail")
    end

end


function XGFakeDBStorage:saveSelfPlayerData()
  local data = PlayerDataManager.getInstance():getSelfPlayerData()
  
  data = data:convertToNetData()
	self:savePlayerData(data)
end

function XGFakeDBStorage:createPlayerCompletionData(ident)

  local data = {}

   return data
end



return XGFakeDBStorage
