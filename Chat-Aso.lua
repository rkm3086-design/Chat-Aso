-- Micy Chat v4.24 - Royal Edition
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Chat = game:GetService("Chat")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
if not httpRequest then
    StarterGui:SetCore("SendNotification", {
        Title = "خطأ في المنفذ ❌",
        Text = "منفذ الألعاب لديك لا يدعم دالة request()!",
        Duration = 10,
    })
    return
end

local FIREBASE_URL = "https://micychat-f41e8-default-rtdb.firebaseio.com/messages.json"
local TYPING_URL = "https://micychat-f41e8-default-rtdb.firebaseio.com/typing.json"
local BANS_URL = "https://micychat-f41e8-default-rtdb.firebaseio.com/bans.json"
local ONLINE_URL = "https://micychat-f41e8-default-rtdb.firebaseio.com/online.json"
local MUTES_URL = "https://micychat-f41e8-default-rtdb.firebaseio.com/mutes.json"
local SessionStartTime = os.time() - 5

local VIP_USER_IDS = {
    [9202875847] = true,
    [10545964840] = true,
    [10567420230] = true,
}

local isVipUser = VIP_USER_IDS[LocalPlayer.UserId] or false

local uiRainbowSpeed = 1.2
local msgRainbowSpeed = 1.2
local nameRainbowSpeed = 1.2

local isUiDynamicRainbow = true 
local isMessageRainbowEnabled = false 
local isNameRainbowEnabled = true

local defaultRainbowColors = {
    Color3.fromRGB(255, 215, 0),
    Color3.fromRGB(218, 165, 32),
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(138, 43, 226)
}

local JoinSound = Instance.new("Sound")
JoinSound.Name = "JoinNotificationSound"
JoinSound.SoundId = "rbxassetid://4590662766"
JoinSound.Volume = 1
JoinSound.Parent = SoundService

local STICKERS_LIST = {
    {name = "مساء التوت", id = "rbxassetid://74216313680636", vip = false},
    {name = "Cool", id = "rbxassetid://6023426920", vip = false},
    {name = "Laugh", id = "rbxassetid://6023427021", vip = false},
    {name = "VIP Fire", id = "rbxassetid://6023426915", vip = true},
    {name = "VIP Star", id = "rbxassetid://6023427005", vip = true}
}

local ignoredUsers = {}
local bannedUsers = {}
local mutedUsers = {}
local loadedKeys = {}

StarterGui:SetCore("SendNotification", {
    Title = isVipUser and "🛡️ [Micy Chat]" or "⚡ Micy Chat";
    Text = "تم تشغيل السكربت الملكي بنجاح!";
    Duration = 5;
})

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MicyChatGui"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local PopupHolder = Instance.new("Frame")
PopupHolder.Name = "PopupHolder"
PopupHolder.Parent = ScreenGui
PopupHolder.BackgroundTransparency = 1
PopupHolder.Position = UDim2.new(1, -235, 1, -195)
PopupHolder.Size = UDim2.new(0, 225, 0, 120)

local PopupLayout = Instance.new("UIListLayout")
PopupLayout.Parent = PopupHolder
PopupLayout.SortOrder = Enum.SortOrder.LayoutOrder
PopupLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
PopupLayout.Padding = UDim.new(0, 6)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BackgroundTransparency = 0.35
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 380, 0, 265)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.BackgroundTransparency = 0.4
Title.Text = "👑 Micy Chat v4.24 [Royal]"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local AdminPanelBtn = Instance.new("TextButton")
AdminPanelBtn.Parent = Title
AdminPanelBtn.Size = UDim2.new(0, 32, 0, 26)
AdminPanelBtn.Position = UDim2.new(0, 8, 0, 4)
AdminPanelBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
AdminPanelBtn.BackgroundTransparency = 0.3
AdminPanelBtn.Text = "⚙️"
AdminPanelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AdminPanelBtn.TextSize = 14
AdminPanelBtn.Visible = isVipUser

local AdminBtnCorner = Instance.new("UICorner")
AdminBtnCorner.CornerRadius = UDim.new(0, 6)
AdminBtnCorner.Parent = AdminPanelBtn

local ClearChatBtn = Instance.new("TextButton")
ClearChatBtn.Parent = Title
ClearChatBtn.Size = UDim2.new(0, 32, 0, 26)
ClearChatBtn.Position = UDim2.new(0, 44, 0, 4)
ClearChatBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ClearChatBtn.BackgroundTransparency = 0.3
ClearChatBtn.Text = "🗑️"
ClearChatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearChatBtn.TextSize = 14

local ClearChatCorner = Instance.new("UICorner")
ClearChatCorner.CornerRadius = UDim.new(0, 6)
ClearChatCorner.Parent = ClearChatBtn

local HeaderMsgRainbowBtn = Instance.new("TextButton")
HeaderMsgRainbowBtn.Parent = Title
HeaderMsgRainbowBtn.Size = UDim2.new(0, 32, 0, 26)
HeaderMsgRainbowBtn.Position = UDim2.new(0, 80, 0, 4)
HeaderMsgRainbowBtn.BackgroundColor3 = isMessageRainbowEnabled and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(50, 50, 50)
HeaderMsgRainbowBtn.BackgroundTransparency = 0.3
HeaderMsgRainbowBtn.Text = "✨"
HeaderMsgRainbowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderMsgRainbowBtn.TextSize = 14

local HeaderMsgRainbowCorner = Instance.new("UICorner")
HeaderMsgRainbowCorner.CornerRadius = UDim.new(0, 6)
HeaderMsgRainbowCorner.Parent = HeaderMsgRainbowBtn

local OnlineCountLabel = Instance.new("TextLabel")
OnlineCountLabel.Parent = Title
OnlineCountLabel.Size = UDim2.new(0, 100, 1, 0)
OnlineCountLabel.Position = UDim2.new(1, -105, 0, 0)
OnlineCountLabel.BackgroundTransparency = 1
OnlineCountLabel.Text = "🟢 المتواجدون: 1"
OnlineCountLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
OnlineCountLabel.TextSize = 12
OnlineCountLabel.Font = Enum.Font.SourceSansBold
OnlineCountLabel.TextXAlignment = Enum.TextXAlignment.Right

local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = MainFrame
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.Size = UDim2.new(1, -20, 0, 135)
Scroll.BackgroundTransparency = 0.95
Scroll.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollBarThickness = 5

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Scroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

ClearChatBtn.MouseButton1Click:Connect(function()
    for _, child in pairs(Scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
end)

HeaderMsgRainbowBtn.MouseButton1Click:Connect(function()
    isMessageRainbowEnabled = not isMessageRainbowEnabled
    HeaderMsgRainbowBtn.BackgroundColor3 = isMessageRainbowEnabled and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(50, 50, 50)
end)

local AdminPanelFrame = Instance.new("Frame")
AdminPanelFrame.Parent = MainFrame
AdminPanelFrame.Position = UDim2.new(0, 10, 0, 45)
AdminPanelFrame.Size = UDim2.new(1, -20, 0, 155)
AdminPanelFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
AdminPanelFrame.BackgroundTransparency = 0.15
AdminPanelFrame.Visible = false
AdminPanelFrame.ZIndex = 5

local AdminPanelCorner = Instance.new("UICorner")
AdminPanelCorner.CornerRadius = UDim.new(0, 8)
AdminPanelCorner.Parent = AdminPanelFrame

local ClearDatabaseBtn = Instance.new("TextButton")
ClearDatabaseBtn.Parent = AdminPanelFrame
ClearDatabaseBtn.Position = UDim2.new(0, 8, 0, 6)
ClearDatabaseBtn.Size = UDim2.new(1, -16, 0, 28)
ClearDatabaseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ClearDatabaseBtn.Text = "🗑️ مسح كل رسائل السيرفر"
ClearDatabaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearDatabaseBtn.Font = Enum.Font.SourceSansBold
ClearDatabaseBtn.TextSize = 11
ClearDatabaseBtn.ZIndex = 6

local ClearDbCorner = Instance.new("UICorner")
ClearDbCorner.CornerRadius = UDim.new(0, 6)
ClearDbCorner.Parent = ClearDatabaseBtn

ClearDatabaseBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        pcall(function() httpRequest({ Url = FIREBASE_URL, Method = "DELETE" }) end)
        for _, child in pairs(Scroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        loadedKeys = {}
    end)
end)

