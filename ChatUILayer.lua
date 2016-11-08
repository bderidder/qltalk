local addonName, QLTalk = ...
local L = QLTalk.L

local ChatUILayer = {}

function ChatUILayer:new(chatLayer)
    o = {}
    setmetatable(o, self)
    self.chatLayer = chatLayer
    self.__index = self
    return o
end

function ChatUILayer:InitLayer()
    QLTalk:Debug("ChatUILayer:InitLayer()")

    local mySelf = self

    QLTalk:RegisterChatCommand(
        "ql",
        function(msg)
            mySelf:_createNewMessage(msg)
        end
    )
    QLTalk:RegisterChatCommand("qltalk", "createNewMessage")

    self.chatLayer:RegisterOnChatMessage(
        function(self, fromName, fromGuild, fromRealm, message)
            mySelf:_localChatMsgHandler(fromName, fromGuild, fromRealm, message)
        end
    )
end

function ChatUILayer:_createNewMessage(msg)
    QLTalk:Debug("ChatUILayer:_createNewMessage() - got message, sending out")

    guildName, guildRankName, guildRankIndex = GetGuildInfo("Player")
    name, realm = UnitName("Player")

    self.chatLayer:SendChatMessage(name, guildName, GetRealmName(), msg)
end

function ChatUILayer:_localChatMsgHandler(fromName, fromGuild, fromRealm, message)
    QLTalk:Debug("ChatUILayer:_localChatMsgHandler() - received message, rendering in chat frame")
    DEFAULT_CHAT_FRAME:AddMessage(
        self:_formatMessagePrefix(fromName, fromGuild, fromRealm) 
        .. message, 
        255/255, 0/255, 0/255
    )
end

function ChatUILayer:_formatMessagePrefix(fromName, fromGuild, fromRealm)
    return "\[QLTalk\] <" .. fromName .. "-" .. fromRealm .. "> "
end

QLTalk.ChatUILayer = ChatUILayer