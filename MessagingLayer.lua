local addonName, QLTalk = ...
local L = QLTalk.L

local MessagingLayer = {}

function MessagingLayer:new()
    o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function MessagingLayer:InitLayer()
    QLTalk:Debug("MessagingLayer:InitLayer")

    local mySelf = self

    C_ChatInfo.RegisterAddonMessagePrefix(QLTalk.QLTALK_ADDON_MSG_PREFIX)
    C_ChatInfo.RegisterAddonMessagePrefix(QLTalk.QLTALK_BN_MSG_PREFIX)

    QLTalk.onEventDispatcher:RegisterEventListener(
        "CHAT_MSG_ADDON",
        function(self, event, ...)
            local prefix, message, type, senderId = ...
            QLTalk:Debug("MessagingLayer:InitLayer - received message from CHAT_MSG_ADDON")
            mySelf:_localChatMsgHandler(event, prefix, message, type, senderId)
        end
    )

    QLTalk.onEventDispatcher:RegisterEventListener(
        "BN_CHAT_MSG_ADDON",
        function(self, event, ...)
            local prefix, message, type, senderId = ...
            QLTalk:Debug("MessagingLayer:InitLayer - received message from BN_CHAT_MSG_ADDON")
            mySelf:_bnChatMsgHandler(event, prefix, message, type, senderId)
        end
    )
end

function MessagingLayer:SendLocalMessage(message)
    local rawMessage = message:createMessage()
    self:_sendLocalMessage(bnAccountId, rawMessage)
end

function MessagingLayer:SendBNMessage(message)
    local rawMessage = message:createMessage()
    self:_broadcastBNMessage(rawMessage)
end

function MessagingLayer:RegisterLocalMessageListener(localMessageListener)
    self._localMessageListener = localMessageListener
end

function MessagingLayer:RegisterBNMessageListener(bnMessageListener)
    self._bnMessageListener = bnMessageListener
end

function MessagingLayer:_sendLocalMessage(localRawMessage)

    guildName, guildRankName, guildRankIndex = GetGuildInfo("Player")

    if(guildName ~= nil) then
        QLTalk:Debug("MessagingLayer:_sendLocalMessage() - sending message on GUILD addon channel")
        C_ChatInfo.SendAddonMessage(QLTalk.QLTALK_ADDON_MSG_PREFIX, rawMessage, "GUILD")
    else
        QLTalk:Debug("MessagingLayer:_sendLocalMessage() - player is not in a guild, not sending out on guild")
    end
end

function MessagingLayer:_broadcastBNMessage(bnRawMessage)
    
    numFriends = BNGetNumFriends();

    for i=1,numFriends do 
        bnetIDAccount, accountName, battleTag, isBattleTagPresence, 
        characterName, bnetIDGameAccount, client, isOnline, lastOnline, 
        isAFK, isDND, messageText, noteText, isRIDFriend, messageTime, 
        canSoR, isReferAFriend, canSummonFriend = BNGetFriendInfo(i);

        if (isOnline and (client == "WoW")) then
            QLTalk:Debug("MessagingLayer:_broadcastBNMessage() - sending message to BN friend '" .. accountName .. "' on character " .. characterName)
            BNSendGameData(bnetIDGameAccount, QLTalk.QLTALK_BN_MSG_PREFIX, bnRawMessage)
        end

    end

end

-- Processes add on messages recevied from the GUILD
function MessagingLayer:_localChatMsgHandler(event, prefix, message, type, senderId)
    if (prefix == QLTalk.QLTALK_ADDON_MSG_PREFIX) then
        local msgObject = self:_unmarshalMessage(message)
        self:_localMessageListener(msgObject)
    end
end

-- Processes add on messages recevied from a BattleNet friend
function MessagingLayer:_bnChatMsgHandler(event, prefix, message, type, senderId)
    if (prefix == QLTalk.QLTALK_BN_MSG_PREFIX) then
        local msgObject = self:_unmarshalMessage(message)
        self:_bnMessageListener(msgObject)
    end
end

-- Split text into a list consisting of the strings in text,
-- separated by strings matching delimiter (which may be a pattern).
-- example: strsplit(",%s*", "Anna, Bob, Charlie,Dolores")
function MessagingLayer:_stringSplit(delimiter, text)
  local list = {}
  local pos = 1
  if strfind("", delimiter, 1) then -- this would result in endless loops
    error("delimiter matches empty string!")
  end
  while 1 do
    local first, last = strfind(text, delimiter, pos)
    if first then -- found?
      tinsert(list, strsub(text, pos, first-1))
      pos = last+1
    else
      tinsert(list, strsub(text, pos))
      break
    end
  end
  return list
end

function MessagingLayer:_unmarshalMessage(rawMessage)

    local messageParts = self:_stringSplit(QLTalk.MSG_SEPARATOR, rawMessage)

    local messageType = messageParts[1]

    if (messageType == "ChatMessage") then
        return QLTalk.ChatMessage:new{
            timestamp = messageParts[2],
            messageId = messageParts[3],
            character = messageParts[4],
            guild     = messageParts[5],
            realm     = messageParts[6],
            message   = messageParts[7],
            }
    end

    return nil
end

QLTalk.MessagingLayer = MessagingLayer