local ColorCustomizerBtn = Instance.new("TextButton")
ColorCustomizerBtn.Parent = AdminPanelFrame
ColorCustomizerBtn.Position = UDim2.new(0, 8, 0, 38)
ColorCustomizerBtn.Size = UDim2.new(1, -16, 0, 26)
ColorCustomizerBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
ColorCustomizerBtn.Text = "👑 لوحة الألوان الملكية المدمجة"
ColorCustomizerBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
ColorCustomizerBtn.Font = Enum.Font.SourceSansBold
ColorCustomizerBtn.TextSize = 11
ColorCustomizerBtn.ZIndex = 6

local ColorCustCorner = Instance.new("UICorner")
ColorCustCorner.CornerRadius = UDim.new(0, 6)
ColorCustCorner.Parent = ColorCustomizerBtn

local AdminScroll = Instance.new("ScrollingFrame")
AdminScroll.Parent = AdminPanelFrame
AdminScroll.Position = UDim2.new(0, 5, 0, 68)
AdminScroll.Size = UDim2.new(1, -10, 1, -74)
AdminScroll.BackgroundTransparency = 1
AdminScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
AdminScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
AdminScroll.ScrollBarThickness = 4
AdminScroll.ZIndex = 6

local AdminScrollList = Instance.new("UIListLayout")
AdminScrollList.Parent = AdminScroll
AdminScrollList.SortOrder = Enum.SortOrder.LayoutOrder
AdminScrollList.Padding = UDim.new(0, 6)

local ColorOptionsFrame = Instance.new("ScrollingFrame")
ColorOptionsFrame.Parent = AdminPanelFrame
ColorOptionsFrame.Size = UDim2.new(1, 0, 1, 0)
ColorOptionsFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ColorOptionsFrame.BackgroundTransparency = 0.02
ColorOptionsFrame.Visible = false
ColorOptionsFrame.ZIndex = 25
ColorOptionsFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
ColorOptionsFrame.ScrollBarThickness = 4

local ColorOptsCorner = Instance.new("UICorner")
ColorOptsCorner.CornerRadius = UDim.new(0, 8)
ColorOptsCorner.Parent = ColorOptionsFrame

local ColorOptsLayout = Instance.new("UIListLayout")
ColorOptsLayout.Parent = ColorOptionsFrame
ColorOptsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ColorOptsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ColorOptsLayout.Padding = UDim.new(0, 6)

