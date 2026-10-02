local sspdo = loadstring(game:HttpGet("https://raw.githubusercontent.com/ruki3i/Creations/refs/heads/main/source/DockManager.luau"))()
local LuaUEngine = loadstring(game:HttpGet("https://raw.githubusercontent.com/questivful/Acursive/refs/heads/main/ProjectLuaU5.1/LuaUEngine.luau"))()

local ScriptViewer = {}
local window
local editor
local currentScript

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
        return nil, "No request/http_request function available in this executor"
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

function ScriptViewer.Init()
    window = sspdo.new("Script Viewer", 650, 450)
    ScriptViewer.Window = window

    local contentPane = window.GuiElems.Content

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

    local btnCopy = createButton("CopyBtn", "Copy to Clipboard", 1)
    local btnSave = createButton("SaveBtn", "Save to File", 2)
    local btnExec = createButton("ExecuteBtn", "Execute", 3)
    local btnClear = createButton("ClearBtn", "Clear", 4)
    local btnDecompile = createButton("DecompileBtn", "Decompile", 5)

    local editorContainer = Instance.new("Frame")
    editorContainer.Name = "EditorContainer"
    editorContainer.Position = UDim2.new(0, 0, 0, 24)
    editorContainer.Size = UDim2.new(1, 0, 1, -24)
    editorContainer.BackgroundTransparency = 1
    editorContainer.Parent = contentPane

    editor = LuaUEngine.new(editorContainer)
    editor.ScrollBarTrackTransparency = 1
    editor.ScrollBarStrokeTransparency = 1
    editor.Font = Enum.Font.Code
    editor.StrokeThickness = 1.35
    editor.StrokeColor3 = Color3.fromRGB(0, 0, 0)
    editor.StrokeTransparency = 0.75
    editor:ImportTheme("https://raw.githubusercontent.com/ruki3i/Creations/refs/heads/main/source/LuaUTheme.luau")

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
end

function ScriptViewer.ViewScript(scriptInstance, customSource)
    if not window then
        ScriptViewer.Init()
    end

    currentScript = scriptInstance
    local name = scriptInstance and scriptInstance.Name or "Script"
    window:SetTitle("Script Viewer - " .. name)

    if customSource then
        editor.Text = customSource
    else
        editor.Text = "Loading script...\nAttempting decompile via luacid.dev..."

        task.spawn(function()
            local success, result = decompileWithAPI(scriptInstance)
            if success and result then
                editor.Text = "-- Decompiled via luacid.dev\n" .. result
            else
                local fallbackMsg = "API decompile failed: " .. (result or "Unknown error") .. "\n\n"

                if decompile and typeof(scriptInstance) == "Instance" and scriptInstance:IsA("LuaSourceContainer") then
                    local ok, localResult = pcall(decompile, scriptInstance)
                    if ok and localResult and #localResult > 0 then
                        editor.Text = fallbackMsg .. "-- Local decompile result:\n" .. localResult
                    else
                        editor.Text = fallbackMsg .. "Local decompile also failed\nScript may be obfuscated or protected"
                    end
                else
                    editor.Text = fallbackMsg .. "No decompile function available"
                end
            end
        end)
    end

    window:Show()
end

function ScriptViewer.ViewAnimateScript()
    local player = game.Players.LocalPlayer
    if not player then
        warn("No local player found")
        return
    end

    local character = player.Character
    if not character then
        character = player.CharacterAdded:Wait()
    end

    local animateScript = character:FindFirstChild("Animate")
    if not animateScript then
        animateScript = game:GetService("StarterCharacterScripts"):FindFirstChild("Animate")
        if not animateScript then
            warn("No Animate script found")
            return
        end
    end

    ScriptViewer.ViewScript(animateScript)
end

return ScriptViewer
