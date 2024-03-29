local addonName, QLTalk = ...
local L = QLTalk.L

local ChatWindow = {}

function ChatWindow:new(chatLayer)
    o = {}
    setmetatable(o, self)
    self.chatLayer = chatLayer
    self.__index = self
    return o
end

function ChatWindow:InitWindow()
    QLTalk:Debug("ChatWindow:InitLayer()")

    local mySelf = self

	self:_initUI()

    self.chatLayer:RegisterOnChatMessage(
        function(self, fromName, fromGuild, fromRealm, message)
            mySelf:_localChatMsgHandler(fromName, fromGuild, fromRealm, message)
        end
    )

	QLTalk.onEventDispatcher:RegisterEventListener(
        "PLAYER_REGEN_DISABLED",
        function(self, event, ...)
            mySelf.frame:Hide()
        end
    )

    QLTalk.onEventDispatcher:RegisterEventListener(
        "PLAYER_REGEN_ENABLED",
        function(self, event, ...)
            mySelf.frame:Show()
        end
    )
end

function ChatWindow:_createNewMessage(msg)
    QLTalk:Debug("ChatWindow:_createNewMessage() - got message, sending out")

    guildName, guildRankName, guildRankIndex = GetGuildInfo("Player")
    name, realm = UnitName("Player")

    self.chatLayer:SendChatMessage(name, guildName, GetRealmName(), msg)
end

function ChatWindow:_localChatMsgHandler(fromName, fromGuild, fromRealm, message)
    QLTalk:Debug("ChatWindow:_localChatMsgHandler() - rendering in chat frame")
    self:_printChatMessage(self:_formatMessagePrefix(fromName, fromGuild, fromRealm) .. message)
end

function ChatWindow:_formatMessagePrefix(fromName, fromGuild, fromRealm)

	local nowTime = date("%H:%M:%S")

    return nowTime .. " <" .. fromName .. "> "
end

function ChatWindow:_printChatMessage(message)
    QLTalk:Debug("ChatWindow:_printChatMessage()")
    self.frame.messageFrame:AddMessage(
        message, 
        255/255, 0/255, 0/255
    )
end

