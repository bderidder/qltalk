local addonName, QLTalk = ...
local L = QLTalk.L

local ChatCLILayer = {}

function ChatCLILayer:new(chatLayer)
    o = {}
    setmetatable(o, self)
    self.chatLayer = chatLayer
    self.__index = self
    return o
end

function ChatCLILayer:InitLayer()
    QLTalk:Debug("ChatCLILayer:InitWindow()")

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

    QLTalk:RegisterChatCommand(
        "qlinfo",
        function()
            mySelf:_printInfo()
        end
    )
end

function ChatCLILayer:_createNewMessage(msg)
    QLTalk:Debug("ChatCLILayer:_createNewMessage() - got message, sending out")

    guildName, guildRankName, guildRankIndex = GetGuildInfo("Player")
    name, realm = UnitName("Player")

    self.chatLayer:SendChatMessage(name, guildName, GetRealmName(), msg)
end

function ChatCLILayer:_toggleDebug()
    QLTalk:Debug("ChatCLILayer:_toggleDebug()")

    if (QLTalk.DEBUG) then
        QLTalk.DEBUG = false
        ChatCLILayer:_printChatMessage("QLTalk debug messages is now OFF")
    else
        QLTalk.DEBUG = true
        ChatCLILayer:_printChatMessage("QLTalk debug messages is now ON")
    end
end

function ChatCLILayer:_printInfo()
    QLTalk:Debug("ChatCLILayer:_printInfo()")

    QLTalk:Print('QLTalk version ' .. QLTalk.VERSION)
end

function ChatCLILayer:_printChatMessage(message)
    QLTalk:Debug("ChatCLILayer:_printChatMessage()")
    DEFAULT_CHAT_FRAME:AddMessage(
        message, 
        255/255, 0/255, 0/255
    )
end

QLTalk.ChatCLILayer = ChatCLILayer