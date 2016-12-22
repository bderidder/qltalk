local addonName, QLTalk = ...
local L = QLTalk.L

LibStub("AceAddon-3.0"):NewAddon(QLTalk, addonName, "AceConsole-3.0")

function QLTalk:OnInitialize()
  -- Startup Message
  QLTalk:Print('QLTalk version ' .. QLTalk.VERSION .. ' loaded and ready to talk')
  QLTalk:Print('Type /qldebug to toggle debug messages on or off')

  QLTalk:Setup()
end

function QLTalk:Setup()

  QLTalk.frame = CreateFrame("FRAME", "QLTalkFrame")

  local messagingLayer = QLTalk.MessagingLayer:new()
  messagingLayer:InitLayer()

  local chatLayer = QLTalk.ChatLayer:new(messagingLayer)
  chatLayer:InitLayer()

  local chatCLILayer = QLTalk.ChatCLILayer:new(chatLayer)
  chatCLILayer:InitLayer()

  local chatWindow = QLTalk.ChatWindow:new(chatLayer)
  chatWindow:InitWindow()

end
