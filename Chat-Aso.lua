-- Micy Chat v4.13 - Instant Local Display & Ultra Fast Speed
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Chat = game:GetService("Chat")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local FIREBASE_URL = "https://micychat-f41e8-default-rtdb.firebaseio.com/messages.json"
local TYPING_URL = "https://micychat-f41e8-default-rtdb.firebaseio.com/typing.json"
local BANS_URL = "https://micychat-f41e8-default-rtdb.firebaseio.com/bans.json"
local ONLINE_URL = "https://micychat-f41e8-default-rtdb.firebaseio.com/online.json"
local MUTES_URL = "https://micychat-f41e8-default-rtdb.firebaseio.com/mutes.json"
local SessionStartTime = os.time() - 5

-- 👑 الأيديـات الخاصة بالمطورين والأدمنية
local VIP_USER_IDS = {
    [9202875847] = true, -- مساعدة المطور سانا
    [10545964840] = true, -- المطور ساني
}

local isVipUser = VIP_USER_IDS[LocalPlayer.UserId] or false

-- 🔊 صوت التنبيه
local JoinSound = Instance.new("Sound")
JoinSound.Name = "JoinNotificationSound"
JoinSound.SoundId = "rbxassetid://4590662766"
JoinSound.Volume = 1
JoinSound.Parent = SoundService

-- 🎨 قائمة الملصقات
local STICKERS_LIST = {
    {name = "مساء التوت", id = "rbxassetid://74216313680636", vip = false},
    {name = "Cool", id = "rbxassetid://6023426920", vip = false},
    {name = "Laugh", id = "rbxassetid://6023427021", vip = false},
    {name = "VIP Fire 👑", id = "rbxassetid://6023426915", vip = true},
    {name = "VIP Star 🌟", id = "rbxassetid://6023427005", vip = true}
}

local ignoredUsers = {}
local bannedUsers = {}
local mutedUsers = {}
local loadedKeys = {}

-- Welcome Notification
StarterGui:SetCore("SendNotification", {
    Title = isVipUser and "🛡️ [Micy Chat v4.13]" or "⚡ Micy Chat v4.13";
    Text = "تم تفعيل الظهور الفوري للرسائل محلياً!";
    Duration = 5;
})

-- ScreenGui Parent (CoreGui for Executor)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MicyChatGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- حاوية الإشعارات الجانبية
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

-- ⏳ نافذة عداد الميوت المصغرة (قابلة للسحب - Draggable)
local MuteTimerLabel = Instance.new("TextButton")
MuteTimerLabel.Name = "MuteTimerLabel"
MuteTimerLabel.Parent = ScreenGui
MuteTimerLabel.Size = UDim2.new(0, 180, 0, 40)
MuteTimerLabel.Position = UDim2.new(0.5, -90, 0.15, 0)
MuteTimerLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MuteTimerLabel.BackgroundTransparency = 0.2
MuteTimerLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
MuteTimerLabel.TextSize = 13
MuteTimerLabel.Font = Enum.Font.SourceSansBold
MuteTimerLabel.Text = "⏳ الميوت: 00:00"
MuteTimerLabel.Visible = false
MuteTimerLabel.Active = true
MuteTimerLabel.Draggable = true

local MuteTimerCorner = Instance.new("UICorner")
MuteTimerCorner.CornerRadius = UDim.new(0, 8)
MuteTimerCorner.Parent = MuteTimerLabel

local MuteTimerStroke = Instance.new("UIStroke")
MuteTimerStroke.Parent = MuteTimerLabel
MuteTimerStroke.Color = Color3.fromRGB(255, 100, 0)
MuteTimerStroke.Thickness = 1.5

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
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

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.BackgroundTransparency = 0.4
Title.Text = "⚡ Micy Chat v4.13"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Admin Settings Button
local AdminPanelBtn = Instance.new("TextButton")
AdminPanelBtn.Parent = Title
AdminPanelBtn.Size = UDim2.new(0, 32, 0, 26)
AdminPanelBtn.Position = UDim2.new(0, 8, 0, 4)
AdminPanelBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
AdminPanelBtn.BackgroundTransparency = 0.3
AdminPanelBtn.Text = "⚙️"
AdminPanelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AdminPanelBtn.TextSize = 14
AdminPanelBtn.Visible = isVipUser

