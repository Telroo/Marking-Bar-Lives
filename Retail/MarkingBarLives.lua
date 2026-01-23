-------------------------------------------------------
-- Local variables and Loaded Message
-------------------------------------------------------
-- Patch 10.1.0+ Fix
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

local MB = "|cffe1a500Marking|cff69ccf0Bar|cffff0000Lives|cffffffff"  -- MB Title
local MBF = "|cffe1a500MBL|cff69ccf0Flares|cffffffff"   -- MBFlares Title
local versionNum = GetAddOnMetadata("MarkingBarLives", "Version")
local curVer = "|cffffffff "..versionNum.."|cffe1a500"      -- Version Number

DEFAULT_CHAT_FRAME:AddMessage(MB..curVer..' is loaded.')
DEFAULT_CHAT_FRAME:AddMessage(MB..' Use /mbl to access the options panel.')

-------------------------------------------------------
-- Databases with Variable Options and Backdrops
-------------------------------------------------------
MBDB = {
    shown = true,
    aloneShow = true,
	partyShow = true,
    raidShow = true,
	locked = false,
	ctrlLock = true,
	clamped = true,
	flipped = false,
	vertical = false,
	bgHide = false,
	tooltips = true,
	scale = 1,
	alpha = 1,
	msg_intro = "I will use the following marks:", --Remember to change below if you change here!!!
	msg_skull = "Kill",
	msg_cross = "then kill",
	msg_square = "Hunter - Freezing Trap",
	msg_moon = "Mage - Polymorph",
	msg_triangle = "Druid - Hibernate",
	msg_diamond = "Warlock - Seduce/Banish/Enslave Demon",
	msg_circle = "Priest - Shackle/Mind Control",
	msg_star = "Rogue - Sap",
	msg_footer = "Input other miscellaneous text to send here.",
	announce_intro = true,
	announce_skull = true,
	announce_cross = true,
	announce_square = true,
	announce_moon = true,
	announce_triangle = true,
	announce_diamond = true,
	announce_circle = true,
	announce_star = true,
    announce_footer = false,
    announce_tooltips = false,
	dummy = true,
}

MBCtrlDB = {
    shown = true,
    aloneShow = true,
	partyShow = true,
    raidShow = true,
	locked = true,
	clamped = true,
	vertical = false,
	bgHide = false,
	tooltips = true,
	scale = 1,
	alpha = 1,
	MarkersAP = "",
	MarkersX = 0,
	MarkersY = 0,
	FlaresAP = "",
	FlaresX = 0,
	FlaresY = 0,
}

MBFlaresDB = {
	shown = true,
    aloneShow = true,
	partyShow = true,
    raidShow = true,
	locked = false,
	clamped = true,
	flipped = false,
	vertical = false,
	bgHide = false,
	tooltips = true,
	scale = 1,
	alpha = 1,
    announce_rw = false,
    msg_rw = "Please look at raid chat to see raid mark descriptions.",
}

-- For later use --
MBGLOBAL = {}

local defaultBackdrop = {
	bgFile = "Interface\\AddOns\\MarkingBarLives\\resources\\UI-Tooltip-Background",
	edgeFile = "Interface\\AddOns\\MarkingBarLives\\resources\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4,}
}
local borderlessBackdrop = {
	bgFile = "Interface\\AddOns\\MarkingBarLives\\resources\\UI-Tooltip-Background",
	tile = true,
	tileSize = 16
}

local editBoxBackdrop = {
	bgFile = "Interface\\AddOns\\MarkingBarLives\\resources\\Common-Input-Border",
	tile = false,InterfaceOptionsFramePanelContainer
}

-------------------------------------------------------
-- MB Main Frame and Movers
-------------------------------------------------------

local MB_mainFrame = CreateFrame("Frame", "MB_mainFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
MB_mainFrame:SetBackdrop(borderlessBackdrop)
MB_mainFrame:SetBackdropColor(0,0,0,0)
MB_mainFrame:EnableMouse(true)
MB_mainFrame:SetMovable(true)
MB_mainFrame:SetUserPlaced(true)
MB_mainFrame:SetUserPlaced(false)
MB_mainFrame:SetSize(190,35)
MB_mainFrame:SetPoint("TOP", UIParent, "TOP")
MB_mainFrame:SetClampedToScreen(false)

local moverLeft = CreateFrame("Frame", "moverLeft", MB_mainFrame, BackdropTemplateMixin and "BackdropTemplate")
moverLeft:SetBackdrop(defaultBackdrop)
moverLeft:SetBackdropColor(1,1,0.1,0.7) -- Make the move box yellow for better visibility
moverLeft:EnableMouse(true)
moverLeft:SetMovable(true)
moverLeft:SetSize(20,35)
moverLeft:SetPoint("RIGHT", MB_mainFrame, "LEFT")
moverLeft:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); 
	GameTooltip:ClearLines(); 
	if InCombatLockdown() then 
		GameTooltip:AddLine("Cannot move in combat", 1, 0.3, 0.3) 
	else 
		GameTooltip:AddLine("Move Bar",0.88,0.65,0) 
	end; 
	GameTooltip:Show() 
end)
moverLeft:RegisterForDrag("LeftButton")
moverLeft:SetScript("OnDragStart", function()
    if InCombatLockdown() then 
		return 
	else
		MB_mainFrame:StartMoving()
	end
end)
moverLeft:SetScript("OnDragStop", function()
    if InCombatLockdown() then 
		return 
	else
		MB_mainFrame:StopMovingOrSizing()
		MB_savepositions()
	end
end)

-------------------------------------------------------
-- MB Icon Frame and Icons
-------------------------------------------------------

local iconFrame = CreateFrame("Frame", "MB_iconFrame", MB_mainFrame, BackdropTemplateMixin and "BackdropTemplate")
iconFrame:SetBackdrop(defaultBackdrop)
iconFrame:SetBackdropColor(0.1,0.1,0.1,0.7)
iconFrame:EnableMouse(true)
iconFrame:SetMovable(true)
iconFrame:SetSize(190,35)
iconFrame:SetPoint("LEFT", MB_mainFrame, "LEFT")

local iconSkull = CreateFrame("Button", "iconSkull", iconFrame, "SecureActionButtonTemplate")
iconSkull:SetSize(15,15)
iconSkull:SetPoint("LEFT", iconFrame, "LEFT",5,0)
iconSkull:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
iconSkull:GetNormalTexture():SetTexCoord(0.75,1,0.25,0.5)
iconSkull:EnableMouse(true)

--iconSkull:SetScript("OnClick", function(self) SetRaidTargetIcon("target", 8) end)
iconSkull:RegisterForClicks("AnyDown")
iconSkull:SetAttribute("type", "macro")
iconSkull:SetAttribute("macrotext", "/tm 8")

iconSkull:SetScript("OnEnter", function(self) if (MBDB.tooltips==true) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); if MBDB.announce_tooltip then GameTooltip:AddLine(MBDB.msg_skull, 1,1,1,true); end GameTooltip:AddLine("Skull", 0.88,0.65,0); GameTooltip:Show() end end)
iconSkull:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local iconCross = CreateFrame("Button", "iconCross", iconFrame, "SecureActionButtonTemplate")
iconCross:SetSize(15,15)
iconCross:SetPoint("LEFT", iconSkull, "RIGHT")
iconCross:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
iconCross:GetNormalTexture():SetTexCoord(0.5,0.75,0.25,0.5)
iconCross:EnableMouse(true)

--iconCross:SetScript("OnClick", function(self) SetRaidTargetIcon("target", 7) end)
iconCross:RegisterForClicks("AnyDown")
iconCross:SetAttribute("type", "macro")
iconCross:SetAttribute("macrotext", "/tm 7")

iconCross:SetScript("OnEnter", function(self) if (MBDB.tooltips==true) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); if MBDB.announce_tooltip then GameTooltip:AddLine(MBDB.msg_cross, 1,1,1,true); end GameTooltip:AddLine("Cross", 0.88,0.65,0); GameTooltip:Show() end end)
iconCross:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local iconSquare = CreateFrame("Button", "iconSquare", iconFrame, "SecureActionButtonTemplate")
iconSquare:SetSize(15,15)
iconSquare:SetPoint("LEFT", iconCross, "RIGHT")
iconSquare:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
iconSquare:GetNormalTexture():SetTexCoord(0.25,0.5,0.25,0.5)
iconSquare:EnableMouse(true)

--iconSquare:SetScript("OnClick", function(self) SetRaidTargetIcon("target", 6) end)
iconSquare:RegisterForClicks("AnyDown")
iconSquare:SetAttribute("type", "macro")
iconSquare:SetAttribute("macrotext", "/tm 6")

iconSquare:SetScript("OnEnter", function(self) if (MBDB.tooltips==true) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); if MBDB.announce_tooltip then GameTooltip:AddLine(MBDB.msg_square, 1,1,1,true); end GameTooltip:AddLine("Square", 0.88,0.65,0); GameTooltip:Show() end end)
iconSquare:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local iconMoon = CreateFrame("Button", "iconMoon", iconFrame, "SecureActionButtonTemplate")
iconMoon:SetSize(15,15)
iconMoon:SetPoint("LEFT", iconSquare, "RIGHT")
iconMoon:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
iconMoon:GetNormalTexture():SetTexCoord(0,0.25,0.25,0.5)
iconMoon:EnableMouse(true)

--iconMoon:SetScript("OnClick", function(self) SetRaidTargetIcon("target", 5) end)
iconMoon:RegisterForClicks("AnyDown")
iconMoon:SetAttribute("type", "macro")
iconMoon:SetAttribute("macrotext", "/tm 5")

iconMoon:SetScript("OnEnter", function(self) if (MBDB.tooltips==true) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); if MBDB.announce_tooltip then GameTooltip:AddLine(MBDB.msg_moon, 1,1,1,true); end GameTooltip:AddLine("Moon", 0.88,0.65,0); GameTooltip:Show() end end)
iconMoon:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local iconTriangle = CreateFrame("Button", "iconTriangle", iconFrame, "SecureActionButtonTemplate")
iconTriangle:SetSize(15,15)
iconTriangle:SetPoint("LEFT", iconMoon, "RIGHT")
iconTriangle:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
iconTriangle:GetNormalTexture():SetTexCoord(0.75,1,0,0.25)
iconTriangle:EnableMouse(true)

--iconTriangle:SetScript("OnClick", function(self) SetRaidTargetIcon("target", 4) end)
iconTriangle:RegisterForClicks("AnyDown")
iconTriangle:SetAttribute("type", "macro")
iconTriangle:SetAttribute("macrotext", "/tm 4")

iconTriangle:SetScript("OnEnter", function(self) if (MBDB.tooltips==true) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); if MBDB.announce_tooltip then GameTooltip:AddLine(MBDB.msg_triangle, 1,1,1,true); end GameTooltip:AddLine("Triangle", 0.88,0.65,0); GameTooltip:Show() end end)
iconTriangle:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local iconDiamond = CreateFrame("Button", "iconDiamond", iconFrame, "SecureActionButtonTemplate")
iconDiamond:SetSize(15,15)
iconDiamond:SetPoint("LEFT", iconTriangle, "RIGHT")
iconDiamond:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
iconDiamond:GetNormalTexture():SetTexCoord(0.5,0.75,0,0.25)
iconDiamond:EnableMouse(true)

--iconDiamond:SetScript("OnClick", function(self) SetRaidTargetIcon("target", 3) end)
iconDiamond:RegisterForClicks("AnyDown")
iconDiamond:SetAttribute("type", "macro")
iconDiamond:SetAttribute("macrotext", "/tm 3")

iconDiamond:SetScript("OnEnter", function(self) if (MBDB.tooltips==true) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); if MBDB.announce_tooltip then GameTooltip:AddLine(MBDB.msg_diamond, 1,1,1,true); end GameTooltip:AddLine("Diamond", 0.88,0.65,0); GameTooltip:Show() end end)
iconDiamond:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local iconCircle = CreateFrame("Button", "iconCircle", iconFrame, "SecureActionButtonTemplate")
iconCircle:SetSize(15,15)
iconCircle:SetPoint("LEFT", iconDiamond, "RIGHT")
iconCircle:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
iconCircle:GetNormalTexture():SetTexCoord(0.25,0.5,0,0.25)
iconCircle:EnableMouse(true)

--iconCircle:SetScript("OnClick", function(self) SetRaidTargetIcon("target", 2) end)
iconCircle:RegisterForClicks("AnyDown")
iconCircle:SetAttribute("type", "macro")
iconCircle:SetAttribute("macrotext", "/tm 2")

iconCircle:SetScript("OnEnter", function(self) if (MBDB.tooltips==true) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); if MBDB.announce_tooltip then GameTooltip:AddLine(MBDB.msg_circle, 1,1,1,true); end GameTooltip:AddLine("Circle", 0.88,0.65,0); GameTooltip:Show() end end)
iconCircle:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local iconStar = CreateFrame("Button", "iconStar", iconFrame, "SecureActionButtonTemplate")
iconStar:SetSize(15,15)
iconStar:SetPoint("LEFT", iconCircle, "RIGHT")
iconStar:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
iconStar:GetNormalTexture():SetTexCoord(0,0.25,0,0.25)
iconStar:EnableMouse(true)

--iconStar:SetScript("OnClick", function(self) SetRaidTargetIcon("target", 1) end)
iconStar:RegisterForClicks("AnyDown")
iconStar:SetAttribute("type", "macro")
iconStar:SetAttribute("macrotext", "/tm 1")

iconStar:SetScript("OnEnter", function(self) if (MBDB.tooltips==true) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); if MBDB.announce_tooltip then GameTooltip:AddLine(MBDB.msg_star, 1,1,1,true); end GameTooltip:AddLine("Star", 0.88,0.65,0); GameTooltip:Show() end end)
iconStar:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local lockIcon = CreateFrame("Button", "lockIcon", iconFrame)
lockIcon:SetSize(20,20)
lockIcon:SetPoint("LEFT", iconStar , "RIGHT")
lockIcon:SetNormalTexture("Interface\\AddOns\\MarkingBarLives\\resources\\Glues-Addon-Icons")
lockIcon:GetNormalTexture():SetTexCoord(0.25, 0.50, 0, 1)
lockIcon:EnableMouse(true)
lockIcon:SetScript("OnClick", function(self) MB_lockToggle("main") end)
lockIcon:SetScript("OnEnter", function(self) if (MBDB.tooltips==true) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); if InCombatLockdown() then GameTooltip:AddLine("In Combat, Hold Shift + Click to (Un)Lock",1, 0.3, 0.3) else GameTooltip:AddLine("Lock/Unlock",0.88,0.65,0) end; GameTooltip:Show() end end)
lockIcon:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------------------------------------------
-- MB Control Frame and Movers
-------------------------------------------------------

local MB_controlFrame = CreateFrame("Frame", "MB_controlFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
MB_controlFrame:SetBackdrop(defaultBackdrop)
MB_controlFrame:SetBackdropColor(0.1,0.1,0.1,0.7)
MB_controlFrame:EnableMouse(true)
MB_controlFrame:SetMovable(true)
MB_controlFrame:SetSize(120,35)
if MBDB.ctrlLock then
    MB_controlFrame:SetSize(100,35)
end
MB_controlFrame:SetPoint("LEFT", MB_iconFrame, "RIGHT",5,0)

local moverRight = CreateFrame("Frame", "moverRight", MB_controlFrame, BackdropTemplateMixin and "BackdropTemplate")
moverRight:SetBackdrop(defaultBackdrop)
moverRight:SetBackdropColor(1,1,0.1,0.7) -- Make the move box yellow for better visibility
moverRight:EnableMouse(true)
moverRight:SetMovable(true)
moverRight:SetSize(20,35)
moverRight:SetPoint("LEFT", MB_controlFrame , "RIGHT")
moverRight:SetAlpha(1)
moverRight:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); 
	GameTooltip:ClearLines(); 
	if InCombatLockdown() then 
		GameTooltip:AddLine("Cannot move in combat", 1, 0.3, 0.3) 
	else 
		GameTooltip:AddLine("Move Bar",0.88,0.65,0) 
	end; 
	GameTooltip:Show() 
