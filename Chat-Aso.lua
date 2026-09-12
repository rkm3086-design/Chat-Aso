-- Micy Chat v3.6 (Transparent, Universal, Copyable & Sound)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Chat = game:GetService("Chat")
local RunService = game:GetService("RunService")
local InsertService = game:GetService("InsertService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

local FIREBASE_URL = "https://micychat-f41e8-default-rtdb.firebaseio.com/messages.json"
local SessionStartTime = os.time()

-- 🔊 صوت التنبيه
local JoinSound = Instance.new("Sound")
JoinSound.Name = "JoinNotificationSound"
JoinSound.SoundId = "rbxassetid://4590662766"
JoinSound.Volume = 1
JoinSound.Parent = SoundService

-- 🎨 دالة تحويل الـ Decal ID
local function getTextureId(assetId)
    local rawId = tostring(assetId):match("%d+")
    if not rawId then return "" end
    
    local success, result = pcall(function()
        local model = InsertService:LoadAsset(tonumber(rawId))
        local decal = model:FindFirstChildOfClass("Decal")
        local texture = decal and decal.Texture or ""
        model:Destroy()
        return texture
    end)
    
    if success and result ~= "" then
        return result
    else
        return "rbxassetid://" .. rawId
    end
end

-- 🎨 قائمة الملصقات
local STICKERS_RAW = {
    {name = "مساء التوت", id = "74216313680636"},
    {name = "Cool", id = "6023426920"},
    {name = "Laugh", id = "6023427021"}
}

local STICKERS_LIST = {}
for _, s in ipairs(STICKERS_RAW) do
    table.insert(STICKERS_LIST, {
        name = s.name,
        id = getTextureId(s.id)
    })
end

-- Welcome Notification
StarterGui:SetCore("SendNotification", {
    Title = "Micy Chat v3.6";
    Text = "Welcome " .. LocalPlayer.DisplayName .. "!";
    Duration = 5;
})

-- ScreenGui Parent (يعمل على جميع المابات)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MicyChatGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Frame (شفافية أعلى ليكون أخف وأجمل)
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

-- Title Bar (شفافية خفيفة)
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.BackgroundTransparency = 0.4
Title.Text = "⚡ Micy Chat v3.6"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Scroll Area for Messages (أكثر شفافية)
local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = MainFrame
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.Size = UDim2.new(1, -20, 0, 155)
Scroll.BackgroundTransparency = 0.95
Scroll.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollBarThickness = 5

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Scroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Text Input Box (أكتب هنا - شفاف وخفيف)
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
StickerFrame.Size = UDim2.new(0, 175, 0, 155)
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
ToggleButton.Position = UDim2.new(0, 5, 0.5, -80)
ToggleButton.Size = UDim2.new(0, 38, 0, 160)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.BackgroundTransparency = 0.5
ToggleButton.Text = "C\nH\nA\nT"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
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

-- Display Functions with Copy feature
local function addMessageToUI(senderName, text, isSticker, stickerId, isSystem, systemColor)
    local container = Instance.new("Frame")
    container.Parent = Scroll
    container.BackgroundTransparency = 1
    
    local nameLabel = Instance.new("TextButton")
    nameLabel.Parent = container
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.TextSize = 14
    nameLabel.TextWrapped = true
    
    if isSystem then
        container.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.TextColor3 = systemColor or Color3.fromRGB(255, 215, 0)
        nameLabel.Text = "[System]: " .. (text or "")
        nameLabel.AutoButtonColor = false
    elseif isSticker then
        container.Size = UDim2.new(1, 0, 0, 65)
        nameLabel.Size = UDim2.new(1, 0, 0, 15)
        nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        nameLabel.Text = "[" .. senderName .. "]:"
        nameLabel.AutoButtonColor = false
        
        local img = Instance.new("ImageLabel")
        img.Parent = container
        img.Position = UDim2.new(0, 10, 0, 18)
        img.Size = UDim2.new(0, 45, 0, 45)
        img.BackgroundTransparency = 1
        img.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        img.Image = stickerId
    else
        container.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        local fullText = "[" .. senderName .. "]: " .. (text or "")
        nameLabel.Text = fullText
        
        -- نسخ النص عند الضغط على الرسالة
        nameLabel.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(text or "")
                StarterGui:SetCore("SendNotification", {
                    Title = "تم النسخ 📋";
                    Text = "تم نسخ الرسالة: " .. (text or "");
                    Duration = 2;
                })
            end
        end)
    end
    
    Scroll.CanvasPosition = Vector2.new(0, Scroll.AbsoluteCanvasSize.Y)
end

-- Chat Bubble Display
local function showBubbleChat(senderName, text)
    for _, player in pairs(Players:GetPlayers()) do
        if player.DisplayName == senderName or player.Name == senderName then
            if player.Character and player.Character:FindFirstChild("Head") then
                pcall(function()
                    Chat:Chat(player.Character.Head, text, Enum.ChatColor.White)
                end)
            end
        end
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
        request({
            Url = FIREBASE_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    end)
end

local function sendMessage()
    local text = InputBox.Text
    if text ~= "" then
        InputBox.Text = ""
        addMessageToUI(LocalPlayer.DisplayName, text, false, nil, false)
        showBubbleChat(LocalPlayer.DisplayName, text)
        sendData(text, false, nil, false)
    end
end

-- Populate Stickers UI
for _, sticker in pairs(STICKERS_LIST) do
    local btn = Instance.new("ImageButton")
    btn.Parent = StickerFrame
    btn.Image = sticker.id
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BackgroundTransparency = 0.5
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        addMessageToUI(LocalPlayer.DisplayName, nil, true, sticker.id, false)
        sendData(nil, true, sticker.id, false)
        StickerFrame.Visible = false
    end)
end

SendButton.MouseButton1Click:Connect(sendMessage)
InputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then sendMessage() end
end)

-- Join Notification
sendData(LocalPlayer.DisplayName .. " joined the chat!", false, nil, true)

-- Real-Time Receiver Loop
local loadedKeys = {}
task.spawn(function()
    while task.wait(0.5) do
        local response = request({
            Url = FIREBASE_URL,
            Method = "GET"
        })
        if response.Success and response.Body and response.Body ~= "null" then
            local success, data = pcall(function()
                return HttpService:JSONDecode(response.Body)
            end)
            
            if success and type(data) == "table" then
                for key, msg in pairs(data) do
                    if not loadedKeys[key] then
                        loadedKeys[key] = true
                        if msg.time and msg.time >= SessionStartTime then
                            if msg.senderId ~= LocalPlayer.UserId then
                                if msg.isSystem then
                                    addMessageToUI(msg.senderName, msg.text, false, nil, true, Color3.fromRGB(85, 255, 127))
                                    JoinSound:Play()
                                    StarterGui:SetCore("SendNotification", {
                                        Title = "Micy Chat 🔔";
                                        Text = msg.text or "شخص ما انضم للدردشة!";
                                        Duration = 4;
                                    })
                                else
                                    -- 🔊 تشغيل صوت "طن" فور وصول رسالة الصديق
                                    JoinSound:Play()
                                    
                                    addMessageToUI(msg.senderName, msg.text, msg.isSticker, msg.stickerId, false)
                                    if not msg.isSticker and msg.text then
                                        showBubbleChat(msg.senderName, msg.text)
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
