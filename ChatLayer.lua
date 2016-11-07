local addonName, QLTalk = ...
local L = QLTalk.L

local ChatLayer = {}

function ChatLayer:new(messagingLayer)
    o = {}
    setmetatable(o, self)
    self.messagingLayer = messagingLayer
    self.__index = self
    return o
end

function ChatLayer:InitLayer()
    QLTalk:Debug("QLTalk.ChatLayer:InitLayer()")

    local mySelf = self

    self.messagingLayer:RegisterLocalMessageListener(
        function(self, message)
            QLTalk:Debug("anonymous QLTalk.ChatLayer:RegisterLocalMessageListener")
            mySelf:localMessageReceived(message)
        end
    )

    self.messagingLayer:RegisterBNMessageListener(
        function(self, message)
            QLTalk:Debug("anonymous QLTalk.ChatLayer:RegisterBNMessageListener")
            mySelf:bnMessageReceived(message)
        end
    )
end

function ChatLayer:SendChatMessage(fromCharacter, fromGuild, fromRealm, messageText)
    chatMessage = QLTalk.ChatMessage:new{
        timestamp = time(),
        messageId = math.random(QLTalk.RANDOM_MAX),
        character = fromCharacter,
        guild     = fromGuild,
        realm     = fromRealm,
        message   = messageText
    }
    self.messagingLayer:SendLocalMessage(chatMessage)
end

function ChatLayer:RegisterOnChatMessage(onChatMessageListener)
    self.onChatMessageListener = onChatMessageListener
end

function ChatLayer:localMessageReceived(message)
    self:onChatMessageListener(message.character, message.guild, message.realm, message.message)
end

function ChatLayer:bnMessageReceived(message)
    self:onChatMessageListener(message.character, message.guild, message.realm, message.message)
end

QLTalk.ChatLayer = ChatLayer