end)
moverRight:RegisterForDrag("LeftButton")
moverRight:SetScript("OnDragStart", function()
    if InCombatLockdown() then 
		return 
	else
		MB_controlFrame:StartMoving()
	end
end)
moverRight:SetScript("OnDragStop", function()
    if InCombatLockdown() then 
		return 
	else
		MB_controlFrame:StopMovingOrSizing()
		MB_savepositions()
	end
	
end)

-------------------------------------------------------
-- MB Control Icon Frame and Icons
-------------------------------------------------------

local announceIcon  = CreateFrame("Button", "announceIcon ", MB_controlFrame)
announceIcon :SetSize(20,20)
announceIcon :SetPoint("LEFT", MB_controlFrame, "LEFT",10,0)
announceIcon :SetNormalTexture("Interface\\AddOns\\MarkingBarLives\\resources\\announce")
announceIcon :GetNormalTexture():SetTexCoord(0,1,0,1)
announceIcon :EnableMouse(true)
announceIcon :SetScript("OnClick", function(self) MB_Announce() end)
announceIcon :SetScript("OnEnter", function(self) if (MBCtrlDB.tooltips==true) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); GameTooltip:AddLine("Announce to Chat", 0.88,0.65,0); GameTooltip:Show() end end)
announceIcon :SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local readyCheck = CreateFrame("Button", "readyCheck", MB_controlFrame)
readyCheck:SetSize(20,20)
readyCheck:SetPoint("LEFT", announceIcon , "RIGHT")
readyCheck:SetNormalTexture("interface\\raidframe\\readycheck-ready")
readyCheck:GetNormalTexture():SetTexCoord(0,1,0,1)
readyCheck:EnableMouse(true)
readyCheck:SetScript("OnClick", function(self) DoReadyCheck() end)
readyCheck:SetScript("OnEnter", function(self) if (MBCtrlDB.tooltips==true) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); GameTooltip:AddLine("Ready Check",0.88,0.65,0); GameTooltip:Show() end end)
readyCheck:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local roleCheck = CreateFrame("Button", "roleCheck", MB_controlFrame)
roleCheck:SetSize(20,20)
roleCheck:SetPoint("LEFT", readyCheck , "RIGHT")
roleCheck:SetNormalTexture("interface\\raidframe\\readycheck-waiting")
roleCheck:GetNormalTexture():SetTexCoord(0,1,0,1)
roleCheck:EnableMouse(true)
roleCheck:SetScript("OnClick", function(self) InitiateRolePoll() end)
roleCheck:SetScript("OnEnter", function(self) if (MBCtrlDB.tooltips==true) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); GameTooltip:AddLine("Role Poll",0.88,0.65,0); GameTooltip:Show() end end)
roleCheck:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local optIcon = CreateFrame("Button", "optIcon", MB_controlFrame)
optIcon:SetSize(20,20)
optIcon:SetPoint("LEFT", roleCheck , "RIGHT")
optIcon:SetNormalTexture("interface\\AddOns\\MarkingBarLives\\resources\\Gear_64")
optIcon:GetNormalTexture():SetTexCoord(0,.5,0,.5)
optIcon:EnableMouse(true)
optIcon:RegisterForClicks("AnyDown")
optIcon:SetScript("OnClick", function(self,button) 
	if InCombatLockdown() then
		return
	else 
		Settings.OpenToCategory(MarkingBarOptSettingsCategoryId) 
	end 
end)
optIcon:SetScript("OnEnter", function(self)
    if (MBCtrlDB.tooltips == true) then
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
        GameTooltip:ClearLines();
        if InCombatLockdown() then
            GameTooltip:AddLine("Cannot open in combat", 1, 0.3, 0.3)
        else
            GameTooltip:AddLine("Options", 0.88, 0.65, 0);
        end
	GameTooltip:Show();
    end
end)
optIcon:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local ctrlLockIcon = CreateFrame("Button", "ctrlLockIcon", MB_controlFrame)
ctrlLockIcon:SetSize(20,20)
ctrlLockIcon:SetNormalTexture("Interface\\AddOns\\MarkingBarLives\\resources\\Glues-Addon-Icons")
ctrlLockIcon:GetNormalTexture():SetTexCoord(0.25, 0.50, 0, 1)
ctrlLockIcon:SetScript("OnClick", function(self) MB_lockToggle("ctrl") end)
ctrlLockIcon:SetScript("OnEnter", function(self) if (MBCtrlDB.tooltips==true) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); if InCombatLockdown() then GameTooltip:AddLine("In Combat, Hold Shift + Click to (Un)Lock",1, 0.3, 0.3) else GameTooltip:AddLine("Lock/Unlock",0.88,0.65,0) end; GameTooltip:Show() end end)
ctrlLockIcon:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
ctrlLockIcon:SetPoint("LEFT", optIcon , "RIGHT")
ctrlLockIcon:SetAlpha(1)
ctrlLockIcon:EnableMouse(true)

-------------------------------------------------------
-- MBFlares Main Frame and Movers
-------------------------------------------------------

local MBFlares_mainFrame = CreateFrame("Frame", "MBFlares_mainFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
MBFlares_mainFrame:SetBackdrop(borderlessBackdrop)
MBFlares_mainFrame:SetBackdropColor(0,0,0,0)
MBFlares_mainFrame:EnableMouse(true)
MBFlares_mainFrame:SetMovable(true)
MBFlares_mainFrame:SetUserPlaced(true)
MBFlares_mainFrame:SetUserPlaced(false)
MBFlares_mainFrame:SetSize(180,35)
MBFlares_mainFrame:SetPoint("TOP", UIParent, "TOP",0,-40)
MBFlares_mainFrame:SetClampedToScreen(false)

local MBFlares_moverLeft = CreateFrame("Frame", "MBFlares_moverLeft", MBFlares_mainFrame, BackdropTemplateMixin and "BackdropTemplate")
MBFlares_moverLeft:SetBackdrop(defaultBackdrop)
MBFlares_moverLeft:SetBackdropColor(1,1,0.1,0.7) -- Make the move box yellow for better visibility
MBFlares_moverLeft:EnableMouse(true)
MBFlares_moverLeft:SetMovable(true)
MBFlares_moverLeft:SetSize(20,35)
MBFlares_moverLeft:SetPoint("RIGHT", MBFlares_mainFrame, "LEFT")
MBFlares_moverLeft:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); 
	GameTooltip:ClearLines(); 
	if InCombatLockdown() then 
		GameTooltip:AddLine("Cannot move in combat", 1, 0.3, 0.3) 
	else 
		GameTooltip:AddLine("Move Bar",0.88,0.65,0) 
	end; 
	GameTooltip:Show() 
end)
MBFlares_moverLeft:RegisterForDrag("LeftButton")
MBFlares_moverLeft:SetScript("OnDragStart", function()
    if InCombatLockdown() then 
		return
	else
		MBFlares_mainFrame:StartMoving()
	end
end)
MBFlares_moverLeft:SetScript("OnDragStop", function()
    if InCombatLockdown() then 
		return
	else
		MBFlares_mainFrame:StopMovingOrSizing()
		MB_savepositions()
	end
end)

-------------------------------------------------------
-- The Flare Frame and Flares
-------------------------------------------------------
local flareFrame = CreateFrame("Frame", "MB_flareFrame", MBFlares_mainFrame, BackdropTemplateMixin and "BackdropTemplate")
flareFrame:SetBackdrop(defaultBackdrop)
flareFrame:SetBackdropColor(0.1,0.1,0.1,0.1,0.7)
flareFrame:EnableMouse(true)
flareFrame:SetMovable(true)
flareFrame:SetSize(255,35)
flareFrame:SetPoint("LEFT", MBFlares_mainFrame, "LEFT")

local flareWhite = CreateFrame("Button", "flareWhite", flareFrame, "SecureActionButtonTemplate")
flareWhite:SetSize(25,25)
flareWhite:SetNormalTexture("interface\\minimap\\partyraidblips")
flareWhite:GetNormalTexture():SetTexCoord(0.5,0.625,0,0.25)
flareWhite:SetPoint("TOPLEFT", flareFrame, "TOPLEFT",5,-5)
flareWhite:SetAttribute("type", "macro")
flareWhite:SetAttribute("macrotext1", "/wm 8")
flareWhite:RegisterForClicks("AnyDown")
flareWhite:SetScript("OnEnter", function(self) if (MBFlaresDB.tooltips) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); GameTooltip:AddLine("Skull world marker",0.88,0.65,0); GameTooltip:Show() end end)
flareWhite:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local flareRed = CreateFrame("Button", "flareRed", flareFrame, "SecureActionButtonTemplate")
flareRed:SetSize(25,25)
flareRed:SetNormalTexture("interface\\minimap\\partyraidblips")
flareRed:GetNormalTexture():SetTexCoord(0.625,0.75,0,0.25)
flareRed:SetPoint("LEFT", flareWhite, "RIGHT")
flareRed:SetAttribute("type", "macro")
flareRed:SetAttribute("macrotext1", "/wm 4")
flareRed:RegisterForClicks("AnyDown")
flareRed:SetScript("OnEnter", function(self) if (MBFlaresDB.tooltips) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); GameTooltip:AddLine("Cross world marker",0.88,0.65,0); GameTooltip:Show() end end)
flareRed:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local flareBlue = CreateFrame("Button", "flareBlue", flareFrame, "SecureActionButtonTemplate")
flareBlue:SetSize(25,25)
flareBlue:SetNormalTexture("interface\\minimap\\partyraidblips")
flareBlue:GetNormalTexture():SetTexCoord(0.75,0.875,0,0.25)
flareBlue:SetPoint("LEFT", flareRed, "RIGHT")
flareBlue:SetAttribute("type", "macro")
flareBlue:SetAttribute("macrotext1", "/wm 1")
flareBlue:RegisterForClicks("AnyDown")
flareBlue:SetScript("OnEnter", function(self) if (MBFlaresDB.tooltips) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); GameTooltip:AddLine("Square world marker",0.88,0.65,0); GameTooltip:Show() end end)
flareBlue:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local flareSilver = CreateFrame("Button", "flareSilver", flareFrame, "SecureActionButtonTemplate")
flareSilver:SetSize(25,25)
flareSilver:SetNormalTexture("interface\\minimap\\partyraidblips")
flareSilver:GetNormalTexture():SetTexCoord(0.875,1,0,0.25)
flareSilver:SetPoint("LEFT", flareBlue, "RIGHT")
flareSilver:SetAttribute("type", "macro")
flareSilver:SetAttribute("macrotext1", "/wm 7")
flareSilver:RegisterForClicks("AnyDown")
flareSilver:SetScript("OnEnter", function(self) if (MBFlaresDB.tooltips) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); GameTooltip:AddLine("Moon world marker",0.88,0.65,0); GameTooltip:Show() end end)
flareSilver:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local flareGreen = CreateFrame("Button", "flareGreen", flareFrame, "SecureActionButtonTemplate")
flareGreen:SetSize(25,25)
flareGreen:SetNormalTexture("interface\\minimap\\partyraidblips")
flareGreen:GetNormalTexture():SetTexCoord(0.25,0.375,0,0.25)
flareGreen:SetPoint("LEFT", flareSilver, "RIGHT")
flareGreen:SetAttribute("type", "macro")
flareGreen:SetAttribute("macrotext1", "/wm 2")
flareGreen:RegisterForClicks("AnyDown")
flareGreen:SetScript("OnEnter", function(self) if (MBFlaresDB.tooltips) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); GameTooltip:AddLine("Triangle world marker",0.88,0.65,0); GameTooltip:Show() end end)
flareGreen:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local flarePurple = CreateFrame("Button", "flarePurple", flareFrame, "SecureActionButtonTemplate")
flarePurple:SetSize(25,25)
flarePurple:SetNormalTexture("interface\\minimap\\partyraidblips")
flarePurple:GetNormalTexture():SetTexCoord(0,0.125,0.25,0.5)
flarePurple:SetPoint("LEFT", flareGreen, "RIGHT")
flarePurple:SetAttribute("type", "macro")
flarePurple:SetAttribute("macrotext1", "/wm 3")
flarePurple:RegisterForClicks("AnyDown")
flarePurple:SetScript("OnEnter", function(self) if (MBFlaresDB.tooltips) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); GameTooltip:AddLine("Diamond world marker",0.88,0.65,0); GameTooltip:Show() end end)
flarePurple:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local flareOrange = CreateFrame("Button", "flareOrange", flareFrame, "SecureActionButtonTemplate")
flareOrange:SetSize(25,25)
flareOrange:SetNormalTexture("interface\\minimap\\partyraidblips")
flareOrange:GetNormalTexture():SetTexCoord(0.25,0.375,0.25,0.5)
flareOrange:SetPoint("LEFT", flarePurple, "RIGHT")
flareOrange:SetAttribute("type", "macro")
flareOrange:SetAttribute("macrotext1", "/wm 6")
flareOrange:RegisterForClicks("AnyDown")
flareOrange:SetScript("OnEnter", function(self) if (MBFlaresDB.tooltips) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); GameTooltip:AddLine("Circle world marker",0.88,0.65,0); GameTooltip:Show() end end)
flareOrange:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local flareYellow = CreateFrame("Button", "flareYellow", flareFrame, "SecureActionButtonTemplate")
flareYellow:SetSize(25,25)
flareYellow:SetNormalTexture("interface\\minimap\\partyraidblips")
flareYellow:GetNormalTexture():SetTexCoord(0.375,0.5,0,0.25)
flareYellow:SetPoint("LEFT", flareOrange, "RIGHT")
flareYellow:SetAttribute("type", "macro")
flareYellow:SetAttribute("macrotext1", "/wm 5")
flareYellow:RegisterForClicks("AnyDown")
flareYellow:SetScript("OnEnter", function(self) if (MBFlaresDB.tooltips) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); GameTooltip:AddLine("Star world marker",0.88,0.65,0); GameTooltip:Show() end end)
flareYellow:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local flareClear = CreateFrame("Button", "flareClear", flareFrame, "SecureActionButtonTemplate")
flareClear:SetSize(15,15)
flareClear:SetNormalTexture("interface\\glues\\loadingscreens\\dynamicelements")
flareClear:GetNormalTexture():SetTexCoord(0,0.5,0,0.5)
flareClear:SetPoint("LEFT", flareYellow, "RIGHT")
flareClear:SetAttribute("type", "macro")
flareClear:SetAttribute("macrotext1", "/cwm 0")
flareClear:RegisterForClicks("AnyDown")
flareClear:SetScript("OnEnter", function(self) if (MBFlaresDB.tooltips) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); GameTooltip:AddLine("Clear all world markers.",0.88,0.65,0); GameTooltip:Show() end end)
flareClear:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local flarelockIcon = CreateFrame("Button", "flarelockIcon", flareFrame)
flarelockIcon:SetSize(20,20)
flarelockIcon:SetPoint("LEFT", flareClear , "RIGHT",5,0)
flarelockIcon:SetNormalTexture("Interface\\AddOns\\MarkingBarLives\\resources\\Glues-Addon-Icons")
flarelockIcon:GetNormalTexture():SetTexCoord(0.25, 0.50, 0, 1)
flarelockIcon:EnableMouse(true)
flarelockIcon:SetScript("OnClick", function(self) MB_lockToggle("flare") end)
flarelockIcon:SetScript("OnEnter", function(self) if (MBFlaresDB.tooltips) then GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); if InCombatLockdown() then GameTooltip:AddLine("In Combat, Hold Shift + Click to (Un)Lock",1, 0.3, 0.3) else GameTooltip:AddLine("Lock/Unlock",0.88,0.65,0) end; GameTooltip:Show() end end)
flarelockIcon:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------------------------------------------
-- Functions
-------------------------------------------------------

function MB_Announce()
	if IsInGroup(LE_PARTY_CATEGORY_HOME) then -- true if player is in a group. 
		if IsInRaid() then  -- IN A RAID
			if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then		-- ABLE TO MARK
				MB_Announce_to_Chat("RAID")	
			else							--NOT ABLE TO MARK
				ChatFrame1:AddMessage(MB .. ": You are not a Raid Leader or Raid Assistant. You cannot use raid markers.");
			end
		else -- IN A PARTY
			MB_Announce_to_Chat("PARTY") 
		end	
			else if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then -- true if the player is in a instance type group. (e.g. LFG, LFR) 
				if IsInRaid() then  -- IN A RAID
					if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then		-- ABLE TO MARK
						MB_Announce_to_Chat("INSTANCE_CHAT")	
					else
				ChatFrame1:AddMessage(MB .. ": You are not a Raid Leader or Raid Assistant. You cannot use raid markers.");
			end
		else
				MB_Announce_to_Chat("INSTANCE_CHAT") 
			end
		else -- NOT IN RAID OR PARTY
			ChatFrame1:AddMessage(MB .. ": You are not in a Party or Raid.");
		end
	end
