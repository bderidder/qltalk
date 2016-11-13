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

    QLTalk:RegisterChatCommand(
        "qldebug",
        function()
            mySelf:_toggleDebug()
        end
    )

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

function ChatUILayer:_toggleDebug()
    QLTalk:Debug("ChatUILayer:_toggleDebug()")

    if (QLTalk.DEBUG) then
        QLTalk.DEBUG = false
        ChatUILayer:_printChatMessage("QLTalk debug messages is now OFF")
    else
        QLTalk.DEBUG = true
        ChatUILayer:_printChatMessage("QLTalk debug messages is now ON")
    end
end

function ChatUILayer:_localChatMsgHandler(fromName, fromGuild, fromRealm, message)
    QLTalk:Debug("ChatUILayer:_localChatMsgHandler() - rendering in chat frame")
    self:_printChatMessage(self:_formatMessagePrefix(fromName, fromGuild, fromRealm) .. message)
end

function ChatUILayer:_formatMessagePrefix(fromName, fromGuild, fromRealm)
    return "\[QLTalk\] <" .. fromName .. "-" .. fromRealm .. "> "
end

function ChatUILayer:_printChatMessage(message)
    QLTalk:Debug("ChatUILayer:_printChatMessage()")
    DEFAULT_CHAT_FRAME:AddMessage(
        message, 
        255/255, 0/255, 0/255
    )
end

QLTalk.ChatUILayer = ChatUILayer