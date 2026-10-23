-- logs_webhook is NOT set here: it is read from the global set before the loadstring (logs_webhook = "..." ; loadstring(...)())

Config = {
    Team = "Pirates",
    Configuration = {
        HopWhenIdle = true,
        AutoHop = true,
        AutoHopDelay = 60 * 60,
        FpsBoost = true,
        blackscreen = false,
        LowGraphics = true
    },
    Items = {
        AutoFullyMelees = true,
        Saber = true,
        CursedDualKatana = true,
        SoulGuitar = true,
        RaceV2 = true,
        AutoRaceV3 = true,
        AutoRandomFruit = true,
    },
    Sword = {
        ["Shark Saw"]        = true,
        ["Wardens Sword"]    = true,
        ["Pole (1st Form)"]  = true,
        ["Gravity Blade"]    = true,
        ["Longsword"]        = true,
        ["Rengoku"]          = true,
        ["Flail"]            = true,
        ["Twin Hooks"]       = true,
    },
    BossWeapons = {
        ["Awakened Ice Admiral"] = true,
        ["Tide Keeper"]          = true,
        ["Deandre"]              = true,
        ["Urban"]                = true,
        ["Diablo"]               = true,
        ["Soul Reaper"]          = true,
        ["Cake Prince"]          = true,
        ["Core"]                 = true,
        ["Darkbeard"]            = true,
        ["Katakuri"]             = true,
        ["Beautiful Pirates"]    = true,
    },
    Melee = {
        AutoBuy              = true,
        CheckMasteryAfterBuy = true,
        RaidAtV1Mastery      = 500,
        GodhumanAtV2Mastery  = 400,
    },
    AutoKen = true,
    BringMobs = true,
    PanicMode = {
        Enabled          = true,
        LowHealthPercent = 20,
        SafeHealthPercent = 75,
        EscapeHeight     = 2000,
        CheckInterval    = 1,
        MaxHideSeconds   = 40,   -- never hide longer than this, even if health has not fully recovered
    },
    Settings = {
        StayInSea2UntilHaveDarkFragments = true
    },
    AutoSea2 = true,
    AutoSea3 = true,
    AutoRaidIce_TargetFragments = 5000,
    Dashboard = {
        UIName = "flowbr | kaitun",
        Subtitle = "ACCOUNT DASHBOARD",
    
        -- Configure HERE in the code (the UI has no customization fields anymore).
        -- Use just the number (e.g. "1234567890") or "rbxassetid://1234567890"
        ToggleImage = "139193750942654",        -- icon of the open/close button (empty = letter F)
        BackgroundImage = "130143515695779",    -- UI background (empty = plain black)
        BackgroundDim = 0.45,    -- dims the background when an image is set (0 = no dimming)
    
        RefreshInterval = 10,    -- seconds between account reads
        MaxLevel = 2800,         -- current max level (shows "(MAX)" when reached)
    
        Scale = 0.56,            -- size of the dashboard window (0.3 = tiny, 1 = original size)
        ToggleSize = 40,         -- size of the round open/close button (pixels)

        Webhook = {
            Enabled = true,
            Url = logs_webhook or (getgenv and getgenv().logs_webhook) or (_G and _G.logs_webhook) or "",  -- read from the global set before the loadstring
            Interval = 12 * 60 * 60, -- one log every 12 hours
            Persist = false,         -- false = sends right after execution, then every Interval. true = remembers the last send (no repeat on hop/re-execution)
            Color = 0xFFFFFF,        -- white
            Footer = "by flowbr",
        },
    
        Emojis = {
            Account   = "<:Kanna:1394181092726149244>",
            Level     = "<a:str:1477728745480523887>",
            Race      = "<a:gears:1063512975295660113>",
            Sea       = "<a:blue_nuvemcr:1369685899226513408>",
            Money     = "<a:money:1394306770746478642>",
            Fragments = "<a:Estrela_roxo:1394183751881326602>",
            Swords    = "<:DogBlade:1533232035936731296>",
            Guns      = "<:soulguitar:1544426809377038406>",
            Styles    = "<:GodHuman:1394163742089936956>",
        },
    },
}

-- strip emojis from status texts (global, avoids using a local)
function FlowbrStripEmoji(s)
    s = tostring(s or "")
    s = s:gsub("[\240-\244][\128-\191][\128-\191][\128-\191]", "")
    s = s:gsub("\239\184[\128-\143]", "")
    s = s:gsub("\226\128\141", "")
    s = s:gsub("\226[\152-\158][\128-\191]", "")
    s = s:gsub("\226[\140\143][\128-\191]", "")
    s = s:gsub("\226[\172\173][\128-\191]", "")
    s = s:gsub("[ \t]+", " ")
    s = s:gsub("^%s+", "")
    s = s:gsub("%s+$", "")
    return s
end

--============================================================
-- FLOWBR | KAITUN DASHBOARD
--============================================================
task.spawn(function()
    local Cfg = Config and Config.Dashboard
    if not Cfg then return end

    --========================================================
    -- Services
    --========================================================
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local HttpService = game:GetService("HttpService")
    local RS = game:GetService("ReplicatedStorage")

    if not game:IsLoaded() then game.Loaded:Wait() end
    local lp = Players.LocalPlayer
    while not lp do task.wait() lp = Players.LocalPlayer end

    local parentGui
    do
        local ok, r = pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
        parentGui = (ok and r) or lp:WaitForChild("PlayerGui")
    end

    pcall(function()
        for _, g in ipairs(parentGui:GetChildren()) do
            if g.Name == "FlowbrKaitunUI" then g:Destroy() end
        end
    end)

    local httpRequest = (syn and syn.request) or (http and http.request) or http_request
        or (fluxus and fluxus.request) or request

    --========================================================
    -- Helpers
    --========================================================
    local function norm(s)
        return (tostring(s):lower():gsub("[%s%p]", ""))
    end

    local function cleanName(s)
        s = tostring(s or "")
        s = s:gsub(" %[.-%]", "")
        s = s:gsub("^%s+", "")
        s = s:gsub("%s+$", "")
        return s
    end

    local function commas(n)
        n = math.floor(tonumber(n) or 0)
        local r = tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse()
        return (r:gsub("^,", ""))
    end

    local MAX_LEVEL = Cfg.MaxLevel or 2800
    local function levelText(n)
        n = math.floor(tonumber(n) or 0)
        return tostring(n) .. (n >= MAX_LEVEL and " (MAX)" or "")
    end

    local function toAsset(id)
        id = (tostring(id or ""):gsub("%s", ""))
        if id == "" then return nil end
        if id:find("rbxassetid://", 1, true) or id:find("http", 1, true) then return id end
        local n = id:match("%d+")
        return n and ("rbxassetid://" .. n) or nil
    end

    local function val(obj, name, default)
        local c = obj and obj:FindFirstChild(name)
        if c and c:IsA("ValueBase") then return c.Value end
        return default
    end

    local function hex(c)
        return string.format("#%02X%02X%02X",
            math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
    end

    --========================================================
    -- Static data
    --========================================================
    -- Sea (old PlaceIds + the new ones the main script already uses)
    local SEA_BY_PLACE = {
        [2753915549] = 1, [85211729168715] = 1,
        [4442272183] = 2, [79091703265657] = 2,
        [7449423635] = 3, [100117331123089] = 3,
    }

    local MELEE_ORDER = {
        "Combat", "Black Leg", "Electro", "Fishman Karate", "Dragon Claw",
        "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw",
        "Dragon Talon", "Godhuman", "Sanguine Art",
    }
    local MELEE_MAP = {}
    for _, n in ipairs(MELEE_ORDER) do MELEE_MAP[norm(n)] = n end

    local UNLOCK_ORDER = {
        "Godhuman", "Cursed Dual Katana", "Valkyrie Helm",
        "Skull Guitar", "Mirror Fractal", "Pull Lever",
    }

    -- Rarity (only used to sort Top Weapons): 5 mythical, 4 legendary, 3 rare, 2 uncommon, 1 common
    local SWORD_RARITY = {}
    do
        local tiers = {
            [5] = { "Dark Blade", "True Triple Katana", "Cursed Dual Katana", "Hallow Scythe", "Triple Dark Blade", "Dog Blade" },
            [4] = { "Rengoku", "Yama", "Tushita", "Buddy Sword", "Shark Anchor", "Fox Lamp", "Dragon Trident", "Saber",
                    "Canvander", "Dark Dagger", "Dragonheart", "Koko", "Midnight Blade", "Oroshi", "Pole (1st Form)",
                    "Pole (2nd Form)", "Saishi", "Shizu", "Longsword", "Pipe", "Soul Cane", "Trident", "Wardens Sword",
                    "Bisento", "Triple Katana", "Twin Hooks", "Dual-Headed Blade", "Flail", "Gravity Blade",
                    "Shisui", "Saddi", "Wando" },
            [3] = { "Spikey Trident", "Fishing Trophy", "Shark Saw" },
            [2] = { "Iron Mace" },
            [1] = { "Cutlass", "Katana", "Dual Katana", "Duel Katana" },
        }
        for r, list in pairs(tiers) do
            for _, n in ipairs(list) do SWORD_RARITY[norm(n)] = r end
        end
    end

    local GUN_RARITY = {}
    do
        local tiers = {
            [5] = { "Skull Guitar", "Soul Guitar", "Dragonstorm", "Venom Bow" },
            [4] = { "Acidum Rifle", "Bizarre Rifle", "Kabucha", "Serpent Bow" },
            [3] = { "Magma Blaster", "Dual Flintlock", "Bazooka" },
            [2] = { "Cannon", "Refined Flintlock", "Refined Slingshot" },
            [1] = { "Slingshot", "Flintlock", "Musket" },
        }
        for r, list in pairs(tiers) do
            for _, n in ipairs(list) do GUN_RARITY[norm(n)] = r end
        end
    end

    --========================================================
    -- Sea
    --========================================================
    local seaCache = nil
    local function detectSea()
        if seaCache then return seaCache end
        local s = SEA_BY_PLACE[game.PlaceId]

        -- fallback 1: game version label (ex: "v30.0.10-Sea3 : 9a2d8d45e")
        if not s then
            pcall(function()
                local pg = lp:FindFirstChild("PlayerGui")
                if not pg then return end
                for _, d in ipairs(pg:GetDescendants()) do
                    if d:IsA("TextLabel") then
                        local n = tostring(d.Text):match("%-Sea(%d)")
                        if n then
                            s = tonumber(n)
                            return
                        end
                    end
                end
            end)
        end

        -- fallback 2: global variable from the main script
        if not s then
            pcall(function()
                if type(SeaIndex) == "number" then s = SeaIndex end
            end)
        end

        if s then seaCache = s end
        return s or "?"
    end

    --========================================================
    -- Inventory (reads several sources and merges them)
    --========================================================
    -- Source 1: ItemReplicationService (new system, also used by the main script)
    -- Source 2: old remotes (getInventory / getInventoryWeapons)
    -- Source 3: Backpack + Character (equipped/held items)
    local function readInventory()
        local items, byKey = {}, {}
        local fromInv = false

        local function add(name, id, kind, mastery, rarity, tooltip, wtype)
            name = cleanName(name)
            local k = norm(name)
            if k == "" then return end
            local e = byKey[k]
            if not e then
                e = { Name = name }
                byKey[k] = e
                items[#items + 1] = e
            end
            e.Id = e.Id or id
            e.Type = e.Type or kind
            e.Mastery = e.Mastery or mastery
            e.Rarity = e.Rarity or rarity
            e.ToolTip = e.ToolTip or tooltip
            e.WeaponType = e.WeaponType or wtype
        end

        -- Source 1
        local gotNew = false
        pcall(function()
            local irs = require(RS:FindFirstChild("ItemReplicationService"))
            local cache = irs._UserCache and irs._UserCache[lp.UserId]
            if not cache then return end
            local qty = cache:GetItems("Quantity")
            if not qty then return end
            local mst = cache:GetItems("Mastery")
            local cfg = require(RS.ItemConfig)
            local cu = nil
            pcall(function() cu = require(RS.Modules.CombatUtil) end)

            local masteryById = {}
            if mst then
                for _, v in pairs(mst) do masteryById[v.ItemId] = v.Value end
            end

            for _, v in pairs(qty) do
                local id = v.ItemId
                local idType, label = "?", ""
                pcall(function()
                    local c = cfg.match(id):unwrap()
                    if c and c.Index then
                        idType = tostring(c.Index.IdType)
                        label = tostring(c.Index.DebugLabel or "")
                    end
                end)
                local name = cleanName(label)
                if name ~= "" then
                    local wtype = nil
                    if idType == "Moveset" or idType == "PhysicalMoveset" then
                        pcall(function()
                            local wd = cu and cu:GetWeaponData(name)
                            if wd and wd.WeaponType ~= nil then wtype = tostring(wd.WeaponType) end
                        end)
                    end
                    add(name, tostring(id), idType, masteryById[id], nil, nil, wtype)
                    gotNew = true
                end
            end
        end)
        if gotNew then fromInv = true end

        -- Source 2
        if not gotNew then
            for _, remoteArg in ipairs({ "getInventory", "getInventoryWeapons" }) do
                local ok, res = pcall(function()
                    return RS.Remotes.CommF_:InvokeServer(remoteArg)
                end)
                if ok and type(res) == "table" then
                    for _, it in pairs(res) do
                        if type(it) == "table" and it.Name then
                            add(it.Name, nil, it.Type, tonumber(it.Mastery), tonumber(it.Rarity), nil, nil)
                            fromInv = true
                        end
                    end
                end
            end
        end

        -- Source 3
        pcall(function()
            local bp = lp:FindFirstChild("Backpack")
            if bp then
                for _, t in ipairs(bp:GetChildren()) do
                    local tip = nil
                    if t:IsA("Tool") then tip = t.ToolTip end
                    add(t.Name, nil, nil, nil, nil, tip, nil)
                end
            end
            local ch = lp.Character
            if ch then
                for _, t in ipairs(ch:GetChildren()) do
                    if t:IsA("Tool") or t:IsA("Accessory") then
                        local tip = nil
                        if t:IsA("Tool") then tip = t.ToolTip end
                        add(t.Name, nil, nil, nil, nil, tip, nil)
                    end
                end
            end
        end)

        return items, fromInv
    end

    -- Sticky: anything already seen keeps counting (avoids LOCKED flicker if a read fails)
    local store = { names = {}, ids = {}, weapons = {}, loaded = false }
    local leverDone = false
    local leverChecked = false
    local lastInvInfo = ""

    local function classify(it)
        local key = norm(it.Name)
        if MELEE_MAP[key] then return "Melee" end
        if SWORD_RARITY[key] then return "Sword" end
        if GUN_RARITY[key] then return "Gun" end
        for _, s in ipairs({ tostring(it.Type or ""), tostring(it.ToolTip or ""), tostring(it.WeaponType or "") }) do
            if s:find("Sword") then return "Sword" end
            if s:find("Gun") or s:find("Ranged") then return "Gun" end
        end
        return nil
    end

    local function hasItem(name)
        local k = norm(name)
        if store.names[k] then return true end
        if k == "skullguitar" and store.names["soulguitar"] then return true end
        for id in pairs(store.ids) do
            if id:find(k, 1, true) then return true end
        end
        return false
    end

    local function weaponSort(a, b)
        if a.Rarity ~= b.Rarity then return a.Rarity > b.Rarity end
        if a.Mastery ~= b.Mastery then return a.Mastery > b.Mastery end
        return a.Name < b.Name
    end

    local function collect()
        local d = {
            Level = 0, Beli = 0, Frags = 0, Race = "Unknown", Sea = "?",
            Swords = {}, Guns = {}, Styles = {}, Unlocks = {}, Top = {}, InvLoaded = false,
        }

        local data = lp:FindFirstChild("Data")
        d.Level = val(data, "Level", 0)
        d.Beli = val(data, "Beli", 0)
        d.Frags = val(data, "Fragments", 0)
        d.Race = tostring(val(data, "Race", "Unknown"))
        d.Sea = detectSea()

        -- full inventory
        local items, fromInv = readInventory()
        if fromInv then store.loaded = true end
        d.InvLoaded = store.loaded

        for _, it in ipairs(items) do
            local key = norm(it.Name)
            store.names[key] = true
            if it.Id then store.ids[norm(it.Id)] = true end

            local kind = classify(it)
            if kind == "Sword" or kind == "Gun" then
                local prev = store.weapons[key]
                local rar = SWORD_RARITY[key] or GUN_RARITY[key] or tonumber(it.Rarity) or (prev and prev.Rarity) or 0
                store.weapons[key] = {
                    Name = it.Name,
                    Type = kind,
                    Rarity = rar,
                    Mastery = tonumber(it.Mastery) or (prev and prev.Mastery) or 0,
                }
            end
        end

        for _, w in pairs(store.weapons) do
            if w.Type == "Sword" then
                d.Swords[#d.Swords + 1] = w
            else
                d.Guns[#d.Guns + 1] = w
            end
        end
        table.sort(d.Swords, weaponSort)
        table.sort(d.Guns, weaponSort)

        -- fighting styles: search ALL in inventory (not only the equipped one)
        for _, n in ipairs(MELEE_ORDER) do
            if hasItem(n) then d.Styles[#d.Styles + 1] = n end
        end

        -- Temple of Time lever
        if not leverDone then
            local ok, res = pcall(function()
                return RS.Remotes.CommF_:InvokeServer("CheckTempleDoor")
            end)
            if ok and type(res) == "boolean" then leverChecked = true end
            if ok and res == true then leverDone = true end
        end

        d.Unlocks = {
            ["Godhuman"] = hasItem("Godhuman"),
            ["Cursed Dual Katana"] = hasItem("Cursed Dual Katana"),
            ["Valkyrie Helm"] = hasItem("Valkyrie Helm"),
            ["Skull Guitar"] = hasItem("Skull Guitar"),
            ["Mirror Fractal"] = hasItem("Mirror Fractal"),
            ["Pull Lever"] = leverDone,
        }
        d.LeverChecked = leverChecked or leverDone

        -- Top weapons: 2 swords + 1 gun (filled up with whatever is left)
        local top = {}
        for i = 1, 2 do
            if d.Swords[i] then top[#top + 1] = { Type = "Sword", Name = d.Swords[i].Name } end
        end
        if d.Guns[1] then top[#top + 1] = { Type = "Gun", Name = d.Guns[1].Name } end
        local si, gi = 3, 2
        while #top < 3 and (d.Swords[si] or d.Guns[gi]) do
            if d.Swords[si] then
                top[#top + 1] = { Type = "Sword", Name = d.Swords[si].Name }
                si = si + 1
            elseif d.Guns[gi] then
                top[#top + 1] = { Type = "Gun", Name = d.Guns[gi].Name }
                gi = gi + 1
            end
        end
        d.Top = top

        local info = (fromInv and "inventario" or "so-tools") .. ":" .. #items .. ":" .. #d.Styles
        if info ~= lastInvInfo then
            lastInvInfo = info
            print(("[flowbr] read %s | swords %d | guns %d | styles %d"):format(
                fromInv and "inventario OK" or "apenas Backpack/Character", #d.Swords, #d.Guns, #d.Styles))
        end

        return d
    end

    --========================================================
    -- UI (light pink + gray + red)
    --========================================================
    local PINK      = Color3.fromRGB(255, 182, 205)  -- light pink
    local PINK_DIM  = Color3.fromRGB(214, 146, 170)
    local RED       = Color3.fromRGB(235, 52, 84)    -- red
    local RED_LIGHT = Color3.fromRGB(255, 98, 126)
    local RED_TINT  = Color3.fromRGB(92, 38, 52)
    local GRAY_BG   = Color3.fromRGB(30, 29, 33)     -- window background
    local GRAY_PANEL= Color3.fromRGB(46, 44, 50)     -- panels
    local GRAY_CELL = Color3.fromRGB(60, 57, 64)     -- cells
    local GRAY_LINE = Color3.fromRGB(104, 99, 110)   -- neutral outlines
    local TEXT      = Color3.fromRGB(248, 240, 244)
    local MUTED     = Color3.fromRGB(156, 150, 160)
    local BLACK     = Color3.fromRGB(0, 0, 0)

    local WIN_W, HEADER_H = 620, 64
    local BODY_H = 372
    local WIN_H = HEADER_H + BODY_H

    local function corner(parent, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = r or UDim.new(0, 10)
        c.Parent = parent
        return c
    end

    local function stroke(parent, thickness, color, transparency)
        local s = Instance.new("UIStroke")
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Thickness = thickness or 1
        s.Color = color or RED
        s.Transparency = transparency or 0
        s.Parent = parent
        return s
    end

    local function frame(parent, x, y, w, h, color, transparency)
        local f = Instance.new("Frame")
        f.BorderSizePixel = 0
        f.Position = UDim2.fromOffset(x, y)
        f.Size = UDim2.fromOffset(w, h)
        f.BackgroundColor3 = color or GRAY_PANEL
        f.BackgroundTransparency = transparency or 0
        f.Parent = parent
        return f
    end

    local function label(parent, props)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.BorderSizePixel = 0
        l.Font = props.Font or Enum.Font.Gotham
        l.TextSize = props.Size or 13
        l.TextColor3 = props.Color or TEXT
        l.TextXAlignment = props.XAlign or Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Center
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.RichText = props.Rich or false
        l.Text = props.Text or ""
        l.Position = props.Pos or UDim2.new()
        l.Size = props.Sz or UDim2.fromScale(1, 1)
        l.Parent = parent
        return l
    end

    local function button(parent, props)
        local b = Instance.new("TextButton")
        b.AutoButtonColor = false
        b.BorderSizePixel = 0
        b.Font = props.Font or Enum.Font.GothamBold
        b.TextSize = props.Size or 12
        b.TextColor3 = props.Color or TEXT
        b.Text = props.Text or ""
        b.BackgroundColor3 = props.Bg or GRAY_PANEL
        b.BackgroundTransparency = props.BgT or 0
        b.Position = props.Pos or UDim2.new()
        b.Size = props.Sz or UDim2.fromOffset(60, 30)
        b.Parent = parent
        corner(b, UDim.new(0, props.Radius or 8))
        return b
    end

    local function panel(parent, x, y, w, h, title)
        local f = frame(parent, x, y, w, h, GRAY_PANEL, 0.1)
        corner(f, UDim.new(0, 12))
        stroke(f, 1.2, GRAY_LINE, 0.4)
        if title then
            label(f, {
                Text = title, Size = 12, Font = Enum.Font.GothamBold, Color = PINK,
                Pos = UDim2.fromOffset(16, 10), Sz = UDim2.fromOffset(w - 32, 18),
            })
        end
        return f
    end

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "FlowbrKaitunUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = parentGui

    -- Window
    local window = Instance.new("Frame")
    window.Name = "Window"
    window.AnchorPoint = Vector2.new(0.5, 0)
    window.Size = UDim2.fromOffset(WIN_W, WIN_H)
    window.BackgroundColor3 = GRAY_BG
    window.BorderSizePixel = 0
    window.ClipsDescendants = true
    window.Parent = gui
    corner(window, UDim.new(0, 16))
    local windowStroke = stroke(window, 2, RED, 0)

    local uiScale = Instance.new("UIScale")
    uiScale.Parent = window

    local function updateScale()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vp = cam.ViewportSize
        uiScale.Scale = math.clamp(math.min((vp.X - 20) / WIN_W, (vp.Y - 20) / WIN_H, 1), 0.2, 1) * (Cfg.Scale or 0.5)
    end
    updateScale()
    do
        local cam = workspace.CurrentCamera
        if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale) end
        local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
        window.Position = UDim2.new(0.5, 0, 0, math.max(10, (vp.Y - WIN_H * uiScale.Scale) / 2))
    end

    -- Pulsing glow (red)
    TweenService:Create(
        windowStroke,
        TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { Transparency = 0.55 }
    ):Play()

    -- Background (optional image, set in Config.Dashboard.BackgroundImage)
    local bgImage = Instance.new("ImageLabel")
    bgImage.Name = "Background"
    bgImage.BackgroundTransparency = 1
    bgImage.BorderSizePixel = 0
    bgImage.Size = UDim2.fromScale(1, 1)
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.ZIndex = 1
    bgImage.Visible = false
    bgImage.Parent = window

    local bgDim = Instance.new("Frame")
    bgDim.Name = "Dim"
    bgDim.BackgroundColor3 = BLACK
    bgDim.BackgroundTransparency = Cfg.BackgroundDim or 0.45
    bgDim.BorderSizePixel = 0
    bgDim.Size = UDim2.fromScale(1, 1)
    bgDim.ZIndex = 2
    bgDim.Visible = false
    bgDim.Parent = window

    -- [FIXED] round the background layers too, otherwise their square corners cover the window's rounded corners
    corner(bgImage, UDim.new(0, 16))
    corner(bgDim, UDim.new(0, 16))

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundTransparency = 1
    header.Size = UDim2.fromOffset(WIN_W, HEADER_H)
    header.ZIndex = 3
    header.Parent = window

    local dragArea = Instance.new("Frame")
    dragArea.BackgroundTransparency = 1
    dragArea.Size = UDim2.fromOffset(WIN_W - 80, HEADER_H)
    dragArea.Parent = header

    label(dragArea, {
        Text = Cfg.UIName, Size = 22, Font = Enum.Font.GothamBold, Color = PINK,
        Pos = UDim2.fromOffset(20, 10), Sz = UDim2.fromOffset(400, 28),
    })
    label(dragArea, {
        Text = Cfg.Subtitle, Size = 11, Font = Enum.Font.GothamMedium, Color = MUTED,
        Pos = UDim2.fromOffset(20, 38), Sz = UDim2.fromOffset(400, 16),
    })

    local headerLine = frame(header, 0, HEADER_H - 1, WIN_W, 1, GRAY_LINE, 0.4)

    -- Single button: open = "-" | closed = "+"
    local collapseBtn = button(header, {
        Text = "-", Size = 22, Bg = GRAY_PANEL, BgT = 0,
        Pos = UDim2.fromOffset(WIN_W - 54, 15), Sz = UDim2.fromOffset(38, 34), Radius = 10,
        Color = PINK,
    })
    stroke(collapseBtn, 1.4, RED, 0.1)

    -- Body
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(0, HEADER_H)
    body.Size = UDim2.fromOffset(WIN_W, BODY_H)
    body.ZIndex = 3
    body.Parent = window

    -- Account Stats
    local statsPanel = panel(body, 14, 14, 288, 168, "ACCOUNT STATS")
    local statVals = {}
    do
        local keys = { "Level", "Race", "Beli", "Fragments", "Sea" }
        for i, k in ipairs(keys) do
            local y = 38 + (i - 1) * 25
            label(statsPanel, {
                Text = k .. ":", Size = 13, Color = PINK_DIM, Font = Enum.Font.GothamMedium,
                Pos = UDim2.fromOffset(16, y), Sz = UDim2.fromOffset(110, 22),
            })
            statVals[k] = label(statsPanel, {
                Text = "-", Size = 14, Font = Enum.Font.GothamBold, Color = TEXT,
                Pos = UDim2.fromOffset(120, y), Sz = UDim2.fromOffset(152, 22),
            })
        end
    end

    -- Top Weapons
    local weaponsPanel = panel(body, 318, 14, 288, 168, "TOP WEAPONS")
    local weaponRows = {}
    for i = 1, 3 do
        local rowY = 42 + (i - 1) * 38
        local rowBg = frame(weaponsPanel, 14, rowY, 260, 32, GRAY_CELL, 0.2)
        corner(rowBg, UDim.new(0, 8))
        weaponRows[i] = label(rowBg, {
            Text = "-", Size = 14, Font = Enum.Font.GothamMedium, Color = MUTED, Rich = true,
            Pos = UDim2.fromOffset(12, 0), Sz = UDim2.new(1, -20, 1, 0),
        })
    end

    -- Account Progress
    local progressPanel = panel(body, 14, 196, 592, 162, "ACCOUNT PROGRESS")
    local cells = {}
    for i, name in ipairs(UNLOCK_ORDER) do
        local col = (i - 1) % 3
        local row = math.floor((i - 1) / 3)
        local cf = frame(progressPanel, 14 + col * 192, 44 + row * 58, 180, 50, GRAY_CELL, 0.1)
        corner(cf, UDim.new(0, 9))
        local st = stroke(cf, 1.2, GRAY_LINE, 0.3)
        local nameLbl = label(cf, {
            Text = name, Size = 13, Font = Enum.Font.GothamBold, Color = TEXT,
            XAlign = Enum.TextXAlignment.Center,
            Pos = UDim2.fromOffset(6, 7), Sz = UDim2.fromOffset(168, 20),
        })
        local stateLbl = label(cf, {
            Text = "LOCKED", Size = 11, Font = Enum.Font.GothamMedium, Color = MUTED,
            XAlign = Enum.TextXAlignment.Center,
            Pos = UDim2.fromOffset(6, 27), Sz = UDim2.fromOffset(168, 16),
        })
        cells[i] = { frame = cf, stroke = st, name = nameLbl, state = stateLbl }
    end

    --========================================================
    -- Round button (opens/closes the UI)
    -- Icon: Config.Dashboard.ToggleImage | Background: Config.Dashboard.BackgroundImage
    --========================================================
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "Toggle"
    toggleBtn.AutoButtonColor = false
    toggleBtn.Text = ""
    toggleBtn.BackgroundColor3 = GRAY_BG
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Size = UDim2.fromOffset(Cfg.ToggleSize or 40, Cfg.ToggleSize or 40)
    toggleBtn.Position = UDim2.new(0, 20, 0.35, 0)
    toggleBtn.Parent = gui
    corner(toggleBtn, UDim.new(1, 0))
    stroke(toggleBtn, 2.2, RED, 0)

    local toggleImg = Instance.new("ImageLabel")
    toggleImg.BackgroundTransparency = 1
    toggleImg.BorderSizePixel = 0
    toggleImg.Position = UDim2.fromOffset(4, 4)
    toggleImg.Size = UDim2.new(1, -8, 1, -8)
    toggleImg.ScaleType = Enum.ScaleType.Crop
    toggleImg.Visible = false
    toggleImg.Parent = toggleBtn
    corner(toggleImg, UDim.new(1, 0))

    local toggleLetter = label(toggleBtn, {
        Text = "F", Size = 18, Font = Enum.Font.GothamBold, Color = PINK,
        XAlign = Enum.TextXAlignment.Center,
    })

    do
        local asset = toAsset(Cfg.ToggleImage)
        toggleImg.Image = asset or ""
        toggleImg.Visible = asset ~= nil
        toggleLetter.Visible = asset == nil
    end
    do
        local asset = toAsset(Cfg.BackgroundImage)
        bgImage.Image = asset or ""
        bgImage.Visible = asset ~= nil
        bgDim.Visible = asset ~= nil
    end

    --========================================================
    -- Dragging (mouse and touch)
    --========================================================
    local function makeDraggable(handle, target, onClick, scaleObj)
        local dragging, moved = false, false
        local startPos, startInput

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging, moved = true, false
                startInput = input.Position
                startPos = target.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        if not moved and onClick then onClick() end
                    end
                end)
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                local s = scaleObj and scaleObj.Scale or 1
                local delta = (input.Position - startInput)
                if delta.Magnitude > 6 then moved = true end
                if moved then
                    target.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X / s,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y / s
                    )
                end
            end
        end)
    end

    makeDraggable(dragArea, window, nil, uiScale)
    makeDraggable(toggleBtn, toggleBtn, function() window.Visible = not window.Visible end, nil)

    --========================================================
    -- Single button: open "-" / collapsed "+"
    --========================================================
    local expanded = true
    local function setExpanded(v)
        expanded = v
        body.Visible = v
        TweenService:Create(
            window,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.fromOffset(WIN_W, v and WIN_H or HEADER_H) }
        ):Play()
        collapseBtn.Text = v and "-" or "+"
        headerLine.Visible = v
    end
    collapseBtn.MouseButton1Click:Connect(function() setExpanded(not expanded) end)
    setExpanded(true)

    --========================================================
    -- Update UI
    --========================================================
    local function updateUI(d)
        statVals.Level.Text = levelText(d.Level)
        statVals.Race.Text = tostring(d.Race)
        statVals.Beli.Text = "$" .. commas(d.Beli)
        statVals.Fragments.Text = commas(d.Frags)
        statVals.Sea.Text = tostring(d.Sea)

        for i = 1, 3 do
            local w = d.Top[i]
            if w then
                local tagColor = (w.Type == "Gun") and RED_LIGHT or PINK
                weaponRows[i].Text = ('<font color="%s">%s</font>   %s'):format(hex(tagColor), string.upper(w.Type), w.Name)
                weaponRows[i].TextColor3 = TEXT
            else
                weaponRows[i].Text = "-"
                weaponRows[i].TextColor3 = MUTED
            end
        end

        for i, name in ipairs(UNLOCK_ORDER) do
            local c = cells[i]
            local on = d.Unlocks[name] == true
            c.state.Text = on and "UNLOCKED" or "LOCKED"
            c.state.TextColor3 = on and RED_LIGHT or MUTED
            c.frame.BackgroundColor3 = on and RED_TINT or GRAY_CELL
            c.stroke.Color = on and RED or GRAY_LINE
            c.stroke.Transparency = on and 0 or 0.3
        end
    end

    --========================================================
    -- Webhook (Discord Components V2) - log every 12h
    --========================================================
    local W = Cfg.Webhook
    local lastData = nil

    -- Names as strings (works for tables with .Name or plain strings)
    local function names(list)
        local t = {}
        for _, e in ipairs(list) do t[#t + 1] = type(e) == "table" and e.Name or tostring(e) end
        return t
    end

    -- Sorted list, `perLine` items per line, stops at `budget` characters
    local function grid(list, perLine, budget)
        local items = {}
        for _, s in ipairs(list) do items[#items + 1] = tostring(s) end
        if #items == 0 then return "_None_" end
        table.sort(items)

        local lines, line, len = {}, {}, 0
        local function flush()
            if #line > 0 then
                lines[#lines + 1] = "▸ " .. table.concat(line, "  •  ")
                line = {}
            end
        end
        for i, s in ipairs(items) do
            if len + #s > budget then
                flush()
                lines[#lines + 1] = ("_+%d more_"):format(#items - i + 1)
                return table.concat(lines, "\n")
            end
            line[#line + 1] = s
            len = len + #s
            if #line == perLine then flush() end
        end
        flush()
        return table.concat(lines, "\n")
    end

    local function buildPayload(d)
        local E = Cfg.Emojis

        local stats = table.concat({
            E.Account .. " **Account**",
            "▸ " .. (E.Level or "") .. " Level: **" .. levelText(d.Level) .. "**",
            "▸ " .. E.Money .. " Beli: **$" .. commas(d.Beli) .. "**",
            "▸ " .. E.Fragments .. " Fragments: **" .. commas(d.Frags) .. "**",
            "▸ " .. (E.Race or "") .. " Race: **" .. tostring(d.Race) .. "**",
            "▸ " .. (E.Sea or "") .. " Sea: **" .. tostring(d.Sea) .. "**",
        }, "\n")

        local progressLines = { "**Progress**" }
        for _, name in ipairs(UNLOCK_ORDER) do
            progressLines[#progressLines + 1] = (d.Unlocks[name] and "<a:Green_dot:1450711072653971476> " or "<a:Off:1553303846317461534> ") .. name
        end
        local progress = table.concat(progressLines, "\n")

        local swords = E.Swords .. " **Swords** (" .. #d.Swords .. ")\n" .. grid(names(d.Swords), 3, 1300)
        local guns   = E.Guns   .. " **Guns** (" .. #d.Guns .. ")\n"       .. grid(names(d.Guns), 3, 600)
        local styles = E.Styles .. " **Fighting Styles** (" .. #d.Styles .. ")\n" .. grid(d.Styles, 3, 500)

        local function sep() return { type = 14, divider = true, spacing = 1 } end
        local function txt(c) return { type = 10, content = c } end

        return {
            flags = 32768, -- IS_COMPONENTS_V2
            components = {
                {
                    type = 17, -- Container
                    accent_color = W.Color,
                    components = {
                        txt(stats), sep(),
                        txt(progress), sep(),
                        txt(swords), sep(),
                        txt(guns), sep(),
                        txt(styles), sep(),
                        txt("-# " .. W.Footer),
                    },
                },
            },
        }
    end

    local function postJson(url, payload)
        if not httpRequest then
            warn("[flowbr] webhook: this executor has no HTTP request function")
            return false
        end
        local ok, body = pcall(function() return HttpService:JSONEncode(payload) end)
        if not ok then
            warn("[flowbr] webhook: JSON encode failed: " .. tostring(body))
            return false
        end
        local okp, res = pcall(httpRequest, {
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = body,
        })
        if not okp then
            warn("[flowbr] webhook: request error: " .. tostring(res))
            return false
        end
        if res then
            local code = tonumber(res.StatusCode) or 0
            if res.Success or (code >= 200 and code < 300) then return true end
            warn(("[flowbr] webhook: HTTP %s %s"):format(tostring(code), tostring(res.Body or ""):sub(1, 200)))
        end
        return false
    end

    -- Plain embed used when the Components V2 message is rejected
    local function buildFallback(d)
        local function list(t, n)
            local s = {}
            for i, e in ipairs(t) do
                if i > n then s[#s + 1] = ("+%d more"):format(#t - n) break end
                s[#s + 1] = type(e) == "table" and e.Name or tostring(e)
            end
            return #s > 0 and table.concat(s, ", ") or "None"
        end
        local unlocked = {}
        for _, name in ipairs(UNLOCK_ORDER) do
            unlocked[#unlocked + 1] = name .. ": " .. (d.Unlocks[name] and "Unlocked" or "Locked")
        end
        return {
            embeds = {{
                title = Cfg.UIName,
                color = W.Color,
                description = table.concat({
                    "**Level:** " .. levelText(d.Level),
                    "**Beli:** $" .. commas(d.Beli),
                    "**Fragments:** " .. commas(d.Frags),
                    "**Race:** " .. tostring(d.Race),
                    "**Sea:** " .. tostring(d.Sea),
                }, "\n"),
                fields = {
                    { name = "Progress", value = table.concat(unlocked, "\n"):sub(1, 1000), inline = false },
                    { name = "Swords (" .. #d.Swords .. ")", value = list(d.Swords, 25):sub(1, 1000), inline = false },
                    { name = "Guns (" .. #d.Guns .. ")", value = list(d.Guns, 15):sub(1, 1000), inline = false },
                    { name = "Fighting Styles (" .. #d.Styles .. ")", value = list(d.Styles, 15):sub(1, 1000), inline = false },
                },
                footer = { text = W.Footer },
            }},
        }
    end

    local function sendReport(d)
        if not W.Enabled or not W.Url or W.Url == "" or not d then return false end
        local base = W.Url:match("^[^?]+")
        local okb, payload = pcall(buildPayload, d)
        if okb and postJson(base .. "?with_components=true", payload) then
            print("[flowbr] webhook sent")
            return true
        end
        -- Components V2 failed -> try a classic embed
        local okf, fb = pcall(buildFallback, d)
        if okf and postJson(base, fb) then
            print("[flowbr] webhook sent (fallback embed)")
            return true
        end
        return false
    end

    -- Timing (stores the last send in a file so it does not repeat on every server hop)
    local STATE_FILE = ("flowbr_kaitun_log_%d.txt"):format(lp.UserId)

    local function readLast()
        if not (isfile and readfile) then return 0 end
        local ok, v = pcall(function()
            if isfile(STATE_FILE) then return tonumber(readfile(STATE_FILE)) end
            return 0
        end)
        return (ok and v) or 0
    end

    local function saveLast(t)
        if writefile then pcall(writefile, STATE_FILE, tostring(t)) end
    end

    --========================================================
    -- Main loop
    --========================================================
    task.spawn(function()
        local startClock = os.clock()
        local lastSent = W.Persist and readLast() or 0
        while gui.Parent do
            local ok, data = pcall(collect)
            if not ok then
                warn("[flowbr] error collecting data: " .. tostring(data))
            elseif data then
                lastData = data
                pcall(updateUI, data)

                -- only sends once the inventory has loaded (or after 90s of waiting)
                local ready = (data.Level > 0 and data.InvLoaded and data.LeverChecked) or (os.clock() - startClock) > 90
                if W.Enabled and ready and os.time() - lastSent >= W.Interval then
                    lastSent = os.time()
                    local stamp = lastSent
                    task.spawn(function()
                        if sendReport(data) then
                            if W.Persist then saveLast(stamp) end
                        else
                            lastSent = os.time() - W.Interval + 300 -- retry in 5 min
                        end
                    end)
                end
            end
            -- poll faster until the inventory has loaded
            task.wait(store.loaded and (Cfg.RefreshInterval or 10) or 3)
        end
    end)

end)

print("[Tiro] Script loaded, waiting for the game to load...")
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer

print("[Main] Starting Tiro Kaitun Module v2.2...")
timeee = os.time()
local W_angle = 30
local lastChange = tick()

-- ============================================================
-- [ADDED] WEAPON SELECTION (from T-Rex Hub)
-- ============================================================
_G.ChooseWP = "Melee"  -- Default: Melee (can be Sword, Gun, Blox Fruit)
_G.SelectWeapon = nil

-- Auto weapon update loop
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if not bp then return end
            if _G.ChooseWP == "Melee" then
                for _, v in pairs(bp:GetChildren()) do
                    if v:IsA("Tool") and v.ToolTip == "Melee" then
                        _G.SelectWeapon = v.Name
                        break
                    end
                end
            elseif _G.ChooseWP == "Sword" then
                for _, v in pairs(bp:GetChildren()) do
                    if v:IsA("Tool") and v.ToolTip == "Sword" then
                        _G.SelectWeapon = v.Name
                        break
                    end
                end
            elseif _G.ChooseWP == "Gun" then
                for _, v in pairs(bp:GetChildren()) do
                    if v:IsA("Tool") and v.ToolTip == "Gun" then
                        _G.SelectWeapon = v.Name
                        break
                    end
                end
            elseif _G.ChooseWP == "Blox Fruit" then
                for _, v in pairs(bp:GetChildren()) do
                    if v:IsA("Tool") and v.ToolTip == "Blox Fruit" then
                        _G.SelectWeapon = v.Name
                        break
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- [ADDED] GAME DATA - plain reference tables, not wired in directly;
-- used to look up level -> mob/quest when needed
-- ============================================================
local GameData = {
	QUESTS = {
		Sea_1 = {
			{1, 9, "Team-dependent", "Team-dependent", 1},
			{10, 14, "Monkey", "JungleQuest", 1},
			{15, 29, "Gorilla", "JungleQuest", 2, "The Gorilla King", 20},
			{30, 39, "Pirate", "BuggyQuest1", 1},
			{40, 59, "Brute", "BuggyQuest1", 2, "Chief", 55},
			{60, 74, "Desert Bandit", "DesertQuest", 1},
			{75, 89, "Desert Officer", "DesertQuest", 2},
			{90, 99, "Snow Bandit", "SnowQuest", 1},
			{100, 119, "Snowman", "SnowQuest", 2, "Yeti", 105},
			{120, 149, "Chief Petty Officer", "MarineQuest2", 1, "Vice Admiral", 130},
			{150, 174, "Sky Bandit", "SkyQuest", 1},
			{175, 189, "Dark Master", "SkyQuest", 2},
			{190, 209, "Prisoner", "PrisonerQuest", 1},
			{210, 249, "Dangerous Prisoner", "PrisonerQuest", 2, {"Warden", 220, "ImpelQuest", 1}, {"Chief Warden", 230, "ImpelQuest", 2}, {"Swan", 240, "ImpelQuest", 3}},
			{250, 274, "Toga Warrior", "ColosseumQuest", 1},
			{275, 299, "Gladiator", "ColosseumQuest", 2},
			{300, 324, "Military Soldier", "MagmaQuest", 1},
			{325, 374, "Military Spy", "MagmaQuest", 2, "Magma Admiral", 350},
			{375, 399, "Fishman Warrior", "FishmanQuest", 1},
			{400, 449, "Fishman Commando", "FishmanQuest", 2, "Fishman Lord", 425},
			{450, 474, "God's Guard", "SkyExp1Quest", 1},
			{475, 524, "Shanda", "SkyExp1Quest", 2, "Wysper", 500},
			{525, 549, "Royal Squad", "SkyExp2Quest", 1},
			{550, 624, "Royal Soldier", "SkyExp2Quest", 2, "Thunder God", 575},
			{625, 649, "Galley Pirate", "FountainQuest", 1},
			{650, 9999, "Galley Captain", "FountainQuest", 2, "Cyborg", 675},
		},
		Sea_2 = {
			{700, 724, "Raider", "Area1Quest", 1},
			{725, 774, "Mercenary", "Area1Quest", 2, "Diamond", 750},
			{775, 799, "Swan Pirate", "Area2Quest", 1},
			{800, 874, "Factory Staff", "Area2Quest", 2, "Jeremy", 850},
			{875, 899, "Marine Lieutenant", "MarineQuest3", 1},
			{900, 949, "Marine Captain", "MarineQuest3", 2, "Orbitus", 925},
			{950, 974, "Zombie", "ZombieQuest", 1},
			{975, 999, "Vampire", "ZombieQuest", 2},
			{1000, 1049, "Snow Trooper", "SnowMountainQuest", 1},
			{1050, 1099, "Winter Warrior", "SnowMountainQuest", 2},
			{1100, 1124, "Lab Subordinate", "IceSideQuest", 1},
			{1125, 1174, "Horned Warrior", "IceSideQuest", 2, "Smoke Admiral", 1150},
			{1175, 1199, "Magma Ninja", "FireSideQuest", 1},
			{1200, 1249, "Lava Pirate", "FireSideQuest", 2},
			{1250, 1274, "Ship Deckhand", "ShipQuest1", 1},
			{1275, 1299, "Ship Engineer", "ShipQuest1", 2},
			{1300, 1324, "Ship Steward", "ShipQuest2", 1},
			{1325, 1349, "Ship Officer", "ShipQuest2", 2},
			{1350, 1374, "Arctic Warrior", "FrostQuest", 1},
			{1375, 1424, "Snow Lurker", "FrostQuest", 2, "Awakened Ice Admiral", 1400},
			{1425, 1449, "Sea Soldier", "ForgottenQuest", 1},
			{1450, 9999, "Water Fighter", "ForgottenQuest", 2, "Tide Keeper", 1475},
		},
		Sea_3 = {
			{1500, 1524, "Pirate Millionaire", "PiratePortQuest", 1},
			{1525, 1574, "Pistol Billionaire", "PiratePortQuest", 2},
			{1575, 1599, "Dragon Crew Warrior", "DragonCrewQuest", 1},
			{1600, 1624, "Dragon Crew Archer", "DragonCrewQuest", 2},
			{1625, 1649, "Hydra Enforcer", "VenomCrewQuest", 1},
			{1650, 1699, "Venomous Assailant", "VenomCrewQuest", 2},
			{1700, 1724, "Marine Commodore", "MarineTreeIsland", 1},
			{1725, 1774, "Marine Rear Admiral", "MarineTreeIsland", 2},
			{1775, 1799, "Fishman Raider", "DeepForestIsland3", 1},
			{1800, 1824, "Fishman Captain", "DeepForestIsland3", 2},
			{1825, 1849, "Forest Pirate", "DeepForestIsland", 1},
			{1850, 1899, "Mythological Pirate", "DeepForestIsland", 2},
			{1900, 1924, "Jungle Pirate", "DeepForestIsland2", 1},
			{1925, 1974, "Musketeer Pirate", "DeepForestIsland2", 2},
			{1975, 1999, "Reborn Skeleton", "HauntedQuest1", 1},
			{2000, 2024, "Living Zombie", "HauntedQuest1", 2},
			{2025, 2049, "Demonic Soul", "HauntedQuest2", 1},
			{2050, 2074, "Posessed Mummy", "HauntedQuest2", 2},
			{2075, 2099, "Peanut Scout", "NutsIslandQuest", 1},
			{2100, 2124, "Peanut President", "NutsIslandQuest", 2},
			{2125, 2149, "Ice Cream Chef", "IceCreamIslandQuest", 1},
			{2150, 2199, "Ice Cream Commander", "IceCreamIslandQuest", 2},
			{2200, 2224, "Cookie Crafter", "CakeQuest1", 1},
			{2225, 2249, "Cake Guard", "CakeQuest1", 2},
			{2250, 2274, "Baking Staff", "CakeQuest2", 1},
			{2275, 2299, "Head Baker", "CakeQuest2", 2},
			{2300, 2324, "Cocoa Warrior", "ChocQuest1", 1},
			{2325, 2349, "Chocolate Bar Battler", "ChocQuest1", 2},
			{2350, 2374, "Sweet Thief", "ChocQuest2", 1},
			{2375, 2399, "Candy Rebel", "ChocQuest2", 2},
			{2400, 2424, "Candy Pirate", "CandyQuest1", 1},
			{2425, 2449, "Snow Demon", "CandyQuest1", 2},
			{2450, 2474, "Isle Outlaw", "TikiQuest1", 1},
			{2475, 2499, "Island Boy", "TikiQuest1", 2},
			{2500, 2524, "Sun-kissed Warrior", "TikiQuest2", 1},
			{2525, 2549, "Isle Champion", "TikiQuest2", 2},
			{2550, 2574, "Serpent Hunter", "TikiQuest3", 1},
			{2575, 2599, "Skull Slayer", "TikiQuest3", 2},
			{2600, 2624, "Reef Bandit", "SubmergedQuest1", 1},
			{2625, 2649, "Coral Pirate", "SubmergedQuest1", 2},
			{2650, 2674, "Sea Chanter", "SubmergedQuest2", 1},
			{2675, 2699, "Ocean Prophet", "SubmergedQuest2", 2},
			{2700, 2724, "High Disciple", "SubmergedQuest3", 1},
			{2725, 9999, "Grand Devotee", "SubmergedQuest3", 2},
		}
	},
	BossList = {
		Sea_1 = {
			{20, "The Gorilla King", "JungleQuest", 3, CFrame.new(-1602, 37, 153)},
			{55, "Chief", "BuggyQuest1", 2, CFrame.new(-1140, 5, 3827)},
			{105, "Yeti", "SnowQuest", 3, CFrame.new(1387, 87, -1298)},
			{130, "Vice Admiral", "MarineQuest2", 2, CFrame.new(-5036, 29, 4325)},
			{220, "Warden", "ImpelQuest", 1, CFrame.new(5192, 3, 686)},
			{230, "Chief Warden", "ImpelQuest", 2, CFrame.new(5192, 3, 686)},
			{240, "Swan", "ImpelQuest", 3, CFrame.new(5192, 3, 686)},
			{350, "Magma Admiral", "MagmaQuest", 3, CFrame.new(-5315, 12, 8517)},
			{425, "Fishman Lord", "FishmanQuest", 3, CFrame.new(61123, 18, 1569)},
			{500, "Wysper", "SkyExp1Quest", 3, CFrame.new(-7862, 5546, -380)},
			{575, "Thunder God", "SkyExp2Quest", 3, CFrame.new(-7903, 5636, -1411)},
			{675, "Cyborg", "FountainQuest", 3, CFrame.new(5258, 39, 4050)},
		},
		Sea_2 = {
			{750, "Diamond", "Area1Quest", 3, CFrame.new(-428, 73, 1835)},
			{850, "Jeremy", "Area2Quest", 3, CFrame.new(637, 73, 918)},
			{925, "Orbitus", "MarineQuest3", 3, CFrame.new(-2442, 73, -3218)},
			{1150, "Smoke Admiral", "IceSideQuest", 3, CFrame.new(-5429, 16, -5298)},
			{1400, "Awakened Ice Admiral", "FrostQuest", 3, CFrame.new(5669, 29, -6483)},
			{1475, "Tide Keeper", "ForgottenQuest", 3, CFrame.new(-3054, 237, -10145)},
		},
		Sea_3 = {
			{1575, "Stone", "PiratePortQuest", 3, CFrame.new(-290, 44, 5580)},
			{1775, "Kilo Admiral", "MarineTreeIsland", 3, CFrame.new(2179, 29, -6740)},
			{1875, "Captain Elephant", "DeepForestIsland", 3, CFrame.new(-13233, 332, -7626)},
			{1950, "Beautiful Pirate", "DeepForestIsland2", 3, CFrame.new(-12682, 391, -9902)},
			{2175, "Cake Queen", "IceCreamIslandQuest", 3, CFrame.new(-819, 65, -10967)},
		}
	},
	MaterialEnemies = {
		Sea_1 = {
			["Angel Wings"] = { "Shanda", "Royal Squad", "Royal Soldier", "Wysper", "Thunder God" },
			["Leather + Scrap Metal"] = { "Brute", "Pirate" },
			["Magma Ore"] = { "Military Soldier", "Military Spy", "Magma Admiral" },
			["Fish Tail"] = { "Fishman Warrior", "Fishman Commando", "Fishman Lord" },
		},
		Sea_2 = {
			["Leather + Scrap Metal"] = { "Marine Captain" },
			["Magma Ore"] = { "Magma Ninja", "Lava Pirate" },
			["Ectoplasm"] = { "Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer" },
			["Mystic Droplet"] = { "Water Fighter" },
			["Radioactive Material"] = { "Factory Staff" },
			["Vampire Fang"] = { "Vampire" },
		},
		Sea_3 = {
			["Leather + Scrap Metal"] = { "Jungle Pirate" },
			["Demonic Wisp"] = { "Demonic Soul" },
			["Fish Tail"] = { "Fishman Raider", "Fishman Captain" },
			["Conjured Cocoa"] = { "Chocolate Bar Battler", "Cocoa Warrior" },
			["Dragon Scale"] = { "Dragon Crew Archer", "Dragon Crew Warrior" },
			["Gunpowder"] = { "Pistol Billionaire" },
			["Mini Tusk"] = { "Mythological Pirate" },
			["Nightmare Catcher"] = { "Reborn Skeleton", "Living Zombie" },
		}
	},
	Materials = {
		Sea_1 = { "Leather + Scrap Metal", "Angel Wings", "Magma Ore", "Fish Tail" },
		Sea_2 = { "Leather + Scrap Metal", "Radioactive Material", "Ectoplasm", "Mystic Droplet", "Magma Ore", "Vampire Fang" },
		Sea_3 = { "Leather + Scrap Metal", "Demonic Wisp", "Conjured Cocoa", "Dragon Scale", "Gunpowder", "Fish Tail", "Mini Tusk", "Nightmare Catcher" }
	},
	BossNames = {
		Sea_1 = { "The Gorilla King", "Chief", "Yeti", "Vice Admiral", "Warden", "Chief Warden", "Swan", "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg", "Saw" },
		Sea_2 = { "Diamond", "Jeremy", "Orbitus", "Smoke Admiral", "Awakened Ice Admiral", "Tide Keeper", "Don Swan" },
		Sea_3 = { "Stone", "Kilo Admiral", "Captain Elephant", "Beautiful Pirate", "Cake Queen" }
	},
	MeleeNames = {
		Sea_1 = { "Black Leg", "Electro", "Fishman Karate" },
		Sea_2 = { "Death Step", "Dragon Claw", "Sharkman Karate", "Superhuman" },
		Sea_3 = { "Dragon Talon", "Electric Claw", "Godhuman", "Sanguine Art" }
	},
	Melees = {
		["Black Leg"] = {
			Model = "Dark Step Teacher",
			Npc = "Dark Step Teacher",
			npc = "Dark Step Teacher",
			CFrame = CFrame.new(-1147.284, 4.752, 3816.326),
			cframe = CFrame.new(-1147.284, 4.752, 3816.326),
			Remote = { "BuyBlackLeg" },
			remote = { "BuyBlackLeg" },
			Sea = 1
		},
		["Electro"] = {
			Model = "Mad Scientist",
			Npc = "Mad Scientist",
			npc = "Mad Scientist",
			CFrame = CFrame.new(-4842.112, 717.670, -2623.149),
			cframe = CFrame.new(-4842.112, 717.670, -2623.149),
			Remote = { "BuyElectro" },
			remote = { "BuyElectro" },
			Sea = 1
		},
		["Fishman Karate"] = {
			Model = "Water Kung-fu Teacher",
			Npc = "Water Kung-fu Teacher",
			npc = "Water Kung-fu Teacher",
			CFrame = CFrame.new(61122.652, 18.497, 1568.351),
			cframe = CFrame.new(61122.652, 18.497, 1568.351),
			Remote = { "BuyFishmanKarate" },
			remote = { "BuyFishmanKarate" },
			Sea = 1
		},
		["Dragon Claw"] = {
			Model = "Sabi",
			Npc = "Sabi",
			npc = "Sabi",
			CFrame = CFrame.new(699.029, 185.661, 654.895),
			cframe = CFrame.new(699.029, 185.661, 654.895),
			CFrames = {
				Sea_2 = CFrame.new(699.029, 185.661, 654.895),
			},
			cframes = {
				Sea_2 = CFrame.new(699.029, 185.661, 654.895),
			},
			Remote = { { "BlackbeardReward", "DragonClaw", "1" }, { "BlackbeardReward", "DragonClaw", "2" } },
			remote = { { "BlackbeardReward", "DragonClaw", "1" }, { "BlackbeardReward", "DragonClaw", "2" } },
			Sea = 2
		},
		["Superhuman"] = {
			Model = "Martial Arts Master",
			Npc = "Martial Arts Master",
			npc = "Martial Arts Master",
			CFrame = CFrame.new(1377.125, 246.542, -5189.951),
			cframe = CFrame.new(1377.125, 246.542, -5189.951),
			CFrames = {
				Sea_2 = CFrame.new(1377.125, 246.542, -5189.951),
			},
			cframes = {
				Sea_2 = CFrame.new(1377.125, 246.542, -5189.951),
			},
			Remote = { "BuySuperhuman" },
			remote = { "BuySuperhuman" },
			Sea = 2
		},
		["Death Step"] = {
			Model = "Phoeyu, the Reformed",
			Npc = "Phoeyu, the Reformed",
			npc = "Phoeyu, the Reformed",
			CFrame = CFrame.new(6356.472, 296.100, -6762.771),
			cframe = CFrame.new(6356.472, 296.100, -6762.771),
			CFrames = {
				Sea_2 = CFrame.new(6356.472, 296.100, -6762.771),
			},
			cframes = {
				Sea_2 = CFrame.new(6356.472, 296.100, -6762.771),
			},
			Remote = { "BuyDeathStep" },
			remote = { "BuyDeathStep" },
			Sea = 2
		},
		["Sharkman Karate"] = {
			Model = "Sharkman Teacher",
			Npc = "Sharkman Teacher",
			npc = "Sharkman Teacher",
			CFrame = CFrame.new(-2599.622, 238.198, -10315.998),
			cframe = CFrame.new(-2599.622, 238.198, -10315.998),
			CFrames = {
				Sea_2 = CFrame.new(-2599.622, 238.198, -10315.998),
			},
			cframes = {
				Sea_2 = CFrame.new(-2599.622, 238.198, -10315.998),
			},
			Remote = { "BuySharkmanKarate" },
			remote = { "BuySharkmanKarate" },
			Sea = 2
		},
		["Electric Claw"] = {
			Model = "Previous Hero",
			Npc = "Previous Hero",
			npc = "Previous Hero",
			CFrame = CFrame.new(-10368.514, 331.788, -10134.120),
			cframe = CFrame.new(-10368.514, 331.788, -10134.120),
			CFrames = {
				Sea_3 = CFrame.new(-10368.514, 331.788, -10134.120),
			},
			cframes = {
				Sea_3 = CFrame.new(-10368.514, 331.788, -10134.120),
			},
			Remote = { "BuyElectricClaw" },
			remote = { "BuyElectricClaw" },
			Sea = 3
		},
		["Dragon Talon"] = {
			Model = "Uzoth",
			Npc = "Uzoth",
			npc = "Uzoth",
			CFrame = CFrame.new(-9515.372, 142.130, 5535.089),
			cframe = CFrame.new(-9515.372, 142.130, 5535.089),
			CFrames = {
				Sea_3 = CFrame.new(-9515.372, 142.130, 5535.089),
			},
			cframes = {
				Sea_3 = CFrame.new(-9515.372, 142.130, 5535.089),
			},
			Remote = { "BuyDragonTalon" },
			remote = { "BuyDragonTalon" },
			Sea = 3
		},
		["Godhuman"] = {
			Model = "Ancient Monk",
			Npc = "Ancient Monk",
			npc = "Ancient Monk",
			CFrame = CFrame.new(-12463.870, 374.910, -7523.770),
			cframe = CFrame.new(-12463.870, 374.910, -7523.770),
			CFrames = {
				Sea_3 = CFrame.new(-12463.870, 374.910, -7523.770),
			},
			cframes = {
				Sea_3 = CFrame.new(-12463.870, 374.910, -7523.770),
			},
			Remote = { "BuyGodhuman" },
			remote = { "BuyGodhuman" },
			Sea = 3
		},
		["Sanguine Art"] = {
			Model = "Shafi",
			Npc = "Shafi",
			npc = "Shafi",
			CFrame = CFrame.new(-16548.800, 12.000, 412.300),
			cframe = CFrame.new(-16548.800, 12.000, 412.300),
			CFrames = {
				Sea_3 = CFrame.new(-16548.800, 12.000, 412.300),
			},
			cframes = {
				Sea_3 = CFrame.new(-16548.800, 12.000, 412.300),
			},
			Remote = { { "BuySanguineArt", true }, { "BuySanguineArt" } },
			remote = { { "BuySanguineArt", true }, { "BuySanguineArt" } },
			Sea = 3
		},
	},
	ItemsToBuy = {
		["Frags"] = {
			["Race Rerol"] = { "BlackbeardReward", "Reroll", "2" },
			["Reset Stats"] = { "BlackbeardReward", "Refund", "2" }
		},
		["Ability"] = {
			["Geppo"] = { "BuyHaki", "Geppo" },
			["Buso Haki"] = { "BuyHaki", "Buso" },
			["Soru"] = { "BuyHaki", "Soru" },
			["Observation Haki"] = { "KenTalk", "Buy" }
		},
		["Gun"] = {
			["Slingshot"] = { "BuyItem", "Slingshot" },
			["Musket"] = { "BuyItem", "Musket" },
			["Flintlock"] = { "BuyItem", "Flintlock" },
			["Refined Slingshot"] = { "BuyItem", "Refined Flintlock" },
			["Refined Flintlock"] = { "BuyItem", "Refined Flintlock" },
			["Cannon"] = { "BuyItem", "Cannon" },
			["Kabucha"] = { "BlackbeardReward", "Slingshot", "1" },
			["Bizarre Rifle"] = { "Ectoplasm", "Buy", 1 }
		},
		["Accessory"] = {
			["Black Cape"] = { "Black Cape" },
			["Swordsman Hat"] = { "Swordsman Hat" },
			["Tomoe Ring"] = { "Tomoe Ring" }
		},
		["Sword"] = {
			["Cutlass"] = { "Cutlass" },
			["Katana"] = { "Katana" },
			["Iron Mace"] = { "Iron Mace" },
			["Dual Katana"] = { "Duel Katana" },
			["Triple Katana"] = { "Triple Katana" },
			["Pipe"] = { "Pipe" },
			["Dual-Headed Blade"] = { "Dual-Headed Blade" },
			["Bisento"] = { "Bisento" },
			["Soul Cane"] = { "Soul Cane" },
			["Pole v.2"] = { "ThunderGodTalk" }
		}
	},
	Islands = {
		["Sea 1"] = {
			["Pirate Starter"] = CFrame.new(1047, 15, 1506),
			["Marine Starter"] = CFrame.new(-2728, 25, 2056),
			["Middle Town"] = CFrame.new(-688, 15, 1585),
			["Jungle"] = CFrame.new(-1614, 37, 146),
			["Pirate Village"] = CFrame.new(-1173, 45, 3837),
			["Desert"] = CFrame.new(944, 21, 4373),
			["Frozen Village"] = CFrame.new(1298, 87, -1344),
			["Marine Fortress"] = CFrame.new(-4810, 21, 4359),
			["Colosseum"] = CFrame.new(-1535, 7, -3014),
			["Lower Skylands"] = CFrame.new(-4814, 718, -2551),
			["Skylands"] = CFrame.new(-4652, 873, -1754),
			["Upper Skylands"] = CFrame.new(-7895, 5547, -380),
			["Prison"] = CFrame.new(4870, 6, 736),
			["Magma Village"] = CFrame.new(-5290, 9, 8349),
			["Underwater City"] = CFrame.new(61164, 5, 1820),
			["Fountain City"] = CFrame.new(5757, 91, 4017),
			["Jean-Luc Island"] = CFrame.new(-2850, 7, 5355),
		},
		["Sea 2"] = {
			["The Cafe"] = CFrame.new(-382, 73, 290),
			["First Spot"] = CFrame.new(-11, 29, 2771),
			["Dark Arena"] = CFrame.new(3494, 13, -3259),
			["Don Swan Mansion"] = CFrame.new(-317, 331, 597),
			["Don Swan Room"] = CFrame.new(2285, 15, 905),
			["Green Zone"] = CFrame.new(-2258, 73, -2696),
			["Graveyard"] = CFrame.new(-5552, 194, -776),
			["Snow Mountain"] = CFrame.new(752, 408, -5277),
			["Hot and Cold"] = CFrame.new(-6008, 29, -5018),
			["Cursed Ship"] = CFrame.new(919, 125, 32869),
			["Ice Castle"] = CFrame.new(5505, 40, -6178),
			["Forgotten Island"] = CFrame.new(-3050, 240, -10178),
			["Remote Island"] = CFrame.new(4816, 8, 2863),
		},
		["Sea 3"] = {
			["Mansion"] = CFrame.new(-12471, 374, -7551),
			["Port Town"] = CFrame.new(-340, 21, 5524),
			["Great Tree"] = CFrame.new(2205, 22, -6766),
			["Castle On The Sea"] = CFrame.new(-4980, 314, -3018),
			["Hydra Island"] = CFrame.new(5294, 1005, 391),
			["Floating Turtle"] = CFrame.new(-12528, 332, -8658),
			["Haunted Castle"] = CFrame.new(-9517, 142, 5528),
			["Ice Cream Land"] = CFrame.new(-843, 66, -10944),
			["Peanut Land"] = CFrame.new(-2082, 38, -10190),
			["Cake Land"] = CFrame.new(-1897, 14, -11576),
			["Candy Cane Land"] = CFrame.new(-1094, 64, -14519),
			["Chocolate Land"] = CFrame.new(219, 127, -12604),
			["Tiki Outpost"] = CFrame.new(-16224, 9, 439),
		}
	},
	PortalLocations = {
		Sea_1 = {
			Vector3.new(-7894.62, 5545.49, -380.25),
			Vector3.new(-4607.82, 872.54, -1667.56),
			Vector3.new(61163.85, 11.76, 1819.78),
			Vector3.new(3876.28, 35.11, -1939.32)
		},
		Sea_2 = {
			Vector3.new(-288.46, 306.13, 598),
			Vector3.new(2284.91, 15.15, 905.48),
			Vector3.new(923.21, 126.98, 32852.83),
			Vector3.new(-6508.56, 89.03, -132.84)
		},
		Sea_3 = {
			Vector3.new(-5058.77, 314.52, -3155.88),
			Vector3.new(-12463.87, 374.91, -7523.77),
			Vector3.new(28282.57, 14896.85, 105.1),
			Vector3.new(5661.53, 1013.09, -334.96),
			Vector3.new(5319, 23, -93),
			Vector3.new(5651, 1018, -350),
			Vector3.new(28286, 14897, 103)
		}
	},
	SwordData = {
		["Dark Blade"] = { Rarity = "Mythical", Order = 1 },
		["True Triple Katana"] = { Rarity = "Mythical", Order = 1 },
		["Cursed Dual Katana"] = { Rarity = "Mythical", Order = 1 },
		["Hallow Scythe"] = { Rarity = "Mythical", Order = 1 },
		["Triple Dark Blade"] = { Rarity = "Mythical", Order = 1 },
		["Dog Blade"] = { Rarity = "Mythical", Order = 1 },

		["Rengoku"] = { Rarity = "Legendary", Order = 2 },
		["Yama"] = { Rarity = "Legendary", Order = 2 },
		["Tushita"] = { Rarity = "Legendary", Order = 2 },
		["Buddy Sword"] = { Rarity = "Legendary", Order = 2 },
		["Shark Anchor"] = { Rarity = "Legendary", Order = 2 },
		["Fox Lamp"] = { Rarity = "Legendary", Order = 2 },
		["Dragon Trident"] = { Rarity = "Legendary", Order = 2 },
		["Saber"] = { Rarity = "Legendary", Order = 2 },
		["Canvander"] = { Rarity = "Legendary", Order = 2 },
		["Dark Dagger"] = { Rarity = "Legendary", Order = 2 },
		["Dragonheart"] = { Rarity = "Legendary", Order = 2 },
		["Koko"] = { Rarity = "Legendary", Order = 2 },
		["Midnight Blade"] = { Rarity = "Legendary", Order = 2 },
		["Oroshi"] = { Rarity = "Legendary", Order = 2 },
		["Pole (1st Form)"] = { Rarity = "Legendary", Order = 2 },
		["Pole (2nd Form)"] = { Rarity = "Legendary", Order = 2 },
		["Saishi"] = { Rarity = "Legendary", Order = 2 },
		["Shizu"] = { Rarity = "Legendary", Order = 2 },
		["Longsword"] = { Rarity = "Legendary", Order = 2 },
		["Pipe"] = { Rarity = "Legendary", Order = 2 },
		["Soul Cane"] = { Rarity = "Legendary", Order = 2 },
		["Trident"] = { Rarity = "Legendary", Order = 2 },
		["Wardens Sword"] = { Rarity = "Legendary", Order = 2 },
		["Bisento"] = { Rarity = "Legendary", Order = 2 },
		["Triple Katana"] = { Rarity = "Legendary", Order = 2 },
		["Twin Hooks"] = { Rarity = "Legendary", Order = 2 },
		["Dual-Headed Blade"] = { Rarity = "Legendary", Order = 2 },
		["Flail"] = { Rarity = "Legendary", Order = 2 },
		["Gravity Blade"] = { Rarity = "Legendary", Order = 2 },

		["Spikey Trident"] = { Rarity = "Rare", Order = 3 },
		["Fishing Trophy"] = { Rarity = "Rare", Order = 3 },
		["Shark Saw"] = { Rarity = "Rare", Order = 3 },

		["Iron Mace"] = { Rarity = "Uncommon", Order = 4 },

		["Cutlass"] = { Rarity = "Common", Order = 5 },
		["Katana"] = { Rarity = "Common", Order = 5 },
		["Dual Katana"] = { Rarity = "Common", Order = 5 },
	},
	BoatsList = {
		'Dinghy',
		'PirateSloop',
		'PirateBrigade',
		'PirateGrandBrigade',
		'MarineSloop',
		'MarineBrigade',
		'MarineGrandBrigade',
		'Beast Hunter',
		'Lantern',
		'Guardian',
		'Grand Brigade',
		'Sloop',
		'The Sentinel'
	},
	ZoneList = {
		'Level 1',
		'Level 2',
		'Level 3',
		'Level 4',
		'Level 5',
		'Level 6',
		'Infinite'
	},
	SeaEventTargets = {
		"Terror Shark",
		"Sea Beast",
		"Shark",
		"Piranha",
		"Fish Crew Member",
		"Pirate Brigade",
		"Pirate Grand Brigade",
		"Ghost Ship"
	},
	RodsList = {
		"Fishing Rod",
		"Gold Rod",
		"Shark Rod",
		"Shell Rod",
		"Treasure Rod",
		"Shark (Corrupted)",
		"Shell (Celestial)"
	},
	BaitsList = {
		"Basic Bait",
		"Kelp Bait",
		"Good Bait",
		"Abyssal Bait",
		"Frozen Bait",
		"Epic Bait",
		"Carnivore Bait"
	},
	DungeonCards = {
		"Hyper",
		"Overflow",
		"Fortress",
		"Shadow",
		"Sniper",
		"Lifesteal",
		"Unbreakable",
		"Health",
		"Defense",
		"Armor",
		"Melee",
		"Sword",
		"Fruit",
		"Gun"
	},
	TrainMethods = {
		"Bones",
		"Cakes"
	},
	LegendarySwordNames = {
		"Shizu",
		"Oroshi",
		"Saishi"
	},
	BossHopNames = {
		"Greybeard",
		"Darkbeard",
		"Cursed Captain",
		"rip_indra True Form",
		"Soul Reaper",
		"Cake Prince",
		"Dough King",
		"Tyrant of the Skies"
	},
	BossMap = {
		["Greybeard"] = "Greybeard",
		["Darkbeard"] = "Darkbeard",
		["Cursed Captain"] = "CursedCaptain",
		["rip_indra True Form"] = "Ripindra",
		["Soul Reaper"] = "SoulReaper",
		["Cake Prince"] = "CakePrince",
		["Dough King"] = "DoughKing",
		["Tyrant of the Skies"] = "Tyrant"
	},
	ScrollList = {
		"Common Scroll",
		"Rare Scroll",
		"Legendary Scroll",
		"Mythical Scroll"
	},
	ChestTiers = {
		"Diamond",
		"Gold",
		"Silver"
	},
	IgnoreNPC = {
		"Quest",
		"Boat",
		"Home"
	},
	DracoSequence = {
		"Relic1",
		"EndRelic1",
		"Relic2",
		"EndRelic2",
		"Relic3",
		"EndRelic3"
	},
	SwordList = {
		"Shizu",
		"Saishi",
		"Oroshi"
	},
	DealerFruitList = {
		"Rocket-Rocket",
		"Spin-Spin",
		"Blade-Blade",
		"Spring-Spring",
		"Bomb-Bomb",
		"Smoke-Smoke",
		"Spike-Spike",
		"Flame-Flame",
		"Ice-Ice",
		"Sand-Sand",
		"Dark-Dark",
		"Eagle-Eagle",
		"Diamond-Diamond",
		"Light-Light",
		"Rubber-Rubber",
		"Ghost-Ghost",
		"Magma-Magma",
		"Quake-Quake",
		"Buddha-Buddha",
		"Love-Love",
		"Creation-Creation",
		"Spider-Spider",
		"Sound-Sound",
		"Phoenix-Phoenix",
		"Portal-Portal",
		"Lightning-Lightning",
		"Pain-Pain",
		"Blizzard-Blizzard",
		"Gravity-Gravity",
		"Mammoth-Mammoth",
		"T-Rex-T-Rex",
		"Dough-Dough",
		"Shadow-Shadow",
		"Venom-Venom",
		"Gas-Gas",
		"Spirit-Spirit",
		"Tiger-Tiger",
		"Yeti-Yeti",
		"Kitsune-Kitsune",
		"Control-Control",
		"Dragon-Dragon"
	}
}

function hoangtuveu()
    local W = {Instances = {}}
    repeat task.wait() until game.CoreGui

    -- ============================================================
    -- STATUS UI (Dynamic Island style, with container)
    -- ============================================================
    local gui = Instance.new('ScreenGui')
    gui.Name = "KaitunUI"
    gui.Parent = game:GetService('CoreGui')
    gui.Enabled = true
    gui.ResetOnSpawn = true
    gui.DisplayOrder = 10
    gui.IgnoreGuiInset = false

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Parent = gui
    container.AnchorPoint = Vector2.new(0.5, 0)
    container.Position = UDim2.new(0.5, 0, 0.01, 0)
    container.AutomaticSize = Enum.AutomaticSize.XY
    container.Size = UDim2.new(0, 0, 0, 0)
    container.BackgroundTransparency = 1

    local containerLayout = Instance.new("UIListLayout", container)
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Padding = UDim.new(0, 4)
    containerLayout.FillDirection = Enum.FillDirection.Vertical
    containerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.Parent = container
    frame.LayoutOrder = 2
    frame.AutomaticSize = Enum.AutomaticSize.XY
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(14, 0, 4)
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0

    local padding = Instance.new("UIPadding", frame)
    padding.PaddingTop = UDim.new(0, 3)
    padding.PaddingBottom = UDim.new(0, 3)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 7)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 0, 60)
    stroke.Thickness = 1
    stroke.Transparency = 0
    game:GetService("TweenService"):Create(stroke, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.55}):Play()

    local layout = Instance.new("UIListLayout", frame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 1)
    layout.FillDirection = Enum.FillDirection.Vertical

    local features = Instance.new("Frame")
    features.Name = "Features"
    features.Parent = frame
    features.LayoutOrder = 1
    features.AutomaticSize = Enum.AutomaticSize.XY
    features.Size = UDim2.new(0, 0, 0, 0)
    features.BackgroundTransparency = 1

    local featLayout = Instance.new("UIListLayout", features)
    featLayout.SortOrder = Enum.SortOrder.LayoutOrder
    featLayout.Padding = UDim.new(0, 0)
    featLayout.FillDirection = Enum.FillDirection.Vertical

    local taskLabel = Instance.new("TextLabel")
    taskLabel.Name = "Task"
    taskLabel.Parent = features
    taskLabel.LayoutOrder = 1
    taskLabel.AutomaticSize = Enum.AutomaticSize.XY
    taskLabel.Size = UDim2.new(0, 0, 0, 0)
    taskLabel.BackgroundTransparency = 1
    taskLabel.Text = "Status :"
    taskLabel.TextSize = 11
    taskLabel.Font = Enum.Font.Ubuntu
    taskLabel.TextColor3 = Color3.fromRGB(255, 60, 95)
    taskLabel.TextXAlignment = Enum.TextXAlignment.Left

    local subTaskLabel = Instance.new("TextLabel")
    subTaskLabel.Name = "SubTask"
    subTaskLabel.Parent = features
    subTaskLabel.LayoutOrder = 2
    subTaskLabel.AutomaticSize = Enum.AutomaticSize.XY
    subTaskLabel.Size = UDim2.new(0, 0, 0, 0)
    subTaskLabel.BackgroundTransparency = 1
    subTaskLabel.Text = "Sub Task :"
    subTaskLabel.TextSize = 10
    subTaskLabel.Font = Enum.Font.Ubuntu
    subTaskLabel.TextColor3 = Color3.fromRGB(255, 60, 95)
    subTaskLabel.TextTransparency = 0
    subTaskLabel.TextXAlignment = Enum.TextXAlignment.Left

    W.Instances['Task1'] = taskLabel
    W.Instances['Task2'] = subTaskLabel
    W.Instances['MainTextLabel'] = taskLabel

    -- [FIX DISPLAY] "latest text wins": the old version spawned one fade per call, and fades that overlapped
    -- finished out of order (or were skipped because label.Text had not changed yet), leaving an OLD text on screen.
    -- Now each label keeps only the most recent wanted text and a single worker applies it.
    local FlowbrWantText, FlowbrTextBusy = {}, {}
    function SetText(key, text)
        text = FlowbrStripEmoji(text)
        if key == 'MainTextLabel' then key = 'Task1' end -- same label: share one worker
        FlowbrWantText[key] = text
        if FlowbrTextBusy[key] then return end
        FlowbrTextBusy[key] = true
        task.spawn(function()
            local ok, err = pcall(function()
                local ts = game:GetService("TweenService")
                while true do
                    task.wait() -- one frame: changes made and undone inside the same frame never reach the screen
                    local label = W.Instances[key]
                    if not label then return end
                    local want = FlowbrWantText[key]
                    if label.Text == want then return end
                    local fadeOut = ts:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1, TextStrokeTransparency = 1})
                    fadeOut:Play()
                    fadeOut.Completed:Wait()
                    label.Text = FlowbrWantText[key] -- always the latest wanted text
                    local fadeIn = ts:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0, TextStrokeTransparency = 0})
                    fadeIn:Play()
                    if FlowbrWantText[key] == label.Text then return end
                end
            end)
            FlowbrTextBusy[key] = false
        end)
    end
    getgenv().alert = function() end
    W.SetText = SetText
    W.ToggleUI = function() end
    W.ToggleInterface = function() end
    W.RegisterForBlur = function() end

    -- ============================================================
    -- CORE LOGIC (kept as-is, including fast attack and equip)
    -- ============================================================
    if false then
        spawn(function()
            pcall(loadstring(game:HttpGet("https://raw.githubusercontent.com/sucvatthieunang/Trackstat/refs/heads/main/cac")))
        end)
    end
    alert("info", "Endpoint reached")
    OldSessionTime = isfile and readfile and isfile('.tdif-' .. game.Players.LocalPlayer.Name) and tonumber(readfile(".tdif-" .. game.Players.LocalPlayer.Name)) or 0
    repeat
        task.wait()
        game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", Config.Team)
    until game.Players.LocalPlayer.Character
    alert("team assembled")
    repeat wait() until game.Players.LocalPlayer.Character
    spawn(function()
        game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild('NewIslandLOD', 9999):Destroy()
        game:GetService("Players")
        LocalPlayer.PlayerScripts:WaitForChild('IslandLOD', 9999):Destroy()
    end)
    alert('wait 1', 'ok')
    local J = {'RawConstants', "Utilly", "QuestManager", 'SpawnRegionLoader', 'TweenController', "AttackController", 'CombatController', 'FunctionsHandler', "Hooks", "Debug", "Hop", "Storage"}
    StartTick = tick()
    repeat
        task.wait()
    until SetText
    alert('load 2')
    SetText('MainTextLabel', 'Initalizing Script..')
    local J = "Rua_Hub/Blox_Fruit/Assets/"
    ScriptStorage = {IsInitalized = false, PlayerData = {}, Melees = {}, CurrentMeleeData = {}, Enemies = {}, Tools = {}, Backpack = {}, IgnoreStoreFruits = {}, Connections = {LocalPlayer = {}}, Task = {}, Tracebacks = {}, TaskController = {}, TracebackUpdater = {}, Interface = W, NPCs = {}, Map = {}}
    Players = game.Players
    LocalPlayer = Players.LocalPlayer
    Character = Players.LocalPlayer.Character
    Humanoid = Character:WaitForChild('Humanoid')
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    PlayerGui = LocalPlayer:WaitForChild('PlayerGui', 10)
    Lighting = game:GetService('Lighting')
    Services = {}
    setmetatable(Services, {__index = function(J, J) return game:GetService(J) end})
    setmetatable(ScriptStorage.Enemies, {__index = function(J, J) return Services.Workspace.Enemies:FindFirstChild(J) or Services.ReplicatedStorage:FindFirstChild(J) end})
    setmetatable(ScriptStorage.Map, {__index = function(J, J) return Services.Workspace.Map:FindFirstChild(J) or Services.Workspace:FindFirstChild(J) end})
    setmetatable(ScriptStorage.Tools, {__index = function(J, J) return LocalPlayer.Character:FindFirstChild(J) or (LocalPlayer:FindFirstChild('Backpack') and LocalPlayer.Backpack:FindFirstChild(J)) end})
    setmetatable(ScriptStorage.NPCs, {__index = function(J, J) if not J then return end; return workspace.NPCs:FindFirstChild(J) or game.ReplicatedStorage.NPCs:FindFirstChild(J) end})

    -- ============================================================
    -- [NEW] PANIC MODE + AUTO KEN - runs in its own task.spawn (outside TasksOrder)
    -- so it can react to low health immediately.
    -- ============================================================
    _G.PanicModeActive = false

    task.spawn(function()
        local escapeY = nil
        local panicStart = 0
        local peakHealth = 0     -- highest health seen on this character (used as the 100% reference)
        local lastChar = nil
        local lowStreak = 0      -- consecutive low readings (debounce)
        local aliveSince = 0
        while task.wait(Config.PanicMode.CheckInterval) do
            pcall(function()
                if not Config.PanicMode.Enabled then return end
                local char = LocalPlayer.Character
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")

                -- Dead / no character: reset everything so a respawned character is not sent to the sky.
                if not hum or not hrp or hum.Health <= 0 then
                    if _G.PanicModeActive then
                        _G.PanicModeActive = false
                        escapeY = nil
                    end
                    peakHealth, lowStreak, lastChar = 0, 0, nil
                    return
                end

                -- New character (respawn / server hop): reset readings and let the stats settle for 5s.
                if char ~= lastChar then
                    lastChar = char
                    peakHealth = 0
                    lowStreak = 0
                    aliveSince = os.clock()
                end
                peakHealth = math.max(peakHealth, hum.Health)
                if os.clock() - aliveSince < 5 then return end

                -- Health percentage. The reference max is never larger than the highest health
                -- actually seen, so a wrong/inflated MaxHealth cannot fake a "10% health" reading.
                local refMax = hum.MaxHealth
                if peakHealth > 0 and peakHealth < refMax then refMax = peakHealth end
                if refMax <= 0 then return end
                local pct = math.clamp(hum.Health / refMax * 100, 0, 100)

                if not _G.PanicModeActive then
                    -- Require 2 low readings in a row before panicking (debounce)
                    if pct < Config.PanicMode.LowHealthPercent then
                        lowStreak = lowStreak + 1
                    else
                        lowStreak = 0
                    end
                    if lowStreak >= 2 then
                        lowStreak = 0
                        -- Cancel any running tween first, otherwise it keeps pulling the character back down.
                        pcall(function() if TweenInstance then TweenInstance:Cancel() end end)
                        _G.PanicModeActive = true
                        panicStart = os.clock()
                        escapeY = hrp.Position.Y + Config.PanicMode.EscapeHeight
                        SetTask("MainTask", "PANIC MODE | Health " .. math.floor(pct) .. "% - flying up to hide")
                        hrp.CFrame = CFrame.new(hrp.Position.X, escapeY, hrp.Position.Z)
                    end
                else
                    -- Hiding up high - hold altitude while health recovers
                    if hrp.Position.Y < (escapeY or 0) - 50 then
                        pcall(function() if TweenInstance then TweenInstance:Cancel() end end)
                        hrp.CFrame = CFrame.new(hrp.Position.X, escapeY, hrp.Position.Z)
                    end
                    local hidden = os.clock() - panicStart
                    if pct >= Config.PanicMode.SafeHealthPercent or hidden > (Config.PanicMode.MaxHideSeconds or 40) then
                        SetTask("MainTask", "Health " .. math.floor(pct) .. "% - going back down to farm")
                        _G.PanicModeActive = false
                        escapeY = nil
                        lowStreak = 0
                    else
                        SetTask("SubTask", "PANIC MODE | Hiding up high - health " .. math.floor(pct) .. "%/" .. Config.PanicMode.SafeHealthPercent .. "%")
                    end
                end
            end)
        end
    end)

    -- [NEW] Auto Ken (Observation Haki) - keep trying until enabled, then stop
    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                if not Config.AutoKen then return end
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HasKen") then
                    return -- already enabled, stop spamming
                end
                Services.ReplicatedStorage.Remotes.CommE:FireServer("Ken", true)
            end)
        end
    end)


    function CreateTraceback(J, W) table.insert(ScriptStorage.Tracebacks, (GetCurrentDateTime() .. ' ( ' .. DispTime(os.time() - os.time(), true) .. ' ) after execution | ' .. J .. " | " .. W)) end
    function Report(message)
        pcall(function()
            print("[Kaitun Report]", tostring(message))
            CreateTraceback("Report", tostring(message))
        end)
    end
    function SetTask(J, W)
        if ScriptStorage.Task[J] == W then return end
        local a = {MainTask = "Task1", SubTask = 'Task2'}
        if a[J] then if SetText then SetText(a[J], J .. ' : ' .. W) end end
        ScriptStorage.Task[J] = W
        ScriptStorage.Task[J .. '-d'] = os.time()
    end
    Remotes = {}
    BindedMeleeNPCNames = {BlackLeg = 'Dark Step Teacher', Electro = "Mad Scientist", FishmanKarate = "Water Kung-fu Teacher", DeathStep = "Phoeyu, the Reformed", SharkmanKarate = 'Sharkman Teacher', DragonTalon = "Uzoth", ElectricClaw = 'Previous Hero', Godhuman = "Ancient Monk"}
    local J = {}
    setmetatable(Remotes, {__index = function(W, W)
        if W ~= 'CommF_' then
            print('captured unregistered signal', key)
            return Services.ReplicatedStorage.Remotes[W]
        end
        local W = {InvokeServer = function(a, ...)
            print('remote fired', ...)
            local a, h = ...
            if string.find(a, "Buy") == 1 and not h then
                local h = string.gsub(a, 'Buy', "")
                if BindedMeleeNPCNames then
                    if table.find(J, h) then
                        local a = ScriptStorage.NPCs[BindedMeleeNPCNames[h]]
                        if a then
                            local h = a.WorldPivot
                            if CaculateDistance(h) > 10 then
                                repeat
                                    wait(1)
                                    TweenController.Create(h.Position)
                                until CaculateDistance(h) < 10
                                task.wait(3)
                                Services.ReplicatedStorage.Remotes.CommF_:InvokeServer(...)
                            end
                        end
                    end
                end
            end
            return Services.ReplicatedStorage.Remotes.CommF_:InvokeServer(...)
        end}
        return W
    end})
    Tasks = {}
    function AwaitUntilPlayerLoaded(W, a)
        repeat task.wait() until W.Character and W.Character:FindFirstChild('Humanoid')
        local hum = W.Character.Humanoid
        repeat task.wait() until hum.Health > 0
    end
    function AddPoint()
        local W = {}
        local a
        for h, h in LocalPlayer.Data.Stats:GetChildren() do
            if h and h:FindFirstChild('Level') then W[h.Name] = h.Level.Value end
        end
        if W.Defense < MaxLevel and (W.Defense < (ScriptStorage.PlayerData.Level / 80) or MaxLevel - W.Melee < 100) then
            a = 'Defense'
        elseif W.Melee < MaxLevel then
            a = "Melee"
        else
            a = 'Sword'
        end
        Remotes.CommF_:InvokeServer("AddPoint", a, 999)
    end
    local W = {Currencies = {Level = "#00BFFF", Beli = "#00BFFF", Fragments = "#00BFFF"}, Races = {}}
function RefreshPlayerData()
    pcall(function()
        for a, a in LocalPlayer.Data:GetChildren() do 
            pcall(function() ScriptStorage.PlayerData[a.Name] = a.Value end) 
        end
    end)
    local a = ""
    for h, X in ScriptStorage.PlayerData do
        local w = W.Currencies[h]
        if w then a = a .. '<font color="' .. w .. '">' .. h .. "</font>: " .. X .. ' ' end
    end
    if ScriptStorage.Interface then SetText('Currencies', a) end
end
    function RefreshRace()
        local W, a = Remotes.CommF_:InvokeServer('Alchemist', "1"), Remotes.CommF_:InvokeServer("Wenlocktoad", "1")
        ScriptStorage.PlayerData.RaceLevel = 1
        if LocalPlayer.Character:FindFirstChild("RaceTransformed") then
            ScriptStorage.PlayerData.RaceLevel = 4
        elseif a == -2.0 then
            ScriptStorage.PlayerData.RaceLevel = 3
        elseif W == -2.0 then
            ScriptStorage.PlayerData.RaceLevel = 2
        end
    end
    function RefreshInventory()
        ScriptStorage.Backpack = {}
        local LP = game.Players.LocalPlayer
        local ok, Items = pcall(function() return require(game.ReplicatedStorage.ItemReplicationService)._UserCache[LP.UserId] end)
        if not ok or not Items then
            for W, W in Remotes.CommF_:InvokeServer('getInventory') do ScriptStorage.Backpack[W.Name] = W end
            return
        end
        local Q = Items:GetItems("Quantity")
        local M = Items:GetItems("Mastery")
        local C = require(game.ReplicatedStorage.ItemConfig)
        local W = require(game.ReplicatedStorage.Modules.CombatUtil)
        local mas = {}
        if M then for _, v in pairs(M) do mas[v.ItemId] = v.Value end end
        local function clean(s) return s:gsub(" %[.-%]", "") end
        for _, v in pairs(Q) do
            local id, qt = v.ItemId, v.Value
            local ty, dn = "?", ""
            pcall(function()
                local c = C.match(id):unwrap()
                if c and c.Index then ty = c.Index.IdType; dn = c.Index.DebugLabel end
            end)
            local name = clean(dn)
            if name ~= "" then
                local entry = {Name = name, Count = qt, ItemId = id}
                ScriptStorage.Backpack[name] = entry
                if ty == "Moveset" or ty == "PhysicalMoveset" then
                    local md = mas[id]
                    if md then
                        local wd = W:GetWeaponData(name)
                        if wd then
                            if tostring(wd.WeaponType):find("Sword") then
                                entry.Type = "Sword"
                                entry.Mastery = md
                                entry.MasteryRequirements = {[1] = 350}
                            else
                                ScriptStorage.Melees[name] = md
                            end
                        end
                    end
                end
            end
        end
    end
    function ResearchMoves(W)
        if W and tostring(W) == 'V' then
            if ScriptStorage.Connections.BurstCheck then
                ScriptStorage.Connections.BurstCheck:Disconnect()
                task.wait(1)
            end
            print('[ Debug ] Registering burst', W)
            ScriptStorage.Connections.BurstCheck = W.Cooldown:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                if EnablingBurstDebounce and os.time() - EnablingBurstDebounce < 10 then return end
                local a = W.Cooldown.AbsoluteSize.X
                if a < 3 then
                    EnablingBurstDebounce = os.time()
                    task.wait(5)
                    SendKey('V', 0)
                end
            end)
        end
    end
    function CheckMeleeBurstMove(W)
        if W.Name == "Black Leg" or W.Name == "Death Step" then
            local a = PlayerGui.Main.Skills:WaitForChild(W.Name, 9)
            ResearchMoves(a:WaitForChild("V"))
        end
    end
    function RefreshMelees(W)
        local a = ''
        for h, X in ScriptStorage.Melees do a = a .. h .. ": " .. X .. " " end
        a = a == '' and '[0]' or a
        if W then return a end
        if ScriptStorage.Interface then SetText('Melees', a) end
    end
    function MeleeCheck(W)
        print('Melee check', W)
        if W and typeof(W) == "Instance" and W:IsA("Tool") then
            if W.ToolTip == "Melee" then
                if ScriptStorage.Connections.Melees then ScriptStorage.Connections.Melees:Disconnect() end
                ScriptStorage.CurrentMeleeData.Name = W.Name
                pcall(function() ScriptStorage.Connections.Melees:Destroy() end)
                local lv = W:FindFirstChild("Level")
                if lv then
                    ScriptStorage.Connections.Melees = lv.Changed:Connect(function(a)
                        ScriptStorage.Melees[W.Name] = a
                        RefreshMelees()
                    end)
                    ScriptStorage.Melees[W.Name] = lv.Value
                end
                RefreshMelees()
            elseif string.find(tostring(W), "Fruit") then
                task.spawn(function()
                    if table.find(ScriptStorage.IgnoreStoreFruits, W:GetAttribute('OriginalName')) then return end
                    local a = Remotes.CommF_:InvokeServer("StoreFruit", W:GetAttribute("OriginalName"), W)
                end)
            end
        end
    end
    SetText('MainTextLabel', 'Refreshing Player Data')
    MeleeCheck(LocalPlayer.Character:FindFirstChildOfClass('Tool'))
    RefreshPlayerData()
    function RegisterLocalPlayerEventsConnection()
        task.spawn(function()
            -- [FIXED] Shorter delay (6s -> 3s): enough for Character/Data to settle after spawn before checking HasBuso.
            task.wait(3)
            if LocalPlayer.Character:FindFirstChild('HasBuso') then return end
            Remotes.CommF_:InvokeServer("Buso")
        end)
        for W, W in ScriptStorage.Connections.LocalPlayer do pcall(function() W:Disconnect() end) end
        AwaitUntilPlayerLoaded(LocalPlayer)
        LocalPlayer:SetAttribute("IsAvailable", true)
        ScriptStorage.Connections.LocalPlayer["HealthCheck"] = LocalPlayer.Character:WaitForChild("Humanoid"):GetPropertyChangedSignal("Health"):Connect(function()
            local W = LocalPlayer.Character.Humanoid.Health
            LocalPlayer:SetAttribute("IsAvailable", W > 10)
            ScriptStorage.LocalPlayerHealth = W
        end)
        ScriptStorage.Connections.LocalPlayer['Melee'] = LocalPlayer.Character.ChildAdded:Connect(MeleeCheck)
        local bp = LocalPlayer:WaitForChild("Backpack")
        ScriptStorage.Connections.LocalPlayer['Fruit'] = bp.ChildAdded:Connect(MeleeCheck)
        for _, c in ipairs(bp:GetChildren()) do MeleeCheck(c) end
        LastIdleCheck = os.time()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        ScriptStorage.Connections.LocalPlayer.PositionChecker = hrp:GetPropertyChangedSignal('CFrame'):Connect(function()
            if os.time() == LastIdleCheck then return end
            LastIdleCheck = os.time()
            if oldPos then
                if (hrp.CFrame.p - oldPos).magnitude < 2 then return end
            end
            oldPos = (hrp.CFrame.p)
            LastIdling = os.time()
        end)
        local W = LocalPlayer.Data:WaitForChild('Points')
        ScriptStorage.Connections.LocalPlayer.PointConnection = W:GetPropertyChangedSignal('Value'):Connect(function()
            local W = LocalPlayer.Data:WaitForChild('Points')
            if OldPointValue == W then return end
            OldPointValue = W
            AddPoint()
        end)
    end
    RegisterLocalPlayerEventsConnection(LocalPlayer)
    game.Players.LocalPlayer.CharacterAdded:Connect(function(W)
        print('[ Debug ] re-registering events')
        RegisterLocalPlayerEventsConnection(LocalPlayer)
    end)
    task.spawn(function()
        task.wait(3)
        if LocalPlayer.Character:FindFirstChild("HasBuso") then return end
        Remotes.CommF_:InvokeServer("Buso")
    end)
    print(1)

    -- ============================================================
    -- MELEE TABLES & DATA (kept as-is)
    -- ============================================================
    MeleesTable = {"Black Leg", 'Electro', "Fishman Karate", "Dragon Claw", "Superhuman", 'Death Step', 'Electric Claw', 'Sharkman Karate', 'Dragon Talon', "Godhuman"}
    MeleesId = {'BlackLeg', "Electro", 'FishmanKarate', "DragonClaw", "Superhuman", 'DeathStep', "ElectricClaw", "SharkmanKarate", 'DragonTalon', 'Godhuman'}
    MeleePrices = {["Black Leg"] = {Price = {Beli = 150000}, Id = "BlackLeg", NextLevelRequirement = 300, position = CFrame.new(), Requirements = function() return true end, Buy = function(W) return BuyMelee("BlackLeg", W, 'Dark Step Teacher') end}, ['Electro'] = {Price = {Beli = 500000}, Id = 'Electro', NextLevelRequirement = 300, Requirements = function() return true end, Buy = function(W) return BuyMelee('Electro', W, "Mad Scientist") end}, ['Fishman Karate'] = {Price = {Beli = 750000}, NextLevelRequirement = 300, Requirements = function() return true end, Buy = function(W) return BuyMelee('FishmanKarate', W, 'Water Kung-fu Teacher') end}, ['Dragon Claw'] = {Price = {Fragments = 1500}, NextLevelRequirement = 300, Requirements = function() return true end, Buy = function(W) return BuyMelee("DragonClaw", W, "Sabi") end}, ["Superhuman"] = {Price = {Beli = 3000000}, NextLevelRequirement = nil, Requirements = function() return true end, Buy = function(W) return BuyMelee("Superhuman", W, "Martial Arts Master") end}, ["Death Step"] = {Price = {Beli = 2500000, Fragments = 5000}, NextLevelRequirement = 400, Requirements = function() return true end, Buy = function(W) return BuyMelee("DeathStep", W, "Phoeyu, the Reformed") end}, ['Sharkman Karate'] = {Price = {Beli = 2500000, Fragments = 5000}, NextLevelRequirement = 400, Requirements = function() return true end, Buy = function(W) return BuyMelee('SharkmanKarate', W, 'Sharkman Teacher') end}, ['Electric Claw'] = {Price = {Beli = 2500000, Fragments = 5000}, NextLevelRequirement = 400, Requirements = function() return true end, Buy = function(W) return BuyMelee("ElectricClaw", W, 'Previous Hero') end}, ['Dragon Talon'] = {Price = {Beli = 2500000, Fragments = 5000}, NextLevelRequirement = 400, Requirements = function() return true end, Buy = function(W) return BuyMelee("DragonTalon", W, 'Uzoth') end}, ["Godhuman"] = {Price = {Beli = 5000000, Fragments = 5000}, NextLevelRequirement = 400, Requirements = function() return true end, Buy = function(W) return BuyMelee("Godhuman", W, 'Ancient Monk') end}}
    DropItemData = {['Buddy Sword'] = {Sea = 3, Level = 1500, Boss = "Cake Queen"}, ['Canvander'] = {Sea = 3, Level = 1500, Boss = "Beautiful Pirate"}, ['Twin Hooks'] = {Sea = 3, Level = 1500, Boss = 'Captain Elephant'}, ["Venom Bow"] = {Sea = 3, Level = 1500, Boss = "Hydra Leader"}}
    GodhumanMaterials = {['Fish Tail'] = {20, 3, {"Fishman Raider", "Fishman Captain"}, {'DeepForestIsland3', 1, 1775, 'Turtle Adventure Quest Giver'}}, ['Dragon Scale'] = {10, 3, {"Dragon Crew Warrior", "Dragon Crew Archer"}, {'DragonCrewQuest', 1, 1575, 'Dragon Crew Quest Giver'}}, ["Magma Ore"] = {20, 2, {'Magma Ninja'}, {"FireSideQuest", 1, 1100, "Fire Quest Giver"}}, ["Mystic Droplet"] = {10, 2, {'Sea Soldier', 'Water Fighter'}, {'ForgottenQuest', 2, 1425, 'Forgotten Quest Giver'}}}
    SeaIndexes = {"Main", "Dressrosa", "Zou"}

    -- [FIXED - IMPORTANT] RefreshTasksData is first-match-wins: the first handler whose Refresh()
    -- returns a value wins the tick and the rest are skipped. LevelFarm almost always returns a value,
    -- so boss tasks placed after it never ran. Boss farming, raids and melee training now come BEFORE
    -- LevelFarm; each of them returns nil when it has nothing to do, letting the next one run.
    -- Saber / CursedDualKatana / SoulGuitar / EvoRace / RaceAwakening must stay in this list or they never run.
    TasksOrder = {
        "SpecialBossesTask", "SwordBossTask", "BossesTask",
        "RaidController", "AutoRaidIce",
        "CakePrinceTask", "MeleesController",
        "LevelFarm", "Tushita", 'Yama',
        "Saber", "CursedDualKatana", "SoulGuitar", "EvoRace", "RaceAwakening",
        -- [FIXED] Removed 'Wenlocktoad' and 'ExpRedeem' (registered but have no Refresh/Start) and the duplicate 'ThirdSeaPuzzle'.
        'Trevor', "UtillyItemsActivitation", 'ColosseumPuzzle', "ThirdSeaPuzzle", "PirateRaid", "SecondSeaPuzzle", "CollectDrops"}
    MaxLevel = 2800
    placeId = game.PlaceId
    if placeId == 85211729168715 or placeId == 2753915549 then
        Sea = 'Main'
        SeaIndex = 1
    elseif placeId == 79091703265657 or placeId == 4442272183 then
        Sea = "Dressrosa"
        SeaIndex = 2
    elseif placeId == 100117331123089 or placeId == 7449423635 then
        Sea = "Zou"
        SeaIndex = 3
    end
    Portals = ({{Vector3.new(-7894.6201171875, 5545.49169921875, -380.246346191406), Vector3.new(-4607.82275390625, 872.5422973632812, -1667.556884765625), Vector3.new(61163.8515625, 11.759522438049316, 1819.7841796875), Vector3.new(3876.280517578125, 35.10614013671875, -1939.3201904296875)}, {Vector3.new(-288.46246337890625, 306.130615234375, 597.9988403320312), Vector3.new(2284.912109375, 15.152046203613281, 905.48291015625), Vector3.new(923.21252441406, 126.9760055542, 32852.83203125), Vector3.new(-6508.5581054688, 89.034996032715, -132.83953857422)}, {}})[SeaIndex]
    -- [FIXED] Removed 'Cake Prince' from this list - CakePrinceTask handles it, avoiding two systems fighting one boss.
    BossesOrder = {"Awakened Ice Admiral", "Tide Keeper", 'Deandre', "Urban", "Diablo", 'Soul Reaper'}
    BossesOrderLevel = {['Awakened Ice Admiral'] = 700, ['Tide Keeper'] = 700, ['Deandre'] = 1500, ['Urban'] = 1500, ['Diablo'] = 1500, ['Soul Reaper'] = 1500}
    BossesOrderWL = {["Deandre"] = 1500, ["Urban"] = 1500, ["Diablo"] = 1500, ['Don Swan'] = 1100, ["Awakened Ice Admiral"] = 700, ['Tide Keeper'] = 700}
    -- [ADDED] Katakuri level (2150) is a safe guess - fix it if wrong.
    -- 'Beautiful Pirates' (not Cake Prince): position taken from a verified file, level unconfirmed (1500).
    SpecialBossesOrder = {["Core"] = 700, ['Darkbeard'] = 700, ["Katakuri"] = 2150, ["Beautiful Pirates"] = 1500}
    -- [NEW] Haunted Castle bones farming position (Fire Essence, Hallow Essence, Yama/Tushita)
    HAUNTED_CASTLE_BONES_CF = CFrame.new(-8817.880859375, 191.16761779785, 6298.6557617188)
    BeautifulPiratesCF = CFrame.new(5319, 23, -93)

    -- Config.Sword and Config.BossWeapons now live at the top of the file (Config block)
    BlankTablets = {"Segment6", 'Segment2', 'Segment8', "Segment9", 'Segment5'}
    Trophy = {["Segment1"] = "Trophy1", ["Segment3"] = "Trophy2", ['Segment4'] = "Trophy3", ['Segment7'] = "Trophy4", ["Segment10"] = "Trophy5"}
    Pipes = {['Part1'] = 'Really black', ['Part2'] = 'Really black', ["Part3"] = "Dusty Rose", ['Part4'] = "Storm blue", ['Part5'] = 'Really black', ['Part6'] = "Parsley green", ["Part7"] = 'Really black', ["Part8"] = "Dusty Rose", ["Part9"] = 'Really black', ['Part10'] = 'Storm blue'}
    function GenerateUUID()
        local W = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
        return string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", '[xy]', function(W)
            local W = (Idx == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
            return string.format('%x', W)
        end)
    end
    function CheckIsPlayerAlive(W) W = W or LocalPlayer; return W and W.Character and W.Character.Humanoid and W.Character.HumanoidRootPart and W.Character.Head and W.Character.Humanoid.Health > 0 end
    function ConvertTo(W, a) return W.new(a.X, a.Y, a.Z) end
    function CaculateDistance(W, a)
        if not W then return 0 end
        a = a or game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        local h, X = ConvertTo(Vector3, W), ConvertTo(Vector3, a)
        return (h - X).magnitude
    end
    function DispTime(W, a)
        W = tonumber(W)
        if not W then return "[err]" end
        local h = math.floor(W / 86400)
        local X = math.floor(math.fmod(W, 86400) / 3600)
        local w = math.floor(math.fmod(W, 3600) / 60)
        local D = math.floor(math.fmod(W, 60))
        if a then return (h .. "day, " .. X .. "hrs, " .. w .. "min, " .. D .. 'sec.') end
        return (h .. 'day, ' .. X .. "hrs.")
    end
    function GetCurrentDateTime()
        local W = os.date("*t")
        local a = W.hour
        local h = W.min
        local X = W.day
        local w = W.month
        local D = W.year
        local y = W.wday
        local W = string.format('%02d:%02d ', a, h)
        local a = {'Sun', "Mon", 'Tue', "Wed", 'Thu', "Fri", 'Sat'}
        local h = a[y]
        local a = {"Jan", "Feb", "Mar", 'Apr', "May", 'Jun', "Jul", 'Aug', 'Sep', "Oct", 'Nov', "Dec"}
        local y = a[w]
        local a = string.format('%s, %s %d %d', h, y, X, D)
        return W .. a
    end
    function RandomArguments(...) local W = {...}; return W[math.random(0, #W)] end
    function RoundVector3Down(W) return Vector3.new(math.floor(W.X / 10) * 10, math.floor(W.Y / 10) * 10, math.floor(W.Z / 10) * 10) end

    -- ============================================================
    -- TICK-BASED CIRCULAR MOTION
    -- [FIXED] W_angle/lastChange were never initialised and crashed on first call; now initialised before use.
    W_angle = W_angle or 0
    lastChange = lastChange or tick()

    -- [UPDATED] Speed changed to 0.01s / 20 degrees (smoother than 0.4s / 80 degrees).
    CaculateCircreDirection = function(a)
        if W_angle > 50000 then W_angle = 60 end
        W_angle = W_angle + ((tick() - lastChange) > 0.01 and 20 or 0)
        if tick() - lastChange > 0.01 then lastChange = tick() end
        local h = a + Vector3.new(math.cos(math.rad(W_angle)) * 40, 0, math.sin(math.rad(W_angle)) * 40)
        return CFrame.new(RoundVector3Down(h.p))
    end

    function GetMonAsSortedRange()
        local W = {}
        table.foreach(Services.Workspace.Enemies:GetChildren(), function(a, a)
            if a and a:FindFirstChild('Humanoid') and a:FindFirstChild("HumanoidRootPart") and a.Humanoid.Health > 0 then
                table.insert(W, a)
            end
        end)
        table.foreach(game.ReplicatedStorage:GetChildren(), function(a, a)
            if a and a:FindFirstChild('Humanoid') and a:FindFirstChild("HumanoidRootPart") and a.Humanoid.Health > 0 then
                table.insert(W, a)
            end
        end)
        table.sort(W, function(a, h) return CaculateDistance(a.HumanoidRootPart.CFrame) < CaculateDistance(h.HumanoidRootPart.CFrame) end)
        return W
    end
    print(1.5)
    function GetMeleeIdByName(W) for a, h in MeleesTable do if h == W then return MeleesId[a] end end end
    function FindMeleeNPC(npcName)
        for _, npc in pairs(workspace.NPCs:GetChildren()) do
            if npc.Name == npcName and npc:FindFirstChild("HumanoidRootPart") then
                return npc.HumanoidRootPart.Position
            end
        end
        return nil
    end
    function getpos(W)
        for a, a in game:GetService("ReplicatedStorage").NPCs:GetChildren() do if a.Name == W then return a.HumanoidRootPart.CFrame end end
        for a, a in workspace.NPCs:GetChildren() do if a.Name == W then return a.HumanoidRootPart.CFrame end end
    end

    -- ============================================================
    -- AUTO FULL MELEE HELPERS
    -- ============================================================
    function GetBP(meleeName)
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp and bp:FindFirstChild(meleeName) then return bp[meleeName] end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild(meleeName) then return char[meleeName] end
        return nil
    end

    function GetM(matName)
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if not bp then return 0 end
        for _, v in pairs(bp:GetChildren()) do
            if v.Name == matName and v:FindFirstChild("Count") then
                return v.Count.Value
            end
        end
        return 0
    end

    function GetConnectionEnemies(enemyName)
        local nearest, dist = nil, math.huge
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
            if enemy.Name == enemyName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                local root = enemy:FindFirstChild("HumanoidRootPart")
                if root then
                    local d = (root.Position - hrp.Position).Magnitude
                    if d < dist then
                        dist = d
                        nearest = enemy
                    end
                end
            end
        end
        return nearest
    end

    function BuyMelee(W, a)
        if W == "DragonClaw" then
            if workspace.NPCs:FindFirstChild('Sabi') then
                if a then
                    if type(Remotes.CommF_:InvokeServer("BlackbeardReward", 'DragonClaw', '1') == 1) == "number" and Remotes.CommF_:InvokeServer('BlackbeardReward', 'DragonClaw', '1') == 1 == 1 and not table.find(J, W) then table.insert(J, W) end
                    return Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "1")
                end
                return Remotes.CommF_:InvokeServer('BlackbeardReward', "DragonClaw", '2')
            end
        end
        if W == "Godhuman" then
            -- [FIXED] BuyGodhuman must be called twice (true, then no args) - same pattern as Dragon Talon.
            Remotes.CommF_:InvokeServer("BuyGodhuman", true)
            local result = Remotes.CommF_:InvokeServer("BuyGodhuman")
            if not table.find(J, W) then table.insert(J, W) end
            return result
        end
        if a then
            local a = Remotes.CommF_:InvokeServer('Buy' .. W, true)
            print("Response_", a == 1, typeof(a))
            if type(a) == 'number' and not table.find(J, W) then table.insert(J, W) end
            return a == 1
        end
        return Remotes.CommF_:InvokeServer("Buy" .. W)
    end

    function SendKey(J, W)
        (function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, J, false, game)
            task.wait(W)
            game:GetService('VirtualInputManager'):SendKeyEvent(false, J, false, game)
        end)()
    end

    function FruitIdToName(J)
        local W = string.match(J, "((%u)[^%-]+)$")
        return W .. ' Fruit'
    end
    function Split(J, W)
        if W == nil then W = "%s" end
        local a = {}
        for h in string.gmatch(J, '([^' .. W .. ']+)') do table.insert(a, h) end
        return a
    end
    function FruitNameToId(J)
        local W = Split(J)[1]
        return W .. '-' .. W
    end

    -- ============================================================
    -- J QUESTS
    -- ============================================================
    local J = {CurrentLevel = 2, DoubleQuest = true, CurrentQuests = {}, BlacklistedQuestIds = {BartiloQuest = 1, CitizenQuest = 1, Trainees = 1, MarineQuest = 1, ImpelQuest = 1}}
    SetText('MainTextLabel', 'Loading Quest Data..')
    local W = select(2, pcall(function() return require(game.ReplicatedStorage.GuideModule).Data.NPCList end))
    if type(W) ~= "table" then W = {} end
    do
        -- [FIX] never wait forever for DataLoaded (could freeze the script on "Refreshing Player Data")
        local t0 = os.clock()
        repeat task.wait() until game.Players.LocalPlayer:FindFirstChild("DataLoaded") or os.clock() - t0 > 15
    end
    pcall(function() J.Quests = require(game.ReplicatedStorage.Quests) end)
    J.Quests = J.Quests or {}
    function J.Set(W, a, h) W[a] = h end
    function J.RefreshQuest(W)
        local timeout = os.time()
        while not ScriptStorage.PlayerData.Level do
            task.wait(1)
            print('[ Debug ] Waiting for LocalPlayer datas.')
            if os.time() - timeout > 30 then
                print('[ Debug ] Timeout waiting for player data, skipping quest refresh')
                return
            end
        end
        local a = 0
        local h
        for X, w in J.Quests do
            if not J.BlacklistedQuestIds[X] then
                if (w[1].LevelReq >= a and w[1].LevelReq <= ScriptStorage.PlayerData.Level) then
                    a = w[1].LevelReq
                    h = w
                    W.CurrentQuestId = X
                    if ScriptStorage.PlayerData.Level >= 1500 and SeaIndex == 2 and X == 'ForgottenQuest' then break end
                end
            end
        end
        local a = h[#h]
        for X, X in a.Task do if X == 1 then table.remove(h, #h) end end
        for a, X in require(game.ReplicatedStorage.GuideModule).Data.NPCList do
            for w, w in X.Levels do if w == h[#h].LevelReq then W.CurrentNpc = a.CFrame end end
        end
        W.CurrentQuests = h
    end
    function J.GetCurrentQuest(W)
        local a = W.CurrentQuests[W.CurrentLevel] and W.CurrentQuests[W.CurrentLevel].LevelReq <= ScriptStorage.PlayerData.Level and W.CurrentLevel or 1
        for h in W.CurrentQuests[a].Task do return h, W.CurrentNpc, W.CurrentQuestId, a, W.CurrentQuests[a].Name end
    end
    function J.MarkAsCompleted(W) W.CurrentLevel = W.CurrentLevel == 2 and 1 or 2 end
    function J.AbandonQuest()
        print('Abandon Quest')
        Remotes.CommF_:InvokeServer("AbandonQuest")
    end
    function J.GetCurrentClaimQuest(W)
        local W = game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible and game.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text:gsub("%s*Defeat%s*(%d*)%s*(.-)%s*%b()", '%2')
        return (type(W) == "string" and string.gsub(W, "Military ", "Mil. ") or W), game.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
    end
    function J.StartQuest(W, a)
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer('ColorsDealer', "2")
        return Remotes.CommF_:InvokeServer("StartQuest", W, a)
    end

    -- ============================================================
    -- SCRIPTSTORAGE MOB REGIONS
    -- ============================================================
    ScriptStorage.MobRegions = {}
    SetText('MainTextLabel', 'Loading Mob Regions..')
    pcall(function()
        local folder = game:GetService("ReplicatedStorage"):FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
        if not folder then return end
        for W, W in folder:GetChildren() do
            ScriptStorage.MobRegions[tostring(W)] = ScriptStorage.MobRegions[tostring(W)] or {}
            table.insert(ScriptStorage.MobRegions[tostring(W)], W.CFrame)
        end
    end)

    -- ============================================================
    -- TWEEN CONTROLLER
    -- ============================================================
    TweenController = {}

    -- [ADDED] Block tween ported from Red Magic Hub: tween an invisible Part and let the character follow it
    -- (getgenv().OnFarm) instead of setting HumanoidRootPart CFrame every frame (avoids anti-cheat detection).
    local block = Instance.new("Part", workspace)
    block.Size = Vector3.new(1, 1, 1)
    block.Name = "Rip_Indra"
    block.Anchored = true
    block.CanCollide = false
    block.CanTouch = false
    block.Transparency = 1
    do
        local blockfind = workspace:FindFirstChild(block.Name)
        if blockfind and blockfind ~= block then blockfind:Destroy() end
    end
    task.spawn(function()
        while task.wait() do
            if block and block.Parent == workspace then
                getgenv().OnFarm = shouldTween and true or false
            else
                getgenv().OnFarm = false
            end
        end
    end)
    task.spawn(function()
        local a = game.Players.LocalPlayer
        repeat task.wait() until a.Character and a.Character.PrimaryPart
        block.CFrame = a.Character.PrimaryPart.CFrame
        while task.wait() do
            pcall(function()
                if getgenv().OnFarm then
                    if block and block.Parent == workspace then
                        local b = a.Character and a.Character.PrimaryPart
                        if b and (b.Position - block.Position).Magnitude <= 200 then
                            b.CFrame = block.CFrame
                        else
                            block.CFrame = b.CFrame
                        end
                    end
                    local c = a.Character
                    if c then
                        for _, e in pairs(c:GetChildren()) do
                            if e:IsA("BasePart") then e.CanCollide = false end
                        end
                    end
                else
                    local c = a.Character
                    if c then
                        for _, e in pairs(c:GetChildren()) do
                            if e:IsA("BasePart") then e.CanCollide = true end
                        end
                    end
                end
            end)
        end
    end)

    local W = 0
    local W = {}
    for a, a in game.ReplicatedStorage.NPCs:GetChildren() do if a.Name == 'Set Home Point' then table.insert(W, a:GetModelCFrame()) end end
    function TweenController.Update()
        local a = game.Players.LocalPlayer.Character.HumanoidRootPart
        HumanoidRootPart = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        if CaculateDistance(a.CFrame) > 250 then
            pcall(function() TweenInstance:Cancel() end)
            TweenDebounce = true
            a.CFrame = HumanoidRootPart.CFrame
            TweenDebounce = false
        end
        HumanoidRootPart.CFrame = a.CFrame + Vector3.new(0, 3, 0)
    end
    function GetPortal(a)
        local h, X = 9e9, nil
        for w, w in Portals do
            local D = CaculateDistance(w, a)
            if D < (CaculateDistance(a) - 300) and D < h then
                h = D
                X = w
            end
        end
        if X then
            Remotes.CommF_:InvokeServer("requestEntrance", X)
            return task.wait()
        end
    end
    function GetEntries(a)
        local h, X = 9e9, nil
        for w, w in W do
            local W = CaculateDistance(w, a)
            if W < (CaculateDistance(a) - 700) and W < h then
                h = W
                X = w
            end
        end
        if X then if os.time() - 0 > 30 then for W = 1, 10, 1 do task.wait() end end end
    end
    function TweenController.Tween2(W, a)
        TweenInstance2 = Services.TweenService:Create(W, TweenInfo.new(CaculateDistance(W.CFrame, a) / 50, Enum.EasingStyle.Linear), {CFrame = ConvertTo(CFrame, a) - Vector3.new(0, 0, 0)})
        TweenInstance2:Play()
    end
    function CheckItem(itemName)
        local bp = game.Players.LocalPlayer:FindFirstChild('Backpack')
        for _, v in next, bp and bp:GetChildren() or {} do
            if v:IsA('Tool') and (v.Name == itemName or string.find(v.Name, itemName)) then return v end
        end
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, v in next, char:GetChildren() do
                if v:IsA('Tool') and (v.Name == itemName or string.find(v.Name, itemName)) then return v end
            end
        end
        return false
    end

    -- [FIX7] A melee you OWN is not always a Tool in Backpack/Character (only the equipped style is).
    -- Ownership also comes from the inventory data (ScriptStorage.Melees / ScriptStorage.Backpack).
    function OwnsMelee(name)
        if CheckItem(name) then return true end
        if ScriptStorage.Melees and ScriptStorage.Melees[name] ~= nil then return true end
        if ScriptStorage.Backpack and ScriptStorage.Backpack[name] ~= nil then return true end
        return false
    end

    -- [FIXED] Bypass-teleport functions removed entirely; normal tweening is used everywhere.

    -- ============================================================
    -- TWEEN CONTROLLER (200/190 kept)
    -- ============================================================
    function TweenController.Create(W)
        if not W or TweenDebounce or _G.PanicModeActive then return end
        local a = typeof(W) ~= 'CFrame' and ConvertTo(CFrame, W) or W
        if TweenInstance then pcall(function() TweenInstance:Cancel() end) end
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- [FIXED] Removed the BypassTP branch (dist >= 4000); every distance uses the normal block tween.
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        local head = character:WaitForChild("Head")
        if not head:FindFirstChild("eltrul") then
            local bv = Instance.new('BodyVelocity')
            bv.Name = "eltrul"
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Velocity = Vector3.zero
            bv.Parent = head
        end
        if CaculateDistance(a) > 500 then
            if SeaIndex == 3 and not ScriptStorage.Backpack['Valkyrie Helm'] then
            elseif SeaIndex ~= 3 then
                GetPortal(a)
            end
        end
        if CaculateDistance(Vector3.new(11256, -2138.0, 9888), a) < (CaculateDistance(a) - 700) and SeaIndex == 3 then
            local gatePos = CFrame.new(-16269.0, 23, 1371)
            if CaculateDistance(gatePos) > 60 then
                TweenController.Create(gatePos)
                task.wait(1)
                return
            end
            local net = require(game.ReplicatedStorage.Modules.Net)
            net:RemoteFunction('SubmarineWorkerSpeak'):InvokeServer('TravelToSubmergedIsland')
        end

        a = CFrame.new(a.Position)
        local dist = CaculateDistance(hrp.CFrame, a)

        if dist <= 5 then
            hrp.CFrame = a
            block.CFrame = a
            return
        end

        -- [FIXED] Single fixed tween speed of 160 (never faster).
        local divisor = 160
        local duration = dist / divisor

        -- [FIXED] Block tween: the character follows an invisible Part via the sync loop (getgenv().OnFarm).
        shouldTween = true
        TweenInstance = Services.TweenService:Create(block, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = a})
        TweenInstance:Play()
        task.spawn(function()
            while TweenInstance and TweenInstance.PlaybackState == Enum.PlaybackState.Playing do
                if not shouldTween then
                    pcall(function() TweenInstance:Cancel() end)
                    break
                end
                task.wait(0.1)
            end
            shouldTween = false
        end)
    end

    -- ============================================================
    -- FAST ATTACK & EQUIP WEAPON (kept as-is)
    -- ============================================================
    local W = {}
    local a = game:GetService('Players')
    local h = game:GetService("RunService")
    local h = game:GetService('ReplicatedStorage')
    local X = game:GetService("Workspace")
    local X = game:GetService("VirtualInputManager")
    local X = a.LocalPlayer
    SetText('MainTextLabel', 'Loading Combat Remotes..')
    -- [FIX v10] every wait has a timeout and is protected: a missing/renamed remote no longer freezes or kills the script
    pcall(function()
        local RS = game:GetService('ReplicatedStorage')
        local mods = RS:WaitForChild('Modules', 10)
        local net = mods and mods:WaitForChild('Net', 10)
        if net then
            net:WaitForChild('RE/RegisterAttack', 5)
            net:WaitForChild('RE/RegisterHit', 5)
            net:WaitForChild('RE/ShootGunEvent', 3)
        end
        local rem = RS:WaitForChild('Remotes', 10)
        if rem then rem:WaitForChild('Validator2', 3) end
    end)
    local h = {}
    function GetAllBladeHits()
        bladehits = {}
        for X, X in pairs(workspace.Enemies:GetChildren()) do
            if X:FindFirstChild('Humanoid') and X:FindFirstChild('HumanoidRootPart') and X.Humanoid.Health > 0 and (X.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 65 then
                table.insert(bladehits, X)
            end
        end
        return bladehits
    end
    function Getplayerhit()
        bladehits = {}
        for X, X in pairs(workspace.Characters:GetChildren()) do
            if X.Name ~= game.Players.LocalPlayer.Name and X:FindFirstChild('Humanoid') and X:FindFirstChild('HumanoidRootPart') and X.Humanoid.Health > 0 and (X.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 65 then
                table.insert(bladehits, X)
            end
        end
        return bladehits
    end
    local X = game:GetService('ReplicatedStorage'):FindFirstChild('Modules') and game:GetService('ReplicatedStorage').Modules:FindFirstChild('Net')
    local w, D
    pcall(function() w = require(X):RemoteEvent("RegisterAttack", true) end)
    pcall(function() D = require(X):RemoteEvent("RegisterHit", true) end)
    if not w and X then w = X:FindFirstChild("RE/RegisterAttack") end -- [FIX v10] fallback
    if not D and X then D = X:FindFirstChild("RE/RegisterHit") end
    if not w then w = {FireServer = function() end} end
    if not D then D = {FireServer = function() end} end
    function h:Attack()
        local X = {}
        for y, y in pairs(GetAllBladeHits()) do table.insert(X, y) end
        for y, y in pairs(Getplayerhit()) do table.insert(X, y) end
        if #X == 0 then return end
        local y = {[1] = nil, [2] = {}, [4] = "078da5141"}
        for L, L in pairs(X) do
            w:FireServer(0)
            if not y[1] then y[1] = L.Head end
            table.insert(y[2], {[1] = L, [2] = L.HumanoidRootPart})
            table.insert(y[2], L)
        end
        D:FireServer(unpack(y))
    end
    task.spawn(function()
        while task.wait(.06) do if _G.FastAttack == os.time() then pcall(function() h:Attack() end) end end
    end)
function W.Attack(target) pcall(function() _G.FastAttack = os.time() end) end

    CombatController = {GRAB = false, GRAB_DISTANCE = SeaIndex == 1 and 250 or 350, MAX_ATTACK_DURATION = 2, MAX_ATTACK_DURATION_2 = 60, LEVITATE_TIME = 0, CurrentIndex = 1}

    -- ============================================================
    -- [NEW] BRING MOBS (from Maru Hub), bringRange reduced 888 -> 300.
    -- Toggle with Config.BringMobs; PosMon/Mon are set externally when mobs must be gathered at a point.
    -- ============================================================
    getgenv().BringMonster = getgenv().BringMonster or false
    PosMon = PosMon or nil
    Mon = Mon or nil

    BringEnemy = function()
        pcall(function()
            if not Config.BringMobs or not getgenv().BringMonster then return end
            if not PosMon then return end

            local _char = LocalPlayer.Character
            if not _char then return end
            local _root = _char:FindFirstChild("HumanoidRootPart")
            if not _root then return end

            local targetCF = typeof(PosMon) == "CFrame" and PosMon or CFrame.new(PosMon)
            local pinCF     = targetCF * CFrame.new(0, 3, 0)
            local maxPull   = 20
            local pulled    = 0
            local bringRange = 300 -- [FIXED] 888 -> 300

            local targetName = (Mon and Mon ~= "") and Mon or nil

            local function LockMob(v, hrp, hum)
                hrp.CFrame     = pinCF
                hrp.CanCollide = false

                local head = v:FindFirstChild("Head")
                if head then
                    head.CFrame     = pinCF * CFrame.new(0, 2, 0)
                    head.CanCollide = false
                end

                hum.WalkSpeed  = 0
                hum.JumpPower  = 0
                hum.AutoRotate = false

                local anim = hum:FindFirstChildOfClass("Animator")
                if anim then anim:Destroy() end

                for _, t in ipairs(v:GetChildren()) do
                    if t:IsA("Script") or t:IsA("LocalScript") then
                        t.Disabled = true
                    end
                end

                if hrp:FindFirstChild("_Lock") then
                    hrp._Lock.Velocity = Vector3.new(0, 0, 0)
                    hrp._Lock.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                else
                    local bv    = Instance.new("BodyVelocity")
                    bv.Name     = "_Lock"
                    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    bv.Velocity = Vector3.new(0, 0, 0)
                    bv.Parent   = hrp
                end

                pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                hum:ChangeState(11)
            end

            local enemyFolder = workspace:FindFirstChild("Enemies")
            if enemyFolder then
                for _, v in ipairs(enemyFolder:GetChildren()) do
                    if pulled >= maxPull then break end
                    if targetName and v.Name ~= targetName then continue end
                    -- (Removed the 'do not lock the mob CombatController is attacking' check: the field it relied on does not exist.)

                    local hrp = v:FindFirstChild("HumanoidRootPart")
                    local hum = v:FindFirstChild("Humanoid")
                    if not hrp or not hum or hum.Health <= 0 then continue end
                    if (hrp.Position - _root.Position).Magnitude > bringRange then continue end

                    LockMob(v, hrp, hum)
                    pulled = pulled + 1
                end
            end
        end)
    end

    task.spawn(function()
        while task.wait(0.05) do
            BringEnemy()
        end
    end)


    LastFound = os.time()
    function CombatController.Grab(mobName)
        pcall(sethiddenproperty, game.Players.LocalPlayer, 'SimulationRadius', math.huge)
        if not CombatController.GRAB or GrabDebounce == os.time() then return end
        GrabDebounce = os.time()
        if not MonResult or not MonResult:FindFirstChild('HumanoidRootPart') then return end
        local targetPos = MonResult.HumanoidRootPart.Position
        local AreaMob = false
        for _, enemy in Services.Workspace.Enemies:GetChildren() do
            if enemy ~= MonResult and enemy.Name == mobName then
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                local root = enemy:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local dist = (root.Position - targetPos).Magnitude
                    if dist <= 3000 then
                        local bv = root:FindFirstChild('FarmingVelocity')
                        if not bv then
                            bv = Instance.new('BodyVelocity')
                            bv.Name = 'FarmingVelocity'
                            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                            bv.Velocity = Vector3.zero
                            bv.Parent = root
                        end
                        if dist <= 10 then
                            AreaMob = true
                        end
                        if not AreaMob and (not isnetworkowner or pcall(isnetworkowner, root)) then
                            root.CFrame = MonResult.HumanoidRootPart.CFrame
                        end
                        enemy:SetAttribute('IsGrabbed', true)
                    end
                end
            end
        end
    end
    function Sort1(entity) return entity and entity:FindFirstChild("HumanoidRootPart") and math.floor(CaculateDistance(entity.HumanoidRootPart.CFrame)) end
    function CombatController.Search(names)
        local candidates = {}
        local anyFound = false
        for _, entity in GetMonAsSortedRange() do
            if table.find(names, entity.Name) and entity:FindFirstChild("Humanoid") and entity.Humanoid.Health > 0 then
                if (entity:GetAttribute('FailureCount') or 0) < 3 then
                    anyFound = true
                    table.insert(candidates, entity)
                end
            end
        end
        table.sort(candidates, function(entity, other) return Sort1(entity) < Sort1(other) end)
        if anyFound then
            local best = candidates[1]
            return best
        end
        for _, npcName in names do
            local npc = game.ReplicatedStorage:FindFirstChild(npcName)
            if npc then return npc end
        end
    end
    function CombatController.Attack(h, X, w, D)
        if ScriptStorage.Tools["Sweet Chalice"] and getsenv(game.ReplicatedStorage.GuideModule)["_G"]['InCombat'] then
            pcall(function() if TweenInstance then TweenInstance:Cancel() end end) -- [FIXED] do not tween to (0,0,0) while Sweet Chalice is InCombat
            return
        end
        sethiddenproperty(game.Players.LocalPlayer, 'SimulationRadius', math.huge)
        h = type(h) == "string" and {h} or (h or {})
        for y, L in (h) do
            local b = tostring(L)
            if b == 'Deandre' or b == "Urban" or b == "Diablo" and (os.time() - (LastFire12 or 0)) > 180 then
                LastFire12 = os.time()
                Remotes.CommF_:InvokeServer("EliteHunter")
            end
            if X then
                local b = GetMonAsSortedRange()[1]
                local C = b and b:FindFirstChild('HumanoidRootPart') and b.HumanoidRootPart.Position
                if C and CaculateDistance(C) < w then MonResult = b end
            else
                MonResult = CombatController.Search(h)
            end
            if MonResult then
                LastFound = os.time()
                local h, w = 0, os.time()
                SetTask('SubTask', '⚔️ Attacking ' .. tostring(MonResult.Name))
                local w, b = 0, os.time()
                while task.wait() do
                    if _G.Stop then return end
                    if _G.PanicModeActive then return end -- hiding: leave the fight, the dispatcher pauses until it is safe
                    if ScriptStorage.Tools["Sweet Chalice"] and getsenv(game.ReplicatedStorage.GuideModule)["_G"]["InCombat"] then
                        pcall(function() if TweenInstance then TweenInstance:Cancel() end end) -- [FIXED] do not tween to (0,0,0) while Sweet Chalice is InCombat
                        return
                    end
                    local C = MonResult:FindFirstChild('Humanoid')
                    local p = MonResult:FindFirstChild('HumanoidRootPart')
                    if not C or C.Health <= 0 then
                        if MonResult.Name == "Don Swan" then Storage:Set("SwanDefeated", true) end
                        break
                    end
                    TweenController.Create(CaculateCircreDirection(p.CFrame) + Vector3.new(0, 27, 0))
                    if CaculateDistance(p.Position + Vector3.new(0, 27, 0)) < 150 then
                        y = D and D()
                        CombatController.Grab(L or '')
                        if MonResult.Name ~= "Core" then
                            if ScriptStorage.PlayerData.Level > 100 and w >= CombatController.MAX_ATTACK_DURATION_2 and C.Health - C.MaxHealth == 0 then
                                SetTask('SubTask', 'Hop Server - Mob Health Unchanged ( ' .. C.Health .. ' / ' .. C.MaxHealth .. ')')
                                alert("stuck", "Mob health unchanged")
                                _G.Stop = true
                                pcall(function() SafeRejoin() end)
                                task.wait(15)
                                -- Still here: the teleport failed or was ignored. Try a fresh server, then RESUME
                                -- (it used to stay stopped forever, which made the script do nothing).
                                _G.Stop = false
                                return
                            end
                            if h >= CombatController.MAX_ATTACK_DURATION and C.Health - C.MaxHealth == 0 then
                                h = 0
                                local D = MonResult:GetAttribute('OldPosition')
                                if D then
                                    MonResult:SetPrimaryPartCFrame(CFrame.new(D))
                                    MonResult:SetAttribute('IgnoreGrab', true)
                                    MonResult:SetAttribute('FailureCount', (MonResult:GetAttribute("FailureCount") or 0) + 1)
                                    alert('Failed to attack', "Returning to the old posiiton ( #" .. MonResult:GetAttribute("FailureCount") .. " )")
                                    MonResult.HumanoidRootPart.CFrame = (CFrame.new(D))
                                    task.wait()
                                    return
                                end
                            end
                        end
                        if (FarmFruitMastery or math.huge) - os.time() < 3 and math.floor(MonResult.Humanoid.Health / MonResult.Humanoid.MaxHealth * 100) < 30 and not FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call() then
                            TweenController.Create((p.CFrame) + Vector3.new(0, 25, 0))
                            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call('Blox Fruit')
                            LockAimPositionTo(MonResult.HumanoidRootPart.CFrame.p)
                            local D = {'Z', 'X', "C", 'V'}
                            local y = D[math.random(1, #D)]
                            SendKey(y, .31)
                        else
                            -- [FIXED] Prefer _G.SelectWeapon when set
                            if _G.SelectWeapon and CheckItem(_G.SelectWeapon) then
                                FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(_G.SelectWeapon)
                            else
                                FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(ScriptStorage.ForceToUseSword and 'Sword' or "Melee")
                            end
                        end
                        W:Attack(MonResult)
                        if os.time() ~= b then
                            b = os.time()
                            h = h + 1
                            w = w + 1
                        end
                        if h > 30 and MonResult.Name ~= "Core" then
                            alert("Take more than 30s to attack, canceling")
                            break
                        end
                    end
                end
            elseif not X then
                if (os.time() - LastFound) > 200 then
                    alert('MeyyHub', 'Error while farming, rejoin')
                    SafeRejoin()
                    return
                end
                local h = ScriptStorage.MobRegions[L]
                if not h then
                    local X = Services.Workspace.Enemies:FindFirstChild(L) or game.ReplicatedStorage:FindFirstChild(L)
                    h = X and {X:GetPrimaryPartCFrame().p}
                end
                if not h then
                    Report('[ Game data error ] Mob with name ' .. tostring(L) .. ' have no spawn region datas')
                    return
                end
                local X
                if not h[CombatController.CurrentIndex] then CombatController.CurrentIndex = 1 end
                X = h[CombatController.CurrentIndex]
                local h = os.time()
                TweenController.Create(X + Vector3.new(0, 35, 35))
                if CaculateDistance(X + Vector3.new(0, 35, 35)) < 15 then CombatController.CurrentIndex = CombatController.CurrentIndex + 1 end
            end
        end
    end
    LevelFarmTTL = 0
    LastTravel = os.time()
    FunctionsHandler = {Initalized = false}
    print(3000)
    setmetatable(FunctionsHandler, {__index = function(h, X)
        QueryResult = rawget(h, X)
        if not QueryResult then
            return {
                Register = function(w)
                    if w == false then return end
                    Result = {CacheListener = {}, RealCache = {}, Methods = {}, Constants = {}, Events = {}, Initalized = true}
                    function Result.RegisterMethod(w, D, y)
                        w.Methods[D] = {Name = D, Callback = y, Call = function(w, ...) return w.Callback(...) end, Events = {}}
                        return true
                    end
                    setmetatable(Result.Constants, {__newindex = function() assert(false, 'cannot change constant value!') end})
                    if h.Constants[Key] then
                        function Result.SaveConstant(w, w, w) return assert(false, 'constant name was used before!') end
                        rawset(h.Constants, Key, Value)
                    end
                    function Result.Set(h, w, D)
                        h.CacheListener[w] = D
                        return D
                    end
                    function Result.Get(h, w) return h.Constants[w] or h.RealCache[w] end
                    function Result.AddVariableChangeListener(h, w, D) h.Events[w] = D end
                    Result.CacheListener.__parent = Result
                    setmetatable(Result.CacheListener, {__newindex = function(h, w, D)
                        _ = h.__parent.Events[w] and h.__parent.Events[w](w, D)
                        h.__parent.RealCache[w] = D
                    end})
                    FunctionsHandler[X] = Result
                end, Initalized = false
            }
        end
        return QueryResult
    end})
    function FunctionsHandler.SynchorizeUntilModuleLoaded(h, X)
        local w = os.time()
        while not h.Initalized do
            task.wait()
            local h = os.time() - w
            assert(not (X and h > X), "timed out")
        end
    end
    function GetCurrentClaimQuest(h)
        local h = game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible and game.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text:gsub("%s*Defeat%s*(%d*)%s*(.-)%s*%b()", "%2")
        return (type(h) == "string" and string.gsub(h, "Military ", "Mil. ") or h), game.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
    end
    FunctionsHandler.LocalPlayerController.Register()
    FunctionsHandler.ExpRedeem:Register()
    FunctionsHandler.LevelFarm:Register()
    FunctionsHandler.Saber:Register()
    FunctionsHandler.Rengoku:Register()
    FunctionsHandler.Yama:Register()
    FunctionsHandler.Tushita:Register()
    FunctionsHandler.SpikeyTrident:Register()
    FunctionsHandler.SharkAchor:Register()
    FunctionsHandler.Pole:Register()
    FunctionsHandler.FoxLamp:Register()
    FunctionsHandler.DarkDagger:Register()
    FunctionsHandler.Canvander:Register()
    FunctionsHandler.BuddySword:Register()
    FunctionsHandler.HallowScythe:Register()
    FunctionsHandler.CursedDualKatana:Register()
    FunctionsHandler.AcidumRifle:Register()
    FunctionsHandler.Kabucha:Register()
    FunctionsHandler.VenomBow:Register()
    FunctionsHandler.SoulGuitar:Register()
    FunctionsHandler.DragonStorm:Register()
    FunctionsHandler.InsictV2:Register()
    FunctionsHandler.RainbowSaviour:Register()
    FunctionsHandler.DarkBladeV2:Register()
    FunctionsHandler.SecondSeaPuzzle:Register()
    FunctionsHandler.ColosseumPuzzle:Register()
    FunctionsHandler.Trevor:Register()
    FunctionsHandler.EvoRace:Register()
    FunctionsHandler.Wenlocktoad:Register()
    FunctionsHandler.DarkBladeV3:Register()
    FunctionsHandler.ThirdSeaPuzzle:Register()
    FunctionsHandler.DojoQuest:Register()
    FunctionsHandler.RaceAwakening:Register()
    FunctionsHandler.PirateRaid:Register()
    FunctionsHandler.SwordBossTask:Register()
    FunctionsHandler.CakePrinceTask:Register()
    FunctionsHandler.RaidController:Register()
    FunctionsHandler.AutoRaidIce:Register()
    FunctionsHandler.MeleesController:Register()
    FunctionsHandler.Superhuman:Register()
    FunctionsHandler.DeathStep:Register()
    FunctionsHandler.SharkmanKarate:Register()
    FunctionsHandler.ElectricClaw:Register()
    FunctionsHandler.DragonTalon:Register()
    FunctionsHandler.Godhuman:Register()
    FunctionsHandler.BossesTask:Register()
    FunctionsHandler.SpecialBossesTask:Register()
    FunctionsHandler.CollectDrops:Register()
    FunctionsHandler.CollectBerries:Register()
    FunctionsHandler.UtillyItemsActivitation:Register()

    -- ============================================================
    -- AUTO FULL MELEE - COMPATIBLE WITH LEVEL FARM
    -- [NEW] V1 -> V2 pairing: tells which fruit mastery belongs to which melee and its teacher/style (MeleePrices).
    local V1ToV2 = {
        ["Black Leg"]      = "Death Step",       -- "Dark Step" (teacher name)
        ["Electro"]        = "Electric Claw",
        ["Fishman Karate"] = "Sharkman Karate",   -- "Water Kung Fu"
        ["Dragon Claw"]    = "Dragon Talon",
    }

    FunctionsHandler.MeleesController:RegisterMethod("Refresh", function()
        if not Config.Items.AutoFullyMelees or not Config.Melee.AutoBuy then return nil end
        if ScriptStorage.PlayerData.Level < 200 then return nil end
        -- [FIXED] Removed the permanent 'if _G.Level then return nil end' lock; Refresh now re-checks every round.

        local allMelees = {"Black Leg", "Electro", "Fishman Karate", "Dragon Claw", "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw", "Dragon Talon", "Godhuman"}
        local hasAll = true
        for _, name in ipairs(allMelees) do
            if not OwnsMelee(name) then
                hasAll = false
                break
            end
        end
        if hasAll then
            SetTask('MainTask', 'Auto Full Melee | ✅ All owned!')
            return nil
        end
        return true
    end)

    FunctionsHandler.MeleesController:RegisterMethod("Start", function()
        if not Config.Items.AutoFullyMelees or not Config.Melee.AutoBuy then return end
        if ScriptStorage.PlayerData.Level < 200 then return end

        local meleeList = {
            -- [FIXED] Keys no longer include the 'Buy' prefix because BuyMelee() adds it itself (it used to call 'BuyBuyBlackLeg').
            {name = "Black Leg", key = "BlackLeg", price = {Beli = 150000}, levelReq = 300},
            {name = "Electro", key = "Electro", price = {Beli = 500000}, levelReq = 300},
            {name = "Fishman Karate", key = "FishmanKarate", price = {Beli = 750000}, levelReq = 300},
            {name = "Dragon Claw", key = "DragonClaw", price = {Fragments = 1500}, levelReq = 300},
            {name = "Superhuman", key = "Superhuman", price = {Beli = 3000000}, levelReq = nil, needMastery = {item = "Dragon Claw", value = 300}},
            {name = "Death Step", key = "DeathStep", price = {Beli = 2500000, Fragments = 5000}, levelReq = 400, needKey = "Library Key"},
            {name = "Sharkman Karate", key = "SharkmanKarate", price = {Beli = 2500000, Fragments = 5000}, levelReq = 400, needKey = "Water Key"},
            {name = "Electric Claw", key = "ElectricClaw", price = {Beli = 2500000, Fragments = 5000}, levelReq = 400},
            {name = "Dragon Talon", key = "DragonTalon", price = {Beli = 2500000, Fragments = 5000}, levelReq = 400, needFireEssence = true},
            {name = "Godhuman", key = "Godhuman", price = {Beli = 5000000, Fragments = 5000}, levelReq = 400, needMaterials = true},
        }

        -- [NEW] Gate: Godhuman materials are only farmed once ALL 9 melees (V1+V2, incl. Superhuman) are bought and at target mastery (V1=500, V2=400).
        local MASTERY_GATE_MELEES = {
            {name = "Black Leg",       target = Config.Melee.RaidAtV1Mastery},
            {name = "Electro",         target = Config.Melee.RaidAtV1Mastery},
            {name = "Fishman Karate",  target = Config.Melee.RaidAtV1Mastery},
            {name = "Dragon Claw",     target = Config.Melee.RaidAtV1Mastery},
            {name = "Superhuman",      target = Config.Melee.RaidAtV1Mastery},
            {name = "Death Step",      target = Config.Melee.GodhumanAtV2Mastery},
            {name = "Sharkman Karate", target = Config.Melee.GodhumanAtV2Mastery},
            {name = "Electric Claw",   target = Config.Melee.GodhumanAtV2Mastery},
            {name = "Dragon Talon",    target = Config.Melee.GodhumanAtV2Mastery},
        }

        local function AllMeleesReady()
            for _, m in ipairs(MASTERY_GATE_MELEES) do
                if not OwnsMelee(m.name) then return false, m.name .. " (not bought)" end
                local mst = ScriptStorage.Melees[m.name] or 0
                if mst < m.target then return false, m.name .. " (" .. mst .. "/" .. m.target .. ")" end
            end
            return true
        end


        -- A sea without an entry means that teacher is not there; Sea 3 has all 8 teachers and is the fallback.
        local TeacherLocations = {
            ["Water Kung-fu Teacher"] = {
                [1] = CFrame.new(61586.96, 19.58, 987.59),
                [2] = CFrame.new(-4957.68, 35.94, -4665.6),
                [3] = CFrame.new(-5023.91, 371.02, -3191.46),
            },
            ["Mad Scientist"] = {
                [1] = CFrame.new(-5382.79, 12.55, -2148.82),
                [2] = CFrame.new(-4866.16, 33.92, -4767.11),
                [3] = CFrame.new(-4996.06, 313.21, -3201.83),
            },
            ["Dark Step Teacher"] = {
                [1] = CFrame.new(-983.62, 12.44, 3990.46),
                [2] = CFrame.new(-4752.44, 33.92, -4848.04),
                [3] = CFrame.new(-5045.61, 370.01, -3182.31),
            },
            ["Phoeyu, the Reformed"] = {
                [2] = CFrame.new(6356.47, 296.1, -6762.78),
                [3] = CFrame.new(-4999.24, 314.01, -3221.58),
            },
            ["Sharkman Teacher"] = {
                [2] = CFrame.new(-2599.63, 238.19, -10316),
                [3] = CFrame.new(-4971.21, 313.88, -3223.08),
            },
            ["Previous Hero"] = {
                [3] = CFrame.new(-10371.48, 330.76, -10131.42),
            },
            ["Uzoth"] = {
                [3] = CFrame.new(5661.89, 1210.87, 863.17),
            },
            ["Ancient Monk"] = {
                [3] = CFrame.new(-13774.1, 333.73, -9879.91),
            },
        }
        -- [NEW] Melee -> teacher (matches MeleePrices.Buy). Dragon Claw and Superhuman have no known position, left empty.
        local MeleeTeacher = {
            ["Fishman Karate"]   = "Water Kung-fu Teacher",
            ["Electro"]          = "Mad Scientist",
            ["Black Leg"]        = "Dark Step Teacher",
            ["Death Step"]       = "Phoeyu, the Reformed",
            ["Sharkman Karate"]  = "Sharkman Teacher",
            ["Electric Claw"]    = "Previous Hero",
            ["Dragon Talon"]     = "Uzoth",
            ["Godhuman"]         = "Ancient Monk",
        }

        -- [NEW] Tween to the teacher before buying (the server rejects purchases made far from the NPC).
        local function GoToTeacher(meleeName)
            local teacher = MeleeTeacher[meleeName]
            if not teacher then return true end -- no position data, skip this step
            local locs = TeacherLocations[teacher]
            if not locs then return true end

            local cf = locs[SeaIndex]
            if not cf then
                if SeaIndex ~= 3 then
                    Remotes.CommF_:InvokeServer("TravelZou")
                    return false
                end
                return true -- in Sea 3 but the table has no Sea 3 coordinates (should not happen)
            end

            if CaculateDistance(cf) > 10 then
                TweenController.Create(cf)
                return false
            end
            return true
        end

        for _, melee in ipairs(meleeList) do
            if _G.Stop then return end

            local bp = OwnsMelee(melee.name)
            if not bp then
                -- [NEW] Dragon Claw V1 needs 1500 Fragments - if short, that is why raids are farmed.
                if melee.name == "Dragon Claw" and (ScriptStorage.PlayerData.Fragments or 0) < 1500 then
                    -- SetTask('MainTask', 'Auto Full Melee | Dragon Claw needs 1500 Fragments - farming Raid (' .. (ScriptStorage.PlayerData.Fragments or 0) .. '/1500)') -- [FIX] silenced: it made the task text flicker
                    getgenv().TaskYield = true -- [FIX] nothing to do here: let the next task (LevelFarm) run
                    return
                end

                local canBuy = true
                for currency, amount in pairs(melee.price) do
                    local have = (currency == "Beli" and ScriptStorage.PlayerData.Beli) or
                                 (currency == "Fragments" and ScriptStorage.PlayerData.Fragments) or 0
                    if have < amount then canBuy = false end
                end
                -- [FIXED] needKey/needFireEssence/needMaterials are prerequisites and are now checked BEFORE buying.

                if melee.needKey and not CheckItem(melee.needKey) then
                    SetTask('MainTask', 'Auto Full Melee | Getting ' .. melee.needKey .. ' for ' .. melee.name)
                    if melee.needKey == "Library Key" then
                        local admiral = GetConnectionEnemies("Awakened Ice Admiral")
                        if admiral then
                            -- [FIXED] Attack() already blocks until the kill, so the extra wait(2) was removed.
                            CombatController.Attack("Awakened Ice Admiral")
                        else
                            TweenController.Create(CFrame.new(5668.978, 28.52, -6483.352))
                        end
                    elseif melee.needKey == "Water Key" then
                        local tide = GetConnectionEnemies("Tide Keeper")
                        if tide then
                            CombatController.Attack("Tide Keeper")
                        else
                            TweenController.Create(CFrame.new(-3053.981, 237.19, -10145.039))
                        end
                    end
                    return
                end

                -- [NEW] Mastery prerequisite: Superhuman needs Dragon Claw at 300 mastery first.
                if melee.needMastery then
                    local preMastery = ScriptStorage.Melees[melee.needMastery.item] or 0
                    if not OwnsMelee(melee.needMastery.item) or preMastery < melee.needMastery.value then
                        -- SetTask('MainTask', 'Auto Full Melee | Needs ' .. melee.needMastery.item .. ' at ' .. melee.needMastery.value .. ' mastery first (currently ' .. preMastery .. ') to buy ' .. melee.name) -- [FIX] silenced: it made the task text flicker
                        getgenv().TaskYield = true -- [FIX] nothing to do here: let the next task (LevelFarm) run
                        return
                    end
                end

                if melee.needFireEssence then
                    local hasFireEssence = CheckItem("Fire Essence")

                    if hasFireEssence then
                        -- [FIXED] Equip Fire Essence then call BuyDragonTalon TWICE (true, then no args).
                        SetTask('MainTask', 'Auto Full Melee | Using Fire Essence to buy Dragon Talon')
                        FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Fire Essence")
                        task.wait(0.5)
                        Remotes.CommF_:InvokeServer("BuyDragonTalon", true)
                        Remotes.CommF_:InvokeServer("BuyDragonTalon")
                        return
                    end

                    if not OwnsMelee(melee.name) then
                        -- [FIXED] Real threshold is 500 Bones (same as CDK); buy in a burst until empty.
                        local bonesCount = Remotes.CommF_:InvokeServer("Bones", "Check")
                        if bonesCount and bonesCount > 500 then
                            SetTask('MainTask', 'Auto Full Melee | Trading Bones for Fire Essence (' .. bonesCount .. ')')
                            repeat
                                Remotes.CommF_:InvokeServer("Bones", "Buy", 1, 1)
                                task.wait(0.2)
                                bonesCount = Remotes.CommF_:InvokeServer("Bones", "Check")
                            until not bonesCount or bonesCount <= 0
                            return
                        end
                        if not ScriptStorage.Enemies["Reborn Skeleton"] and not ScriptStorage.Enemies["Living Zombie"]
                            and not ScriptStorage.Enemies["Demonic Soul"] and not ScriptStorage.Enemies["Posessed Mummy"] then
                            -- [NEW] No mob nearby -> go to the Haunted Castle farm spot instead of standing still.
                            SetTask('MainTask', 'Auto Full Melee | Moving to Haunted Castle to farm Bones (' .. (bonesCount or 0) .. '/500)')
                            TweenController.Create(HAUNTED_CASTLE_BONES_CF)
                            return
                        end
                        SetTask('MainTask', 'Auto Full Melee | Farming Bones for Fire Essence (' .. (bonesCount or 0) .. '/500)')
                        CombatController.Attack({'Reborn Skeleton', 'Living Zombie', 'Demonic Soul', 'Posessed Mummy'})
                        return
                    end
                end

                if melee.needMaterials then
                    -- [NEW] Gate: only farm Godhuman materials when all other 8 melees are bought and at target mastery.
                    local ready, reason = AllMeleesReady()
                    if not ready then
                        -- SetTask('MainTask', 'Auto Full Melee | Godhuman: requirements not met - ' .. (reason or "?")) -- [FIX] silenced: it made the task text flicker
                        getgenv().TaskYield = true -- [FIX] nothing to do here: let the next task (LevelFarm) run
                        return
                    end

                    local materials = {
                        {name = "Dragon Scale", need = 10, sea = 3, mobs = {"Dragon Crew Warrior", "Dragon Crew Archer"}},
                        {name = "Fish Tail", need = 20, sea = 3, mobs = {"Fishman Raider", "Fishman Captain"}},
                        {name = "Mystic Droplet", need = 10, sea = 2, mobs = {"Sea Soldier", "Water Fighter"}},
                        {name = "Magma Ore", need = 20, sea = 2, mobs = {"Magma Ninja"}},
                    }
                    for _, mat in ipairs(materials) do
                        local count = ScriptStorage.Backpack[mat.name] and ScriptStorage.Backpack[mat.name].Count or 0
                        if count < mat.need then
                            if SeaIndex ~= mat.sea then
                                Remotes.CommF_:InvokeServer(mat.sea == 2 and "TravelDressrosa" or "TravelZou")
                                return
                            end
                            SetTask('MainTask', 'Auto Full Melee | Godhuman: farm ' .. mat.name .. ' (' .. count .. '/' .. mat.need .. ')')
                            CombatController.Attack(mat.mobs)
                            return
                        end
                    end
                    -- Materials ready -> fall through to the money/Fragments check below.
                end

                if canBuy then
                    -- [FIXED] GoToTeacher() tweens manually (correct). The purchase must be called twice: BuyMelee(key, true) is only a CHECK,
                    -- then BuyMelee(key) runs the real purchase.
                    if not GoToTeacher(melee.name) then
                        SetTask('MainTask', 'Auto Full Melee | Moving to ' .. (MeleeTeacher[melee.name] or "?") .. ' to buy ' .. melee.name)
                        return
                    end
                    SetTask('MainTask', 'Auto Full Melee | Buying ' .. melee.name)
                    local checkResult = BuyMelee(melee.key, true)  -- Step 1: check (proxy records into J if valid)
                    task.wait(0.3)
                    BuyMelee(melee.key)                            -- Step 2: real purchase (triggers proxy auto-navigate + real invoke)
                    task.wait(0.5)
                    if OwnsMelee(melee.name) then
                        SetTask('MainTask', 'Auto Full Melee | ✅ Purchased ' .. melee.name)
                    else
                        SetTask('SubTask', 'Auto Full Melee | Purchase sent for ' .. melee.name .. ' - re-checking next round')
                    end
                else
                    -- [FIXED] No longer sets the permanent _G.Level lock; reports status and returns, Refresh retries next round.
                    -- SetTask('MainTask', 'Auto Full Melee | Need to farm money for ' .. melee.name) -- [FIX] silenced: it made the task text flicker
                    getgenv().TaskYield = true -- [FIX] nothing to do here: let the next task (LevelFarm) run
                    return
                end
            else
                -- [FIXED] Mastery is read from ScriptStorage.Melees[name] (the old bp.Level.Value does not exist on tools).
                local mastery = ScriptStorage.Melees[melee.name] or 0

                if melee.levelReq and ScriptStorage.PlayerData.Level < melee.levelReq then
                    -- SetTask('MainTask', 'Auto Full Melee | Need Player Level ' .. melee.levelReq .. ' for ' .. melee.name) -- [FIX] silenced: it made the task text flicker
                    getgenv().TaskYield = true -- [FIX] nothing to do here: let the next task (LevelFarm) run
                    return
                end

                -- [NEW] V1 at 500 mastery and V2 not owned -> prioritise Raid for Fragments. Keep looping over the remaining melees.
                local v2Name = V1ToV2[melee.name]
                if Config.Melee.CheckMasteryAfterBuy and v2Name and not OwnsMelee(v2Name) then
                    if mastery < Config.Melee.RaidAtV1Mastery then
                        SetTask('SubTask', melee.name .. ' training mastery (' .. mastery .. '/' .. Config.Melee.RaidAtV1Mastery .. ')')
                    else
                        local v2Data = MeleePrices[v2Name]
                        local needFrags = (v2Data and v2Data.Price and v2Data.Price.Fragments) or 5000
                        local needBeli  = (v2Data and v2Data.Price and v2Data.Price.Beli) or 2500000
                        local haveFrags = ScriptStorage.PlayerData.Fragments or 0
                        local haveBeli  = ScriptStorage.PlayerData.Beli or 0
                        if haveFrags < needFrags or haveBeli < needBeli then
                            SetTask('MainTask', string.format(
                                'Auto Full Melee | %s reached %d mastery - waiting for Raid to farm Fragments for %s (F:%d/%d, Beli:%d/%d)',
                                melee.name, mastery, v2Name, haveFrags, needFrags, haveBeli, needBeli
                            ))
                        end
                    end
                end

                -- [NEW] V2 at 400 mastery -> Godhuman requirement met for this melee (AllMeleesReady() decides the overall condition).
                local V2_TO_GODHUMAN = {["Death Step"]=true, ["Sharkman Karate"]=true, ["Electric Claw"]=true, ["Dragon Talon"]=true}
                if Config.Melee.CheckMasteryAfterBuy and V2_TO_GODHUMAN[melee.name] and not OwnsMelee("Godhuman") then
                    if mastery < Config.Melee.GodhumanAtV2Mastery then
                        SetTask('SubTask', melee.name .. ' training mastery (' .. mastery .. '/' .. Config.Melee.GodhumanAtV2Mastery .. ')')
                    end
                end

                SetTask('SubTask', '✅ ' .. melee.name .. ' ready')
            end
        end

        -- SetTask('MainTask', 'Auto Full Melee | 🎉 All done!') -- [FIX] silenced: it made the task text flicker
        getgenv().TaskYield = true -- [FIX] nothing to do here: let the next task (LevelFarm) run
    end)

    -- ============================================================
    -- LEVEL FARM
    -- [ADDED] QuestController tracks quests via the real Remotes.QuestUpdate event instead of reading GUI text
    -- (which lags behind replication and could abandon a quest that was just accepted).
    QuestController = {
        CurrentQuest = "",
        CurrentQuestName = "",
        QuestConnection = nil,
    }
    QuestController.Set = function(self, data)
        self.CurrentQuest = (function()
            for i, _ in next, data.Progress do
                return i
            end
        end)()
        self.CurrentQuestName = data.InternalQuestName
    end
    QuestController.Reset = function(self)
        self.CurrentQuest = ""
        self.CurrentQuestName = ""
    end
    local questConnectOk = pcall(function()
        QuestController.QuestConnection = Services.ReplicatedStorage.Remotes.QuestUpdate.OnClientEvent:Connect(function(a2, a3)
            if a2 and typeof(a2) == "table" then
                QuestController:Set(a2)
                return
            end
            QuestController:Reset()
        end)
    end)
    -- [FIXED] QuestController.CurrentQuestName is the QUEST name (e.g. BanditQuest1), different from GetCurrentClaimQuest() (mob name from GUI).
    -- If Remotes.QuestUpdate cannot be connected, nil is returned and Start() falls back to GetCurrentClaimQuest().
    function HasActiveQuestEvent()
        return questConnectOk and QuestController.QuestConnection ~= nil
    end
    function GetActiveQuestName()
        if not HasActiveQuestEvent() then return nil end
        if QuestController.CurrentQuest == "" then return false end
        return QuestController.CurrentQuestName
    end

    local function ManualLevelLookup()
        -- [ADDED] MANUAL level farm table: does not depend on J.RefreshQuest / require(Quests). Reads only ScriptStorage.PlayerData.Level
        -- and looks up mob + CFrame directly (data taken from verified reference files).
        local MyLevel = ScriptStorage.PlayerData.Level or 0
        local Mon, Qdata, Qname, NameMon = "", 0, "", ""
        local PosQ, PosM = nil, nil

        if SeaIndex == 1 then
            if MyLevel >= 1 and MyLevel <= 9 then
                Mon = "Bandit"; Qdata = 1; Qname = "BanditQuest1"; NameMon = "Bandit"
                PosQ = CFrame.new(1059.37195, 15.4495068, 1550.4231, 0.939700544, 0, -0.341998369, 0, 1, 0, 0.341998369, 0, 0.939700544)
                PosM = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125)
            elseif MyLevel >= 10 and MyLevel <= 14 then
                Mon = "Monkey"; Qdata = 1; Qname = "JungleQuest"; NameMon = "Monkey"
                PosQ = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, 0, -1, 0, 0)
                PosM = CFrame.new(-1448.51806640625, 67.85301208496094, 11.46579647064209)
            elseif MyLevel >= 15 and MyLevel <= 29 then
                Mon = "Gorilla"; Qdata = 2; Qname = "JungleQuest"; NameMon = "Gorilla"
                PosQ = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, 0, -1, 0, 0)
                PosM = CFrame.new(-1129.8836669921875, 40.46354675296875, -525.4237060546875)
            elseif MyLevel >= 30 and MyLevel <= 39 then
                Mon = "Pirate"; Qdata = 1; Qname = "BuggyQuest1"; NameMon = "Pirate"
                PosQ = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, 0, -0.258804798, 0, 1, 0, 0.258804798, 0, 0.965929627)
                PosM = CFrame.new(-1103.513427734375, 13.752052307128906, 3896.091064453125)
            elseif MyLevel >= 40 and MyLevel <= 59 then
                Mon = "Brute"; Qdata = 2; Qname = "BuggyQuest1"; NameMon = "Brute"
                PosQ = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, 0, -0.258804798, 0, 1, 0, 0.258804798, 0, 0.965929627)
                PosM = CFrame.new(-1140.083740234375, 14.809885025024414, 4322.92138671875)
            elseif MyLevel >= 60 and MyLevel <= 74 then
                Mon = "Desert Bandit"; Qdata = 1; Qname = "DesertQuest"; NameMon = "Desert Bandit"
                PosQ = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, 0, -0.573571265, 0, 1, 0, 0.573571265, 0, 0.819155693)
                PosM = CFrame.new(924.7998046875, 6.44867467880249, 4481.5859375)
            elseif MyLevel >= 75 and MyLevel <= 89 then
                Mon = "Desert Officer"; Qdata = 2; Qname = "DesertQuest"; NameMon = "Desert Officer"
                PosQ = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, 0, -0.573571265, 0, 1, 0, 0.573571265, 0, 0.819155693)
                PosM = CFrame.new(1608.2822265625, 8.614224433898926, 4371.00732421875)
            elseif MyLevel >= 90 and MyLevel <= 99 then
                Mon = "Snow Bandit"; Qdata = 1; Qname = "SnowQuest"; NameMon = "Snow Bandit"
                PosQ = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, 0.939684391, 0, 1, 0, -0.939684391, 0, -0.342042685)
                PosM = CFrame.new(1354.347900390625, 87.27277374267578, -1393.946533203125)
            elseif MyLevel >= 100 and MyLevel <= 119 then
                Mon = "Snowman"; Qdata = 2; Qname = "SnowQuest"; NameMon = "Snowman"
                PosQ = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, 0.939684391, 0, 1, 0, -0.939684391, 0, -0.342042685)
                PosM = CFrame.new(1201.6412353515625, 144.57958984375, -1550.0670166015625)
            elseif MyLevel >= 120 and MyLevel <= 149 then
                Mon = "Chief Petty Officer"; Qdata = 1; Qname = "MarineQuest2"; NameMon = "Chief Petty Officer"
                PosQ = CFrame.new(-5039.58643, 27.3500385, 4324.68018, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                PosM = CFrame.new(-4881.23095703125, 22.65204429626465, 4273.75244140625)
            elseif MyLevel >= 150 and MyLevel <= 174 then
                Mon = "Sky Bandit"; Qdata = 1; Qname = "SkyQuest"; NameMon = "Sky Bandit"
                PosQ = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
                PosM = CFrame.new(-4953.20703125, 295.74420166015625, -2899.22900390625)
            elseif MyLevel >= 175 and MyLevel <= 189 then
                Mon = "Dark Master"; Qdata = 2; Qname = "SkyQuest"; NameMon = "Dark Master"
                PosQ = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
                PosM = CFrame.new(-5259.8447265625, 391.3976745605469, -2229.035400390625)
            elseif MyLevel >= 190 and MyLevel <= 209 then
                Mon = "Prisoner"; Qdata = 1; Qname = "PrisonerQuest"; NameMon = "Prisoner"
                PosQ = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, 0, -0.995993316, 0, 1, 0, 0.995993316, 0, -0.0894274712)
                PosM = CFrame.new(5098.9736328125, -0.3204058110713959, 474.2373352050781)
            elseif MyLevel >= 210 and MyLevel <= 249 then
                Mon = "Dangerous Prisoner"; Qdata = 2; Qname = "PrisonerQuest"; NameMon = "Dangerous Prisoner"
                PosQ = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, 0, -0.995993316, 0, 1, 0, 0.995993316, 0, -0.0894274712)
                PosM = CFrame.new(5654.5634765625, 15.633401870727539, 866.2991943359375)
            elseif MyLevel >= 250 and MyLevel <= 274 then
                Mon = "Toga Warrior"; Qdata = 1; Qname = "ColosseumQuest"; NameMon = "Toga Warrior"
                PosQ = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, 0.857167721, 0, -0.515037298)
                PosM = CFrame.new(-1820.21484375, 51.68385696411133, -2740.6650390625)
            elseif MyLevel >= 275 and MyLevel <= 299 then
                Mon = "Gladiator"; Qdata = 2; Qname = "ColosseumQuest"; NameMon = "Gladiator"
                PosQ = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, 0.857167721, 0, -0.515037298)
                PosM = CFrame.new(-1292.838134765625, 56.380882263183594, -3339.031494140625)
            elseif MyLevel >= 300 and MyLevel <= 324 then
                Mon = "Military Soldier"; Qdata = 1; Qname = "MagmaQuest"; NameMon = "Military Soldier"
                PosQ = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, -0.499959469)
                PosM = CFrame.new(-5411.16455078125, 11.081554412841797, 8454.29296875)
            elseif MyLevel >= 325 and MyLevel <= 374 then
                Mon = "Military Spy"; Qdata = 2; Qname = "MagmaQuest"; NameMon = "Military Spy"
                PosQ = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, -0.499959469)
                PosM = CFrame.new(-5802.8681640625, 86.26241302490234, 8828.859375)
            elseif MyLevel >= 375 and MyLevel <= 399 then
                Mon = "Fishman Warrior"; Qdata = 1; Qname = "FishmanQuest"; NameMon = "Fishman Warrior"
                PosQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
                PosM = CFrame.new(60878.30078125, 18.482830047607422, 1543.7574462890625)
            elseif MyLevel >= 400 and MyLevel <= 449 then
                Mon = "Fishman Commando"; Qdata = 2; Qname = "FishmanQuest"; NameMon = "Fishman Commando"
                PosQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
                PosM = CFrame.new(61922.6328125, 18.482830047607422, 1493.934326171875)
            elseif MyLevel >= 450 and MyLevel <= 474 then
                Mon = "God's Guard"; Qdata = 1; Qname = "SkyExp1Quest"; NameMon = "God's Guard"
                PosQ = CFrame.new(-4721.88867, 843.874695, -1949.96643, 0.996191859, 0, -0.0871884301, 0, 1, 0, 0.0871884301, 0, 0.996191859)
                PosM = CFrame.new(-4710.04296875, 845.2769775390625, -1927.3079833984375)
            elseif MyLevel >= 475 and MyLevel <= 524 then
                Mon = "Shanda"; Qdata = 2; Qname = "SkyExp1Quest"; NameMon = "Shanda"
                PosQ = CFrame.new(-7859.09814, 5544.19043, -381.476196, -0.422592998, 0, 0.906319618, 0, 1, 0, -0.906319618, 0, -0.422592998)
                PosM = CFrame.new(-7678.48974609375, 5566.40380859375, -497.2156066894531)
            elseif MyLevel >= 525 and MyLevel <= 549 then
                Mon = "Royal Squad"; Qdata = 1; Qname = "SkyExp2Quest"; NameMon = "Royal Squad"
                PosQ = CFrame.new(-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                PosM = CFrame.new(-7624.25244140625, 5658.13330078125, -1467.354248046875)
            elseif MyLevel >= 550 and MyLevel <= 624 then
                Mon = "Royal Soldier"; Qdata = 2; Qname = "SkyExp2Quest"; NameMon = "Royal Soldier"
                PosQ = CFrame.new(-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                PosM = CFrame.new(-7836.75341796875, 5645.6640625, -1790.6236572265625)
            elseif MyLevel >= 625 and MyLevel <= 649 then
                Mon = "Galley Pirate"; Qdata = 1; Qname = "FountainQuest"; NameMon = "Galley Pirate"
                PosQ = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, 0.087131381)
                PosM = CFrame.new(5551.02197265625, 78.90135192871094, 3930.412841796875)
            elseif MyLevel >= 650 then
                Mon = "Galley Captain"; Qdata = 2; Qname = "FountainQuest"; NameMon = "Galley Captain"
                PosQ = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, 0.087131381)
                PosM = CFrame.new(5441.95166015625, 42.50205993652344, 4950.09375)
            end
        elseif SeaIndex == 2 then
            if MyLevel >= 700 and MyLevel <= 724 then
                Mon = "Raider"; Qdata = 1; Qname = "Area1Quest"; NameMon = "Raider"
                PosQ = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, 0.974368095, 0, -0.22495985)
                PosM = CFrame.new(-728.3267211914062, 52.779319763183594, 2345.7705078125)
            elseif MyLevel >= 725 and MyLevel <= 774 then
                Mon = "Mercenary"; Qdata = 2; Qname = "Area1Quest"; NameMon = "Mercenary"
                PosQ = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, 0.974368095, 0, -0.22495985)
                PosM = CFrame.new(-1004.3244018554688, 80.15886688232422, 1424.619384765625)
            elseif MyLevel >= 775 and MyLevel <= 799 then
                Mon = "Swan Pirate"; Qdata = 1; Qname = "Area2Quest"; NameMon = "Swan Pirate"
                PosQ = CFrame.new(638.43811, 71.769989, 918.282898, 0.139203906, 0, 0.99026376, 0, 1, 0, -0.99026376, 0, 0.139203906)
                PosM = CFrame.new(1068.664306640625, 137.61428833007812, 1322.1060791015625)
            elseif MyLevel >= 800 and MyLevel <= 874 then
                Mon = "Factory Staff"; Qdata = 2; Qname = "Area2Quest"; NameMon = "Factory Staff"
                PosQ = CFrame.new(632.698608, 73.1055908, 918.666321, -0.0319722369, 0, -0.999488771, 0, 1, 0, 0.999488771, 0, -0.0319722369)
                PosM = CFrame.new(73.07867431640625, 81.86344146728516, -27.470672607421875)
            elseif MyLevel >= 875 and MyLevel <= 899 then
                Mon = "Marine Lieutenant"; Qdata = 1; Qname = "MarineQuest3"; NameMon = "Marine Lieutenant"
                PosQ = CFrame.new(-2440.79639, 71.7140732, -3216.06812, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
                PosM = CFrame.new(-2821.372314453125, 75.89727783203125, -3070.089111328125)
            elseif MyLevel >= 900 and MyLevel <= 949 then
                Mon = "Marine Captain"; Qdata = 2; Qname = "MarineQuest3"; NameMon = "Marine Captain"
                PosQ = CFrame.new(-2440.79639, 71.7140732, -3216.06812, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
                PosM = CFrame.new(-1861.2310791015625, 80.17658233642578, -3254.697509765625)
            elseif MyLevel >= 950 and MyLevel <= 974 then
                Mon = "Zombie"; Qdata = 1; Qname = "ZombieQuest"; NameMon = "Zombie"
                PosQ = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, 0, -0.95628953, 0, 1, 0, 0.95628953, 0, -0.29242146)
                PosM = CFrame.new(-5657.77685546875, 78.96973419189453, -928.68701171875)
            elseif MyLevel >= 975 and MyLevel <= 999 then
                Mon = "Vampire"; Qdata = 2; Qname = "ZombieQuest"; NameMon = "Vampire"
                PosQ = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, 0, -0.95628953, 0, 1, 0, 0.95628953, 0, -0.29242146)
                PosM = CFrame.new(-6037.66796875, 32.18463897705078, -1340.6597900390625)
            elseif MyLevel >= 1000 and MyLevel <= 1049 then
                Mon = "Snow Trooper"; Qdata = 1; Qname = "SnowMountainQuest"; NameMon = "Snow Trooper"
                PosQ = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, 0, 0.92718488, 0, 1, 0, -0.92718488, 0, -0.374604106)
                PosM = CFrame.new(549.1473388671875, 427.3870544433594, -5563.69873046875)
            elseif MyLevel >= 1050 and MyLevel <= 1099 then
                Mon = "Winter Warrior"; Qdata = 2; Qname = "SnowMountainQuest"; NameMon = "Winter Warrior"
                PosQ = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, 0, 0.92718488, 0, 1, 0, -0.92718488, 0, -0.374604106)
                PosM = CFrame.new(1142.7451171875, 475.6398010253906, -5199.41650390625)
            elseif MyLevel >= 1100 and MyLevel <= 1124 then
                Mon = "Lab Subordinate"; Qdata = 1; Qname = "IceSideQuest"; NameMon = "Lab Subordinate"
                PosQ = CFrame.new(-6064.06885, 15.2422857, -4902.97852, 0.453972578, 0, -0.891015649, 0, 1, 0, 0.891015649, 0, 0.453972578)
                PosM = CFrame.new(-5707.4716796875, 15.951709747314453, -4513.39208984375)
            elseif MyLevel >= 1125 and MyLevel <= 1174 then
                Mon = "Horned Warrior"; Qdata = 2; Qname = "IceSideQuest"; NameMon = "Horned Warrior"
                PosQ = CFrame.new(-6064.06885, 15.2422857, -4902.97852, 0.453972578, 0, -0.891015649, 0, 1, 0, 0.891015649, 0, 0.453972578)
                PosM = CFrame.new(-6341.36669921875, 15.951770782470703, -5723.162109375)
            elseif MyLevel >= 1175 and MyLevel <= 1199 then
                Mon = "Magma Ninja"; Qdata = 1; Qname = "FireSideQuest"; NameMon = "Magma Ninja"
                PosQ = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
                PosM = CFrame.new(-5449.6728515625, 76.65874481201172, -5808.20068359375)
            elseif MyLevel >= 1200 and MyLevel <= 1249 then
                Mon = "Lava Pirate"; Qdata = 2; Qname = "FireSideQuest"; NameMon = "Lava Pirate"
                PosQ = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
                PosM = CFrame.new(-5213.33154296875, 49.73788070678711, -4701.451171875)
            elseif MyLevel >= 1250 and MyLevel <= 1274 then
                Mon = "Ship Deckhand"; Qdata = 1; Qname = "ShipQuest1"; NameMon = "Ship Deckhand"
                PosQ = CFrame.new(1037.80127, 125.092171, 32911.6016)
                PosM = CFrame.new(1212.0111083984375, 150.79205322265625, 33059.24609375)
            elseif MyLevel >= 1275 and MyLevel <= 1299 then
                Mon = "Ship Engineer"; Qdata = 2; Qname = "ShipQuest1"; NameMon = "Ship Engineer"
                PosQ = CFrame.new(1037.80127, 125.092171, 32911.6016)
                PosM = CFrame.new(919.4786376953125, 43.54401397705078, 32779.96875)
            elseif MyLevel >= 1300 and MyLevel <= 1324 then
                Mon = "Ship Steward"; Qdata = 1; Qname = "ShipQuest2"; NameMon = "Ship Steward"
                PosQ = CFrame.new(968.80957, 125.092171, 33244.125)
                PosM = CFrame.new(919.4385375976562, 129.55599975585938, 33436.03515625)
            elseif MyLevel >= 1325 and MyLevel <= 1349 then
                Mon = "Ship Officer"; Qdata = 2; Qname = "ShipQuest2"; NameMon = "Ship Officer"
                PosQ = CFrame.new(968.80957, 125.092171, 33244.125)
                PosM = CFrame.new(1036.0179443359375, 181.4390411376953, 33315.7265625)
            elseif MyLevel >= 1350 and MyLevel <= 1374 then
                Mon = "Arctic Warrior"; Qdata = 1; Qname = "FrostQuest"; NameMon = "Arctic Warrior"
                PosQ = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, 0, -0.358349502, 0, 1, 0, 0.358349502, 0, -0.933587909)
                PosM = CFrame.new(5966.24609375, 62.97002029418945, -6179.3828125)
            elseif MyLevel >= 1375 and MyLevel <= 1424 then
                Mon = "Snow Lurker"; Qdata = 2; Qname = "FrostQuest"; NameMon = "Snow Lurker"
                PosQ = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, 0, -0.358349502, 0, 1, 0, 0.358349502, 0, -0.933587909)
                PosM = CFrame.new(5407.07373046875, 69.19437408447266, -6880.88037109375)
            elseif MyLevel >= 1425 and MyLevel <= 1449 then
                Mon = "Sea Soldier"; Qdata = 1; Qname = "ForgottenQuest"; NameMon = "Sea Soldier"
                PosQ = CFrame.new(-3054.44458, 235.544281, -10142.8193, 0.990270376, 0, -0.13915664, 0, 1, 0, 0.13915664, 0, 0.990270376)
                PosM = CFrame.new(-3028.2236328125, 64.67451477050781, -9775.4267578125)
            elseif MyLevel >= 1450 then
                Mon = "Water Fighter"; Qdata = 2; Qname = "ForgottenQuest"; NameMon = "Water Fighter"
                PosQ = CFrame.new(-3054, 240, -10146)
                PosM = CFrame.new(-3291, 252, -10501)
            end
        elseif SeaIndex == 3 then
            if MyLevel >= 1500 and MyLevel <= 1524 then
                Mon = "Pirate Millionaire"; Qdata = 1; Qname = "PiratePortQuest"; NameMon = "Pirate Millionaire"
                PosQ = CFrame.new(-290.074677, 42.9034653, 5581.58984, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627)
                PosM = CFrame.new(-245.9963836669922, 47.30615234375, 5584.1005859375)
            elseif MyLevel >= 1525 and MyLevel <= 1574 then
                Mon = "Pistol Billionaire"; Qdata = 2; Qname = "PiratePortQuest"; NameMon = "Pistol Billionaire"
                PosQ = CFrame.new(-290.074677, 42.9034653, 5581.58984, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627)
                PosM = CFrame.new(-187.3301544189453, 86.23987579345703, 6013.513671875)
            elseif MyLevel >= 1575 and MyLevel <= 1599 then
                Mon = "Dragon Crew Warrior"; Qdata = 1; Qname = "DragonCrewQuest"; NameMon = "Dragon Crew Warrior"
                PosQ = CFrame.new(6738.96142578125, 127.81645965576172, -713.511474609375)
                PosM = CFrame.new(6920.71435546875, 56.15597152709961, -942.5044555664062)
            elseif MyLevel >= 1600 and MyLevel <= 1624 then
                Mon = "Dragon Crew Archer"; Qdata = 2; Qname = "DragonCrewQuest"; NameMon = "Dragon Crew Archer"
                PosQ = CFrame.new(6738.96142578125, 127.81645965576172, -713.511474609375)
                PosM = CFrame.new(6817.91259765625, 484.804443359375, 513.4141235351562)
            elseif MyLevel >= 1625 and MyLevel <= 1649 then
                Mon = "Hydra Enforcer"; Qdata = 1; Qname = "VenomCrewQuest"; NameMon = "Hydra Enforcer"
                PosQ = CFrame.new(5213.8740234375, 1004.5042724609375, 758.6944580078125)
                PosM = CFrame.new(4584.69287109375, 1002.6435546875, 705.7958984375)
            elseif MyLevel >= 1650 and MyLevel <= 1699 then
                Mon = "Venomous Assailant"; Qdata = 2; Qname = "VenomCrewQuest"; NameMon = "Venomous Assailant"
                PosQ = CFrame.new(5213.8740234375, 1004.5042724609375, 758.6944580078125)
                PosM = CFrame.new(4638.78564453125, 1078.94091796875, 881.8002319335938)
            elseif MyLevel >= 1700 and MyLevel <= 1724 then
                Mon = "Marine Commodore"; Qdata = 1; Qname = "MarineTreeIsland"; NameMon = "Marine Commodore"
                PosQ = CFrame.new(2180.54126, 27.8156815, -6741.5498, -0.965929747, 0, 0.258804798, 0, 1, 0, -0.258804798, 0, -0.965929747)
                PosM = CFrame.new(2286.0078125, 73.13391876220703, -7159.80908203125)
            elseif MyLevel >= 1725 and MyLevel <= 1774 then
                Mon = "Marine Rear Admiral"; Qdata = 2; Qname = "MarineTreeIsland"; NameMon = "Marine Rear Admiral"
                PosQ = CFrame.new(2179.98828125, 28.731239318848, -6740.0551757813)
                PosM = CFrame.new(3656.773681640625, 160.52406311035156, -7001.5986328125)
            elseif MyLevel >= 1775 and MyLevel <= 1799 then
                Mon = "Fishman Raider"; Qdata = 2; Qname = "DeepForestIsland3"; NameMon = "Fishman Raider"
                PosQ = CFrame.new(3142.67822, 108.42981, 7482.37988, 0.34205412, 0, 0.939680243, 0, 1, 0, -0.939680243, 0, 0.34205412)
                PosM = CFrame.new(-10407.5263671875, 331.76263427734375, -8368.5166015625)
            elseif MyLevel >= 1800 and MyLevel <= 1824 then
                Mon = "Fishman Captain"; Qdata = 1; Qname = "DeepForestIsland3"; NameMon = "Fishman Captain"
                PosQ = CFrame.new(-10581.6563, 330.872955, -8761.18652, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
                PosM = CFrame.new(-10994.701171875, 352.38140869140625, -9002.1103515625)
            elseif MyLevel >= 1825 and MyLevel <= 1849 then
                Mon = "Forest Pirate"; Qdata = 2; Qname = "DeepForestIsland"; NameMon = "Forest Pirate"
                PosQ = CFrame.new(-13234.04, 331.488495, -7625.40137, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247)
                PosM = CFrame.new(-13274.478515625, 332.3781433105469, -7769.58056640625)
            elseif MyLevel >= 1850 and MyLevel <= 1899 then
                Mon = "Forest Pirate"; Qdata = 1; Qname = "DeepForestIsland"; NameMon = "Forest Pirate"
                PosQ = CFrame.new(-13234.04, 331.488495, -7625.40137, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247)
                PosM = CFrame.new(-13680.607421875, 501.08154296875, -6991.189453125)
            elseif MyLevel >= 1900 and MyLevel <= 1924 then
                Mon = "Jungle Pirate"; Qdata = 2; Qname = "DeepForestIsland"; NameMon = "Jungle Pirate"
                PosQ = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002)
                PosM = CFrame.new(-12256.16015625, 331.73828125, -10485.8369140625)
            elseif MyLevel >= 1925 and MyLevel <= 1974 then
                Mon = "Musketeer Pirate"; Qdata = 2; Qname = "DeepForestIsland2"; NameMon = "Musketeer Pirate"
                PosQ = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002)
                PosM = CFrame.new(-13457.904296875, 391.545654296875, -9859.177734375)
            elseif MyLevel >= 1975 and MyLevel <= 1999 then
                Mon = "Reborn Skeleton"; Qdata = 1; Qname = "HauntedQuest1"; NameMon = "Reborn Skeleton"
                PosQ = CFrame.new(-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, -0, -1, 0, 0)
                PosM = CFrame.new(-8763.7236328125, 165.72299194335938, 6159.86181640625)
            elseif MyLevel >= 2000 and MyLevel <= 2024 then
                Mon = "Living Zombie"; Qdata = 2; Qname = "HauntedQuest1"; NameMon = "Living Zombie"
                PosQ = CFrame.new(-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, -0, -1, 0, 0)
                PosM = CFrame.new(-10144.1318359375, 138.62667846679688, 5838.0888671875)
            elseif MyLevel >= 2025 and MyLevel <= 2049 then
                Mon = "Demonic Soul"; Qdata = 1; Qname = "HauntedQuest2"; NameMon = "Demonic Soul"
                PosQ = CFrame.new(-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                PosM = CFrame.new(-9505.8720703125, 172.10482788085938, 6158.9931640625)
            elseif MyLevel >= 2050 and MyLevel <= 2074 then
                Mon = "Posessed Mummy"; Qdata = 2; Qname = "HauntedQuest2"; NameMon = "Posessed Mummy"
                PosQ = CFrame.new(-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                PosM = CFrame.new(-9582.0224609375, 6.251527309417725, 6205.478515625)
            elseif MyLevel >= 2075 and MyLevel <= 2099 then
                Mon = "Peanut Scout"; Qdata = 1; Qname = "NutsIslandQuest"; NameMon = "Peanut Scout"
                PosQ = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                PosM = CFrame.new(-2143.241943359375, 47.72198486328125, -10029.9951171875)
            elseif MyLevel >= 2100 and MyLevel <= 2124 then
                Mon = "Peanut President"; Qdata = 1; Qname = "NutsIslandQuest"; NameMon = "Peanut President"
                PosQ = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                PosM = CFrame.new(-1859.35400390625, 38.10316848754883, -10422.4296875)
            elseif MyLevel >= 2125 and MyLevel <= 2149 then
                Mon = "Ice Cream Chef"; Qdata = 1; Qname = "IceCreamIslandQuest"; NameMon = "Ice Cream Chef"
                PosQ = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                PosM = CFrame.new(-872.24658203125, 65.81957244873047, -10919.95703125)
            elseif MyLevel >= 2150 and MyLevel <= 2199 then
                Mon = "Ice Cream Commander"; Qdata = 2; Qname = "IceCreamIslandQuest"; NameMon = "Ice Cream Commander"
                PosQ = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                PosM = CFrame.new(-558.06103515625, 112.04895782470703, -11290.7744140625)
            elseif MyLevel >= 2200 and MyLevel <= 2224 then
                Mon = "Cookie Crafter"; Qdata = 1; Qname = "CakeQuest1"; NameMon = "Cookie Crafter"
                PosQ = CFrame.new(-2021.32007, 37.7982254, -12028.7295, 0.957576931, -8.80302053e-08, 0.288177818, 6.9301187e-08, 1, 7.51931211e-08, -0.288177818, -5.2032135e-08, 0.957576931)
                PosM = CFrame.new(-2374.13671875, 37.79826354980469, -12125.30859375)
            elseif MyLevel >= 2225 and MyLevel <= 2249 then
                Mon = "Cake Guard"; Qdata = 2; Qname = "CakeQuest1"; NameMon = "Cake Guard"
                PosQ = CFrame.new(-2021.32007, 37.7982254, -12028.7295, 0.957576931, -8.80302053e-08, 0.288177818, 6.9301187e-08, 1, 7.51931211e-08, -0.288177818, -5.2032135e-08, 0.957576931)
                PosM = CFrame.new(-1598.3070068359375, 43.773197174072266, -12244.5810546875)
            elseif MyLevel >= 2250 and MyLevel <= 2274 then
                Mon = "Baking Staff"; Qdata = 1; Qname = "CakeQuest2"; NameMon = "Baking Staff"
                PosQ = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.22142143e-08, 0.250778586, 4.74911062e-08, 1, 1.49904711e-08, -0.250778586, 2.64211941e-08, -0.96804446)
                PosM = CFrame.new(-1887.8099365234375, 77.6185073852539, -12998.3505859375)
            elseif MyLevel >= 2275 and MyLevel <= 2299 then
                Mon = "Head Baker"; Qdata = 2; Qname = "CakeQuest2"; NameMon = "Head Baker"
                PosQ = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.22142143e-08, 0.250778586, 4.74911062e-08, 1, 1.49904711e-08, -0.250778586, 2.64211941e-08, -0.96804446)
                PosM = CFrame.new(-2216.188232421875, 82.884521484375, -12869.2939453125)
            elseif MyLevel >= 2300 and MyLevel <= 2324 then
                Mon = "Cocoa Warrior"; Qdata = 1; Qname = "ChocQuest1"; NameMon = "Cocoa Warrior"
                PosQ = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375)
                PosM = CFrame.new(-21.55328369140625, 80.57499694824219, -12352.3876953125)
            elseif MyLevel >= 2325 and MyLevel <= 2349 then
                Mon = "Chocolate Bar Battler"; Qdata = 2; Qname = "ChocQuest1"; NameMon = "Chocolate Bar Battler"
                PosQ = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375)
                PosM = CFrame.new(582.590576171875, 77.18809509277344, -12463.162109375)
            elseif MyLevel >= 2350 and MyLevel <= 2374 then
                Mon = "Sweet Thief"; Qdata = 1; Qname = "ChocQuest2"; NameMon = "Sweet Thief"
                PosQ = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875)
                PosM = CFrame.new(165.1884765625, 76.05885314941406, -12600.8369140625)
            elseif MyLevel >= 2375 and MyLevel <= 2399 then
                Mon = "Candy Rebel"; Qdata = 2; Qname = "ChocQuest2"; NameMon = "Candy Rebel"
                PosQ = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875)
                PosM = CFrame.new(134.86563110351562, 77.2476806640625, -12876.5478515625)
            elseif MyLevel >= 2400 and MyLevel <= 2424 then
                Mon = "Candy Pirate"; Qdata = 1; Qname = "CandyQuest1"; NameMon = "Candy Pirate"
                PosQ = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375)
                PosM = CFrame.new(-1310.5003662109375, 26.016523361206055, -14562.404296875)
            elseif MyLevel >= 2425 and MyLevel <= 2449 then
                Mon = "Snow Demon"; Qdata = 2; Qname = "CandyQuest1"; NameMon = "Snow Demon"
                PosQ = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375)
                PosM = CFrame.new(-880.2006225585938, 71.24776458740234, -14538.609375)
            elseif MyLevel >= 2450 and MyLevel <= 2474 then
                Mon = "Isle Outlaw"; Qdata = 1; Qname = "TikiQuest1"; NameMon = "Isle Outlaw"
                PosQ = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632812)
                PosM = CFrame.new(-16442.814453125, 116.13899993896484, -264.4637756347656)
            elseif MyLevel >= 2475 and MyLevel <= 2499 then
                Mon = "Island Boy"; Qdata = 2; Qname = "TikiQuest1"; NameMon = "Island Boy"
                PosQ = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632812)
                PosM = CFrame.new(-16901.26171875, 84.06756591796875, -192.88906860351562)
            -- [FIX] faltavam Sun-kissed Warrior e Serpent Hunter (Isle Champion usava a quest errada)
            elseif MyLevel >= 2500 and MyLevel <= 2524 then
                Mon = "Sun-kissed Warrior"; Qdata = 1; Qname = "TikiQuest2"; NameMon = "Sun-kissed Warrior"
                PosQ = CFrame.new(-16539.078125, 55.68632888793945, 1051.5738525390625)
                PosM = CFrame.new(-16641.6796875, 235.7825469970703, 1031.282958984375)
            elseif MyLevel >= 2525 and MyLevel <= 2549 then
                Mon = "Isle Champion"; Qdata = 2; Qname = "TikiQuest2"; NameMon = "Isle Champion"
                PosQ = CFrame.new(-16539.078125, 55.68632888793945, 1051.5738525390625)
                PosM = CFrame.new(-16641.6796875, 235.7825469970703, 1031.282958984375)
            elseif MyLevel >= 2550 and MyLevel <= 2574 then
                Mon = "Serpent Hunter"; Qdata = 1; Qname = "TikiQuest3"; NameMon = "Serpent Hunter"
                PosQ = CFrame.new(-16665.1914, 104.596405, 1579.69434)
                PosM = CFrame.new(-16887.7305, 113.074638, 1629.97778)
            elseif MyLevel >= 2575 and MyLevel <= 2599 then
                Mon = "Skull Slayer"; Qdata = 2; Qname = "TikiQuest3"; NameMon = "Skull Slayer"
                PosQ = CFrame.new(-16665.1914, 104.596405, 1579.69434, 0.951068401, -0, -0.308980465, 0, 1, -0, 0.308980465, 0, 0.951068401)
                PosM = CFrame.new(-16887.7305, 113.074638, 1629.97778, -0.559032857, 1.2313353e-08, -0.829145491, 1.05618814e-09, 1, 1.41385428e-08, 0.829145491, 7.02817626e-09, -0.559032857)
            elseif MyLevel >= 2600 and MyLevel <= 2624 then
                Mon = "Reef Bandit"; Qdata = 1; Qname = "SubmergedQuest1"; NameMon = "Reef Bandit"
                PosQ = CFrame.new(10778.875, -2087.72437, 9265.18359, 0.934615612, -9.33109447e-08, -0.355659455, 9.17655143e-08, 1, -2.12154276e-08, 0.355659455, -1.28090019e-08, 0.934615612)
                PosM = CFrame.new(11019.1318, -2146.06812, 9342.3916, -0.719955266, -1.74275385e-08, 0.69402045, 5.76556367e-08, 1, 8.49211546e-08, -0.69402045, 1.01153624e-07, -0.719955266)
            elseif MyLevel >= 2625 and MyLevel <= 2649 then
                Mon = "Coral Pirate"; Qdata = 2; Qname = "SubmergedQuest1"; NameMon = "Coral Pirate"
                PosQ = CFrame.new(10778.875, -2087.72437, 9265.18359, 0.934615612, -9.33109447e-08, -0.355659455, 9.17655143e-08, 1, -2.12154276e-08, 0.355659455, -1.28090019e-08, 0.934615612)
                PosM = CFrame.new(10808.6006, -2030.36145, 9364.2334, -0.775185347, -0.0359364748, 0.6307109, 0.0615428537, 0.989336014, 0.132010356, -0.628728986, 0.141148239, -0.764707148)
            elseif MyLevel >= 2650 and MyLevel <= 2674 then
                Mon = "Sea Chanter"; Qdata = 1; Qname = "SubmergedQuest2"; NameMon = "Sea Chanter"
                PosQ = CFrame.new(10880.6855, -2086.20044, 10032.624, -0.321384728, 9.87648434e-08, -0.946948707, 7.13271007e-08, 1, 8.00902953e-08, 0.946948707, -4.18033075e-08, -0.321384728)
                PosM = CFrame.new(10671.2715, -2057.59155, 10047.2588)
            elseif MyLevel >= 2675 and MyLevel <= 2699 then
                Mon = "Ocean Prophet"; Qdata = 2; Qname = "SubmergedQuest2"; NameMon = "Ocean Prophet"
                PosQ = CFrame.new(10880.6855, -2086.20044, 10032.624, -0.321384728, 9.87648434e-08, -0.946948707, 7.13271007e-08, 1, 8.00902953e-08, 0.946948707, -4.18033075e-08, -0.321384728)
                PosM = CFrame.new(11008.5195, -2007.72839, 10223.0791, -0.688615739, 2.33523378e-09, -0.725126445, 2.99292546e-09, 1, 3.78221315e-10, 0.725126445, -1.90980032e-09, -0.688615739)
            elseif MyLevel >= 2700 and MyLevel <= 2724 then
                Mon = "High Disciple"; Qdata = 1; Qname = "SubmergedQuest3"; NameMon = "High Disciple"
                PosQ = CFrame.new(9640.08789, -1992.44507, 9613.65234, -0.957327187, 4.11991223e-08, 0.289006323, 1.5775445e-08, 1, -9.02985846e-08, -0.289006323, -8.18860855e-08, -0.957327187)
                PosM = CFrame.new(9750.41602, -1966.93884, 9753.36035, -0.749824047, 5.57797613e-08, -0.661637306, 2.03500754e-08, 1, 6.1243199e-08, 0.661637306, 3.24572511e-08, -0.749824047)
            elseif MyLevel >= 2725 then
                Mon = "Grand Devotee"; Qdata = 2; Qname = "SubmergedQuest3"; NameMon = "Grand Devotee"
                PosQ = CFrame.new(9640.08789, -1992.44507, 9613.65234, -0.957327187, 4.11991223e-08, 0.289006323, 1.5775445e-08, 1, -9.02985846e-08, -0.289006323, -8.18860855e-08, -0.957327187)
                PosM = CFrame.new(9611.70508, -1993.47119, 9882.68848, -0.591375351, 4.14332426e-08, -0.806396425, 4.73774868e-08, 1, 1.66361875e-08, 0.806396425, -2.83668058e-08, -0.591375351)
            end
        end

        if Mon == "" or not PosM then return nil end
        return {Mon = Mon, Qdata = Qdata, Qname = Qname, NameMon = NameMon, PosQ = PosQ, PosM = PosM}
    end

    -- [ADDED] MAX LEVEL FARM: above the manual table (max level 2800) there is no mob,
    -- so the script farms the Dough King. If it is not spawned for 30s, it hops to find it.
    FlowbrMaxFarmSince = os.clock()
    function FlowbrMaxLevelFarm()
        local MAX_FARM_BOSS = "Dough King"
        local boss = ScriptStorage.Enemies[MAX_FARM_BOSS]
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            FlowbrMaxFarmSince = os.clock()
            SetTask("MainTask", "Max Level Farm | " .. MAX_FARM_BOSS)
            SetTask("SubTask", "👑 Attacking " .. MAX_FARM_BOSS)
            CombatController.Attack(MAX_FARM_BOSS)
            return
        end
        local waited = os.clock() - FlowbrMaxFarmSince
        SetTask("MainTask", "Max Level Farm | Waiting for " .. MAX_FARM_BOSS)
        SetTask("SubTask", ("Not spawned yet (%ds), hop after 30s"):format(math.floor(waited)))
        if waited >= 30 then
            FlowbrMaxFarmSince = os.clock()
            Hop()
        end
    end


    -- ══════════════════════════════════════════════════════════════════
    -- [ADDED] AUTO STORE FRUIT - stores fruits from Backpack/Character into inventory every 1s.
    -- ScriptStorage.IgnoreStoreFruits prevents storing fruits used by AutoRandomFruit / AutoRaidIce.
    -- ══════════════════════════════════════════════════════════════════
    task.spawn(function()
        while true do
            pcall(function()
                local gg = {}
                for _, container in next, {LocalPlayer.Backpack, LocalPlayer.Character} do
                    if container then
                        for _, v in next, container:GetChildren() do
                            if v.Name:find("Fruit") and v:IsA("Tool") then
                                local ori = v:GetAttribute("OriginalName") or v.Name
                                -- Skip if held by IgnoreStoreFruits
                                if not table.find(ScriptStorage.IgnoreStoreFruits, v.Name)
                                and not table.find(ScriptStorage.IgnoreStoreFruits, ori) then
                                    table.insert(gg, {tool = v, ori = ori})
                                end
                            end
                        end
                    end
                end
                if #gg > 0 then
                    local sf = {}
                    local ok, inv = pcall(function()
                        return Remotes.CommF_:InvokeServer("getInventoryFruits")
                    end)
                    if ok and type(inv) == "table" then
                        for _, _v in pairs(inv) do
                            if type(_v) == "table" and _v.Name then
                                sf[_v.Name] = true
                            end
                        end
                    end
                    for _, v in pairs(gg) do
                        if not sf[v.ori] then
                            pcall(function()
                                Remotes.CommF_:InvokeServer("StoreFruit", v.ori, v.tool)
                            end)
                            sf[v.ori] = true
                        end
                    end
                end
            end)
            -- DLCBoxData ping (kept as original)
            pcall(function()
                Remotes.CommF_:InvokeServer("Cousin", "DLCBoxData")
            end)
            task.wait(1)
        end
    end)

    -- [ADDED] AUTO RANDOM FRUIT - randomly swaps between owned Devil Fruits using getInventoryFruits + LoadFruit,
    -- reading Config.Items.AutoRandomFruit.
    task.spawn(function()
        while task.wait(30) do
            pcall(function()
                if not Config.Items.AutoRandomFruit then return end
                local ok, inventoryFruits = pcall(function()
                    return Remotes.CommF_:InvokeServer("getInventoryFruits")
                end)
                if not ok or type(inventoryFruits) ~= "table" then return end
                local names = {}
                for _, fruitData in pairs(inventoryFruits) do
                    if fruitData and fruitData.Name then
                        table.insert(names, fruitData.Name)
                    end
                end
                if #names == 0 then return end
                local picked = names[math.random(1, #names)]
                table.insert(ScriptStorage.IgnoreStoreFruits, picked)
                Remotes.CommF_:InvokeServer("LoadFruit", picked)
            end)
        end
    end)

    -- ══════════════════════════════════════════════════════════════════
    -- [REPLACED] CheckDataLevel ported from message(10). NOTE: hard level->mob mapping with no real position check
    -- (risk of freezing if the position does not match). Mapping: plr.Data.Level.Value -> ScriptStorage.PlayerData.Level
    -- ══════════════════════════════════════════════════════════════════
    FunctionsHandler.LevelFarm:RegisterMethod("Refresh", function()
        -- Guard against conflicts with AutoSea2/AutoSea3
        -- [FIXED] the sea-transition lock only matters outside Sea 3 (a stuck flag stopped the farm)
        if _G.SeaTransitionActive and SeaIndex ~= 3 then return nil end

        local lv = ScriptStorage.PlayerData.Level or 0
        -- Same mapping as message(10) CheckDataLevel()
        if lv < 10 then
            return 1
        elseif lv < 70 then
            return 2   -- Shanda @ Upper Skylands
        elseif lv < 120 then
            return 3   -- God's Guard @ Skylands
        else
            return 4
        end
    end)
    -- ══════════════════════════════════════════════════════════════════
    -- [REPLACED] FarmLevelLogic port. Mapping: plr.Data.Level.Value -> ScriptStorage.PlayerData.Level; PLACE_ID.sea1/2/3() -> SeaIndex;
    -- bringMob+equipWeapon+FastAttack -> CombatController.Attack(name); Teleport("sky 2/3") -> TweenController.Create.
    -- HYBRID: checks the real location (CurrentLocation) before tweening so it does not freeze.
    -- ══════════════════════════════════════════════════════════════════
    FunctionsHandler.LevelFarm:RegisterMethod("Start", function(h)
        local currentLevel = ScriptStorage.PlayerData.Level or 0

        -- Guard: level is high enough for Sea 2 -> stop farming Sea 1
        if currentLevel >= 700 and SeaIndex == 1 then return end

        -- Sea 3: farm Bones if needed (original DynamicIsland behaviour)
        if SeaIndex == 3 then
            if (ScriptStorage.Backpack.Bones or {Count = 0}).Count >= 50 then
                if os.time() > (BonesCooldown or 0) then
                    local X, X, X, w = Remotes.CommF_:InvokeServer("Bones", "Check")
                    if tonumber(X or 1) == 0 then
                        local X = Split(w, ":")
                        local w = ((tonumber(X[1]) * 60) + tonumber(X[2])) * 60
                        BonesCooldown = os.time() + w
                    else
                        Remotes.CommF_:InvokeServer("Bones", "Buy", 1, 1)
                    end
                end
            end
        end

        -- h == 2: level 10-69 -> farm Shanda @ Upper Skylands (levelData == 2 branch of message(10).txt)
        if h == 2 then
            if SeaIndex == 1 then
                local loc = LocalPlayer:GetAttribute("CurrentLocation")
                if not loc or (loc ~= "Skylands" and loc ~= "Upper Skylands") then
                    -- [FIXED] requestEntrance removed, tween only
                    TweenController.Create(CFrame.new(-7894, 5547, -380))
                    task.wait(1)
                    return
                end
            end
            SetTask("MainTask", "Level Farm | Shanda | Upper Skylands")

            local foundMob = false
            for _, folder in ipairs({workspace.Enemies, game.ReplicatedStorage}) do
                for _, v2 in ipairs(folder:GetChildren()) do
                    if v2.Name == "Shanda" and v2:IsA("Model") then
                        local hum = v2:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            foundMob = true
                            SetTask("SubTask", "⚔️ Attacking Shanda")
                            CombatController.Attack("Shanda")
                            break
                        end
                    end
                end
                if foundMob then break end
            end
            if not foundMob then
                local spawnFolder = game.ReplicatedStorage:FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
                local n = spawnFolder and spawnFolder:FindFirstChild("Shanda")
                if n then
                    TweenController.Create(n:GetPivot() + Vector3.new(0, 25, 0))
                else
                    TweenController.Create(CFrame.new(-7783, 5576, -519))
                end
            end

        -- h == 3: level 70-119 -> farm God's Guard @ Skylands
        elseif h == 3 then
            if SeaIndex == 1 then
                local loc = LocalPlayer:GetAttribute("CurrentLocation")
                if not loc or (loc ~= "Skylands" and loc ~= "Upper Skylands") then
                    -- [FIXED] requestEntrance removed, tween only
                    TweenController.Create(CFrame.new(-4650, 872, -1775))
                    task.wait(1.5)
                    return
                end
            end
            SetTask("MainTask", "Level Farm | God's Guard | Skylands")

            local foundMob = false
            for _, folder in ipairs({workspace.Enemies, game.ReplicatedStorage}) do
                for _, v2 in ipairs(folder:GetChildren()) do
                    if v2.Name == "God's Guard" and v2:IsA("Model") then
                        local hum = v2:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            foundMob = true
                            SetTask("SubTask", "⚔️ Attacking God's Guard")
                            CombatController.Attack("God's Guard")
                            break
                        end
                    end
                end
                if foundMob then break end
            end
            if not foundMob then
                local spawnFolder = game.ReplicatedStorage:FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
                local n = spawnFolder and spawnFolder:FindFirstChild("God's Guard")
                if n then
                    TweenController.Create(n:GetPivot() + Vector3.new(0, 25, 0))
                end
            end

        -- === h == 4 / h == 1: general farm via ManualLevelLookup ========
        else
            local Q = ManualLevelLookup()
            if not Q then
                -- [ADDED] Level above the manual table (2800 max): farm the Dough King instead
                if SeaIndex == 3 and currentLevel >= 2700 then
                    return FlowbrMaxLevelFarm()
                end
                Report("LevelFarm: ManualLevelLookup found no matching range (lv="
                    .. tostring(currentLevel) .. ", sea=" .. tostring(SeaIndex) .. ")")
                return
            end
            local activeQuestName = GetActiveQuestName()
            if activeQuestName ~= nil then
                if activeQuestName ~= false then
                    if activeQuestName ~= Q.Qname then return J.AbandonQuest() end
                else
                    if not Q.PosQ then return end
                    TweenController.Create(Q.PosQ + Vector3.new(0, 5, 3))
                    SetTask("SubTask", "📋 " .. Q.NameMon .. " | Quest: " .. Q.Mon)
                    SetTask("MainTask", "Level Farm | " .. Q.Mon .. " | Accepting Quest")
                    if CaculateDistance(Q.PosQ) > 10 then return end
                    task.wait(0.5)
                    LevelFarmTTL = 0
                    J.StartQuest(Q.Qname, Q.Qdata)
                    task.wait(0.3)
                end
            else
                CurrentClaimQuest1 = GetCurrentClaimQuest()
                if CurrentClaimQuest1 then
                    if CurrentClaimQuest1 ~= Q.NameMon and CurrentClaimQuest1 ~= (Q.NameMon .. "s") then
                        return J.AbandonQuest()
                    end
                else
                    if not Q.PosQ then return end
                    TweenController.Create(Q.PosQ + Vector3.new(0, 5, 3))
                    SetTask("SubTask", "📋 " .. Q.NameMon .. " | Quest: " .. Q.Mon)
                    SetTask("MainTask", "Level Farm | " .. Q.Mon .. " | Accepting Quest")
                    if CaculateDistance(Q.PosQ) > 10 then return end
                    task.wait(0.5)
                    LevelFarmTTL = 0
                    J.StartQuest(Q.Qname, Q.Qdata)
                    task.wait(0.3)
                end
            end
            -- CombatController.Attack finds the mob, tweens and attacks (replaces bringMob + equipWeapon + FastAttack + CheckMonster)
            SetTask("MainTask", "Level Farm | " .. Q.Mon)
            CombatController.Attack(Q.Mon)
        end
    end)

    -- ============================================================
    -- EQUIP WEAPON (from test.txt - already built into CombatController.Attack)
    -- ============================================================
    FunctionsHandler.LocalPlayerController:RegisterMethod("EquipTool", function(h)
        if not Humanoid then return end
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if not bp then return end
        for X, X in bp:GetChildren() do
            if X:IsA('Tool') and X.Name ~= "Tool" and (X.Name == tostring(h) or X.ToolTip == h) then
                LocalPlayer.Character:WaitForChild('Humanoid'):EquipTool(X)
            end
        end
    end)
    FunctionsHandler.LocalPlayerController:RegisterMethod('ToggleAbilities', function(h, X)
        if h == 'Buso' then
            if LocalPlayer:HasTag('Buso') and not X or X then Remotes.CommF_:InvokeServer('Buso') end
        elseif h == "Observation" then
        end
    end)
    FunctionsHandler.LocalPlayerController:RegisterMethod('ConfigurationAbilitiesToggle', function()
        FunctionsHandler.LocalPlayerController.Methods.ToggleAbilities:Call('Buso', SCRIPT_CONFIG.BUSO)
        FunctionsHandler.LocalPlayerController.Methods.ToggleAbilities:Call('Observation', SCRIPT_CONFIG.OBSERVATION)
    end)
    print(3)

    -- ============================================================
    -- SABER QUEST
    -- ============================================================
    FunctionsHandler.Saber:RegisterMethod('Refresh', function()
        if not Config.Items.Saber then return end
        if ScriptStorage.Backpack.Saber then return end
        if ScriptStorage.PlayerData.Level < 200 then return end
        local X = Remotes.CommF_:InvokeServer('ProQuestProgress')
        local h
        for w, w in X.Plates do if w == false then h = 1 end end
        if not h then
            if not X.UsedTorch then h = 2
            elseif not X.UsedCup then h = 3
            elseif not X.TalkedSon then h = 4
            elseif not X.KilledMob then h = 5
            elseif not X.UsedRelic then h = 6
            elseif not X.KilledShanks and ScriptStorage.Enemies["Saber Expert"] then h = 7 end
        end
        FunctionsHandler.Saber:Set("CurrentProgressLevel", h)
        FunctionsHandler.Saber:Set('LastestRefreshSenque', os.time())
        return h
    end)

    FunctionsHandler.Saber:RegisterMethod('GetQuestplates', function()
        local h = FunctionsHandler.Saber:Get("QuestplatesCache")
        if h then return h end
        local h = Services.Workspace.Map.Jungle
        local X = {}
        table.foreach(h.QuestPlates:GetChildren(), function(h, w) h = w:FindFirstChild("Button") and table.insert(X, w) end)
        FunctionsHandler.Saber:Set('QuestplatesCache', X)
        return X
    end)

    FunctionsHandler.Saber:RegisterMethod('Start', function()
        local h, X = FunctionsHandler.Saber:Get("CurrentProgressLevel"), FunctionsHandler.Saber:Get('LastestRefreshSenque')
        if not h then
            FunctionsHandler.Saber.Methods.Refresh:Call()
            return FunctionsHandler.Saber.Methods.Start:Call()
        elseif h == 0 then
        elseif os.time() - X > 60 then
            FunctionsHandler.Saber.Methods.Refresh:Call()
            return FunctionsHandler.Saber.Methods.Start:Call()
        else
            if h == 1 then
                local X = FunctionsHandler.Saber.Methods.GetQuestplates:Call()
                for w, D in X do
                    SetTask('MainTask', "Saber Quest | Quest Plates | Touching " .. w .. "/5")
                    while CaculateDistance(D.Button.CFrame) > 20 do
                        task.wait()
                        TweenController.Create(D.Button.CFrame)
                    end
                    task.wait(1)
                end
            elseif h == 2 then
                SetTask('MainTask', 'Saber Quest | Torch Puzzle | Using Torch')
                Remotes.CommF_:InvokeServer("ProQuestProgress", 'GetTorch')
                task.wait(1)
                Remotes.CommF_:InvokeServer('ProQuestProgress', "DestroyTorch")
            elseif h == 3 then
                SetTask('MainTask', "Saber Quest | Sick Man | Helping with Cup")
                Remotes.CommF_:InvokeServer('ProQuestProgress', "GetCup")
                if ScriptStorage.Tools.Cup then
                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call('Cup')
                    task.wait(1)
                    Remotes.CommF_:InvokeServer("ProQuestProgress", 'FillCup', LocalPlayer.Character.Cup)
                end
                Remotes.CommF_:InvokeServer("ProQuestProgress", 'SickMan')
            elseif h == 4 then
                SetTask('MainTask', 'Saber Quest | Rich Son | Getting Information')
                Remotes.CommF_:InvokeServer('ProQuestProgress', 'RichSon')
            elseif h == 5 then
                SetTask("MainTask", "Saber Quest | Mob Leader | Defeating Boss")
                CombatController.Attack('Mob Leader')
            elseif h == 6 then
                SetTask("MainTask", 'Saber Quest | Relic | Placing at Location')
                Remotes.CommF_:InvokeServer('ProQuestProgress', 'RichSon')
                Remotes.CommF_:InvokeServer("ProQuestProgress", "PlaceRelic")
            elseif h == 7 then
                SetTask('MainTask', "Saber Quest | Saber Expert | Final Battle")
                CombatController.Attack("Saber Expert")
            end
        end
    end)
    pcall(function() -- [FIX v10] RefreshQuestPro may not exist: it used to throw and abort the whole script load
        local rqp = game:GetService('ReplicatedStorage'):FindFirstChild('Remotes') and game:GetService('ReplicatedStorage').Remotes:FindFirstChild('RefreshQuestPro')
        if rqp then rqp.OnClientEvent:Connect(FunctionsHandler.Saber.Methods.Refresh.Callback) end
    end)

    -- ============================================================
    -- SECOND SEA PUZZLE (DRESSROSA)
    -- ============================================================
    FunctionsHandler.SecondSeaPuzzle:RegisterMethod('Refresh', function()
        if ScriptStorage.PlayerData.Level < 700 or SeaIndex ~= 1 then return end
        if FunctionsHandler.SecondSeaPuzzle:Get('IsCompleted') then return end
        local k = Remotes.CommF_:InvokeServer('DressrosaQuestProgress')
        if not k.TalkedDetective then Result = 1
        elseif not k.KilledIceBoss then Result = 2
        else FunctionsHandler.SecondSeaPuzzle:Set("IsCompleted", true) end
        FunctionsHandler.SecondSeaPuzzle:Set("CurrentProgressLevel", Result)
        FunctionsHandler.SecondSeaPuzzle:Set('LastestRefreshSenque', os.time())
        return Result
    end)

    FunctionsHandler.SecondSeaPuzzle:RegisterMethod("Start", function()
        local k, h = FunctionsHandler.SecondSeaPuzzle:Get('CurrentProgressLevel'), FunctionsHandler.SecondSeaPuzzle:Get('LastestRefreshSenque')
        FunctionsHandler.SecondSeaPuzzle:Set('CurrentProgressLevel', nil)
        if not k then
            FunctionsHandler.SecondSeaPuzzle.Methods.Refresh:Call()
            return FunctionsHandler.SecondSeaPuzzle.Methods.Start:Call()
        elseif k == 1 then
            SetTask('SubTask', '🧩 Sea2: Talk to Detective')
            SetTask('MainTask', "Auto Second Sea - Talk To Detective")
            Remotes.CommF_:InvokeServer('DressrosaQuestProgress', 'Detective')
            Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")
            task.wait(1)
            Remotes.CommF_:InvokeServer('DressrosaQuestProgress', 'UseKey')
        elseif k == 2 then
            SetTask('SubTask', '🧩 Sea2: Defeat Ice Admiral')
            Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")
            Remotes.CommF_:InvokeServer('DressrosaQuestProgress', 'Detective')
            task.wait(1)
            Remotes.CommF_:InvokeServer('DressrosaQuestProgress', 'UseKey')
            SetTask("MainTask", "Auto Second Sea - Defeating Ice Admiral")
            CombatController.Attack("Ice Admiral")
            Remotes.CommF_:InvokeServer('TravelDressrosa')
        end
    end)

    -- ============================================================
    -- COLOSSEUM PUZZLE (BARTILO)
    -- ============================================================
    FunctionsHandler.ColosseumPuzzle:RegisterMethod("Refresh", function()
        if SeaIndex ~= 2 then return end
        if ScriptStorage.PlayerData.Level < 850 or ScriptStorage.Backpack['Warrior Helmet'] then return end
        local k = Remotes.CommF_:InvokeServer("BartiloQuestProgress")
        if not k.KilledBandits then Result = 1
        elseif not k.KilledSpring then
            if ScriptStorage.Enemies.Jeremy then Result = 2 end
        elseif not k.DidPlates then Result = 3 end
        FunctionsHandler.ColosseumPuzzle:Set("CurrentProgressLevel", Result)
        FunctionsHandler.ColosseumPuzzle:Set("LastestRefreshSenque", os.time())
        return Result
    end)

    FunctionsHandler.ColosseumPuzzle:RegisterMethod('Start', function()
        local k, h = FunctionsHandler.ColosseumPuzzle:Get("CurrentProgressLevel"), FunctionsHandler.ColosseumPuzzle:Get("LastestRefreshSenque")
        FunctionsHandler.ColosseumPuzzle:Set("CurrentProgressLevel", nil)
        if not k then
            FunctionsHandler.ColosseumPuzzle.Methods.Refresh:Call()
            return FunctionsHandler.ColosseumPuzzle.Methods.Start:Call()
        elseif k == 1 then
            SetTask("MainTask", 'Auto Bartilo Quest - Defeating 50x Swan Pirate')
            local h, X = J:GetCurrentClaimQuest()
            if h then
                if not string.find(X, '50') then J.AbandonQuest()
                else CombatController.Attack("Swan Pirate") end
            else
                J.StartQuest('BartiloQuest', 1)
            end
        elseif k == 2 then
            SetTask('MainTask', "Auto Bartilo Quest - Defeating Jeremy")
            CombatController.Attack("Jeremy")
        elseif k == 3 then
            SetTask("MainTask", 'Auto Bartilo Quest - Doing Puzzle')
            if CaculateDistance(CFrame.new(-1837.46155, 44.2921753, 1656.1987, 0.999881566, -1.03885048e-22, -0.0153914848, 1.07805858e-22, 1, 2.53909284e-22, 0.0153914848, -2.55538502e-22, 0.999881566)) > 10 then
                alert("tween to")
                TweenController.Create(CFrame.new(-1837.46155, 44.2921753, 1656.1987, 0.999881566, -1.03885048e-22, -0.0153914848, 1.07805858e-22, 1, 2.53909284e-22, 0.0153914848, -2.55538502e-22, 0.999881566))
            else
                LocalPlayer = game.Players.LocalPlayer
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1836.0, 11, 1714)
                alert("1")
                task.wait(.5)
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1850.49329, 13.1789551, 1750.89685)
                alert('2')
                task.wait(1)
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1858.87305, 19.3777466, 1712.01807)
                alert("3")
                task.wait(1)
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1803.94324, 16.5789185, 1750.89685)
                task.wait(1)
                alert("4")
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1858.55835, 16.8604317, 1724.79541)
                task.wait(1)
                alert('5')
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1869.54224, 15.987854, 1681.00659)
                task.wait(1)
                alert("6")
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1800.0979, 16.4978027, 1684.52368)
                task.wait(1)
                alert("7")
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1819.26343, 14.795166, 1717.90625)
                task.wait(1)
                alert("8")
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1813.51843, 14.8604736, 1724.79541)
            end
        end
    end)

    -- ============================================================
    -- EVOLUTION RACE (RACE V2)
    -- ============================================================
    FunctionsHandler.EvoRace:RegisterMethod("Refresh", function()
        if not Config.Items.RaceV2 then return end
        if SeaIndex ~= 2 then return end
        if getsenv(game.ReplicatedStorage.GuideModule)._G.ServerData.ExpBoost ~= 0 or ScriptStorage.PlayerData.Level < 900 or ScriptStorage.PlayerData.Beli < 1000000 or ScriptStorage.PlayerData.RaceLevel ~= 1 then return end
        return true
    end)

    FunctionsHandler.EvoRace:RegisterMethod('Start', function()
        Remotes.CommF_:InvokeServer('Alchemist', "1")
        Remotes.CommF_:InvokeServer('Alchemist', '2')
        for k = 1, 2, 1 do
            SetTask('SubTask', '🌈 Collecting Flower ' .. k .. ' for Race V2')
            local h = ScriptStorage.Tools["Flower " .. k]
            local X = Services.Workspace:FindFirstChild('Flower' .. k)
            if not h then
                if X and X.Transparency == 0 then
                    SetTask('MainTask', 'Auto Race V2 - Collecting Flower ' .. k)
                    while not ScriptStorage.Tools["Flower " .. k] do
                        task.wait()
                        TweenController.Create(X.CFrame + Vector3.new(0, math.random(-1.0, 2), 0))
                    end
                end
            end
        end
        if not ScriptStorage.Tools['Flower 3'] then
            SetTask('SubTask', '🌈 Farming Swan Pirate for Flower 3')
            SetTask('MainTask', 'Auto Race V2 - Collecting Flower ' .. 3)
            CombatController.Attack('Swan Pirate')
        else
            SetTask('SubTask', '🌈 Race V2 completed, idling...')
            SetTask("MainTask", 'Auto Race V2 - Idling')
            if LocalPlayer.Character.HumanoidRootPart.CFrame.Y < 50000 then
                TweenController.Create(LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 50, 0))
            end
            Remotes.CommF_:InvokeServer("Alchemist", "3")
            RefreshRace()
        end
    end)

    -- ============================================================
    -- [REBUILT] RACE AWAKENING (Race V3): rebuilt from verified data.
    -- Human boss order is Jeremy -> Diamond -> Orbitus, with real waiting positions; Wenlocktoad("1") is the state driver.
    -- [NEW] Mink race ("Rabbit"): farm 30 workspace.ChestModels then claim. Fishman race left untouched.
    -- ============================================================
    local _raceAwakenState = {
        humanStage = 0,  -- 0=Jeremy, 1=Diamond, 2=Orbitus, 3=claim
        minkChestsDone = 0,
    }
    local HUMAN_V3_WAIT_CF = {
        [0] = CFrame.new(2333.209228515625, 449.2427062988281, 699.5128784179688),   -- waiting for Jeremy
        [1] = CFrame.new(-1713.5589599609375, 198.99554443359375, -104.31584167480469), -- waiting for Diamond
        [2] = CFrame.new(-2148.7568359375, 73.27831268310547, -4304.4130859375),     -- waiting for Orbitus
    }
    local HUMAN_V3_BOSS_NAME = {[0] = "Jeremy", [1] = "Diamond", [2] = "Orbitus"}

    local function _fightWorldBossV3(bossName, waitCF)
        local live = ScriptStorage.Enemies[bossName]
        if not live then
            SetTask("SubTask", "Race Awakening | Waiting for " .. bossName .. " - moving to the meeting point")
            if waitCF then TweenController.Create(waitCF) end
            return false
        end
        local hum = live:FindFirstChildOfClass("Humanoid")
        local hrp = live:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            SetTask("MainTask", "Race Awakening | Fighting " .. bossName)
            TweenController.Create(hrp.CFrame + Vector3.new(0, 30, 0))
            if not LocalPlayer.Character:FindFirstChild("HasBuso") then
                pcall(function() Remotes.CommF_:InvokeServer("Buso") end)
            end
            CombatController.Attack(bossName)
            return false
        end
        return true -- dead
    end

    FunctionsHandler.RaceAwakening:RegisterMethod("Refresh", function()
        if not Config.Items.AutoRaceV3 then return nil end
        local data = LocalPlayer:FindFirstChild("Data")
        if not data or not data:FindFirstChild("Race") then return nil end
        if data.Race:FindFirstChild("Evolved") then return nil end -- already awakened
        local raceVal = data.Race.Value
        if raceVal ~= "Human" and raceVal ~= "Fishman" and raceVal ~= "Rabbit" then return nil end
        if (ScriptStorage.PlayerData.Level or 0) < 1400 then return nil end
        if (ScriptStorage.PlayerData.Beli or 0) < 2000000 then return nil end
        local wOk = pcall(function() return Remotes.CommF_:InvokeServer("Wenlocktoad", "3") end)
        local wResult = wOk and Remotes.CommF_:InvokeServer("Wenlocktoad", "3") or nil
        if wResult == -2 then return nil end
        local tOk, tResult = pcall(function() return Remotes.CommF_:InvokeServer("TalkTrevor", "1") end)
        if not tOk or tResult ~= 0 then return nil end
        return true
    end)

    FunctionsHandler.RaceAwakening:RegisterMethod("Start", function()
        local data = LocalPlayer:FindFirstChild("Data")
        if not data or not data:FindFirstChild("Race") then return end
        local race = data.Race.Value

        -- [FIXED] Use Wenlocktoad("1") as the real state driver, re-read every time
        local check = Remotes.CommF_:InvokeServer("Wenlocktoad", "1")

        if check == 0 then
            SetTask("MainTask", "Race Awakening | Starting quest (Wenlocktoad)")
            Remotes.CommF_:InvokeServer("Wenlocktoad", "2")
            return
        elseif check == 2 then
            SetTask("MainTask", "Race Awakening | Requirements met - claiming!")
            Remotes.CommF_:InvokeServer("Wenlocktoad", "3")
            return
        elseif check ~= 1 then
            return -- unexpected value, wait for the next round
        end

        -- check == 1: currently fighting bosses / farming by race
        if race == "Human" then
            local stage = _raceAwakenState.humanStage
            if stage >= 3 then
                SetTask("MainTask", "Race Awakening | Defeated 3 bosses - claiming!")
                Remotes.CommF_:InvokeServer("Wenlocktoad", "3")
                _raceAwakenState.humanStage = 0
                return
            end
            local bossName = HUMAN_V3_BOSS_NAME[stage]
            SetTask("SubTask", "Race Awakening | " .. (stage + 1) .. "/3 " .. bossName)
            if _fightWorldBossV3(bossName, HUMAN_V3_WAIT_CF[stage]) then
                _raceAwakenState.humanStage = stage + 1
            end

        elseif race == "Rabbit" then
            -- [NEW - Mink] Farm 30 ChestModels then claim
            local chestFolder = workspace:FindFirstChild("ChestModels")
            if not chestFolder then
                SetTask("SubTask", "Race Awakening | Mink: ChestModels not found")
                return
            end
            if _raceAwakenState.minkChestsDone >= 30 then
                SetTask("MainTask", "Race Awakening | Mink: 30 chests collected - claiming!")
                Remotes.CommF_:InvokeServer("Wenlocktoad", "3")
                return
            end
            local chests = chestFolder:GetChildren()
            local idx = _raceAwakenState.minkChestsDone + 1
            local chest = chests[idx]
            if chest and chest:FindFirstChild("WorldPivot") then
                SetTask("MainTask", "Race Awakening | Mink: chest " .. idx .. "/30")
                TweenController.Create(chest.WorldPivot.Position)
                if CaculateDistance(chest.WorldPivot.Position) < 10 then
                    _raceAwakenState.minkChestsDone = _raceAwakenState.minkChestsDone + 1
                end
            else
                SetTask("SubTask", "Race Awakening | Mink: no more chests available (" .. #chests .. " total)")
            end

        elseif race == "Fishman" then
            -- (Fishman race unchanged)
            SetTask("MainTask", "Race Awakening | Fishman: farm Sea Beast")
            local seaBeasts = Services.Workspace:FindFirstChild("SeaBeasts")
            if not seaBeasts then
                SetTask("SubTask", "⚠️ workspace.SeaBeasts not found - trying to hop")
                Hop()
                return
            end
            pcall(function() Remotes.CommF_:InvokeServer("BuyFishmanKarate") end)
            local target = nil
            for _, beast in pairs(seaBeasts:GetChildren()) do
                local h = beast:FindFirstChild("Health")
                local hrp = beast:FindFirstChild("HumanoidRootPart")
                if h and hrp and h.Value > 0 then target = beast break end
            end
            if not target then
                SetTask("SubTask", "Fishman | No Sea Beast yet, waiting for spawn...")
                task.wait(3)
                return
            end
            TweenController.Create(target.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0))
            if CaculateDistance(target.HumanoidRootPart.CFrame) < 15 then
                pcall(function()
                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Fishman Karate")
                end)
                SetTask("SubTask", "Fishman | Fighting Sea Beast (skills Z/X/C)")
                pcall(function()
                    Services.VirtualInputManager:SendKeyEvent(true, "Z", false, game)
                    task.wait(0.3)
                    Services.VirtualInputManager:SendKeyEvent(false, "Z", false, game)
                end)
            end
        end
    end)

    -- ============================================================
    -- BOSSES TASK
    -- [FIXED] Confirm the boss is REALLY dead: during phase changes Parent/Humanoid disappear briefly (e.g. Cake Prince phase 2).
    -- Now waits for continuous confirmation and cancels the reset if the boss comes back alive.
    -- ============================================================
    local function ConfirmBossDead(bossName)
        -- [FIXED] Confirmation shortened to 6 polls x 0.3s (1.8s) - more polls, shorter total time, keeps false-positive protection.
        for _ = 1, 6 do
            task.wait(0.3)
            local stillThere = ScriptStorage.Enemies[bossName]
            if stillThere and stillThere:FindFirstChild("Humanoid") and stillThere.Humanoid.Health > 0 then
                return false -- came back alive (phase change) - NOT a real death
            end
        end
        return true -- not seen alive for 1.8s straight - definitely dead
    end

    FunctionsHandler.BossesTask:RegisterMethod("Refresh", function()
        local k
        for h, h in BossesOrder do
            -- [FIXED] Added Config.BossWeapons gate: set Config.BossWeapons[name] = false to skip a boss.
            if Config.BossWeapons[h] ~= false then
                local X = BossesOrderLevel[h]
                if ScriptStorage.PlayerData.Level >= X then
                    local X = ScriptStorage.Enemies[h]
                    if X and X:FindFirstChild("Humanoid") and X.Humanoid.Health > 0 then k = X end
                end
            end
        end
        if k and (CaculateDistance(k.HumanoidRootPart.CFrame) < (SeaIndex == 2 and 3000 or 5000) or BossesOrderWL[tostring(k)] or ScriptStorage.PlayerData.Level == MaxLevel) then
            return k
        end
    end)

    FunctionsHandler.BossesTask:RegisterMethod('Start', function(k)
        if k then
            SetTask("MainTask", "Auto Farm Boss - Defeating " .. k.Name)
            SetTask('SubTask', '👑 Boss: ' .. k.Name .. ' | HP: ' .. math.floor(k.Humanoid.Health / k.Humanoid.MaxHealth * 100) .. '%')
            CombatController.Attack(tostring(k), null, null, function() SpecialItems = nil end)
            SpecialItems = nil

            -- [ADDED] After a boss dies, reset the character (respawn) so LevelFarm resumes cleanly.
            pcall(function()
                if k.Parent == nil or (k:FindFirstChild("Humanoid") and k.Humanoid.Health <= 0) then
                    -- [FIXED] Confirm real death before resetting (avoid false positives on phase change)
                    if ConfirmBossDead(k.Name) then
                        SetTask('SubTask', '✅ Defeated ' .. k.Name .. ' - resetting back to level farm')
                        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum.Health = 0
                            LocalPlayer.CharacterAdded:Wait()
                        end
                    else
                        SetTask('SubTask', k.Name .. ' is changing phase - keep fighting')
                    end
                end
            end)
        end
    end)

    -- ============================================================
    -- SPECIAL BOSSES TASK
    -- ============================================================
    FunctionsHandler.SpecialBossesTask:RegisterMethod('Refresh', function()
        local k
        for h, X in SpecialBossesOrder do
            -- [FIXED] Same Config.BossWeapons gate as BossesTask
            if Config.BossWeapons[h] ~= false and ScriptStorage.PlayerData.Level >= X then
                local X = ScriptStorage.Enemies[h]
                if X and X:FindFirstChild('Humanoid') and X.Humanoid.Health > 0 then k = X end
            end
        end
        -- [ADDED] No boss up -> light Bones farming in the background (does not return true, LevelFarm still runs).
        if not k then
            pcall(function()
                local bonesCheck = Remotes.CommF_:InvokeServer("Bones", "Check")
                if bonesCheck and bonesCheck > 0 then
                    Remotes.CommF_:InvokeServer("Bones", "Buy", 1, 1)
                end
            end)
        end
        return k
    end)

    FunctionsHandler.SpecialBossesTask:RegisterMethod('Start', function(k)
        if FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call() then
            pcall(function() LocalPlayer.Character.Humanoid.Health = 0 end)
        end
        if k then
            SetTask('MainTask', "Auto Farm Boss - Defeating " .. k.Name)
            SetTask('SubTask', '👾 Special Boss: ' .. k.Name)
            CombatController.Attack(tostring(k))

            -- [ADDED] Same reset logic as BossesTask for Katakuri/Core/Darkbeard
            pcall(function()
                if k.Parent == nil or (k:FindFirstChild("Humanoid") and k.Humanoid.Health <= 0) then
                    -- [FIXED] Confirm real death before resetting (avoid false positives on phase change)
                    if ConfirmBossDead(k.Name) then
                        SetTask('SubTask', '✅ Defeated ' .. k.Name .. ' - resetting back to level farm')
                        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum.Health = 0
                            LocalPlayer.CharacterAdded:Wait()
                        end
                    else
                        SetTask('SubTask', k.Name .. ' is changing phase - keep fighting')
                    end
                end
            end)
        end
    end)

    -- ============================================================
    -- RAID CONTROLLER
    -- [NEW] getInventoryFruits reads ItemConfig/FruitInfo directly (no remote round-trip), includes Rarity.
    -- ============================================================
    local function getInventoryFruits()
        local fruits = {}
        local inventory = require(ReplicatedStorage.ItemConfig):GetItems(ReplicatedStorage.ItemConfig.KEYS.QUANTITY)
        for _, item in pairs(inventory) do
            if item.Value and item.Value > 0 then
                local _, data = pcall(function()
                    return ReplicatedStorage.FruitInfo.List[item.ItemId]
                end)
                if data then
                    local name = data.Display.Name or item.ItemId
                    local rarity = data.Rarity and data.Rarity.Name or "Unknown"
                    local value = data.Price or 0
                    table.insert(fruits, {Name = name, Rarity = rarity, Value = value})
                end
            end
        end
        return fruits
    end

    -- [NEW] Pick the fruit to sell/use for chips: prefer Common/Uncommon + cheapest; otherwise the cheapest in inventory.
    local function PickFruitToSpend()
        local ok, fruits = pcall(getInventoryFruits)
        if not ok or not fruits or #fruits == 0 then return nil end

        local commonUncommon = {}
        for _, f in ipairs(fruits) do
            if f.Rarity == "Common" or f.Rarity == "Uncommon" then
                table.insert(commonUncommon, f)
            end
        end

        local pool = #commonUncommon > 0 and commonUncommon or fruits
        table.sort(pool, function(a, b) return (a.Value or 0) < (b.Value or 0) end)
        return pool[1]
    end

    -- ============================================================
    -- ============================================================
    -- [NEW] SWORD BOSS TASK - farm bosses for swords; skips swords already owned (inventory check).
    -- ============================================================
    local SwordBossList = {
        {sword = "Shark Saw",       boss = "The Saw",              sea = 1, level = 100},
        {sword = "Wardens Sword",   boss = "Chief Warden",         sea = 1, level = 100},
        {sword = "Pole (1st Form)", boss = "Thunder God",          sea = 1, level = 100},
        {sword = "Gravity Blade",   boss = "Orbitus",               sea = 2, level = 800},
        {sword = "Longsword",       boss = "Diamond",               sea = 2, level = 800},
        {sword = "Rengoku",         boss = "Awakened Ice Admiral",  sea = 2, level = 800},
        {sword = "Flail",           boss = "Smoke Admiral",         sea = 2, level = 0},
        {sword = "Twin Hooks",      boss = "Captain Elephant",      sea = 3, level = 0},
    }
    -- Hidden Key / Library Key positions used to unlock Rengoku (verified)
    local HIDDEN_KEY_CF  = CFrame.new(6572.29248, 295.712677, -6966.09961)
    local LIBRARY_KEY_CF = CFrame.new(6377.12549, 296.634735, -6843.76025)

    FunctionsHandler.SwordBossTask:RegisterMethod("Refresh", function()
        for _, sw in ipairs(SwordBossList) do
            -- [NEW] Check inventory continuously - skip if the sword is already owned
            if Config.Sword[sw.sword] and not CheckItem(sw.sword)
                and SeaIndex == sw.sea and (ScriptStorage.PlayerData.Level or 0) >= sw.level then
                local boss = ScriptStorage.Enemies[sw.boss]
                if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                    return sw
                end
            end
        end
        -- Rengoku only: extra paths via Hidden Key / Library Key (boss need not be alive, just holding the key in Sea 2)
        if Config.Sword["Rengoku"] and not CheckItem("Rengoku") and SeaIndex == 2 then
            if CheckItem("Hidden Key") or CheckItem("Library Key") then
                return {sword = "Rengoku", useKey = true}
            end
        end
        return nil
    end)

    FunctionsHandler.SwordBossTask:RegisterMethod("Start", function(sw)
        if not sw then return end

        if sw.useKey then
            local keyName = CheckItem("Hidden Key") and "Hidden Key" or "Library Key"
            local cf = keyName == "Hidden Key" and HIDDEN_KEY_CF or LIBRARY_KEY_CF
            SetTask("MainTask", "Sword Boss | Using " .. keyName .. " to open Rengoku")
            TweenController.Create(cf)
            if CaculateDistance(cf) <= 5 then
                FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(keyName)
            end
            return
        end

        local boss = ScriptStorage.Enemies[sw.boss]
        if not boss then return end

        SetTask("MainTask", "Sword Boss | Fighting " .. sw.boss .. " for " .. sw.sword)
        if boss:FindFirstChild("HumanoidRootPart") then
            TweenController.Create(boss.HumanoidRootPart.CFrame + Vector3.new(0, 30, 0))
        end
        CombatController.Attack(sw.boss)

        -- [ADDED] After the kill, reset to level farming like the other bosses
        pcall(function()
            if boss.Parent == nil or (boss:FindFirstChild("Humanoid") and boss.Humanoid.Health <= 0) then
                if ConfirmBossDead(sw.boss) then
                    SetTask('SubTask', '✅ Defeated ' .. sw.boss .. ' - resetting back to level farm')
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.Health = 0
                        LocalPlayer.CharacterAdded:Wait()
                    end
                else
                    SetTask('SubTask', sw.boss .. ' is changing phase - keep fighting')
                end
            end
        end)
    end)


    -- Cake Prince [Lv. 2300] [Raid Boss] (Sea 3, Cake Loaf island)
    -- [FIXED] Now ONLY used to farm MASTERY for the melee in training (V1 needs 500, V2 needs 400); no longer gated by Fragments.
    -- ============================================================
    local CAKE_AREA_CF   = CFrame.new(-2077, 252, -12373)        -- Cake Loaf island (general)
    local CAKE_BOSS_CF   = CFrame.new(-2151.82, 149.32, -12404.91) -- where Cake Prince spawns
    local CAKE_UNLOCK_MOBS = {"Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker"}

    -- [NEW] Work out which melee needs mastery training - shared by CakePrinceTask and MeleesController (V1 -> V2 order).
    local MASTERY_TRAIN_ORDER = {
        {name = "Black Leg",       target = 500, tier = "V1"},
        {name = "Electro",         target = 500, tier = "V1"},
        {name = "Fishman Karate",  target = 500, tier = "V1"},
        {name = "Dragon Claw",     target = 500, tier = "V1"},
        {name = "Superhuman",      target = 500, tier = "V1"},
        {name = "Death Step",      target = 400, tier = "V2"},
        {name = "Sharkman Karate", target = 400, tier = "V2"},
        {name = "Electric Claw",   target = 400, tier = "V2"},
        {name = "Dragon Talon",    target = 400, tier = "V2"},
    }

    function GetCurrentTrainingMelee()
        for _, m in ipairs(MASTERY_TRAIN_ORDER) do
            if OwnsMelee(m.name) then
                local mastery = ScriptStorage.Melees[m.name] or 0
                if mastery < m.target then
                    return m.name, mastery, m.target
                end
            end
        end
        return nil
    end

    FunctionsHandler.CakePrinceTask:RegisterMethod("Refresh", function()
        if SeaIndex ~= 3 then return nil end
        if (ScriptStorage.PlayerData.Level or 0) < 1500 then return nil end
        -- [FIXED] Gated by 'is any melee in need of mastery training', no longer by Fragments
        local trainingName = GetCurrentTrainingMelee()
        if not trainingName then return nil end
        return trainingName
    end)

    FunctionsHandler.CakePrinceTask:RegisterMethod("Start", function(trainingName)
        if not trainingName then return end
        local mastery, target = ScriptStorage.Melees[trainingName] or 0, nil
        for _, m in ipairs(MASTERY_TRAIN_ORDER) do
            if m.name == trainingName then target = m.target break end
        end

        -- [NEW] Check mastery every round - stop at the threshold and let Refresh() move to the next melee
        if mastery >= (target or 500) then
            SetTask("SubTask", "✅ " .. trainingName .. " reached " .. mastery .. " mastery - switching to next melee")
            return
        end

        -- [NEW] Equip the melee being trained so damage counts for the right weapon
        pcall(function()
            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(trainingName)
        end)

        local cakeLoaf  = workspace.Map:FindFirstChild("CakeLoaf")
        local bigMirror = cakeLoaf and cakeLoaf:FindFirstChild("BigMirror")
        local enemies   = workspace.Enemies

        -- Not on Cake island yet -> teleport there first
        if not cakeLoaf then
            SetTask("MainTask", "Cake Mastery | " .. trainingName .. " (" .. mastery .. "/" .. (target or 500) .. ") - moving to Cake island")
            TweenController.Create(CAKE_AREA_CF)
            return
        end

        local mirrorOpen = bigMirror and bigMirror:FindFirstChild("Other") and bigMirror.Other.Transparency == 0
        local bossUp     = enemies:FindFirstChild("Cake Prince")

        if mirrorOpen or bossUp then
            -- Mirror open OR boss up -> fight (mastery rises faster)
            local boss = enemies:FindFirstChild("Cake Prince")
            if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                SetTask("MainTask", "Cake Mastery | " .. trainingName .. " (" .. mastery .. "/" .. (target or 500) .. ") | Cake Prince HP " .. math.floor(boss.Humanoid.Health / boss.Humanoid.MaxHealth * 100) .. "%")
                TweenController.Create(boss.HumanoidRootPart.CFrame + Vector3.new(0, 30, 0))
                CombatController.Attack("Cake Prince")

                -- [ADDED] After the kill, reset to normal farming like BossesTask/SpecialBossesTask
                pcall(function()
                    if boss.Parent == nil or boss.Humanoid.Health <= 0 then
                        -- [FIXED] Exact case reported: Cake Prince phase 2 was mistaken for death
                        if ConfirmBossDead("Cake Prince") then
                            SetTask('SubTask', '✅ Defeated Cake Prince - resetting back to level farm')
                            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if hum then
                                hum.Health = 0
                                LocalPlayer.CharacterAdded:Wait()
                            end
                        else
                            SetTask('SubTask', 'Cake Prince is changing phase - keep fighting')
                        end
                    end
                end)
            else
                TweenController.Create(CAKE_BOSS_CF)
            end
            return
        end

        -- Mirror not open, boss not up -> farm normal mobs for mastery and check unlock progress (summons Cake Prince when enough)
        -- [FIX8] No SetTask here: it alternated with the "farming unlock mobs" text every round (flicker).
        -- The kill count is cached for 5s to avoid spamming the remote every loop.
        local now = os.clock()
        if not getgenv().CakeKilledCache or now - (getgenv().CakeKilledAt or 0) > 5 then
            local okK, killedStr = pcall(function() return Remotes.CommF_:InvokeServer("CakePrinceSpawner") end)
            getgenv().CakeKilledCache = okK and killedStr and tonumber(tostring(killedStr):match("%d+")) or 0
            getgenv().CakeKilledAt = now
        end
        local killed = getgenv().CakeKilledCache
        local remaining = math.max(0, 500 - killed)

        if remaining <= 0 then
            -- [FIX7] Summon, then actually wait for the boss. If it never shows up after a few tries,
            -- stop idling and farm normal Cake mobs for mastery instead.
            getgenv().CakeSummonTries = (getgenv().CakeSummonTries or 0)
            if getgenv().CakeSummonTries < 4 then
                SetTask("MainTask", "Cake Mastery | Requirements met - summoning Cake Prince (try " .. (getgenv().CakeSummonTries + 1) .. "/4)")
                if CaculateDistance(CAKE_BOSS_CF) > 150 then
                    TweenController.Create(CAKE_BOSS_CF + Vector3.new(0, 40, 0))
                    return
                end
                getgenv().CakeSummonTries = getgenv().CakeSummonTries + 1
                pcall(function() Remotes.CommF_:InvokeServer("CakePrinceSpawner", true) end)
                local t0 = os.clock()
                repeat task.wait(0.5) until enemies:FindFirstChild("Cake Prince") or os.clock() - t0 > 8
                if enemies:FindFirstChild("Cake Prince") then getgenv().CakeSummonTries = 0 end
                return
            end
            SetTask("MainTask", "Cake Mastery | " .. trainingName .. " (" .. mastery .. "/" .. (target or 500) .. ") - boss did not spawn, farming mobs")
            local fm = nil
            for _, mobName in ipairs(CAKE_UNLOCK_MOBS) do
                local m = enemies:FindFirstChild(mobName)
                if m and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 then fm = m break end
            end
            if fm then
                TweenController.Create(fm.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0))
                CombatController.Attack(CAKE_UNLOCK_MOBS)
            else
                TweenController.Create(CAKE_AREA_CF)
            end
            -- retry the summon every ~60s
            getgenv().CakeLastRetry = getgenv().CakeLastRetry or os.clock()
            if os.clock() - getgenv().CakeLastRetry > 60 then
                getgenv().CakeSummonTries = 0
                getgenv().CakeLastRetry = os.clock()
            end
            return
        end

        -- Not enough yet -> farm unlock mobs
        SetTask("MainTask", "Cake Mastery | " .. trainingName .. " (" .. mastery .. "/" .. (target or 500) .. ") - farming mobs, summon in " .. remaining)
        local mob = nil
        for _, mobName in ipairs(CAKE_UNLOCK_MOBS) do
            local m = enemies:FindFirstChild(mobName)
            if m and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 then mob = m break end
        end
        if mob then
            TweenController.Create(mob.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0))
            CombatController.Attack(CAKE_UNLOCK_MOBS)
        else
            TweenController.Create(CAKE_AREA_CF)
        end
    end)


    FunctionsHandler.RaidController:RegisterMethod("RefreshRaidType", function()
        for k, k in require(game.ReplicatedStorage.Raids).raids do
            if string.find(ScriptStorage.PlayerData.DevilFruit, k) then
                FunctionsHandler.RaidController:Set('CurrentChip', k)
                return
            end
        end
        FunctionsHandler.RaidController:Set('CurrentChip', 'Flame')
    end)

    FunctionsHandler.RaidController:RegisterMethod('GetRaidableFruit', function()
        -- [FIXED] Now uses PickFruitToSpend(): prefers Common/Uncommon + cheapest, falling back to the cheapest overall
        -- (it used to grab the first fruit under 1M Beli).
        local picked = PickFruitToSpend()
        if picked then
            for k, k in ScriptStorage.Backpack do
                if k.Name == picked.Name then return k end
            end
        end
        -- Fall back to old logic if getInventoryFruits() fails
        for k, k in ScriptStorage.Backpack do
            if string.find(FruitIdToName(k.Name), " Fruit") then
                if k.Value and k.Value < 1000000 then return k end
            end
        end
    end)

    FunctionsHandler.RaidController:RegisterMethod("GetCurrentRaidIsland", function()
        -- [FIXED] raid finished: the RaidTimer was visible and is gone now -> stop treating the island as active.
        -- Without this the script kept 'Clearing wave' on Island 5 after the raid was already completed.
        local okT, timerVisible = pcall(function()
            local gui  = LocalPlayer:FindFirstChild("PlayerGui")
            local main = gui and gui:FindFirstChild("Main")
            local top  = main and main:FindFirstChild("TopHUDList")
            local timer = top and top:FindFirstChild("RaidTimer")
            return timer and timer.Visible or false
        end)
        if okT then
            if timerVisible then
                FlowbrRaidSeen = true
            elseif FlowbrRaidSeen then
                FlowbrRaidSeen = false
                FlowbrRaidDoneAt = os.time()
                print("[Raid] completed - going back to normal farm")
            end
        end
        if FlowbrRaidDoneAt and os.time() - FlowbrRaidDoneAt < 300 then return nil end

        local IslandsList = {{}, {}, {}, {}, {}}
        for k, k in workspace['_WorldOrigin'].Locations:GetChildren() do
            if string.find(k.Name, 'Island ') and CaculateDistance(k.Position, Vector3.new(0, 0, 0)) > 7000 then
                local h = string.gsub(k.Name, "Island ", "")
                local X = tonumber(h)
                table.insert(IslandsList[X], k)
            end
        end
        for k = 5, 1, -1 do
            for h, h in IslandsList[k] do if CaculateDistance(h.Position) < 2000 then return h end end
        end
        return nil
    end)

    function CheckSpecialMicrochip()
        local bp = LocalPlayer:FindFirstChild("Backpack")
        for _, h in {LocalPlayer.Character:GetChildren(), bp and bp:GetChildren() or {}} do
            for _, X in h do if X.Name == "Special Microchip" then return X end end
        end
        return nil
    end

    FunctionsHandler.RaidController:RegisterMethod("Refresh", function()
        local lv = ScriptStorage.PlayerData.Level or 0
        if lv < 1300 then return nil end
        if CheckSpecialMicrochip() then return nil end
        local fr = ScriptStorage.PlayerData.Fragments or 0
        if lv < 1500 and fr > 2000 then return nil end
        if lv < MaxLevel and fr > 5000 then return nil end
        if lv >= MaxLevel and fr > 10000 then return nil end
        local fruit = FunctionsHandler.RaidController.Methods.GetRaidableFruit:Call()
        if fruit then FunctionsHandler.RaidController:Set("CurrentProgressLevel", fruit) end
        return fruit or FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call() or CheckSpecialMicrochip()
    end)

    FunctionsHandler.RaidController:RegisterMethod("Start", function()
        if not FunctionsHandler.RaidController:Get('CurrentChip') then FunctionsHandler.RaidController.Methods.RefreshRaidType:Call() end
        local k = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
        RefreshInventory()
        FunctionsHandler.RaidController:Set("CurrentProgressLevel", nil)
        if not k then
            SetTask('MainTask', 'Auto Raid - Buying Chip - ' .. FunctionsHandler.RaidController:Get("CurrentChip"))
            if not ScriptStorage.Tools['Special Microchip'] then
                local h = FunctionsHandler.RaidController.Methods.GetRaidableFruit:Call()
                table.insert(ScriptStorage.IgnoreStoreFruits, h.Name)
                alert('Load Fruit', h.Name)
                Remotes.CommF_:InvokeServer('LoadFruit', h.Name)
                Remotes.CommF_:InvokeServer("RaidsNpc", 'Select', FunctionsHandler.RaidController:Get('CurrentChip'))
                task.wait(2)
            end
            local h = ({nil, 'Circle Island', "Boat Castle"})[SeaIndex]
            if not ScriptStorage.Map[h] and not ScriptStorage.Map[h] then
                task.wait(1)
                SafeRejoin()
            end
            if not ScriptStorage.Map[h]:FindFirstChild('RaidSummon2') then
                task.wait(1)
                TweenController.Create(ScriptStorage.Map[h]:GetModelCFrame() or ScriptStorage.Map[h]:GetModelCFrame())
            end
            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call('Special Microchip')
            fireclickdetector((ScriptStorage.Map[h] or workspace.Map:FindFirstChild(h) or workspace:FindFirstChild(h)).RaidSummon2.Button.Main.ClickDetector)
            local h = os.time()
            SetTask("MainTask", "Auto Raid - Waiting Until Raid Is Started")
            repeat task.wait() until os.time() - (LastRaidAlert2 or 0) < 20 or os.time() - h > 30
            TweenController.Create(LocalPlayer.Character.HumanoidRootPart.CFrame)
            repeat task.wait() until os.time() - (LastRaidAlert or 0) < 20 or os.time() - h > 30
            alert('info', "Tween Paused")
            task.wait(.5)
            if os.time() - h > 30 then
                SafeRejoin()
                SetTask('MainTask', "Auto Raid - Raid Is Not Stared?")
                Report('[ Raid Error ] Time Limit Reached')
            end
            LastRaidAlert = 0
        else
            SetTask('MainTask', "Auto Raid - " .. k.Name .. " /5")
            SetTask('SubTask', 'Raid Island ' .. k.Name .. ' | Clearing wave...')
            local islandNum = tonumber(string.match(k.Name, "(%d+)"))
            if islandNum and islandNum >= 4 then
                TweenController.Create(k.Position + Vector3.new(0, 50, 0))
                task.wait(0.5)
                for _, v in workspace.Enemies:GetChildren() do
                    pcall(function()
                        if v:FindFirstChild("Humanoid") then v.Humanoid.Health = 0 end
                        if v:FindFirstChild("HumanoidRootPart") then v.HumanoidRootPart.CanCollide = false end
                        v:BreakJoints()
                    end)
                end
            else
                local h = false
                for X, X in GetMonAsSortedRange() do
                    local w = os.time()
                    while X and X:FindFirstChild("HumanoidRootPart") and X.Humanoid.Health > 0 and CaculateDistance(X.HumanoidRootPart.Position) < 1000 and os.time() - w < 60 and task.wait(.05) do
                        h = true
                        if string.find(X.Name, "Master") or true then
                            CombatController.Attack(X.Name)
                        else
                            pcall(sethiddenproperty, LocalPlayer, 'SimulationRadius', math.huge)
                            pcall(function()
                                X.HumanoidRootPart.CanCollide = false
                                X.Humanoid.Health = 0
                                X:BreakJoints()
                            end)
                        end
                    end
                end
                if not h then TweenController.Create(k.Position + Vector3.new(0, 100, 0)) end
            end
        end
    end)

    -- ============================================================
    -- AUTO RAID ICE
    -- ============================================================
    local RAID_ICE_CHIP_COOLDOWN = 2 * 60 * 60

    -- [NEW] 2 helpers from Moonlight_New_Public_source.lua (logic only) to make AutoRaidIce more reliable:
    -- 1. TriggerInteractive: presses the raid summon button via ProximityPrompt AND ClickDetector (recursive search).
    -- 2. RaidTimerActive: checks PlayerGui.Main.TopHUDList.RaidTimer.Visible to know instantly if the raid started
    --    (notifications are kept as a backup).
    local function TriggerInteractive(object)
        if not object then return false end
        local prompt = object:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and typeof(fireproximityprompt) == "function" then
            local ok = pcall(fireproximityprompt, prompt)
            if ok then return true end
        end
        local click = object:FindFirstChildWhichIsA("ClickDetector", true)
        if click and typeof(fireclickdetector) == "function" then
            local ok = pcall(fireclickdetector, click)
            if ok then return true end
        end
        return false
    end

    local function RaidTimerActive()
        local ok, result = pcall(function()
            local gui  = LocalPlayer:FindFirstChild("PlayerGui")
            local main = gui and gui:FindFirstChild("Main")
            local top  = main and main:FindFirstChild("TopHUDList")
            local timer = top and top:FindFirstChild("RaidTimer")
            return timer and timer.Visible or false
        end)
        return ok and result or false
    end


    FunctionsHandler.AutoRaidIce:RegisterMethod("GetCheapestFruit", function(maxPrice)
        maxPrice = maxPrice or 1000000
        local ok1, fruitPrices = pcall(function() return Remotes.CommF_:InvokeServer("GetFruits") end)
        local ok2, inventoryFruits = pcall(function() return Remotes.CommF_:InvokeServer("getInventoryFruits") end)
        -- [FIXED] server can return nil here; checking types stops the 'pairs' error
        if not ok1 or not ok2 or type(fruitPrices) ~= "table" or type(inventoryFruits) ~= "table" then return nil end
        local priceMap = {}
        for _, v in pairs(fruitPrices) do
            if v.Price and v.Price <= maxPrice then
                priceMap[v.Name] = v.Price
            end
        end
        local cheapest, lowestPrice = nil, math.huge
        for _, fruitData in pairs(inventoryFruits) do
            local name = fruitData.Name
            if name and priceMap[name] and priceMap[name] < lowestPrice then
                lowestPrice = priceMap[name]
                cheapest = name
            end
        end
        return cheapest, lowestPrice
    end)

    FunctionsHandler.AutoRaidIce:RegisterMethod("KillAura", function()
        local currentIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
        pcall(sethiddenproperty, LocalPlayer, 'SimulationRadius', math.huge)
        for _, v in pairs(workspace.Enemies:GetChildren()) do
            pcall(function()
                if currentIsland then
                    local dist = CaculateDistance(v.HumanoidRootPart.Position, currentIsland.Position)
                    if dist > 1500 then return end
                end
                if v:FindFirstChild("Humanoid") then v.Humanoid.Health = 0 end
                if v:FindFirstChild("HumanoidRootPart") then v.HumanoidRootPart.CanCollide = false end
                v:BreakJoints()
            end)
        end
    end)

    FunctionsHandler.AutoRaidIce:RegisterMethod("BuyChip", function()
        local lastBuy = Storage:Get("RaidIceLastChipBuy") or 0
        if os.time() - lastBuy < RAID_ICE_CHIP_COOLDOWN then return false end
        local fruitName = FunctionsHandler.AutoRaidIce.Methods.GetCheapestFruit:Call(1000000)
        if fruitName then
            SetTask('MainTask', 'Auto Raid Ice | Buying chip with fruit ' .. fruitName)
            table.insert(ScriptStorage.IgnoreStoreFruits, fruitName)
            Remotes.CommF_:InvokeServer('LoadFruit', fruitName)
            task.wait(0.5)
            Remotes.CommF_:InvokeServer("RaidsNpc", "Select", "Ice")
            task.wait(1)
            RefreshInventory()
            if CheckSpecialMicrochip() then
                Storage:Set("RaidIceLastChipBuy", os.time())
                Storage:Save()
                return true
            else
                for i = 1, 2 do
                    task.wait(2)
                    Remotes.CommF_:InvokeServer("RaidsNpc", "Select", "Ice")
                    task.wait(1)
                    RefreshInventory()
                    if CheckSpecialMicrochip() then
                        Storage:Set("RaidIceLastChipBuy", os.time())
                        Storage:Save()
                        return true
                    end
                end
                SetTask('MainTask', 'Auto Raid Ice | Chip purchase failed')
                return false
            end
        elseif (ScriptStorage.PlayerData.Beli or 0) >= 100000 then
            SetTask('MainTask', 'Auto Raid Ice | Buying chip with Beli')
            Remotes.CommF_:InvokeServer("RaidsNpc", "Select", "Ice")
            task.wait(1)
            RefreshInventory()
            if CheckSpecialMicrochip() then
                Storage:Set("RaidIceLastChipBuy", os.time())
                Storage:Save()
                return true
            end
            return false
        end
        SetTask('MainTask', 'Auto Raid Ice | Not enough resources to buy the chip')
        return false
    end)

    FunctionsHandler.AutoRaidIce:RegisterMethod("Refresh", function()
        local lv = ScriptStorage.PlayerData.Level or 0
        local fr = ScriptStorage.PlayerData.Fragments or 0
        local target = Config.AutoRaidIce_TargetFragments or 5000
        if lv < 1300 then return nil end
        if fr >= target then
            SetTask('MainTask', 'Raid Ice | Target reached: ' .. fr .. '/' .. target)
            return nil
        end
        local hasChip = CheckSpecialMicrochip() ~= nil
        local onRaid = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
        if onRaid then return true end
        if hasChip then return true end
        local lastBuy = Storage:Get("RaidIceLastChipBuy") or 0
        if os.time() - lastBuy >= RAID_ICE_CHIP_COOLDOWN then return true end
        return nil
    end)

    FunctionsHandler.AutoRaidIce:RegisterMethod("Start", function()
        local currentIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
        local target = Config.AutoRaidIce_TargetFragments or 5000
        local fr = ScriptStorage.PlayerData.Fragments or 0
        if fr >= target then
            SetTask('MainTask', 'Raid Ice | Fragment target reached')
            return
        end
        if currentIsland then
            local islandNum = tonumber(string.match(currentIsland.Name, "(%d+)"))
            SetTask('MainTask', 'Raid Ice | Fragments: ' .. fr .. '/' .. target .. ' | Island ' .. (islandNum or "?") .. '/5')
            SetTask('SubTask', 'Raid Ice | Clearing island ' .. (islandNum or "?"))
            if islandNum and islandNum >= 3 then
                SetTask('MainTask', 'Raid Ice | Island ' .. islandNum .. ' | Kill Aura')
                FunctionsHandler.AutoRaidIce.Methods.KillAura:Call()
                TweenController.Create(currentIsland.Position + Vector3.new(0, 50, 0))
                task.wait(1)
            else
                local hasEnemy = false
                for _, v in GetMonAsSortedRange() do
                    if CaculateDistance(v.HumanoidRootPart.Position) < 1500 then
                        hasEnemy = true
                        CombatController.Attack(v.Name)
                        break
                    end
                end
                if not hasEnemy then
                    TweenController.Create(currentIsland.Position + Vector3.new(0, 100, 0))
                end
            end
            return
        end
        if not CheckSpecialMicrochip() then
            local bought = FunctionsHandler.AutoRaidIce.Methods.BuyChip:Call()
            if not bought then return end
            task.wait(2)
            RefreshInventory()
        end
        if not CheckSpecialMicrochip() then return end
        local mapName = ({nil, 'Circle Island', 'Boat Castle'})[SeaIndex]
        if not mapName then return end
        local mapObj = ScriptStorage.Map[mapName]
        if not mapObj then
            Report('[AutoRaidIce] Map not found: ' .. mapName)
            return
        end
        local summonCFrame
        if SeaIndex == 2 then summonCFrame = CFrame.new(-6438.73, 250.64, -4501.50)
        elseif SeaIndex == 3 then summonCFrame = CFrame.new(-5097.93, 316.44, -3142.66) end
        if summonCFrame then
            SetTask('MainTask', 'Raid Ice | Going to the summon button')
            TweenController.Create(summonCFrame)
            local t0 = tick()
            repeat task.wait(0.3) until CaculateDistance(summonCFrame) < 25 or tick()-t0 > 20
        end
        if not mapObj:FindFirstChild('RaidSummon2') then
            TweenController.Create(mapObj:GetModelCFrame())
            task.wait(1)
            return
        end
        FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call('Special Microchip')
        local btn = (mapObj or workspace.Map:FindFirstChild(mapName) or workspace:FindFirstChild(mapName))
        local summonObj = btn and btn:FindFirstChild("RaidSummon2")
        local clickSuccess = false
        for retry = 1, 3 do
            if retry > 1 then task.wait(3) end
            pcall(function()
                -- [FIXED] Use TriggerInteractive (handles both ProximityPrompt and ClickDetector)
                if summonObj and TriggerInteractive(summonObj) then
                    clickSuccess = true
                    SetTask('MainTask', 'Raid Ice | Clicked start (attempt ' .. retry .. ')')
                else
                    SetTask('MainTask', 'Raid Ice | Button not found (attempt ' .. retry .. ')')
                end
            end)
            if clickSuccess then break end
        end
        if not clickSuccess then
            SetTask('MainTask', 'Raid Ice | Could not click start')
            return
        end
        SetTask('MainTask', 'Raid Ice | Waiting for the raid to start...')
        local raidStarted = false
        for attempt = 1, 3 do
            if attempt > 1 then
                SetTask('MainTask', 'Raid Ice | Retry attempt ' .. attempt)
                pcall(function()
                    if summonObj then TriggerInteractive(summonObj) end
                end)
            end
            local h = os.time()
            repeat task.wait(0.5) until
                RaidTimerActive() or
                os.time() - (LastRaidAlert2 or 0) < 20 or
                os.time() - (LastRaidAlert or 0) < 20 or
                os.time() - h > 35
            if os.time() - h <= 35 then
                raidStarted = true
                break
            end
        end
        if raidStarted then
            LastRaidAlert = 0
            SetTask('MainTask', 'Raid Ice | Raid started!')
        else
            Report('[AutoRaidIce] Raid did not start')
            SetTask('MainTask', 'Raid Ice | Raid did not start, retrying later...')
        end
    end)

    -- ============================================================
    -- COLLECT DROPS
    -- ============================================================
    FunctionsHandler.CollectDrops:RegisterMethod("Refresh", function()
        local k = {}
        for h in ScriptStorage.Backpack do k[FruitIdToName(h)] = h end
        for h, h in workspace:GetChildren() do
            if string.find(h.Name, 'Fruit') and not a:FindFirstChild(h.Name) and h:FindFirstChild("Handle") and not k[tostring(h)] and not ScriptStorage.Backpack[FruitNameToId(tostring(h))] then
                FunctionsHandler.CollectDrops:Set('CurrentProgressLevel', h)
                return h
            end
        end
    end)

    FunctionsHandler.CollectDrops:RegisterMethod('Start', function()
        local k = FunctionsHandler.CollectDrops:Get('CurrentProgressLevel')
        FunctionsHandler.CollectDrops:Set('CurrentProgressLevel', nil)
        if k then
            SetTask('SubTask', '📦 Collecting: ' .. tostring(k))
            SetTask("MainTask", "Auto Collect Drop Items - " .. tostring(k))
            TweenController.Create(k:GetModelCFrame())
        end
    end)

    -- ============================================================
    -- UTILLY ITEMS ACTIVATION
    -- ============================================================
    FunctionsHandler.UtillyItemsActivitation:RegisterMethod('Refresh', function()
        if os.time() - timeee < 20 then return end
        if not SpecialItems then
            SpecialItems = {}
            local k = {}
            IceAdmiralPassed = true
            if not ScriptStorage.Backpack.Rengoku then
                table.insert(SpecialItems, "Hidden Key")
                IceAdmiralPassed = false
            end
            if SeaIndex == 2 and Services.Workspace.Map.IceCastle.Hall.LibraryDoor:FindFirstChild("PhoeyuDoor") then
                table.insert(SpecialItems, 'Library Key')
                IceAdmiralPassed = false
            end
            if IceAdmiralPassed then table.insert(k, 'Awakened Ice Admiral') end
            local h = not ScriptStorage.Melees['Sharkman Karate'] and Remotes.CommF_:InvokeServer("BuySharkmanKarate", true)
            SharkmanPassed = typeof(h) == 'string'
            if typeof(h) == "string" then
                table.insert(SpecialItems, 'Water Key')
            else
                TidePassed = true
                table.insert(k, 'Tide Keeper')
            end
            if ScriptStorage.Backpack.Yama then
                table.insert(k, "Deandre")
                table.insert(k, 'Urban')
                table.insert(k, 'Diablo')
            end
            local function h()
                local X = {}
                for w, w in BossesOrder do
                    local D = true
                    for y, y in k do if y == w then D = false end end
                    if D then table.insert(X, w) end
                end
                local k = #X
                for w = 1, k - 1 do
                    for D = 1, k - w do
                        local k = key and tostring(X[D][key]):lower() or tostring(X[D]):lower()
                        local w = key and tostring(X[D + 1][key]):lower() or tostring(X[D + 1]):lower()
                        if k > w then X[D], X[D + 1] = X[D + 1], X[D] end
                    end
                end
                return X
            end
            BossesOrder = h()
            for k, h in DropItemData do
                if not ScriptStorage.Backpack[k] and SeaIndex == h.Sea then
                    if ScriptStorage.PlayerData.Level >= h.Level then
                        BossesOrderLevel[h.Boss] = h.Level
                        table.insert(BossesOrder, h.Boss)
                    end
                end
            end
            if FunctionsHandler.Trevor:Get("IsCompleted") and not Storage:Get('SwanDefeated') then
                BossesOrderLevel["Don Swan"] = 1100
                table.insert(BossesOrder, 'Don Swan')
                if SeaIndex == 2 and ScriptStorage.PlayerData.Level > 1500 and not ScriptStorage.Enemies['Don Swan'] then
                    alert("Don Swan", 'Hopping for Don Swan')
                    Hop()
                end
            end
        end
        for k, k in SpecialItems do
            if ScriptStorage.Tools[k] then
                FunctionsHandler.UtillyItemsActivitation:Set('CurrentProgressLevel', k)
                return k
            end
        end
        if SeaIndex == 3 and (ScriptStorage.Melees["Death Step"] or 0) >= 400 and (ScriptStorage.Melees["Black Leg"] or 0) >= 400 and ScriptStorage.PlayerData.Beli >= 2500000 and ScriptStorage.PlayerData.Fragments >= 5000 and not ScriptStorage.Melees['Electric Claw'] then
            FunctionsHandler.UtillyItemsActivitation:Set('CurrentProgressLevel', "Previous Hero")
            return 'Previous Hero'
        end
        if ScriptStorage.Tools["Red Key"] then
            FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", "Red Key")
            return 'Red Key'
        end
        if ScriptStorage.Tools['Hallow Essence'] then
            FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", 'Soul Reaper Spawner')
            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Fire Essence")
            return "Soul Reaper Spawner"
        end
        if ScriptStorage.Tools['Fire Essence'] then
            FunctionsHandler.UtillyItemsActivitation:Set('CurrentProgressLevel', "Uzoth")
            return 'Uzoth'
        end
    end)

    FunctionsHandler.UtillyItemsActivitation:RegisterMethod('Start', function()
        local k = FunctionsHandler.UtillyItemsActivitation:Get("CurrentProgressLevel")
        if k == 'Hidden Key' then
            SetTask('SubTask', '🔑 Using Hidden Key for Rengoku')
            Remotes.CommF_:InvokeServer("OpenRengoku")
        elseif k == 'Water Key' then
            SetTask('SubTask', '🔑 Using Water Key for Sharkman Karate')
            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Water Key")
            Remotes.CommF_:InvokeServer("BuySharkmanKarate", true)
            Remotes.CommF_:InvokeServer("BuySharkmanKarate")
        elseif k == "Library Key" then
            SetTask('SubTask', '🔑 Using Library Key')
            Remotes.CommF_:InvokeServer("OpenLibrary")
            Services.Workspace.Map.IceCastle.Hall.LibraryDoor:FindFirstChild("PhoeyuDoor"):Destroy()
        elseif k == "Red Key" then
            SetTask('SubTask', '🔑 Submitting Red Key to scientist')
            alert('Red Key', "Submitting red key to the scienctist.")
            Remotes.CommF_:InvokeServer('CakeScientist', "Check")
            ScriptStorage.Tools["Red Key"]:Destroy()
        elseif k == 'Previous Hero' then
            SetTask('SubTask', '⚡ Buying Electric Claw from Previous Hero')
            Remotes.CommF_:InvokeServer('BuyElectricClaw', "Start")
            task.wait(3)
            repeat
                task.wait()
                TweenController.Create(CFrame.new(-12548.0, 332.378 + math.random(-2.0, 2), -7617.0))
            until CaculateDistance(CFrame.new(-12548.0, 332.378, -7617.0)) < 30
            Data = MeleePrices["Electric Claw"]
            Data.Buy(1)
            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call('Melee')
        elseif k == "Uzoth" then
            SetTask('SubTask', '🔥 Using Fire Essence for Dragon Talon')
            print('Use Fire Essence')
            Remotes.CommF_:InvokeServer("BuyDragonTalon", true)
            Remotes.CommF_:InvokeServer('BuyDragonTalon')
            IsFireEssenceGave = true
            Report("Fire Essence Used")
        elseif k == "Soul Reaper Spawner" then
            SetTask('SubTask', '💀 Using Hallow Essence to spawn Soul Reaper')
            print("Use Hallow Essence")
            if CaculateDistance(workspace.Map["Haunted Castle"].Summoner.Detection.CFrame) < 100 then SpecialItems = nil end
            TweenController.Create(workspace.Map["Haunted Castle"].Summoner.Detection.CFrame)
        end
    end)

    -- ============================================================
    -- TREVOR
    -- ============================================================
    FunctionsHandler.Trevor:RegisterMethod('GetFruit', function()
        for k, k in ScriptStorage.Backpack do
            if string.find(FruitIdToName(k.Name), " Fruit") then
                if k.Value and k.Value > 1000000 and k.Value < 2500000 then return k end
            end
        end
    end)

    FunctionsHandler.Trevor:RegisterMethod('Refresh', function()
        if FunctionsHandler.Trevor:Get('IsCompleted') or os.time() - timeee < 1 then return end
        if ScriptStorage.PlayerData.Level < 1100 then return end
        local k = FunctionsHandler.Trevor.Methods.GetFruit:Call()
        if k then FunctionsHandler.Trevor:Set('Fruit', k) end
        TrevorDebounce = os.time()
        if not FunctionsHandler.Trevor:Get('IsCompleted') then
            FunctionsHandler.Trevor:Set('IsCompleted', (Remotes.CommF_:InvokeServer("TalkTrevor", "1") == 0))
        end
        return not FunctionsHandler.Trevor:Get("IsCompleted") and k
    end)

    FunctionsHandler.Trevor:RegisterMethod("Start", function()
        alert('[ info ]', "Pulling fruit for trevor...")
        local k = FunctionsHandler.Trevor:Get("Fruit")
        FunctionsHandler.Trevor:Set('Fruit', nil)
        table.insert(ScriptStorage.IgnoreStoreFruits, k.Name)
        Remotes.CommF_:InvokeServer('LoadFruit', k.Name)
        task.wait()
        FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(FruitIdToName(k.Name))
        Remotes.CommF_:InvokeServer('TalkTrevor', '1')
        Remotes.CommF_:InvokeServer('TalkTrevor', "2")
        Remotes.CommF_:InvokeServer("TalkTrevor", "3")
        task.wait(1)
        FunctionsHandler.Trevor:Set('IsCompleted', true)
    end)

    -- ============================================================
    -- THIRD SEA PUZZLE (ZOU)
    -- ============================================================
    FunctionsHandler.ThirdSeaPuzzle:RegisterMethod("Refresh", function()
        if ScriptStorage.PlayerData.Level < 1500 or SeaIndex ~= 2 then return end
        if nil == FunctionsHandler.ThirdSeaPuzzle:Get('State') then
            ZQuestProgress = Remotes.CommF_:InvokeServer("ZQuestProgress", 'Check')
            print('ZQuestProgress', ZQuestProgress)
            FunctionsHandler.ThirdSeaPuzzle:Set("State", ZQuestProgress == 0)
        end
        return FunctionsHandler.ThirdSeaPuzzle:Get('State')
    end)

    FunctionsHandler.ThirdSeaPuzzle:RegisterMethod('Start', function()
        local k = FunctionsHandler.ThirdSeaPuzzle:Get("State")
        SetTask('SubTask', '🧩 Sea3: Starting ZQuest...')
        alert('1093', "start")
        if k then
            alert('1095', "case test")
            repeat
                task.wait(1)
                alert('1096', 'fire')
                print('StartResponse', Remotes.CommF_:InvokeServer("ZQuestProgress", "Begin"))
            until CaculateDistance(Vector3.new(0, 0, 0)) > 20000
            task.spawn(function()
                alert("1098", "rejoin")
                -- [FIXED] Delay reduced 30s -> 15s; still enough for the server to register state before the forced rejoin.
                task.wait(15)
                SafeRejoin()
            end)
            alert("attack")
            while task.wait() do CombatController.Attack("rip_indra") end
        end
    end)

    -- ============================================================
    -- YAMA
    -- ============================================================
    FunctionsHandler.Yama:RegisterMethod('Refresh', function()
        if SeaIndex ~= 3 then return end
        if ScriptStorage.Backpack.Yama then return end
        if not FunctionsHandler.Yama:Get("EliteCount") then
            FunctionsHandler.Yama:Set("EliteCount", Remotes.CommF_:InvokeServer("EliteHunter", "Progress"))
        end
        if FunctionsHandler.Yama:Get('EliteCount') >= 30 then return true end
    end)

    FunctionsHandler.Yama:RegisterMethod("Start", function()
        SetTask('SubTask', '🗡️ Getting Yama...')
        repeat
            task.wait()
            TweenController.Create(game:GetService("ReplicatedStorage").FakeIslands.Waterfall:GetModelCFrame())
        until workspace.Map:FindFirstChild("Waterfall") and workspace.Map.Waterfall:FindFirstChild("SealedKatana")
        fireclickdetector(workspace.Map.Waterfall.SealedKatana.Hitbox.ClickDetector)
    end)

    -- ============================================================
    -- PIRATE RAID
    -- ============================================================
    FunctionsHandler.PirateRaid:RegisterMethod("Refresh", function()
        local k = FunctionsHandler.PirateRaid:Get('Senque')
        return k and os.time() - k < 500
    end)

    FunctionsHandler.PirateRaid:RegisterMethod("Start", function()
        local k = GetMonAsSortedRange()
        local h = Vector3.new(-5543.5327148438, 313.80062866211, -2964.2585449219)
        if k[1] then
            local X, w = k[1]:FindFirstChild("Humanoid"), k[1]:FindFirstChild("HumanoidRootPart")
            if w and X and X.Health > 0 and CaculateDistance(w.CFrame, h) < 500 then
                CombatController.Attack(k[1].Name)
                return
            end
        end
        TweenController.Create(h)
    end)

    -- ============================================================
    -- SOUL GUITAR - logic from HI.LUA + AUTO CHEST
    -- HELPERS
    local _SgSpecialItems = {
        "God's Chalice", "Fist of Darkness", "Sweet Chalice",
        "Hallow Essence", "Mirror Fractal"
    }

    local function _SgHasSpecialItem()
        local bp = LocalPlayer:FindFirstChild("Backpack")
        local char = LocalPlayer.Character
        for _, name in ipairs(_SgSpecialItems) do
            if bp and bp:FindFirstChild(name) then return true, name end
            if char and char:FindFirstChild(name) then return true, name end
        end
        return false, nil
    end

    local function _SgGetChests()
        local chests = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Parent
               and string.find(string.lower(obj.Name), "chest") then
                table.insert(chests, obj)
            end
        end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos = hrp.Position
            table.sort(chests, function(a, b)
                if a and b and a.Parent and b.Parent then
                    return (pos - a.Position).Magnitude < (pos - b.Position).Magnitude
                end
                return false
            end)
        end
        return chests
    end

    local function _SgCollectChest(chest)
        pcall(function()
            if not chest or not chest.Parent then return end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
            local targetCF = chest.CFrame + Vector3.new(0, 3, 0)
            -- [FIXED] Removed the BypassTP branch for far chests (>3000 studs); always use normal TweenController.Create.
            TweenController.Create(targetCF)
            task.wait(0.35)
            if firetouchinterest then
                firetouchinterest(hrp, chest, 0)
                task.wait()
                firetouchinterest(hrp, chest, 1)
            end
        end)
    end

    local _SgChestPhaseDone = false
    local _SgVisited = {}

    local function _SgHopServer()
        SetTask("MainTask", "🎸 Soul Guitar | Hop: Searching for a server...")
        local ok, servers = pcall(GetServers)
        if ok and servers then
            local list = {}
            for jobId, data in pairs(servers) do
                if jobId ~= game.JobId and not _SgVisited[jobId] then
                    table.insert(list, {id = jobId, players = data.Count or 0})
                end
            end
            table.sort(list, function(a, b) return a.players < b.players end)
            if list[1] then
                _SgVisited[list[1].id] = true
                SetTask("SubTask", "🎸 Hop → " .. list[1].id:sub(1,8) .. "... (" .. list[1].players .. " players)")
                pcall(function()
                    SafeTeleportTo(list[1].id)
                end)
                -- [FIXED] Delay 8s -> 4s: teleport usually drops the connection within a few seconds.
                task.wait(4)
                _SgChestPhaseDone = false
                return
            end
        end
        pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            local resp = game:HttpGet(url)
            local data = game:GetService("HttpService"):JSONDecode(resp)
            if not data or not data.data then return end
            table.sort(data.data, function(a, b) return (a.playing or 0) < (b.playing or 0) end)
            for _, sv in ipairs(data.data) do
                local slots = (sv.maxPlayers or 0) - (sv.playing or 0)
                if slots >= 2 and sv.id ~= game.JobId and not _SgVisited[sv.id] then
                    _SgVisited[sv.id] = true
                    SetTask("SubTask", "🎸 Hop HTTP → " .. sv.id:sub(1,8) .. " (" .. (sv.playing or 0) .. "/" .. (sv.maxPlayers or 0) .. ")")
                    pcall(function()
                        SafeTeleportTo(sv.id)
                    end)
                    -- [FIXED] Delay 8s -> 4s (same as the hop branch above)
                    task.wait(4)
                    _SgChestPhaseDone = false
                    return
                end
            end
        end)
        SetTask("MainTask", "🎸 Soul Guitar | Hop: No server found, retrying...")
        -- [FIXED] Retry backoff 5s -> 2s
        task.wait(2)
    end

    local function _SgRunChestBatch()
        local hasItem, itemName = _SgHasSpecialItem()
        if hasItem then
            SetTask("MainTask", "🎸 Auto Chest: Found " .. itemName .. " - stopping")
            return false
        end
        if ScriptStorage.Backpack["Skull Guitar"] then
            return false
        end
        local chests = _SgGetChests()
        SetTask("SubTask", "🎸 Auto Chest: " .. #chests .. " chests left")
        if #chests == 0 then
            return false
        end
        for _, chest in ipairs(chests) do
            if _G.Stop then return false end
            local hasMid, nameMid = _SgHasSpecialItem()
            if hasMid then
                SetTask("MainTask", "🎸 Auto Chest: Found " .. nameMid)
                return false
            end
            if chest and chest.Parent then
                SetTask("MainTask", "🎸 Collecting: " .. chest.Name)
                _SgCollectChest(chest)
                task.wait(0.2)
            end
        end
        return #_SgGetChests() > 0
    end

    -- MAIN LOGIC
    FunctionsHandler.SoulGuitar:RegisterMethod("Refresh", function()
        if not Config.Items.SoulGuitar then return end
        if ScriptStorage.Backpack['Skull Guitar'] then return end
        if ScriptStorage.PlayerData.Level < 2300 then return end

        local ectoCount = (ScriptStorage.Backpack['Ectoplasm'] or {Count = 0}).Count or 0
        local bonesCount = (ScriptStorage.Backpack['Bones'] or {Count = 0}).Count or 0
        local frags = ScriptStorage.PlayerData.Fragments or 0

        -- STEP 1: Farm Ectoplasm up to 250 in Sea 2
        if ectoCount < 250 then
            _SgChestPhaseDone = false
            return 1
        end

        -- STEP 2: If no Dark Fragment yet -> farm chests -> summon Blackbeard -> fight
        if not ScriptStorage.Backpack['Dark Fragment'] then
            if ScriptStorage.Backpack['Fist of Darkness'] then
                return 10   -- summon & fight Blackbeard
            end
            if not _SgChestPhaseDone then
                local chests = _SgGetChests()
                if #chests > 0 then
                    return 9   -- auto chest
                else
                    _SgChestPhaseDone = true
                    SetTask("MainTask", "🎸 Soul Guitar | Out of chests, hopping server to find Fist of Darkness")
                    task.spawn(_SgHopServer)
                    return
                end
            else
                _SgChestPhaseDone = false
                return 9
            end
        end

        -- STEP 3: Has Dark Fragment -> go to the Sea 3 puzzle
        if SeaIndex ~= 3 then
            SetTask('MainTask', '🎸 Soul Guitar: Teleport to Sea 3')
            Remotes.CommF_:InvokeServer("TravelZou")
            return
        end

        SoulGuitarProcess = Remotes.CommF_:InvokeServer("GuitarPuzzleProgress", 'Check')
        if not SoulGuitarProcess then
            Remotes.CommF_:InvokeServer("gravestoneEvent", 2)
            if not CheckFullMoon() then
                SetTask('MainTask', 'Hopping for full moon (soul guitar)')
                _SgHopServer()
            end
            return 7
        end
        if not SoulGuitarProcess.Swamp      then return 2
        elseif not SoulGuitarProcess.Gravestones then return 3
        elseif not SoulGuitarProcess.Ghost  then return 4
        elseif not SoulGuitarProcess.Trophies   then return 5
        elseif not SoulGuitarProcess.Pipes  then return 6
        elseif bonesCount >= 500 and frags >= 5000 and not ScriptStorage.Backpack["Skull Guitar"] then
            return 8
        end
    end)

    FunctionsHandler.SoulGuitar:RegisterMethod('Start', function(k)
        if k == 9 then
            SetTask("MainTask", "🎸 Soul Guitar | Auto Chest: Collecting chests...")
            local hasMore = _SgRunChestBatch()
            if not hasMore then
                _SgChestPhaseDone = true
            end

        elseif k == 10 then
            SetTask('SubTask', '🎸 Soul Guitar: Summon Blackbeard')
            local darkArenaPos = CFrame.new(-1742.0, 241.0, 1290.0)
            TweenController.Create(darkArenaPos)
            task.wait(1)
            pcall(function()
                Remotes.CommF_:InvokeServer("Blackbeard", "Spawn")
            end)
            task.wait(1)
            SetTask('MainTask', '🎸 Soul Guitar: Fighting Blackbeard for the Dark Fragment')
            CombatController.Attack("Blackbeard")

        elseif k == 7 then
            SetTask('SubTask', '🎸 Soul Guitar: Full moon gravestone')
            while CaculateDistance(CFrame.new(-8654.0, 140, 6167)) > 5 do
                task.wait()
                TweenController.Create(CFrame.new(-8654.0, 140, 6167))
            end
            SoulGuitarProcess = Remotes.CommF_:InvokeServer("gravestoneEvent", 2, true)

        elseif k == 1 then
            if SeaIndex ~= 2 then
                SetTask("SubTask", '🎸 Soul Guitar: Teleporting to Sea 2 to farm ectoplasm')
                SetTask("MainTask", 'Teleport to second sea to farm ectoplasm')
                Remotes.CommF_:InvokeServer("TravelDressrosa")
                return
            else
                local ecto = (ScriptStorage.Backpack['Ectoplasm'] or {Count = 0}).Count or 0
                SetTask("SubTask", '🎸 Soul Guitar: Farming Ectoplasm (' .. ecto .. '/250)')
                SetTask("MainTask", "Soul Guitar | Ectoplasm " .. ecto .. "/250")
                CombatController.Attack({"Ship Deckhand", "Ship Engineer", 'Ship Steward', "Ship Officer"})
                return
            end

        elseif k == 2 then
            SetTask('SubTask', '🎸 Soul Guitar: Kill Living Zombies (Swamp)')
            TTL9 = TTL9 or 0
            if os.time() ~= LastestTime1 then
                TTL9 = TTL9 + 1
                LastestTime1 = os.time()
            end
            if TTL9 > 60 then _SgHopServer() return end

            local zombies = {}
            for _, enemy in ipairs(Services.Workspace.Enemies:GetChildren()) do
                if enemy.Name == "Living Zombie" then
                    table.insert(zombies, enemy)
                end
            end

            if #zombies < 6 then
                SetTask('MainTask', 'Soul Guitar: Waiting Living Zombies (' .. #zombies .. '/6)')
                TweenController.Create(ScriptStorage.MobRegions["Living Zombie"][1] + Vector3.new(0, 30, 0))
            else
                local startT = os.time()
                for idx, zombie in ipairs(zombies) do
                    local hum  = zombie:FindFirstChild("Humanoid")
                    local root = zombie:FindFirstChild("HumanoidRootPart")
                    if not hum or not root then continue end
                    while task.wait() and hum.Health > 7000 do
                        SetTask('MainTask', 'Soul Guitar: Weakening zombie ' .. idx .. '/' .. #zombies)
                        FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call('Melee')
                        if os.time() - startT > 60 then _SgHopServer() return end
                        TweenController.Create(root.CFrame + Vector3.new(0, 50, 0))
                        pcall(function() _G.FastAttack = os.time() end)
                    end
                end
                SetTask("MainTask", 'Soul Guitar: Finishing all Living Zombies')
                local killT = os.time()
                while workspace.Enemies:FindFirstChild("Living Zombie") and task.wait() do
                    if os.time() - killT > 60 then _SgHopServer() return end
                    CombatController.Attack('Living Zombie')
                end
                TTL9 = 0
            end

        elseif k == 3 then
            SetTask('SubTask', '🎸 Soul Guitar: Placard puzzle')
            local castle = workspace.Map["Haunted Castle"]
            while CaculateDistance(CFrame.new(-8800.0, 178, 6033)) > 10 do
                task.wait()
                SetTask("MainTask", "Soul Guitar: Completing placards...")
                TweenController.Create(CFrame.new(-8800.0, 178, 6033))
            end
            for placadName, dir in pairs({
                Placard1 = "Right", Placard2 = "Right", Placard3 = "Left",
                Placard4 = "Right", Placard5 = "Left", Placard6 = "Left", Placard7 = "Left"
            }) do
                pcall(function() fireclickdetector(castle[placadName][dir].ClickDetector) end)
            end

        elseif k == 4 then
            SetTask('SubTask', '🎸 Soul Guitar: Ghost task')
            Remotes.CommF_:InvokeServer("GuitarPuzzleProgress", "Ghost")

        elseif k == 5 then
            SetTask('SubTask', '🎸 Soul Guitar: Trophy puzzle')
            if CaculateDistance(CFrame.new(-9530.0126953125, 6.104853630065918, 6054.83349609375)) > 30 then
                TweenController.Create(CFrame.new(-9530.0126953125, 6.104853630065918, 6054.83349609375))
            else
                local tablet = workspace.Map['Haunted Castle'].Tablet
                for _, segName in pairs(BlankTablets) do
                    local seg = tablet[segName]
                    if seg and seg.Line.Rotation.Z ~= 0 then
                        repeat task.wait() fireclickdetector(seg.ClickDetector)
                        until seg.Line.Rotation.Z == 0
                    end
                end
                for segName, trophyName in pairs(Trophy) do
                    pcall(function()
                        local handle = workspace.Map["Haunted Castle"].Trophies.Quest[trophyName].Handle
                        local rotPart = tostring(handle.CFrame):split(", ")[4]
                        local targetRot = (rotPart == "1" or rotPart == "-1") and "90" or "180"
                        local seg = tablet[segName]
                        if seg and not string.find(tostring(seg.Line.Rotation.Z), targetRot) then
                            repeat task.wait() fireclickdetector(seg.ClickDetector)
                            until string.find(tostring(seg.Line.Rotation.Z), targetRot)
                        end
                    end)
                end
            end

        elseif k == 6 then
            SetTask('SubTask', '🎸 Soul Guitar: Pipe puzzle')
            for pipeName, colorName in pairs(Pipes) do
                pcall(function()
                    local pipe = workspace.Map['Haunted Castle']['Lab Puzzle'].ColorFloor.Model[pipeName]
                    if pipe and pipe.BrickColor.Name ~= colorName then
                        repeat task.wait() fireclickdetector(pipe.ClickDetector)
                        until pipe.BrickColor.Name == colorName
                    end
                end)
            end
            Remotes.CommF_:InvokeServer('soulGuitarBuy')

        elseif k == 8 then
            SetTask('SubTask', '🎸 Soul Guitar: Buying Skull Guitar')
            Remotes.CommF_:InvokeServer('soulGuitarBuy')
        end
    end)
    -- ============================================================
    -- END OF SOUL GUITAR SECTION
    -- ============================================================

    -- ============================================================
    -- TUSHITA
    -- ============================================================
    FunctionsHandler.Tushita:RegisterMethod("Refresh", function()
        if ScriptStorage.Backpack.Tushita then return end
        if ScriptStorage.PlayerData.Level < 2000 then return end
        if SeaIndex ~= 3 then return end
        TushitaProgress = TushitaProgress or Remotes.CommF_:InvokeServer("TushitaProgress")
        if not TushitaProgress.OpenedDoor then
            if ScriptStorage.Enemies["rip_indra True Form"] then
                TushitaProgress = nil
                return 1
            end
        else
            if ScriptStorage.Enemies['Longma'] then
                TushitaProgress = nil
                return 2
            end
        end
    end)

    FunctionsHandler.Tushita:RegisterMethod('Start', function(k)
        if k == 1 then
            SetTask('SubTask', '🗡️ Tushita: Placing torches (Step 1)')
            alert('Auto Tushita', 'Placing torches...')
            TweenController.Create(CFrame.new(5714, math.random(19, 21), 256))
            if ScriptStorage.Tools["Holy Torch"] then
                for W = 1, 5 do Remotes.CommF_:InvokeServer("TushitaProgress", "Torch", W) end
                return true
            end
        elseif k == 2 then
            SetTask('SubTask', '🗡️ Tushita: Defeating Longma (Step 2)')
            alert("Auto Tushita", "Defeating Longma")
            CombatController.Attack("Longma")
        end
    end)

    -- ============================================================
    -- CURSED DUAL KATANA (CDK)
    -- ============================================================
    FunctionsHandler.CursedDualKatana:RegisterMethod("Refresh", function()
        if not Config.Items.CursedDualKatana then return end
        local k = ScriptStorage.Backpack
        if ScriptStorage.PlayerData.Level < 2200 then return end
        -- [FIXED] Missing 350 mastery used to just return silently. Now returns 'trainSwords' so Start() farms Bones at Haunted Castle,
        -- checking mastery every second; CDK only starts when BOTH Yama and Tushita are >= 350.
        if k["Cursed Dual Katana"] then return end
        if not k.Tushita or (k.Tushita.Mastery or 0) < 350 or not k.Yama or (k.Yama.Mastery or 0) < 350 then
            return {"trainSwords"}
        end
        if SeaIndex ~= 3 then return end
        local k = CdkProgess or Remotes.CommF_:InvokeServer("CDKQuest", 'Progress') or 'uwu'
        if not k or k == 'uwu' then return end
        if workspace.Map.Turtle.Cursed:FindFirstChild("Breakable") then
            alert('Cursed Dual Katana', 'Open Door')
            return {"break"}
        end
        local W = {Good = 'Tushita', Evil = 'Yama'}
        if k.Good == 4 and k.Evil == 4 then
            print("burn 2")
            return {'burn 2'}
        end
        if k.Good == 3 or k.Evil == 3 then
            print('burn 1')
            return {"burn"}
        end
        if k.Opened then
            for h, X in k do
                if h ~= 'Opened' and h ~= "Finished" and X < 3 then
                    print(h, X)
                    ScriptStorage.CdkCache = {h, X + 1}
                    if not ScriptStorage.Tools[W[h]] then Remotes.CommF_:InvokeServer('LoadItem', W[h]) end
                    alert("Cursed Dual Katana", "Start " .. tostring(W[h]) .. ' ' .. tostring(h))
                    Remotes.CommF_:InvokeServer('CDKQuest', 'StartTrial', h)
                    SetTask("MainTask", "Cursed Dual Katana - " .. tostring(W[h]) .. ' ' .. tostring(h))
                    return false
                end
            end
        end
        local k = ScriptStorage.CdkCache
        if not k then return end
        local W, h = k[1], k[2]
        if W == "Evil" and h == 3 then
            -- [FIXED] Used to set ForceToRollBone=true and hang forever (no handler read it). Now the real chain:
            -- Bones -> Hallow Essence -> equip at summon position -> Soul Reaper spawns -> fight.
            local HALLOW_SUMMON_CF = CFrame.new(-8932.86, 143.258, 6063.31)

            if ScriptStorage.Enemies['Soul Reaper'] then
                -- Already spawned -> fight, nothing else to do on this branch
                return k
            end

            local hasHallow = ScriptStorage.Backpack["Hallow Essence"]
                or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Hallow Essence"))

            if hasHallow then
                SetTask('SubTask', 'CDK Quest / Using Hallow Essence to summon Soul Reaper')
                TweenController.Create(HALLOW_SUMMON_CF)
                if CaculateDistance(HALLOW_SUMMON_CF) <= 8 then
                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Hallow Essence")
                end
                return
            else
                -- [FIXED] Real threshold is 500 Bones (not 50). Below that keep farming, do not fire Buy.
                local bonesCount = Remotes.CommF_:InvokeServer("Bones", "Check")
                SetTask('SubTask', 'CDK Quest / Farming Bones for Hallow Essence (' .. tostring(bonesCount) .. '/500)')

                if bonesCount and bonesCount > 500 then
                    -- [FIXED] At 500 -> spend everything in one burst (repeat Buy(1,1) until Check == 0)
                    repeat
                        Remotes.CommF_:InvokeServer("Bones", "Buy", 1, 1)
                        task.wait(0.2)
                        bonesCount = Remotes.CommF_:InvokeServer("Bones", "Check")
                    until not bonesCount or bonesCount <= 0
                    return
                end

                if not ScriptStorage.Enemies["Reborn Skeleton"] and not ScriptStorage.Enemies["Living Zombie"]
                    and not ScriptStorage.Enemies["Demonic Soul"] and not ScriptStorage.Enemies["Posessed Mummy"] then
                    -- [NEW] No corpse nearby -> go to the Haunted Castle farm spot instead of standing still
                    SetTask('SubTask', 'CDK Quest / Moving to Haunted Castle to farm Bones')
                    TweenController.Create(HAUNTED_CASTLE_BONES_CF)
                    return
                end
                CombatController.Attack({"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"})
                return
            end
        elseif W == 'Good' then
            if h == 2 then
                SetTask("SubTask", 'CDK Quest / Waiting until pirate raid started')
                return
            elseif h == 3 and not ScriptStorage.Enemies["Cake Queen"] then
                Hop()
                SetTask('SubTask', "CDK Quest / Waiting until Cake Queen boss spawned")
                return
            end
        end
        return k
    end)

    FunctionsHandler.CursedDualKatana:RegisterMethod("GetHazeMon", function()
        local k = {}
        for W, W in LocalPlayer.QuestHaze:GetChildren() do if W.Value > 0 then table.insert(k, W) end end
        table.sort(k, function(W, h) return CaculateDistance(W:GetAttribute('Position')) < CaculateDistance(h:GetAttribute('Position')) end)
        return tostring(k[1])
    end)

    FunctionsHandler.CursedDualKatana:RegisterMethod("DoDimension", function(k)
        local W = string.gsub(k, ' ', "")
        local k = os.time()
        repeat
            task.wait()
            TweenController.Create(LocalPlayer.Character.HumanoidRootPart.CFrame)
            if os.time() - k > 60 then return end
        until os.time() - TorchEnabledTime < 10
        repeat
            task.wait()
            local k = workspace.Map:WaitForChild(W, 10)
            if k then
                for h, h in k:GetChildren() do
                    if h and string.find(h.Name, "Torch") and h:FindFirstChild('ProximityPrompt') and h.ProximityPrompt.Enabled then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = h.CFrame
                        h.ProximityPrompt.HoldDuration = 0
                        task.wait(1)
                        local X = game:GetService("VirtualInputManager")
                        X:SendKeyEvent(true, "E", 0, game)
                        X:SendKeyEvent(false, "E", 0, game)
                        fireproximityprompt(workspace.Map:WaitForChild(W, 10):FindFirstChild(tostring(h)).ProximityPrompt)
                    end
                    for W, W in workspace.Enemies:GetChildren() do
                        local h = W:FindFirstChild("HumanoidRootPart")
                        local X = W:FindFirstChild("Humanoid")
                        if h and X and CaculateDistance(h.CFrame) < 1000 then CombatController.Attack(W.Name) end
                    end
                end
                ExitDoor = k:FindFirstChild("Exit")
                print("exit door", ExitDoor)
                if ExitDoor then
                    PortalBrick = tostring(ExitDoor.BrickColor)
                    print("Brick color", ExitDoor, ExitDoor.BrickColor, PortalBrick)
                end
            else
                print('no island idk wt-')
            end
            print('loop damn', PortalBrick)
        until PortalBrick == 'Olive' or PortalBrick == "Cloudy grey"
        print('leave')
        while os.time() - DoneCdkTick > 15 do
            TweenController.Create(ExitDoor.CFrame + Vector3.new(0, math.random(1, 5), 0))
            task.wait()
        end
        Hop()
    end)

    FunctionsHandler.CursedDualKatana:RegisterMethod("Start", function(k)
        local W = workspace.Map.Turtle.Cursed
        if k[1] == "trainSwords" then
            -- [NEW] Yama/Tushita below 350 mastery -> farm Bones at Haunted Castle with the missing sword equipped
            -- so mastery counts for it.
            local bp = ScriptStorage.Backpack
            local tushitaMastery = bp.Tushita and bp.Tushita.Mastery or 0
            local yamaMastery    = bp.Yama and bp.Yama.Mastery or 0

            local swordToTrain = nil
            if not bp.Tushita then
                swordToTrain = "buy_tushita"
            elseif tushitaMastery < 350 then
                swordToTrain = "Tushita"
            elseif not bp.Yama then
                swordToTrain = "buy_yama"
            elseif yamaMastery < 350 then
                swordToTrain = "Yama"
            end

            if swordToTrain == "buy_tushita" or swordToTrain == "buy_yama" then
                SetTask('MainTask', 'CDK Prep | Missing ' .. (swordToTrain == "buy_tushita" and "Tushita" or "Yama") .. ' - waiting for the Tushita/Yama handler to buy it')
                return
            end

            SetTask('MainTask', string.format('CDK Prep | Tushita %d/350, Yama %d/350', tushitaMastery, yamaMastery))

            if swordToTrain then
                pcall(function()
                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(swordToTrain)
                end)
            end

            if not ScriptStorage.Enemies["Reborn Skeleton"] and not ScriptStorage.Enemies["Living Zombie"]
                and not ScriptStorage.Enemies["Demonic Soul"] and not ScriptStorage.Enemies["Posessed Mummy"] then
                SetTask('SubTask', 'CDK Prep | Moving to Haunted Castle')
                TweenController.Create(HAUNTED_CASTLE_BONES_CF)
                return
            end
            CombatController.Attack({"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"})
            return
        end
        if k[1] == 'break' then
            SetTask('SubTask', '⚔️ CDK: Opening door')
            TweenController.Create(workspace.Map.Turtle.Cursed.Breakable.CFrame)
            Remotes.CommF_:InvokeServer('CDKQuest', "OpenDoor")
            Remotes.CommF_:InvokeServer("CDKQuest", "OpenDoor", true)
            workspace.Map.Turtle.Cursed.Breakable:Destroy()
            CdkProgess = nil
            return
        end
        if k[1] == "burn 2" then
            SetTask('SubTask', '⚔️ CDK: Burning pedestals (step 2)')
            if workspace.Map.Turtle.Cursed.Pedestal3.ProximityPrompt.Enabled then
                fireproximityprompt(workspace.Map.Turtle.Cursed.Pedestal3.ProximityPrompt)
                task.wait(1)
                pcall(function() LocalPlayer.Character.Humanoid.Health = 0 end)
                -- [FIXED] Delay 10s -> 5s: waiting for respawn after self-kill (normally 2-3s).
                task.wait(5)
            else
                CDKAttempts = (CDKAttempts or 0) + 1
                TweenController.Create(CFrame.new(-12341.66796875, 603.3455810546875, -6550.6064453125))
                -- [FIXED] Delay 5s/5s -> 3s/3s
                task.wait(3)
                pcall(function() LocalPlayer.Character.Humanoid.Health = 0 end)
                task.wait(3)
                if CDKAttempts > 5 then Hop() end
                CdkProgess = nil
            end
        elseif k[1] == "burn" then
            SetTask('SubTask', '⚔️ CDK: Burning pedestals')
            for W = 1, 3, 1 do
                local h = workspace.Map.Turtle.Cursed:FindFirstChild("Pedestal" .. W)
                if workspace.Map.Turtle.Cursed:FindFirstChild('Pedestal' .. W).ProximityPrompt.Enabled then
                    repeat
                        task.wait()
                        TweenController.Create(workspace.Map.Turtle.Cursed:FindFirstChild('Pedestal' .. W).CFrame)
                    until CaculateDistance(workspace.Map.Turtle.Cursed:FindFirstChild("Pedestal" .. W).CFrame) < 5
                    fireproximityprompt(workspace.Map.Turtle.Cursed:FindFirstChild("Pedestal" .. W).ProximityPrompt)
                    task.wait(3)
                    pcall(function() LocalPlayer.Character.Humanoid.Health = 0 end)
                end
                CdkProgess = nil
            end
        elseif k[1] == 'Evil' then
            if k[2] == 1 then
                SetTask('SubTask', '⚔️ CDK: Evil trial - Forest Pirate')
                local W = ScriptStorage.Enemies["Forest Pirate"]
                TweenController.Create((W and W.HumanoidRootPart.CFrame) or ScriptStorage.MobRegions["Forest Pirate"][0])
                CdkProgess = nil
            elseif k[2] == 2 then
                SetTask('SubTask', '⚔️ CDK: Evil trial - Haze monster')
                CombatController.Attack(FunctionsHandler.CursedDualKatana.Methods.GetHazeMon:Call())
                CdkProgess = nil
            elseif k[2] == 3 then
                SetTask('SubTask', '⚔️ CDK: Evil trial - Soul Reaper')
                Report("found cdk yama 3")
                while not (os.time() - TorchEnabledTime < 100 or not ScriptStorage.Enemies["Soul Reaper"]) do
                    print("tweening to soul reaper")
                    task.wait()
                    if FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call() then
                        pcall(function() LocalPlayer.Character.Humanoid.Health = 0 end)
                    end
                    TweenController.Create(ScriptStorage.Enemies["Soul Reaper"]:GetModelCFrame())
                end
                if not ScriptStorage.Enemies["Soul Reaper"] then return end
                FunctionsHandler.CursedDualKatana.Methods.DoDimension.Callback("Hell Dimension")
                CdkProgess = nil
            end
        else
            if k[2] == 1 then
                SetTask('SubTask', '⚔️ CDK: Good trial - Boat Dealer')
                for W, W in game.ReplicatedStorage.NPCs:GetChildren() do
                    if W.Name == "Luxury Boat Dealer" then
                        repeat
                            task.wait()
                            if os.time() - DoneCdkTick < 15 then return end
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = (W:GetModelCFrame())
                            RealNPC = nil
                            for h, h in workspace.NPCs:GetChildren() do
                                if CaculateDistance(h:GetModelCFrame(), W:GetModelCFrame()) < 20 then
                                    RealNPC = h
                                    break
                                end
                            end
                        until CaculateDistance(W:GetModelCFrame()) < 5 and RealNPC
                        Remotes.CommF_:InvokeServer("CDKQuest", "BoatQuest", RealNPC)
                    end
                end
                CdkProgess = nil
            elseif k[2] == 3 then
                SetTask('SubTask', '⚔️ CDK: Good trial - Cake Queen')
                repeat
                    task.wait()
                    print('attacking cage queen')
                    CombatController.Attack("Cage Queen")
                until os.time() - TorchEnabledTime < 10 or not ScriptStorage.Enemies['Cake Queen']
                TweenController.Create(LocalPlayer.Character.HumanoidRootPart.CFrame)
                Report('Cake Queen')
                FunctionsHandler.CursedDualKatana.Methods.DoDimension.Callback("Heavenly Dimension")
                CdkProgess = nil
            end
        end
    end)

    -- ============================================================
    -- NOTIFICATION LISTENERS
    -- ============================================================
    local k = {Listeners = {}}
    TorchEnabledTime = 0
    DoneCdkTick = 0
    getgenv().NotificationCallBack = (function(W)
        for h, X in k.Listeners do
            if string.find(string.lower(W), string.lower(h)) then X(W) end
        end
    end)
    function k:RegisterNotifyListener(W, h) k.Listeners[W] = h end
    k:RegisterNotifyListener('go!', function() LastRaidAlert = os.time() end)
    k:RegisterNotifyListener('raid', function() LastRaidAlert2 = os.time() end)
    k:RegisterNotifyListener("been spotted approaching", function() FunctionsHandler.PirateRaid:Set('Senque', os.time()) end)
    k:RegisterNotifyListener('job', function() FunctionsHandler.PirateRaid:Set('Senque', 0) end)
    k:RegisterNotifyListener("level", function() AddPoint() end)
    k:RegisterNotifyListener("torch", function() TorchEnabledTime = os.time() end)
    k:RegisterNotifyListener("scroll reacts", function() DoneCdkTick = os.time() end)
    k:RegisterNotifyListener("elite", function()
        FunctionsHandler.Yama:Set('EliteCount', Remotes.CommF_:InvokeServer("EliteHunter", "Progress"))
        alert("[MeyyHub ] ", "Elite defeated: " .. tostring(FunctionsHandler.Yama:Get("EliteCount") or 'n/a'))
    end)
    k:RegisterNotifyListener('the raid with', function()
        if ScriptStorage.PlayerData.Level < MaxLevel then return end
        Remotes.CommF_:InvokeServer('Awakener', "Awaken")
    end)
    k:RegisterNotifyListener('quest completed', function()
        J:RefreshQuest()
        task.wait()
        if not J:GetCurrentClaimQuest() then J:MarkAsCompleted() end
    end)
    local k
    pcall(function()
        k = hookfunction(require(game.ReplicatedStorage.Notification).new, function(W, h)
            v21 = tostring(tostring(W or '') .. tostring(h or "")) or ""
            pcall(function() getgenv().NotificationCallBack(v21) end)
            return k(W, h)
        end)
    end)

    -- ============================================================
    -- SERVER MANAGEMENT
    -- ============================================================
    if SeaIndex ~= 1 then end
    function IfTableHaveIndex(k) for W in k do return true end end
    print(1)
    function GetServers()
        if LastServersDataPulled then
            if os.time() - LastServersDataPulled < 60 then return CachedServers end
        end
        for k = 1, 100, 1 do
            local W = game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser"):InvokeServer(k)
            if IfTableHaveIndex(W) then
                LastServersDataPulled = os.time()
                CachedServers = W
                return W
            end
        end
    end
    spawn(function()
        GetServers()
        -- [FIXED] Delay 180s -> 90s; not lower, to avoid spamming Roblox's server-list API (rate limited).
        while task.wait(90) do GetServers() end
    end)
    -- ============================================================
    -- [FIXED] SAFE HOP / REJOIN
    -- Old problems: "rejoin" teleported to game.JobId (the server you are already in) and the idle code spammed
    -- TeleportService:Teleport(game.PlaceId) every frame -> Roblox answers "attempted to teleport to a restricted place".
    -- Now: always a DIFFERENT server, failures are caught (TeleportInitFailed), the failed server is blacklisted,
    -- several methods are tried in order and there is a cooldown so the teleport is never spammed.
    -- ============================================================
    getgenv().__HopBlacklist = getgenv().__HopBlacklist or {}
    _TS = game:GetService("TeleportService") -- globals on purpose: avoids the 200-locals limit of this huge function
    _tpFail = nil
    pcall(function()
        _TS.TeleportInitFailed:Connect(function(plr, result, msg)
            _tpFail = {result = result, msg = msg}
            warn("[Hop] TeleportInitFailed:", tostring(result), tostring(msg))
        end)
    end)

    -- Tries to enter a specific server. Returns false if every method failed (if it works, the script dies with the old server).
    function SafeTeleportTo(jobId)
        local LP = game:GetService("Players").LocalPlayer
        local methods = {
            function()
                local sb = game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser", 5)
                if sb then sb:InvokeServer("teleport", jobId) end
            end,
            function() _TS:TeleportToPlaceInstance(game.PlaceId, jobId, LP) end,
        }
        for i, m in ipairs(methods) do
            _tpFail = nil
            local ok, err = pcall(m)
            if not ok then warn("[Hop] method " .. i .. " error:", err) end
            local t0 = os.clock()
            while os.clock() - t0 < 10 and not _tpFail do task.wait(0.25) end
            if not _tpFail then
                -- no failure reported: the teleport is probably loading, give it time (we die here if it works)
                task.wait(20)
            end
            if not _tpFail then return true end
            getgenv().__HopBlacklist[jobId] = true
            task.wait(2) -- small cooldown before trying the next method
        end
        return false
    end

    function _HopCandidates(maxPlayers, region)
        local list = {}
        local okS, servers = pcall(GetServers)
        if okS and type(servers) == "table" then
            for jobId, d in pairs(servers) do
                local count = tonumber(d.Count) or 0
                if jobId ~= game.JobId and not getgenv().__HopBlacklist[jobId]
                   and count < (maxPlayers or 11)
                   and (not region or d.Region == region) then
                    table.insert(list, jobId)
                end
            end
        end
        return list
    end

    function SafeHop(maxPlayers, region)
        if getgenv().__Hopping and os.clock() - getgenv().__Hopping < 90 then return "busy" end -- already hopping
        getgenv().__Hopping = os.clock()
        local reached = false
        for attempt = 1, 8 do
            local cands = _HopCandidates(maxPlayers, region)
            if #cands == 0 then
                LastServersDataPulled = nil -- force a fresh server list
                task.wait(3)
                cands = _HopCandidates(maxPlayers, region)
            end
            if #cands == 0 then break end
            local pick = cands[math.random(1, #cands)]
            print("[Hop] attempt " .. attempt .. " ->", pick)
            pcall(function() SetTask('SubTask', 'Hop -> ' .. pick:sub(1, 8) .. ' (try ' .. attempt .. ')') end)
            if SafeTeleportTo(pick) then reached = true break end
        end
        -- fallback: public server list over HTTP (only if the in-game list failed)
        if not reached then pcall(LowHop) end
        getgenv().__Hopping = nil
        return reached and "ok" or "failed"
    end
    Hop = SafeHop

    -- "Rejoin" = go to ANOTHER server (rejoining the same JobId is what raised the restricted-place error)
    function SafeRejoin()
        if SafeHop() == "busy" then return end
        -- still here after everything failed: plain Teleport, at most once every 60s
        if not getgenv().__LastPlainTp or os.clock() - getgenv().__LastPlainTp > 60 then
            getgenv().__LastPlainTp = os.clock()
            _tpFail = nil
            pcall(function() _TS:Teleport(game.PlaceId, game:GetService("Players").LocalPlayer) end)
            task.wait(15)
        end
    end

    LowHop = function()
        local ok, resp = pcall(function()
            return game:HttpGet('https://games.roblox.com/v1/games/' .. game.PlaceId .. '/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true')
        end)
        if not ok then return alert('Serverhop', "Server list request failed.") end
        local okD, data = pcall(function() return game:GetService("HttpService"):JSONDecode(resp) end)
        local ids = {}
        if okD and data and data.data then
            for _, sv in next, data.data do
                if type(sv) == "table" and tonumber(sv.playing) and tonumber(sv.maxPlayers)
                   and sv.playing < sv.maxPlayers - 1 and sv.id ~= game.JobId
                   and not getgenv().__HopBlacklist[sv.id] then
                    table.insert(ids, sv.id)
                end
            end
        end
        if #ids == 0 then return alert('Serverhop', "Couldn't find a server.") end
        for i = 1, math.min(#ids, 4) do
            if SafeTeleportTo(ids[math.random(1, #ids)]) then return end
        end
    end

    -- ============================================================
    -- STORAGE
    -- ============================================================
    Storage = {WRITE_DELAY = .5, Data = {}}
    Services = {}
    setmetatable(Services, {__index = function(k, k) return game:GetService(k) end})
    LocalPlayer = game.Players.LocalPlayer
    local k = ".storage_u_" .. tostring(LocalPlayer)
    function Decode(W) return Services.HttpService:JSONDecode(W) end
    function Encode(W) return Services.HttpService:JSONEncode(W) end
    print(5)
    function Storage.Set(W, h, X) W.Data[h] = X end
    function Storage.Get(W, h) return W.Data[h] end
    function Storage.Save(W) pcall(function() if writefile then writefile(k, Encode(W.Data)) end end) end
    if isfile and readfile and not isfile(k) then
        pcall(writefile, k, "{}")
        task.wait(1)
    end
    Storage.Data = {}
    if readfile then pcall(function() Storage.Data = Decode(readfile(k) or '{}') end) end
    spawn(function() while task.wait(Storage.WRITE_DELAY) do Storage:Save() end end)
    CreateTraceback('Initalize', "Initalizing script..")
    local k = {}
    SetTask("MainTask", 'Level Farming')
    SetTask("SubTask", "Idle")
    ParsingTimes = 0
    FlowbrLastTaskName = nil
    function FlowbrSetTask(key, text) if text ~= nil then SetTask(key, text) end end
    function RefreshTasksData()
        if _G.Stop then return end
        if _G.PanicModeActive then return end
        for W, W in TasksOrder do
            local h = FunctionsHandler[W]
            if not h.Initalized then
                if not k[W] then
                    print("[ Debug ] Task", Name, "is not registered yet")
                    k[W] = true
                end
            else
                local k = h.Methods.Refresh
                local X = h.Methods.Start
                if k then
                    -- [FIX DISPLAY] snapshot of the status texts: a task that only "looked" (Refresh false / TaskYield)
                    -- must not leave its text behind (that caused MainTask/SubTask flickering between tasks).
                    local tkM, tkS = ScriptStorage.Task.MainTask, ScriptStorage.Task.SubTask
                    -- [FIXED] a task that errors no longer stops the rest of the loop
                    local okR, h = pcall(function() return k:Call(ParsingTimes < 100) end)
                    if not okR then print("[ Task error ]", W, h) end
                    ParsingTimes = ParsingTimes + 1
                    if okR and h and ParsingTimes > 100 then
                        CurrentTask = CurrentTask ~= W
                        CurrentTask = W
                        ScriptStorage.Interface.SetText('DebugLine', W)
                        -- [FIX DISPLAY] a different task is taking over: clear leftovers of the previous one
                        -- (the task's own SetTask calls override these right after)
                        if FlowbrLastTaskName ~= W then
                            if ScriptStorage.Task.MainTask == tkM then FlowbrSetTask("MainTask", tostring(W)) end
                            if ScriptStorage.Task.SubTask == tkS then FlowbrSetTask("SubTask", "Running") end
                        end
                        getgenv().TaskYield = false
                        local okS, errS = pcall(function() X:Call(h) end)
                        if not okS then
                            print("[ Task error ]", W, errS)
                            getgenv().TaskYield = true -- [FIX] an erroring task counts as "nothing to do" so the next task (LevelFarm) still runs
                        end
                        if getgenv().TaskYield then
                            getgenv().TaskYield = false -- task had nothing to do -> try the next one (LevelFarm...)
                            FlowbrSetTask("MainTask", tkM) -- [FIX DISPLAY] drop the texts of a task that did nothing
                            FlowbrSetTask("SubTask", tkS)
                        else
                            FlowbrLastTaskName = W
                            return
                        end
                    else
                        FlowbrSetTask("MainTask", tkM) -- [FIX DISPLAY] Refresh said "nothing to do": drop any text it set
                        FlowbrSetTask("SubTask", tkS)
                    end
                end
            end
        end
    end
    SetText('MainTextLabel', "Refreshing Player Items..")
    -- [FIX] each step is protected: one error here used to abort the whole script before the farm loop started
    pcall(AddPoint)
    pcall(function() J:RefreshQuest() end)
    pcall(RefreshInventory)
    pcall(function()
        Remotes.CommE.OnClientEvent:Connect(function(...)
            local J = {...}
            if type(J[1]) == "string" and string.find(J[1], 'Item') then pcall(RefreshInventory) end
        end)
    end)
    pcall(RefreshRace)
    a.LocalPlayer.Idled:Connect(function()
        Services.VirtualUser:CaptureController()
        Services.VirtualUser:ClickButton2(Vector2.new())
    end)
    SetText("MainTextLabel", 'Loaded In ' .. tick() - StartTick .. 'ms!')
    -- ============================================================
    -- [REPLACED] FPS BOOSTER: the old EnableFpsBoost() returned on its first line so nothing ever ran.
    -- Replaced with simple, working logic: gray out map + character, disable particles/trails, lower QualityLevel.
    -- DescendantAdded is tracked so newly spawned objects are optimised too.
    -- ============================================================
    local function GrayAndOptimize(object)
        if object:IsA("BasePart") or object:IsA("MeshPart") or object:IsA("UnionOperation") then
            object.Material = Enum.Material.Plastic
            object.Reflectance = 0
            if not object.Name:find("Handle") and not object.Name:find("Attachment") then
                pcall(function() object.Color = Color3.fromRGB(128, 128, 128) end)
            end
        end
        if object:IsA("Decal") or object:IsA("Texture") then
            object.Transparency = 1
        end
        if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Smoke") or object:IsA("Fire") then
            object.Enabled = false
        end
    end

    local function EnableFpsBoost()
        if not (Config.Configuration and Config.Configuration.FpsBoost) then return end
        task.spawn(function()
            pcall(function()
                Services.Lighting.GlobalShadows = false
                Services.Lighting.Brightness = 1
                Services.Lighting.Ambient = Color3.fromRGB(128, 128, 128)
                if settings and settings().Rendering then
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                end

                for _, descendant in ipairs(workspace:GetDescendants()) do
                    pcall(GrayAndOptimize, descendant)
                end

                local function onCharacterAdded(character)
                    if not character then return end
                    task.wait(0.5)
                    for _, descendant in ipairs(character:GetDescendants()) do
                        pcall(GrayAndOptimize, descendant)
                    end
                end
                if LocalPlayer and LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end
                LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
                Services.Players.PlayerAdded:Connect(function(player)
                    player.CharacterAdded:Connect(onCharacterAdded)
                end)

                -- [FIXED - LAG] A task.wait(0.1) inside the handler for EVERY object added to workspace caused heavy lag.
                -- Removed the wait and added early filtering of irrelevant classes (Script, Sound, Folder, Value...).
                local GRAYABLE_CLASSES = {
                    BasePart = true, MeshPart = true, UnionOperation = true,
                    Decal = true, Texture = true, ParticleEmitter = true,
                    Trail = true, Smoke = true, Fire = true,
                }
                workspace.DescendantAdded:Connect(function(descendant)
                    if not (Config.Configuration and Config.Configuration.FpsBoost) then return end
                    if not GRAYABLE_CLASSES[descendant.ClassName] then return end
                    pcall(GrayAndOptimize, descendant)
                end)

                print("[FPS Boost] Gray mode enabled + graphics lowered")
            end)
        end)
    end
    EnableFpsBoost()
    QueueList = {}
    function NearbyHopHandler()
        do return end
        if NearbyHopHandlerDebounce and os.time() - NearbyHopHandlerDebounce < 10 then return end
        NearbyHopHandlerDebounce = os.time()
        for J, J in a:GetPlayers() do
            local k = J and J.Character and J.Character:FindFirstChild("HumanoidRootPart") and J.Character.HumanoidRootPart.Position
            if k then
                local W = QueueList[J.Name]
                if not W then
                    QueueList[J.Name] = os.time()
                else
                    if os.time() - W > 30 then
                        if CaculateDistance(k) < 100 then
                            Hop('nearby plr')
                            -- [FIXED] Delay 5s -> 2s
                            task.wait(2)
                        else
                            QueueList[J.Name] = nil
                        end
                    end
                end
            end
        end
    end
    task.spawn(function()
        while task.wait() do
            if not _G.Stop then
                NearbyHopHandler()
                if LocalPlayer.Character:FindFirstChild('Humanoid') and LocalPlayer.Character.Humanoid.Sit then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                pcall(RefreshPlayerData)
                local J = os.time() - timeee
                local r = J + OldSessionTime
                if writefile then pcall(writefile, ".tdif-" .. game.Players.LocalPlayer.Name, tostring(r)) end
                if ScriptStorage.Interface then
                    SetText('LiveTime', "Total Elapsed Time: " .. DispTime(r, true) .. ' Elapsed Time: ' .. DispTime(J, true))
                end
                RefreshDebounce = os.time()
            end
        end
    end)
    AddPoint()
    Remotes.CommF_:InvokeServer("Cousin", 'Buy')
    task.spawn(function()
        task.wait(Config.Configuration.AutoHopDelay)
        if not Config.Configuration.AutoHop then Hop('Autohop') end
    end)

    -- ============================================================
    -- AUTO SEA 2 & 3 (SEPARATE THREADS)
    -- ============================================================
    task.spawn(function()
        while task.wait(0.5) do
            if Config.AutoSea2 then
                pcall(function()
                    if ScriptStorage.PlayerData.Level >= 700 and SeaIndex ~= 2 then
                        _G.SeaTransitionActive = true  -- [ADDED] synced with AutoSea3, prevents LevelFarm from fighting for the tween
                        local iceDoor = workspace.Map.Ice.Door
                        if iceDoor and iceDoor.CanCollide == true and iceDoor.Transparency == 0 then
                            Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")
                            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Key")
                            TweenController.Create(CFrame.new(1347.71, 37.38, -1325.65))
                            repeat task.wait() until not Config.AutoSea2 or (HumanoidRootPart and (HumanoidRootPart.Position - Vector3.new(1347.71, 37.38, -1325.65)).Magnitude < 5)
                        elseif iceDoor and iceDoor.CanCollide == false and iceDoor.Transparency == 1 then
                            if workspace.Enemies:FindFirstChild("Ice Admiral") then
                                CombatController.Attack("Ice Admiral")
                                repeat task.wait() until not Config.AutoSea2 or not workspace.Enemies:FindFirstChild("Ice Admiral") or workspace.Enemies["Ice Admiral"].Humanoid.Health <= 0
                                Remotes.CommF_:InvokeServer("TravelDressrosa")
                            else
                                TweenController.Create(CFrame.new(1347.71, 37.38, -1325.65))
                            end
                        else
                            Remotes.CommF_:InvokeServer("TravelDressrosa")
                        end
                        -- [ADDED] Check the real PlaceId to confirm Sea 2, 60s timeout to avoid hanging forever
                        local waitStart = tick()
                        repeat
                            task.wait(1)
                        until game.PlaceId == 4442272183 or game.PlaceId == 79091703265657
                           or SeaIndex == 2 or (tick() - waitStart) > 60
                        _G.SeaTransitionActive = false
                    end
                end)
            end
        end
    end)

    task.spawn(function()
        while task.wait(0.5) do
            if not Config.AutoSea3 then _G.SeaTransitionActive = false end
            if SeaIndex == 3 then _G.RipIndraBegun = false end
            if Config.AutoSea3 then
                pcall(function()
                    -- [FIXED] Added the missing 'SeaIndex ~= 3' check: the loop used to run forever even after reaching Sea 3.
                    if ScriptStorage.PlayerData.Level >= 1500 and SeaIndex ~= 3 then
                        -- [ADDED] Lock LevelFarm while the quest / travel to Sea 3 is in progress
                        _G.SeaTransitionActive = true

                        local bartiloProgress = Remotes.CommF_:InvokeServer("BartiloQuestProgress", "Bartilo")
                        if bartiloProgress == 0 then
                            local questText = game.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                            if string.find(questText, "Swan Pirates") and string.find(questText, "50") and game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible then
                                local swan = workspace.Enemies:FindFirstChild("Swan Pirate")
                                if swan and swan:FindFirstChild("Humanoid") and swan.Humanoid.Health > 0 then
                                    CombatController.Attack("Swan Pirate")
                                else
                                    TweenController.Create(CFrame.new(1057.93, 137.61, 1242.08))
                                end
                            else
                                TweenController.Create(CFrame.new(-456.29, 73.02, 299.90))
                            end
                        elseif bartiloProgress == 1 then
                            local jeremy = workspace.Enemies:FindFirstChild("Jeremy")
                            if jeremy and jeremy:FindFirstChild("Humanoid") and jeremy.Humanoid.Health > 0 then
                                CombatController.Attack("Jeremy")
                            else
                                TweenController.Create(CFrame.new(2099.88, 448.93, 648.00))
                            end
                        elseif bartiloProgress == 2 then
                            TweenController.Create(CFrame.new(-1836, 11, 1714))
                            if CaculateDistance(CFrame.new(-1836, 11, 1714)) < 5 then
                                local positions = {
                                    CFrame.new(-1850.49, 13.18, 1750.90),
                                    CFrame.new(-1858.87, 19.38, 1712.02),
                                    CFrame.new(-1803.94, 16.58, 1750.90),
                                    CFrame.new(-1858.56, 16.86, 1724.80),
                                    CFrame.new(-1869.54, 15.99, 1681.01),
                                    CFrame.new(-1800.10, 16.50, 1684.52),
                                    CFrame.new(-1819.26, 14.80, 1717.91),
                                    CFrame.new(-1813.52, 14.86, 1724.80)
                                }
                                for _, pos in ipairs(positions) do
                                    if not Config.AutoSea3 then break end
                                    HumanoidRootPart.CFrame = pos
                                    task.wait(0.1)
                                end
                            end
                        elseif bartiloProgress == 3 then
                            local unlockables = Remotes.CommF_:InvokeServer("GetUnlockables")
                            if unlockables.FlamingoAccess == nil then
                                local inventoryFruits = Remotes.CommF_:InvokeServer("getInventoryFruits")
                                local fruitStore = {}
                                for _, v in pairs(inventoryFruits) do
                                    for i1, v1 in pairs(v) do
                                        if i1 == "Name" then table.insert(fruitStore, v1) end
                                    end
                                end
                                local fruitPrices = Remotes.CommF_:InvokeServer("GetFruits")
                                local availableFruits = {}
                                for _, v in next, fruitPrices do
                                    if v.Price >= 1000000 then table.insert(availableFruits, v.Name) end
                                end
                                for _, fruitName in pairs(availableFruits) do
                                    for _, storeFruit in pairs(fruitStore) do
                                        if fruitName == storeFruit and unlockables.FlamingoAccess == nil then
                                            if not game.Players.LocalPlayer.Backpack:FindFirstChild(fruitName) then
                                                Remotes.CommF_:InvokeServer("LoadFruit", fruitName)
                                            else
                                                Remotes.CommF_:InvokeServer("TalkTrevor", "1")
                                                Remotes.CommF_:InvokeServer("TalkTrevor", "2")
                                                Remotes.CommF_:InvokeServer("TalkTrevor", "3")
                                            end
                                        end
                                    end
                                end
                                Remotes.CommF_:InvokeServer("TalkTrevor", "1")
                                Remotes.CommF_:InvokeServer("TalkTrevor", "2")
                                Remotes.CommF_:InvokeServer("TalkTrevor", "3")
                            else
                                local zCheck = Remotes.CommF_:InvokeServer("ZQuestProgress", "Check")
                                if zCheck == 0 then
                                    local rip_indra = workspace.Enemies:FindFirstChild("rip_indra")
                                    if rip_indra and rip_indra:FindFirstChild("Humanoid") and rip_indra.Humanoid.Health > 0 then
                                        -- [FIXED] Attack and then WAIT for it to actually die (same pattern as Ice Admiral in AutoSea2)
                                        CombatController.Attack("rip_indra")
                                        repeat
                                            task.wait()
                                            CombatController.Attack("rip_indra")
                                        until not Config.AutoSea3
                                           or not rip_indra.Parent
                                           or rip_indra.Humanoid.Health <= 0

                                        -- [ADDED] Right after confirming death -> re-check and travel immediately, without waiting for the next 0.5s poll
                                        task.wait(1)
                                        local zAfterKill = Remotes.CommF_:InvokeServer("ZQuestProgress", "Check")
                                        if zAfterKill == 1 or zAfterKill == 2 then
                                            Remotes.CommF_:InvokeServer("TravelZou")
                                            local waitStart2 = tick()
                                            repeat
                                                task.wait(1)
                                            until game.PlaceId == 7449423635 or game.PlaceId == 100117331123089
                                               or SeaIndex == 3 or (tick() - waitStart2) > 60
                                        end

                                    elseif not rip_indra then
                                        -- [FIXED] Only call 'Begin' when rip_indra has NEVER spawned (it used to re-call Begin on a fresh corpse, resetting the quest).
                                        if not _G.RipIndraBegun then
                                            Remotes.CommF_:InvokeServer("ZQuestProgress", "Begin")
                                            _G.RipIndraBegun = true
                                        end
                                        TweenController.Create(CFrame.new(2288.80, 15.19, 863.03))
                                    else
                                        -- rip_indra exists but Health <= 0 (corpse not cleaned up yet) -> do NOT call Begin, wait for the next poll to re-read zCheck
                                        task.wait(1)
                                    end
                                elseif zCheck == 1 then
                                    -- [ADDED] This is the REAL teleport to another place (Sea 3 has a different PlaceId). After calling it, wait for game.PlaceId to change
                                    -- before continuing, otherwise code below keeps using the destroyed old character/workspace.
                                    Remotes.CommF_:InvokeServer("TravelZou")
                                    local waitStart = tick()
                                    repeat
                                        task.wait(1)
                                    until game.PlaceId == 7449423635 or game.PlaceId == 100117331123089
                                       or SeaIndex == 3 or (tick() - waitStart) > 60
                                else
                                    local donSwan = workspace.Enemies:FindFirstChild("Don Swan")
                                    if donSwan and donSwan:FindFirstChild("Humanoid") and donSwan.Humanoid.Health > 0 then
                                        CombatController.Attack("Don Swan")
                                    else
                                        TweenController.Create(CFrame.new(2288.80, 15.19, 863.03))
                                    end
                                end
                            end
                        end
                    else
                        -- [ADDED] Level not high enough OR already in Sea 3 -> release LevelFarm lock
                        _G.SeaTransitionActive = false
                    end
                end)
            end
        end
    end)

    -- ============================================================
    -- ANTI LAG / LOW GRAPHICS
    -- ============================================================
    if Config.Configuration and Config.Configuration.LowGraphics ~= false then
        task.spawn(function()
            pcall(function()
                local lighting = game:GetService("Lighting")
                lighting.GlobalShadows = false
                lighting.FogEnd = 9e9
                lighting.Brightness = 0
                for _, v in pairs(lighting:GetDescendants()) do
                    if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                        v.Enabled = false
                    end
                end
                local terrain = workspace.Terrain
                if terrain then
                    terrain.WaterWaveSize = 0
                    terrain.WaterWaveSpeed = 0
                    terrain.WaterReflectance = 0
                    terrain.WaterTransparency = 0
                end
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                        obj.Lifetime = NumberRange.new(0)
                    elseif obj:IsA("Fire") or obj:IsA("SpotLight") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                        obj.Enabled = false
                    end
                end
                if settings and settings().Rendering then
                    settings().Rendering.QualityLevel = "Level01"
                    settings().Rendering.GraphicsMode = "NoGraphics"
                end
                print("[Anti Lag] Graphics optimisation applied!")
            end)
        end)
    end

    -- ============================================================
    -- MAIN LOOP
    -- ============================================================
    while task.wait() do
        if Config.Configuration.HopWhenIdle and LastIdling and os.time() - LastIdling > 300.0 then
            SetTask('MainTask', "Rejoining due idle in 10 min!")
            task.wait(1)
            LastIdling = os.time() -- [FIX] reset so it does not retrigger every frame
            task.spawn(function() pcall(SafeRejoin) end)
        end
        if not AnimationDelay or os.time() - AnimationDelay > 60 then
            AnimationDelay = os.time()
        end
        if ScriptStorage.PlayerData.Level and ScriptStorage.PlayerData.Level > 0 then
            local J, r = xpcall(RefreshTasksData, debug.traceback)
            if not J then 
                print('[ Error ]', r)
                task.wait(1)
            end
        else
            task.wait(1)
            pcall(RefreshPlayerData)
        end
    end
end

--============================================================
-- [EXTRAS] NO ANIMATION + AUTO REDEEM CODES + AUTO RANDOM FRUIT (GACHA)
-- Options (edit / disable as you like):
Config.Extras = {
    NoAnimation      = true,   -- disables character animations
    AutoRedeemCodes  = true,   -- redeems all codes at start
    AutoGachaFruit   = true,   -- rolls the Gacha (Random Fruit) automatically
    GachaInterval    = 5,      -- seconds between gacha checks
    AutoStoreAfterRoll = true, -- stores the fruit automatically after each successful roll
}
--============================================================
task.spawn(function()
    local Players = game:GetService("Players")
    local LP = Players.LocalPlayer

    -- NO ANIMATION
    local function disableAnimations(character)
        if not Config.Extras.NoAnimation or not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end
        end
        local animate = character:FindFirstChild("Animate")
        if animate then pcall(function() animate.Disabled = true end) end
    end
    if LP.Character then task.spawn(disableAnimations, LP.Character) end
    LP.CharacterAdded:Connect(function(char) task.wait(0.5); disableAnimations(char) end)
    task.spawn(function()
        while task.wait(5) do pcall(disableAnimations, LP.Character) end
    end)

    -- AUTO REDEEM CODES
    task.spawn(function()
        if not Config.Extras.AutoRedeemCodes then return end
        local REDEEM_CODES = {
            "fudd10", "fudd10_V2", "Chandler", "BIGNEWS", "KITT_RESET",
            "Sub2UncleKizaru", "SUB2GAMERROBOT_RESET1", "Sub2Fer999", "Enyu_is_Pro",
            "JCWK", "StarcodeHEO", "MagicBUS", "KittGaming", "Sub2CaptainMaui",
            "Sub2OfficialNoobie", "TheGreatAce", "Sub2NoobMaster123", "Sub2Daigrock",
            "Axiore", "StrawHatMaine", "TantaiGaming", "Bluxxy", "SUB2GAMERROBOT_EXP1",
        }
        local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
        local redeem = remotes:FindFirstChild("Redeem") or remotes:WaitForChild("Redeem", 10)
        local commF = remotes:FindFirstChild("CommF_")
        for _, code in ipairs(REDEEM_CODES) do
            pcall(function()
                if redeem then redeem:InvokeServer(code)
                elseif commF then commF:InvokeServer("Redeem", code) end
            end)
            task.wait(1)
        end
    end)

    -- AUTO RANDOM FRUIT (GACHA - Zioles)
    getgenv().AutoRandomFruit = Config.Extras.AutoGachaFruit

    local GachaRF
    local function getGachaRF()
        if GachaRF then return GachaRF end
        local ok = pcall(function()
            GachaRF = game:GetService("ReplicatedStorage").Modules.Net:WaitForChild("RF/GachaNetworkRF", 10)
        end)
        return ok and GachaRF or nil
    end

    -- [FIXED] same calls as the AGR script that works (taken from the real log):
    -- Check sends SpokeNPC, Purchase is sent only with Context + BoxName.
    local function GachaCall(ctx)
        local rf = getGachaRF()
        if not rf then return false, "GachaNetworkRF not found" end
        local ok, result = pcall(function()
            if ctx == "Purchase" then
                return rf:InvokeServer({ Context = "Purchase", BoxName = "ZiolesGacha" })
            end
            return rf:InvokeServer({ SpokeNPC = "Blox Fruit Gacha", Context = ctx, BoxName = "ZiolesGacha" })
        end)
        if not ok then return false, tostring(result) end
        return true, result
    end

    -- [ADDED] decides if a roll can be bought, based on the Check response (same rules as the AGR script)
    local function GachaCanRoll(res)
        if type(res) ~= "table" then return false, "no Check response" end
        if res.RequirementsMet ~= true then return false, res.ErrorMessage or "requirements not met" end
        if res.Level and res.Level.RequirementMet == false then return false, "level too low" end
        if res.Cooldown and res.Cooldown.RequirementMet == false then return false, "cooldown" end
        local price = res.Price
        if price and price.RequirementMet == false then return false, price.ErrorMessage or "no money" end
        return true
    end

    -- [ADDED] stores every fruit in Backpack/Character (except the ones the script is using)
    local function StoreFruitsAfterRoll()
        local lp = game:GetService("Players").LocalPlayer
        local ignore = (type(ScriptStorage) == "table" and ScriptStorage.IgnoreStoreFruits) or {}
        local commF = game:GetService("ReplicatedStorage").Remotes:WaitForChild("CommF_", 10)
        if not commF then return 0 end
        local count = 0
        for _, container in ipairs({ lp.Backpack, lp.Character }) do
            if container then
                for _, v in ipairs(container:GetChildren()) do
                    if v:IsA("Tool") and v.Name:find("Fruit") then
                        local ori = v:GetAttribute("OriginalName") or v.Name
                        if not table.find(ignore, v.Name) and not table.find(ignore, ori) then
                            local ok = pcall(function()
                                commF:InvokeServer("StoreFruit", ori, v)
                            end)
                            if ok then count = count + 1 end
                        end
                    end
                end
            end
        end
        return count
    end

    task.spawn(function()
        while task.wait(Config.Extras.GachaInterval or 5) do
            if getgenv().AutoRandomFruit and Config.Extras.AutoGachaFruit then
                local ok, result = GachaCall("Check")
                local can, why = false, nil
                if ok then can, why = GachaCanRoll(result) else why = tostring(result) end
                if not can and why ~= GachaLastWhy then GachaLastWhy = why; print("[Gacha] Not rolling: " .. tostring(why)) end
                if can then
                    local ok2, success = GachaCall("Purchase")
                    if ok2 and success == true then
                        print("[Gacha] Rolled successfully!")
                        if Config.Extras.AutoStoreAfterRoll then
                            task.wait(2) -- give the fruit time to reach the backpack
                            print("[Gacha] Stored fruits: " .. tostring(StoreFruitsAfterRoll()))
                        end
                    else
                        print("[Gacha] Failed: " .. tostring(success))
                    end
                end
            end
        end
    end)

    getgenv().HexHubOficial = {
        Start = function() getgenv().AutoRandomFruit = true; Config.Extras.AutoGachaFruit = true end,
        Stop  = function() getgenv().AutoRandomFruit = false; Config.Extras.AutoGachaFruit = false end,
        Spin  = function() return GachaCall("Purchase") end,
        Check = function() return GachaCall("Check") end,
    }
end)

-- [FIX] hoangtuveu() has an infinite main loop, so it must be called AFTER the extras/gacha threads are spawned
-- [FIX v10] errors are now shown on the status UI and in the console (before, the script died silently on "Loading...")
local __ok, __err = xpcall(hoangtuveu, function(e) return tostring(e) .. "\n" .. debug.traceback() end)
if not __ok then
    warn("[KAITUN ERROR] " .. tostring(__err))
    pcall(function() ScriptStorage.Interface.SetText('MainTextLabel', 'ERRO: ' .. tostring(__err):sub(1, 120)) end)
end

--============================================================
-- [VOID ATTACK] ATAQUE ENVIADO PELO USUARIO
--============================================================
do
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RS_Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RE_ShootGunEvent = Net:WaitForChild("RE/ShootGunEvent")
local RE_RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RE_RegisterHit = Net:WaitForChild("RE/RegisterHit")
local GunValidator = RS_Remotes:WaitForChild("Validator2")

local SUCCESS_SHOOT, SHOOT_FUNCTION = pcall(function()
    return getupvalue(require(ReplicatedStorage.Controllers.CombatController).Attack, 9)
end)

local capturedChild, RemoteId = nil, nil

local function tryCapture(parent)
    if not parent then return end
    for _, item in ipairs(parent:GetChildren()) do
        if item:IsA("RemoteEvent") then
            local attr = item:GetAttribute("Id")
            if attr then
                RemoteId, capturedChild = attr, item
                return true
            end
        end
    end
    return false
end

for _, name in ipairs({"Util","Common","Remotes","Assets","FX"}) do
    local c = ReplicatedStorage:FindFirstChild(name)
    if c then
        tryCapture(c)
        c.ChildAdded:Connect(function(ch)
            if ch:IsA("RemoteEvent") and ch:GetAttribute("Id") then
                RemoteId, capturedChild = ch:GetAttribute("Id"), ch
            end
        end)
    end
end

getgenv().VOidAttack = getgenv().VOidAttack or {}
local CFG = getgenv().VOidAttack

CFG.Enabled          = CFG.Enabled          == true  -- [DISABLED] off by default; set getgenv().VOidAttack.Enabled = true to use it
CFG.Range            = CFG.Range            or 90
CFG.AttackPlayers    = CFG.AttackPlayers    ~= false
CFG.AttackMobs       = CFG.AttackMobs       ~= false
CFG.MultiHitCount    = CFG.MultiHitCount    or 3
CFG.MultiHitDelay    = CFG.MultiHitDelay    or 0.02
CFG.LoopDelay        = CFG.LoopDelay        or 0.01
CFG.MeleeDelay       = CFG.MeleeDelay       or 0.12
CFG.UseObfuscated    = CFG.UseObfuscated    ~= false
CFG.VisualActivate   = CFG.VisualActivate   ~= false
CFG.Paralyze         = CFG.Paralyze         ~= false
CFG.ParalyzeTick     = CFG.ParalyzeTick     or 0.01
CFG.ResetCooldown    = CFG.ResetCooldown    ~= false

CFG.HitboxLimbs = CFG.HitboxLimbs or {
    "RightLowerArm","RightUpperArm","LeftLowerArm","LeftUpperArm",
    "RightHand","LeftHand","RightLowerLeg","LeftLowerLeg",
    "RightUpperLeg","LeftUpperLeg","RightFoot","LeftFoot",
    "Head","Torso","HumanoidRootPart"
}

local function GetValidator2()
    if not SUCCESS_SHOOT or not SHOOT_FUNCTION then
        return math.random(1, 99999999), 1
    end

    local v53 = getupvalue(SHOOT_FUNCTION, 13)
    local v54 = getupvalue(SHOOT_FUNCTION, 14)
    local v55 = getupvalue(SHOOT_FUNCTION, 15)
    local v56 = getupvalue(SHOOT_FUNCTION, 16)
    local v57 = getupvalue(SHOOT_FUNCTION, 17)
    local v58 = getupvalue(SHOOT_FUNCTION, 18)
    local v59 = getupvalue(SHOOT_FUNCTION, 19)

    local v93 = v53 * v54
    local v96 = (v55 * v54 + v53 * v56) % v57
    v96 = (v96 * v57 + v93) % v58
    v55 = math.floor(v96 / v57)
    v53 = v96 - v55 * v57
    v59 = v59 + 1

    setupvalue(SHOOT_FUNCTION, 13, v53)
    setupvalue(SHOOT_FUNCTION, 15, v55)
    setupvalue(SHOOT_FUNCTION, 19, v59)

    return math.floor(v96 / v58 * 16777215), v59
end

local function isAlive(m)
    local h = m and m:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function getHitbox(m)
    for _ = 1, 6 do
        local name = CFG.HitboxLimbs[math.random(#CFG.HitboxLimbs)]
        local part = m:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
    end
    return m:FindFirstChild("HumanoidRootPart")
end

local function collectTargets(char)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return {} end
    local pos = root.Position
    local list = {}

    local function scan(folder)
        if not folder then return end
        for _, e in ipairs(folder:GetChildren()) do
            if e ~= char and isAlive(e) then
                local rp = e:FindFirstChild("HumanoidRootPart")
                if rp and (rp.Position - pos).Magnitude <= CFG.Range then
                    list[#list + 1] = e
                end
            end
        end
    end

    if CFG.AttackMobs    then scan(workspace:FindFirstChild("Enemies"))    end
    if CFG.AttackPlayers then scan(workspace:FindFirstChild("Characters")) end
    return list
end

local function buildConfig(targets)
    local cfg = {}
    for _, e in ipairs(targets) do
        local part = getHitbox(e)
        if part then cfg[#cfg + 1] = {e, part} end
    end
    return cfg
end

local function fireStandard(targets)
    local cfg = buildConfig(targets)
    if #cfg == 0 then return end

    local primary = cfg[1][1]:FindFirstChild("Head")
                    or cfg[1][1]:FindFirstChild("HumanoidRootPart")
    if not primary then return end

    RE_RegisterAttack:FireServer(0)
    RE_RegisterHit:FireServer(primary, cfg)
end

local function fireObfuscated(targets)
    if not (CFG.UseObfuscated and capturedChild and RemoteId) then return end
    local cfg = buildConfig(targets)
    if #cfg == 0 then return end

    local primary = cfg[1][1]:FindFirstChild("Head")
                    or cfg[1][1]:FindFirstChild("HumanoidRootPart")
    if not primary then return end

    pcall(function()
        RE_RegisterAttack:FireServer()
        local key1 = string.gsub("RE/RegisterHit", ".", function(ch)
            return string.char(bit32.bxor(string.byte(ch),
                math.floor(workspace:GetServerTimeNow() / 10 % 10) + 1))
        end)
        local seed = Net.seed:InvokeServer() * 2
        local key2 = bit32.bxor(RemoteId + 909090, seed)
        cloneref(capturedChild):FireServer(key1, key2, primary, cfg)
    end)
end

local function clearAllCooldowns(tool)
    if not (CFG.ResetCooldown and tool) then return end
    pcall(function()
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("NumberValue") then
                local n = v.Name:lower()
                if n:find("cooldown") or n:find("cd") or n:find("reload") then
                    v.Value = 0
                end
            end
        end
    end)
end

local paralyzedMobs = {}

local function paralyzeMob(mob)
    if not CFG.Paralyze or not mob or not mob.Parent then return end

    local hrp = mob:FindFirstChild("HumanoidRootPart")
    local hum = mob:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local stored = paralyzedMobs[mob]
    local lockedPos = stored and stored.pos or hrp.Position
    if not stored then
        paralyzedMobs[mob] = { pos = lockedPos }
    end

    pcall(function()
        if setnetworkowner then setnetworkowner(mob, false) end
    end)

    pcall(function()
        hrp.Velocity = Vector3.zero
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(lockedPos, lockedPos + hrp.CFrame.LookVector)
    end)

    pcall(function()
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hum.JumpHeight = 0
        hum.AutoRotate = false
    end)

    pcall(function()
        local bp = hrp:FindFirstChild("VOidLock")
        if not bp then
            bp = Instance.new("BodyPosition")
            bp.Name = "VOidLock"
            bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bp.P = 200000
            bp.D = 1000
            bp.Position = lockedPos
            bp.Parent = hrp
        else
            bp.Position = lockedPos
        end

        local bg = hrp:FindFirstChild("VOidGyro")
        if not bg then
            bg = Instance.new("BodyGyro")
            bg.Name = "VOidGyro"
            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bg.P = 200000
            bg.D = 1000
            bg.CFrame = CFrame.new(lockedPos, lockedPos + hrp.CFrame.LookVector)
            bg.Parent = hrp
        else
            bg.CFrame = CFrame.new(lockedPos, lockedPos + hrp.CFrame.LookVector)
        end
    end)
end

local function clearParalyze(mob)
    if not mob then return end
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function()
        if hrp:FindFirstChild("VOidLock") then hrp.VOidLock:Destroy() end
        if hrp:FindFirstChild("VOidGyro") then hrp.VOidGyro:Destroy() end
    end)
    paralyzedMobs[mob] = nil
end

local function attackMelee(char, tool, targets)
    for _, t in ipairs(targets) do paralyzeMob(t) end

    for i = 1, CFG.MultiHitCount do
        task.spawn(function()
            fireStandard(targets)
            fireObfuscated(targets)
        end)
        if i < CFG.MultiHitCount then task.wait(CFG.MultiHitDelay) end
    end

    if CFG.VisualActivate and tool then
        pcall(function() tool:Activate() end)
    end
end

local function attackFruit(char, tool, targets)
    for _, t in ipairs(targets) do paralyzeMob(t) end

    local remote = tool:FindFirstChild("LeftClickRemote")
    if not remote then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local trp  = targets[1]:FindFirstChild("HumanoidRootPart")
    if not (root and trp) then return end
    local dir = (trp.Position - root.Position).Unit
    pcall(function() remote:FireServer(dir, 1) end)
end

local function attackGun(char, tool, targets)
    for _, t in ipairs(targets) do paralyzeMob(t) end

    local hrp = targets[1]:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    clearAllCooldowns(tool)

    pcall(function()
        tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)
    end)

    pcall(function()
        GunValidator:FireServer(GetValidator2())
    end)

    pcall(function()
        RE_ShootGunEvent:FireServer(hrp.Position, { hrp })
    end)
end

local lastMelee = 0

task.spawn(function()
    while task.wait(CFG.LoopDelay) do
        if not CFG.Enabled then continue end

        local char = LocalPlayer.Character
        if not char or not isAlive(char) then continue end

        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then continue end

        local tip = tool.ToolTip
        local now = os.clock()

        if tip == "Melee" or tip == "Sword" then
            if now - lastMelee >= CFG.MeleeDelay then
                local targets = collectTargets(char)
                if #targets > 0 then
                    lastMelee = now
                    pcall(attackMelee, char, tool, targets)
                end
            end

        elseif tip == "Blox Fruit" then
            local targets = collectTargets(char)
            if #targets > 0 then pcall(attackFruit, char, tool, targets) end

        elseif tip == "Gun" then
            local targets = collectTargets(char)
            if #targets > 0 then pcall(attackGun, char, tool, targets) end
        end
    end
end)

task.spawn(function()
    while task.wait(CFG.ParalyzeTick) do
        if not CFG.Enabled or not CFG.Paralyze then continue end

        local char = LocalPlayer.Character
        if not char then continue end

        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then continue end

        local tip = tool.ToolTip
        if tip ~= "Melee" and tip ~= "Sword" and tip ~= "Gun" and tip ~= "Blox Fruit" then
            continue
        end

        local targets = collectTargets(char)
        for _, t in ipairs(targets) do paralyzeMob(t) end

        for mob in pairs(paralyzedMobs) do
            if not mob.Parent or not isAlive(mob) then
                clearParalyze(mob)
            end
        end
    end
end)

getgenv().VOidAttack = CFG

end