end

function MB_Announce_to_Chat(ChatType)
	if (MBDB.announce_intro) then
		SendChatMessage(MBDB.msg_intro,ChatType,nil)
	end
	if (MBDB.announce_skull) then
		SendChatMessage(MBDB.msg_skull .. " {rt8}.",ChatType,nil)
	end
	if (MBDB.announce_cross) then
		SendChatMessage(MBDB.msg_cross .. " {rt7}.",ChatType,nil)
	end
	if (MBDB.announce_square) then
		SendChatMessage(MBDB.msg_square .. " {rt6}.",ChatType,nil)
	end
	if (MBDB.announce_moon) then
		SendChatMessage(MBDB.msg_moon .. " {rt5}.",ChatType,nil)
	end
	if (MBDB.announce_triangle) then
		SendChatMessage(MBDB.msg_triangle .. " {rt4}.",ChatType,nil)
	end
	if (MBDB.announce_diamond) then
		SendChatMessage(MBDB.msg_diamond .. " {rt3}.",ChatType,nil)
	end
	if (MBDB.announce_circle) then
		SendChatMessage(MBDB.msg_circle .. " {rt2}.",ChatType,nil)
	end
	if (MBDB.announce_star) then
		SendChatMessage(MBDB.msg_star .. " {rt1}.",ChatType,nil)
	end
    if (MBDB.announce_footer) then
		SendChatMessage(MBDB.msg_footer,ChatType,nil)
	end

    if ( ChatType == "RAID") then
        if MBFlaresDB.announce_rw then
            SendChatMessage(MBFlaresDB.msg_rw,ChatType,nil);
            SendChatMessage(MBFlaresDB.msg_rw,"RAID_WARNING",nil);
        end
    end
end

local function SafeSetShown(frame, show)
    if not frame then return end

    if InCombatLockdown() then
        frame._pendingShown = show
        return
    end

    if show then
        frame:Show()
    else
        frame:Hide()
    end
end

local combatWatcher = CreateFrame("Frame")
combatWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
combatWatcher:SetScript("OnEvent", function()
    for _, frame in ipairs({
        MB_mainFrame,
        MB_controlFrame,
        MBFlares_mainFrame
    }) do
        if frame and frame._pendingShown ~= nil then
            if frame._pendingShown then
                frame:Show()
            else
                frame:Hide()
            end
            frame._pendingShown = nil
        end
    end
end)

function MB_targetChecker(DB)
    if DB == "main" then
        if not MB_mainFrame then return end
		
		if not MBDB.shown and not UnitExists("target") then --show only with targe & target exists
            SafeSetShown(MB_mainFrame, false)
        else
            SafeSetShown(MB_mainFrame, true) -- show regardless of target
        end
    elseif ( DB == "ctrl" ) then
        if not MB_controlFrame then return end

        if not MBCtrlDB.shown and not UnitExists("target") then --show only with targe & target exists
            SafeSetShown(MB_controlFrame, false)
        else
            SafeSetShown(MB_mainFrame, true) -- show regardless of target
        end
    elseif ( DB == "flare" ) then
        if not MBFlares_mainFrame then return end

        if not MBFlaresDB.shown and not UnitExists("target") then --show only with targe & target exists
            SafeSetShown(MBFlares_mainFrame, false)
        else
            SafeSetShown(MB_mainFrame, true) -- show regardless of target
        end
    end
end

