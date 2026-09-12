-- Micy Chat v3.0 (Fixed Real-Time Multi-Player Sync)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Chat = game:GetService("Chat")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local FIREBASE_URL = "https://micychat-f41e8-default-rtdb.firebaseio.com/messages.json"
local SessionStartTime = os.time()

-- Welcome Notification
StarterGui:SetCore("SendNotification", {
    Title = "Micy Chat v3.0";
    Text = "Welcome " .. LocalPlayer.DisplayName .. "!";
    Duration = 5;
})

-- ScreenGui Parent
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MicyChatGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.15
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 360, 0, 260)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Thickness = 2.5
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.BackgroundTransparency = 0.2
Title.Text = "⚡ Micy Chat v3.0"
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
Scroll.Size = UDim2.new(1, -20, 0, 155)
Scroll.BackgroundTransparency = 0.85
Scroll.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollBarThickness = 6

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 8)
ScrollCorner.Parent = Scroll

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Scroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Text Input Box
local InputBox = Instance.new("TextBox")
InputBox.Parent = MainFrame
InputBox.Position = UDim2.new(0, 10, 0, 210)
InputBox.Size = UDim2.new(0, 250, 0, 38)
InputBox.PlaceholderText = "Type message..."
InputBox.Text = ""
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
InputBox.BackgroundTransparency = 0.3
InputBox.Font = Enum.Font.SourceSans
InputBox.TextSize = 14

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = InputBox

-- Send Button
local SendButton = Instance.new("TextButton")
SendButton.Parent = MainFrame
SendButton.Position = UDim2.new(0, 268, 0, 210)
SendButton.Size = UDim2.new(0, 82, 0, 38)
SendButton.Text = "Send"
SendButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SendButton.BackgroundTransparency = 0.2
SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SendButton.Font = Enum.Font.SourceSansBold
SendButton.TextSize = 15

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 8)
SendCorner.Parent = SendButton

-- Vertical Side Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0, 5, 0.5, -80)
ToggleButton.Size = UDim2.new(0, 38, 0, 160)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.BackgroundTransparency = 0.4
ToggleButton.Text = "C\nH\nA\nT"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.SourceSansBold

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Parent = ToggleButton
ToggleStroke.Thickness = 2.5

-- 🌈 Dynamic Color Cycle (Green 🟢 -> Yellow 🟡 -> White ⚪)
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

-- Toggle Event
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Display Message UI
local function addMessageToUI(senderName, text, isSystem, systemColor)
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Parent = Scroll
    msgLabel.Size = UDim2.new(1, 0, 0, 20)
    msgLabel.BackgroundTransparency = 1
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Font = Enum.Font.SourceSans
    msgLabel.TextSize = 14
    
    if isSystem then
        msgLabel.TextColor3 = systemColor or Color3.fromRGB(255, 215, 0)
        msgLabel.Text = "[System]: " .. text
    else
        msgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        msgLabel.Text = "[" .. senderName .. "]: " .. text
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
local function sendData(text, isSystem)
    task.spawn(function()
        local data = {
            senderId = LocalPlayer.UserId,
            senderName = LocalPlayer.DisplayName,
            text = text,
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
        addMessageToUI(LocalPlayer.DisplayName, text)
        showBubbleChat(LocalPlayer.DisplayName, text)
        sendData(text, false)
    end
end

SendButton.MouseButton1Click:Connect(sendMessage)
InputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        sendMessage()
    end
end)

-- Join Notification
sendData(LocalPlayer.DisplayName .. " joined the chat!", true)

-- Real-Time Receiver Loop (تم تصحيح استقبال ورؤية الرسائل)
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
                            -- التحقق عن طريق الـ UserId لضمان استقبال رسائل الشخص الآخر فقط
                            if msg.senderId ~= LocalPlayer.UserId then
                                if msg.isSystem then
                                    addMessageToUI(msg.senderName, msg.text, true, Color3.fromRGB(85, 255, 127))
                                else
                                    addMessageToUI(msg.senderName, msg.text)
                                    showBubbleChat(msg.senderName, msg.text)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
