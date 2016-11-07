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
            mySelf:createNewMessage(msg)
        end
    )
    QLTalk:RegisterChatCommand("qltalk", "createNewMessage")

    self.chatLayer:RegisterOnChatMessage(
        function(self, fromName, fromGuild, fromRealm, message)
            mySelf:localChatMsgHandler(fromName, fromGuild, fromRealm, message)
        end
    )
end

-- This is the main function that creates a new message and send to this guild and to
-- all guilds that we are a part of.
function ChatUILayer:createNewMessage(msg)
    QLTalk:Debug("createNewMessage")
    -- Find out of the player is in a guild, if he's not, then we won't do anything.
    guildName, guildRankName, guildRankIndex = GetGuildInfo("Player")
    name, realm = UnitName("Player")

    if(guildName ~= nil) then
        self.chatLayer:SendChatMessage(name, guildName, GetRealmName(), msg)
    else
        QLTalk:error()
    end
end

-- Processes add on messages recevied from "GUILD" scope 
function ChatUILayer:localChatMsgHandler(fromName, fromGuild, fromRealm, message)
    QLTalk:Debug("QLTalk:localChatMsgHandler")
    DEFAULT_CHAT_FRAME:AddMessage(
        self:formatMessagePrefix(fromName, fromGuild, fromRealm) 
        .. message, 
        255/255, 0/255, 0/255
    )
end

function ChatUILayer:formatMessagePrefix(fromName, fromGuild, fromRealm)
    return "\[QLTalk\] <" .. fromName .. "-" .. fromRealm .. "> "
end

QLTalk.ChatUILayer = ChatUILayer