function MB_partyChecker(DB)
    if ( DB == "main" ) then
		if (IsInGroup()) then -- IN A PARTY OR RAID
			if (IsInRaid()) then -- IN A RAID
				if (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
					SafeSetShown(MB_mainFrame, true)
				end
			else -- IN APARTY
				if ( MBDB.partyShow == true ) then
					SafeSetShown(MB_mainFrame, true)
				else
					SafeSetShown(MB_mainFrame, false)
				end
			end
		else -- NOT IN ANY GROUP
			if ( MBDB.aloneShow == true ) then
				SafeSetShown(MB_mainFrame, true)
			else
				SafeSetShown(MB_mainFrame, false)
			end
		end
    elseif ( DB == "ctrl" ) then
		if (IsInGroup()) then -- IN A PARTY OR RAID
			if (IsInRaid()) then -- IN A RAID
				if (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
					SafeSetShown(MB_controlFrame, true)
				end
			else -- IN APARTY
				if ( MBCtrlDB.partyShow == true ) then
					SafeSetShown(MB_controlFrame, true)
				else
					SafeSetShown(MB_controlFrame, false)
				end
			end
		else -- NOT IN ANY GROUP
			if ( MBCtrlDB.aloneShow == true ) then
				SafeSetShown(MB_controlFrame, true)
			else
				SafeSetShown(MB_controlFrame, false)
			end
		end
    elseif ( DB == "flare" ) then
		if (IsInGroup()) then -- IN A PARTY OR RAID
			if (IsInRaid()) then -- IN A RAID
				if (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
					SafeSetShown(MBFlares_mainFrame, true)
				end
			else -- IN APARTY
				if ( MBFlaresDB.partyShow == true ) then
					SafeSetShown(MBFlares_mainFrame, true)
				else
					SafeSetShown(MBFlares_mainFrame, false)
				end
			end
		else -- NOT IN ANY GROUP
			if ( MBFlaresDB.aloneShow == true ) then
				SafeSetShown(MBFlares_mainFrame, true)
			else
				SafeSetShown(MBFlares_mainFrame, false)
			end
		end
    end
end

function MB_lock(DB)
    if ( DB == "main" ) then
        MBDB.locked = true
        moverLeft:SetAlpha(0)
        moverLeft:EnableMouse(false)
        lockIcon:GetNormalTexture():SetTexCoord(0, 0.25, 0, 1)
    elseif  ( DB == "ctrl" ) then
        MBCtrlDB.locked = true
        moverRight:SetAlpha(0)
        moverRight:EnableMouse(false)
        ctrlLockIcon:GetNormalTexture():SetTexCoord(0, 0.25, 0, 1)
    elseif  ( DB == "flare" ) then
        MBFlaresDB.locked = true
    	MBFlares_moverLeft:SetAlpha(0)
        MBFlares_moverLeft:EnableMouse(false)
        flarelockIcon:GetNormalTexture():SetTexCoord(0, 0.25, 0, 1)
    end
end

function MB_unlock(DB)
    if ( DB == "main" ) then
        MBDB.locked = false
        moverLeft:SetAlpha(1)
        moverLeft:EnableMouse(true)
        lockIcon:GetNormalTexture():SetTexCoord(0.25, 0.50, 0, 1)
    elseif  ( DB == "ctrl" ) then
        MBCtrlDB.locked = false
        moverRight:SetAlpha(1)
        moverRight:EnableMouse(true)
        ctrlLockIcon:GetNormalTexture():SetTexCoord(0.25, 0.50, 0, 1)
    elseif  ( DB == "flare" ) then
        MBFlaresDB.locked = false
        MBFlares_moverLeft:SetAlpha(1)
        MBFlares_moverLeft:EnableMouse(true)
        flarelockIcon:GetNormalTexture():SetTexCoord(0.25, 0.50, 0, 1)
    end
end

function MB_lockToggle(DB)
	if InCombatLockdown() then -- In Combat prevents Lock interaction		
		--if IsControlKeyDown() and not (IsAltKeyDown() or IsShiftKeyDown()) then -- Ctrl and not Alt or Shift is used to unlock
		if IsShiftKeyDown() then -- Shift is used to unlock
			if ( DB == "main" ) then
				if MBDB.locked then
					MB_unlock("main")
				else
					MB_lock("main")
				end
			elseif ( DB == "ctrl" ) then
				if MBCtrlDB.locked then
					if MBDB.ctrlLock then -- if ctrl is connected to icons
						MB_ctrlUnlock()
					end
					MB_unlock("ctrl")
				else
					MB_lock("ctrl")
				end
			elseif ( DB == "flare" ) then
				if MBFlaresDB.locked then
					MB_unlock("flare")
				else
					MB_lock("flare")
				end
			end
		end
	else -- Out of Combat allows Lock interaction	
		if ( DB == "main" ) then
			if MBDB.locked then
				MB_unlock("main")
			else
				MB_lock("main")
			end
		elseif ( DB == "main_menu" ) then
			if MBDB.locked then
				MB_unlock("main")
			else
				MB_lock("main")
			end
		elseif ( DB == "ctrl" ) then
			if MBCtrlDB.locked then -- if ctrl is connected to icons
				if MBDB.ctrlLock then
					MB_ctrlUnlock()
				end
				MB_unlock("ctrl")
			else
				MB_lock("ctrl")
			end
		elseif ( DB == "ctrl_menu" ) then
			if MBCtrlDB.locked then
				if MBDB.ctrlLock then -- if ctrl is connected to icons
					MB_ctrlUnlock()
				end
				MB_unlock("ctrl")
			else
				MB_lock("ctrl")
			end
		elseif ( DB == "flare" ) then
			if MBFlaresDB.locked then
				MB_unlock("flare")
			else
				MB_lock("flare")
			end
		elseif ( DB == "flare_menu" ) then
			if MBFlaresDB.locked then
				MB_unlock("flare")
			else
			MB_lock("flare")
			end
		end
	end
end

function MB_ctrlLock()
	MBDB.ctrlLock = true
    MB_lock("ctrl")
    MB_flipChecker()
end

function MB_ctrlUnlock()
	MBDB.ctrlLock = false
    MB_unlock("ctrl")
    MB_flipChecker()
end

function MB_ctrlLockToggle()
	if (MBDB.ctrlLock == true) then
		MB_ctrlUnlock()
	else
		MB_ctrlLock()
	end
end

function MB_reset_msg() 	--Remember to change up top if you change here!!!
	MBDB.msg_intro = "I will use the following marks:"
	MBDB.msg_skull = "Kill"
	MBDB.msg_cross = "Then kill"
	MBDB.msg_square = "Hunter - Freezing Trap"
	MBDB.msg_moon = "Mage - Polymorph"
	MBDB.msg_triangle = "Druid - Hibernate"
	MBDB.msg_diamond = "Warlock - Seduce/Banish/Enslave Demon"
	MBDB.msg_circle = "Priest - Shackle/Mind Control"
	MBDB.msg_star = "Rogue - Sap"
    MBDB.msg_footer = "Input other miscellaneous text to send here."
	MBDB.announce_intro = true
	MBDB.announce_skull = true
	MBDB.announce_cross = true
	MBDB.announce_square = true
	MBDB.announce_moon = true
	MBDB.announce_triangle = true
	MBDB.announce_diamond = true
	MBDB.announce_circle = true
	MBDB.announce_star = true
    MBDB.announce_footer = false
    MBFlaresDB.announce_rw = false
    MBFlaresDB.msg_rw = "Please look at raid chat to see raid mark descriptions."
end

function MB_reset()
    -- reset variables
    MBDB.ctrlLock = true
	MBDB.shown = true
    MBDB.aloneShow = true
	MBDB.partyShow = true
    MBDB.raidShow = true
	MBDB.locked= false
	MBDB.clamped = true
	MBDB.flipped = false
	MBDB.vertical = false
	MBDB.bgHide = false
	MBDB.tooltips = true
	MBDB.scale = 1
	MBDB.alpha = 1

	MB_reset_msg()

    --reset orientations
    MB_targetChecker("main")
	MB_unlock("main")
	MB_mainFrame:SetClampedToScreen(true)
	MB_bgShow("main")

    --reset variables for Ctrl
	MBCtrlDB.shown = true
    MBCtrlDB.aloneShow = true
	MBCtrlDB.partyShow = true
    MBCtrlDB.raidShow = true
	MBCtrlDB.locked = true
	MBCtrlDB.clamped = true
	MBCtrlDB.vertical = false
	MBCtrlDB.bgHide = false
	MBCtrlDB.tooltips = true
    MBDB.announce_tooltip = false
	MBCtrlDB.scale = 1
	MBCtrlDB.alpha = 1
    --reset orientation for Ctrl
	MB_targetChecker("ctrl")
    MB_ctrlLock()
	MB_lock("ctrl")
	MB_controlFrame:SetClampedToScreen(true)
	MB_bgShow("ctrl")

	MB_flipChecker()

    --reset variables for flares
	MBFlaresDB.shown = true
    MBFlaresDB.aloneShow = true
	MBFlaresDB.partyShow = true
    MBFlaresDB.raidShow = true
	MBFlaresDB.locked = false
	MBFlaresDB.clamped = true
	MBFlaresDB.bgHide = false
	MBFlaresDB.tooltips = true
	MBFlaresDB.scale = 1
	MBFlaresDB.alpha = 1
    --reset orientation for flares
	MB_targetChecker("flare")
	MB_unlock("flare")
	MBFlares_mainFrame:SetClampedToScreen(true)
    MB_flareflip(1)
	MB_bgShow("flare")
    --updates checkmarks
    --reset frames to center positions
	MB_mainFrame:ClearAllPoints()
    MB_controlFrame:ClearAllPoints()
	MBFlares_mainFrame:ClearAllPoints()
	MB_mainFrame:SetPoint("TOP", UIParent, "TOP")
    MB_controlFrame:SetPoint("LEFT", MB_iconFrame, "RIGHT",5,0)
	MBFlares_mainFrame:SetPoint("TOP", UIParent, "TOP",0,-50)
	MB_checkUpdater()
end

local VALID_POINTS = {
    TOP = true, BOTTOM = true, LEFT = true, RIGHT = true,
    TOPLEFT = true, TOPRIGHT = true,
    BOTTOMLEFT = true, BOTTOMRIGHT = true,
    CENTER = true,
}

local function NormalizePoint(p)
    return VALID_POINTS[p] and p or "TOP"
end

function MB_savepositions()
    local p, _, rp, x, y = MB_mainFrame:GetPoint()
    MBCtrlDB.MarkersPoint = p
    MBCtrlDB.MarkersRelativePoint = rp
    MBCtrlDB.MarkersX = x
    MBCtrlDB.MarkersY = y

    local fp, _, frp, fx, fy = MBFlares_mainFrame:GetPoint()
    MBCtrlDB.FlaresPoint = fp
    MBCtrlDB.FlaresRelativePoint = frp
    MBCtrlDB.FlaresX = fx
    MBCtrlDB.FlaresY = fy
end

function MB_setpositions()
    MB_mainFrame:ClearAllPoints()
    MB_mainFrame:SetPoint(
        NormalizePoint(MBCtrlDB.MarkersPoint),
        UIParent,
        NormalizePoint(MBCtrlDB.MarkersRelativePoint),
        MBCtrlDB.MarkersX,
        MBCtrlDB.MarkersY
    )

    MBFlares_mainFrame:ClearAllPoints()
    MBFlares_mainFrame:SetPoint(
        NormalizePoint(MBCtrlDB.FlaresPoint),
        UIParent,
        NormalizePoint(MBCtrlDB.FlaresRelativePoint),
        MBCtrlDB.FlaresX,
        MBCtrlDB.FlaresY
    )

    MB_checkUpdater()
end

function MB_flip(dir)
	iconSkull:ClearAllPoints()
	iconCross:ClearAllPoints()
	iconSquare:ClearAllPoints()
	iconMoon:ClearAllPoints()
	iconTriangle:ClearAllPoints()
	iconDiamond:ClearAllPoints()
	iconCircle:ClearAllPoints()
	iconStar:ClearAllPoints()
	lockIcon:ClearAllPoints()
	moverLeft:ClearAllPoints()
	iconFrame:ClearAllPoints()
    announceIcon:ClearAllPoints()
	readyCheck:ClearAllPoints()
	roleCheck:ClearAllPoints()
	optIcon:ClearAllPoints()
    ctrlLockIcon:ClearAllPoints()
    moverRight:ClearAllPoints()
	if (dir==1) then -- Normal
		iconSkull:SetPoint("LEFT", iconFrame, "LEFT",10,0)
		iconCross:SetPoint("LEFT", iconSkull, "RIGHT",5,0)
		iconSquare:SetPoint("LEFT", iconCross, "RIGHT",5,0)
		iconMoon:SetPoint("LEFT", iconSquare, "RIGHT",5,0)
		iconTriangle:SetPoint("LEFT", iconMoon, "RIGHT",5,0)
		iconDiamond:SetPoint("LEFT", iconTriangle, "RIGHT",5,0)
		iconCircle:SetPoint("LEFT", iconDiamond, "RIGHT",5,0)
		iconStar:SetPoint("LEFT", iconCircle, "RIGHT",5,0)
		lockIcon:SetPoint("LEFT", iconStar , "RIGHT",5,0)
		MB_mainFrame:SetSize(198,35)
		iconFrame:SetSize(198,35)
		iconFrame:SetPoint("LEFT", MB_mainFrame, "LEFT")
        moverLeft:SetSize(20,35)
		moverLeft:SetPoint("RIGHT", MB_mainFrame, "LEFT")
	elseif (dir==2) then -- Backwards
		iconStar:SetPoint("LEFT", iconFrame, "LEFT",10,0)
		iconCircle:SetPoint("LEFT", iconStar, "RIGHT",5,0)
		iconDiamond:SetPoint("LEFT", iconCircle, "RIGHT",5,0)
		iconTriangle:SetPoint("LEFT", iconDiamond, "RIGHT",5,0)
		iconMoon:SetPoint("LEFT", iconTriangle, "RIGHT",5,0)
		iconSquare:SetPoint("LEFT", iconMoon, "RIGHT",5,0)
		iconCross:SetPoint("LEFT", iconSquare, "RIGHT",5,0)
		iconSkull:SetPoint("LEFT", iconCross, "RIGHT",5,0)
		lockIcon:SetPoint("LEFT", iconSkull , "RIGHT",5,0)
		MB_mainFrame:SetSize(198,35)
		iconFrame:SetSize(198,35)
		iconFrame:SetPoint("LEFT", MB_mainFrame, "LEFT")
		moverLeft:SetSize(20,35)
		moverLeft:SetPoint("RIGHT", MB_mainFrame, "LEFT")
	elseif (dir==3) then -- Normal vertical
		iconSkull:SetPoint("TOP", iconFrame, "TOP",0,-10)
		iconCross:SetPoint("TOP", iconSkull, "BOTTOM",0,-5)
		iconSquare:SetPoint("TOP", iconCross, "BOTTOM",0,-5)
		iconMoon:SetPoint("TOP", iconSquare, "BOTTOM",0,-5)
		iconTriangle:SetPoint("TOP", iconMoon, "BOTTOM",0,-5)
		iconDiamond:SetPoint("TOP", iconTriangle, "BOTTOM",0,-5)
		iconCircle:SetPoint("TOP", iconDiamond, "BOTTOM",0,-5)
		iconStar:SetPoint("TOP", iconCircle, "BOTTOM",0,-5)
		lockIcon:SetPoint("TOP", iconStar , "BOTTOM",0,-5)
		MB_mainFrame:SetSize(35,198)
		iconFrame:SetSize(35,198)
		iconFrame:SetPoint("TOP", MB_mainFrame, "TOP")
		moverLeft:SetSize(35,20)
		moverLeft:SetPoint("BOTTOM", MB_mainFrame, "TOP")
	elseif (dir==4) then -- Backwards vertical
		iconStar:SetPoint("TOP", iconFrame, "TOP",0,-10)
		iconCircle:SetPoint("TOP", iconStar, "BOTTOM",0,-5)
		iconDiamond:SetPoint("TOP", iconCircle, "BOTTOM",0,-5)
		iconTriangle:SetPoint("TOP", iconDiamond, "BOTTOM",0,-5)
		iconMoon:SetPoint("TOP", iconTriangle, "BOTTOM",0,-5)
		iconSquare:SetPoint("TOP", iconMoon, "BOTTOM",0,-5)
		iconCross:SetPoint("TOP", iconSquare, "BOTTOM",0,-5)
		iconSkull:SetPoint("TOP", iconCross, "BOTTOM",0,-5)
		lockIcon:SetPoint("TOP", iconSkull , "BOTTOM",0,-5)
		MB_mainFrame:SetSize(35,198)
		iconFrame:SetSize(35,198)
		iconFrame:SetPoint("TOP", MB_mainFrame, "TOP")
		moverLeft:SetSize(35,20)
		moverLeft:SetPoint("BOTTOM", MB_mainFrame, "TOP")
	end
    if MBCtrlDB.vertical then
            -- and stuff for control options vertically
		announceIcon :SetPoint("TOP", MB_controlFrame, "TOP",0,-7)
		readyCheck:SetPoint("TOP", announceIcon , "BOTTOM")
		roleCheck:SetPoint("TOP", readyCheck , "BOTTOM",0,-3)
		optIcon:SetPoint("TOP", roleCheck , "BOTTOM",0,-1)
		if MBDB.ctrlLock then
            MB_controlFrame:ClearAllPoints()
            MB_controlFrame:SetSize(35,100)
            ctrlLockIcon:SetAlpha(0)
            ctrlLockIcon:EnableMouse(false)
            moverRight:SetAlpha(0)
            moverRight:EnableMouse(false)
            MB_controlFrame:SetParent(MB_mainFrame)
            MB_controlFrame:SetPoint("TOP", MB_iconFrame, "BOTTOM",0,5)
        else
            MB_controlFrame:SetSize(35,120)
            ctrlLockIcon:SetAlpha(1)
            ctrlLockIcon:EnableMouse(true)
            MB_controlFrame:SetParent(UIParent)
            ctrlLockIcon:SetPoint("TOP", optIcon , "BOTTOM",0,-1)
            moverRight:SetSize(35,20)
            moverRight:SetPoint("TOP", MB_controlFrame, "BOTTOM")
        end
    else
            -- and stuff for control options horizontally
		announceIcon :SetPoint("LEFT", MB_controlFrame, "LEFT",8,0)
		readyCheck:SetPoint("LEFT", announceIcon , "RIGHT")
		roleCheck:SetPoint("LEFT", readyCheck , "RIGHT")
		optIcon:SetPoint("LEFT", roleCheck , "RIGHT",-1,0)
 		if MBDB.ctrlLock then
            MB_controlFrame:ClearAllPoints()
            MB_controlFrame:SetSize(98,35)
            ctrlLockIcon:SetAlpha(0)
            ctrlLockIcon:EnableMouse(false)
            moverRight:SetAlpha(0)
            moverRight:EnableMouse(false)
            MB_controlFrame:SetPoint("LEFT", MB_iconFrame, "RIGHT",5,0)
        else
            MB_controlFrame:SetSize(118,35)
            ctrlLockIcon:SetAlpha(1)
            ctrlLockIcon:EnableMouse(true)
            ctrlLockIcon:SetPoint("LEFT", optIcon , "RIGHT",2,0)
            moverRight:SetSize(20,35)
            moverRight:SetPoint("LEFT", MB_controlFrame , "RIGHT")
        end
    end
end

function MB_flipChecker()
	if (MBDB.flipped==false) and (MBDB.vertical==false) then
		MB_flip(1)
	elseif (MBDB.flipped==true) and (MBDB.vertical==false) then
		MB_flip(2)
	elseif (MBDB.flipped==false) and (MBDB.vertical==true) then
		MB_flip(3)
	elseif (MBDB.flipped==true) and (MBDB.vertical==true) then
		MB_flip(4)
	end
end

function MB_flareflip(dir)
	flareWhite:ClearAllPoints()
	flareRed:ClearAllPoints()
	flareBlue:ClearAllPoints()
	flareSilver:ClearAllPoints()
	flareGreen:ClearAllPoints()
	flarePurple:ClearAllPoints()
	flareOrange:ClearAllPoints()
	flareYellow:ClearAllPoints()
	flareClear:ClearAllPoints()
	flarelockIcon:ClearAllPoints()
	flareFrame:ClearAllPoints()
	MBFlares_moverLeft:ClearAllPoints()
	if (dir==1) then -- Normal
		flareWhite:SetPoint("TOPLEFT", flareFrame, "TOPLEFT",4,-5)
		flareRed:SetPoint("LEFT", flareWhite, "RIGHT",-5,0)
		flareBlue:SetPoint("LEFT", flareRed, "RIGHT",-5,0)
		flareSilver:SetPoint("LEFT", flareBlue, "RIGHT",-5,0)
		flareGreen:SetPoint("LEFT", flareSilver, "RIGHT",-5,0)
		flarePurple:SetPoint("LEFT", flareGreen, "RIGHT",-5,0)
		flareOrange:SetPoint("LEFT", flarePurple, "RIGHT",-5,0)
		flareYellow:SetPoint("LEFT", flareOrange, "RIGHT",-5,0)
		flareClear:SetPoint("LEFT", flareYellow, "RIGHT",0,0)
		flarelockIcon:SetPoint("LEFT", flareClear, "RIGHT",3,0)
		MBFlares_mainFrame:SetSize(140,35)
		flareFrame:SetSize(215,35) --180
		flareFrame:SetPoint("LEFT", MBFlares_mainFrame, "LEFT")
		MBFlares_moverLeft:SetSize(20,35)
		MBFlares_moverLeft:SetPoint("RIGHT", MBFlares_mainFrame, "LEFT")
	elseif (dir==2) then -- Backwards
		flareYellow:SetPoint("TOPLEFT", flareFrame, "TOPLEFT",4,-5)
		flareOrange:SetPoint("LEFT", flareYellow, "RIGHT",-5,0)
		flarePurple:SetPoint("LEFT", flareOrange, "RIGHT",-5,0)
		flareGreen:SetPoint("LEFT", flarePurple, "RIGHT",-5,0)
		flareSilver:SetPoint("LEFT", flareGreen, "RIGHT",-5,0)
		flareBlue:SetPoint("LEFT", flareSilver, "RIGHT",-5,0)
		flareRed:SetPoint("LEFT", flareBlue, "RIGHT",-5,0)
		flareWhite:SetPoint("LEFT", flareRed, "RIGHT",-5,0)
		flareClear:SetPoint("LEFT", flareWhite, "RIGHT",0,0)
		flarelockIcon:SetPoint("LEFT", flareClear, "RIGHT",3,0)
		MBFlares_mainFrame:SetSize(140,35)
		flareFrame:SetSize(215,35) --180
		flareFrame:SetPoint("LEFT", MBFlares_mainFrame, "LEFT")
		MBFlares_moverLeft:SetSize(20,35)
		MBFlares_moverLeft:SetPoint("RIGHT", MBFlares_mainFrame, "LEFT")
	elseif (dir==3) then -- Normal vertical
		flareWhite:SetPoint("TOPLEFT", flareFrame, "TOPLEFT",4,-5)
		flareRed:SetPoint("TOP", flareWhite, "BOTTOM",0,5)
		flareBlue:SetPoint("TOP", flareRed, "BOTTOM",0,5)
		flareSilver:SetPoint("TOP", flareBlue, "BOTTOM",0,5)
		flareGreen:SetPoint("TOP", flareSilver, "BOTTOM",0,5)
		flarePurple:SetPoint("TOP", flareGreen, "BOTTOM",0,5)
		flareOrange:SetPoint("TOP", flarePurple, "BOTTOM",0,5)
		flareYellow:SetPoint("TOP", flareOrange, "BOTTOM",0,5)
		flareClear:SetPoint("TOP", flareYellow, "BOTTOM",1,1)
		flarelockIcon:SetPoint("TOP", flareClear, "BOTTOM",-1,-3)
		MBFlares_mainFrame:SetSize(35,140)
		flareFrame:SetSize(35,215) --180
		flareFrame:SetPoint("TOP", MBFlares_mainFrame, "TOP")
		MBFlares_moverLeft:SetSize(35,20)
		MBFlares_moverLeft:SetPoint("BOTTOM", MBFlares_mainFrame, "TOP")
	elseif (dir==4) then -- Backwards vertical
		flareYellow:SetPoint("TOPLEFT", flareFrame, "TOPLEFT",4,-5)
		flareOrange:SetPoint("TOP", flareYellow, "BOTTOM",0,5)
		flarePurple:SetPoint("TOP", flareOrange, "BOTTOM",0,5)
		flareGreen:SetPoint("TOP", flarePurple, "BOTTOM",0,5)
		flareSilver:SetPoint("TOP", flareGreen, "BOTTOM",0,5)
		flareBlue:SetPoint("TOP", flareSilver, "BOTTOM",0,5)
		flareRed:SetPoint("TOP", flareBlue, "BOTTOM",0,5)
		flareWhite:SetPoint("TOP", flareRed, "BOTTOM",0,5)
		flareClear:SetPoint("TOP", flareWhite, "BOTTOM",1,1)
		flarelockIcon:SetPoint("TOP", flareClear, "BOTTOM",-1,-3)
		MBFlares_mainFrame:SetSize(35,140)
		flareFrame:SetSize(35,215) --180
		flareFrame:SetPoint("TOP", MBFlares_mainFrame, "TOP")
		MBFlares_moverLeft:SetSize(35,20)
		MBFlares_moverLeft:SetPoint("BOTTOM", MBFlares_mainFrame, "TOP")
	end
end

function MB_flareflipChecker()
	if (not MBFlaresDB.flipped) and ( not MBFlaresDB.vertical) then
		MB_flareflip(1)
	elseif (MBFlaresDB.flipped) and ( not MBFlaresDB.vertical) then
		MB_flareflip(2)
	elseif (not MBFlaresDB.flipped) and (MBFlaresDB.vertical) then
		MB_flareflip(3)
	elseif (MBFlaresDB.flipped) and (MBFlaresDB.vertical) then
		MB_flareflip(4)
	end
end

function MB_bgToggle(DB)
    if ( DB == "main" ) then
    	if ( MBDB.bgHide ) then MBDB.bgHide = false; MB_bgShow("main") else	MBDB.bgHide = true; MB_bgHide("main") end
    elseif ( DB == "ctrl" ) then
    	if ( MBCtrlDB.bgHide ) then MBCtrlDB.bgHide = false; MB_bgShow("ctrl") else	MBCtrlDB.bgHide = true; MB_bgHide("ctrl") end
    elseif ( DB == "flare" ) then
    	if ( MBFlaresDB.bgHide ) then MBFlaresDB.bgHide = false; MB_bgShow("flare") else MBFlaresDB.bgHide = true; MB_bgHide("flare") end
    end
end

function MB_bgHide(DB)
    if ( DB == "main" ) then
        iconFrame:SetBackdropColor(0,0,0,0)
        iconFrame:SetBackdropBorderColor(0,0,0,0)
    elseif ( DB == "ctrl" ) then
        MB_controlFrame:SetBackdropColor(0,0,0,0)
        MB_controlFrame:SetBackdropBorderColor(0,0,0,0)
    elseif ( DB == "flare" ) then
        flareFrame:SetBackdropColor(0,0,0,0)
        flareFrame:SetBackdropBorderColor(0,0,0,0)
    end
end

function MB_bgShow(DB)
    if ( DB == "main" ) then
        iconFrame:SetBackdropColor(0.1,0.1,0.1,0.7)
        iconFrame:SetBackdropBorderColor(1,1,1,1)
    elseif ( DB == "ctrl" ) then
        MB_controlFrame:SetBackdropColor(0.1,0.1,0.1,0.7)
        MB_controlFrame:SetBackdropBorderColor(1,1,1,1)
    elseif ( DB == "flare" ) then
        flareFrame:SetBackdropColor(0.1,0.1,0.1,0.7)
        flareFrame:SetBackdropBorderColor(1,1,1,1)
    end
end

function MB_scale(self,DB)
	if self == nil then return end
    if ( DB == "main" ) then
    	MBDB.scale = (self:GetValue());
        getglobal(self:GetName().."Text"):SetText(MB .." scale: "..math.floor((MBDB.scale*100)).."%")
        MB_mainFrame:SetScale(MBDB.scale);
    elseif ( DB == "ctrl" ) then
    	MBCtrlDB.scale = (self:GetValue());
        getglobal(self:GetName().."Text"):SetText(MB .." controls scale: "..math.floor((MBCtrlDB.scale*100)).."%")
        MB_controlFrame:SetScale(MBCtrlDB.scale);
    elseif ( DB == "flare" ) then
    	MBFlaresDB.scale = (self:GetValue());
        getglobal(self:GetName().."Text"):SetText(MBF .." scale: "..math.floor((MBFlaresDB.scale*100)).."%")
        MBFlares_mainFrame:SetScale(MBFlaresDB.scale);
    end
end

function MB_alpha(self,DB)
	if self == nil then return end
    if ( DB == "main" ) then
        MBDB.alpha = (self:GetValue());
        getglobal(self:GetName().."Text"):SetText(MB .." opacity: "..math.floor((MBDB.alpha*100)).."%")
        MB_mainFrame:SetAlpha(MBDB.alpha);
    elseif ( DB == "ctrl" ) then
        MBCtrlDB.alpha = (self:GetValue());
        getglobal(self:GetName().."Text"):SetText(MB .." controls opacity: "..math.floor((MBCtrlDB.alpha*100)).."%")
        MB_controlFrame:SetAlpha(MBCtrlDB.alpha);
    elseif ( DB == "flare" ) then
        MBFlaresDB.alpha = (self:GetValue());
        getglobal(self:GetName().."Text"):SetText(MBF .." opacity: "..math.floor((MBFlaresDB.alpha*100)).."%")
        MBFlares_mainFrame:SetAlpha(MBFlaresDB.alpha);
    end
end

function MB_checkUpdater()
	showCheck:SetChecked(MBDB.shown)
    aloneCheck:SetChecked(MBDB.aloneShow)
	partyCheck:SetChecked(MBDB.partyShow)
    raidCheck:SetChecked(MBDB.raidShow)
	lockCheck:SetChecked(MBDB.locked)
    ctrlCheck:SetChecked(MBDB.ctrlLock)
	clampCheck:SetChecked(MBDB.clamped)
	flipCheck:SetChecked(MBDB.flipped)
	vertCheck:SetChecked(MBDB.vertical)
	bgCheck:SetChecked(MBDB.bgHide)
	toolCheck:SetChecked(MBDB.tooltips)
	getglobal(scaleSlider:GetName().."Low"):SetText("50%")
	getglobal(scaleSlider:GetName().."High"):SetText("150%")
	getglobal(scaleSlider:GetName().."Text"):SetText(MB .." scale: "..math.floor((MBDB.scale*100)).."%")
	scaleSlider:SetValue(MBDB.scale)
	getglobal(alphaSlider:GetName().."Low"):SetText("0%")
	getglobal(alphaSlider:GetName().."High"):SetText("100%")
	getglobal(alphaSlider:GetName().."Text"):SetText(MB .." opacity: "..math.floor((MBDB.alpha*100)).."%")
	alphaSlider:SetValue(MBDB.alpha)

    ctrlShowCheck:SetChecked(MBCtrlDB.shown)
    ctrlAloneCheck:SetChecked(MBCtrlDB.aloneShow)
	ctrlPartyCheck:SetChecked(MBCtrlDB.partyShow)
    ctrlRaidCheck:SetChecked(MBCtrlDB.raidShow)
	ctrlLockCheck:SetChecked(MBCtrlDB.locked)
	ctrlClampCheck:SetChecked(MBCtrlDB.clamped)
	ctrlVertCheck:SetChecked(MBCtrlDB.vertical)
	ctrlBgCheck:SetChecked(MBCtrlDB.bgHide)
	ctrlToolCheck:SetChecked(MBCtrlDB.tooltips)
	getglobal(ctrlScaleSlider:GetName().."Low"):SetText("50%")
	getglobal(ctrlScaleSlider:GetName().."High"):SetText("150%")
	getglobal(ctrlScaleSlider:GetName().."Text"):SetText(MB .." scale: "..math.floor((MBCtrlDB.scale*100)).."%")
	ctrlScaleSlider:SetValue(MBCtrlDB.scale)
	getglobal(ctrlAlphaSlider:GetName().."Low"):SetText("0%")
	getglobal(ctrlAlphaSlider:GetName().."High"):SetText("100%")
	getglobal(ctrlAlphaSlider:GetName().."Text"):SetText(MB .." opacity: "..math.floor((MBCtrlDB.alpha*100)).."%")
	ctrlAlphaSlider:SetValue(MBCtrlDB.alpha)

	flareShowCheck:SetChecked(MBFlaresDB.shown)
    flareAloneCheck:SetChecked(MBFlaresDB.aloneShow)
	flarePartyCheck:SetChecked(MBFlaresDB.partyShow)
    flareRaidCheck:SetChecked(MBFlaresDB.raidShow)
	flareLockCheck:SetChecked(MBFlaresDB.locked)
	flareClampCheck:SetChecked(MBFlaresDB.clamped)
	flareflipCheck:SetChecked(MBFlaresDB.flipped)
	flarevertCheck:SetChecked(MBFlaresDB.vertical)
	flareBgCheck:SetChecked(MBFlaresDB.bgHide)
	flareToolCheck:SetChecked(MBFlaresDB.tooltips)
	getglobal(flareScaleSlider:GetName().."Low"):SetText("50%")
	getglobal(flareScaleSlider:GetName().."High"):SetText("150%")
	getglobal(flareScaleSlider:GetName().."Text"):SetText(MBF .. " scale: "..math.floor((MBFlaresDB.scale*100)).."%")
	flareScaleSlider:SetValue(MBFlaresDB.scale)
	getglobal(flareAlphaSlider:GetName().."Low"):SetText("0%")
	getglobal(flareAlphaSlider:GetName().."High"):SetText("100%")
	getglobal(flareAlphaSlider:GetName().."Text"):SetText(MBF .. " opacity: "..math.floor((MBFlaresDB.alpha*100)).."%")
	flareAlphaSlider:SetValue(MBFlaresDB.alpha)

    MB_Update_Announce()
end
function MB_Update_Announce()
	AnnounceIntroCheck:SetChecked(MBDB.announce_intro)
	AnnounceIntroMsg:SetText(MBDB.msg_intro)
    AnnounceIntroMsg:SetCursorPosition(0)
	AnnounceskullCheck:SetChecked(MBDB.announce_skull)
	AnnounceskullMsg:SetText(MBDB.msg_skull)
    AnnounceskullMsg:SetCursorPosition(0)
	AnnouncecrossCheck:SetChecked(MBDB.announce_cross)
	AnnouncecrossMsg:SetText(MBDB.msg_cross)
    AnnouncecrossMsg:SetCursorPosition(0)
	AnnouncesquareCheck:SetChecked(MBDB.announce_square)
	AnnouncesquareMsg:SetText(MBDB.msg_square)
	AnnouncesquareMsg:SetCursorPosition(0)
    AnnouncemoonCheck:SetChecked(MBDB.announce_moon)
	AnnouncemoonMsg:SetText(MBDB.msg_moon)
	AnnouncemoonMsg:SetCursorPosition(0)
    AnnouncetriangleCheck:SetChecked(MBDB.announce_triangle)
	AnnouncetriangleMsg:SetText(MBDB.msg_triangle)
	AnnouncetriangleMsg:SetCursorPosition(0)
    AnnouncediamondCheck:SetChecked(MBDB.announce_diamond)
	AnnouncediamondMsg:SetText(MBDB.msg_diamond)
	AnnouncediamondMsg:SetCursorPosition(0)
    AnnouncecircleCheck:SetChecked(MBDB.announce_circle)
	AnnouncecircleMsg:SetText(MBDB.msg_circle)
	AnnouncecircleMsg:SetCursorPosition(0)
    AnnouncestarCheck:SetChecked(MBDB.announce_star)
	AnnouncestarMsg:SetText(MBDB.msg_star)
    AnnouncestarMsg:SetCursorPosition(0)
    AnnouncefooterCheck:SetChecked(MBDB.announce_footer)
	AnnouncefooterMsg:SetText(MBDB.msg_footer)
    AnnouncefooterMsg:SetCursorPosition(0)
    AnnouncerwCheck:SetChecked(MBFlaresDB.announce_rw)
    AnnouncerwMsg:SetText(MBFlaresDB.msg_rw)
    AnnouncerwMsg:SetCursorPosition(0)
    AnnouncetooltipCheck:SetChecked(MBDB.announce_tooltip)
end

function MB_Announce_Save()
	MBDB.msg_intro = AnnounceIntroMsg:GetText()
	MBDB.msg_skull = AnnounceskullMsg:GetText()
	MBDB.msg_cross = AnnouncecrossMsg:GetText()
	MBDB.msg_square = AnnouncesquareMsg:GetText()
	MBDB.msg_moon = AnnouncemoonMsg:GetText()
	MBDB.msg_triangle = AnnouncetriangleMsg:GetText()
	MBDB.msg_diamond = AnnouncediamondMsg:GetText()
	MBDB.msg_circle = AnnouncecircleMsg:GetText()
	MBDB.msg_star = AnnouncestarMsg:GetText()
    MBDB.msg_footer = AnnouncefooterMsg:GetText()
    MBFlaresDB.msg_rw = AnnouncerwMsg:GetText()
end

-------------------------------------------------------
-- Slash Commands
-------------------------------------------------------

SLASH_MB1 = '/MBL'
SLASH_MB2 = '/MBLF'
SLASH_MB3 = "/MARKINGBARLIVES"
SLASH_MB4 = "/MBLFLARES"
SLASH_MB5 = "/MARKINGBARLIVESFLARES"
function SlashCmdList.MB(msg, editbox)
	local chan
	if (msg=="reset") then
		MB_reset()
    elseif (msg=="options") then
		Settings.OpenToCategory(MarkingBarOptSettingsCategoryId)
	else
		DEFAULT_CHAT_FRAME:AddMessage(MB..": v"..versionNum.." Author: "..GetAddOnMetadata("MarkingBarLives", "Author"))
		DEFAULT_CHAT_FRAME:AddMessage("use /mbl options to open configuration screen")
	end
end

----------------
-- Main Options Page
----------------
MarkingBarOpt = {};				   
local MarkingBarOpt = CreateFrame( "Frame", "MarkingBarOpt", InterfaceOptionsFramePanelContainer );
MarkingBarOpt.name = "Marking Bar Lives";
MarkingBarOpt.okay = function(self) MB_Announce_Save(); end
MarkingBarOpt.cancel = function(self) MB_Announce_Save(); end
MarkingBarOpt.default = function(self) MB_reset(); MB_checkUpdater(); end
MarkingBarOpt.refresh = function(self) MB_checkUpdater(); MB_Announce_Save(); end
local category, layout = Settings.RegisterCanvasLayoutCategory(MarkingBarOpt, MarkingBarOpt.name);
Settings.RegisterAddOnCategory(category);
MarkingBarOptSettingsCategoryId = category:GetID();

local MBOptionsText = MarkingBarOpt:CreateFontString("MBOptionsText", "OVERLAY", "ChatFontNormal")
MBOptionsText:SetPoint("TOP", MarkingBarOpt, "TOP",0,-10)
MBOptionsText:SetText(MB.."|cffe1a500 Options")
local OptionsText = MarkingBarOpt:CreateFontString("OptionsText", "OVERLAY", "ChatFontSmall")
OptionsText:SetPoint("TOPLEFT", MarkingBarOpt, "TOPLEFT",25,-30)
OptionsText:SetText("Expand the MarkingBarLives (+) on the left to see the options.")

local versFooter = CreateFrame("Frame", "versFooter", MarkingBarOpt, BackdropTemplateMixin and "BackdropTemplate")
versFooter:SetBackdrop(defaultBackdrop)
versFooter:SetBackdropColor(0.1,0.1,0.1,0.9)
versFooter:SetBackdropBorderColor(1,1,1,0.5)
versFooter:SetPoint("BOTTOM", MarkingBarOpt, "BOTTOM",0,5)
versFooter:SetSize(175,23)

local versionText = versFooter:CreateFontString("versionText", "OVERLAY", "ChatFontSmall")
versionText:SetPoint("TOP", versFooter, "TOP",0,-5)
versionText:SetText(MB..curVer)

local ResetMsgButton = CreateFrame("Button", "markerResetMsgButton", MarkingBarOpt, "UIPanelButtonTemplate") --Was OptionsButtonTemplate until patch 10.0.0
ResetMsgButton:SetPoint("BOTTOMRIGHT", MarkingBarOpt, "BOTTOMRIGHT",-5,5)
ResetMsgButton:SetScript("OnClick", function(self) MB_reset_msg(); MB_checkUpdater(); end)
ResetMsgButton:SetSize(200,20)
ResetMsgButton:SetText("Reset to Default Settings")

----------------
-- Marker Options Page
----------------
local MarkerOptPg = CreateFrame( "Frame", "optionsMarker");
MarkerOptPg.name = "Markers";
MarkerOptPg.parent = MarkingBarOpt.name;
MarkerOptPg.okay = function(self) MB_Announce_Save(); end
MarkerOptPg.cancel = function(self) MB_Announce_Save(); end
MarkerOptPg.default = function(self) MB_reset(); MB_checkUpdater(); end
MarkerOptPg.refresh = function(self) MB_checkUpdater(); MB_Announce_Save(); end
local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(category, MarkerOptPg, MarkerOptPg.name);
Settings.RegisterAddOnCategory(subcategory);
MarkerOptPgCategoryId = subcategory:GetID();

local markerOptionsText = MarkerOptPg:CreateFontString("markerOptionsText", "OVERLAY", "ChatFontNormal")
markerOptionsText:SetPoint("TOP", MarkerOptPg, "TOP",0,-10)
markerOptionsText:SetText(MB.."|cffe1a500 Options")

local showCheck = CreateFrame("CheckButton", "showCheck", MarkerOptPg, "UICheckButtonTemplate")
showCheck:SetPoint("TOPLEFT", MarkerOptPg, "TOPLEFT",25,-30)
showCheck:SetSize(20,20)
showCheck:SetScript("OnClick", function(self) MBDB.shown = not MBDB.shown; MB_targetChecker("main") end)
local showText = MarkerOptPg:CreateFontString("showText", "OVERLAY", "ChatFontSmall")
showText:SetPoint("LEFT", showCheck, "RIGHT", 5,0)
showText:SetText("Always show "..MB.." with or without a target")

local partyRaidText = MarkerOptPg:CreateFontString("partyRaidText", "OVERLAY", "ChatFontSmall")
partyRaidText:SetPoint("TOPLEFT", showCheck,"BOTTOMLEFT",0,-5)
partyRaidText:SetText("Show "..MB.." when...")

local aloneCheck = CreateFrame("CheckButton", "aloneCheck", MarkerOptPg, "UICheckButtonTemplate")
aloneCheck:SetPoint("TOPLEFT", partyRaidText,"BOTTOMLEFT",0,-2)
aloneCheck:SetSize(20,20)
aloneCheck:SetScript("OnClick", function(self) MBDB.aloneShow = not MBDB.aloneShow; MB_targetChecker("main") end)
local aloneText = MarkerOptPg:CreateFontString("aloneText", "OVERLAY", "ChatFontSmall")
aloneText:SetPoint("LEFT", aloneCheck, "RIGHT", 5,0)
aloneText:SetText(" Alone")

local partyCheck = CreateFrame("CheckButton", "partyCheck", MarkerOptPg, "UICheckButtonTemplate")
partyCheck:SetPoint("LEFT", aloneText, "RIGHT",20,0)
partyCheck:SetSize(20,20)
partyCheck:SetScript("OnClick", function(self) MBDB.partyShow = not MBDB.partyShow; MB_targetChecker("main") end)
local partyText = MarkerOptPg:CreateFontString("partyText", "OVERLAY", "ChatFontSmall")
partyText:SetPoint("LEFT", partyCheck, "RIGHT", 5,0)
partyText:SetText(" in a Party ")

local raidCheck = CreateFrame("CheckButton", "raidCheck", MarkerOptPg, "UICheckButtonTemplate")
raidCheck:SetPoint("LEFT", partyText, "RIGHT",20,0)
raidCheck:SetSize(20,20)
raidCheck:SetScript("OnClick", function(self) MBDB.raidShow = not MBDB.raidShow; MB_targetChecker("main") end)
local raidText = MarkerOptPg:CreateFontString("raidText", "OVERLAY", "ChatFontSmall")
raidText:SetPoint("LEFT", raidCheck, "RIGHT", 5,0)
raidText:SetText(" in a Raid ")

local lockCheck = CreateFrame("CheckButton", "lockCheck", MarkerOptPg, "UICheckButtonTemplate")
lockCheck:SetPoint("TOP",aloneCheck,"BOTTOM",0,-5)
lockCheck:SetSize(20,20)
lockCheck:SetScript("OnClick", function(self) MB_lockToggle("main") MB_checkUpdater() end)
local lockText = MarkerOptPg:CreateFontString("lockText", "OVERLAY", "ChatFontSmall")
lockText:SetPoint("LEFT", lockCheck, "RIGHT", 5,0)
lockText:SetText("Lock "..MB.."'s position")

local clampCheck = CreateFrame("CheckButton", "clampCheck", MarkerOptPg, "UICheckButtonTemplate")
clampCheck:SetPoint("TOP",lockCheck,"BOTTOM",0,-5)
clampCheck:SetSize(20,20)
clampCheck:SetScript("OnClick", function(self) MBDB.clamped = not MBDB.clamped; MB_mainFrame:SetClampedToScreen(MBDB.clamped) end)
local clampText = MarkerOptPg:CreateFontString("clampText", "OVERLAY", "ChatFontSmall")
clampText:SetPoint("LEFT", clampCheck, "RIGHT", 5,0)
clampText:SetText("Keep "..MB.." inside screen edges")

local flipCheck = CreateFrame("CheckButton", "flipCheck", MarkerOptPg, "UICheckButtonTemplate")
flipCheck:SetPoint("TOP",clampCheck,"BOTTOM",0,-5)
flipCheck:SetSize(20,20)
flipCheck:SetScript("OnClick", function(self) MBDB.flipped = not MBDB.flipped; MB_flipChecker() end)
local flipText = MarkerOptPg:CreateFontString("flipText", "OVERLAY", "ChatFontSmall")
flipText:SetPoint("LEFT", flipCheck, "RIGHT", 5,0)
flipText:SetText("Reverse "..MB.."'s icon order")

local vertCheck = CreateFrame("CheckButton", "vertCheck", MarkerOptPg, "UICheckButtonTemplate")
vertCheck:SetPoint("TOP",flipCheck,"BOTTOM",0,-5)
vertCheck:SetSize(20,20)
vertCheck:SetScript("OnClick", function(self) MBDB.vertical = not MBDB.vertical; MB_flipChecker() end)
local vertText = MarkerOptPg:CreateFontString("vertText", "OVERLAY", "ChatFontSmall")
vertText:SetPoint("LEFT", vertCheck, "RIGHT", 5,0)
vertText:SetText("Display "..MB.." vertically")

local bgCheck = CreateFrame("CheckButton", "bgCheck", MarkerOptPg, "UICheckButtonTemplate")
bgCheck:SetPoint("TOP",vertCheck,"BOTTOM",0,-5)
bgCheck:SetSize(20,20)
bgCheck:SetScript("OnClick", function(self) MB_bgToggle("main") end)
local bgText = MarkerOptPg:CreateFontString("bgText", "OVERLAY", "ChatFontSmall")
bgText:SetPoint("LEFT", bgCheck, "RIGHT", 5,0)
bgText:SetText("Hide "..MB.."'s background and border")

local toolCheck = CreateFrame("CheckButton", "toolCheck", MarkerOptPg, "UICheckButtonTemplate")
toolCheck:SetPoint("TOP",bgCheck,"BOTTOM",0,-5)
toolCheck:SetSize(20,20)
toolCheck:SetScript("OnClick", function(self) MBDB.tooltips = not MBDB.tooltips end)
local toolText = MarkerOptPg:CreateFontString("toolText", "OVERLAY", "ChatFontSmall")
toolText:SetPoint("LEFT", toolCheck, "RIGHT", 5,0)
toolText:SetText("Enable "..MB.."'s tooltips")

local alphaSlider = CreateFrame("Slider", "alphaSlider", MarkerOptPg, "OptionsSliderTemplate")
alphaSlider:SetPoint("TOPLEFT", toolCheck, "BOTTOMLEFT",25,-25)
alphaSlider:SetSize(180,16)
alphaSlider:SetMinMaxValues(0,1)
alphaSlider:SetValue(1)
alphaSlider:SetValueStep(0.01)
alphaSlider:SetOrientation("HORIZONTAL")
alphaSlider:SetScript("OnValueChanged", function(self) MB_alpha(self,"main") end)
alphaSlider:SetScript("OnLoad", function(self) MB_alpha(self,"main") end)

local scaleSlider = CreateFrame("Slider", "scaleSlider", MarkerOptPg, "OptionsSliderTemplate")
scaleSlider:SetPoint("TOPLEFT", alphaSlider, "BOTTOMLEFT",0,-25)
scaleSlider:SetSize(180,16)
scaleSlider:SetMinMaxValues(0.5,1.5)
scaleSlider:SetValue(1)
scaleSlider:SetValueStep(0.01)
scaleSlider:SetOrientation("HORIZONTAL")
scaleSlider:SetScript("OnValueChanged", function(self) MB_scale(self,"main") end)
scaleSlider:SetScript("OnLoad", function(self) MB_scale(self,"main") end)

local markerResetMsgButton = CreateFrame("Button", "markerResetMsgButton", MarkerOptPg, "UIPanelButtonTemplate") --Was OptionsButtonTemplate until patch 10.0.0
markerResetMsgButton:SetPoint("BOTTOMRIGHT", MarkerOptPg, "BOTTOMRIGHT",-5,5)
markerResetMsgButton:SetScript("OnClick", function(self) MB_reset_msg(); MB_checkUpdater(); end)
markerResetMsgButton:SetSize(200,20)
markerResetMsgButton:SetText("Reset to Default Settings")

----------------
-- Control Options Page
----------------
local ControlOptPg = CreateFrame( "Frame", "optionsControl", MarkingBarOpt);
ControlOptPg.name = "Controls";
ControlOptPg.parent = MarkingBarOpt.name;
ControlOptPg.okay = function(self) MB_Announce_Save(); end
ControlOptPg.cancel = function(self) MB_Announce_Save(); end
ControlOptPg.default = function(self) MB_reset(); MB_checkUpdater(); end
ControlOptPg.refresh = function(self) MB_checkUpdater(); MB_Announce_Save(); end
local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(category, ControlOptPg, ControlOptPg.name);
Settings.RegisterAddOnCategory(subcategory);
ControlOptPgCategoryId = subcategory:GetID();

local ctrlOptionsText = ControlOptPg:CreateFontString("ctrlOptionsText", "OVERLAY", "ChatFontNormal")
ctrlOptionsText:SetPoint("TOP", ControlOptPg, "TOP",0,-10)
ctrlOptionsText:SetText(MB.."|cffe1a500 Control Options")

local ctrlShowCheck = CreateFrame("CheckButton", "ctrlShowCheck", ControlOptPg, "UICheckButtonTemplate")
ctrlShowCheck:SetPoint("TOPLEFT", ControlOptPg, "TOPLEFT",25,-30)
ctrlShowCheck:SetSize(20,20)
ctrlShowCheck:SetScript("OnClick", function(self) MBCtrlDB.shown = not MBCtrlDB.shown; MB_targetChecker("ctrl") end)
ControlOptPg:CreateFontString("ctrlShowText", "OVERLAY", "ChatFontSmall")
ctrlShowText:SetPoint("LEFT", ctrlShowCheck, "RIGHT", 5,0)
ctrlShowText:SetText("Always show "..MB.." controls  with or without a target")

local ctrlPartyRaidText = ControlOptPg:CreateFontString("ctrlPartyRaidText", "OVERLAY", "ChatFontSmall")
ctrlPartyRaidText:SetPoint("TOPLEFT", ctrlShowCheck,"BOTTOMLEFT",0,-5)
ctrlPartyRaidText:SetText("Show "..MB.." controls  when...")

local ctrlAloneCheck = CreateFrame("CheckButton", "ctrlAloneCheck", ControlOptPg, "UICheckButtonTemplate")
ctrlAloneCheck:SetPoint("TOPLEFT", ctrlPartyRaidText,"BOTTOMLEFT",0,-2)
ctrlAloneCheck:SetSize(20,20)
ctrlAloneCheck:SetScript("OnClick", function(self) MBCtrlDB.aloneShow = not MBCtrlDB.aloneShow; MB_targetChecker("ctrl") end)
local ctrlAloneText = ControlOptPg:CreateFontString("ctrlAloneText", "OVERLAY", "ChatFontSmall")
ctrlAloneText:SetPoint("LEFT", ctrlAloneCheck, "RIGHT", 5,0)
ctrlAloneText:SetText(" Alone")

local ctrlPartyCheck = CreateFrame("CheckButton", "ctrlPartyCheck", ControlOptPg, "UICheckButtonTemplate")
ctrlPartyCheck:SetPoint("LEFT", ctrlAloneText, "RIGHT",20,0)
ctrlPartyCheck:SetSize(20,20)
ctrlPartyCheck:SetScript("OnClick", function(self) MBCtrlDB.partyShow = not MBCtrlDB.partyShow; MB_targetChecker("ctrl") end)
local ctrlPartyText = ControlOptPg:CreateFontString("ctrlPartyText", "OVERLAY", "ChatFontSmall")
ctrlPartyText:SetPoint("LEFT", ctrlPartyCheck, "RIGHT", 5,0)
ctrlPartyText:SetText(" in a Party ")

local ctrlRaidCheck = CreateFrame("CheckButton", "ctrlRaidCheck", ControlOptPg, "UICheckButtonTemplate")
ctrlRaidCheck:SetPoint("LEFT", ctrlPartyText, "RIGHT",20,0)
ctrlRaidCheck:SetSize(20,20)
ctrlRaidCheck:SetScript("OnClick", function(self) MBCtrlDB.raidShow = not MBCtrlDB.raidShow; MB_targetChecker("ctrl") end)
local ctrlRaidText = ControlOptPg:CreateFontString("ctrlRaidText", "OVERLAY", "ChatFontSmall")
ctrlRaidText:SetPoint("LEFT", ctrlRaidCheck, "RIGHT", 5,0)
ctrlRaidText:SetText(" in a Raid ")

local ctrlCheck = CreateFrame("CheckButton", "ctrlCheck", ControlOptPg, "UICheckButtonTemplate")
ctrlCheck:SetPoint("TOP",ctrlAloneCheck,"BOTTOM",0,-5)
ctrlCheck:SetSize(20,20)
ctrlCheck:SetScript("OnClick", function(self) MB_ctrlLockToggle(); MB_checkUpdater(); end)
local ctrlText = ControlOptPg:CreateFontString("ctrlText", "OVERLAY", "ChatFontSmall")
ctrlText:SetPoint("LEFT", ctrlCheck, "RIGHT", 5,0)
ctrlText:SetText("Connect "..MB.."'s controls to the raid icons.")

local ctrlLockCheck = CreateFrame("CheckButton", "ctrlLockCheck", ControlOptPg, "UICheckButtonTemplate")
ctrlLockCheck:SetPoint("TOP",ctrlCheck, "BOTTOM",0,-5)
ctrlLockCheck:SetSize(20,20)
ctrlLockCheck:SetScript("OnClick", function(self) MB_lockToggle("ctrl"); MB_checkUpdater(); end)
ctrlLockCheck:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); GameTooltip:AddLine("Note: Changing this options will disconnect controls from the raid icons.",0.88,0.65,0); GameTooltip:Show() end)
ctrlLockCheck:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
local ctrlLockText = ControlOptPg:CreateFontString("ctrlLockText", "OVERLAY", "ChatFontSmall")
ctrlLockText:SetPoint("LEFT", ctrlLockCheck, "RIGHT", 5,0)
ctrlLockText:SetText("Lock "..MB.." control's position.")

local ctrlClampCheck = CreateFrame("CheckButton", "ctrlClampCheck", ControlOptPg, "UICheckButtonTemplate")
ctrlClampCheck:SetPoint("TOP",ctrlLockCheck,"BOTTOM",0,-5)
ctrlClampCheck:SetSize(20,20)
ctrlClampCheck:SetScript("OnClick", function(self) MBCtrlDB.clamped = not MBCtrlDB.clamped; MB_controlFrame:SetClampedToScreen(MBCtrlDB.clamped) end)
local ctrlClampText = ControlOptPg:CreateFontString("ctrlClampText", "OVERLAY", "ChatFontSmall")
ctrlClampText:SetPoint("LEFT", ctrlClampCheck, "RIGHT", 5,0)
ctrlClampText:SetText("Keep "..MB.." controls  inside screen edges")

local ctrlVertCheck = CreateFrame("CheckButton", "ctrlVertCheck", ControlOptPg, "UICheckButtonTemplate")
ctrlVertCheck:SetPoint("TOP",ctrlClampCheck,"BOTTOM",0,-5)
ctrlVertCheck:SetSize(20,20)
ctrlVertCheck:SetScript("OnClick", function(self) MBCtrlDB.vertical = not MBCtrlDB.vertical; if MBDB.ctrlLock then MB_ctrlUnlock() end; MB_flipChecker(); MB_checkUpdater() end)
ctrlVertCheck:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); GameTooltip:AddLine("Note: Changing this options will disconnect controls from the raid icons.",0.88,0.65,0); GameTooltip:Show() end)
ctrlVertCheck:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
local ctrlVertText = ControlOptPg:CreateFontString("ctrlvertText", "OVERLAY", "ChatFontSmall")
ctrlVertText:SetPoint("LEFT", ctrlVertCheck, "RIGHT", 5,0)
ctrlVertText:SetText("Display "..MB.." controls  vertically")

