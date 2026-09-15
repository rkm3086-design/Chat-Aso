local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Chat = game:GetService("Chat")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
 
local FIREBASE_URL = "https://micychat-f41e8-default-rtdb.firebaseio.com/messages.json"
local SessionStartTime = os.time()
 
-- 🔊 صوت التنبيه (صوت يشبه إشعار بلايستيشن)
local JoinSound = Instance.new("Sound")
JoinSound.Name = "JoinNotificationSound"
JoinSound.SoundId = "rbxassetid://4590662766"
JoinSound.Volume = 1
JoinSound.Parent = SoundService
 
-- 🎨 قائمة الملصقات
local STICKERS_LIST = {
    {name = "مساء التوت", id = "rbxassetid://74216313680636"},
    {name = "Cool", id = "rbxassetid://6023426920"},
    {name = "Laugh", id = "rbxassetid://6023427021"}
}
 
-- Welcome Notification
StarterGui:SetCore("SendNotification", {
    Title = "Micy Chat v3.8.7";
    Text = "Welcome " .. LocalPlayer.DisplayName .. "!";
    Duration = 5;
})
 
-- ScreenGui Parent
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MicyChatGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")
 
-- 🎮 حاوية إشعارات البلايستيشن (فوق على اليمين أو الجنب بشكل صغير ومناسب)
local PopupHolder = Instance.new("Frame")
PopupHolder.Name = "PS4PopupHolder"
PopupHolder.Parent = ScreenGui
PopupHolder.BackgroundTransparency = 1
PopupHolder.Position = UDim2.new(1, -280, 0, 20)
PopupHolder.Size = Instance.new("Frame") and UDim2.new(0, 260, 0, 200)
 
local PopupLayout = Instance.new("UIListLayout")
PopupLayout.Parent = PopupHolder
PopupLayout.SortOrder = Enum.SortOrder.LayoutOrder
PopupLayout.VerticalAlignment = Enum.VerticalAlignment.Top
PopupLayout.Padding = UDim.new(0, 8)
 
-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.35
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 380, 0, 260)
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
Title.Text = "⚡ Micy Chat v3.8.7"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
 
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title
 
-- Scroll Area for Messages
local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = MainFrame
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.Size = UDim2.new(1, -20, 0, 135)
Scroll.BackgroundTransparency = 0.95
Scroll.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 5
 
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Scroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
 
-- دالة النزول للأسفل تلقائياً وتحديث الـ CanvasSize
local function scrollToBottom()
    Scroll.CanvasPosition = Vector2.new(0, Scroll.AbsoluteCanvasSize.Y)
end
 
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    scrollToBottom()
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
InputBox.Size = UDim2.new(0, 175, 0, 38)
InputBox.PlaceholderText = "اكتب هنا..."
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
 
-- Sticker Menu Button
local StickerMenuBtn = Instance.new("TextButton")
StickerMenuBtn.Parent = MainFrame
StickerMenuBtn.Position = UDim2.new(0, 195, 0, 210)
StickerMenuBtn.Size = UDim2.new(0, 45, 0, 38)
StickerMenuBtn.Text = "🖼️"
StickerMenuBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
StickerMenuBtn.BackgroundTransparency = 0.3
StickerMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StickerMenuBtn.Font = Enum.Font.SourceSansBold
StickerMenuBtn.TextSize = 16
 
local StickerCorner = Instance.new("UICorner")
StickerCorner.CornerRadius = UDim.new(0, 8)
StickerCorner.Parent = StickerMenuBtn
 
-- Send Button
local SendButton = Instance.new("TextButton")
SendButton.Parent = MainFrame
SendButton.Position = UDim2.new(0, 248, 0, 210)
SendButton.Size = UDim2.new(0, 122, 0, 38)
SendButton.Text = "إرسال"
SendButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SendButton.BackgroundTransparency = 0.3
SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SendButton.Font = Enum.Font.SourceSansBold
SendButton.TextSize = 15
 
local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 8)
SendCorner.Parent = SendButton
 
-- Stickers Frame
local StickerFrame = Instance.new("Frame")
StickerFrame.Parent = MainFrame
StickerFrame.Position = UDim2.new(0, 195, 0, 45)
StickerFrame.Size = UDim2.new(0, 175, 0, 140)
StickerFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
StickerFrame.BackgroundTransparency = 0.2
StickerFrame.Visible = false
 