local AdminBtnCorner = Instance.new("UICorner")
AdminBtnCorner.CornerRadius = UDim.new(0, 6)
AdminBtnCorner.Parent = AdminPanelBtn

-- Online Count Label
local OnlineCountLabel = Instance.new("TextLabel")
OnlineCountLabel.Parent = Title
OnlineCountLabel.Size = UDim2.new(0, 100, 1, 0)
OnlineCountLabel.Position = UDim2.new(1, -105, 0, 0)
OnlineCountLabel.BackgroundTransparency = 1
OnlineCountLabel.Text = "🟢 المتواجدون: 1"
OnlineCountLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
OnlineCountLabel.TextSize = 12
OnlineCountLabel.Font = Enum.Font.SourceSansBold
OnlineCountLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Scroll Area for Messages
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

-- Admin Control Panel Window
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

local AdminScroll = Instance.new("ScrollingFrame")
AdminScroll.Parent = AdminPanelFrame
AdminScroll.Position = UDim2.new(0, 5, 0, 10)
AdminScroll.Size = UDim2.new(1, -10, 1, -15)
AdminScroll.BackgroundTransparency = 1
AdminScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
AdminScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
AdminScroll.ScrollBarThickness = 4
AdminScroll.ZIndex = 6

local AdminScrollList = Instance.new("UIListLayout")
AdminScrollList.Parent = AdminScroll
AdminScrollList.SortOrder = Enum.SortOrder.LayoutOrder
AdminScrollList.Padding = UDim.new(0, 6)

-- نافذة خيارات مدة الميوت الفرعية
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
end)

-- Typing Indicator Label
local TypingIndicatorLabel = Instance.new("TextLabel")
TypingIndicatorLabel.Parent = MainFrame
TypingIndicatorLabel.Position = UDim2.new(0, 10, 0, 186)
TypingIndicatorLabel.Size = UDim2.new(1, -20, 0, 20)
TypingIndicatorLabel.BackgroundTransparency = 1
TypingIndicatorLabel.Text = ""
TypingIndicatorLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
TypingIndicatorLabel.TextSize = 13
TypingIndicatorLabel.Font = Enum.Font.SourceSansBold
TypingIndicatorLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Text Input Box
local InputBox = Instance.new("TextBox")
InputBox.Parent = MainFrame
InputBox.Position = UDim2.new(0, 10, 0, 210)
InputBox.Size = UDim2.new(0, 160, 0, 38)
InputBox.PlaceholderText = "اكتب هنا للشات..."
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

-- Spam Button (صاروخ 🚀 صار مكانه مكان الملصقات)
local SpamButton = Instance.new("TextButton")
SpamButton.Parent = MainFrame
SpamButton.Position = UDim2.new(0, 178, 0, 210)
SpamButton.Size = UDim2.new(0, 40, 0, 38)
SpamButton.Text = "🚀"
SpamButton.BackgroundColor3 = isVipUser and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(50, 50, 50)
SpamButton.BackgroundTransparency = 0.3
SpamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpamButton.Font = Enum.Font.SourceSansBold
SpamButton.TextSize = 16

local SpamCorner = Instance.new("UICorner")
SpamCorner.CornerRadius = UDim.new(0, 8)
SpamCorner.Parent = SpamButton

-- Sticker Menu Button (ملصقات 🖼️ صارت مكان الصاروخ)
local StickerMenuBtn = Instance.new("TextButton")
StickerMenuBtn.Parent = MainFrame
StickerMenuBtn.Position = UDim2.new(0, 226, 0, 210)
StickerMenuBtn.Size = UDim2.new(0, 40, 0, 38)
StickerMenuBtn.Text = "🖼️"
StickerMenuBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
StickerMenuBtn.BackgroundTransparency = 0.3
StickerMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StickerMenuBtn.Font = Enum.Font.SourceSansBold
StickerMenuBtn.TextSize = 15

