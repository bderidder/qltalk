local addonName, QLTalk = ...
local L = QLTalk.L

--
-- AbstractMessage
--

QLTalk.AbstractMessage = {};

function QLTalk.AbstractMessage:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function QLTalk.AbstractMessage:getMessageName()
    return "AbstractMessage";
end

function QLTalk.AbstractMessage:getParameterArray()
    return {};
end

function QLTalk.AbstractMessage:createMessage()
    rawMessage = self:getMessageName();
    parameters = self:getParameterArray();
    for i=1,#parameters do
        rawMessage = rawMessage .. QLTalk.MSG_SEPARATOR;
        rawMessage = rawMessage .. parameters[i];
    end

    return rawMessage;
end

--
-- Chat Message
--

local ChatMessage = QLTalk.AbstractMessage:new();

function ChatMessage:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function ChatMessage:getMessageName()
    return "ChatMessage";
end

function ChatMessage:getParameterArray()
    return {self.timestamp, self.messageId, self.character, self.guild, self.realm, self.message};
end

QLTalk.ChatMessage = ChatMessage;
