local addonName, QLTalk = ...
local L = QLTalk.L

local ChatLayer = {}

function ChatLayer:new(messagingLayer)
    o = {}
    setmetatable(o, self)
    self.messagingLayer = messagingLayer
    self.messageCache = QLTalk.MessageCache:new()
    self.__index = self
    return o
end

function ChatLayer:InitLayer()
    QLTalk:Debug("QLTalk.ChatLayer:InitLayer()")

    local mySelf = self

    self.messagingLayer:RegisterLocalMessageListener(
        function(self, message)
            QLTalk:Debug("(ChatLayer Listener) local guild message received")
            mySelf:_localMessageReceived(message)
        end
    )

    self.messagingLayer:RegisterBNMessageListener(
        function(self, message)
            QLTalk:Debug("(ChatLayer Listener) Battle.net message received")
            mySelf:_bnMessageReceived(message)
        end
    )
end

function ChatLayer:SendChatMessage(fromCharacter, fromGuild, fromRealm, messageText)
    chatMessage = QLTalk.ChatMessage:new{
        timestamp = tostring(time()),
        messageId = tostring(math.random(QLTalk.RANDOM_MAX)),
        character = fromCharacter,
        guild     = fromGuild,
        realm     = fromRealm,
        message   = messageText
    }

    self.messageCache:AddChatMessage(chatMessage)
    self:onChatMessageListener(chatMessage.character, chatMessage.guild, chatMessage.realm, chatMessage.message)

    self.messagingLayer:SendLocalMessage(chatMessage)
    self.messagingLayer:SendBNMessage(chatMessage)
end

function ChatLayer:RegisterOnChatMessage(onChatMessageListener)
    self.onChatMessageListener = onChatMessageListener
end

function ChatLayer:_localMessageReceived(message)

    if self.messageCache:IsChatMessageInCache(message) then
        QLTalk:Debug("Message received from local GUILD and it is already in our cache, ignoring")
        -- ignore message
    else
        QLTalk:Debug("Message received from local GUILD and it is not in our cache")
        self.messageCache:AddChatMessage(chatMessage)
        self:_notifyChatMessageListener(chatMessage)
        self.messagingLayer:SendBNMessage(message)
    end


end

function ChatLayer:_bnMessageReceived(chatMessage)

    if self.messageCache:IsChatMessageInCache(message) then
        QLTalk:Debug("Message received from Battle.net and it is already in our cache, ignoring")
        -- ignore message
    else
        QLTalk:Debug("Message received from Battle.net and it is not in our cache")
        self.messageCache:AddChatMessage(chatMessage)
        self:_notifyChatMessageListener(chatMessage)
        self.messagingLayer:SendLocalMessage(chatMessage)
        self.messagingLayer:SendBNMessage(chatMessage)
    end

end

function ChatLayer:_notifyChatMessageListener(chatMessage)
    self:onChatMessageListener(chatMessage.character, chatMessage.guild, chatMessage.realm, chatMessage.message)
end

QLTalk.ChatLayer = ChatLayer