local StickerCorner = Instance.new("UICorner")
StickerCorner.CornerRadius = UDim.new(0, 8)
StickerCorner.Parent = StickerMenuBtn

-- Send Button
local SendButton = Instance.new("TextButton")
SendButton.Parent = MainFrame
SendButton.Position = UDim2.new(0, 274, 0, 210)
SendButton.Size = UDim2.new(0, 96, 0, 38)
SendButton.Text = "إرسال"
SendButton.BackgroundColor3 = isVipUser and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 150, 255)
SendButton.BackgroundTransparency = 0.3
SendButton.TextColor3 = isVipUser and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
SendButton.Font = Enum.Font.SourceSansBold
SendButton.TextSize = 15

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 8)
SendCorner.Parent = SendButton

-- Stickers Frame (تعديل موضعها لتناسب المكان الجديد لزر الملصقات)
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

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0, 5, 0.5, -30)
ToggleButton.Size = UDim2.new(0, 32, 0, 120)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.BackgroundTransparency = 0.5
ToggleButton.Text = "C\nH\nA\nT"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.SourceSansBold

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Parent = ToggleButton
ToggleStroke.Thickness = 2

local rainbowNameLabels = {}

-- تأثير الألوان الديناميكية
task.spawn(function()
    local colors = isVipUser and {
        Color3.fromRGB(255, 215, 0),
        Color3.fromRGB(255, 140, 0),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 105, 180)
    } or {
        Color3.fromRGB(46, 204, 113),
        Color3.fromRGB(241, 196, 15),
        Color3.fromRGB(255, 255, 255)
    }
    
    local t = 0
    while true do
        local delta = RunService.RenderStepped:Wait()
        t = (t + delta * 1.2) % #colors
        local index = math.floor(t) + 1
        local nextIndex = (index % #colors) + 1
        local alpha = t - math.floor(t)
        local currentColor = colors[index]:Lerp(colors[nextIndex], alpha)
        
        UIStroke.Color = currentColor
        ToggleStroke.Color = currentColor
        
        for _, lbl in pairs(rainbowNameLabels) do
            if lbl and lbl.Parent then
                lbl.TextColor3 = currentColor
            end
        end
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- نظام الحضور والوجود السريع
task.spawn(function()
    while true do
        pcall(function()
            request({
                Url = "https://micychat-f41e8-default-rtdb.firebaseio.com/online/" .. LocalPlayer.UserId .. ".json",
                Method = "PUT",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({time = os.time(), name = LocalPlayer.DisplayName})
            })
        end)
        task.wait(3)
    end
end)

local function sendBanAction(targetId, isBanned, targetName)
    task.spawn(function()
        local data = {adminId = LocalPlayer.UserId, targetId = tostring(targetId), action = isBanned and "ban" or "unban", targetName = targetName or ""}
        pcall(function()
            request({
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
            request({
                Url = "https://micychat-f41e8-default-rtdb.firebaseio.com/mutes/" .. tostring(targetId) .. ".json",
                Method = "PUT",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end)
    end)
end

-- دالة لإضافة الرسالة محلياً للشات مباشرة وبدون تأخير
local function addMessageToUI(senderId, senderName, text, isSticker, stickerId, isSystem, systemColor, isVipSender)
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
        if tostring(senderId) == "9202875847" then rankTitle = "[المطوره سـانا] 👑"
        elseif tostring(senderId) == "10545964840" then rankTitle = "[المطور سـاني] 👑"
        elseif isVipSender then rankTitle = senderName .. " 👑 [VIP]"
        else rankTitle = "[" .. senderName .. "]" end

        local nameLabel = Instance.new("TextButton")
        nameLabel.Parent = container
        nameLabel.Position = UDim2.new(0, 34, 0, 0)
        nameLabel.Size = UDim2.new(1, -34, 0, 16)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 14
        nameLabel.TextColor3 = isVipSender and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 170, 255)
        nameLabel.Text = rankTitle
        nameLabel.AutoButtonColor = false

        if isVipSender then table.insert(rainbowNameLabels, nameLabel) end

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
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.Text = text or ""

            textLabel.MouseButton1Click:Connect(function()
                if setclipboard then
                    setclipboard(text or "")
                    StarterGui:SetCore("SendNotification", {Title = "تم النسخ 📋", Text = "تم نسخ الرسالة", Duration = 2})
                end
            end)
        end
    end

    Scroll.CanvasPosition = Vector2.new(0, Scroll.AbsoluteCanvasSize.Y)
end

-- دالة الإرسال مع العرض المحلي الفوري (Zero-Delay)
local function sendData(text, isSticker, stickerId, isSystem)
    if not isSystem and (text ~= "" or isSticker) then
        addMessageToUI(LocalPlayer.UserId, LocalPlayer.DisplayName, text, isSticker, stickerId, false, nil, isVipUser)
    end

    task.spawn(function()
        local data = {
            senderId = LocalPlayer.UserId,
            senderName = LocalPlayer.DisplayName,
            text = text or "",
            isSticker = isSticker or false,
            stickerId = stickerId or "",
            isSystem = isSystem or false,
            isVip = isVipUser,
            time = os.time()
        }
        pcall(function()
            local res = request({
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

local function sendColoredSystemMessage(text, colorHex)
    local formattedText = string.format("<font color='%s'><b>%s</b></font>", colorHex, text)
    pcall(function()
        local channels = TextChatService:WaitForChild("TextChannels", 2)
        if channels and channels:FindFirstChild("RBXSystem") then
            channels.RBXSystem:DisplaySystemMessage(formattedText)
        end
    end)
end

local function isUserMutedLocally()
    local expire = mutedUsers[tostring(LocalPlayer.UserId)]
    if expire then
        if expire == 0 or os.time() < expire then
            return true, expire
        else
            mutedUsers[tostring(LocalPlayer.UserId)] = nil
        end
    end
    return false, 0
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
        stroke.Color = isVipSender and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 150, 255)
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
        nameLabel.TextColor3 = isVipSender and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 170, 255)
        
        local popupTitle = senderName
        if tostring(senderId) == "9202875847" then popupTitle = "[المطوره سـانا] 👑"
        elseif tostring(senderId) == "10545964840" then popupTitle = "[المطور سـاني] 👑"
        elseif isVipSender then popupTitle = senderName .. " 👑 [VIP]" end
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
        local data = {senderId = LocalPlayer.UserId, senderName = LocalPlayer.DisplayName, isTyping = isTyping}
        pcall(function()
            request({
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
    local isMuted, _ = isUserMutedLocally()
    if isMuted then return end
    local isTyping = (InputBox.Text ~= "")
    if isTyping ~= lastTypingState then
        lastTypingState = isTyping
        updateTypingStatus(isTyping)
    end
end)

local function sendMessage()
    local isMuted, _ = isUserMutedLocally()
    if isMuted then
        StarterGui:SetCore("SendNotification", {Title = "معطل بسبب الميوت ⏳", Text = "أنت معاقب بالميوت حالياً!", Duration = 3})
        return
    end
    if lastTypingState then
        lastTypingState = false
        updateTypingStatus(false)
    end
    local text = InputBox.Text
    if text ~= "" then
        InputBox.Text = ""
        sendData(text, false, nil, false)
        showBubbleChat(LocalPlayer.UserId, text)
    end
end

InputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then sendMessage() end
end)
SendButton.MouseButton1Click:Connect(sendMessage)

local isSpamming = false
SpamButton.MouseButton1Click:Connect(function()
    local isMuted, _ = isUserMutedLocally()
    if isMuted then return end
    if not isVipUser then
        StarterGui:SetCore("SendNotification", {Title = "اشتراك مطلوب 🔒", Text = "ميزة السبام مخصصة للمطورين!", Duration = 3})
        return
    end
    local text = InputBox.Text
    if text == "" then return end
    isSpamming = not isSpamming
    if isSpamming then
        SpamButton.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
        task.spawn(function()
            while isSpamming do
                sendData(text, false, nil, false)
                showBubbleChat(LocalPlayer.UserId, text)
                task.wait(0.05)
            end
        end)
    else
        SpamButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
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
        local isMuted, _ = isUserMutedLocally()
        if isMuted then return end
        if sticker.vip and not isVipUser then return end
        sendData(nil, true, sticker.id, false)
        StickerFrame.Visible = false
    end)
end

sendData(LocalPlayer.DisplayName .. " joined the chat!", false, nil, true)

local previousMuteStates = {}
local previousBanStates = {}

-- حلقة التحديث الفائقة السرعة لاستقبال رسائل الآخرين (0.08 ثانية)
task.spawn(function()
    while task.wait(0.08) do
        pcall(function()
            -- 1. تحديث المتواجدين ولوحة الإدارة
            local onlineResponse = request({ Url = ONLINE_URL, Method = "GET" })
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
                                
                                local isMutedTarget = mutedUsers[tostring(id)]
                                local isTargetMuteActive = isMutedTarget and (isMutedTarget == 0 or currentTime < isMutedTarget)

                                local muteBtn = Instance.new("TextButton")
                                muteBtn.Parent = row
                                muteBtn.Size = UDim2.new(0, 55, 0, 24)
                                muteBtn.Position = UDim2.new(1, -118, 0, 4)
                                muteBtn.BackgroundColor3 = isTargetMuteActive and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(80, 80, 80)
                                muteBtn.Text = isTargetMuteActive and "إلغاء ميوت" or "ميوت ⏳"
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
                                        StarterGui:SetCore("SendNotification", {Title = "إدارة الشات ✅", Text = "تم إلغاء الميوت عن المستخدم", Duration = 2})
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
                                                StarterGui:SetCore("SendNotification", {Title = "إدارة الشات ⏳", Text = "تم إعطاء ميوت للمستخدم", Duration = 2})
                                            end)
                                        end

                                        createDurationBtn("دقيقة واحدة (1m)", 60)
                                        createDurationBtn("5 دقائق (5m)", 300)
                                        createDurationBtn("ساعة كاملة (1h)", 3600)
                                        createDurationBtn("5 ساعات (5h)", 18000)
                                        
                                        local closeOpt = Instance.new("TextButton")
                                        closeOpt.Parent = MuteOptionsFrame
                                        closeOpt.Size = UDim2.new(0, 200, 0, 28)
                                        closeOpt.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
                                        closeOpt.Text = "إلغاء ❌"
                                        closeOpt.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        closeOpt.Font = Enum.Font.SourceSansBold
                                        closeOpt.TextSize = 12
                                        closeOpt.ZIndex = 21
                                        local cc = Instance.new("UICorner")
                                        cc.CornerRadius = UDim.new(0, 6)
                                        cc.Parent = closeOpt
                                        closeOpt.MouseButton1Click:Connect(function()
                                            MuteOptionsFrame.Visible = false
                                        end)
                                    end
                                end)

                                local isBanned = bannedUsers[tostring(id)] == true
                                local banBtn = Instance.new("TextButton")
                                banBtn.Parent = row
                                banBtn.Size = UDim2.new(0, 50, 0, 24)
                                banBtn.Position = UDim2.new(1, -58, 0, 4)
                                banBtn.BackgroundColor3 = isBanned and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(180, 40, 40)
                                banBtn.Text = isBanned and "إلغاء 🔓" or "طرد 🛑"
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

            -- 2. الفحوصات والحظر
            local bansResponse = request({ Url = BANS_URL, Method = "GET" })
            if bansResponse.Success and bansResponse.Body and bansResponse.Body ~= "null" then
                local bansData = HttpService:JSONDecode(bansResponse.Body)
                if type(bansData) == "table" then
                    for id, info in pairs(bansData) do
                        local wasBanned = previousBanStates[id]
                        if info.action == "ban" then
                            bannedUsers[tostring(id)] = true
                            if not wasBanned then
                                previousBanStates[id] = true
                                local targetName = info.targetName or ("مستخدم (" .. id .. ")")
                                sendColoredSystemMessage("تم طرد " .. targetName, "#FF0000")
                                if tostring(id) == tostring(LocalPlayer.UserId) then
                                    LocalPlayer:Kick("تم طردك من السيرفر من قبل المطور.")
                                end
                            end
                        elseif info.action == "unban" then
                            bannedUsers[tostring(id)] = nil
                            previousBanStates[id] = nil
                        end
                    end
                end
            end

            local mutesResponse = request({ Url = MUTES_URL, Method = "GET" })
            if mutesResponse.Success and mutesResponse.Body and mutesResponse.Body ~= "null" then
                local mutesData = HttpService:JSONDecode(mutesResponse.Body)
                if type(mutesData) == "table" then
                    for id, info in pairs(mutesData) do
                        if info.expireTime then mutedUsers[tostring(id)] = info.expireTime end
                    end
                end
            end

            -- 3. حالة الميوت وتحديث العداد الصغير القابل للسحب
            local isMuted, expireTime = isUserMutedLocally()
            local myUserIdStr = tostring(LocalPlayer.UserId)
            
            if isMuted then
                previousMuteStates[myUserIdStr] = true
                MuteTimerLabel.Visible = true
                
                if expireTime == 0 then
                    MuteTimerLabel.Text = "⏳ ميوت دائم (Permanent)"
                else
                    local remaining = expireTime - os.time()
                    if remaining > 0 then
                        local mins = math.floor(remaining / 60)
                        local secs = remaining % 60
                        MuteTimerLabel.Text = string.format("⏳ الميوت: %02d:%02d", mins, secs)
                    else
                        MuteTimerLabel.Visible = false
                        mutedUsers[myUserIdStr] = nil
                        sendColoredSystemMessage("مبروك تمت ازالة الميوت عنك", "#00FF00")
                    end
                end
            else
                if previousMuteStates[myUserIdStr] then
                    previousMuteStates[myUserIdStr] = nil
                    MuteTimerLabel.Visible = false
                    sendColoredSystemMessage("مبروك تمت ازالة الميوت عنك", "#00FF00")
                else
                    MuteTimerLabel.Visible = false
                end
            end

            -- 4. استقبال رسائل الآخرين الجديدة
            local response = request({ Url = FIREBASE_URL, Method = "GET" })
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
                                            addMessageToUI(msg.senderId, msg.senderName, msg.text, false, nil, true, Color3.fromRGB(255, 85, 85), msg.isVip)
                                        else
                                            addMessageToUI(msg.senderId, msg.senderName, msg.text, msg.isSticker, msg.stickerId, false, nil, msg.isVip)
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

            -- 5. مؤشر الكتابة السريع
            local typingResponse = request({ Url = TYPING_URL, Method = "GET" })
            if typingResponse.Success and typingResponse.Body and typingResponse.Body ~= "null" then
                local typingData = HttpService:JSONDecode(typingResponse.Body)
                if type(typingData) == "table" then
                    local typingUser = nil
                    for _, info in pairs(typingData) do
                        if info and info.isTyping == true and tostring(info.senderId) ~= tostring(LocalPlayer.UserId) then
                            local tMute = mutedUsers[tostring(info.senderId)]
                            local tMuteActive = tMute and (tMute == 0 or os.time() < tMute)
                            if not bannedUsers[tostring(info.senderId)] and not tMuteActive then
                                typingUser = info.senderName
                                break
                            end
                        end
                    end
                    if typingUser then TypingIndicatorLabel.Text = "✍️ " .. typingUser .. " يكتب الآن..."
                    else TypingIndicatorLabel.Text = "" end
                end
            else
                TypingIndicatorLabel.Text = ""
            end
        end)
    end
end)
