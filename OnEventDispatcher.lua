local addonName, QLTalk = ...
local L = QLTalk.L

local OnEventDispatcher = {}

function OnEventDispatcher:new()
    o = {}
    setmetatable(o, self)
    self.eventListeners = {}
    self.__index = self
    return o
end

function OnEventDispatcher:InitDispatcher()
    QLTalk:Debug("OnEventDispatcher:InitDispatcher")

    local mySelf = self

    QLTalk.frame:SetScript(
        "OnEvent",
        function(self, event, ...)
            local eventListener = mySelf.eventListeners[event]

            if eventListener == nil then
                QLTalk:Debug("OnEventDispatcher:OnEvent - received event but no listeners found - " .. event)
            else
                QLTalk:Debug("OnEventDispatcher:OnEvent - received event with listener, dispatching - " .. event)
                eventListener(self, event, ...)
            end
        end
    )

end

function OnEventDispatcher:RegisterEventListener(eventName, eventListener)
    QLTalk:Debug("OnEventDispatcher:RegisterEventListener - registering for " .. eventName)

    QLTalk.frame:RegisterEvent(eventName)

    self.eventListeners[eventName] = eventListener

end

QLTalk.OnEventDispatcher = OnEventDispatcher