function ChatWindow:_initUI()
    QLTalk:Debug("ChatWindow:_initUI()")
    
	local mySelf = self

	local frame  = CreateFrame("Frame", "QLTalk_ChatWindow", UIParent)
	frame.width  = 350
	frame.height = 200
	frame:SetFrameStrata("MEDIUM")
	frame:SetSize(frame.width, frame.height)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	frame:SetBackdrop({
		bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
		tile     = true,
		tileSize = 32,
		edgeSize = 32,
		insets   = { left = 8, right = 8, top = 8, bottom = 8 }
	})
	frame:SetBackdropColor(0, 0, 0, 1)
	frame:EnableMouse(true)
	frame:EnableMouseWheel(true)
	frame:SetMinResize(150, 120)

	frame:SetMovable(true)
	frame:SetResizable(true)

	self.frame = frame

	local left, bottom, frameWidth, frameHeight = frame:GetRect()

	--tinsert(UISpecialFrames, "QLTalk_ChatWindow")

	-- Chat Input
	local chatInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	chatInput:SetPoint("BOTTOMLEFT", 15, 10)
	chatInput:SetHeight(25)
	chatInput:SetWidth(frameWidth - 50)
	chatInput:SetAutoFocus(false)
	chatInput:SetScript(
		"OnEnterPressed", 
		function(self)
			mySelf:_createNewMessage(self:GetText())
			self:SetText("")
			self:ClearFocus()
		end
	)
	frame.chatInput = chatInput

	-- ScrollingMessageFrame
	local messageFrame = CreateFrame("ScrollingMessageFrame", nil, frame)
	messageFrame:SetPoint("TOPLEFT", 15, -15)
	messageFrame:SetSize(frameWidth - 50, frameHeight - 60)
	messageFrame:SetFontObject(GameFontNormal)
	messageFrame:SetTextColor(1, 1, 1, 1) -- default color
	messageFrame:SetJustifyH("LEFT")
	messageFrame:SetHyperlinksEnabled(true)
	messageFrame:SetFading(false)
	messageFrame:SetMaxLines(300)
	--messageFrame.texture = messageFrame:CreateTexture(nil, "BACKGROUND")
	--messageFrame.texture:SetAllPoints(true)
	--messageFrame:SetTexture(1.0, 0.0, 0.0, 0.5)
	--messageFrame:SetBackdropColor(255,0,0,1)
	frame.messageFrame = messageFrame

	-------------------------------------------------------------------------------
	-- Scroll bar
	-------------------------------------------------------------------------------
	local scrollBar = CreateFrame("Slider", nil, frame, "UIPanelScrollBarTemplate")
	scrollBar:SetPoint("RIGHT", frame, "RIGHT", -10, 10)
	scrollBar:SetSize(30, frameHeight - 90)
	scrollBar:SetMinMaxValues(0, 9)
	scrollBar:SetValueStep(1)
	scrollBar.scrollStep = 1
	frame.scrollBar = scrollBar

	scrollBar:SetScript("OnValueChanged", function(self, value)
		messageFrame:SetScrollOffset(select(2, scrollBar:GetMinMaxValues()) - value)
	end)

	scrollBar:SetValue(select(2, scrollBar:GetMinMaxValues()))

	local dragBottomRight = CreateFrame("Button", "RecountResizeGripRight", frame)
	dragBottomRight:Show()
	dragBottomRight:SetFrameLevel(frame:GetFrameLevel() + 10)
	dragBottomRight:SetNormalTexture("Interface\\AddOns\\qltalk\\textures\\ResizeGripRight")
	dragBottomRight:SetHighlightTexture("Interface\\AddOns\\qltalk\\textures\\ResizeGripRight")
	dragBottomRight:SetWidth(16)
	dragBottomRight:SetHeight(16)
	dragBottomRight:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	dragBottomRight:EnableMouse(true)
	dragBottomRight:SetScript(
		"OnMouseDown", 
		function(self, button)
			if (not frame.lockMoveSize:GetChecked()) then
				self:GetParent():StartSizing("BOTTOMRIGHT")
			end
		end
	)
	dragBottomRight:SetScript(
		"OnMouseUp", 
		function(self, button)
			self:GetParent():StopMovingOrSizing()
			--frame.lockMoveSize:SetChecked(true)
			--mySelf:_DisableResizeMove()
		end
	)
	frame.dragBottomRight = dragBottomRight

	local lockMoveSize = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	--lockMoveSize:Show()
	--lockMoveSize:SetFrameLevel(frame:GetFrameLevel() + 11)
	lockMoveSize:SetPoint("BOTTOMRIGHT", -10, 7)
	lockMoveSize:SetSize(25, 25)
	lockMoveSize:SetChecked(true)
	lockMoveSize:SetScript(
		"OnClick", 
		function(self, button)
			if (frame.lockMoveSize:GetChecked()) then
				mySelf:_DisableResizeMove()
			else
				mySelf:_EnableResizeMove()
			end
		end
	)
	frame.lockMoveSize = lockMoveSize

	frame:SetScript("OnMouseWheel", function(self, delta)
		--print(messageFrame:GetNumMessages())

		local cur_val = scrollBar:GetValue()
		local min_val, max_val = scrollBar:GetMinMaxValues()

		if delta < 0 and cur_val < max_val then
			cur_val = math.min(max_val, cur_val + 1)
			scrollBar:SetValue(cur_val)
		elseif delta > 0 and cur_val > min_val then
			cur_val = math.max(min_val, cur_val - 1)
			scrollBar:SetValue(cur_val)
		end
	end)

	SLASH_AHF1 = "/ahf"
	SlashCmdList.AHF = function()
		if QLTalk_ChatWindow:IsShown() then
			QLTalk_ChatWindow:Hide()
		else
			QLTalk_ChatWindow:Show()
		end
	end

	SLASH_CHATTEST1 = "/chattest"
	SlashCmdList.CHATTEST = function()
		messageFrame:AddMessage(
			"This is a test message to see if it all properly works, some more words to make it long enough", 
			255/255, 0/255, 0/255
		)
	end

	frame:SetScript(
		"OnSizeChanged", 
		function(self)
			mySelf:ResizeWindow();
		end
	)

	frame:Show()
	mySelf:_DisableResizeMove()

end

function ChatWindow:_DisableResizeMove()

	--self.frame:SetMovable(false)
	--self.frame:SetResizable(false)
	
	self.frame:RegisterForDrag()
	self.frame:SetScript("OnDragStart", nil)
	self.frame:SetScript("OnDragStop", nil)

	self.frame.dragBottomRight:Hide()

end

function ChatWindow:_EnableResizeMove()

	local mySelf = self

	--self.frame:SetMovable(true)
	--self.frame:SetResizable(true)
	
	self.frame:RegisterForDrag("LeftButton")
	self.frame:SetScript("OnDragStart", self.frame.StartMoving)
	self.frame:SetScript(
		"OnDragStop", 
		function(self)
			mySelf.frame:StopMovingOrSizing()
			--mySelf.frame.lockMoveSize:SetChecked(true)
			--mySelf:_DisableResizeMove()
		end
	)

	self.frame.dragBottomRight:Show()

end

function ChatWindow:ResizeWindow()
	local left, bottom, frameWidth, frameHeight = self.frame:GetRect()
	self.frame.chatInput:SetWidth(frameWidth - 50)
	self.frame.messageFrame:SetSize(frameWidth - 50, frameHeight - 60)
	self.frame.scrollBar:SetSize(30, frameHeight - 90)
end

QLTalk.ChatWindow = ChatWindow
