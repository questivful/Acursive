local ScriptViewer = {}
local window
local editor
local currentScript
local sspdo
local LuaUEngine

local function loadModule(url)
    local ok, result = pcall(function()
        local source = game:HttpGet(url)
        local chunk, err = loadstring(source)
        if not chunk then
            error("loadstring error: " .. tostring(err))
        end
        return chunk()
    end)
    if not ok then
        warn("[ScriptViewer] Failed to load " .. url .. ": " .. tostring(result))
        return nil
    end
    return result
end

local function ensureModules()
    if not sspdo then
        sspdo = loadModule("https://raw.githubusercontent.com/ruki3i/Creations/refs/heads/main/source/DockManager.luau")
    end
    if not LuaUEngine then
        LuaUEngine = loadModule("https://raw.githubusercontent.com/questivful/Acursive/refs/heads/main/ProjectLuaU5.1/LuaUEngine.luau")
    end
    if not sspdo then
        warn("[ScriptViewer] DockManager module unavailable")
        return false
    end
    if not LuaUEngine then
        warn("[ScriptViewer] LuaUEngine module unavailable")
        return false
    end
    return true
end

local function getBytecodeSafe(scriptInstance)
    if not scriptInstance then return nil end
    local success, bytecode = pcall(getscriptbytecode, scriptInstance)
    if success and type(bytecode) == "string" and #bytecode > 0 then
        return bytecode
    end
    if scriptInstance.GetBytecode then
        success, bytecode = pcall(scriptInstance.GetBytecode, scriptInstance)
        if success and type(bytecode) == "string" and #bytecode > 0 then
            return bytecode
        end
    end
    if scriptInstance.Bytecode then
        return scriptInstance.Bytecode
    end
    return nil
end

local function getRequestFunction()
    if syn and syn.request then return syn.request end
    if request then return request end
    if http_request then return http_request end
    if http and http.request then return http.request end
    if fluxus and fluxus.request then return fluxus.request end
    return nil
end

local function decompileWithAPI(scriptInstance)
    if not scriptInstance then
        return nil, "No script instance provided"
    end
    if not scriptInstance:IsA("LuaSourceContainer") then
        return nil, "Script is not a LuaSourceContainer"
    end
    local bytecode = getBytecodeSafe(scriptInstance)
    if not bytecode or #bytecode == 0 then
        return nil, "No bytecode found in script"
    end
    local reqFn = getRequestFunction()
    if not reqFn then
        return nil, "No request/http_request function available"
    end
    local success, response = pcall(reqFn, {
        Url = "https://api.luacid.dev/decompile?type_annotations=useful&indent=2",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/octet-stream"
        },
        Body = bytecode
    })
    if not success or not response then
        return nil, "Request failed: " .. tostring(response)
    end
    if typeof(response) == "string" then
        return response, nil
    end
    if typeof(response) == "table" then
        local status = response.StatusCode or response.Status or 0
        local body = response.Body or response.body
        if status == 200 and body and #body > 0 then
            return body, nil
        end
        return nil, "API returned status " .. tostring(status) .. ": " .. tostring(body or "")
    end
    return nil, "Unexpected response format"
end

local function readSourceSafe(scriptInstance)
    if not scriptInstance then return nil end
    local ok, src = pcall(function() return scriptInstance.Source end)
    if ok and type(src) == "string" and #src > 0 then
        return src
    end
    return nil
end

local function constructWindow(title, width, height)
    local constructor = sspdo.New or sspdo.new
    if not constructor then
        error("DockManager does not expose a New/new constructor")
    end
    local attempts = {
        function() return constructor(title, width, height) end,
        function() return constructor({ Title = title, Width = width, Height = height, Size = UDim2.fromOffset(width, height) }) end,
    }
    for _, attempt in ipairs(attempts) do
        local ok, result = pcall(attempt)
        if ok and result then
            return result
        end
    end
    error("Unable to construct DockManager window with any known signature")
end