local ctrlBgCheck = CreateFrame("CheckButton", "ctrlBgCheck", ControlOptPg, "UICheckButtonTemplate")
ctrlBgCheck:SetPoint("TOP",ctrlVertCheck,"BOTTOM",0,-5)
ctrlBgCheck:SetSize(20,20)
ctrlBgCheck:SetScript("OnClick", function(self) MB_bgToggle("ctrl") end)
local ctrlBgText = ControlOptPg:CreateFontString("ctrlBgText", "OVERLAY", "ChatFontSmall")
ctrlBgText:SetPoint("LEFT", ctrlBgCheck, "RIGHT", 5,0)
ctrlBgText:SetText("Hide "..MB.." controls 's background and borders")

local ctrlToolCheck = CreateFrame("CheckButton", "ctrlToolCheck", ControlOptPg, "UICheckButtonTemplate")
ctrlToolCheck:SetPoint("TOP",ctrlBgCheck,"BOTTOM",0,-5)
ctrlToolCheck:SetSize(20,20)
ctrlToolCheck:SetScript("OnClick", function(self) MBCtrlDB.tooltips = not MBCtrlDB.tooltips; end)
local ctrlToolText = ControlOptPg:CreateFontString("ctrlToolText", "OVERLAY", "ChatFontSmall")
ctrlToolText:SetPoint("LEFT", ctrlToolCheck, "RIGHT", 5,0)
ctrlToolText:SetText("Enable "..MB.." controls 's tooltips")

