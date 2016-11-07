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
    QLTalk:Debug("QLTalk.ChatUILayer:InitLayer()")

    local mySelf = self

    QLTalk:RegisterChatCommand(
        "ql",
        function(msg)
            QLTalk:Debug("anonymous ql handler")
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
    QLTalk:Debug("createNewMessage")

    guildName, guildRankName, guildRankIndex = GetGuildInfo("Player")
    name, realm = UnitName("Player")

    if(guildName ~= nil) then
        self.chatLayer:SendChatMessage(name, guildName, GetRealmName(), msg)
    else
        QLTalk:ErrorNotInGuild()
    end
end

function ChatUILayer:_localChatMsgHandler(fromName, fromGuild, fromRealm, message)
    QLTalk:Debug("QLTalk:localChatMsgHandler")
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