function ScriptViewer.Init()
    if window then return window end
    if not ensureModules() then
        return nil
    end

    local ok, result = pcall(constructWindow, "Script Viewer", 650, 450)
    if not ok then
        warn("[ScriptViewer] Window construction failed: " .. tostring(result))
        return nil
    end
    window = result
    ScriptViewer.Window = window

    local contentPane = window.ContentPane
        or (window.GuiElems and window.GuiElems.Content)
        or window.Content
        or (window.GetContentPane and window:GetContentPane())
    if not contentPane then
        warn("[ScriptViewer] Could not find content pane in the dock window")
        return nil
    end

    local actionBar = Instance.new("Frame")
    actionBar.Name = "ActionBar"
    actionBar.Size = UDim2.new(1, 0, 0, 24)
    actionBar.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
    actionBar.BorderSizePixel = 0
    actionBar.Parent = contentPane

    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Horizontal
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 0)
    listLayout.Parent = actionBar

    local function createButton(name, text, order)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.LayoutOrder = order
        btn.Size = UDim2.new(0.2, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Text = text
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.AutoButtonColor = false
        btn.Parent = actionBar
        return btn
    end

    local btnCopy = createButton("CopyBtn", "Copy", 1)
    local btnSave = createButton("SaveBtn", "Save", 2)
    local btnExec = createButton("ExecuteBtn", "Execute", 3)
    local btnClear = createButton("ClearBtn", "Clear", 4)
    local btnDecompile = createButton("DecompileBtn", "Decompile", 5)

    local editorContainer = Instance.new("Frame")
    editorContainer.Name = "EditorContainer"
    editorContainer.Position = UDim2.new(0, 0, 0, 24)
    editorContainer.Size = UDim2.new(1, 0, 1, -24)
    editorContainer.BackgroundTransparency = 1
    editorContainer.Parent = contentPane

    local editorOk, editorInstance = pcall(function()
        return LuaUEngine.new(editorContainer)
    end)
    if not editorOk or not editorInstance then
        warn("[ScriptViewer] LuaUEngine.new failed: " .. tostring(editorInstance))
        return window
    end
    editor = editorInstance
    pcall(function() editor.ScrollBarTrackTransparency = 1 end)
    pcall(function() editor.ScrollBarStrokeTransparency = 1 end)
    pcall(function() editor.Font = Enum.Font.Code end)
    pcall(function() editor.StrokeThickness = 1.35 end)
    pcall(function() editor.StrokeColor3 = Color3.fromRGB(0, 0, 0) end)
    pcall(function() editor.StrokeTransparency = 0.75 end)
    pcall(function()
        editor:ImportTheme("https://raw.githubusercontent.com/ruki3i/Creations/refs/heads/main/source/LuaUTheme.luau")
    end)

    btnCopy.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(editor.Text)
        end
    end)

    btnSave.MouseButton1Click:Connect(function()
        if writefile then
            local filename = "ScriptViewer_" .. os.time() .. ".txt"
            if currentScript and currentScript.Name then
                filename = currentScript.Name .. "_" .. os.time() .. ".txt"
            end
            writefile(filename, editor.Text)
        end
    end)

    btnExec.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(editor.Text)()
        end)
    end)

    btnClear.MouseButton1Click:Connect(function()
        editor.Text = ""
    end)

    btnDecompile.MouseButton1Click:Connect(function()
        if not currentScript then
            editor.Text = "No script loaded to decompile"
            return
        end
        editor.Text = "Decompiling via luacid.dev...\nPlease wait..."
        task.spawn(function()
            local success, result = decompileWithAPI(currentScript)
            if success then
                editor.Text = "-- Decompiled via luacid.dev\n" .. result
            else
                editor.Text = "Decompilation failed: " .. (result or "Unknown error") .. "\n\nTrying local decompile as fallback...\n"
                if decompile and typeof(currentScript) == "Instance" and currentScript:IsA("LuaSourceContainer") then
                    local ok, localResult = pcall(decompile, currentScript)
                    if ok and localResult and #localResult > 0 then
                        editor.Text = editor.Text .. "\n-- Local decompile fallback result:\n" .. localResult
                    else
                        editor.Text = editor.Text .. "\nLocal decompile also failed"
                    end
                end
            end
        end)
    end)

    return window
end

function ScriptViewer.ViewScript(scriptInstance, customSource)
    if not window then
        if not ScriptViewer.Init() then
            warn("[ScriptViewer] Cannot view script; window failed to initialize")
            return
        end
    end
    if not editor then
        warn("[ScriptViewer] Editor unavailable; window may not have initialized correctly")
        return
    end

    currentScript = scriptInstance
    local name = scriptInstance and scriptInstance.Name or "Script"
    if window.SetTitle then
        pcall(function() window:SetTitle("Script Viewer - " .. name) end)
    end

    if customSource then
        editor.Text = customSource
        return
    end

    local direct = readSourceSafe(scriptInstance)
    if direct then
        editor.Text = direct
        return
    end

    editor.Text = "Loading script...\nAttempting decompile via luacid.dev..."
    task.spawn(function()
        local success, result = decompileWithAPI(scriptInstance)
        if success and result then
            editor.Text = "-- Decompiled via luacid.dev\n" .. result
            return
        end
        local fallbackMsg = "API decompile failed: " .. (result or "Unknown error") .. "\n\n"
        if decompile and typeof(scriptInstance) == "Instance" and scriptInstance:IsA("LuaSourceContainer") then
            local ok, localResult = pcall(decompile, scriptInstance)
            if ok and localResult and #localResult > 0 then
                editor.Text = fallbackMsg .. "-- Local decompile result:\n" .. localResult
                return
            end
        end
        editor.Text = fallbackMsg .. "No decompile method succeeded\nScript may be obfuscated or protected"
    end)
end

local function findAnimateScript()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    if not player then return nil end

    local character = player.Character
    if not character then
        local ok, newChar = pcall(function() return player.CharacterAdded:Wait() end)
        if ok then character = newChar end
    end
    if character then
        local animate = character:FindFirstChild("Animate")
        if animate then return animate end
    end

    local playerScripts = player:FindFirstChild("PlayerScripts")
    if playerScripts then
        local animate = playerScripts:FindFirstChild("Animate")
        if animate then return animate end
    end

    local scs = game:GetService("StarterCharacterScripts")
    return scs:FindFirstChild("Animate")
end

function ScriptViewer.ViewAnimateScript()
    local animateScript = findAnimateScript()
    if not animateScript then
        warn("[ScriptViewer] No Animate script found in Character, PlayerScripts, or StarterCharacterScripts")
        return
    end
    ScriptViewer.ViewScript(animateScript)
end

return ScriptViewer