local ctrlAlphaSlider = CreateFrame("Slider", "ctrlAlphaSlider", ControlOptPg, "OptionsSliderTemplate")
ctrlAlphaSlider:SetPoint("TOPLEFT", ctrlToolCheck, "BOTTOMLEFT",25,-25)
ctrlAlphaSlider:SetSize(180,16)
ctrlAlphaSlider:SetMinMaxValues(0,1)
ctrlAlphaSlider:SetValue(1)
ctrlAlphaSlider:SetValueStep(0.01)
ctrlAlphaSlider:SetOrientation("HORIZONTAL")
ctrlAlphaSlider:SetScript("OnValueChanged", function(self) MB_alpha(self,"ctrl") end)
ctrlAlphaSlider:SetScript("OnLoad", function(self) MB_alpha(self,"ctrl") end)

local ctrlScaleSlider = CreateFrame("Slider", "ctrlScaleSlider", ControlOptPg, "OptionsSliderTemplate")
ctrlScaleSlider:SetPoint("TOPLEFT", ctrlAlphaSlider, "BOTTOMLEFT",0,-25)
ctrlScaleSlider:SetSize(180,16)
ctrlScaleSlider:SetMinMaxValues(0.5,1.5)
ctrlScaleSlider:SetValue(1)
ctrlScaleSlider:SetValueStep(0.01)
ctrlScaleSlider:SetOrientation("HORIZONTAL")
ctrlScaleSlider:SetScript("OnValueChanged", function(self) MB_scale(self,"ctrl") end)
ctrlScaleSlider:SetScript("OnLoad", function(self) MB_scale (self,"ctrl") end)