ColorCustomizerBtn.MouseButton1Click:Connect(function()
    ColorOptionsFrame.Visible = true
    for _, child in pairs(ColorOptionsFrame:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UICorner") then child:Destroy() end
    end

    local function createSectionTitle(text)
        local lbl = Instance.new("TextLabel")
        lbl.Parent = ColorOptionsFrame
        lbl.Size = UDim2.new(0, 340, 0, 24)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
        lbl.Font = Enum.Font.SourceSansBold
        lbl.TextSize = 12
        lbl.ZIndex = 26
    end

    -- 1. واجهة التطبيق
    createSectionTitle("🌟 1. لون واجهة التطبيق الملكية:")

    local uiBoxContainer = Instance.new("Frame")
    uiBoxContainer.Parent = ColorOptionsFrame
    uiBoxContainer.Size = UDim2.new(0, 340, 0, 75)
    uiBoxContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    uiBoxContainer.BackgroundTransparency = 0.3
    uiBoxContainer.ZIndex = 26
    local uibc = Instance.new("UICorner") uibc.CornerRadius = UDim.new(0, 6) uibc.Parent = uiBoxContainer

    local toggleUiBtn = Instance.new("TextButton")
    toggleUiBtn.Parent = uiBoxContainer
    toggleUiBtn.Position = UDim2.new(0, 10, 0, 8)
    toggleUiBtn.Size = UDim2.new(0, 155, 0, 26)
    toggleUiBtn.BackgroundColor3 = isUiDynamicRainbow and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(160, 40, 40)
    toggleUiBtn.Text = isUiDynamicRainbow and "رينبو الواجهة: ✅" or "رينبو الواجهة: ❌"
    toggleUiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleUiBtn.Font = Enum.Font.SourceSansBold
    toggleUiBtn.TextSize = 11
    toggleUiBtn.ZIndex = 27
    local tuic = Instance.new("UICorner") tuic.CornerRadius = UDim.new(0, 6) tuic.Parent = toggleUiBtn
    toggleUiBtn.MouseButton1Click:Connect(function()
        isUiDynamicRainbow = not isUiDynamicRainbow
        toggleUiBtn.BackgroundColor3 = isUiDynamicRainbow and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(160, 40, 40)
        toggleUiBtn.Text = isUiDynamicRainbow and "رينبو الواجهة: ✅" or "رينبو الواجهة: ❌"
    end)

    local uiSpeedLbl = Instance.new("TextLabel")
    uiSpeedLbl.Parent = uiBoxContainer
    uiSpeedLbl.Position = UDim2.new(0, 175, 0, 8)
    uiSpeedLbl.Size = UDim2.new(0, 155, 0, 26)
    uiSpeedLbl.BackgroundTransparency = 1
    uiSpeedLbl.Text = "السرعة: " .. string.format("%.1f", uiRainbowSpeed)
    uiSpeedLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    uiSpeedLbl.TextSize = 11
    uiSpeedLbl.Font = Enum.Font.SourceSansBold
    uiSpeedLbl.ZIndex = 27

    local uiFaster = Instance.new("TextButton")
    uiFaster.Parent = uiBoxContainer
    uiFaster.Position = UDim2.new(0, 175, 0, 40)
    uiFaster.Size = UDim2.new(0, 75, 0, 26)
    uiFaster.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    uiFaster.Text = "أسرع ⚡"
    uiFaster.TextColor3 = Color3.fromRGB(255, 255, 255)
    uiFaster.TextSize = 10
    uiFaster.ZIndex = 27
    local uic1 = Instance.new("UICorner") uic1.CornerRadius = UDim.new(0, 4) uic1.Parent = uiFaster
    uiFaster.MouseButton1Click:Connect(function()
        uiRainbowSpeed = math.min(uiRainbowSpeed + 0.3, 5.0)
        uiSpeedLbl.Text = "السرعة: " .. string.format("%.1f", uiRainbowSpeed)
    end)

    local uiSlower = Instance.new("TextButton")
    uiSlower.Parent = uiBoxContainer
    uiSlower.Position = UDim2.new(0, 255, 0, 40)
    uiSlower.Size = UDim2.new(0, 75, 0, 26)
    uiSlower.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    uiSlower.Text = "أبطأ 🐢"
    uiSlower.TextColor3 = Color3.fromRGB(255, 255, 255)
    uiSlower.TextSize = 10
    uiSlower.ZIndex = 27
    local uic2 = Instance.new("UICorner") uic2.CornerRadius = UDim.new(0, 4) uic2.Parent = uiSlower
    uiSlower.MouseButton1Click:Connect(function()
        uiRainbowSpeed = math.max(uiRainbowSpeed - 0.3, 0.1)
        uiSpeedLbl.Text = "السرعة: " .. string.format("%.1f", uiRainbowSpeed)
    end)

    local uiColorDropdownBtn = Instance.new("TextButton")
    uiColorDropdownBtn.Parent = uiBoxContainer
    uiColorDropdownBtn.Position = UDim2.new(0, 10, 0, 40)
    uiColorDropdownBtn.Size = UDim2.new(0, 155, 0, 26)
    uiColorDropdownBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    uiColorDropdownBtn.Text = "👑 قائمة الألوان الملكية المدمجة"
    uiColorDropdownBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    uiColorDropdownBtn.TextSize = 9
    uiColorDropdownBtn.Font = Enum.Font.SourceSansBold
    uiColorDropdownBtn.ZIndex = 27
    local uiddc = Instance.new("UICorner") uiddc.CornerRadius = UDim.new(0, 4) uiddc.Parent = uiColorDropdownBtn

    local uiColorDropdownList = Instance.new("ScrollingFrame")
    uiColorDropdownList.Parent = ColorOptionsFrame
    uiColorDropdownList.Size = UDim2.new(0, 340, 0, 95)
    uiColorDropdownList.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    uiColorDropdownList.BackgroundTransparency = 0.05
    uiColorDropdownList.Visible = false
    uiColorDropdownList.ZIndex = 30
    uiColorDropdownList.CanvasSize = UDim2.new(0, 0, 0, 160)
    uiColorDropdownList.ScrollBarThickness = 4
    local uiddlc = Instance.new("UICorner") uiddlc.CornerRadius = UDim.new(0, 6) uiddlc.Parent = uiColorDropdownList
    local uigrid = Instance.new("UIGridLayout") uigrid.Parent = uiColorDropdownList uigrid.CellSize = UDim2.new(0, 105, 0, 26) uigrid.CellPadding = UDim2.new(0, 5, 0, 5) uigrid.SortOrder = Enum.SortOrder.LayoutOrder

    uiColorDropdownBtn.MouseButton1Click:Connect(function()
        uiColorDropdownList.Visible = not uiColorDropdownList.Visible
    end)

    local royalColors = {
        {"👑 ذهبي ملكي", Color3.fromRGB(255, 215, 0)},
        {"💎 بنفسجي ملكي", Color3.fromRGB(138, 43, 226)},
        {"🍷 أحمر ملكي", Color3.fromRGB(178, 34, 34)},
        {"🌌 أزرق ملكي", Color3.fromRGB(65, 105, 225)},
        {"🪙 ذهبي برونزي", Color3.fromRGB(218, 165, 32)},
        {"🔮 بنفسجي غامق", Color3.fromRGB(75, 0, 130)},
        {"🖤 أسود ملكي فخم", Color3.fromRGB(35, 35, 35)},
        {"🤍 أبيض لؤلؤي", Color3.fromRGB(245, 245, 245)},
        {"🌹 وردي مخملي", Color3.fromRGB(199, 21, 133)},
        {"🌿 زمردي ملكي", Color3.fromRGB(46, 139, 87)},
        {"🔥 برتقالي نحاسي", Color3.fromRGB(205, 92, 92)},
        {"⚡ فضي لامع", Color3.fromRGB(192, 192, 192)}
    }

    for _, colData in ipairs(royalColors) do
        local cBtn = Instance.new("TextButton")
        cBtn.Parent = uiColorDropdownList
        cBtn.BackgroundColor3 = colData[2]
        cBtn.Text = colData[1]
        cBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        cBtn.TextSize = 10
        cBtn.Font = Enum.Font.SourceSansBold
        cBtn.ZIndex = 31
        local cbc = Instance.new("UICorner") cbc.CornerRadius = UDim.new(0, 4) cbc.Parent = cBtn
        cBtn.MouseButton1Click:Connect(function()
            isUiDynamicRainbow = false
            UIStroke.Color = colData[2]
            ToggleStroke.Color = colData[2]
            toggleUiBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
            toggleUiBtn.Text = "رينبو الواجهة: ❌"
            uiColorDropdownList.Visible = false
        end)
    end

    -- 2. رسائل الشات
    createSectionTitle("💬 2. لون رسائل الشات الملكية:")

    local msgBoxContainer = Instance.new("Frame")
    msgBoxContainer.Parent = ColorOptionsFrame
    msgBoxContainer.Size = UDim2.new(0, 340, 0, 75)
    msgBoxContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    msgBoxContainer.BackgroundTransparency = 0.3
    msgBoxContainer.ZIndex = 26
    local mbtc = Instance.new("UICorner") mbtc.CornerRadius = UDim.new(0, 6) mbtc.Parent = msgBoxContainer

    local toggleMsgBtn = Instance.new("TextButton")
    toggleMsgBtn.Parent = msgBoxContainer
    toggleMsgBtn.Position = UDim2.new(0, 10, 0, 8)
    toggleMsgBtn.Size = UDim2.new(0, 155, 0, 26)
    toggleMsgBtn.BackgroundColor3 = isMessageRainbowEnabled and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(160, 40, 40)
    toggleMsgBtn.Text = isMessageRainbowEnabled and "رينبو الرسائل: ✅" or "رينبو الرسائل: ❌"
    toggleMsgBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleMsgBtn.Font = Enum.Font.SourceSansBold
    toggleMsgBtn.TextSize = 11
    toggleMsgBtn.ZIndex = 27
    local tmcc = Instance.new("UICorner") tmcc.CornerRadius = UDim.new(0, 6) tmcc.Parent = toggleMsgBtn
    toggleMsgBtn.MouseButton1Click:Connect(function()
        isMessageRainbowEnabled = not isMessageRainbowEnabled
        HeaderMsgRainbowBtn.BackgroundColor3 = isMessageRainbowEnabled and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(50, 50, 50)
        toggleMsgBtn.BackgroundColor3 = isMessageRainbowEnabled and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(160, 40, 40)
        toggleMsgBtn.Text = isMessageRainbowEnabled and "رينبو الرسائل: ✅" or "رينبو الرسائل: ❌"
    end)

    local msgSpeedLbl = Instance.new("TextLabel")
    msgSpeedLbl.Parent = msgBoxContainer
    msgSpeedLbl.Position = UDim2.new(0, 175, 0, 8)
    msgSpeedLbl.Size = UDim2.new(0, 155, 0, 26)
    msgSpeedLbl.BackgroundTransparency = 1
    msgSpeedLbl.Text = "السرعة: " .. string.format("%.1f", msgRainbowSpeed)
    msgSpeedLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    msgSpeedLbl.TextSize = 11
    msgSpeedLbl.Font = Enum.Font.SourceSansBold
    msgSpeedLbl.ZIndex = 27

    local msgFaster = Instance.new("TextButton")
    msgFaster.Parent = msgBoxContainer
    msgFaster.Position = UDim2.new(0, 175, 0, 40)
    msgFaster.Size = UDim2.new(0, 75, 0, 26)
    msgFaster.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    msgFaster.Text = "أسرع ⚡"
    msgFaster.TextColor3 = Color3.fromRGB(255, 255, 255)
    msgFaster.TextSize = 10
    msgFaster.ZIndex = 27
    local mc1 = Instance.new("UICorner") mc1.CornerRadius = UDim.new(0, 4) mc1.Parent = msgFaster
    msgFaster.MouseButton1Click:Connect(function()
        msgRainbowSpeed = math.min(msgRainbowSpeed + 0.3, 5.0)
        msgSpeedLbl.Text = "السرعة: " .. string.format("%.1f", msgRainbowSpeed)
    end)

    local msgSlower = Instance.new("TextButton")
    msgSlower.Parent = msgBoxContainer
    msgSlower.Position = UDim2.new(0, 255, 0, 40)
    msgSlower.Size = UDim2.new(0, 75, 0, 26)
    msgSlower.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    msgSlower.Text = "أبطأ 🐢"
    msgSlower.TextColor3 = Color3.fromRGB(255, 255, 255)
    msgSlower.TextSize = 10
    msgSlower.ZIndex = 27
    local mc2 = Instance.new("UICorner") mc2.CornerRadius = UDim.new(0, 4) mc2.Parent = msgSlower
    msgSlower.MouseButton1Click:Connect(function()
        msgRainbowSpeed = math.max(msgRainbowSpeed - 0.3, 0.1)
        msgSpeedLbl.Text = "السرعة: " .. string.format("%.1f", msgRainbowSpeed)
    end)

    local msgColorDropdownBtn = Instance.new("TextButton")
    msgColorDropdownBtn.Parent = msgBoxContainer
    msgColorDropdownBtn.Position = UDim2.new(0, 10, 0, 40)
    msgColorDropdownBtn.Size = UDim2.new(0, 155, 0, 26)
    msgColorDropdownBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    msgColorDropdownBtn.Text = "👑 قائمة الألوان الملكية للرسائل"
    msgColorDropdownBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    msgColorDropdownBtn.TextSize = 9
    msgColorDropdownBtn.Font = Enum.Font.SourceSansBold
    msgColorDropdownBtn.ZIndex = 27
    local mcddc = Instance.new("UICorner") mcddc.CornerRadius = UDim.new(0, 4) mcddc.Parent = msgColorDropdownBtn

    local msgColorDropdownList = Instance.new("ScrollingFrame")
    msgColorDropdownList.Parent = ColorOptionsFrame
    msgColorDropdownList.Size = UDim2.new(0, 340, 0, 95)
    msgColorDropdownList.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    msgColorDropdownList.BackgroundTransparency = 0.05
    msgColorDropdownList.Visible = false
    msgColorDropdownList.ZIndex = 30
    msgColorDropdownList.CanvasSize = UDim2.new(0, 0, 0, 160)
    msgColorDropdownList.ScrollBarThickness = 4
    local mcddlc = Instance.new("UICorner") mcddlc.CornerRadius = UDim.new(0, 6) mcddlc.Parent = msgColorDropdownList
    local msggrid = Instance.new("UIGridLayout") msggrid.Parent = msgColorDropdownList msggrid.CellSize = UDim2.new(0, 105, 0, 26) msggrid.CellPadding = UDim2.new(0, 5, 0, 5) msggrid.SortOrder = Enum.SortOrder.LayoutOrder

    msgColorDropdownBtn.MouseButton1Click:Connect(function()
        msgColorDropdownList.Visible = not msgColorDropdownList.Visible
    end)

    for _, colData in ipairs(royalColors) do
        local cBtn = Instance.new("TextButton")
        cBtn.Parent = msgColorDropdownList
        cBtn.BackgroundColor3 = colData[2]
        cBtn.Text = colData[1]
        cBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        cBtn.TextSize = 10
        cBtn.Font = Enum.Font.SourceSansBold
        cBtn.ZIndex = 31
        local cbc = Instance.new("UICorner") cbc.CornerRadius = UDim.new(0, 4) cbc.Parent = cBtn
        cBtn.MouseButton1Click:Connect(function()
            isMessageRainbowEnabled = false
            HeaderMsgRainbowBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            toggleMsgBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
            toggleMsgBtn.Text = "رينبو الرسائل: ❌"
            local hexColor = string.format("#%02x%02x%02x", math.floor(colData[2].R*255), math.floor(colData[2].G*255), math.floor(colData[2].B*255))
            for _, item in pairs(activeMessageLabels) do
                if item and item.Label and item.Label.Parent then
                    item.Label.Text = string.format("<font color='%s'>%s</font>", hexColor, item.OriginalText or "")
                end
            end
            msgColorDropdownList.Visible = false
        end)
    end

    -- 3. أسماء المطورين
    createSectionTitle("👑 3. لون أسماء المطورين:")

    local nameBoxContainer = Instance.new("Frame")
    nameBoxContainer.Parent = ColorOptionsFrame
    nameBoxContainer.Size = UDim2.new(0, 340, 0, 75)
    nameBoxContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    nameBoxContainer.BackgroundTransparency = 0.3
    nameBoxContainer.ZIndex = 26
    local nbtc = Instance.new("UICorner") nbtc.CornerRadius = UDim.new(0, 6) nbtc.Parent = nameBoxContainer

    local toggleNameBtn = Instance.new("TextButton")
    toggleNameBtn.Parent = nameBoxContainer
    toggleNameBtn.Position = UDim2.new(0, 10, 0, 8)
    toggleNameBtn.Size = UDim2.new(0, 155, 0, 26)
    toggleNameBtn.BackgroundColor3 = isNameRainbowEnabled and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(160, 40, 40)
    toggleNameBtn.Text = isNameRainbowEnabled and "رينبو الأسماء: ✅" or "رينبو الأسماء: ❌"
    toggleNameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleNameBtn.Font = Enum.Font.SourceSansBold
    toggleNameBtn.TextSize = 11
    toggleNameBtn.ZIndex = 27
    local tncc = Instance.new("UICorner") tncc.CornerRadius = UDim.new(0, 6) tncc.Parent = toggleNameBtn
    toggleNameBtn.MouseButton1Click:Connect(function()
        isNameRainbowEnabled = not isNameRainbowEnabled
        toggleNameBtn.BackgroundColor3 = isNameRainbowEnabled and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(160, 40, 40)
        toggleNameBtn.Text = isNameRainbowEnabled and "رينبو الأسماء: ✅" or "رينبو الأسماء: ❌"
    end)

    local nameSpeedLbl = Instance.new("TextLabel")
    nameSpeedLbl.Parent = nameBoxContainer
    nameSpeedLbl.Position = UDim2.new(0, 175, 0, 8)
    nameSpeedLbl.Size = UDim2.new(0, 155, 0, 26)
    nameSpeedLbl.BackgroundTransparency = 1
    nameSpeedLbl.Text = "السرعة: " .. string.format("%.1f", nameRainbowSpeed)
    nameSpeedLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameSpeedLbl.TextSize = 11
    nameSpeedLbl.Font = Enum.Font.SourceSansBold
    nameSpeedLbl.ZIndex = 27

    local nameFaster = Instance.new("TextButton")
    nameFaster.Parent = nameBoxContainer
    nameFaster.Position = UDim2.new(0, 175, 0, 40)
    nameFaster.Size = UDim2.new(0, 75, 0, 26)
    nameFaster.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    nameFaster.Text = "أسرع ⚡"
    nameFaster.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameFaster.TextSize = 10
    nameFaster.ZIndex = 27
    local nc1 = Instance.new("UICorner") nc1.CornerRadius = UDim.new(0, 4) nc1.Parent = nameFaster
    nameFaster.MouseButton1Click:Connect(function()
        nameRainbowSpeed = math.min(nameRainbowSpeed + 0.3, 5.0)
        nameSpeedLbl.Text = "السرعة: " .. string.format("%.1f", nameRainbowSpeed)
    end)

    local nameSlower = Instance.new("TextButton")
    nameSlower.Parent = nameBoxContainer
    nameSlower.Position = UDim2.new(0, 255, 0, 40)
    nameSlower.Size = UDim2.new(0, 75, 0, 26)
    nameSlower.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    nameSlower.Text = "أبطأ 🐢"
    nameSlower.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameSlower.TextSize = 10
    nameSlower.ZIndex = 27
    local nc2 = Instance.new("UICorner") nc2.CornerRadius = UDim.new(0, 4) nc2.Parent = nameSlower
    nameSlower.MouseButton1Click:Connect(function()
        nameRainbowSpeed = math.max(nameRainbowSpeed - 0.3, 0.1)
        nameSpeedLbl.Text = "السرعة: " .. string.format("%.1f", nameRainbowSpeed)
    end)

    local closeColorBtn = Instance.new("TextButton")
    closeColorBtn.Parent = ColorOptionsFrame
    closeColorBtn.Size = UDim2.new(0, 340, 0, 32)
    closeColorBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    closeColorBtn.Text = "حفظ وإغلاق القائمة الملكية ✅"
    closeColorBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    closeColorBtn.Font = Enum.Font.SourceSansBold
    closeColorBtn.TextSize = 12
    closeColorBtn.ZIndex = 26
    local ccc = Instance.new("UICorner") ccc.CornerRadius = UDim.new(0, 6) ccc.Parent = closeColorBtn
    closeColorBtn.MouseButton1Click:Connect(function()
        ColorOptionsFrame.Visible = false
        uiColorDropdownList.Visible = false
        msgColorDropdownList.Visible = false
    end)
end)

local MuteOptionsFrame = Instance.new("Frame")
MuteOptionsFrame.Parent = AdminPanelFrame
MuteOptionsFrame.Size = UDim2.new(1, 0, 1, 0)
MuteOptionsFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MuteOptionsFrame.BackgroundTransparency = 0.1
MuteOptionsFrame.Visible = false
MuteOptionsFrame.ZIndex = 20

local MuteOptsCorner = Instance.new("UICorner")
MuteOptsCorner.CornerRadius = UDim.new(0, 8)
MuteOptsCorner.Parent = MuteOptionsFrame

local MuteOptsLayout = Instance.new("UIListLayout")
MuteOptsLayout.Parent = MuteOptionsFrame
MuteOptsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
MuteOptsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
MuteOptsLayout.SortOrder = Enum.SortOrder.LayoutOrder
MuteOptsLayout.Padding = UDim.new(0, 8)

AdminPanelBtn.MouseButton1Click:Connect(function()
    AdminPanelFrame.Visible = not AdminPanelFrame.Visible
    MuteOptionsFrame.Visible = false
    ColorOptionsFrame.Visible = false
end)

local TypingIndicatorLabel = Instance.new("TextLabel")
TypingIndicatorLabel.Parent = MainFrame
TypingIndicatorLabel.Position = UDim2.new(0, 10, 0, 186)
TypingIndicatorLabel.Size = UDim2.new(1, -20, 0, 20)
TypingIndicatorLabel.BackgroundTransparency = 1
TypingIndicatorLabel.Text = ""
TypingIndicatorLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
TypingIndicatorLabel.TextSize = 13
TypingIndicatorLabel.Font = Enum.Font.SourceSansBold
TypingIndicatorLabel.TextXAlignment = Enum.TextXAlignment.Left

local InputBox = Instance.new("TextBox")
InputBox.Parent = MainFrame
InputBox.Position = UDim2.new(0, 10, 0, 210)
InputBox.Size = UDim2.new(0, 150, 0, 38)
InputBox.PlaceholderText = "اكتب هنا بالشات..."
InputBox.Text = ""
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
InputBox.BackgroundTransparency = 0.4
InputBox.Font = Enum.Font.SourceSans
InputBox.TextSize = 14
InputBox.TextXAlignment = Enum.TextXAlignment.Right

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = InputBox

local SpamButton = Instance.new("TextButton")
SpamButton.Parent = MainFrame
SpamButton.Position = UDim2.new(0, 166, 0, 210)
SpamButton.Size = UDim2.new(0, 36, 0, 38)
SpamButton.Text = "🚀"
SpamButton.BackgroundColor3 = isVipUser and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(50, 50, 50)
SpamButton.BackgroundTransparency = 0.3
SpamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpamButton.Font = Enum.Font.SourceSansBold
SpamButton.TextSize = 16

local SpamCorner = Instance.new("UICorner")
SpamCorner.CornerRadius = UDim.new(0, 8)
SpamCorner.Parent = SpamButton

local StickerMenuBtn = Instance.new("TextButton")
StickerMenuBtn.Parent = MainFrame
StickerMenuBtn.Position = UDim2.new(0, 206, 0, 210)
StickerMenuBtn.Size = UDim2.new(0, 36, 0, 38)
StickerMenuBtn.Text = "🖼️"
StickerMenuBtn.BackgroundColor3 = Color3.fromRGB(218, 165, 32)
StickerMenuBtn.BackgroundTransparency = 0.3
StickerMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StickerMenuBtn.Font = Enum.Font.SourceSansBold
StickerMenuBtn.TextSize = 15

local StickerCorner = Instance.new("UICorner")
StickerCorner.CornerRadius = UDim.new(0, 8)
StickerCorner.Parent = StickerMenuBtn

local SendButton = Instance.new("TextButton")
SendButton.Parent = MainFrame
SendButton.Position = UDim2.new(0, 246, 0, 210)
SendButton.Size = UDim2.new(0, 124, 0, 38)
SendButton.Text = "إرسال"
SendButton.BackgroundColor3 = isVipUser and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(138, 43, 226)
SendButton.BackgroundTransparency = 0.3
SendButton.TextColor3 = isVipUser and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
SendButton.Font = Enum.Font.SourceSansBold
SendButton.TextSize = 15

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 8)
SendCorner.Parent = SendButton

