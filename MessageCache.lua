local addonName, QLTalk = ...
local L = QLTalk.L

local MessageCache = {}

function MessageCache:new (o)
    o = o or {}
    setmetatable(o, self)
    self.messageCache = {}
    self.__index = self
    return o
end

-- verify if a message is in the cache
function MessageCache:IsChatMessageInCache(chatMessage)

    self:_cleanUpCache()

    for i, cachedMessage in ipairs(self.messageCache) do

        if cachedMessage.timestamp == chatMessage.timestamp
            and
           cachedMessage.messageId == chatMessage.messageId
            and
           cachedMessage.character == chatMessage.character
            and
           cachedMessage.realm == chatMessage.realm then
           return true
        end

    end

    return false
end

-- add a ChatMessage to the cache
function MessageCache:AddChatMessage(chatMessage)
    table.insert(self.messageCache, chatMessage)
end

-- clean up cache (remove old ChatMessages)
function MessageCache:_cleanUpCache()

    QLTalk:Debug("Message Cache size before cleaning " .. tostring(#self.messageCache))

    local purgeTimestamp = time() - QLTalk.MESSAGE_CACHE_TTL

    local i = 1
    while i <= #self.messageCache do
        local cachedMessage = self.messageCache[i]
        if (tonumber(cachedMessage.timestamp) < purgeTimestamp) then
            QLTalk:Debug("Purging message from cache " .. cachedMessage.timestamp)
            table.remove(self.messageCache, i)
        else
            i = i + 1
        end
    end

    QLTalk:Debug("Message Cache size after cleaning " .. tostring(#self.messageCache))

end

QLTalk.MessageCache = MessageCache