local ctrlResetMsgButton = CreateFrame("Button", "ctrlResetMsgButton", ControlOptPg, "UIPanelButtonTemplate") --Was OptionsButtonTemplate until patch 10.0.0
ctrlResetMsgButton:SetPoint("BOTTOMRIGHT", ControlOptPg, "BOTTOMRIGHT",-5,5)
ctrlResetMsgButton:SetScript("OnClick", function(self) MB_reset_msg(); MB_checkUpdater(); end)
ctrlResetMsgButton:SetSize(200,20)
ctrlResetMsgButton:SetText("Reset to Default Settings")

----------------
-- Flares Options Page
----------------
local FlaresOptPg = CreateFrame( "Frame", "optionsFlares", MarkingBarOpt);
FlaresOptPg.name = "Flares";
FlaresOptPg.parent = MarkingBarOpt.name;
FlaresOptPg.okay = function(self) MB_Announce_Save(); end
FlaresOptPg.cancel = function(self) MB_Announce_Save(); end
FlaresOptPg.default = function(self) MB_reset(); MB_checkUpdater(); end
FlaresOptPg.refresh = function(self) MB_checkUpdater(); MB_Announce_Save(); end
local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(category, FlaresOptPg, FlaresOptPg.name);
Settings.RegisterAddOnCategory(subcategory);
FlaresOptPgCategoryId = subcategory:GetID();

local flareOptionsText = FlaresOptPg:CreateFontString("flareOptionsText", "OVERLAY", "ChatFontNormal")
flareOptionsText:SetPoint("TOP", FlaresOptPg, "TOP",0,-10)
flareOptionsText:SetText(MBF.."|cffe1a500 Options")

local flareShowCheck = CreateFrame("CheckButton", "flareShowCheck", FlaresOptPg, "UICheckButtonTemplate")
flareShowCheck:SetPoint("TOPLEFT", FlaresOptPg, "TOPLEFT",25,-30)
flareShowCheck:SetSize(20,20)
flareShowCheck:SetScript("OnClick", function(self) MBFlaresDB.shown = not MBFlaresDB.shown; MB_targetChecker("flare") end)
FlaresOptPg:CreateFontString("flareShowText", "OVERLAY", "ChatFontSmall")
flareShowText:SetPoint("LEFT", flareShowCheck, "RIGHT", 5,0)
flareShowText:SetText("Always show "..MBF.." with or without a target")

local flarePartyRaidText = FlaresOptPg:CreateFontString("flarePartyRaidText", "OVERLAY", "ChatFontSmall")
flarePartyRaidText:SetPoint("TOPLEFT", flareShowCheck,"BOTTOMLEFT",0,-5)
flarePartyRaidText:SetText("Show "..MBF.." when...")

local flareAloneCheck = CreateFrame("CheckButton", "flareAloneCheck", FlaresOptPg, "UICheckButtonTemplate")
flareAloneCheck:SetPoint("TOPLEFT", flarePartyRaidText,"BOTTOMLEFT",0,-2)
flareAloneCheck:SetSize(20,20)
flareAloneCheck:SetScript("OnClick", function(self) MBFlaresDB.aloneShow = not MBFlaresDB.aloneShow; MB_targetChecker("flare") end)
local flareAloneText = FlaresOptPg:CreateFontString("flareAloneText", "OVERLAY", "ChatFontSmall")
flareAloneText:SetPoint("LEFT", flareAloneCheck, "RIGHT", 5,0)
flareAloneText:SetText(" Alone")

local flarePartyCheck = CreateFrame("CheckButton", "flarePartyCheck", FlaresOptPg, "UICheckButtonTemplate")
flarePartyCheck:SetPoint("LEFT", flareAloneText, "RIGHT",20,0)
flarePartyCheck:SetSize(20,20)
flarePartyCheck:SetScript("OnClick", function(self) MBFlaresDB.partyShow = not MBFlaresDB.partyShow; MB_targetChecker("flare") end)
local flarePartyText = FlaresOptPg:CreateFontString("flarePartyText", "OVERLAY", "ChatFontSmall")
flarePartyText:SetPoint("LEFT", flarePartyCheck, "RIGHT", 5,0)
flarePartyText:SetText(" in a Party ")

local flareRaidCheck = CreateFrame("CheckButton", "flareRaidCheck", FlaresOptPg, "UICheckButtonTemplate")
flareRaidCheck:SetPoint("LEFT", flarePartyText, "RIGHT",20,0)
flareRaidCheck:SetSize(20,20)
flareRaidCheck:SetScript("OnClick", function(self) MBFlaresDB.raidShow = not MBFlaresDB.raidShow; MB_targetChecker("flare") end)
local flareRaidText = FlaresOptPg:CreateFontString("flareRaidText", "OVERLAY", "ChatFontSmall")
flareRaidText:SetPoint("LEFT", flareRaidCheck, "RIGHT", 5,0)
flareRaidText:SetText(" in a Raid ")

local flareLockCheck = CreateFrame("CheckButton", "flareLockCheck", FlaresOptPg, "UICheckButtonTemplate")
flareLockCheck:SetPoint("TOP",flareAloneCheck, "BOTTOM",0,-5)
flareLockCheck:SetSize(20,20)
flareLockCheck:SetScript("OnClick", function(self) MB_lockToggle("flare") MB_checkUpdater() end)
local flareLockText = FlaresOptPg:CreateFontString("flareLockText", "OVERLAY", "ChatFontSmall")
flareLockText:SetPoint("LEFT", flareLockCheck, "RIGHT", 5,0)
flareLockText:SetText("Lock "..MBF.."'s position")

local flareClampCheck = CreateFrame("CheckButton", "flareClampCheck", FlaresOptPg, "UICheckButtonTemplate")
flareClampCheck:SetPoint("TOP",flareLockCheck,"BOTTOM",0,-5)
flareClampCheck:SetSize(20,20)
flareClampCheck:SetScript("OnClick", function(self) MBFlaresDB.clamped = not MBFlaresDB.clamped; MBFlares_mainFrame:SetClampedToScreen(MBFlaresDB.clamped) end)
local flareClampText = FlaresOptPg:CreateFontString("flareClampText", "OVERLAY", "ChatFontSmall")
flareClampText:SetPoint("LEFT", flareClampCheck, "RIGHT", 5,0)
flareClampText:SetText("Keep "..MBF.." inside screen edges")

local flareFlipCheck = CreateFrame("CheckButton", "flareflipCheck", FlaresOptPg, "UICheckButtonTemplate")
flareFlipCheck:SetPoint("TOP",flareClampCheck,"BOTTOM",0,-5)
flareFlipCheck:SetSize(20,20)
flareFlipCheck:SetScript("OnClick", function(self) MBFlaresDB.flipped = not MBFlaresDB.flipped; MB_flareflipChecker() end)
local flareFlipText = FlaresOptPg:CreateFontString("flareflipText", "OVERLAY", "ChatFontSmall")
flareFlipText:SetPoint("LEFT", flareflipCheck, "RIGHT", 5,0)
flareFlipText:SetText("Reverse "..MBF.."'s icon order")

local flareVertCheck = CreateFrame("CheckButton", "flarevertCheck", FlaresOptPg, "UICheckButtonTemplate")
flareVertCheck:SetPoint("TOP",flareflipCheck,"BOTTOM",0,-5)
flareVertCheck:SetSize(20,20)
flareVertCheck:SetScript("OnClick", function(self) MBFlaresDB.vertical = not MBFlaresDB.vertical; MB_flareflipChecker() end)
local flareVertText = FlaresOptPg:CreateFontString("flarevertText", "OVERLAY", "ChatFontSmall")
flareVertText:SetPoint("LEFT", flarevertCheck, "RIGHT", 5,0)
flareVertText:SetText("Display "..MBF.." vertically")

local flareBgCheck = CreateFrame("CheckButton", "flareBgCheck", FlaresOptPg, "UICheckButtonTemplate")
flareBgCheck:SetPoint("TOP",flarevertCheck,"BOTTOM",0,-5)
flareBgCheck:SetSize(20,20)
flareBgCheck:SetScript("OnClick", function(self) MB_bgToggle("flare") end)
local flareBgText = FlaresOptPg:CreateFontString("flareBgText", "OVERLAY", "ChatFontSmall")
flareBgText:SetPoint("LEFT", flareBgCheck, "RIGHT", 5,0)
flareBgText:SetText("Hide "..MBF.."'s background and borders")

local flareToolCheck = CreateFrame("CheckButton", "flareToolCheck", FlaresOptPg, "UICheckButtonTemplate")
flareToolCheck:SetPoint("TOP",flareBgCheck,"BOTTOM",0,-5)
flareToolCheck:SetSize(20,20)
flareToolCheck:SetScript("OnClick", function(self) MBFlaresDB.tooltips = not MBFlaresDB.tooltips end)
local flareToolText = FlaresOptPg:CreateFontString("flareToolText", "OVERLAY", "ChatFontSmall")
flareToolText:SetPoint("LEFT", flareToolCheck, "RIGHT", 5,0)
flareToolText:SetText("Enable "..MBF.."'s tooltips")

local flareAlphaSlider = CreateFrame("Slider", "flareAlphaSlider", FlaresOptPg, "OptionsSliderTemplate")
flareAlphaSlider:SetPoint("TOPLEFT", flareToolCheck, "BOTTOMLEFT",25,-25)
flareAlphaSlider:SetSize(180,16)
flareAlphaSlider:SetMinMaxValues(0,1)
flareAlphaSlider:SetValue(1)
flareAlphaSlider:SetValueStep(0.01)
flareAlphaSlider:SetOrientation("HORIZONTAL")
flareAlphaSlider:SetScript("OnValueChanged", function(self) MB_alpha(self,"flare") end)
flareAlphaSlider:SetScript("OnLoad", function(self) MB_alpha(self,"flare") end)

local flareScaleSlider = CreateFrame("Slider", "flareScaleSlider", FlaresOptPg, "OptionsSliderTemplate")
flareScaleSlider:SetPoint("TOPLEFT", flareAlphaSlider, "BOTTOMLEFT",0,-25)
flareScaleSlider:SetSize(180,16)
flareScaleSlider:SetMinMaxValues(0.5,1.5)
flareScaleSlider:SetValue(1)
flareScaleSlider:SetValueStep(0.01)
flareScaleSlider:SetOrientation("HORIZONTAL")
flareScaleSlider:SetScript("OnValueChanged", function(self) MB_scale(self,"flare") end)
flareScaleSlider:SetScript("OnLoad", function(self) MB_scale(self,"flare") end)

local flareResetMsgButton = CreateFrame("Button", "flareResetMsgButton", FlaresOptPg, "UIPanelButtonTemplate") --Was OptionsButtonTemplate until patch 10.0.0
flareResetMsgButton:SetPoint("BOTTOMRIGHT", FlaresOptPg, "BOTTOMRIGHT",-5,5)
flareResetMsgButton:SetScript("OnClick", function(self) MB_reset_msg(); MB_checkUpdater(); end)
flareResetMsgButton:SetSize(200,20)
flareResetMsgButton:SetText("Reset to Default Settings")

----------------
-- Announce Options Page
----------------
local AnnounceOptPg = CreateFrame( "Frame", "optionsAnnounce", MarkingBarOpt);
AnnounceOptPg.name = "Marker Announcements";
AnnounceOptPg.parent = MarkingBarOpt.name;
AnnounceOptPg.okay = function(self) MB_Announce_Save(); end
AnnounceOptPg.cancel = function(self) MB_Announce_Save(); end
AnnounceOptPg.default = function(self) MB_reset(); end
AnnounceOptPg.refresh = function(self) MB_checkUpdater(); MB_Announce_Save(); end
local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(category, AnnounceOptPg, AnnounceOptPg.name);
Settings.RegisterAddOnCategory(subcategory);
AnnounceOptPgCategoryId = subcategory:GetID();

local AnnounceOptionsText = AnnounceOptPg:CreateFontString("AnnounceOptionsText", "OVERLAY", "ChatFontNormal")
AnnounceOptionsText:SetPoint("TOP", AnnounceOptPg, "TOP",0,-10)
AnnounceOptionsText:SetText("|cffe1a500Chat Announcement Options")

local AnnounceInstText1 = AnnounceOptPg:CreateFontString("AnnounceInstText", "OVERLAY", "ChatFontSmall")
AnnounceInstText1:SetPoint("TOPLEFT", AnnounceOptPg, "TOPLEFT", 10,-30)
AnnounceInstText1:SetText("Send")

local AnnounceInstText2 = AnnounceOptPg:CreateFontString("AnnounceInstText", "OVERLAY", "ChatFontSmall")
AnnounceInstText2:SetPoint("TOP", AnnounceOptPg, "TOP", 0, -30)
AnnounceInstText2:SetText("Enter the chat messages to send:")

local AnnounceIntroCheck = CreateFrame("CheckButton", "AnnounceIntroCheck", AnnounceOptPg, "UICheckButtonTemplate")
AnnounceIntroCheck:SetPoint("TOPLEFT", AnnounceOptPg, "TOPLEFT", 10,-50)
AnnounceIntroCheck:SetSize(20,20)
AnnounceIntroCheck:SetScript("OnClick", function(self) MBDB.announce_intro = not MBDB.announce_intro end)
local AnnounceIntroMsg = CreateFrame("EditBox", "AnnounceIntroMsg", AnnounceOptPg, "InputBoxTemplate")
AnnounceIntroMsg:SetPoint("LEFT", AnnounceIntroCheck, "RIGHT", 10,0)
AnnounceIntroMsg:SetSize(320,20)
AnnounceIntroMsg:SetFont("Fonts\\ARIALN.TTF", 12, "")
AnnounceIntroMsg:SetAutoFocus(false)

local AnnounceskullCheck = CreateFrame("CheckButton", "AnnounceskullCheck", AnnounceOptPg, "UICheckButtonTemplate")
AnnounceskullCheck:SetPoint("TOP", AnnounceIntroCheck, "BOTTOM",0,-15)
AnnounceskullCheck:SetSize(20,20)
AnnounceskullCheck:SetScript("OnClick", function(self) MBDB.announce_skull = not MBDB.announce_skull end)
local AnnounceskullMsg = CreateFrame("EditBox", "AnnounceskullMsg", AnnounceOptPg, "InputBoxTemplate")
AnnounceskullMsg:SetPoint("LEFT", AnnounceskullCheck, "RIGHT", 10,0)
AnnounceskullMsg:SetSize(320,20)
AnnounceskullMsg:SetFont("Fonts\\ARIALN.TTF", 12, "")
local AnnounceskullIcon = CreateFrame("Button", "AnnounceSkullIcon", AnnounceOptPg)
AnnounceskullIcon:SetSize(20,20)
AnnounceskullIcon:SetPoint("LEFT", AnnounceskullMsg, "Right",5,0)
AnnounceskullIcon:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
AnnounceskullIcon:GetNormalTexture():SetTexCoord(0.75,1,0.25,0.5)
AnnounceskullIcon:EnableMouse(false)
AnnounceskullMsg:SetAutoFocus(false)

local AnnouncecrossCheck = CreateFrame("CheckButton", "AnnouncecrossCheck", AnnounceOptPg, "UICheckButtonTemplate")
AnnouncecrossCheck:SetPoint("TOP", AnnounceskullCheck, "BOTTOM",0,-5)
AnnouncecrossCheck:SetSize(20,20)
AnnouncecrossCheck:SetScript("OnClick", function(self) MBDB.announce_cross = not MBDB.announce_cross end)
local AnnouncecrossMsg = CreateFrame("EditBox", "AnnouncecrossMsg", AnnounceOptPg, "InputBoxTemplate")
AnnouncecrossMsg:SetPoint("LEFT", AnnouncecrossCheck, "RIGHT", 10,0)
AnnouncecrossMsg:SetSize(320,20)
AnnouncecrossMsg:SetFont("Fonts\\ARIALN.TTF", 12, "")
local AnnouncecrossIcon = CreateFrame("Button", "AnnouncecrossIcon", AnnounceOptPg)
AnnouncecrossIcon:SetSize(20,20)
AnnouncecrossIcon:SetPoint("LEFT", AnnouncecrossMsg, "Right",5,0)
AnnouncecrossIcon:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
AnnouncecrossIcon:GetNormalTexture():SetTexCoord(0.5,0.75,0.25,0.5)
AnnouncecrossIcon:EnableMouse(false)
AnnouncecrossMsg:SetAutoFocus(false)