local StickerFrame = Instance.new("Frame")
StickerFrame.Parent = MainFrame
StickerFrame.Position = UDim2.new(0, 178, 0, 45)
StickerFrame.Size = UDim2.new(0, 192, 0, 140)
StickerFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
StickerFrame.BackgroundTransparency = 0.2
StickerFrame.Visible = false

local StickerFrameCorner = Instance.new("UICorner")
StickerFrameCorner.CornerRadius = UDim.new(0, 10)
StickerFrameCorner.Parent = StickerFrame

local StickerGrid = Instance.new("UIGridLayout")
StickerGrid.Parent = StickerFrame
StickerGrid.CellSize = UDim2.new(0, 50, 0, 50)
StickerGrid.CellPadding = UDim2.new(0, 8, 0, 8)

StickerMenuBtn.MouseButton1Click:Connect(function()
    StickerFrame.Visible = not StickerFrame.Visible
end)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0, 5, 0.5, -30)
ToggleButton.Size = UDim2.new(0, 32, 0, 120)
ToggleButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ToggleButton.BackgroundTransparency = 0.5
ToggleButton.Text = "C\nH\nA\nT"
ToggleButton.TextColor3 = Color3.fromRGB(255, 215, 0)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.SourceSansBold

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Parent = ToggleButton
ToggleStroke.Thickness = 2