local StickerFrameCorner = Instance.new("UICorner")
StickerFrameCorner.CornerRadius = UDim.new(0, 10)
StickerFrameCorner.Parent = StickerFrame
 
local StickerGrid = Instance.new("UIGridLayout")
StickerGrid.Parent = StickerFrame
StickerGrid.CellSize = UDim2.new(0, 45, 0, 45)
StickerGrid.CellPadding = UDim2.new(0, 8, 0, 8)
 
StickerMenuBtn.MouseButton1Click:Connect(function()
    StickerFrame.Visible = not StickerFrame.Visible
end)
 
-- Toggle Button (Side Bar)
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
 
-- Dynamic Color Animation
task.spawn(function()
    local colors = {
        Color3.fromRGB(46, 204, 113),
        Color3.fromRGB(241, 196, 15),
        Color3.fromRGB(255, 255, 255)
    }
    local t = 0
    while true do
        local delta = RunService.RenderStepped:Wait()
        t = (t + delta * 0.8) % #colors
        local index = math.floor(t) + 1
        local nextIndex = (index % #colors) + 1
        local alpha = t - math.floor(t)
        local currentColor = colors[index]:Lerp(colors[nextIndex], alpha)
        UIStroke.Color = currentColor
        ToggleStroke.Color = currentColor
    end
end)
 
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
 
-- 🎮 تصميم إشعار البلايستيشن الصغير والأنيق
local function showSidePopup(senderId, senderName, text, isSticker, stickerId)
    task.spawn(function()
        local popup = Instance.new("Frame")
        popup.Parent = PopupHolder
        popup.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        popup.BackgroundTransparency = 0.2
        popup.Size = UDim2.new(0, 260, 0, 65)
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = popup
        
        local stroke = Instance.new("UIStroke")
        stroke.Parent = popup
        stroke.Color = Color3.fromRGB(0, 150, 255)
        stroke.Thickness = 1.5
        
        -- الأفاتار الصغير على جنب الإشعار
        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Parent = popup
        avatarImg.Position = UDim2.new(0, 10, 0, 10)
        avatarImg.Size = UDim2.new(0, 45, 0, 45)
        avatarImg.BackgroundTransparency = 1
        avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(senderId) .. "&w=420&h=420"
        
        local avatarCorner = Instance.new("UICorner")
        avatarCorner.CornerRadius = UDim.new(1, 0)
        avatarCorner.Parent = avatarImg
        
        -- اسم المرسل
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = popup
        nameLabel.Position = UDim2.new(0, 65, 0, 8)
        nameLabel.Size = UDim2.new(1, -75, 0, 18)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 13
        nameLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
        nameLabel.Text = "رسالة جديدة من: " .. senderName
        
        if isSticker then
            local label = Instance.new("TextLabel")
            label.Parent = popup
            label.Position = UDim2.new(0, 65, 0, 28)
            label.Size = UDim2.new(1, -75, 0, 25)
            label.BackgroundTransparency = 1
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.SourceSans
            label.TextSize = 13
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.Text = "أرسل ملصقاً 🖼️"
        else
            local contentLabel = Instance.new("TextLabel")
            contentLabel.Parent = popup
            contentLabel.Position = UDim2.new(0, 65, 0, 26)
            contentLabel.Size = UDim2.new(1, -75, 0, 32)
            contentLabel.BackgroundTransparency = 1
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.TextYAlignment = Enum.TextYAlignment.Top
            contentLabel.Font = Enum.Font.SourceSans
            contentLabel.TextSize = 12
            contentLabel.TextWrapped = true
            contentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            contentLabel.Text = text or ""
        end
        
        -- الانتظار 3.5 ثانية ثم اختفاء الإشعار بسلاسة
        task.wait(3.5)
        
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(popup, tweenInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(stroke, tweenInfo, {Transparency = 1}):Play()
        TweenService:Create(avatarImg, tweenInfo, {ImageTransparency = 1}):Play()
        TweenService:Create(nameLabel, tweenInfo, {TextTransparency = 1}):Play()
        
        for _, child in pairs(popup:GetChildren()) do
            if child:IsA("TextLabel") then
                TweenService:Create(child, tweenInfo, {TextTransparency = 1}):Play()
            end
        end
        
        task.wait(0.5)
        popup:Destroy()
    end)
end
 
-- 💬 نظام عرض الرسائل داخل الشات
local function addMessageToUI(senderId, senderName, text, isSticker, stickerId, isSystem, systemColor)
    local container = Instance.new("Frame")
    container.Parent = Scroll
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
 
    if isSystem then
        container.Size = UDim2.new(1, 0, 0, 25)
        local nameLabel = Instance.new("TextButton")
        nameLabel.Parent = container
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 13
        nameLabel.TextColor3 = systemColor or Color3.fromRGB(255, 215, 0)
        nameLabel.Text = "[System]: " .. (text or "")
        nameLabel.AutoButtonColor = false
    else
        local isMe = (tostring(senderId) == tostring(LocalPlayer.UserId))
        
        local msgWrapper = Instance.new("Frame")
        msgWrapper.Parent = container
        msgWrapper.BackgroundTransparency = 1
        msgWrapper.Size = UDim2.new(0, 300, 0, 0)
        msgWrapper.AutomaticSize = Enum.AutomaticSize.Y
        msgWrapper.Position = isMe and UDim2.new(1, -310, 0, 0) or UDim2.new(0, 10, 0, 0)
 
        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Parent = msgWrapper
        avatarImg.Position = isMe and UDim2.new(1, -26, 0, 0) or UDim2.new(0, 0, 0, 0)
        avatarImg.Size = UDim2.new(0, 26, 0, 26)
        avatarImg.BackgroundTransparency = 1
        avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(senderId) .. "&w=420&h=420"
        
        local avatarCorner = Instance.new("UICorner")
        avatarCorner.CornerRadius = UDim.new(1, 0)
        avatarCorner.Parent = avatarImg
 
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Parent = msgWrapper
        nameLbl.Position = isMe and UDim2.new(0, 0, 0, 4) or UDim2.new(0, 32, 0, 4)
        nameLbl.Size = UDim2.new(1, -35, 0, 18)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.SourceSansBold
        nameLbl.TextSize = 12
        nameLbl.TextColor3 = isMe and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(180, 180, 180)
        nameLbl.TextXAlignment = isMe and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
        nameLbl.Text = senderName
 
        local bubble = Instance.new("Frame")
        bubble.Parent = msgWrapper
        bubble.Position = UDim2.new(0, 0, 0, 30)
        bubble.Size = UDim2.new(1, 0, 0, 0)
        bubble.AutomaticSize = Enum.AutomaticSize.Y
        bubble.BackgroundColor3 = isMe and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(35, 35, 35)
        bubble.BackgroundTransparency = 0.2
 
        local bubbleCorner = Instance.new("UICorner")
        bubbleCorner.CornerRadius = UDim.new(0, 10)
        bubbleCorner.Parent = bubble
 
        if isSticker then
            bubble.Size = UDim2.new(0, 110, 0, 110)
            local img = Instance.new("ImageLabel")
            img.Parent = bubble
            img.Position = UDim2.new(0, 5, 0, 5)
            img.Size = UDim2.new(1, -10, 1, -10)
            img.BackgroundTransparency = 1
            img.Image = stickerId
        else
            local textBtn = Instance.new("TextButton")
            textBtn.Parent = bubble
            textBtn.Position = UDim2.new(0, 8, 0, 6)
            textBtn.Size = UDim2.new(1, -16, 1, -12)
            textBtn.AutomaticSize = Enum.AutomaticSize.Y
            textBtn.BackgroundTransparency = 1
            textBtn.TextXAlignment = Enum.TextXAlignment.Left
            textBtn.TextYAlignment = Enum.TextYAlignment.Top
            textBtn.Font = Enum.Font.SourceSans
            textBtn.TextSize = 14
            textBtn.TextWrapped = true
            textBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            textBtn.Text = text or ""
 
            textBtn.MouseButton1Click:Connect(function()
                if setclipboard then
                    setclipboard(text or "")
                    StarterGui:SetCore("SendNotification", {
                        Title = "تم النسخ 📋";
                        Text = "تم نسخ الرسالة";
                        Duration = 2;
                    })
                end
            end)
        end
    end
end
 
-- Chat Bubble Display
local function showBubbleChat(senderId, text)
    local targetPlayer = Players:GetPlayerByUserId(tonumber(senderId))
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        pcall(function()
            Chat:Chat(targetPlayer.Character.Head, text, Enum.ChatColor.White)
        end)
    end
end
 
-- Send Request Function
local function sendData(text, isSticker, stickerId, isSystem)
    task.spawn(function()
        local data = {
            senderId = LocalPlayer.UserId,
            senderName = LocalPlayer.DisplayName,
            text = text or "",
            isSticker = isSticker or false,
            stickerId = stickerId or "",
            isSystem = isSystem or false,
            time = os.time()
        }
        local json = HttpService:JSONEncode(data)
        pcall(function()
            request({
                Url = FIREBASE_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = json
            })
        end)
    end)
end
 
-- Send Typing Status
local function updateTypingStatus(isTyping)
    task.spawn(function()
        local data = {
            senderId = LocalPlayer.UserId,
            senderName = LocalPlayer.DisplayName,
            isTyping = isTyping
        }
        local json = HttpService:JSONEncode(data)
        pcall(function()
            request({
                Url = "https://micychat-f41e8-default-rtdb.firebaseio.com/typing/" .. LocalPlayer.UserId .. ".json",
                Method = "PUT",
                Headers = {["Content-Type"] = "application/json"},
                Body = json
            })
        end)
    end)
end
 
-- Typing Triggers
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
        addMessageToUI(LocalPlayer.UserId, LocalPlayer.DisplayName, text, false, nil, false)
        showBubbleChat(LocalPlayer.UserId, text)
        sendData(text, false, nil, false)
    end
end
 
InputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        sendMessage()
    end
end)
 
SendButton.MouseButton1Click:Connect(sendMessage)
 
-- Populate Stickers UI
for _, sticker in pairs(STICKERS_LIST) do
    local letBtn = Instance.new("ImageButton")
    letBtn.Parent = StickerFrame
    letBtn.Image = sticker.id
    letBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    letBtn.BackgroundTransparency = 0.5
 
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = letBtn
 
    letBtn.MouseButton1Click:Connect(function()
        addMessageToUI(LocalPlayer.UserId, LocalPlayer.DisplayName, nil, true, sticker.id, false)
        sendData(nil, true, sticker.id, false)
        StickerFrame.Visible = false
    end)
end
 
-- Join Notification
sendData(LocalPlayer.DisplayName .. " joined the chat!", false, nil, true)
 
-- Real-Time Receiver Loop
local loadedKeys = {}
task.spawn(function()
    while task.wait(0.8) do
        pcall(function()
            local response = request({ Url = FIREBASE_URL, Method = "GET" })
            if response.Success and response.Body and response.Body ~= "null" then
                local data = HttpService:JSONDecode(response.Body)
                if type(data) == "table" then
                    for key, msg in pairs(data) do
                        if not loadedKeys[key] then
                            loadedKeys[key] = true
                            if msg.time and msg.time >= SessionStartTime then
                                if tostring(msg.senderId) ~= tostring(LocalPlayer.UserId) then
                                    if msg.isSystem then
                                        addMessageToUI(msg.senderId, msg.senderName, msg.text, false, nil, true, Color3.fromRGB(255, 85, 85))
                                        JoinSound:Play()
                                    else
                                        JoinSound:Play()
                                        addMessageToUI(msg.senderId, msg.senderName, msg.text, msg.isSticker, msg.stickerId, false)
                                        showSidePopup(msg.senderId, msg.senderName, msg.text, msg.isSticker, msg.stickerId)
                                        if not msg.isSticker and msg.text then
                                            showBubbleChat(msg.senderId, msg.text)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
 
            -- فحص ومراقبة مؤشر الكتابة
            local typingResponse = request({ Url = "https://micychat-f41e8-default-rtdb.firebaseio.com/typing.json", Method = "GET" })
            if typingResponse.Success and typingResponse.Body and typingResponse.Body ~= "null" then
                local typingData = HttpService:JSONDecode(typingResponse.Body)
                if type(typingData) == "table" then
                    local typingUser = nil
                    for _, info in pairs(typingData) do
                        if info and info.isTyping and tostring(info.senderId) ~= tostring(LocalPlayer.UserId) then
                            typingUser = info.senderName
                            break
                        end
                    end
                    if typingUser then
                        TypingIndicatorLabel.Text = "✍️ " .. typingUser .. " يكتب الآن..."
                    else
                        TypingIndicatorLabel.Text = ""
                    end
                end
            end
        end)
    end
end)