local AnnouncesquareCheck = CreateFrame("CheckButton", "AnnouncesquareCheck", AnnounceOptPg, "UICheckButtonTemplate")
AnnouncesquareCheck:SetPoint("TOP", AnnouncecrossCheck, "BOTTOM",0,-5)
AnnouncesquareCheck:SetSize(20,20)
AnnouncesquareCheck:SetScript("OnClick", function(self) MBDB.announce_square = not MBDB.announce_square end)
local AnnouncesquareMsg = CreateFrame("EditBox", "AnnouncesquareMsg", AnnounceOptPg, "InputBoxTemplate")
AnnouncesquareMsg:SetPoint("LEFT", AnnouncesquareCheck, "RIGHT", 10,0)
AnnouncesquareMsg:SetSize(320,20)
AnnouncesquareMsg:SetFont("Fonts\\ARIALN.TTF", 12, "")
local AnnouncesquareIcon = CreateFrame("Button", "AnnouncesquareIcon", AnnounceOptPg)
AnnouncesquareIcon:SetSize(20,20)
AnnouncesquareIcon:SetPoint("LEFT", AnnouncesquareMsg, "Right",5,0)
AnnouncesquareIcon:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
AnnouncesquareIcon:GetNormalTexture():SetTexCoord(0.25,0.5,0.25,0.5)
AnnouncesquareIcon:EnableMouse(false)
AnnouncesquareMsg:SetAutoFocus(false)

local AnnouncemoonCheck = CreateFrame("CheckButton", "AnnouncemoonCheck", AnnounceOptPg, "UICheckButtonTemplate")
AnnouncemoonCheck:SetPoint("TOP", AnnouncesquareCheck, "BOTTOM",0,-5)
AnnouncemoonCheck:SetSize(20,20)
AnnouncemoonCheck:SetScript("OnClick", function(self) MBDB.announce_moon = not MBDB.announce_moon end)
local AnnouncemoonMsg = CreateFrame("EditBox", "AnnouncemoonMsg", AnnounceOptPg, "InputBoxTemplate")
AnnouncemoonMsg:SetPoint("LEFT", AnnouncemoonCheck, "RIGHT", 10,0)
AnnouncemoonMsg:SetSize(320,20)
AnnouncemoonMsg:SetFont("Fonts\\ARIALN.TTF", 12, "")
local AnnouncemoonIcon = CreateFrame("Button", "AnnouncemoonIcon", AnnounceOptPg)
AnnouncemoonIcon:SetSize(20,20)
AnnouncemoonIcon:SetPoint("LEFT", AnnouncemoonMsg, "Right",5,0)
AnnouncemoonIcon:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
AnnouncemoonIcon:GetNormalTexture():SetTexCoord(0,0.25,0.25,0.5)
AnnouncemoonIcon:EnableMouse(false)
AnnouncemoonMsg:SetAutoFocus(false)

local AnnouncetriangleCheck = CreateFrame("CheckButton", "AnnouncetriangleCheck", AnnounceOptPg, "UICheckButtonTemplate")
AnnouncetriangleCheck:SetPoint("TOP", AnnouncemoonCheck, "BOTTOM",0,-5)
AnnouncetriangleCheck:SetSize(20,20)
AnnouncetriangleCheck:SetScript("OnClick", function(self) MBDB.announce_triangle = not MBDB.announce_triangle end)
local AnnouncetriangleMsg = CreateFrame("EditBox", "AnnouncetriangleMsg", AnnounceOptPg, "InputBoxTemplate")
AnnouncetriangleMsg:SetPoint("LEFT", AnnouncetriangleCheck, "RIGHT", 10,0)
AnnouncetriangleMsg:SetSize(320,20)
AnnouncetriangleMsg:SetFont("Fonts\\ARIALN.TTF", 12, "")
local AnnouncetriangleIcon = CreateFrame("Button", "AnnouncetriangleIcon", AnnounceOptPg)
AnnouncetriangleIcon:SetSize(20,20)
AnnouncetriangleIcon:SetPoint("LEFT", AnnouncetriangleMsg, "Right",5,0)
AnnouncetriangleIcon:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
AnnouncetriangleIcon:GetNormalTexture():SetTexCoord(0.75,1,0,0.25)
AnnouncetriangleIcon:EnableMouse(false)
AnnouncetriangleMsg:SetAutoFocus(false)

local AnnouncediamondCheck = CreateFrame("CheckButton", "AnnouncediamondCheck", AnnounceOptPg, "UICheckButtonTemplate")
AnnouncediamondCheck:SetPoint("TOP", AnnouncetriangleCheck, "BOTTOM",0,-5)
AnnouncediamondCheck:SetSize(20,20)
AnnouncediamondCheck:SetScript("OnClick", function(self) MBDB.announce_diamond = not MBDB.announce_diamond end)
local AnnouncediamondMsg = CreateFrame("EditBox", "AnnouncediamondMsg", AnnounceOptPg, "InputBoxTemplate")
AnnouncediamondMsg:SetPoint("LEFT", AnnouncediamondCheck, "RIGHT", 10,0)
AnnouncediamondMsg:SetSize(320,20)
AnnouncediamondMsg:SetFont("Fonts\\ARIALN.TTF", 12, "")
local AnnouncediamondIcon = CreateFrame("Button", "AnnouncediamondIcon", AnnounceOptPg)
AnnouncediamondIcon:SetSize(20,20)
AnnouncediamondIcon:SetPoint("LEFT", AnnouncediamondMsg, "Right",5,0)
AnnouncediamondIcon:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
AnnouncediamondIcon:GetNormalTexture():SetTexCoord(0.5,0.75,0,0.25)
AnnouncediamondIcon:EnableMouse(false)
AnnouncediamondMsg:SetAutoFocus(false)

local AnnouncecircleCheck = CreateFrame("CheckButton", "AnnouncecircleCheck", AnnounceOptPg, "UICheckButtonTemplate")
AnnouncecircleCheck:SetPoint("TOP", AnnouncediamondCheck, "BOTTOM",0,-5)
AnnouncecircleCheck:SetSize(20,20)
AnnouncecircleCheck:SetScript("OnClick", function(self) MBDB.announce_circle = not MBDB.announce_circle end)
local AnnouncecircleMsg = CreateFrame("EditBox", "AnnouncecircleMsg", AnnounceOptPg, "InputBoxTemplate")
AnnouncecircleMsg:SetPoint("LEFT", AnnouncecircleCheck, "RIGHT", 10,0)
AnnouncecircleMsg:SetSize(320,20)
AnnouncecircleMsg:SetFont("Fonts\\ARIALN.TTF", 12, "")
local AnnouncecircleIcon = CreateFrame("Button", "AnnouncecircleIcon", AnnounceOptPg)
AnnouncecircleIcon:SetSize(20,20)
AnnouncecircleIcon:SetPoint("LEFT", AnnouncecircleMsg, "Right",5,0)
AnnouncecircleIcon:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
AnnouncecircleIcon:GetNormalTexture():SetTexCoord(0.25,0.5,0,0.25)
AnnouncecircleIcon:EnableMouse(false)
AnnouncecircleMsg:SetAutoFocus(false)

local AnnouncestarCheck = CreateFrame("CheckButton", "AnnouncestarCheck", AnnounceOptPg, "UICheckButtonTemplate")
AnnouncestarCheck:SetPoint("TOP", AnnouncecircleCheck, "BOTTOM",0,-5)
AnnouncestarCheck:SetSize(20,20)
AnnouncestarCheck:SetScript("OnClick", function(self) MBDB.announce_star = not MBDB.announce_star end)
local AnnouncestarMsg = CreateFrame("EditBox", "AnnouncestarMsg", AnnounceOptPg, "InputBoxTemplate")
AnnouncestarMsg:SetPoint("LEFT", AnnouncestarCheck, "RIGHT", 10,0)
AnnouncestarMsg:SetSize(320,20)
AnnouncestarMsg:SetFont("Fonts\\ARIALN.TTF", 12, "")
local AnnouncestarIcon = CreateFrame("Button", "AnnouncestarIcon", AnnounceOptPg)
AnnouncestarIcon:SetSize(20,20)
AnnouncestarIcon:SetPoint("LEFT", AnnouncestarMsg, "Right",5,0)
AnnouncestarIcon:SetNormalTexture("interface\\targetingframe\\ui-raidtargetingicons")
AnnouncestarIcon:GetNormalTexture():SetTexCoord(0,0.25,0,0.25)
AnnouncestarIcon:EnableMouse(false)
AnnouncestarMsg:SetAutoFocus(false)

local AnnouncefooterCheck = CreateFrame("CheckButton", "AnnouncefooterCheck", AnnounceOptPg, "UICheckButtonTemplate")
AnnouncefooterCheck:SetPoint("TOP", AnnouncestarCheck, "BOTTOM",0,-5)
AnnouncefooterCheck:SetSize(20,20)
AnnouncefooterCheck:SetScript("OnClick", function(self) MBDB.announce_footer = not MBDB.announce_footer end)
local AnnouncefooterMsg = CreateFrame("EditBox", "AnnouncefooterMsg", AnnounceOptPg, "InputBoxTemplate")
AnnouncefooterMsg:SetPoint("LEFT", AnnouncefooterCheck, "RIGHT", 10,0)
AnnouncefooterMsg:SetSize(320,20)
AnnouncefooterMsg:SetFont("Fonts\\ARIALN.TTF", 12, "")
AnnouncefooterMsg:SetAutoFocus(false)

local AnnouncerwText = AnnounceOptPg:CreateFontString("AnnouncerwText", "OVERLAY", "ChatFontSmall")
AnnouncerwText:SetPoint("TOPLEFT", AnnouncefooterCheck, "BOTTOMLEFT",0,-15)
AnnouncerwText:SetText("Enter the chat message to send as a Raid Warning: (Only in a Raid)")

local AnnouncerwCheck = CreateFrame("CheckButton", "AnnouncerwCheck", AnnounceOptPg, "UICheckButtonTemplate")
AnnouncerwCheck:SetPoint("TOPLEFT", AnnouncerwText, "BOTTOMLEFT",0,-5)
AnnouncerwCheck:SetSize(20,20)
AnnouncerwCheck:SetScript("OnClick", function(self) MBFlaresDB.announce_rw = not MBFlaresDB.announce_rw end)
local AnnouncerwMsg = CreateFrame("EditBox", "AnnouncerwMsg", AnnounceOptPg, "InputBoxTemplate")
AnnouncerwMsg:SetPoint("LEFT", AnnouncerwCheck, "RIGHT", 10,0)
AnnouncerwMsg:SetSize(320,20)
AnnouncerwMsg:SetFont("Fonts\\ARIALN.TTF", 12, "")
AnnouncerwMsg:SetAutoFocus(false)

local AnnouncetooltipCheck = CreateFrame("CheckButton", "AnnouncetooltipCheck", AnnounceOptPg, "UICheckButtonTemplate")
AnnouncetooltipCheck:SetPoint("TOP", AnnouncerwCheck, "BOTTOM",0,-15)
AnnouncetooltipCheck:SetSize(20,20)
AnnouncetooltipCheck:SetScript("OnClick", function(self) MBDB.announce_tooltip = not MBDB.announce_tooltip end)
local AnnouncetooltipText = AnnounceOptPg:CreateFontString("AnnouncetooltipText", "OVERLAY", "ChatFontSmall")
AnnouncetooltipText:SetPoint("LEFT", AnnouncetooltipCheck, "RIGHT",10,0)
AnnouncetooltipText:SetText("Add announce text to raid icon tooltips.")

local AnnounceResetMsgButton = CreateFrame("Button", "AnnounceResetMsgButton", AnnounceOptPg, "UIPanelButtonTemplate") --Was OptionsButtonTemplate until patch 10.0.0
AnnounceResetMsgButton:SetPoint("BOTTOMRIGHT", AnnounceOptPg, "BOTTOMRIGHT",-5,5)
AnnounceResetMsgButton:SetScript("OnClick", function(self) MB_reset_msg(); MB_checkUpdater(); end)
AnnounceResetMsgButton:SetSize(200,20)
AnnounceResetMsgButton:SetText("Reset to Default Settings")

-------------------------------------------------------
-- Profile Page
-------------------------------------------------------
--local ProfilePg = CreateFrame( "Frame", "optionsProfiles", MarkingBarOpt);
--ProfilePg.name = "Profiles";
--ProfilePg.parent = MarkingBarOpt.name;
--ProfilePg.refresh = function(self) MB_checkUpdater(); MB_Announce_Save(); end
--local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(category, ProfilePg, ProfilePg.name);
--Settings.RegisterAddOnCategory(subcategory);
--ProfilePgCategoryId = subcategory:GetID();

-------------------------------------------------------
-- OnEvent
-------------------------------------------------------
local MB_OnUpdate = CreateFrame("Frame")
MB_OnUpdate:RegisterEvent("ADDON_LOADED")
MB_OnUpdate:RegisterEvent("GROUP_ROSTER_UPDATE")
MB_OnUpdate:RegisterEvent("PLAYER_TARGET_CHANGED")
MB_OnUpdate:RegisterEvent("PLAYER_REGEN_DISABLED") --to hide flares and get no taint
MB_OnUpdate:RegisterEvent("PLAYER_REGEN_ENABLED")  --stupid taint
MB_OnUpdate:RegisterEvent("PLAYER_LOGOUT") -- save frame positions here
MB_OnUpdate:RegisterEvent("PLAYER_LOGIN")

MB_OnUpdate:SetScript("OnEvent", function(self,event,addon,...)
	if (event=="ADDON_LOADED") then
		if (addon=="MarkingBarLives") then
			if (MBDB.shown) then MB_targetChecker("main") else SafeSetShown(MB_mainFrame, false) end
			if (MBDB.locked) then MB_lock("main") else MB_unlock("main") end
			MB_mainFrame:SetClampedToScreen(MBDB.clamped)
			if (MBDB.bgHide) then MB_bgHide("main") else MB_bgShow("main") end
			MB_mainFrame:SetScale(MBDB.scale,main)
			MB_mainFrame:SetAlpha(MBDB.alpha,main)

            if (MBCtrlDB.shown) then MB_targetChecker("ctrl") else SafeSetShown(MB_controlFrame, false) end
			MB_controlFrame:SetClampedToScreen(MBCtrlDB.clamped)
            if (MBCtrlDB.locked) then MB_lock("ctrl") else MB_unlock("ctrl") end
            if (MBCtrlDB.bgHide) then MB_bgHide("ctrl") else MB_bgShow("ctrl") end
			MB_controlFrame:SetScale(MBCtrlDB.scale,ctrl)
			MB_controlFrame:SetAlpha(MBCtrlDB.alpha,ctrl)

            MB_flipChecker()

            if (MBFlaresDB.shown) then MB_targetChecker("flare") else SafeSetShown(MBFlares_mainFrame, false) end --for shown and partyShow
			if (MBFlaresDB.locked) then MB_lock("flare") else MB_unlock("flare") end
			MBFlares_mainFrame:SetClampedToScreen(MBFlaresDB.clamped)
			MB_flareflipChecker() -- for flipped and vertical
			if (MBFlaresDB.bgHide) then MB_bgHide("flare") else MB_bgShow("flare") end
			MBFlares_mainFrame:SetScale(MBFlaresDB.scale,flare)
			MBFlares_mainFrame:SetAlpha(MBFlaresDB.alpha,flare)
		end
	end
	if (event=="GROUP_ROSTER_UPDATE") or (event=="PLAYER_TARGET_CHANGED") then
		MB_targetChecker("main")
        MB_targetChecker("ctrl")
        if ( not InCombatLockdown() ) then
            MB_targetChecker("flare")
        end
    end
    if (event=="PLAYER_REGEN_ENABLED") then
        MB_targetChecker("flare")
    end
	if (event=="PLAYER_LOGOUT") then
		MB_savepositions()
	end
	if (event=="PLAYER_LOGIN") then
		MB_setpositions()
	end
end
)