local rainbowNameLabels = {}
local activeMessageLabels = {}

task.spawn(function()
    local t = 0
    while true do
        local delta = RunService.RenderStepped:Wait()
        if isUiDynamicRainbow then
            local colors = defaultRainbowColors
            t = (t + delta * uiRainbowSpeed) % #colors
            local index = math.floor(t) + 1
            local nextIndex = (index % #colors) + 1
            local alpha = t - math.floor(t)
            local currentColor = colors[index]:Lerp(colors[nextIndex], alpha)
            
            UIStroke.Color = currentColor
            ToggleStroke.Color = currentColor
        end
    end
end)

task.spawn(function()
    local t = 0
    while true do
        local delta = RunService.RenderStepped:Wait()
        if isNameRainbowEnabled then
            local colors = defaultRainbowColors
            t = (t + delta * nameRainbowSpeed) % #colors
            local index = math.floor(t) + 1
            local nextIndex = (index % #colors) + 1
            local alpha = t - math.floor(t)
            local currentColor = colors[index]:Lerp(colors[nextIndex], alpha)
            
            for _, lbl in pairs(rainbowNameLabels) do
                if lbl and lbl.Parent then
                    lbl.TextColor3 = currentColor
                end
            end
        else
            for _, lbl in pairs(rainbowNameLabels) do
                if lbl and lbl.Parent then
                    lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
                end
            end
        end
    end
end)

task.spawn(function()
    local t = 0
    while true do
        local delta = RunService.RenderStepped:Wait()
        if isMessageRainbowEnabled then
            local colors = defaultRainbowColors
            t = (t + delta * msgRainbowSpeed) % #colors
            local index = math.floor(t) + 1
            local nextIndex = (index % #colors) + 1
            local alpha = t - math.floor(t)
            local currentColor = colors[index]:Lerp(colors[nextIndex], alpha)
            
            local hexColor = string.format("#%02x%02x%02x", math.floor(currentColor.R*255), math.floor(currentColor.G*255), math.floor(currentColor.B*255))
            for _, item in pairs(activeMessageLabels) do
                if item and item.Label and item.Label.Parent then
                    local rawText = item.OriginalText or ""
                    item.Label.Text = string.format("<font color='%s'>%s</font>", hexColor, rawText)
                end
            end
        end
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local myOnlineDisplayName = "ساني"
if tostring(LocalPlayer.UserId) == "9202875847" then myOnlineDisplayName = "[المطوره سـانا] 👑"
elseif tostring(LocalPlayer.UserId) == "10545964840" then myOnlineDisplayName = "[المطور الثاني] 👑"
elseif tostring(LocalPlayer.UserId) == "10567420230" then myOnlineDisplayName = "[المطور سـاني] 👑"
elseif isVipUser then myOnlineDisplayName = "ساني [👑 VIP]" end

task.spawn(function()
    while true do
        pcall(function()
            httpRequest({
                Url = "https://micychat-f41e8-default-rtdb.firebaseio.com/online/" .. LocalPlayer.UserId .. ".json",
                Method = "PUT",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({time = os.time(), name = myOnlineDisplayName})
            })
        end)
        task.wait(3)
    end
end)

local function sendBanAction(targetId, isBanned, targetName)
    task.spawn(function()
        local data = {adminId = LocalPlayer.UserId, targetId = tostring(targetId), action = isBanned and "ban" or "unban", targetName = targetName or ""}
        pcall(function()
            httpRequest({
                Url = "https://micychat-f41e8-default-rtdb.firebaseio.com/bans/" .. tostring(targetId) .. ".json",
                Method = "PUT",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end)
    end)
end

local function sendMuteAction(targetId, durationSeconds)
    task.spawn(function()
        local unbanTime = (durationSeconds == 0) and 0 or (os.time() + durationSeconds)
        local data = {adminId = LocalPlayer.UserId, targetId = tostring(targetId), expireTime = unbanTime}
        pcall(function()
            httpRequest({
                Url = "https://micychat-f41e8-default-rtdb.firebaseio.com/mutes/" .. tostring(targetId) .. ".json",
                Method = "PUT",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end)
    end)
end

local function addMessageToUI(senderId, senderName, text, isSticker, stickerId, isSystem, systemColor, isVipSender, isRainbowMsg)
    local isMutedUser = mutedUsers[tostring(senderId)]
    local isMutedActive = isMutedUser and (isMutedUser == 0 or os.time() < isMutedUser)
    if bannedUsers[tostring(senderId)] or ignoredUsers[tostring(senderId)] or isMutedActive then return end

    local container = Instance.new("Frame")
    container.Parent = Scroll
    container.BackgroundTransparency = 1

    if isSystem then
        container.Size = UDim2.new(1, 0, 0, 20)
        local nameLabel = Instance.new("TextButton")
        nameLabel.Parent = container
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.SourceSans
        nameLabel.TextSize = 14
        nameLabel.TextColor3 = systemColor or Color3.fromRGB(255, 215, 0)
        nameLabel.Text = "[System]: " .. (text or "")
        nameLabel.AutoButtonColor = false
    else
        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Parent = container
        avatarImg.Position = UDim2.new(0, 0, 0, 0)
        avatarImg.Size = UDim2.new(0, 28, 0, 28)
        avatarImg.BackgroundTransparency = 1
        avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(senderId) .. "&w=420&h=420"
        
        local avatarCorner = Instance.new("UICorner")
        avatarCorner.CornerRadius = UDim.new(1, 0)
        avatarCorner.Parent = avatarImg

        local rankTitle = ""
        local isDevUser = VIP_USER_IDS[tonumber(senderId)] or false
        if tostring(senderId) == "9202875847" then rankTitle = "[المطوره سـانا] 👑"
        elseif tostring(senderId) == "10545964840" then rankTitle = "[المطور الثاني] 👑"
        elseif tostring(senderId) == "10567420230" then rankTitle = "[المطور سـاني] 👑"
        elseif isVipSender then rankTitle = senderName .. " [👑 VIP]"
        else rankTitle = "[" .. senderName .. "]" end

        local nameLabel = Instance.new("TextButton")
        nameLabel.Parent = container
        nameLabel.Position = UDim2.new(0, 34, 0, 0)
        nameLabel.Size = UDim2.new(1, -34, 0, 16)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 14
        nameLabel.TextColor3 = isDevUser and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(138, 43, 226)
        nameLabel.Text = rankTitle
        nameLabel.AutoButtonColor = false

        if isDevUser then table.insert(rainbowNameLabels, nameLabel) end

        if isSticker then
            container.Size = UDim2.new(1, 0, 0, 70)
            local img = Instance.new("ImageLabel")
            img.Parent = container
            img.Position = UDim2.new(0, 34, 0, 18)
            img.Size = UDim2.new(0, 48, 0, 48)
            img.BackgroundTransparency = 1
            img.Image = stickerId
        else
            container.Size = UDim2.new(1, 0, 0, 42)
            local textLabel = Instance.new("TextButton")
            textLabel.Parent = container
            textLabel.Position = UDim2.new(0, 34, 0, 17)
            textLabel.Size = UDim2.new(1, -34, 0, 22)
            textLabel.BackgroundTransparency = 1
            textLabel.TextXAlignment = Enum.TextXAlignment.Left
            textLabel.Font = Enum.Font.SourceSans
            textLabel.TextSize = 14
            textLabel.TextWrapped = true
            textLabel.RichText = true
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.Text = text or ""

            if isRainbowMsg then
                table.insert(activeMessageLabels, {Label = textLabel, OriginalText = text})
            end

            textLabel.MouseButton1Click:Connect(function()
                if setclipboard then
                    setclipboard(text or "")
                end
            end)
        end
    end

    Scroll.CanvasPosition = Vector2.new(0, Scroll.AbsoluteCanvasSize.Y)
end

local function sendData(text, isSticker, stickerId, isSystem, isRainbow)
    if not isSystem and (text ~= "" or isSticker) then
        addMessageToUI(LocalPlayer.UserId, "ساني", text, isSticker, stickerId, false, nil, isVipUser, isRainbow)
    end

    task.spawn(function()
        local data = {
            senderId = LocalPlayer.UserId,
            senderName = "ساني",
            text = text or "",
            isSticker = isSticker or false,
            stickerId = stickerId or "",
            isSystem = isSystem or false,
            isVip = isVipUser,
            isRainbow = isRainbow or false,
            time = os.time()
        }
        pcall(function()
            local res = httpRequest({
                Url = FIREBASE_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
            if res and res.Success and res.Body then
                local decoded = HttpService:JSONDecode(res.Body)
                if decoded and decoded.name then
                    loadedKeys[decoded.name] = true
                end
            end
        end)
    end)
end

local function showSidePopup(senderId, senderName, text, isSticker, stickerId, isVipSender)
    task.spawn(function()
        local popup = Instance.new("Frame")
        popup.Parent = PopupHolder
        popup.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        popup.BackgroundTransparency = 0.3
        popup.Size = UDim2.new(0, 225, 0, 52)
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = popup
        
        local stroke = Instance.new("UIStroke")
        stroke.Parent = popup
        stroke.Color = isVipSender and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(138, 43, 226)
        stroke.Thickness = 1.2
        
        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Parent = popup
        avatarImg.Position = UDim2.new(0, 6, 0, 6)
        avatarImg.Size = UDim2.new(0, 38, 0, 38)
        avatarImg.BackgroundTransparency = 1
        avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(senderId) .. "&w=420&h=420"
        
        local avatarCorner = Instance.new("UICorner")
        avatarCorner.CornerRadius = UDim.new(1, 0)
        avatarCorner.Parent = avatarImg
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = popup
        nameLabel.Position = UDim2.new(0, 50, 0, 4)
        nameLabel.Size = UDim2.new(1, -56, 0, 14)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 11
        nameLabel.TextColor3 = isVipSender and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(138, 43, 226)
        
        local popupTitle = senderName
        if tostring(senderId) == "9202875847" then popupTitle = "[المطوره سـانا] 👑"
        elseif tostring(senderId) == "10545964840" then popupTitle = "[المطور الثاني] 👑"
        elseif tostring(senderId) == "10567420230" then popupTitle = "[المطور سـاني] 👑"
        elseif isVipSender then popupTitle = senderName .. " [👑 VIP]" end
        nameLabel.Text = popupTitle
        
        if isSticker then
            local img = Instance.new("ImageLabel")
            img.Parent = popup
            img.Position = UDim2.new(0, 50, 0, 18)
            img.Size = UDim2.new(0, 30, 0, 30)
            img.BackgroundTransparency = 1
            img.Image = stickerId
        else
            local contentLabel = Instance.new("TextLabel")
            contentLabel.Parent = popup
            contentLabel.Position = UDim2.new(0, 50, 0, 18)
            contentLabel.Size = UDim2.new(1, -56, 0, 30)
            contentLabel.BackgroundTransparency = 1
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.TextYAlignment = Enum.TextYAlignment.Top
            contentLabel.Font = Enum.Font.SourceSans
            contentLabel.TextSize = 11
            contentLabel.TextWrapped = true
            contentLabel.RichText = true
            contentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            contentLabel.Text = text or ""
        end
        
        task.wait(3)
        popup:Destroy()
    end)
end

local function showBubbleChat(senderId, text)
    local targetPlayer = Players:GetPlayerByUserId(tonumber(senderId))
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        pcall(function() Chat:Chat(targetPlayer.Character.Head, text, Enum.ChatColor.White) end)
    end
end

local function updateTypingStatus(isTyping)
    task.spawn(function()
        local data = {senderId = LocalPlayer.UserId, senderName = "ساني", isTyping = isTyping}
        pcall(function()
            httpRequest({
                Url = "https://micychat-f41e8-default-rtdb.firebaseio.com/typing/" .. LocalPlayer.UserId .. ".json",
                Method = "PUT",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end)
    end)
end

local lastTypingState = false
InputBox:GetPropertyChangedSignal("Text"):Connect(function()
    local isTyping = (InputBox.Text ~= "")
    if isTyping ~= lastTypingState then
        lastTypingState = isTyping
        updateTypingStatus(isTyping)
    end
end)

local function sendMessage()
    if lastTypingState then
        lastTypingState = false
        updateTypingStatus(false)
    end
    local text = InputBox.Text
    if text ~= "" then
        InputBox.Text = ""
        sendData(text, false, nil, false, isMessageRainbowEnabled)
        showBubbleChat(LocalPlayer.UserId, text)
    end
end

InputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then sendMessage() end
end)
SendButton.MouseButton1Click:Connect(sendMessage)

local isSpamming = false
SpamButton.MouseButton1Click:Connect(function()
    if not isVipUser then return end
    local text = InputBox.Text
    if text == "" then return end
    isSpamming = not isSpamming
    if isSpamming then
        SpamButton.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
        task.spawn(function()
            while isSpamming do
                sendData(text, false, nil, false, isMessageRainbowEnabled)
                showBubbleChat(LocalPlayer.UserId, text)
                task.wait(0.05)
            end
        end)
    else
        SpamButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    end
end)

for _, sticker in pairs(STICKERS_LIST) do
    local btn = Instance.new("ImageButton")
    btn.Parent = StickerFrame
    btn.Image = sticker.id
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BackgroundTransparency = 0.5
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    if sticker.vip and not isVipUser then
        local lockLabel = Instance.new("TextLabel")
        lockLabel.Parent = btn
        lockLabel.Size = UDim2.new(1, 0, 1, 0)
        lockLabel.BackgroundTransparency = 0.5
        lockLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        lockLabel.Text = "🔒"
        lockLabel.TextSize = 16
    end

    btn.MouseButton1Click:Connect(function()
        if (sticker.vip and not isVipUser) then return end
        sendData(nil, true, sticker.id, false, false)
        StickerFrame.Visible = false
    end)
end

sendData("ساني joined the royal chat!", false, nil, true, false)

task.spawn(function()
    while task.wait(0.03) do
        pcall(function()
            local onlineResponse = httpRequest({ Url = ONLINE_URL, Method = "GET" })
            if onlineResponse.Success and onlineResponse.Body and onlineResponse.Body ~= "null" then
                local onlineData = HttpService:JSONDecode(onlineResponse.Body)
                if type(onlineData) == "table" then
                    local count = 0
                    local currentTime = os.time()
                    
                    for _, child in pairs(AdminScroll:GetChildren()) do
                        if child:IsA("Frame") then child:Destroy() end
                    end

                    for id, info in pairs(onlineData) do
                        if info and info.time and (currentTime - info.time < 10) then
                            count = count + 1
                            
                            if isVipUser then
                                local row = Instance.new("Frame")
                                row.Parent = AdminScroll
                                row.Size = UDim2.new(1, 0, 0, 32)
                                row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                                row.BackgroundTransparency = 0.3
                                row.ZIndex = 6
                                
                                local rowCorner = Instance.new("UICorner")
                                rowCorner.CornerRadius = UDim.new(0, 6)
                                rowCorner.Parent = row
                                
                                local nameLbl = Instance.new("TextLabel")
                                nameLbl.Parent = row
                                nameLbl.Size = UDim2.new(0, 120, 1, 0)
                                nameLbl.Position = UDim2.new(0, 8, 0, 0)
                                nameLbl.BackgroundTransparency = 1
                                nameLbl.Text = info.name or id
                                nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                                nameLbl.TextSize = 12
                                nameLbl.Font = Enum.Font.SourceSansBold
                                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                                nameLbl.ZIndex = 6
                                
                                if VIP_USER_IDS[tonumber(id)] then
                                    table.insert(rainbowNameLabels, nameLbl)
                                end
                                
                                local isMutedTarget = mutedUsers[tostring(id)]
                                local isTargetMuteActive = isMutedTarget and (isMutedTarget == 0 or currentTime < isMutedTarget)

                                local muteBtn = Instance.new("TextButton")
                                muteBtn.Parent = row
                                muteBtn.Size = UDim2.new(0, 55, 0, 24)
                                muteBtn.Position = UDim2.new(1, -118, 0, 4)
                                muteBtn.BackgroundColor3 = isTargetMuteActive and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(80, 80, 80)
                                muteBtn.Text = isTargetMuteActive and "إلغاء ميوت" or "ميوت"
                                muteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                                muteBtn.TextSize = 10
                                muteBtn.Font = Enum.Font.SourceSansBold
                                muteBtn.ZIndex = 6
                                
                                local mCorner = Instance.new("UICorner")
                                mCorner.CornerRadius = UDim.new(0, 4)
                                mCorner.Parent = muteBtn
                                
                                muteBtn.MouseButton1Click:Connect(function()
                                    if isTargetMuteActive then
                                        sendMuteAction(id, 0)
                                        mutedUsers[tostring(id)] = nil
                                    else
                                        MuteOptionsFrame.Visible = true
                                        for _, child in pairs(MuteOptionsFrame:GetChildren()) do
                                            if child:IsA("TextButton") then child:Destroy() end
                                        end

                                        local function createDurationBtn(text, seconds)
                                            local dBtn = Instance.new("TextButton")
                                            dBtn.Parent = MuteOptionsFrame
                                            dBtn.Size = UDim2.new(0, 200, 0, 32)
                                            dBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                                            dBtn.Text = text
                                            dBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                                            dBtn.Font = Enum.Font.SourceSansBold
                                            dBtn.TextSize = 14
                                            dBtn.ZIndex = 21
                                            
                                            local dc = Instance.new("UICorner")
                                            dc.CornerRadius = UDim.new(0, 6)
                                            dc.Parent = dBtn
                                            
                                            dBtn.MouseButton1Click:Connect(function()
                                                sendMuteAction(id, seconds)
                                                mutedUsers[tostring(id)] = (seconds == 0) and 0 or (os.time() + seconds)
                                                MuteOptionsFrame.Visible = false
                                            end)
                                        end

                                        createDurationBtn("دقيقة واحدة", 60)
                                        createDurationBtn("5 دقائق", 300)
                                        createDurationBtn("ساعة كاملة", 3600)
                                        createDurationBtn("5 ساعات", 18000)
                                        
                                        local closeOpt = Instance.new("TextButton")
                                        closeOpt.Parent = MuteOptionsFrame
                                        closeOpt.Size = UDim2.new(0, 200, 0, 28)
                                        closeOpt.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
                                        closeOpt.Text = "إلغاء"
                                        closeOpt.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        closeOpt.Font = Enum.Font.SourceSansBold
                                        closeOpt.TextSize = 12
                                        closeOpt.ZIndex = 21
                                        local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0, 6) cc.Parent = closeOpt
                                        closeOpt.MouseButton1Click:Connect(function() MuteOptionsFrame.Visible = false end)
                                    end
                                end)

                                local isBanned = bannedUsers[tostring(id)] == true
                                local banBtn = Instance.new("TextButton")
                                banBtn.Parent = row
                                banBtn.Size = UDim2.new(0, 50, 0, 24)
                                banBtn.Position = UDim2.new(1, -58, 0, 4)
                                banBtn.BackgroundColor3 = isBanned and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(180, 40, 40)
                                banBtn.Text = isBanned and "إلغاء" or "طرد"
                                banBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                                banBtn.TextSize = 10
                                banBtn.Font = Enum.Font.SourceSansBold
                                banBtn.ZIndex = 6
                                
                                local bCorner = Instance.new("UICorner")
                                bCorner.CornerRadius = UDim.new(0, 4)
                                bCorner.Parent = banBtn
                                
                                banBtn.MouseButton1Click:Connect(function()
                                    if isBanned then
                                        bannedUsers[tostring(id)] = nil
                                        sendBanAction(id, false, info.name)
                                    else
                                        bannedUsers[tostring(id)] = true
                                        sendBanAction(id, true, info.name)
                                    end
                                end)
                            end
                        end
                    end
                    OnlineCountLabel.Text = "🟢 المتواجدون: " .. tostring(count)
                end
            end

            local response = httpRequest({ Url = FIREBASE_URL, Method = "GET" })
            if response.Success and response.Body and response.Body ~= "null" then
                local data = HttpService:JSONDecode(response.Body)
                if type(data) == "table" then
                    for key, msg in pairs(data) do
                        if not loadedKeys[key] then
                            loadedKeys[key] = true
                            if msg.time and msg.time >= SessionStartTime then
                                local targetMuteExpire = mutedUsers[tostring(msg.senderId)]
                                local isTargetMuted = targetMuteExpire and (targetMuteExpire == 0 or os.time() < targetMuteExpire)
                                
                                if not bannedUsers[tostring(msg.senderId)] and not isTargetMuted then
                                    if tostring(msg.senderId) ~= tostring(LocalPlayer.UserId) then
                                        JoinSound:Play()
                                        if msg.isSystem then
                                            addMessageToUI(msg.senderId, msg.senderName, msg.text, false, nil, true, Color3.fromRGB(255, 215, 0), msg.isVip, false)
                                        else
                                            addMessageToUI(msg.senderId, msg.senderName, msg.text, msg.isSticker, msg.stickerId, false, nil, msg.isVip, msg.isRainbow)
                                            showSidePopup(msg.senderId, msg.senderName, msg.text, msg.isSticker, msg.stickerId, msg.isVip)
                                            if not msg.isSticker and msg.text and not msg.text:match("^http") then
                                                showBubbleChat(msg.senderId, msg.text)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)
