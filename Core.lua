local addonName, QLTalk = ...
local L = QLTalk.L

LibStub("AceAddon-3.0"):NewAddon(QLTalk, addonName, "AceConsole-3.0")

--
function QLTalk:OnInitialize()
  -- Startup Message
  QLTalk:Print('QL talk version 0.1 loaded and ready to talk... (444)')

  QLTalk:Setup()
end

function QLTalk:Setup()
  QLTalk.frame = CreateFrame("FRAME", "QLTalkFrame")

  local messagingLayer = QLTalk.MessagingLayer:new()
  messagingLayer:InitLayer()

  local chatLayer = QLTalk.ChatLayer:new(messagingLayer)
  chatLayer:InitLayer()

  local chatUILayer = QLTalk.ChatUILayer:new(chatLayer)
  chatUILayer:InitLayer()

end
