--[[
    FLOWBR | KAITUN  (single script, 3 modes)

    Set BEFORE the loadstring (see the *_config_template files):
        getgenv().mode   = "farm" | "leviathan" | "weapon"
        getgenv().Config = { ... }   -- each mode has its own config, webhook included

    farm      -> Blox Fruits kaitun (Godhuman, CDK, Skull Guitar, Mirror/Valk, Pull Lever, ...) + account dashboard
    leviathan -> Leviathan / sea-events hunter + its own UI
    weapon    -> weapon collector kaitun + its own UI
]]
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local __Mode = string.lower(tostring(getgenv().mode or "farm"))
local __UserConfig = type(getgenv().Config) == "table" and getgenv().Config or {}

local function RunFarm(...)
-- FLOWBR | KAITUN (farm mode). Config + webhook come from OUTSIDE the script (getgenv().Config set before the loadstring).
local UserConfig = ...

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
        ToggleImage = "130143515695779",        -- icon of the open/close button (empty = letter F)
        BackgroundImage = "134924508387467",    -- UI background image (asset id)
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


-- ============================================================================
-- USER CONFIG  (comes from OUTSIDE the script: getgenv().Config set before the loadstring)
-- Everything the user can toggle is read here and written into the internal Config above.
-- ============================================================================
do
    local U = (type(UserConfig) == "table" and UserConfig)
        or (type(getgenv) == "function" and type(getgenv().Config) == "table" and getgenv().Config)
        or {}
    local function B(v, d) if v == nil then return d end return v and true or false end
    local function T(v) return type(v) == "table" and v or {} end
    local C = Config
    local Setup, O = T(U.Setup), T(U.Others)

    -- general
    C.Team = (U.Team == "Marines" or U.Team == "Pirates") and U.Team or C.Team
    C.FPS = tonumber(U.FPS) or 40
    pcall(function() if setfpscap then setfpscap(C.FPS) end end)
    C.Configuration.FpsBoost    = B(U.BoostFPS, B(Setup.BoostFPS, false))
    C.Configuration.LowGraphics = B(O.LowGraphics, C.Configuration.FpsBoost)
    C.Configuration.blackscreen = B(U.BlackScreen, B(Setup.BlackScreen, false))
    C.Configuration.HopWhenIdle = B(O.HopWhenIdle, true)
    C.Configuration.AutoHop     = B(O.AutoHop, false)
    C.Configuration.AutoHopDelay = tonumber(O.AutoHopDelay) or C.Configuration.AutoHopDelay

    -- main items (top level of the config)
    C.Items.AutoFullyMelees  = B(U.GodHuman, true)      -- Godhuman (+ every melee needed for it)
    C.Items.MM               = B(U.MM, true)            -- Mirror Fractal + Valkyrie Helm
    C.Items.CursedDualKatana = B(U.CDK, true)
    C.Items.SoulGuitar       = B(U.SkullGuitar, true)
    C.Items.AutoRaceV3       = B(U.RaceV3, false)
    C.Items.PullLever        = B(U.PullLever, true)
    C.Items.SharkAnchor      = B(U.SharkAnchor, true)   -- reserved: not implemented in any of the provided scripts

    -- Others = everything else the script gets
    C.Items.Saber           = B(O.Saber, true)
    C.Items.RaceV2          = B(O.RaceV2, true)
    C.Items.RerollRace      = B(O.RerollRace, false)    -- re-rolls the race until Human/Mink (needs 3000 fragments each)
    C.Items.AutoRandomFruit = B(O.AutoRandomFruit, true)
    C.Items.Trevor          = B(O.Trevor, true)
    C.Items.ExpRedeem       = B(O.ExpRedeem, true)
    for k, v in pairs(T(U.Items)) do C.Items[k] = v end -- advanced: Items = { Name = true/false } overrides anything above

    C.Melee.AutoBuy = B(O.AutoBuyMelees, true)
    C.Melee.RaidAtV1Mastery = tonumber(O.RaidAtV1Mastery) or C.Melee.RaidAtV1Mastery
    C.Melee.GodhumanAtV2Mastery = tonumber(O.GodhumanAtV2Mastery) or C.Melee.GodhumanAtV2Mastery
    C.AutoKen = B(O.AutoKen, true)
    C.BringMobs = B(O.BringMobs, true)
    C.AutoSea2 = B(O.AutoSea2, true)
    C.AutoSea3 = B(O.AutoSea3, true)
    C.Settings.StayInSea2UntilHaveDarkFragments = B(O.StayInSea2UntilHaveDarkFragments, true)
    C.AutoRaidIce_TargetFragments = tonumber(O.AutoRaidIceTargetFragments) or C.AutoRaidIce_TargetFragments
    C.Fragments = { Max = tonumber(O.MaxFragments) or 10000 }

    for k in pairs(C.Sword) do C.Sword[k] = B(T(O.Swords)[k], true) end
    for k in pairs(C.BossWeapons) do C.BossWeapons[k] = B(T(O.BossWeapons)[k], true) end
    C.BossWeapons["Tyrant of the Skies"] = B(T(O.BossWeapons)["Tyrant of the Skies"], true)

    if type(O.PanicMode) == "boolean" then C.PanicMode.Enabled = O.PanicMode
    elseif type(O.PanicMode) == "table" then
        for k, v in pairs(O.PanicMode) do if C.PanicMode[k] ~= nil then C.PanicMode[k] = v end end
    end

    -- server hop options (use the hop API)
    C.Hop = {
        ["Hop RipIndra For Tushita"]            = B(O.HopRipIndraForTushita, false),
        ["Hop For Dough King ( Mirror Fractal )"] = B(O.HopDoughKingForMirror, false),
        ["Hop For Rip Indra ( Valkyrie Helm )"]   = B(O.HopRipIndraForValkyrie, false),
    }

    -- tasks (the script's task list: a task set to false is removed from the order)
    C.Tasks = {
        SpecialBossesTask = B(O.SpecialBosses, true),
        SwordBossTask     = B(O.SwordBosses, true),
        BossesTask        = B(O.Bosses, true),
        RaidController    = B(O.Raids, true),
        AutoRaidIce       = B(O.AutoRaidIce, true),
        CakePrinceTask    = B(O.CakePrince, true),
        Tushita           = B(O.Tushita, true),
        Yama              = B(O.Yama, true),
        ColosseumPuzzle   = B(O.ColosseumPuzzle, true),
        SecondSeaPuzzle   = B(O.SecondSeaPuzzle, true),
        ThirdSeaPuzzle    = B(O.ThirdSeaPuzzle, true),
        PirateRaid        = B(O.PirateRaid, true),
        CollectDrops      = B(O.CollectDrops, true),
        UtillyItemsActivitation = B(O.UtilityItems, true),
    }

    -- extras
    C.ExtrasUser = {
        NoAnimation        = B(O.NoAnimation, true),
        AutoRedeemCodes    = B(O.AutoRedeemCodes, true),
        AutoGachaFruit     = B(O.AutoRandomFruit, true),
        GachaInterval      = tonumber(O.GachaInterval) or 5,
        AutoStoreAfterRoll = B(O.AutoStoreAfterRoll, true),
    }

    -- webhook (comes from the loadstring)
    local W = T(U.WebHook)
    local WH = C.Dashboard.Webhook
    if type(W.Url) == "string" and W.Url ~= "" then WH.Url = W.Url end
    if type(U.Webhook) == "string" and U.Webhook ~= "" then WH.Url = U.Webhook end
    WH.Enabled = B(W.Enable, WH.Url ~= "") and WH.Url ~= ""
    WH.Interval = tonumber(W.Interval) or WH.Interval
    WH.Persist = B(W.Persist, WH.Persist)

    -- dashboard look (optional)
    local UI = T(U.UI)
    if type(UI.Name) == "string" and UI.Name ~= "" then C.Dashboard.UIName = UI.Name end
    if UI.ToggleImage ~= nil then C.Dashboard.ToggleImage = tostring(UI.ToggleImage) end
    if UI.BackgroundImage ~= nil then C.Dashboard.BackgroundImage = tostring(UI.BackgroundImage) end
    if tonumber(UI.Scale) then C.Dashboard.Scale = tonumber(UI.Scale) end
end

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
    -- the panel only shows what the user config actually goes for
    do
        local gate = {
            ["Godhuman"] = Config.Items.AutoFullyMelees, ["Cursed Dual Katana"] = Config.Items.CursedDualKatana,
            ["Valkyrie Helm"] = Config.Items.MM, ["Mirror Fractal"] = Config.Items.MM,
            ["Skull Guitar"] = Config.Items.SoulGuitar, ["Pull Lever"] = Config.Items.PullLever,
        }
        local f = {}
        for _, n in ipairs(UNLOCK_ORDER) do if gate[n] ~= false then f[#f + 1] = n end end
        if #f > 0 then UNLOCK_ORDER = f end
    end

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
    local PINK      = Color3.fromRGB(185, 28, 45)    -- dark red (titles)
    local PINK_DIM  = Color3.fromRGB(150, 24, 38)    -- dark red (labels)
    local RED       = Color3.fromRGB(170, 28, 44)    -- dark red
    local RED_LIGHT = Color3.fromRGB(205, 45, 60)
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
        -- [NEW] ported from deobf: Mirror Fractal / Valkyrie Helm, Pull Lever (Race V4 door) and the X2 EXP codes
        "MirrorAndValk", "PullLever", "ExpRedeem",
        "LevelFarm", "Tushita", 'Yama',
        "Saber", "CursedDualKatana", "SoulGuitar", "EvoRace", "RaceAwakening",
        'Trevor', "UtillyItemsActivitation", 'ColosseumPuzzle', "ThirdSeaPuzzle", "PirateRaid", "SecondSeaPuzzle", "CollectDrops"}
    -- tasks switched off in the user config are removed from the order
    do
        local filtered = {}
        for _, name in ipairs(TasksOrder) do
            if not (Config.Tasks and Config.Tasks[name] == false) then filtered[#filtered + 1] = name end
        end
        TasksOrder = filtered
    end
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
    BossesOrder = {"Awakened Ice Admiral", "Tide Keeper", 'Deandre', "Urban", "Diablo", 'Soul Reaper', "Tyrant of the Skies"}
    BossesOrderLevel = {['Awakened Ice Admiral'] = 700, ['Tide Keeper'] = 700, ['Deandre'] = 1500, ['Urban'] = 1500, ['Diablo'] = 1500, ['Soul Reaper'] = 1500, ['Tyrant of the Skies'] = 1550}
    BossesOrderWL = {["Deandre"] = 1500, ["Urban"] = 1500, ["Diablo"] = 1500, ['Don Swan'] = 1100, ["Awakened Ice Admiral"] = 700, ['Tide Keeper'] = 700, ['Tyrant of the Skies'] = 1550}
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
            if (b == 'Deandre' or b == "Urban" or b == "Diablo") and (os.time() - (LastFire12 or 0)) > 180 then
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
    FunctionsHandler.PullLever:Register()
    FunctionsHandler.MirrorAndValk:Register()
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
        -- [NEW - deobf] optional race re-roll until Human / Mink (only while the race is still V1)
        if Config.Items.RerollRace then
            local okR, raceName = pcall(function() return LocalPlayer.Data.Race.Value end)
            if okR and raceName ~= "Mink" and raceName ~= "Rabbit" and raceName ~= "Human"
               and (ScriptStorage.PlayerData.RaceLevel or 1) == 1 and (ScriptStorage.PlayerData.Fragments or 0) >= 3000 then
                return "Reroll"
            end
        end
        if not Config.Items.RaceV2 then return end
        if SeaIndex ~= 2 then return end
        if getsenv(game.ReplicatedStorage.GuideModule)._G.ServerData.ExpBoost ~= 0 or ScriptStorage.PlayerData.Level < 900 or ScriptStorage.PlayerData.Beli < 1000000 or ScriptStorage.PlayerData.RaceLevel ~= 1 then return end
        return true
    end)

    FunctionsHandler.EvoRace:RegisterMethod('Start', function(job)
        if job == "Reroll" then
            SetTask("MainTask", "Auto Race - Rerolling Race")
            Remotes.CommF_:InvokeServer("BlackbeardReward", "Reroll", "2")
            task.wait(1)
            pcall(RefreshRace)
            return
        end
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
        if lv >= MaxLevel then
            if fr > ((Config.Fragments and Config.Fragments.Max) or 10000) then return nil end
            -- [NEW - deobf] at max level: Godhuman first, then Mirror Fractal + Valkyrie Helm, only then farm raids
            if Config.Items.AutoFullyMelees and not (ScriptStorage.Melees.Godhuman or ScriptStorage.Backpack.Godhuman) then return nil end
            if Config.Items.MM and (not ScriptStorage.Backpack["Valkyrie Helm"] or not ScriptStorage.Backpack["Mirror Fractal"]) then return nil end
        end
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

    -- ============================================================
    -- [NEW - ported from deobf] EXP REDEEM / PULL LEVER / MIRROR FRACTAL + VALKYRIE HELM
    -- ============================================================
    local function _ExpBoost()
        local ok, v = pcall(function() return getsenv(game.ReplicatedStorage.GuideModule)._G.ServerData.ExpBoost end)
        return ok and v or nil
    end

    FunctionsHandler.ExpRedeem:RegisterMethod("Refresh", function()
        if not Config.Items.ExpRedeem then return end
        if (ScriptStorage.PlayerData.Level or 0) >= MaxLevel then return end
        if Storage:Get("IsCodesRanOut") then return end
        return _ExpBoost() == 0
    end)
    FunctionsHandler.ExpRedeem:RegisterMethod("Start", function()
        for _, code in ipairs({
            "EASTEREXP", "BANEXPLOIT", "NOMOREHACKS", "WildDares", "BossBuild", "GetPranked", "EARN_FRUITS",
            "Sub2UncleKizaru", "FIGHT4FRUIT", "kittgaming", "TRIPLEABUSE", "Sub2CaptainMaui", "Sub2Fer999",
            "Enyu_is_Pro", "Magicbus", "JCWK", "Starcodeheo", "Bluxxy", "SUB2GAMERROBOT_EXP1", "Sub2NoobMaster123",
            "Sub2Daigrock", "Axiore", "TantaiGaming", "StrawHatMaine", "Sub2OfficialNoobie", "TheGreatAce",
            "SEATROLLIN", "24NOADMIN", "ADMIN_TROLL", "NEWTROLL", "SECRET_ADMIN", "staffbattle", "NOEXPLOIT",
            "NOOB2ADMIN", "CODESLIDE", "fruitconcepts",
        }) do
            local okR, response = pcall(function() return Remotes.Redeem:InvokeServer(code) end)
            task.wait()
            if _ExpBoost() ~= 0 then return end
            if okR and type(response) == "string" and string.find(response, "SUCC") then
                SetTask("MainTask", "Code Redemption | X2 Exp Boost Activated!")
                task.wait(1)
                return
            end
        end
        Storage:Set("IsCodesRanOut", 1)
        Storage:Save()
    end)

    GetBlueGear = function()
        local isl = workspace.Map:FindFirstChild("MysticIsland")
        if not isl then return end
        for _, v in ipairs(isl:GetDescendants()) do
            if v:IsA("MeshPart") and v.MeshId == "rbxassetid://10153114969" and v.Transparency ~= 1 then
                return v.CFrame
            end
        end
    end

    local _PullLeverResponse, _PullLeverChecked = nil, 0
    FunctionsHandler.PullLever:RegisterMethod("Refresh", function()
        if not Config.Items.PullLever then return end
        if (ScriptStorage.PlayerData.Level or 0) < MaxLevel then return end
        if Remotes.CommF_:InvokeServer("CheckTempleDoor") then return end -- already opened
        if not ScriptStorage.Backpack["Valkyrie Helm"] or not ScriptStorage.Backpack["Mirror Fractal"] then return end
        if (Remotes.CommF_:InvokeServer("getRaceLevel") or 0) < 3 then return end -- needs Race V3
        if SeaIndex ~= 3 then return "TravelToSea3" end
        if _PullLeverResponse == nil or tick() - _PullLeverChecked > 3 then
            _PullLeverResponse = Remotes.CommF_:InvokeServer("RaceV4Progress", "Check")
            _PullLeverChecked = tick()
        end
        SetTask("MainTask", "Pull Lever")
        if not _PullLeverResponse then return 1 end
        if workspace.Map:FindFirstChild("MysticIsland") then
            local clock = math.floor(game.Lighting.ClockTime)
            if clock >= 12 or clock < 5 then return 2 end
            SetTask("SubTask", "Hop for server with moon and mirage")
            Hop.API("Mirage", 12, 5)
        else
            SetTask("SubTask", "Hop for server with mirage")
            Hop.API("Mirage", 12, 5)
        end
    end)
    FunctionsHandler.PullLever:RegisterMethod("Start", function(step)
        if step == "TravelToSea3" then
            SetTask("MainTask", "Pull Lever | Travelling to Third Sea")
            Remotes.CommF_:InvokeServer("TravelZou")
            task.wait(10)
            return
        end
        if step == 2 then
            SetTask("SubTask", "Go to Mirage Island")
            local gear = GetBlueGear()
            if gear then
                TweenController.Create(gear)
                SetTask("SubTask", "Pull Lever | Done")
                return true
            end
            local above = workspace.Map.MysticIsland.Center.CFrame * CFrame.new(0, 400, 0)
            TweenController.Create(above)
            if CaculateDistance(above) < 20 then
                LocalPlayer.CameraMaxZoomDistance = 0.5
                LocalPlayer.CameraMaxZoomDistance = 200
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, game.Lighting:GetMoonDirection() + workspace.CurrentCamera.CFrame.Position)
                game.ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility")
            end
            return
        end
        if step ~= 1 then return end
        SetTask("SubTask", "Get Quest Pull Lever")
        if PullLeverQuestDebounce and tick() - PullLeverQuestDebounce < 8 then return end
        TweenController.Create(CFrame.new(3032, 2280, -7325))
        if not (CaculateDistance(CFrame.new(3032, 2280, -7325)) < 30) then return end
        PullLeverQuestDebounce = tick()
        if not workspace.Map:FindFirstChild("Temple of Time") then
            game.ReplicatedStorage.MapStash["Temple of Time"].Parent = workspace.Map
        end
        Remotes.CommF_:InvokeServer("RaceV4Progress", "Begin")
        Remotes.CommF_:InvokeServer("RaceV4Progress", "Check")
        Remotes.CommF_:InvokeServer("RaceV4Progress", "Teleport")
        task.wait(2)
        TweenController.Create(CFrame.new(28613, 14896, 106))
        Remotes.CommF_:InvokeServer("RaceV4Progress", "Check")
        Remotes.CommF_:InvokeServer("RaceV4Progress", "TeleportBack")
        _PullLeverChecked = 0
        _PullLeverResponse = Remotes.CommF_:InvokeServer("RaceV4Progress", "Check")
        Hop.A()
    end)

    FunctionsHandler.MirrorAndValk:RegisterMethod("Refresh", function()
        if not Config.Items.MM then return end
        local hasGod = ScriptStorage.Melees.Godhuman or ScriptStorage.Backpack.Godhuman
        if Config.Items.AutoFullyMelees and not hasGod then return end -- Godhuman first (when it is enabled)
        for _, boss in ipairs({ "Dough King", "Cake Prince", "rip_indra True Form" }) do
            if ScriptStorage.Enemies[boss] then return { AttackBoss = boss } end
        end
        if (ScriptStorage.PlayerData.Level or 0) < MaxLevel then return end
        local hasMirror = ScriptStorage.Backpack["Mirror Fractal"] ~= nil
        local hasValk = ScriptStorage.Backpack["Valkyrie Helm"] ~= nil
        if hasMirror and hasValk then return end
        if SeaIndex ~= 3 then return { TravelToSea3 = true } end
        if ScriptStorage.Tools["God's Chalice"] or ScriptStorage.Tools["Sweet Chalice"] then return end
        return { Mirror = not hasMirror, Valk = not hasValk }
    end)
    FunctionsHandler.MirrorAndValk:RegisterMethod("Start", function(job)
        if job.TravelToSea3 then
            SetTask("MainTask", "Mirror And Valk | Travelling to Third Sea")
            Remotes.CommF_:InvokeServer("TravelZou")
            task.wait(10)
            return
        end
        if job.AttackBoss then
            SetTask("MainTask", "Priority Boss | Attacking " .. job.AttackBoss)
            CombatController.Attack(job.AttackBoss)
            return
        end
        if job.Mirror then
            if Config.Hop["Hop For Dough King ( Mirror Fractal )"] then
                SetTask("MainTask", "Mirror Fractal | Hopping for Dough King")
                Hop.API("Doughking", 12, 5)
            else
                SetTask("MainTask", "Mirror Fractal | Hunting Elite for Chalice")
                Hop.API("Elite", 12, 5)
            end
            return
        end
        if not job.Valk then return end
        if Config.Hop["Hop For Rip Indra ( Valkyrie Helm )"] then
            SetTask("MainTask", "Valkyrie Helm | Hopping for Rip Indra")
            Hop.API("RipIndra", 12, 5)
        else
            SetTask("MainTask", "Valkyrie Helm | Hunting Elite for Chalice")
            Hop.API("Elite", 12, 5)
        end
    end)

    FunctionsHandler.Trevor:RegisterMethod('Refresh', function()
        if Config.Items.Trevor == false then return end
        if FunctionsHandler.Trevor:Get('IsCompleted') or os.time() - timeee < 1 then return end
        if ScriptStorage.PlayerData.Level < 1100 then return end
        -- [NEW - deobf] quest already finished on the account (Flamingo access unlocked)
        do
            local okU, unl = pcall(function() return Remotes.CommF_:InvokeServer("GetUnlockables") end)
            if okU and type(unl) == "table" and unl.FlamingoAcces ~= nil then
                FunctionsHandler.Trevor:Set('IsCompleted', true)
                return
            end
        end
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
            if Config.Hop and Config.Hop["Hop RipIndra For Tushita"] then Hop.API("ripindra", 12, 1) end
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
    -- Hop is now a callable table: Hop() / Hop("reason") -> random server (string args are ignored, they used to break SafeHop)
    -- Hop.API(kind, maxPlayers, tries) -> servers listed by the hop API (e.g. "Mirage", "fullmoon", "Doughking", "RipIndra", "Elite")
    -- Hop.A(maxPlayers) -> plain hop
    do
        getgenv().FailedJobIds = getgenv().FailedJobIds or {}
        local HttpSvc = game:GetService("HttpService")
        local HopT = {}
        function HopT.API(kind, maxPlayers, tries)
            maxPlayers = maxPlayers or 12
            tries = tries or 25
            if getgenv().__HopAPIBusy and os.clock() - getgenv().__HopAPIBusy < 25 then return false end
            getgenv().__HopAPIBusy = os.clock()
            local url = "https://kurinianhub.up.railway.app/api/bloxfruit/" .. tostring(kind)
            local rounds = math.max(1, math.floor(tries / 5))
            for i = 1, rounds do
                local ok, result = pcall(function()
                    local body
                    pcall(function() body = game:HttpGet(url) end)
                    if not body then
                        local req = (syn and syn.request) or request or (http and http.request)
                        local r = req and req({ Url = url, Method = "GET" })
                        body = r and r.Body
                    end
                    if not body then return "ERROR" end
                    local data = HttpSvc:JSONDecode(body)
                    if typeof(data) ~= "table" then return "ERROR" end
                    local servers = data.servers or data.data or data
                    if typeof(servers) ~= "table" then return "ERROR" end
                    local cands = {}
                    for _, s in ipairs(servers) do
                        local jobId = s.jobId or s.jobid
                        local placeId = tonumber(s.placeId) or tonumber(s.placeid)
                        local players = tonumber(s.players) or 99
                        if jobId and placeId == game.PlaceId and players > 2 and players < maxPlayers
                           and jobId ~= game.JobId and not getgenv().FailedJobIds[jobId] then
                            cands[#cands + 1] = jobId
                        end
                    end
                    if #cands == 0 then return "NO_SERVER" end
                    for _, jobId in ipairs(cands) do
                        local full = false
                        local conn
                        pcall(function()
                            conn = game:GetService("TeleportService").TeleportInitFailed:Connect(function(_, res)
                                if res == Enum.TeleportResult.GameFull then
                                    full = true
                                    getgenv().FailedJobIds[jobId] = tick()
                                end
                            end)
                        end)
                        local sent = pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser"):InvokeServer("teleport", jobId)
                        end)
                        task.wait(2)
                        if conn then pcall(function() conn:Disconnect() end) end
                        if sent and not full then return true end
                        getgenv().FailedJobIds[jobId] = tick()
                    end
                    return "FAILED_HOP"
                end)
                if ok and result == true then return true end
                if i < rounds then task.wait(5) end
            end
            getgenv().__HopAPIBusy = nil
            return false
        end
        function HopT.A(maxPlayers) return SafeHop(maxPlayers) end
        Hop = setmetatable(HopT, { __call = function(_, a, b)
            if type(a) ~= "number" then a = nil end
            if type(b) ~= "string" then b = nil end
            return SafeHop(a, b)
        end })
    end

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
        if Config.Configuration.AutoHop then Hop('Autohop') end
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
Config.Extras = Config.ExtrasUser or {
    NoAnimation = true, AutoRedeemCodes = true, AutoGachaFruit = true, GachaInterval = 5, AutoStoreAfterRoll = true,
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

end

local function RunLeviathan(...)
--[[
    FLOWBR | LEVIATHAN - Kaitun Leviathan module.
    Hunt Leviathan / sea events, craft scrolls, shop & status, webhook, skill selection.
    Options come from the user config table (see levi_config_template.lua).
]]
local UserConfig = ...

-- ===================== CONFIG (Defaults + user overrides) =====================
local Defaults = {
    Team = "Marines",                 -- "Marines" or "Pirates"
    Noclip = true,
    RemoveFog = true,
    PartyAPI = true,                  -- sync boat-party data with the external party API (false = local file only)
    Speed = { Tween = 170, Boat = 250 },
    Boat = { Name = "Beast Hunter", Buyer = "", PartySize = 5 },
    Hunt = {
        AutoStart = true,             -- start hunting automatically
        SpinPosition = true,
        FlightHeight = 20,
        SafeFlyingBoat = true,
        SafeHeight = 400,
        SafeRadius = 250,
        ShootHeart = false,
        DriveTo = "None",             -- "None" / "Tiki" / "Hydra"
        PullHeight = 35,
        DestroyIDK = false,
    },
    Events = {
        Leviathan = true, SeaBeast = false, Piranha = false, Terrorshark = false,
        Shark = false, PirateBrigade = false, PirateGrandBrigade = false, FishBoat = false,
    },
    Combat = {
        Weapon = "Melee",             -- "Melee" / "Sword" / "Blox Fruit" / "Gun"
        UseGunEvent = false,
        UseM1Fruit = false,
        AutoBuso = true,
        AutoV3 = true,
        AutoKen = true,
        NoSkillDelay = true,
        SkillDelay = { Melee = 100, Fruit = 100, Gun = 100, Sword = 100 },
        Skills = {
            Melee = { "Z", "X", "C" },
            Fruit = { "Z", "X", "C", "F" },
            Gun = { "Z", "X" },
            Sword = { "Z", "X" },
        },
    },
    Ignore = { SeaEvent = true, Island = true, SeaEventHeight = 500, IslandHeight = 800 },
    Scrolls = {
        Craft = false,
        Selected = {},                -- e.g. { ["Mythical Scroll"] = true } (Common Scroll, Rare Scroll, Legendary Scroll, Mythical Scroll)
        Caps = { Common = 10, Rare = 10, Legendary = 15, Mythical = 10 },
    },
    Fruit = { AutoRandom = true, AutoStore = true },
    UI = { ShowSettings = false },    -- true = also show the big settings window (runtime toggles)
    WebHook = {
        Enable = false, Url = "", DiscordID = "", Ping = false,
        NotifyWatcher = true, NotifyShoot = true, NotifyDelivered = true, NotifyInventory = true,
    },
}

local function MergeConfig(def, usr)
    local out = {}
    for k, v in pairs(def) do
        if type(v) == "table" and v[1] == nil and type(usr) == "table" and type(usr[k]) == "table" then
            out[k] = MergeConfig(v, usr[k])
        elseif type(v) == "table" and v[1] == nil then
            out[k] = MergeConfig(v, nil)
        elseif type(usr) == "table" and usr[k] ~= nil and type(usr[k]) == type(v) then
            out[k] = usr[k]
        elseif type(v) == "number" and type(usr) == "table" and tonumber(usr[k]) then
            out[k] = tonumber(usr[k])
        else
            out[k] = v
        end
    end
    if type(usr) == "table" then
        for k, v in pairs(usr) do
            if out[k] == nil then out[k] = v end -- keep extra keys (e.g. custom Scrolls.Selected names)
        end
    end
    return out
end
local Cfg = MergeConfig(Defaults, type(UserConfig) == "table" and UserConfig or {})

-- webhook backward compat: global logs_webhook
do
    local legacy
    pcall(function() legacy = (getgenv and getgenv().logs_webhook) or _G.logs_webhook end)
    if (type(Cfg.WebHook.Url) ~= "string" or Cfg.WebHook.Url == "") and type(legacy) == "string" and legacy ~= "" then
        Cfg.WebHook.Url = legacy
        local userWH = type(UserConfig) == "table" and type(UserConfig.WebHook) == "table" and UserConfig.WebHook or {}
        if userWH.Enable == nil then Cfg.WebHook.Enable = true end
    end
end

local function CfgList(map, order)
    local list = {}
    for _, name in ipairs(order) do if map[name] then table.insert(list, name) end end
    return list
end
local function CfgSelectedList(map)
    local list = {}
    for name, on in pairs(map) do if on == true then table.insert(list, name) end end
    table.sort(list)
    return list
end
local function CfgTeam(t)
    t = tostring(t or ""):lower()
    if t:sub(1, 3) == "pir" then return "Pirates" end
    return "Marines"
end
-- =============================================================================
Services = setmetatable({}, {__index = function(self, name)
    local s, c = pcall(function() return cloneref(game:GetService(name)) end)
    if s then rawset(self, name, c) return c
    else error("Invalid Roblox Service: " .. tostring(name)) end
end})
Players = Services.Players
LP = Players.LocalPlayer
ReplicatedStorage = Services.ReplicatedStorage
RunService = game:GetService("RunService")
TweenService = game:GetService("TweenService")
Lighting = game:GetService("Lighting")
VirtualInputManager = game:GetService("VirtualInputManager")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
Workspace = workspace
Camera = workspace.CurrentCamera
local MapFolder = Workspace:WaitForChild("Map", 5)
local _WaterBasePlane = MapFolder and MapFolder:FindFirstChild("WaterBase-Plane")

_G.ChonPhe = CfgTeam(Cfg.Team)
_G.BatNoclip = Cfg.Noclip
_G.TocDoTween = Cfg.Speed.Tween
_G.TocDoTweenBoat = Cfg.Speed.Boat
_G.XoaSuongMu = Cfg.RemoveFog
_G.NguoiMuaThuyen = (type(Cfg.Boat.Buyer) == "string" and Cfg.Boat.Buyer ~= "") and Cfg.Boat.Buyer or LP.Name
_G.SoNguoiCanThiet = Cfg.Boat.PartySize
_G.ChieuCaoBay = Cfg.Hunt.FlightHeight
_G.DangSan = Cfg.Hunt.AutoStart
_G.ChoPhepDiChuyen = false
_G.TenThuyen = Cfg.Boat.Name
_G.SpinPosition = Cfg.Hunt.SpinPosition
_G.SelectedWeapon = Cfg.Combat.Weapon
_G.UseGunEvent = Cfg.Combat.UseGunEvent
_G.UseM1FruitEvent = Cfg.Combat.UseM1Fruit
_G.EnableIgnoreIsland = Cfg.Ignore.Island
_G.EnableIgnoreSeaEvent = Cfg.Ignore.SeaEvent
_G.IgnoreHeight = Cfg.Ignore.SeaEventHeight
_G.IgnoreIslandHeight = Cfg.Ignore.IslandHeight
local EventKeys = {
    {"Leviathan", "Leviathan"}, {"SeaBeast", "Sea Beast"}, {"Piranha", "Piranha"}, {"Terrorshark", "Terrorshark"},
    {"Shark", "Shark"}, {"PirateBrigade", "PirateBrigade"}, {"PirateGrandBrigade", "PirateGrandBrigade"}, {"FishBoat", "FishBoat"}
}
_G.SelectedEvents = {}
for _, pair in ipairs(EventKeys) do
    if Cfg.Events[pair[1]] == true then table.insert(_G.SelectedEvents, pair[2]) end
end
_G.SelectedMelee = Cfg.Combat.Skills.Melee
_G.SelectedFruit = Cfg.Combat.Skills.Fruit
_G.SelectedGun = Cfg.Combat.Skills.Gun
_G.SelectedScrolls = CfgSelectedList(Cfg.Scrolls.Selected)
_G.AutoCraftScrollSwitch = Cfg.Scrolls.Craft
_G.SelectedSword = Cfg.Combat.Skills.Sword
_G.ShootHeart = Cfg.Hunt.ShootHeart
_G.DestroyIDK = Cfg.Hunt.DestroyIDK
_G.AutoRandomFruit = Cfg.Fruit.AutoRandom
_G.AutoStoreFruit = Cfg.Fruit.AutoStore
_G.PullYHeight = Cfg.Hunt.PullHeight
_G.SpyCheckResult = -1
_G.FoundLeviathanGate = false
_G.LastHRPPosition = nil
_G.DriveToTiki = (tostring(Cfg.Hunt.DriveTo):lower() == "tiki")
_G.DriveToHydra = (tostring(Cfg.Hunt.DriveTo):lower() == "hydra")
_G.DangKeoTim = false
_G.SafeFlyingBoat = Cfg.Hunt.SafeFlyingBoat
_G.SafeHeightY = Cfg.Hunt.SafeHeight
_G.SafeRadius = Cfg.Hunt.SafeRadius
_G.AutoBuso = Cfg.Combat.AutoBuso
_G.AutoV3 = Cfg.Combat.AutoV3
_G.AutoKen = Cfg.Combat.AutoKen
_G.NoSkillDelay = Cfg.Combat.NoSkillDelay
_G.SkillDelayMelee = Cfg.Combat.SkillDelay.Melee
_G.SkillDelayFruit = Cfg.Combat.SkillDelay.Fruit
_G.SkillDelayGun = Cfg.Combat.SkillDelay.Gun
_G.SkillDelaySword = Cfg.Combat.SkillDelay.Sword
_G.WebhookLevi = {
    Enabled = Cfg.WebHook.Enable == true,
    Url = tostring(Cfg.WebHook.Url or ""),
    DiscordID = tostring(Cfg.WebHook.DiscordID or ""),
    PingEnabled = Cfg.WebHook.Ping == true,
    NotifyWatcher = Cfg.WebHook.NotifyWatcher == true,
    NotifyShoot = Cfg.WebHook.NotifyShoot == true,
    NotifyDelivered = Cfg.WebHook.NotifyDelivered == true,
    NotifyInventory = Cfg.WebHook.NotifyInventory == true
}

local DISCORD_THEME = {
    color = 16762567, -- #FFC6C7 (Pastel Pink)
    thumbnail = "https://cdn.discordapp.com/attachments/1540565014937739394/1540692132568895588/b006e4745cec6a9c6130b5360c63699f.png",
    footerIcon = "https://cdn.discordapp.com/attachments/1540565014937739394/1540690154317160448/tai_xuong.png",
    heart = "<a:a_afx_heart_2_pink:1540683293954015263>",
    rabbit = "<a:ast_dcr_thovotay:1540657913985630299>",
    key = "<a:p_key01:1540681875067113552>",
    diamond = "<a:p_diamond01:1540686688505036830>",
    online = "<a:pent_online_scr:1540681158512214086>",
    cloud = "<a:ast_cloud:1540681581939654737>",
    booster = "<:JBVBoosterIcon:1540681208223236098>",
    leftWing = "<a:p_wing03:1540688176253771846>",
    rightWing = "<a:p_wing04:1540688262421680130>"
}

local function safeCountItem(itemName)
    if CountItem then
        local s, res = pcall(CountItem, itemName)
        if s and type(res) == "number" then return res end
    end
    local s, res = pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        local IRS = require(RS:WaitForChild("ItemReplicationService", 2))
        local KEYS_MOD = require(RS.ItemReplicationService:WaitForChild("KEYS", 2))
        local IC = require(RS:WaitForChild("ItemConfig", 2))
        local qItems = IRS:GetItems(KEYS_MOD.QUANTITY)
        if not qItems then return 0 end
        local targetClean = string.lower(string.gsub(itemName, "%s+", ""))
        for _, item in pairs(qItems) do
            local rawName = IC.match(item.ItemId):unwrap().Index.DebugLabel
            local cleanName = string.match(rawName, "^(.-)%s*%[") or rawName
            if string.lower(string.gsub(cleanName, "%s+", "")) == targetClean then
                return item.Value or 0
            end
        end
        return 0
    end)
    return (s and res) or 0
end

local function sendLeviWebhook(eventType, details)
    if not _G.WebhookLevi or not _G.WebhookLevi.Enabled or _G.WebhookLevi.Url == "" then
        return
    end

    if (eventType == "Found Frozen Dimension" or eventType == "Found Watcher") and not _G.WebhookLevi.NotifyWatcher then
        return
    elseif (eventType == "Heart Shooted" or eventType == "Heart Harpooned") and not _G.WebhookLevi.NotifyShoot then
        return
    elseif (eventType == "Heart Delivered") and not _G.WebhookLevi.NotifyDelivered then
        return
    end

    local url = _G.WebhookLevi.Url
    local pingString = ""
    if _G.WebhookLevi.PingEnabled then
        if _G.WebhookLevi.DiscordID and _G.WebhookLevi.DiscordID ~= "" then
            pingString = "<@" .. tostring(_G.WebhookLevi.DiscordID) .. ">"
        else
            pingString = "@everyone"
        end
    end

    local data = {
        ["username"] = "ʚ ᙏᥱყყ♡Bot ɞ",
        ["avatar_url"] = "https://cdn.discordapp.com/attachments/1483412809957113917/1505120553734766713/cte_2.jfif",
        ["embeds"] = {{
            ["author"] = {
                ["name"] = "FLOWBR • Leviathan Tracking Service",
                ["icon_url"] = DISCORD_THEME.footerIcon
            },
            ["title"] = DISCORD_THEME.heart .. " FLOWBR - LEVIATHAN EVENT " .. DISCORD_THEME.heart,
            ["description"] = "> " .. DISCORD_THEME.online .. " Status Update: **" .. tostring(eventType) .. "**\n> *" .. DISCORD_THEME.leftWing .. " Automated Leviathan Hunt Assistant " .. DISCORD_THEME.rightWing .. "*\n\u{200B}",
            ["color"] = DISCORD_THEME.color,
            ["fields"] = {
                {
                    ["name"] = DISCORD_THEME.rabbit .. " Player",
                    ["value"] = "```text\n" .. tostring(LP.Name) .. "\n```",
                    ["inline"] = true
                },
                {
                    ["name"] = DISCORD_THEME.booster .. " Boat Buyer",
                    ["value"] = "```text\n" .. tostring(_G.NguoiMuaThuyen) .. "\n```",
                    ["inline"] = true
                },
                {
                    ["name"] = DISCORD_THEME.diamond .. " Event Details",
                    ["value"] = "```text\n" .. tostring(details or "Success") .. "\n```",
                    ["inline"] = false
                },
                {
                    ["name"] = DISCORD_THEME.cloud .. " Server JobId",
                    ["value"] = "```text\n" .. tostring(game.JobId) .. "\n```",
                    ["inline"] = false
                }
            },
            ["thumbnail"] = {
                ["url"] = DISCORD_THEME.thumbnail
            },
            ["footer"] = {
                ["text"] = "FLOWBR Webhook | " .. os.date("%H:%M:%S %d/%m/%Y"),
                ["icon_url"] = DISCORD_THEME.footerIcon
            }
        }}
    }
    
    if pingString ~= "" then
        data["content"] = pingString
    end

    pcall(function()
        local jsonData = HttpService:JSONEncode(data)
        local req = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
        if req then
            req({
                Url = url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = jsonData
            })
        end
    end)
end

local function sendLeviInventoryWebhook(destination)
    if not _G.WebhookLevi or not _G.WebhookLevi.Enabled or _G.WebhookLevi.Url == "" or not _G.WebhookLevi.NotifyInventory then
        return
    end

    local url = _G.WebhookLevi.Url
    local pingString = ""
    if _G.WebhookLevi.PingEnabled then
        if _G.WebhookLevi.DiscordID and _G.WebhookLevi.DiscordID ~= "" then
            pingString = "<@" .. tostring(_G.WebhookLevi.DiscordID) .. ">"
        else
            pingString = "@everyone"
        end
    end

    local items = {
        "Leviathan Heart",
        "Leviathan Scale",
        "Mutant Tooth",
        "Terror Eyes",
        "Electric Wing",
        "Shark Tooth",
        "Fool's Gold",
        "Common Scroll",
        "Rare Scroll",
        "Legendary Scroll",
        "Mythical Scroll"
    }

    local fields = {
        {
            ["name"] = DISCORD_THEME.rabbit .. " Player",
            ["value"] = "```text\n" .. tostring(LP.Name) .. "\n```",
            ["inline"] = true
        },
        {
            ["name"] = DISCORD_THEME.booster .. " Delivered At",
            ["value"] = "```text\n" .. tostring(destination or "Island") .. "\n```",
            ["inline"] = true
        }
    }

    for _, itemName in ipairs(items) do
        local count = safeCountItem(itemName)
        table.insert(fields, {
            ["name"] = DISCORD_THEME.key .. " " .. itemName,
            ["value"] = "```text\n" .. tostring(count) .. "\n```",
            ["inline"] = true
        })
    end

    local data = {
        ["username"] = "ʚ ᙏᥱყყ♡Bot ɞ",
        ["avatar_url"] = "https://cdn.discordapp.com/attachments/1483412809957113917/1505120553734766713/cte_2.jfif",
        ["embeds"] = {{
            ["author"] = {
                ["name"] = "FLOWBR • Inventory Tracking Summary",
                ["icon_url"] = DISCORD_THEME.footerIcon
            },
            ["title"] = DISCORD_THEME.heart .. " LEVIATHAN MATERIALS STATS " .. DISCORD_THEME.heart,
            ["description"] = "> " .. DISCORD_THEME.online .. " Inventory summary updated after claiming heart!\n> *" .. DISCORD_THEME.leftWing .. " All drops and marine materials synchronized " .. DISCORD_THEME.rightWing .. "*\n\u{200B}",
            ["color"] = DISCORD_THEME.color,
            ["fields"] = fields,
            ["thumbnail"] = {
                ["url"] = DISCORD_THEME.thumbnail
            },
            ["footer"] = {
                ["text"] = "FLOWBR Webhook | " .. os.date("%H:%M:%S %d/%m/%Y"),
                ["icon_url"] = DISCORD_THEME.footerIcon
            }
        }}
    }
    
    if pingString ~= "" then
        data["content"] = pingString
    end

    pcall(function()
        local jsonData = HttpService:JSONEncode(data)
        local req = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
        if req then
            req({
                Url = url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = jsonData
            })
        end
    end)
end
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local spycheck = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("InfoLeviathan", "1")
            if spycheck then
                _G.SpyCheckResult = spycheck
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(30) do
        pcall(function()
            if _G.SpyCheckResult ~= 5 and _G.SpyCheckResult > -1 then
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("InfoLeviathan", "2")
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local mapFolder = workspace:FindFirstChild("Map") or workspace:WaitForChild("Map", 5)
            if mapFolder then
                local waterPlane = mapFolder:FindFirstChild("WaterBase-Plane")
                if waterPlane and waterPlane.Size ~= Vector3.new(1000, 112, 1000) then
                    waterPlane.Size = Vector3.new(1000, 112, 1000)
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", _G.ChonPhe)
            end)
        end
    end
end)

repeat
    task.wait(0.5)
until LP.Team ~= nil and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")


local Themes = {
    ["Dark"] = {
        Background = Color3.fromRGB(15, 15, 15),
        Darker = Color3.fromRGB(8, 8, 8),
        ContainerBg = Color3.fromHex("#525252"),
        ContainerTrans = 0.6,
        PillBack = Color3.fromRGB(20, 25, 30),
        Text = Color3.fromHex("#FFFFFF"),
        TextDim = Color3.fromHex("#808080"),
        Red = Color3.fromRGB(255, 60, 60),
        Green = Color3.fromRGB(130, 255, 100),
        Active = Color3.fromHex("#888888"),
        TextContrast = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#808080")),
            ColorSequenceKeypoint.new(0.50, Color3.fromHex("#D3D3D3")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#000000"))
        }),
        TextGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")), 
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#8A8A8A")), 
            ColorSequenceKeypoint.new(1, Color3.fromHex("#1A1A1A")) 
        }),
        RowStroke = Color3.fromHex("#FFFFFF"),
        RowStrokeGrad = ColorSequence.new({ 
            ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")), 
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#555555")), 
            ColorSequenceKeypoint.new(1, Color3.fromHex("#54626F")) 
        }),
        StrokeGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(20, 20, 20)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(20, 20, 20)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        })
    },


    ["Dream"] = {
        Background = Color3.fromHex("#0A1428"),
        Darker = Color3.fromHex("#050A14"),
        ContainerBg = Color3.fromHex("#151C3B"),
        ContainerTrans = 0.5,
        PillBack = Color3.fromHex("#0D162C"),
        Text = Color3.fromHex("#E6FFFF"),
        TextDim = Color3.fromHex("#FFFFFF"),
        Red = Color3.fromHex("#FF3C3C"),
        Green = Color3.fromHex("#82FF64"),
        Active = Color3.fromHex("#8C64FF"),
        TextContrast = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#46E6FF")),
            ColorSequenceKeypoint.new(0.50, Color3.fromHex("#8C64FF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#46E6FF"))
        }),
        TextGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#B4FFFF")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#A08CFF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#8C64FF"))
        }),
        RowStroke = Color3.fromHex("#808080"),
        RowStrokeGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#46E6FF")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#8C64FF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#46E6FF"))
        }),
        StrokeGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#8C64FF")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#46E6FF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#8C64FF"))
        })
    },
["Candy"] = {
		Background = Color3.fromHex("#1C0F14"),
		Darker = Color3.fromHex("#12090D"),
		ContainerBg = Color3.fromHex("#331822"),
		ContainerTrans = 0.5,
		PillBack = Color3.fromHex("#26111A"),
		Text = Color3.fromHex("#FFFFFF"),
		TextDim = Color3.fromHex("#F2B8CA"),
		Red = Color3.fromRGB(255, 60, 60),
		Green = Color3.fromRGB(130, 255, 100),
		Active = Color3.fromHex("#FFFFFF"),
		TextContrast = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.50, Color3.fromHex("#E16389")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		TextGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#E16389")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#C8A2C8"))
		}),
		RowStroke = Color3.fromHex("#808080"),
		RowStrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#E16389")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		StrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#E16389")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#C8A2C8"))
		})
	},
	["Lavender"] = {
		Background = Color3.fromHex("#14101A"),
		Darker = Color3.fromHex("#0D0A12"),
		ContainerBg = Color3.fromHex("#251D30"),
		ContainerTrans = 0.5,
		PillBack = Color3.fromHex("#1B1524"),
		Text = Color3.fromHex("#FFFFFF"),
		TextDim = Color3.fromHex("#D8C8EA"),
		Red = Color3.fromRGB(255, 60, 60),
		Green = Color3.fromRGB(130, 255, 100),
		Active = Color3.fromHex("#FFFFFF"),
		TextContrast = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.50, Color3.fromHex("#B589D6")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		TextGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#B589D6")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#9966CC"))
		}),
		RowStroke = Color3.fromHex("#808080"),
		RowStrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#B589D6")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		StrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#B589D6")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#8A2BE2"))
		})
	},



	["Sky"] = {
		Background = Color3.fromHex("#0F161C"),
		Darker = Color3.fromHex("#090E12"),
		ContainerBg = Color3.fromHex("#1B2733"),
		ContainerTrans = 0.5,
		PillBack = Color3.fromHex("#141D26"),
		Text = Color3.fromHex("#FFFFFF"),
		TextDim = Color3.fromHex("#C2E2F5"),
		Red = Color3.fromRGB(255, 60, 60),
		Green = Color3.fromRGB(130, 255, 100),
		Active = Color3.fromHex("#FFFFFF"),
		TextContrast = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.50, Color3.fromHex("#70C1B3")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		TextGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#70C1B3")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#5B9BD5"))
		}),
		RowStroke = Color3.fromHex("#808080"),
		RowStrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#70C1B3")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		StrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#70C1B3")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#4A90E2"))
		})
	},



	["Luxury"] = {
		Background = Color3.fromHex("#1A1712"),
		Darker = Color3.fromHex("#100E0A"),
		ContainerBg = Color3.fromHex("#302A20"),
		ContainerTrans = 0.5,
		PillBack = Color3.fromHex("#221E16"),
		Text = Color3.fromHex("#FFFFFF"),
		TextDim = Color3.fromHex("#EAE0C8"),
		Red = Color3.fromRGB(255, 60, 60),
		Green = Color3.fromRGB(130, 255, 100),
		Active = Color3.fromHex("#FFFFFF"),
		TextContrast = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.50, Color3.fromHex("#F4D03F")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		TextGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#F4D03F")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#D4AC0D"))
		}),
		RowStroke = Color3.fromHex("#808080"),
		RowStrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#F4D03F")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		StrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#F4D03F")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#B7950B"))
		})
	},



	["Mint"] = {
		Background = Color3.fromHex("#0F1A17"),
		Darker = Color3.fromHex("#09100E"),
		ContainerBg = Color3.fromHex("#1B302B"),
		ContainerTrans = 0.5,
		PillBack = Color3.fromHex("#142420"),
		Text = Color3.fromHex("#FFFFFF"),
		TextDim = Color3.fromHex("#C2EAE2"),
		Red = Color3.fromRGB(255, 60, 60),
		Green = Color3.fromRGB(130, 255, 100),
		Active = Color3.fromHex("#FFFFFF"),
		TextContrast = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.50, Color3.fromHex("#56C596")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		TextGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#56C596")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#329D9C"))
		}),
		RowStroke = Color3.fromHex("#808080"),
		RowStrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#56C596")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
		}),
		StrokeGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#56C596")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#205072"))
		})
	},
}

local CurrentThemeName = "Dark"
local Theme = Themes[CurrentThemeName]
local UI_Elements = {
    Backgrounds = {},
    ContainerBgs = {},
    PillBacks = {},
    Texts = {},
    TextDims = {},
    RowStrokes = {},
    DarkerStrokes = {},
    TextGrads = {},
    ContrastGrads = {},
    RowStrokeGrads = {},
    MainStrokeGrads = {}
}
local StrokeGradients = {}
local AnimatedGradients = {}
local ValueLabels = {}



local function ChangeTheme(themeName)
    if not Themes[themeName] or CurrentThemeName == themeName then return end
    CurrentThemeName = themeName
    local newT = Themes[themeName]
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    local function applySpatialWave(obj, tweenProps, directProps)
        local guiObj = obj
        if not guiObj:IsA("GuiObject") then
            guiObj = guiObj.Parent
        end

        local delayTime = 0
        if guiObj and guiObj:IsA("GuiObject") then
            local posX = guiObj.AbsolutePosition.X
            local posY = guiObj.AbsolutePosition.Y
            delayTime = (posX + posY) / 3500 
        end

        task.delay(delayTime, function()
            if tweenProps then
                TweenService:Create(obj, tweenInfo, tweenProps):Play()
            end
            if directProps then
                for k, v in pairs(directProps) do
                    obj[k] = v
                end
            end
        end)
    end

    for _, obj in pairs(UI_Elements.Backgrounds) do applySpatialWave(obj, {BackgroundColor3 = newT.Background}) end
    for _, obj in pairs(UI_Elements.ContainerBgs) do applySpatialWave(obj, {BackgroundColor3 = newT.ContainerBg, BackgroundTransparency = newT.ContainerTrans}) end
    for _, obj in pairs(UI_Elements.PillBacks) do applySpatialWave(obj, {BackgroundColor3 = newT.PillBack}) end
    for _, obj in pairs(UI_Elements.Texts) do applySpatialWave(obj, {TextColor3 = newT.Text}) end
    for _, obj in pairs(UI_Elements.TextDims) do applySpatialWave(obj, {TextColor3 = newT.TextDim}) end
    for _, obj in pairs(UI_Elements.RowStrokes) do applySpatialWave(obj, {Color = newT.RowStroke}) end
    for _, obj in pairs(UI_Elements.DarkerStrokes) do applySpatialWave(obj, {Color = newT.Darker}) end

    for _, grad in pairs(UI_Elements.TextGrads) do applySpatialWave(grad, nil, {Color = newT.TextGrad}) end
    for _, grad in pairs(UI_Elements.ContrastGrads) do applySpatialWave(grad, nil, {Color = newT.TextContrast}) end
    for _, grad in pairs(UI_Elements.RowStrokeGrads) do applySpatialWave(grad, nil, {Color = newT.RowStrokeGrad}) end
    for _, grad in pairs(UI_Elements.MainStrokeGrads) do applySpatialWave(grad, nil, {Color = newT.StrokeGrad}) end
end

local KaitunGui = Instance.new("ScreenGui")
KaitunGui.Name = "FlowbrLeviathanUI"
KaitunGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KaitunGui.ResetOnSpawn = false

if gethui then
    KaitunGui.Parent = gethui()
else
    KaitunGui.Parent = CoreGui
end


local function MakeDraggable(topbar, object)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(object, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = newPos}):Play()
    end

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end


local function CreateButtonEffects(button, visualTarget)
    local target = visualTarget or button
    local scale = Instance.new("UIScale")
    scale.Scale = 1
    scale.Parent = target

    button.MouseEnter:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Scale = 1.05}):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end)

    button.MouseButton1Down:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Scale = 0.8}):Play()
    end)

    button.MouseButton1Up:Connect(function()
        local t1 = TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Scale = 1.3})
        t1:Play()
        t1.Completed:Connect(function()
            TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Scale = 1}):Play()
        end)
    end)
end


local function ApplyTextGradient(obj, isContrast)
    obj.TextColor3 = Theme.Text
    table.insert(UI_Elements.Texts, obj)
    
    local grad = Instance.new("UIGradient", obj)
    grad.Rotation = 90
    grad.Color = isContrast and Theme.TextContrast or Theme.TextGrad
    if isContrast then
        table.insert(UI_Elements.ContrastGrads, grad)
    else
        table.insert(UI_Elements.TextGrads, grad)
    end
    
    local shadow = Instance.new("UIStroke")
    shadow.Color = Theme.Darker
    shadow.Thickness = 0.5
    shadow.Transparency = 0
    shadow.Parent = obj
    table.insert(UI_Elements.DarkerStrokes, shadow)
    
    return grad
end
-- ============================================================================
-- LEVIATHAN STATUS UI  (farm-dashboard look: small, centered, draggable, "-" / "+" collapse button)
-- ============================================================================
local PINK       = Color3.fromRGB(185, 28, 45)
local PINK_DIM   = Color3.fromRGB(150, 24, 38)
local RED        = Color3.fromRGB(150, 22, 36)
local GRAY_BG    = Color3.fromRGB(30, 29, 33)
local GRAY_PANEL = Color3.fromRGB(46, 44, 50)
local GRAY_CELL  = Color3.fromRGB(60, 57, 64)
local GRAY_LINE  = Color3.fromRGB(104, 99, 110)
local TEXT_COL   = Color3.fromRGB(248, 240, 244)

local WIN_W, HEADER_H = 250, 38
local ROW_H, ROWS = 24, { "Fool's Gold", "Shark Tooth", "Electric Wing", "Mutant Tooth", "Terror Eyes" }
local BODY_H = 10 + 40 + 8 + (#ROWS * (ROW_H + 4)) + 8
local WIN_H = HEADER_H + BODY_H

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(WIN_W, WIN_H)
MainFrame.Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2)
MainFrame.BackgroundColor3 = GRAY_BG
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = KaitunGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
do
    local st = Instance.new("UIStroke", MainFrame)
    st.Color = RED
    st.Thickness = 1.6
    st.Transparency = 0.15
    local bg = Instance.new("ImageLabel")
    bg.Name = "Bg"
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundTransparency = 1
    bg.Image = "rbxassetid://134924508387467"
    bg.ScaleType = Enum.ScaleType.Crop
    bg.Parent = MainFrame
    local dim = Instance.new("Frame")
    dim.Name = "Dim"
    dim.Size = UDim2.fromScale(1, 1)
    dim.BackgroundColor3 = Color3.new(0, 0, 0)
    dim.BackgroundTransparency = 0.45
    dim.BorderSizePixel = 0
    dim.Parent = MainFrame
end

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.fromOffset(WIN_W, HEADER_H)
Header.BackgroundTransparency = 1
Header.Active = true
Header.Parent = MainFrame

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1, -60, 1, 0)
TitleLbl.Position = UDim2.fromOffset(14, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "flowbr | leviathan"
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 15
TitleLbl.TextColor3 = PINK
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = Header

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.fromOffset(WIN_W, 1)
HeaderLine.Position = UDim2.fromOffset(0, HEADER_H - 1)
HeaderLine.BackgroundColor3 = GRAY_LINE
HeaderLine.BackgroundTransparency = 0.4
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local CollapseBtn = Instance.new("TextButton")
CollapseBtn.Size = UDim2.fromOffset(30, 24)
CollapseBtn.Position = UDim2.fromOffset(WIN_W - 40, 7)
CollapseBtn.BackgroundColor3 = GRAY_PANEL
CollapseBtn.AutoButtonColor = false
CollapseBtn.Text = "-"
CollapseBtn.Font = Enum.Font.GothamBold
CollapseBtn.TextSize = 18
CollapseBtn.TextColor3 = PINK
CollapseBtn.Parent = Header
Instance.new("UICorner", CollapseBtn).CornerRadius = UDim.new(0, 8)
do
    local st = Instance.new("UIStroke", CollapseBtn)
    st.Color = RED
    st.Thickness = 1.2
    st.Transparency = 0.2
end

local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Position = UDim2.fromOffset(0, HEADER_H)
Body.Size = UDim2.fromOffset(WIN_W, BODY_H)
Body.BackgroundTransparency = 1
Body.Parent = MainFrame

-- current task
local TaskBlock = Instance.new("Frame")
TaskBlock.Position = UDim2.fromOffset(10, 10)
TaskBlock.Size = UDim2.fromOffset(WIN_W - 20, 40)
TaskBlock.BackgroundColor3 = GRAY_PANEL
TaskBlock.BorderSizePixel = 0
TaskBlock.Parent = Body
Instance.new("UICorner", TaskBlock).CornerRadius = UDim.new(0, 8)

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.fromOffset(8, 8)
StatusDot.Position = UDim2.new(0, 10, 0.5, -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(90, 220, 130)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = TaskBlock
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

local StatusAction = Instance.new("TextLabel")
StatusAction.Size = UDim2.new(1, -34, 1, -4)
StatusAction.Position = UDim2.fromOffset(26, 2)
StatusAction.BackgroundTransparency = 1
StatusAction.Text = "Idle"
StatusAction.TextColor3 = TEXT_COL
StatusAction.Font = Enum.Font.GothamBold
StatusAction.TextSize = 12
StatusAction.TextWrapped = true
StatusAction.TextXAlignment = Enum.TextXAlignment.Left
StatusAction.Parent = TaskBlock
ValueLabels["CurrentTask"] = StatusAction

-- item counters
for i, key in ipairs(ROWS) do
    local row = Instance.new("Frame")
    row.Position = UDim2.fromOffset(10, 58 + (i - 1) * (ROW_H + 4))
    row.Size = UDim2.fromOffset(WIN_W - 20, ROW_H)
    row.BackgroundColor3 = GRAY_CELL
    row.BackgroundTransparency = 0.2
    row.BorderSizePixel = 0
    row.Parent = Body
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local k = Instance.new("TextLabel")
    k.Size = UDim2.new(0.6, 0, 1, 0)
    k.Position = UDim2.fromOffset(10, 0)
    k.BackgroundTransparency = 1
    k.Text = key .. ":"
    k.Font = Enum.Font.GothamMedium
    k.TextSize = 12
    k.TextColor3 = PINK_DIM
    k.TextXAlignment = Enum.TextXAlignment.Left
    k.Parent = row

    local v = Instance.new("TextLabel")
    v.Size = UDim2.new(0.4, -10, 1, 0)
    v.Position = UDim2.new(0.6, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.Text = "0"
    v.Font = Enum.Font.GothamBold
    v.TextSize = 13
    v.TextColor3 = TEXT_COL
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.Parent = row
    ValueLabels[key] = v
end

-- drag (header) - mouse + touch
do
    local dragging, dragStart, startPos, dragInput
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local d = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- collapse: "-" (open) / "+" (collapsed)
local expanded = true
CollapseBtn.MouseButton1Click:Connect(function()
    expanded = not expanded
    Body.Visible = expanded
    HeaderLine.Visible = expanded
    CollapseBtn.Text = expanded and "-" or "+"
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.fromOffset(WIN_W, expanded and WIN_H or HEADER_H) }):Play()
end)

RunService.RenderStepped:Connect(function()
    StatusDot.BackgroundTransparency = math.abs(math.sin(tick() * 4)) * 0.8
end)

getgenv().Meyy6Race_API = {
    SetValue = function(key, val)
        local label = ValueLabels[key]
        if label and label.Text ~= tostring(val) then
            label.Text = tostring(val)
        end
    end,
    SetTask = function(taskText)
        if ValueLabels["CurrentTask"] then
            ValueLabels["CurrentTask"].Text = tostring(taskText)
        end
    end,
    SetTheme = function(themeName)
        ChangeTheme(themeName)
    end
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemReplicationService = require(ReplicatedStorage:WaitForChild("ItemReplicationService"))
local KEYS = require(ReplicatedStorage.ItemReplicationService.KEYS)
local ItemConfig = require(ReplicatedStorage:WaitForChild("ItemConfig"))

while ItemReplicationService.IsInitialized ~= true do
    task.wait()
end



local function getItemName(itemId)
    local ok, name = pcall(function()
        return ItemConfig.match(itemId):unwrap().Index.DebugLabel
    end)
    if ok and name then
        return name
    end
    return "Unknown_" .. tostring(itemId)
end


local function GetIdItem(targetName)
    local quantityItems = ItemReplicationService:GetItems(KEYS.QUANTITY)
    if not quantityItems then return nil end

    local targetClean = string.lower(string.gsub(targetName, "%s+", ""))

    for _, item in pairs(quantityItems) do
        local rawName = getItemName(item.ItemId)
        local cleanName = string.match(rawName, "^(.-)%s*%[") or rawName
        local cleanMatch = string.lower(string.gsub(cleanName, "%s+", ""))

        if cleanMatch == targetClean then
            if string.find(rawName, "%[Material%-") or not string.find(rawName, "%[Accessory%-") then
                return item.ItemId
            end
        end
    end

    for _, item in pairs(quantityItems) do
        local rawName = getItemName(item.ItemId)
        if string.find(rawName, "%[Material%-") then
            local cleanName = string.match(rawName, "^(.-)%s*%[") or rawName
            local cleanMatch = string.lower(string.gsub(cleanName, "%s+", ""))
            if string.find(cleanMatch, targetClean, 1, true) then
                return item.ItemId
            end
        end
    end

    return nil
end



local function getItemCount(targetItemId)
    local quantityItems = ItemReplicationService:GetItems(KEYS.QUANTITY)
    if quantityItems then
        for _, item in pairs(quantityItems) do
            if item.ItemId == targetItemId then
                return item.Value or 0
            end
        end
    end
    return 0
end



local function CountItem(ItemName)
    local itemId = GetIdItem(ItemName)
    if itemId then
        return getItemCount(itemId)
    else
        return 0
    end
end


task.spawn(function()
    local itemsToCheck = {
        "Fool's Gold",
        "Shark Tooth",
        "Electric Wing",
        "Mutant Tooth",
        "Terror Eyes"
    }
    
    local lastCounts = {}
    
    while task.wait(0.5) do
        for _, itemName in ipairs(itemsToCheck) do
            local currentCount = CountItem(itemName)
            
            if lastCounts[itemName] == nil or currentCount ~= lastCounts[itemName] then
                lastCounts[itemName] = currentCount
                                
                if getgenv().Meyy6Race_API and getgenv().Meyy6Race_API.SetValue then
                    local targetName = itemName
                    local targetCount = currentCount
                    task.defer(function()
                        getgenv().Meyy6Race_API.SetValue(targetName, targetCount)
                    end)
                end
            end
        end
    end
end)

getgenv().CurrentTarget = nil
getgenv().CurrentTargetPart = nil
getgenv().MacroAimPos = nil

getgenv().IsPureM1 = false
getgenv().UseOnlyGunSkill = false

getgenv().currentEquippedGun = nil

local function checkEquippedGun()
    local character = game:GetService("Players").LocalPlayer.Character
    if not character then
        return nil
    end

    local equippedTool = character:FindFirstChildOfClass("Tool")
    if equippedTool then
        return equippedTool.Name
    else
        return nil
    end
end

task.spawn(function()
    while task.wait(0.1) do
        getgenv().currentEquippedGun = checkEquippedGun()
    end
end)

task.spawn(function()
    pcall(function()
        -- [INLINE FastAttack — original: https://pastefy.app/45hCw1JE/raw]
(function() --begin FastAttack
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Modules = ReplicatedStorage:FindFirstChild("Modules")
local Net = Modules and Modules:FindFirstChild("Net")
local RegisterAttack = Net and Net:FindFirstChild("RE/RegisterAttack")
local RegisterHit = Net and Net:FindFirstChild("RE/RegisterHit")
local ShootGunEvent = Net and Net:FindFirstChild("RE/ShootGunEvent")
local GunValidator = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Validator2")

local LocalPlayer = Players.LocalPlayer
local NetModule
pcall(function()
    if Modules and Modules:FindFirstChild("Net") then
        NetModule = require(Modules.Net)
    end
end)

local Remotes = {}
local Assets = ReplicatedStorage:WaitForChild("Assets")

local RemoteFolder = ReplicatedStorage:FindFirstChild("Remotes")
if RemoteFolder then
    for _, child in ipairs(RemoteFolder:GetChildren()) do
        if child:IsA("RemoteEvent") then
            local id = child:GetAttribute("Id")
            if id then
                Remotes[id] = child
            end
        end
    end

    RemoteFolder.ChildAdded:Connect(function(child)
        if child:IsA("RemoteEvent") then
            local id = child:GetAttribute("Id")
            if id then
                Remotes[id] = child
            end
        end
    end)
end

local KillTrap = {
    LockedTargets = {}, 
    StuckTimeout = 1.5
}

function KillTrap:Process(enemy)
    local hum = enemy:FindFirstChild("Humanoid")
    if not hum then 
        if self.LockedTargets[enemy] then
            self.LockedTargets[enemy] = nil
        end
        return false 
    end
    
    local currentHealth = hum.Health
    local data = self.LockedTargets[enemy]

    if currentHealth <= 0 then
        if self.LockedTargets[enemy] then
            self.LockedTargets[enemy] = nil
        end
        return false
    end

    if not data then
        self.LockedTargets[enemy] = {
            lastHealth = currentHealth,
            lastChangeTime = tick()
        }
        return true
    end

    if currentHealth < data.lastHealth then
        data.lastHealth = currentHealth
        data.lastChangeTime = tick()
        return true
    elseif currentHealth == data.lastHealth then
        if tick() - data.lastChangeTime > self.StuckTimeout then
            self.LockedTargets[enemy] = nil
            return false
        end
        return true
    else
        data.lastHealth = currentHealth
        data.lastChangeTime = tick()
        return true
    end
end

---------
local function GetClosestEnemy()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local closestEnemy = nil
    local shortestDistance = math.huge

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    local charsFolder = workspace:FindFirstChild("Characters")
    local seaBeastsFolder = workspace:FindFirstChild("SeaBeasts")
    
    local function Scan(folder)
        if not folder then return end
        for _, enemy in ipairs(folder:GetChildren()) do
            if enemy:IsA("Model") and enemy ~= character then
                local n = enemy.Name
                local isSeaBeast = (folder.Name == "SeaBeasts") or n:find("SeaBeast") or n == "Leviathan Segment" or n == "Leviathan"
                local isShip = n:find("PirateBrigade") or n:find("PirateGrandBrigade") or n:find("Brigade")
                
                if isSeaBeast then
                    local pivotSuccess, pivot = pcall(function() return enemy:GetPivot() end)
                    if pivotSuccess and pivot then
                        local dist = (rootPart.Position - pivot.Position).Magnitude
                        if dist <= 6000 and dist < shortestDistance then
                            closestEnemy = enemy
                            shortestDistance = dist
                        end
                    end
                elseif isShip then
                    local healthVal = enemy:FindFirstChild("Health")
                    if healthVal and healthVal.Value > 0 then
                        local pivotSuccess, pivot = pcall(function() return enemy:GetPivot() end)
                        if pivotSuccess and pivot then
                            local dist = (rootPart.Position - pivot.Position).Magnitude
                            if dist <= 6000 and dist < shortestDistance then
                                closestEnemy = enemy
                                shortestDistance = dist
                            end
                        end
                    end
                else
                    local root = enemy:FindFirstChild("HumanoidRootPart")
                    local hum = enemy:FindFirstChild("Humanoid")
                    if root and hum and hum.Health > 0 then
                        local dist = (rootPart.Position - root.Position).Magnitude
                        if dist <= 6000 then
                            KillTrap:Process(enemy)
                        end
                    end
                end
            end
        end
    end

    Scan(enemiesFolder)
    Scan(seaBeastsFolder)
    Scan(charsFolder)

    for enemy, _ in pairs(KillTrap.LockedTargets) do
        if KillTrap:Process(enemy) then
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
            if enemyRoot then
                local distance = (rootPart.Position - enemyRoot.Position).Magnitude
                if distance < shortestDistance then
                    closestEnemy = enemy
                    shortestDistance = distance
                end
            end
        end
    end
    
    return closestEnemy
end

local function Attack()
    local character = LocalPlayer.Character
    if not character then return end
    
    ---------
    local tool = character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    ---------
    if not tool or tool:GetAttribute("WeaponType") ~= "Melee" then return end

    local enemy = GetClosestEnemy()
    if enemy then
        local regAttack = Remotes["RE/RegisterAttack"] or RegisterAttack
        if regAttack then
            regAttack:FireServer()
        end

        local hitPart = enemy:FindFirstChild("Head") or enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart or enemy:FindFirstChildWhichIsA("BasePart")
        if hitPart then
            local regHit = Remotes["RE/RegisterHit"] or RegisterHit
            if regHit then
                regHit:FireServer(enemy, hitPart)
            end
            if NetModule and NetModule.RemoteEvent then
                NetModule:RemoteEvent("RegisterHit"):FireServer(enemy, hitPart)
            end
        end
    end
end

local function GetBladeHits()
    local targets = {}
    local char = game.Players.LocalPlayer.Character
    if not char then return targets end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return targets end

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    local charsFolder = workspace:FindFirstChild("Characters")
    local seaBeastsFolder = workspace:FindFirstChild("SeaBeasts")
    
    local function CheckFolder(folder)
        if not folder then return end
        for _, v in pairs(folder:GetChildren()) do
            if v:IsA("Model") and v ~= char then
                local n = v.Name
                local isSeaBeast = (folder.Name == "SeaBeasts") or n:find("SeaBeast") or n == "Leviathan Segment" or n == "Leviathan"
                local isShip = n:find("PirateBrigade") or n:find("PirateGrandBrigade") or n:find("Brigade")

                if isSeaBeast then
                    local pivotSuccess, pivot = pcall(function() return v:GetPivot() end)
                    if pivotSuccess and pivot then
                        if (pivot.Position - root.Position).Magnitude <= 6000 then
                            table.insert(targets, v)
                        end
                    end
                elseif isShip then
                    local healthVal = v:FindFirstChild("Health")
                    if healthVal and healthVal.Value > 0 then
                        local pivotSuccess, pivot = pcall(function() return v:GetPivot() end)
                        if pivotSuccess and pivot then
                            if (pivot.Position - root.Position).Magnitude <= 6000 then
                                table.insert(targets, v)
                            end
                        end
                    end
                elseif v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
                    local dist = (v.HumanoidRootPart.Position - root.Position).Magnitude
                    if dist <= 6000 then
                        KillTrap:Process(v)
                    end
                end
            end
        end
    end

    CheckFolder(enemiesFolder)
    CheckFolder(seaBeastsFolder)
    CheckFolder(charsFolder)

    for enemy, _ in pairs(KillTrap.LockedTargets) do
        if KillTrap:Process(enemy) then
            table.insert(targets, enemy)
        end
    end

    return targets
end

local function AttackAll()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end

    ---------
    local equippedWeapon = character:FindFirstChild("EquippedWeapon") or player.Backpack:FindFirstChildOfClass("Tool")
    ---------
    if not equippedWeapon then return end

    local regAttack = Remotes["RE/RegisterAttack"] or RegisterAttack
    local regHit = Remotes["RE/RegisterHit"] or RegisterHit
    
    local enemies = GetBladeHits()
    if #enemies > 0 then
        if regAttack then
            regAttack:FireServer(-math.huge)
        end
        
        local args = {nil, {}}
        for i, v in pairs(enemies) do
            local hitPart = v:FindFirstChild("Head") or v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
            if not args[1] then
                args[1] = hitPart
            end
            args[2][i] = {v, hitPart}
        end
        
        if args[1] and regHit then
            regHit:FireServer(unpack(args))
        end
    end
end
---------

---------
RunService.Stepped:Connect(function()
    AttackAll()
end)
---------

local Config = {
    AttackDistance = 65,
    AttackMobs = true,
    AttackPlayers = true,
    AttackCooldown = 0,
    ComboResetTime = 0,
    MaxCombo = 2,
    HitboxLimbs = {"RightLowerArm", "RightUpperArm", "LeftLowerArm", "LeftUpperArm", "RightHand", "LeftHand"},
    AutoClickEnabled = true
}

local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        Debounce = 0,
        ComboDebounce = 0,
        ShootDebounce = 0,
        M1Combo = 0,
        EnemyRootPart = nil,
        Connections = {},
        Overheat = {Dragonstorm = {MaxOverheat = 3, Cooldown = 0, TotalOverheat = 0, Distance = 350, Shooting = false}},
        ShootsPerTarget = {["Dual Flintlock"] = 2},
        SpecialShoots = {["Skull Guitar"] = "TAP", ["Bazooka"] = "Position", ["Cannon"] = "Position", ["Dragonstorm"] = "Overheat"}
    }, FastAttack)
    
    pcall(function()
        local CombatController = require(ReplicatedStorage.Controllers.CombatController)
        if getupvalue then
            self.ShootFunction = getupvalue(CombatController.Attack, 9)
        end
        
        local Flags = Modules:FindFirstChild("Flags")
        if Flags then
            self.CombatFlags = require(Flags).COMBAT_REMOTE_THREAD
        end

        local LocalScript = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if LocalScript and getsenv then
            local env = getsenv(LocalScript)
            if env._G and env._G.SendHitsToServer then
                self.HitFunction = env._G.SendHitsToServer
            end
        end
    end)
    
    return self
end

function FastAttack:IsEntityAlive(entity)
    local humanoid = entity and entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

function FastAttack:CheckStun(Character, Humanoid, ToolTip)
    local Stun = Character:FindFirstChild("Stun")
    local Busy = Character:FindFirstChild("Busy")
    if Humanoid.Sit and (ToolTip == "Sword" or ToolTip == "Melee" or ToolTip == "Blox Fruit") then
        return false
    elseif (Stun and Stun.Value > 0) or (Busy and Busy.Value) then
        return false
    end
    return true
end

function FastAttack:GetBladeHits(Character, Distance)
    local Position = Character:GetPivot().Position
    local BladeHits = {}
    local MaxDist = Distance or 6000
    
    local function ScanForNewTargets(Folder)
        if not Folder then return end
        for _, Enemy in ipairs(Folder:GetChildren()) do
            if Enemy ~= Character then
                local n = Enemy.Name
                local isSeaBeast = (Folder.Name == "SeaBeasts") or n:find("SeaBeast") or n == "Leviathan Segment" or n == "Leviathan"
                local isShip = n:find("PirateBrigade") or n:find("PirateGrandBrigade") or n:find("Brigade")
                
                if isSeaBeast or isShip then
                    local pivotSuccess, pivot = pcall(function() return Enemy:GetPivot() end)
                    if pivotSuccess and pivot then
                        if (Position - pivot.Position).Magnitude <= MaxDist then
                            local BasePart = Enemy:FindFirstChild("Head") or Enemy:FindFirstChild("Hitbox") or Enemy:FindFirstChild("HumanoidRootPart") or Enemy.PrimaryPart or Enemy:FindFirstChildWhichIsA("BasePart")
                            if BasePart then
                                if not self.EnemyRootPart then
                                    self.EnemyRootPart = BasePart
                                else
                                    table.insert(BladeHits, {Enemy, BasePart})
                                end
                            end
                        end
                    end
                elseif self:IsEntityAlive(Enemy) then
                    local root = Enemy:FindFirstChild("HumanoidRootPart")
                    if root and (Position - root.Position).Magnitude <= MaxDist then
                        KillTrap:Process(Enemy)
                    end
                end
            end
        end
    end

    if Config.AttackMobs then 
        ScanForNewTargets(Workspace:FindFirstChild("Enemies")) 
        ScanForNewTargets(Workspace:FindFirstChild("SeaBeasts")) 
    end
    if Config.AttackPlayers then ScanForNewTargets(Workspace:FindFirstChild("Characters")) end

    for Enemy, _ in pairs(KillTrap.LockedTargets) do
        if KillTrap:Process(Enemy) then
            local BasePart = Enemy:FindFirstChild(Config.HitboxLimbs[math.random(#Config.HitboxLimbs)]) or Enemy:FindFirstChild("HumanoidRootPart")
            if BasePart then
                if not self.EnemyRootPart then
                    self.EnemyRootPart = BasePart
                else
                    table.insert(BladeHits, {Enemy, BasePart})
                end
            end
        end
    end
    
    return BladeHits
end

function FastAttack:GetClosestEnemy(Character, Distance)
    local BladeHits = self:GetBladeHits(Character, Distance)
    local Closest, MinDistance = nil, math.huge
    
    for _, Hit in ipairs(BladeHits) do
        local Magnitude = (Character:GetPivot().Position - Hit[2].Position).Magnitude
        if Magnitude < MinDistance then
            MinDistance = Magnitude
            Closest = Hit[2]
        end
    end
    return Closest
end

function FastAttack:GetCombo()
    self.ComboDebounce = tick()
    self.M1Combo = 3
    return 3
end

function FastAttack:ShootInTarget(TargetPosition)
    local Character = Player.Character
    if not Character then return end
    
    local Equipped = Character:FindFirstChildOfClass("Tool") or Player.Backpack:FindFirstChildOfClass("Tool")
    if not Equipped or Equipped.ToolTip ~= "Gun" then return end
    
    local Cooldown = Equipped:FindFirstChild("Cooldown") and Equipped.Cooldown.Value or 0.3
    if (tick() - self.ShootDebounce) < Cooldown then return end
    
    local ShootType = self.SpecialShoots[Equipped.Name] or "Normal"
    if ShootType == "Position" or (ShootType == "TAP" and Equipped:FindFirstChild("RemoteEvent")) then
        Equipped:SetAttribute("LocalTotalShots", (Equipped:GetAttribute("LocalTotalShots") or 0) + 1)
        
        if self.ShootFunction and getupvalue and GunValidator then
            GunValidator:FireServer(self:GetValidator2())
        end
        
        if ShootType == "TAP" and Equipped:FindFirstChild("RemoteEvent") then
            Equipped.RemoteEvent:FireServer("TAP", TargetPosition)
        elseif ShootGunEvent then
            ShootGunEvent:FireServer(TargetPosition)
        end
        self.ShootDebounce = tick()
    else
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        self.ShootDebounce = tick()
    end
end

function FastAttack:GetValidator2()
    if not getupvalue or not setupvalue or not self.ShootFunction then return 0, 0 end
    
    local u27 = getupvalue(self.ShootFunction, 13)
    local u23 = getupvalue(self.ShootFunction, 14)
    local u26 = getupvalue(self.ShootFunction, 15)
    local u22 = getupvalue(self.ShootFunction, 16)
    local u24 = getupvalue(self.ShootFunction, 17)
    local u25 = getupvalue(self.ShootFunction, 18)
    local u28 = getupvalue(self.ShootFunction, 19)
    
    local u81 = u27 * u23
    local u82 = (u26 * u23 + u27 * u22) % u24
    u82 = (u82 * u24 + u81) % u25
    u26 = math.floor(u82 / u24)
    u27 = u82 - u26 * u24
    u28 = u28 + 1
    
    setupvalue(self.ShootFunction, 13, u27)
    setupvalue(self.ShootFunction, 14, u23)
    setupvalue(self.ShootFunction, 15, u26)
    setupvalue(self.ShootFunction, 16, u22)
    setupvalue(self.ShootFunction, 17, u24)
    setupvalue(self.ShootFunction, 18, u25)
    setupvalue(self.ShootFunction, 19, u28)
    
    return math.floor(u82 / u25 * 16777215), u28
end

function FastAttack:UseNormalClick(Character, Humanoid, Cooldown)
    self.EnemyRootPart = nil
    local BladeHits = self:GetBladeHits(Character)
    
    local regAttack = Remotes["RE/RegisterAttack"] or RegisterAttack
    local regHit = Remotes["RE/RegisterHit"] or RegisterHit

    if self.EnemyRootPart or #BladeHits > 0 then
        if regAttack then
            regAttack:FireServer(-math.huge) 
        end

        if self.EnemyRootPart then
            local HitTable = {}
            if self.EnemyRootPart.Parent then
                table.insert(HitTable, {self.EnemyRootPart.Parent, self.EnemyRootPart})
            end
            for _, hitData in ipairs(BladeHits) do
                table.insert(HitTable, {hitData[1], hitData[2]})
            end

            if self.CombatFlags and self.HitFunction then
                self.HitFunction(self.EnemyRootPart, HitTable)
            elseif regHit then
                regHit:FireServer(self.EnemyRootPart, HitTable)
            end
        end
    end
end

function FastAttack:UseFruitM1(Character, Equipped, Combo)
    local Targets = self:GetBladeHits(Character)
    
    if #Targets > 0 or self.EnemyRootPart then
        local Direction
        if Targets[1] then
            Direction = (Targets[1][2].Position - Character:GetPivot().Position).Unit
        else
            Direction = Character:GetPivot().LookVector
        end
        local remote = Equipped:FindFirstChild("LeftClickRemote")
        if remote then
            remote:FireServer(Direction, Combo)
        end
    end
end

function FastAttack:Attack()
    if not Config.AutoClickEnabled or (tick() - self.Debounce) < Config.AttackCooldown then return end
    local Character = Player.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    
    local Equipped = Character:FindFirstChildOfClass("Tool") or Player.Backpack:FindFirstChildOfClass("Tool")
    if not Equipped then return end
    
    local ToolTip = Equipped.ToolTip
    if not table.find({"Melee", "Blox Fruit", "Sword", "Gun"}, ToolTip) then return end
    
    local CooldownVal = Equipped:FindFirstChild("Cooldown")
    local Cooldown = CooldownVal and CooldownVal.Value or Config.AttackCooldown
    if not self:CheckStun(Character, Humanoid, ToolTip) then return end
    
    local Combo = self:GetCombo()
    Cooldown = Cooldown + (Combo >= Config.MaxCombo and 0.05 or 0)
    self.Debounce = Combo >= Config.MaxCombo and ToolTip ~= "Gun" and (tick() + 0.05) or tick()
    
    if ToolTip == "Blox Fruit" and Equipped:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(Character, Equipped, Combo)
    elseif ToolTip == "Gun" then
        local Target = self:GetClosestEnemy(Character, 120)
        if Target then
            self:ShootInTarget(Target.Position)
        end
    else
        self:UseNormalClick(Character, Humanoid, Cooldown)
    end
end

local AttackInstance = FastAttack.new()

table.insert(AttackInstance.Connections, RunService.Stepped:Connect(function()
    AttackInstance:Attack()
end))

if getgc and hookfunction then
    for _, v in pairs(getgc(true)) do
        if typeof(v) == "function" and iscclosure(v) then
            local info = debug.getinfo(v)
            local name = info and info.name
            if name == "Attack" or name == "attack" or name == "RegisterHit" then
                pcall(function()
                    hookfunction(v, function(...)
                        AttackInstance:Attack()
                        return v(...)
                    end)
                end)
            end
        end
    end
end
end)() --end FastAttack
    end)
end)

repeat
    task.wait(0.5)
until LP.Team ~= nil and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

local Library = -- [INLINE UI Library — original: https://pastefy.app/frkIutHc/raw]
(function() --begin UI Library

local Library = {}
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

---------
local HttpService = game:GetService("HttpService")

local isfolder = isfolder or function() return false end
local makefolder = makefolder or function() end
local writefile = writefile or function() end
local readfile = readfile or function() return "" end
local isfile = isfile or function() return false end

Library.ConfigFolder = "HubPremium_Configs"
Library.ConfigElements = {}



local saveTick = 0
function Library:AutoSave()
    if Library.IsLoading then return end
    saveTick = tick()
    task.delay(0.5, function()
        if tick() - saveTick >= 0.45 then
            Library:SaveConfig("AutoSave", true)
        end
    end)
end
---------

---------
local UI_Elements = {
    AnimatedGradients = {},
    AnimatedStrokes = {},
    RowStrokes = {},
    RowStrokeGradients = {},
    DivGradients = {},
    TabGradients = {},
    Switches = {},
    TextGradients = {},
    RotatingGradients = {},
    Containers = {},
    TabBackgrounds = {},
    PageElements = {},
    Descriptions = {},
    TabIcons = {},
    TextObjects = {}
}
---------


---------
local CurrentTheme = "Dark"
local Notifications = {}

local exactFruitSeq = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromHex("#B4DCFF")), 
    ColorSequenceKeypoint.new(0.5, Color3.fromHex("#FFFFFF")), 
    ColorSequenceKeypoint.new(1, Color3.fromHex("#B4DCFF"))
})


---------
local Themes = {
    ["Ocean"] = {
        MainBg = Color3.fromHex("#D3D3D3"),
        MainBgTrans = 0.3,
        ContainerBg = Color3.fromHex("#FFFFFF"),
        ContainerTrans = 0.8,
        TextColor = Color3.fromHex("#FFFFFF"),
        DescTextColor = Color3.fromHex("#969696"),
        MainStroke = Color3.fromHex("#FFFFFF"),
        TextContrast = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#B4DCFF")),
            ColorSequenceKeypoint.new(0.50, Color3.fromHex("#B4DCFF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
        }),
        Wave = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#E0F0FF")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#FFFFFF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#E0F0FF"))
        }),
        TitleStroke = Color3.fromHex("#ADD8E6"),
        TextGrad = exactFruitSeq,
        TabGrad = exactFruitSeq,
        DivGrad = exactFruitSeq,
        RowStroke = Color3.fromHex("#ADD8E6"),
        RowStrokeGrad = exactFruitSeq,
        ToggleActive = Color3.fromHex("#96C8DC"),
        LoopSeq = exactFruitSeq,
        SearchIconColor = Color3.fromHex("#333333")
    },
 
    ["Dream"] = {
        MainBg = Color3.fromHex("#0A1428"),
        MainBgTrans = 0.2,
        ContainerBg = Color3.fromHex("#151C3B"),
        ContainerTrans = 0.5,
        TextColor = Color3.fromHex("#E6FFFF"),
        DescTextColor = Color3.fromHex("#FFFFFF"),
        MainStroke = Color3.fromHex("#D3D3D3"),
        TextContrast = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#46E6FF")),
            ColorSequenceKeypoint.new(0.50, Color3.fromHex("#8C64FF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#46E6FF"))
        }),
        Wave = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#151C3B")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#46E6FF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#151C3B"))
        }),
        TitleStroke = Color3.fromHex("#140A32"),
        TextGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#B4FFFF")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#A08CFF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#8C64FF"))
        }),
        TabGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#46E6FF")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#8C64FF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#46E6FF"))
        }),
        DivGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#151C3B")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#8C64FF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#151C3B"))
        }),
        RowStroke = Color3.fromHex("#808080"),
        RowStrokeGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#46E6FF")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#8C64FF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#46E6FF"))
        }),
        ToggleActive = Color3.fromHex("#8C64FF"),
        LoopSeq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#8C64FF")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#46E6FF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#8C64FF"))
        }),
        SearchIconColor = Color3.fromHex("#8C64FF")
    },

    ["Dark"] = {
        MainBg = Color3.fromHex("#000000"),
        MainBgTrans = 0.3,
        ContainerBg = Color3.fromHex("#525252"), 
        ContainerTrans = 0.6,
        TextColor = Color3.fromHex("#FFFFFF"),
        DescTextColor = Color3.fromHex("#FFFFFF"),
        MainStroke = Color3.fromHex("#FFFFFF"), 
        TextContrast = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#808080")),
            ColorSequenceKeypoint.new(0.50, Color3.fromHex("#D3D3D3")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#000000"))
        }),
        Wave = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#0D0D0D")), 
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#1A1A1A")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#0D0D0D"))
        }),
        TitleStroke = Color3.fromHex("#222222"),
        TextGrad = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")), 
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#8A8A8A")), 
            ColorSequenceKeypoint.new(1, Color3.fromHex("#1A1A1A")) 
        }),
        TabGrad = ColorSequence.new({ 
            ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#777777")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
        }),
        DivGrad = ColorSequence.new({ 
            ColorSequenceKeypoint.new(0, Color3.fromHex("#222222")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#888888")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#222222"))
        }),
        RowStroke = Color3.fromHex("#FFFFFF"), 
        RowStrokeGrad = ColorSequence.new({ 
            ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")), 
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#555555")), 
            ColorSequenceKeypoint.new(1, Color3.fromHex("#54626F")) 
        }),
        ToggleActive = Color3.fromHex("#888888"),
        LoopSeq = ColorSequence.new({ 
            ColorSequenceKeypoint.new(0, Color3.fromHex("#AAAAAA")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#222222")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#000000"))
        }),
        SearchIconColor = Color3.fromHex("#FFFFFF")
    }
}
---------
local CurrentFont = Font.fromName("FredokaOne", Enum.FontWeight.Bold)
local CurrentFontScale = 1

local function ApplyTextGradient(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        obj.FontFace = CurrentFont
        obj.TextColor3 = Themes[CurrentTheme].TextColor
        
        local grad = Instance.new("UIGradient", obj)
        grad.Rotation = 90
        grad.Color = Themes[CurrentTheme].TextContrast
        table.insert(UI_Elements.TextGradients, grad)
        
        local shadow = Instance.new("UIStroke")
        shadow.Color = Themes[CurrentTheme].ToggleActive
        shadow.Thickness = 0.2
        shadow.Transparency = 0
        shadow.Parent = obj

        task.defer(function()
            if not obj or not obj.Parent then return end
            local base = obj.TextSize
            table.insert(UI_Elements.TextObjects, {Obj = obj, BaseSize = base})
            if CurrentFontScale ~= 1 then
                obj.TextSize = math.clamp(math.round(base * CurrentFontScale), 6, 60)
            end
        end)
    end
end

function Library:ApplyFont(fontName)
    local success, newFont = pcall(function()
        return Font.fromName(fontName, Enum.FontWeight.Bold)
    end)
    if not success or not newFont then
        newFont = Font.fromName(fontName)
    end
    CurrentFont = newFont
    for _, item in ipairs(UI_Elements.TextObjects) do
        if item.Obj and item.Obj.Parent then
            item.Obj.FontFace = newFont
        end
    end
end

function Library:ApplyFontScale(percent)
    CurrentFontScale = percent / 100
    for _, item in ipairs(UI_Elements.TextObjects) do
        if item.Obj and item.Obj.Parent then
            item.Obj.TextSize = math.clamp(math.round(item.BaseSize * CurrentFontScale), 6, 60)
        end
    end
end
Library.IsLoading = false

function Library:SaveConfig(fileName, silent)
    if not isfolder(Library.ConfigFolder) then
        makefolder(Library.ConfigFolder)
    end
    local data = {}
    for flag, element in pairs(Library.ConfigElements) do
        data[flag] = element.Value
    end
    local json = HttpService:JSONEncode(data)
    local actualFileName = LocalPlayer.Name .. "-Flowbr-" .. fileName
    writefile(Library.ConfigFolder .. "/" .. actualFileName .. ".json", json)
    if not silent then
        Library:SendNotification("Config System", "Saved " .. actualFileName)
    end
end

function Library:LoadConfig(fileName, silent)
    local actualFileName = LocalPlayer.Name .. "-Flowbr-" .. fileName
    local path = Library.ConfigFolder .. "/" .. actualFileName .. ".json"
    if isfile(path) then
        local json = readfile(path)
        local success, data = pcall(function()
            return HttpService:JSONDecode(json)
        end)
        if success and type(data) == "table" then
            Library.IsLoading = true
            for flag, value in pairs(data) do
                if Library.ConfigElements[flag] then
                    Library.ConfigElements[flag].Set(value)
                end
            end
            Library.IsLoading = false
            if not silent then
                Library:SendNotification("Config System", "Loaded " .. actualFileName)
            end
        else
            if not silent then
                Library:SendNotification("Config Error", "Failed to parse JSON")
            end
        end
    else
        if not silent then
            Library:SendNotification("Config Error", "File not found")
        end
    end
end
---------
function Library:SendNotification(titleText, descText)
    local g2 = Instance.new("ScreenGui")
    g2.Name = "UI_Cloud_Notification_" .. math.random(100, 999)
    g2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function() g2.Parent = CoreGui end)
    if not g2.Parent then g2.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    local m2 = Instance.new("Frame", g2)
    m2.Name = "Main"
    m2.BackgroundColor3 = Themes[CurrentTheme].MainBg
    m2.BackgroundTransparency = 0.3
    m2.Size = UDim2.new(0, 260, 0, 80)
    m2.AnchorPoint = Vector2.new(1, 1)
    m2.Position = UDim2.new(1, 50, 1, -20)
    Instance.new("UICorner", m2).CornerRadius = UDim.new(0, 10)
    
    local u2 = Instance.new("UIStroke", m2)
    u2.Thickness = 2.5
    u2.Color = Themes[CurrentTheme].MainStroke
    
    local e2 = Instance.new("UIGradient", u2)
    e2.Color = Themes[CurrentTheme].LoopSeq
    table.insert(UI_Elements.RotatingGradients, e2)
    
    local bgGradient = Instance.new("UIGradient", m2)
    bgGradient.Color = Themes[CurrentTheme].Wave
    
    local function CreateStatusLabel(name, pos, text, size)
        local label = Instance.new("TextLabel", m2)
        label.Name = name
        label.Size = UDim2.new(1, -20, 0, 25)
        label.Position = UDim2.new(0.5, 0, 0, pos)
        label.AnchorPoint = Vector2.new(0.5, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.Text = text
        label.TextSize = size or 12
        -------------------------
        ApplyTextGradient(label)
        -------------------------
        return label
    end
    
    local titleLabel = CreateStatusLabel("Title", 12, titleText, 16)
    local subLabel = CreateStatusLabel("Subtitle", 40, descText, 12)
    
    local renderSteppedConn
    renderSteppedConn = RunService.RenderStepped:Connect(function()
        bgGradient.Offset = Vector2.new(math.sin(tick() * 1.5) * 0.3, 0)
    end)
    
    for i, notif in ipairs(Notifications) do
        if notif and notif.Parent then
            local newY = -20 - (i * 90)
            TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 1, newY)}):Play()
        end
    end
    
    table.insert(Notifications, 1, m2)
    if #Notifications > 5 then
        local oldNotif = table.remove(Notifications, 6)
        if oldNotif then
            TweenService:Create(oldNotif, TweenInfo.new(0.3), {Position = UDim2.new(1, 300, 1, oldNotif.Position.Y.Offset)}):Play()
            task.delay(0.3, function() oldNotif.Parent:Destroy() end)
        end
    end
    
    local showTween = TweenService:Create(m2, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 1, -20)})
    showTween:Play()
    
    task.delay(3, function()
        for i, notif in ipairs(Notifications) do
            if notif == m2 then
                table.remove(Notifications, i)
                break
            end
        end
        local hideTween = TweenService:Create(m2, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 300, 1, m2.Position.Y.Offset)})
        hideTween:Play()
        hideTween.Completed:Connect(function()
            if renderSteppedConn then renderSteppedConn:Disconnect() end
            g2:Destroy()
            for i, notif in ipairs(Notifications) do
                if notif and notif.Parent then
                    local newY = -20 - ((i - 1) * 90)
                    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 1, newY)}):Play()
                end
            end
        end)
    end)
end

function Library:CreateWindow(config)
    local Window = {}
    config = config or {}
    local windowTitle = config.Title or "Hub Premium"
    
    if getgenv().MainUI_Library then
        pcall(function() getgenv().MainUI_Library:Destroy() end)
        getgenv().MainUI_Library = nil
    end
    
    local g = Instance.new("ScreenGui")
    g.Name = "Hub_Premium_" .. math.random(100, 999)
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    g.ResetOnSpawn = false
    
    pcall(function() g.Parent = CoreGui end)
    if not g.Parent then g.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    getgenv().MainUI_Library = g
    
---------
local AuraGlow = Instance.new("ImageLabel", g)
AuraGlow.Name = "AuraGlow"
AuraGlow.BackgroundTransparency = 1
AuraGlow.Image = "rbxassetid://5028857084"
AuraGlow.ImageTransparency = 0.4
AuraGlow.ImageColor3 = Color3.fromHex("#E0E0E0")
AuraGlow.ZIndex = 0
AuraGlow.AnchorPoint = Vector2.new(0.5, 0.5)

Instance.new("UICorner", AuraGlow).CornerRadius = UDim.new(0, 15)

local auraScale = Instance.new("UIScale", AuraGlow)

local m = Instance.new("Frame", g)
m.Name = "MainFrame"
m.BackgroundColor3 = Themes[CurrentTheme].MainBg
m.BackgroundTransparency = Themes[CurrentTheme].MainBgTrans
m.Size = UDim2.new(0, 600, 0, 525) -- Updated Ratio 400:350
m.Position = UDim2.new(0.5, 0, 0.5, 0)
m.AnchorPoint = Vector2.new(0.5, 0.5)
m.ClipsDescendants = true
Instance.new("UICorner", m).CornerRadius = UDim.new(0, 15)

local function UpdateAura()
    local targetWidth = m.Size.X.Scale == 1 and 600 or m.Size.X.Offset
    local factor = math.clamp(targetWidth / 600, 0, 1)
    
    local expandX = 105 * factor 
    local expandY = 95 * factor 

    AuraGlow.Position = m.Position
    AuraGlow.Size = UDim2.new(m.Size.X.Scale, m.Size.X.Offset + expandX, m.Size.Y.Scale, m.Size.Y.Offset + expandY)
    AuraGlow.Visible = m.Visible
end
m:GetPropertyChangedSignal("Position"):Connect(UpdateAura)
m:GetPropertyChangedSignal("Size"):Connect(UpdateAura)
m:GetPropertyChangedSignal("Visible"):Connect(UpdateAura)
UpdateAura()
---------
    ---------
local isMini = false
    local isMax = false

    local mainScale = Instance.new("UIScale", m)
    mainScale.Scale = 1
    
    mainScale:GetPropertyChangedSignal("Scale"):Connect(function()
        if g:FindFirstChild("AuraGlow") and g.AuraGlow:FindFirstChildOfClass("UIScale") then
            g.AuraGlow:FindFirstChildOfClass("UIScale").Scale = mainScale.Scale
        end
    end)
    
    local function UpdateUIScale()
        if not g then return end
        
        if m.Size.X.Scale == 1 and m.Size.Y.Scale == 1 then 
            TweenService:Create(mainScale, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 1}):Play()
            return 
        end
        
        local screenSize = g.AbsoluteSize
        if screenSize.X > 0 and screenSize.Y > 0 then
            local targetScale = math.clamp(math.min(screenSize.X / 650, screenSize.Y / 600), 0.45, 1)
            TweenService:Create(mainScale, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = targetScale}):Play()
        end
    end
    
    UpdateUIScale()
    g:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateUIScale)
    m:GetPropertyChangedSignal("Size"):Connect(UpdateUIScale)
---------


    local EdgeBarHitbox = Instance.new("TextButton", g)
    EdgeBarHitbox.Name = "EdgeBarHitbox"
    EdgeBarHitbox.Size = UDim2.new(0, 30, 0, 140) 
    EdgeBarHitbox.Position = UDim2.new(1, 0, 0.5, 0)
    EdgeBarHitbox.AnchorPoint = Vector2.new(1, 0.5)
    EdgeBarHitbox.BackgroundTransparency = 1 
    EdgeBarHitbox.Visible = false
    EdgeBarHitbox.Text = ""

    local EdgeBarVisual = Instance.new("Frame", EdgeBarHitbox)
    EdgeBarVisual.Size = UDim2.new(0, 4, 0, 120) 
    EdgeBarVisual.Position = UDim2.new(1, -2, 0.5, 0)
    EdgeBarVisual.AnchorPoint = Vector2.new(1, 0.5)
    EdgeBarVisual.BackgroundColor3 = Color3.fromHex("#FFFFFF")
    EdgeBarVisual.BackgroundTransparency = 0.8
    Instance.new("UICorner", EdgeBarVisual).CornerRadius = UDim.new(1, 0)

    local Mini3DIcon = Instance.new("Frame", g)
    Mini3DIcon.Name = "Mini3DIcon"
    Mini3DIcon.Size = UDim2.new(0, 140, 0, 140)
    Mini3DIcon.Position = UDim2.new(1, 150, 0.5, 0)
    Mini3DIcon.AnchorPoint = Vector2.new(1, 0.5)
    Mini3DIcon.BackgroundTransparency = 1
    Mini3DIcon.Visible = false

    local coreLayers = {}
    local baseSizes = {30, 45, 62, 78, 95, 112}    
    local baseTransparencies = {0.1, 0.3, 0.5, 0.7, 0.85, 0.93}
    for i = 1, #baseSizes do
        local layer = Instance.new("Frame")
        layer.AnchorPoint = Vector2.new(0.5, 0.5)
        layer.Position = UDim2.new(0.5, 0, 0.5, 0)
        layer.BorderSizePixel = 0
        layer.ZIndex = 3
        Instance.new("UICorner", layer).CornerRadius = UDim.new(1, 0)
        layer.Parent = Mini3DIcon
        table.insert(coreLayers, {frame = layer, baseSize = baseSizes[i], baseTrans = baseTransparencies[i]})
    end
    
    local phi = (1 + math.sqrt(5)) / 2
    local vertices = {
        Vector3.new(0, 1, phi), Vector3.new(0, -1, phi),
        Vector3.new(0, 1, -phi), Vector3.new(0, -1, -phi),
        Vector3.new(1, phi, 0), Vector3.new(-1, phi, 0),
        Vector3.new(1, -phi, 0), Vector3.new(-1, -phi, 0),
        Vector3.new(phi, 0, 1), Vector3.new(-phi, 0, 1),
        Vector3.new(phi, 0, -1), Vector3.new(-phi, 0, -1)
    }
    local edges = {}
    for i = 1, #vertices - 1 do
        for j = i + 1, #vertices do
            if math.abs((vertices[i] - vertices[j]).Magnitude - 2) < 0.1 then
                table.insert(edges, {i, j})
            end
        end
    end
    
    local lines, lineGradients = {}, {}
    for i = 1, #edges do
        local line = Instance.new("Frame")
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BackgroundColor3 = Color3.fromHex("#FFFFFF")
        line.BorderSizePixel = 0
        line.ZIndex = 3
        local lineGrad = Instance.new("UIGradient", line)
        table.insert(lineGradients, lineGrad)
        local glow = Instance.new("UIStroke", line)
        glow.Thickness = 2
        glow.Transparency = 0.4
        glow.Color = Color3.fromHex("#FFFFFF")
        local glowGrad = Instance.new("UIGradient", glow)
        table.insert(lineGradients, glowGrad)
        line.Parent = Mini3DIcon
        lines[i] = line
    end

  local MiniClickBtn = Instance.new("TextButton", Mini3DIcon)
    MiniClickBtn.Size = UDim2.new(1, 0, 1, 0)
    MiniClickBtn.BackgroundTransparency = 1
    MiniClickBtn.Text = ""
    MiniClickBtn.ZIndex = 10

    local angleX, angleY, r3D = 0, 0, 0
    local currentTiltX, currentTiltY = 0, 0
    local scale3D, perspective3D = 45, 150
    local function project3D(v3, aX, aY)
        local x, y, z = v3.X, v3.Y, v3.Z
        local cosY, sinY = math.cos(aY), math.sin(aY)
        x, z = x * cosY - z * sinY, x * sinY + z * cosY
        local cosX, sinX = math.cos(aX), math.sin(aX)
        y, z = y * cosX - z * sinX, y * sinX + z * cosX
        local factor = perspective3D / (perspective3D + z)
        return Vector2.new(x * factor * scale3D + 70, -y * factor * scale3D + 70), z
    end

    local clickCount = 0
    EdgeBarHitbox.MouseButton1Click:Connect(function()
        clickCount = clickCount + 1
        if clickCount == 1 then
            TweenService:Create(EdgeBarVisual, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, Size = UDim2.new(0, 6, 0, 140)}):Play()
            task.delay(0.6, function() 
                if clickCount == 1 then
                    clickCount = 0 
                    TweenService:Create(EdgeBarVisual, TweenInfo.new(0.2), {BackgroundTransparency = 0.8, Size = UDim2.new(0, 4, 0, 120)}):Play()
                end
            end)
        elseif clickCount == 2 then
            clickCount = 0
            EdgeBarHitbox.Visible = false
            Mini3DIcon.Visible = true
            TweenService:Create(Mini3DIcon, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 0.5, 0)}):Play()
        end
    end)


    ---------
    MiniClickBtn.MouseButton1Click:Connect(function()
        local tw = TweenService:Create(Mini3DIcon, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 150, 0.5, 0)})
        tw:Play()
        tw.Completed:Wait()
        Mini3DIcon.Visible = false
        
        local tgIcon = g:FindFirstChild("ToggleIcon")
        if tgIcon then tgIcon.Visible = true end
        
        m.Visible = true
        m.Size = UDim2.new(0, 0, 0, 0)
        m.Position = UDim2.new(1, 0, 0.5, 0)
        local targetSize = isMax and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 600, 0, 525)
        TweenService:Create(m, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = targetSize,
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        isMini = false
    end)
---------

-------------------------
    local SnowContainer = Instance.new("Frame", m)
    SnowContainer.Name = "SnowContainer"
    SnowContainer.Size = UDim2.new(1, -40, 1, -40)
    SnowContainer.Position = UDim2.new(0, 20, 0, 20)
    SnowContainer.BackgroundTransparency = 1
    SnowContainer.ZIndex = 0
    SnowContainer.ClipsDescendants = true
    Instance.new("UICorner", SnowContainer).CornerRadius = UDim.new(0, 15)
    
    task.spawn(function()
        while task.wait(0.15) do
            if not m.Visible or isMini then continue end
            local flake = Instance.new("ImageLabel", SnowContainer)
            flake.BackgroundTransparency = 1
            local iconId = "137906289429512"
            if CurrentTheme == "Dream" then iconId = "88081350809596"
            elseif CurrentTheme == "Dark" then iconId = "97956199432234" end
            
            flake.Image = "rbxthumb://type=Asset&id=" .. iconId .. "&w=150&h=150"
            
            local depth = math.random()
            
            local size = 13 + (7 * depth)
            flake.Size = UDim2.new(0, size, 0, size)
            
            flake.ImageTransparency = 0.8 - (0.6 * depth)
            flake.ZIndex = math.floor(depth * 3)
            
            local startX = math.random()
            flake.Position = UDim2.new(startX, 0, -0.1, 0)
            
            local fallDuration = 9 - (5 * depth)
            local swaySpeed = 1.2 + math.random()
            local swayAmount = 0.03 + (0.07 * depth)
            local randomOffset = math.random() * math.pi * 2
            local rotSpeed = 30 + (90 * depth)
            local rotDir = math.random(1, 2) == 1 and 1 or -1
            
            local startTime = tick()
            local renderConn
            renderConn = RunService.RenderStepped:Connect(function()
                if not flake or not flake.Parent then
                    if renderConn then renderConn:Disconnect() end
                    return
                end
                
                local elapsed = tick() - startTime
                local progress = elapsed / fallDuration
                
                if progress >= 1 then
                    flake:Destroy()
                    if renderConn then renderConn:Disconnect() end
                    return
                end
                
                local currentY = -0.1 + (1.2 * progress)
                local currentX = startX + math.sin(tick() * swaySpeed + randomOffset) * swayAmount
                
                flake.Position = UDim2.new(currentX, 0, currentY, 0)
                flake.Rotation = elapsed * rotSpeed * rotDir
            end)
        end
    end)
-------------------------
   ---------
local ToggleIcon = Instance.new("ImageButton", g)
ToggleIcon.Name = "ToggleIcon"
ToggleIcon.Size = UDim2.new(0, 45, 0, 45)
ToggleIcon.Position = UDim2.new(0, 20, 1, -65)
ToggleIcon.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
ToggleIcon.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
Instance.new("UICorner", ToggleIcon).CornerRadius = UDim.new(1, 0)

local rawIconId = "77000372466296"
local idClean = string.match(rawIconId, "%d+")
if idClean then
    ToggleIcon.Image = "rbxthumb://type=Asset&id=" .. idClean .. "&w=150&h=150"
else
    ToggleIcon.Image = rawIconId
end
ToggleIcon.ImageColor3 = Themes[CurrentTheme].TextColor

local iconStroke = Instance.new("UIStroke", ToggleIcon)
iconStroke.Thickness = 1.5
iconStroke.Color = Themes[CurrentTheme].MainStroke
table.insert(UI_Elements.AnimatedStrokes, {Obj = iconStroke, Type = "MainStroke"})

local iconStrokeGrad = Instance.new("UIGradient", iconStroke)
table.insert(UI_Elements.RotatingGradients, iconStrokeGrad)

local iconGrad = Instance.new("UIGradient", ToggleIcon)
iconGrad.Rotation = 45
iconGrad.Color = Themes[CurrentTheme].TextContrast

task.spawn(function()
    while task.wait(0.5) do
        if not ToggleIcon.Parent then break end
        if Themes[CurrentTheme] then
            ToggleIcon.ImageColor3 = Themes[CurrentTheme].TextColor
            ToggleIcon.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
            ToggleIcon.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
            iconGrad.Color = Themes[CurrentTheme].TextContrast
        end
    end
end)

local toggleScale = Instance.new("UIScale", ToggleIcon)
toggleScale.Scale = 1

local function CreateBubbleEffect(centerPos)
local pColor = Themes[CurrentTheme] and Themes[CurrentTheme].ToggleActive or Color3.fromHex("#969696")

for i = 1, 14 do
    task.delay(math.random(0, 10)/100, function()
        if not ToggleIcon or not ToggleIcon.Parent then return end
        
        local toggleRadius = ToggleIcon.AbsoluteSize.X / 2 
        local angle = math.rad(math.random(0, 360))
        
        local startX = centerPos.X + math.cos(angle) * toggleRadius
        local startY = centerPos.Y + math.sin(angle) * toggleRadius
        
        local particle = Instance.new("Frame", ToggleIcon.Parent)
        particle.Size = UDim2.new(0, 10, 0, 10)
        particle.AnchorPoint = Vector2.new(0.5, 0.5)
        particle.Position = UDim2.new(0, startX, 0, startY)
        particle.BackgroundColor3 = pColor
        particle.ZIndex = 50
        
        Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
        
        local distance = math.random(15, 35)
        local targetX = startX + math.cos(angle) * distance
        local targetY = startY + math.sin(angle) * distance
        
        local pTween = TweenService:Create(particle, TweenInfo.new(math.random(3, 5)/10, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, targetX, 0, targetY),
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        pTween:Play()
        pTween.Completed:Connect(function() particle:Destroy() end)
    end)
end
end

local function PlayJellyBounce()
local tUp = TweenService:Create(toggleScale, TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Scale = 1})
tUp:Play()
CreateBubbleEffect(ToggleIcon.AbsolutePosition + (ToggleIcon.AbsoluteSize / 2))
end

local toggleDragging = false
local toggleDragStart, toggleStartPos, toggleMoved

ToggleIcon.InputBegan:Connect(function(input)
if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
toggleDragging = true
toggleMoved = false
toggleDragStart = input.Position
toggleStartPos = ToggleIcon.Position

    TweenService:Create(toggleScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Scale = 0.85}):Play()
end
end)

UserInputService.InputChanged:Connect(function(input)
if toggleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
local delta = input.Position - toggleDragStart
if delta.Magnitude > 5 then
toggleMoved = true
end
ToggleIcon.Position = UDim2.new(toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X, toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y)
end
end)
---------
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if toggleDragging then
            toggleDragging = false
            
            if toggleMoved then
                local parentSize = ToggleIcon.Parent and ToggleIcon.Parent.AbsoluteSize or workspace.CurrentCamera.ViewportSize
                local tSize = ToggleIcon.AbsoluteSize
                local tPos = ToggleIcon.AbsolutePosition
                
                local left = tPos.X
                local right = parentSize.X - (tPos.X + tSize.X)
                local top = tPos.Y
                local bottom = parentSize.Y - (tPos.Y + tSize.Y)
                
                local min = math.min(left, right, top, bottom)
                local sinkAmount = tSize.X * 0.35
                local restMargin = 2 
                local bottomMargin = 12 
                
                local sinkUDim, targetUDim
                
                if min == left then
                    sinkUDim = UDim2.new(0, -sinkAmount, 0, tPos.Y)
                    targetUDim = UDim2.new(0, restMargin, 0, tPos.Y)
                elseif min == right then
                    sinkUDim = UDim2.new(0, parentSize.X - tSize.X + sinkAmount, 0, tPos.Y)
                    targetUDim = UDim2.new(0, parentSize.X - tSize.X - restMargin, 0, tPos.Y)
                elseif min == top then
                    sinkUDim = UDim2.new(0, tPos.X, 0, -sinkAmount)
                    targetUDim = UDim2.new(0, tPos.X, 0, restMargin)
                else
                    sinkUDim = UDim2.new(0, tPos.X, 0, parentSize.Y - tSize.Y + sinkAmount)
                    targetUDim = UDim2.new(0, tPos.X, 0, parentSize.Y - tSize.Y - bottomMargin)
                end
                
                local sinkTween = TweenService:Create(ToggleIcon, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = sinkUDim})
                sinkTween:Play()
                
                sinkTween.Completed:Connect(function()
                    TweenService:Create(ToggleIcon, TweenInfo.new(0.35, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Position = targetUDim}):Play()
                    PlayJellyBounce()
                end)
            else
                PlayJellyBounce()
            end
        end
    end
end)

ToggleIcon.MouseButton1Click:Connect(function()
    if toggleMoved then return end
    if not m then return end
    if m.Size.X.Offset > 0 or m.Size.X.Scale > 0 then
        TweenService:Create(m, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(1, 0, 0.5, 0)
        }):Play()
        task.wait(0.3)
        m.Visible = false
    else
        m.Visible = true
        local targetSize = isMini and UDim2.new(0, 600, 0, 525) or (isMax and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 600, 0, 525))
        local targetPos = isMini and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(m, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize, Position = targetPos}):Play()
    end
end)
---------
    ---------
    ToggleIcon.MouseButton1Click:Connect(function()
        if not m then return end
        if m.Size.X.Offset > 0 or m.Size.X.Scale > 0 then
            TweenService:Create(m, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(1, 0, 0.5, 0)
            }):Play()
            task.wait(0.3)
            m.Visible = false
        else
            m.Visible = true
            local targetSize = isMini and UDim2.new(0, 600, 0, 525) or (isMax and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 600, 0, 525))
            local targetPos = isMini and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 0.5, 0)
            TweenService:Create(m, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize, Position = targetPos}):Play()
        end
    end)
    ---------
    
    local u = Instance.new("UIStroke", m)
    u.Thickness = 4.5
    u.Color = Themes[CurrentTheme].MainStroke
    table.insert(UI_Elements.AnimatedStrokes, {Obj = u, Type = "MainStroke"})
    
    local e = Instance.new("UIGradient", u)
    table.insert(UI_Elements.RotatingGradients, e)
    
    local titleBar = Instance.new("Frame", m)
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 55)
    titleBar.BackgroundTransparency = 1
    titleBar.ZIndex = 2
    
    local hubTitle = Instance.new("TextLabel", titleBar)
    hubTitle.Size = UDim2.new(0, 300, 1, 0)
    hubTitle.Position = UDim2.new(0, 20, 0, 0)
    hubTitle.BackgroundTransparency = 1
    hubTitle.Font = Enum.Font.GothamBold
    hubTitle.Text = windowTitle
    -------------------------
    ApplyTextGradient(hubTitle)
    -------------------------
    hubTitle.TextSize = 15
    hubTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local function CreateWinBtn(text, pos)
        local btn = Instance.new("TextButton", titleBar)
        btn.Size = UDim2.new(0, 30, 0, 30)
        btn.Position = UDim2.new(1, pos, 0.5, 0)
        btn.AnchorPoint = Vector2.new(0, 0.5)
        btn.BackgroundTransparency = 1
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        -------------------------
        ApplyTextGradient(btn)
        -------------------------
        btn.TextSize = 16
        return btn
    end
    
    local minBtn = CreateWinBtn("~", -105)
    local maxBtn = CreateWinBtn("⬚", -70)
    local closeBtn = CreateWinBtn("x", -35)


    minBtn.MouseButton1Click:Connect(function()
        if not isMini then
            isMini = true
            
            local tgIcon = g:FindFirstChild("ToggleIcon")
            if tgIcon then tgIcon.Visible = false end
            
            TweenService:Create(m, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(1, 0, 0.5, 0)
            }):Play()
            task.delay(0.5, function()
                if isMini then
                    m.Visible = false
                    EdgeBarHitbox.Visible = true
                    EdgeBarVisual.BackgroundTransparency = 0.8
                    EdgeBarVisual.Size = UDim2.new(0, 4, 0, 120)
                end
            end)
        end
    end)
---------

    
    maxBtn.MouseButton1Click:Connect(function()
        if not isMax then
            isMax = true; isMini = false
            TweenService:Create(m, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
            if m:FindFirstChild("Sidebar") then m.Sidebar.Visible = true end
            if m:FindFirstChild("LeftDivider") then m.LeftDivider.Visible = true end
            if m:FindFirstChild("TopDivider") then m.TopDivider.Visible = true end
            if m:FindFirstChild("Sidebar") then
                for _, btn in pairs(m.Sidebar:GetChildren()) do
                    if btn:IsA("TextButton") and btn:FindFirstChild("ActiveBg") and btn.ActiveBg.BackgroundTransparency < 1 then
                        local pageName = btn.Text:gsub("%s+", "") .. "Page"
                        if m:FindFirstChild(pageName) then m[pageName].Visible = true end
                    end
                end
            end
        else
            isMax = false
            TweenService:Create(m, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 600, 0, 525), -- Updated
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
        end
    end)
    ---------
    
    closeBtn.MouseButton1Click:Connect(function()
        if m.Size.X.Offset > 0 or m.Size.X.Scale > 0 then
            TweenService:Create(m, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(1, 0, 0.5, 0)
            }):Play()
            task.wait(0.3)
            m.Visible = false
        end
    end)
    
    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            dragStart = input.Position
            startPos = m.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            m.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    local TopDivider = Instance.new("Frame", m)
    TopDivider.Name = "TopDivider"
    TopDivider.Size = UDim2.new(1, -40, 0, 1)
    TopDivider.Position = UDim2.new(0, 20, 0, 55)
    TopDivider.BackgroundColor3 = Color3.fromHex("#FFFFFF")
    TopDivider.BorderSizePixel = 0
    TopDivider.ZIndex = 3
    
    local topDivGrad = Instance.new("UIGradient", TopDivider)
    topDivGrad.Color = Themes[CurrentTheme].DivGrad
    topDivGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    table.insert(UI_Elements.DivGradients, topDivGrad)
    
    ---------
    local LeftDivider = Instance.new("Frame", m)
    LeftDivider.Name = "LeftDivider"
    LeftDivider.Size = UDim2.new(0, 1, 1, -80)
    LeftDivider.Position = UDim2.new(0, 175, 0, 65) -- Adjusted for UI Ratio
    LeftDivider.BackgroundColor3 = Color3.fromHex("#FFFFFF")
    LeftDivider.BorderSizePixel = 0
    LeftDivider.ZIndex = 3
    
    local leftDivGrad = Instance.new("UIGradient", LeftDivider)
    leftDivGrad.Rotation = 90
    leftDivGrad.Color = Themes[CurrentTheme].DivGrad
    leftDivGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    table.insert(UI_Elements.DivGradients, leftDivGrad)
        local Sidebar = Instance.new("ScrollingFrame", m)
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 170, 1, -65) -- Adjusted width for 600 UI
    Sidebar.Position = UDim2.new(0, 5, 0, 60)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Sidebar.ZIndex = 2
    
    local sideLayout = Instance.new("UIListLayout", Sidebar)
    sideLayout.Padding = UDim.new(0, 5)
    sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder -- Ensure layout order respects Logo & Search

    -- Sidebar Logo Area
    local LogoFrame = Instance.new("Frame", Sidebar)
    LogoFrame.Name = "LogoArea"
    LogoFrame.BackgroundTransparency = 1
    LogoFrame.LayoutOrder = 1
    
    LogoFrame.Size = UDim2.new(1, -10, 0, 120)
    local logoIcon = Instance.new("ImageLabel", LogoFrame)
    logoIcon.Size = UDim2.new(1, 0, 1, 0)
    logoIcon.BackgroundTransparency = 1
    logoIcon.ScaleType = Enum.ScaleType.Fit
    
    task.spawn(function()
        while task.wait(0.5) do
            if not LogoFrame.Parent then break end
            local iconId = "121203350952750"
            if CurrentTheme == "Dream" then 
                iconId = "90308084903285"
            elseif CurrentTheme == "Ocean" then 
                iconId = "103281926053314" 
            end
            logoIcon.Image = "rbxthumb://type=Asset&id=" .. iconId .. "&w=150&h=150"
        end
    end)

   -- Sidebar Search Area
    local SearchFrame = Instance.new("Frame", Sidebar)
    SearchFrame.Name = "SearchArea"
    SearchFrame.Size = UDim2.new(1, -20, 0, 32)
    SearchFrame.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
    SearchFrame.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
    SearchFrame.LayoutOrder = 2
    table.insert(UI_Elements.Containers, SearchFrame)
    Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 6)

    local SearchIconDisplay = Instance.new("ImageLabel", SearchFrame)
    SearchIconDisplay.Size = UDim2.new(0, 25, 0, 25)
SearchIconDisplay.AnchorPoint = Vector2.new(1, 0.5)
    SearchIconDisplay.Position = UDim2.new(1, -10, 0.5, 0)
    SearchIconDisplay.BackgroundTransparency = 1
    SearchIconDisplay.Image = "rbxthumb://type=Asset&id=111352610696552&w=150&h=150"
    
 if Themes[CurrentTheme] and Themes[CurrentTheme].SearchIconColor then
        SearchIconDisplay.ImageColor3 = Themes[CurrentTheme].SearchIconColor
    else
        SearchIconDisplay.ImageColor3 = Themes[CurrentTheme].TextColor
    end
    
    -- Vòng lặp kiểm tra để tự động thay đổi màu khi ann chọn theme khác nhó~
    task.spawn(function()
        while task.wait(0.5) do
            if not SearchIconDisplay.Parent then break end
            if Themes[CurrentTheme] then
                if Themes[CurrentTheme].SearchIconColor then
                    SearchIconDisplay.ImageColor3 = Themes[CurrentTheme].SearchIconColor
                else
                    SearchIconDisplay.ImageColor3 = Themes[CurrentTheme].TextColor
                end
            end
        end
    end)


    local SearchBox = Instance.new("TextBox", SearchFrame)
    SearchBox.Size = UDim2.new(1, -30, 1, 0)
    SearchBox.Position = UDim2.new(0, 26, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Font = Enum.Font.GothamBold
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search Tab..."
    SearchBox.TextSize = 12
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    ApplyTextGradient(SearchBox)
    ---------
    
    local TabsList = {}
    local PagesList = {}
    
    ---------
    -- Handle Search Filter
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local searchText = string.lower(SearchBox.Text)
        for _, tabData in ipairs(TabsList) do
            if searchText == "" or string.find(string.lower(tabData.Name), searchText) then
                tabData.Btn.Visible = true
            else
                tabData.Btn.Visible = false
            end
        end
    end)
    ---------

    -- [[ TAB SYSTEM ]] --
    function Window:CreateTab(name, isFirstPage, tabIconId)
        local Tab = {}
        local currentTitle = ""
        local currentSubTitle = ""

        local function GetSecureFlag(elementText, customFlag)
            -- Lớp 1: Đường dẫn cơ bản
            local t = currentTitle ~= "" and currentTitle or "NoTitle"
            local st = currentSubTitle ~= "" and currentSubTitle or "NoSub"
            local basePath = name .. "_" .. t .. "_" .. st .. "_" .. elementText

            -- Lớp 2: Gán Flag thủ công
            if customFlag then
                basePath = basePath .. "_" .. customFlag
            end

            -- Lớp 4: Khóa đường dẫn Namespace
            local namespace = "[" .. name .. "][" .. t .. "][" .. st .. "]"
            local finalFlag = namespace .. "_" .. basePath

            -- Lớp 3: Mã UUID chữa cháy nếu vẫn trùng
            if Library.ConfigElements[finalFlag] then
                finalFlag = finalFlag .. "_" .. HttpService:GenerateGUID(false)
            end

            return finalFlag
        end

        local btn = Instance.new("TextButton", Sidebar)
        btn.Size = UDim2.new(1, -20, 0, 38)
        btn.BackgroundTransparency = 1
        btn.Font = Enum.Font.GothamBold
        btn.Text = ""
        btn.LayoutOrder = 3 + #TabsList -- Tab order goes below Logo & Search
        
        ---------
        -- Elegant Tab Background Indicator
        local activeBg = Instance.new("Frame", btn)
        activeBg.Name = "ActiveBg"
        activeBg.Size = UDim2.new(1, 0, 1, 0)
        activeBg.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
        activeBg.BackgroundTransparency = isFirstPage and 0.8 or 1
        Instance.new("UICorner", activeBg).CornerRadius = UDim.new(0, 8)
        table.insert(UI_Elements.TabBackgrounds, activeBg)
        
        local activeGlow = Instance.new("Frame", activeBg)
        activeGlow.Size = UDim2.new(0, 4, 1, -10)
        activeGlow.Position = UDim2.new(0, 4, 0.5, 0)
        activeGlow.AnchorPoint = Vector2.new(0, 0.5)
        activeGlow.BackgroundColor3 = Color3.fromHex("#FFFFFF")
        activeGlow.BackgroundTransparency = isFirstPage and 0 or 1
        activeGlow.BorderSizePixel = 0
        Instance.new("UICorner", activeGlow).CornerRadius = UDim.new(1, 0)
        
        local glowGrad = Instance.new("UIGradient", activeGlow)
        glowGrad.Rotation = 90
        glowGrad.Color = Themes[CurrentTheme].DivGrad
        glowGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.15, 0.5),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(0.85, 0.5),
            NumberSequenceKeypoint.new(1, 1)
        })
        table.insert(UI_Elements.DivGradients, glowGrad)
        ---------
        
        local btnText = Instance.new("TextLabel", btn)
        btnText.Size = UDim2.new(1, -25, 1, 0)
        btnText.Position = UDim2.new(0, 18, 0, 0)
        btnText.BackgroundTransparency = 1
        btnText.Font = Enum.Font.GothamBold
        btnText.Text = name
        -------------------------
        ApplyTextGradient(btnText)
        -------------------------
        btnText.TextSize = 13 -- Slightly scaled down for new UI ratio
        btnText.TextXAlignment = Enum.TextXAlignment.Left

      ---------
        if tabIconId and tabIconId ~= "" then
            local iconDisplay = Instance.new("ImageLabel", btn)
            iconDisplay.Size = UDim2.new(0, 18, 0, 18)
            iconDisplay.Position = UDim2.new(0, 14, 0.5, 0)
            iconDisplay.AnchorPoint = Vector2.new(0, 0.5)
            iconDisplay.BackgroundTransparency = 1
            
            local idClean = string.match(tabIconId, "%d+")
            if idClean then
                iconDisplay.Image = "rbxthumb://type=Asset&id=" .. idClean .. "&w=150&h=150"
            else
                iconDisplay.Image = tabIconId
            end

            iconDisplay.ImageColor3 = Themes[CurrentTheme].TextColor
            
            local iconGrad = Instance.new("UIGradient", iconDisplay)
            iconGrad.Rotation = 90
            iconGrad.Color = Themes[CurrentTheme].TextContrast
            table.insert(UI_Elements.TextGradients, iconGrad)
            
            table.insert(UI_Elements.TabIcons, iconDisplay)
            
            btnText.Position = UDim2.new(0, 39, 0, 0)
            btnText.Size = UDim2.new(1, -40, 1, 0)
        end
        
        table.insert(TabsList, {Btn = btn, Bg = activeBg, Glow = activeGlow, Name = name})
---------
        
        local page = Instance.new("ScrollingFrame", m)
        page.Name = name .. "Page"
        ---------
        page.Size = UDim2.new(1, -190, 1, -85) -- Adjusted for 600 width
        page.Position = UDim2.new(0, 180, 0, 70)
        ---------
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 0
        page.ZIndex = 2
        page.Visible = isFirstPage
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local pagePadding = Instance.new("UIPadding", page)
        pagePadding.PaddingLeft = UDim.new(0, 10)
        pagePadding.PaddingRight = UDim.new(0, 20)
        pagePadding.PaddingTop = UDim.new(0, 5)
        
        local contentLayout = Instance.new("UIListLayout", page)
        contentLayout.Padding = UDim.new(0, 8)
        table.insert(PagesList, page)
        
---------
        -- Smooth Tab Transition with Light Beam Effect
        btn.MouseButton1Click:Connect(function()
            if page.Visible then return end

            local beam = Instance.new("Frame")
            beam.Name = "LightBeamEffect"
            beam.Size = UDim2.new(0, 250, 1, 0)
            beam.Position = UDim2.new(0, -250, 0, 0)
            beam.BackgroundColor3 = Themes[CurrentTheme] and Themes[CurrentTheme].ToggleActive or Color3.fromHex("#FFFFFF")
            beam.BorderSizePixel = 0
            beam.ZIndex = 50 
            beam.Parent = m

            local beamGrad = Instance.new("UIGradient", beam)
            beamGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.4, 0.5),
                NumberSequenceKeypoint.new(0.5, 0),
                NumberSequenceKeypoint.new(0.6, 0.5),
                NumberSequenceKeypoint.new(1, 1)
            })
            beamGrad.Rotation = 15 

            local sweepTween = TweenService:Create(beam, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(1, m.AbsoluteSize.X + 100, 0, 0)
            })
            sweepTween:Play()
            
            local flashTween = TweenService:Create(beamGrad, TweenInfo.new(0.08, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut, -1, true), {
                Offset = Vector2.new(0, 0.3)
            })
            flashTween:Play()

            task.delay(0.22, function()
                for _, p in pairs(PagesList) do 
                    if p.Visible then
                        TweenService:Create(p, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {ScrollBarImageTransparency = 1}):Play()
                        p.Visible = false 
                    end
                end
                for _, t in pairs(TabsList) do 
                    TweenService:Create(t.Bg, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundTransparency = 1}):Play()
                    TweenService:Create(t.Glow, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundTransparency = 1}):Play()
                end
                
                page.Position = UDim2.new(0, 180, 0, 100) 
                page.ScrollBarImageTransparency = 1
                page.Visible = true
                
                TweenService:Create(page, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 180, 0, 70),
                    ScrollBarImageTransparency = 0
                }):Play()
                
                TweenService:Create(activeBg, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0.8}):Play()
                TweenService:Create(activeGlow, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
                
            end)

            sweepTween.Completed:Connect(function()
                flashTween:Cancel()
                beam:Destroy()
            end)
        end)
        ---------

        function Tab:CreatePageTitle(text)
            currentTitle = text
            currentSubTitle = ""
            local titleWrapper = Instance.new("Frame", page)
            titleWrapper.Size = UDim2.new(1, 0, 0, 45)
            titleWrapper.BackgroundTransparency = 1
            
            local title = Instance.new("TextLabel", titleWrapper)
            title.Size = UDim2.new(1, 0, 1, 0)
            title.Position = UDim2.new(0, 10, 0, 0)
            title.BackgroundTransparency = 1
            title.Font = Enum.Font.GothamBold
            title.Text = text
            -------------------------
            ApplyTextGradient(title)
            -------------------------
            title.TextSize = 26
            title.TextXAlignment = Enum.TextXAlignment.Left
        end
        
        function Tab:CreatePageSubTitle(text)
            currentSubTitle = text
            local titleWrapper = Instance.new("Frame", page)
            titleWrapper.Size = UDim2.new(1, 0, 0, 35)
            titleWrapper.BackgroundTransparency = 1
            
            local title = Instance.new("TextLabel", titleWrapper)
            title.Size = UDim2.new(1, 0, 1, 0)
            title.Position = UDim2.new(0, 10, 0, 0)
            title.BackgroundTransparency = 1
            title.Font = Enum.Font.GothamBold
            title.Text = text
            -------------------------
            ApplyTextGradient(title)
            -------------------------
            title.TextSize = 20
            title.TextXAlignment = Enum.TextXAlignment.Left
        end
        
        ---------
     ---------
        function Tab:CreateDropdown(text, default, optionsList, desc, callback, flag)
            local Dropdown = {}
            local rowHeight = (desc and desc ~= "") and 58 or 42
            local containerHeight = (desc and desc ~= "") and 62 or 46

            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(1, -4, 0, containerHeight)
            container.Position = UDim2.new(0, 2, 0, 0)
            container.BackgroundTransparency = 1
            container.ClipsDescendants = false
            
            local row = Instance.new("Frame", container)
            row.Size = UDim2.new(1, 0, 0, rowHeight)
            row.Position = UDim2.new(0, 0, 0, 2)
            row.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
            row.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
            table.insert(UI_Elements.Containers, row)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
            
            local rowStroke = Instance.new("UIStroke", row)
            rowStroke.Color = Themes[CurrentTheme].RowStroke
            rowStroke.Thickness = 1.2
            table.insert(UI_Elements.RowStrokes, rowStroke)
            
            local rowGrad = Instance.new("UIGradient", rowStroke)
            rowGrad.Color = Themes[CurrentTheme].RowStrokeGrad
            table.insert(UI_Elements.RowStrokeGradients, rowGrad)
            table.insert(UI_Elements.AnimatedGradients, rowGrad)
            
            local label = Instance.new("TextLabel", row)
            label.Size = UDim2.new(0.5, -10, 0, 42)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold
            label.Text = text
            ApplyTextGradient(label)
            label.TextSize = 14.5
            label.TextXAlignment = Enum.TextXAlignment.Left

            if desc and desc ~= "" then
                local descLabel = Instance.new("TextLabel", row)
                descLabel.Size = UDim2.new(1, -150, 0, 15)
                descLabel.Position = UDim2.new(0, 15, 0, 32)
                descLabel.BackgroundTransparency = 1
                descLabel.Font = Enum.Font.GothamBold
                descLabel.Text = desc
                descLabel.TextSize = 10
                descLabel.TextColor3 = Themes[CurrentTheme].DescTextColor
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                table.insert(UI_Elements.Descriptions, descLabel)
            end

            local dropBtn = Instance.new("TextButton", row)
            dropBtn.Size = UDim2.new(0, 130, 0, 30)
            dropBtn.Position = UDim2.new(1, -145, 0, 6)
            dropBtn.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
            dropBtn.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
            table.insert(UI_Elements.Containers, dropBtn)
            dropBtn.Text = default
            dropBtn.Font = Enum.Font.GothamBold
            ApplyTextGradient(dropBtn)
            dropBtn.TextSize = 12.5
            Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 6)
            
            local arrow = Instance.new("TextLabel", dropBtn)
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(1, -25, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "​​≡"
            ApplyTextGradient(arrow)
            arrow.TextSize = 10
            
            local dropList = Instance.new("ScrollingFrame", container)
            dropList.Size = UDim2.new(1, 0, 1, -containerHeight - 2)
            dropList.Position = UDim2.new(0, 0, 0, containerHeight + 2)
            dropList.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
            dropList.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
            table.insert(UI_Elements.Containers, dropList)
            dropList.BorderSizePixel = 0
            dropList.ScrollBarThickness = 2
            dropList.Visible = false
            dropList.AutomaticCanvasSize = Enum.AutomaticSize.Y
            dropList.CanvasSize = UDim2.new(0, 0, 0, 0)
            Instance.new("UICorner", dropList).CornerRadius = UDim.new(0, 8)
            
            local listLayout = Instance.new("UIListLayout", dropList)
            listLayout.Padding = UDim.new(0, 5)
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            
            local dropListStroke = Instance.new("UIStroke", dropList)
            dropListStroke.Color = Themes[CurrentTheme].RowStroke
            dropListStroke.Thickness = 1.2
            table.insert(UI_Elements.RowStrokes, dropListStroke)
            
            local dropListGrad = Instance.new("UIGradient", dropListStroke)
            dropListGrad.Color = Themes[CurrentTheme].RowStrokeGrad
            table.insert(UI_Elements.RowStrokeGradients, dropListGrad)
            table.insert(UI_Elements.AnimatedGradients, dropListGrad)

            local flagId = GetSecureFlag(text, flag)
            local function SetValue(val)
                dropBtn.Text = val
                if Library.ConfigElements[flagId] then
                    Library.ConfigElements[flagId].Value = val
                end
                if callback then callback(val) end
                Library:AutoSave()
            end

            Library.ConfigElements[flagId] = { Value = default, Set = SetValue }
            
            local isDropped = false

            local function RenderOptions(list)
                for _, child in pairs(dropList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end

                for _, opt in pairs(list) do
                    local dummyBtn = Instance.new("TextButton", dropList)
                    dummyBtn.Size = UDim2.new(1, -10, 0, 30)
                    dummyBtn.BackgroundTransparency = 1
                    dummyBtn.Text = opt
                    dummyBtn.Font = Enum.Font.GothamBold
                    ApplyTextGradient(dummyBtn)
                    dummyBtn.TextSize = 12
                    
                    dummyBtn.MouseButton1Click:Connect(function()
                        isDropped = false
                        
                        local tweenConn
                        local closeTween = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -4, 0, containerHeight)})
                        closeTween:Play()
                        
                        TweenService:Create(arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                        
                        tweenConn = closeTween.Completed:Connect(function()
                            if not isDropped then
                                dropList.Visible = false
                            end
                            tweenConn:Disconnect()
                        end)

                        SetValue(opt)
                    end)
                end
            end

            RenderOptions(optionsList)
            
            dropBtn.MouseButton1Click:Connect(function()
                isDropped = not isDropped
                local targetHeight = isDropped and 165 or containerHeight
                
                if isDropped then
                    dropList.Visible = true
                    task.spawn(function()
                        while isDropped and container and container.Parent do
                            if container.AbsoluteSize.Y < targetHeight - 2 or container.AbsoluteSize.X < 20 then
                                dropList.Visible = true
                                task.wait(0.05)
                            else
                                break
                            end
                        end
                        if isDropped then
                            dropList.Visible = true
                        end
                    end)
                end
                
                local tween = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -4, 0, targetHeight)})
                tween:Play()
                
                if not isDropped then
                    local tweenConn
                    tweenConn = tween.Completed:Connect(function()
                        if not isDropped then
                            dropList.Visible = false
                        end
                        tweenConn:Disconnect()
                    end)
                end    
                
                TweenService:Create(arrow, TweenInfo.new(0.3), {Rotation = isDropped and 180 or 0}):Play()
            end)

            function Dropdown:Refresh(newList, newDefault)
                RenderOptions(newList)
                if newDefault then
                    SetValue(newDefault)
                else
                    local currentVal = Library.ConfigElements[flagId].Value
                    local exists = false
                    for _, opt in pairs(newList) do
                        if opt == currentVal then
                            exists = true
                            break
                        end
                    end
                    if not exists and #newList > 0 then
                        SetValue(newList[1])
                    elseif not exists then
                        SetValue("None")
                    end
                end
            end

            return Dropdown
        end

---------
        function Tab:CreateMultiDropdown(text, defaultSelections, optionsList, desc, callback, flag)
            local MultiDropdown = {}
            local rowHeight = (desc and desc ~= "") and 58 or 42
            local containerHeight = (desc and desc ~= "") and 62 or 46

            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(1, -4, 0, containerHeight)
            container.Position = UDim2.new(0, 2, 0, 0)
            container.BackgroundTransparency = 1
            container.ClipsDescendants = false
            
            local row = Instance.new("Frame", container)
            row.Size = UDim2.new(1, 0, 0, rowHeight)
            row.Position = UDim2.new(0, 0, 0, 2)
            row.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
            row.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
            table.insert(UI_Elements.Containers, row)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
            
            local rowStroke = Instance.new("UIStroke", row)
            rowStroke.Color = Themes[CurrentTheme].RowStroke
            rowStroke.Thickness = 1.2
            table.insert(UI_Elements.RowStrokes, rowStroke)
            
            local rowGrad = Instance.new("UIGradient", rowStroke)
            rowGrad.Color = Themes[CurrentTheme].RowStrokeGrad
            table.insert(UI_Elements.RowStrokeGradients, rowGrad)
            table.insert(UI_Elements.AnimatedGradients, rowGrad)
            
            local label = Instance.new("TextLabel", row)
            label.Size = UDim2.new(0.5, -10, 0, 42)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold
            label.Text = text
            ApplyTextGradient(label)
            label.TextSize = 14.5
            label.TextXAlignment = Enum.TextXAlignment.Left

            if desc and desc ~= "" then
                local descLabel = Instance.new("TextLabel", row)
                descLabel.Size = UDim2.new(1, -70, 0, 15)
                descLabel.Position = UDim2.new(0, 12, 0, 32)
                descLabel.BackgroundTransparency = 1
                descLabel.Font = Enum.Font.GothamBold
                descLabel.Text = desc
                descLabel.TextSize = 10
                descLabel.TextColor3 = Themes[CurrentTheme].DescTextColor
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                table.insert(UI_Elements.Descriptions, descLabel)
            end
            
            local dropBtn = Instance.new("TextButton", row)
            dropBtn.Size = UDim2.new(0, 130, 0, 30)
            dropBtn.Position = UDim2.new(1, -145, 0, 6)
            dropBtn.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
            dropBtn.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
            table.insert(UI_Elements.Containers, dropBtn)
            dropBtn.Font = Enum.Font.GothamBold
            ApplyTextGradient(dropBtn)
            dropBtn.TextSize = 12.5
            dropBtn.TextTruncate = Enum.TextTruncate.AtEnd
            Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 6)
            
            local arrow = Instance.new("TextLabel", dropBtn)
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(1, -25, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "​​≡"
            ApplyTextGradient(arrow)
            arrow.TextSize = 10
            
            local dropList = Instance.new("ScrollingFrame", container)
            dropList.Size = UDim2.new(1, 0, 1, -containerHeight - 2)
            dropList.Position = UDim2.new(0, 0, 0, containerHeight + 2)
            dropList.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
            dropList.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
            table.insert(UI_Elements.Containers, dropList)
            dropList.BorderSizePixel = 0
            dropList.ScrollBarThickness = 2
            dropList.Visible = false
            dropList.AutomaticCanvasSize = Enum.AutomaticSize.Y
            dropList.CanvasSize = UDim2.new(0, 0, 0, 0)
            Instance.new("UICorner", dropList).CornerRadius = UDim.new(0, 8)
            
            local listLayout = Instance.new("UIListLayout", dropList)
            listLayout.Padding = UDim.new(0, 5)
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            
            local dropListStroke = Instance.new("UIStroke", dropList)
            dropListStroke.Color = Themes[CurrentTheme].RowStroke
            dropListStroke.Thickness = 1.2 
            table.insert(UI_Elements.RowStrokes, dropListStroke)
            
            local dropListGrad = Instance.new("UIGradient", dropListStroke)
            dropListGrad.Color = Themes[CurrentTheme].RowStrokeGrad
            table.insert(UI_Elements.RowStrokeGradients, dropListGrad)
            table.insert(UI_Elements.AnimatedGradients, dropListGrad)

            local isDropped = false
            local selectedItems = {}
            optionsList = optionsList or {"Sample Mode 1", "Sample Mode 2"}
            defaultSelections = defaultSelections or {}
            
            for _, v in pairs(defaultSelections) do
                table.insert(selectedItems, v)
            end
            
            local OptionUpdaters = {}
            local flagId = GetSecureFlag(text, flag)

            local function UpdateButtonText()
                if #selectedItems == 0 then
                    dropBtn.Text = "None Selected"
                elseif #selectedItems == 1 then
                    dropBtn.Text = selectedItems[1]
                elseif #selectedItems == 2 then
                    dropBtn.Text = selectedItems[1] .. ", " .. selectedItems[2]
                else
                    dropBtn.Text = "Selected (" .. tostring(#selectedItems) .. ")"
                end
            end
            
            local function SetValue(arr)
                selectedItems = {}
                local saveArr = {}
                for _, v in pairs(arr) do
                    table.insert(selectedItems, v)
                    table.insert(saveArr, v)
                end
                UpdateButtonText()
                for _, updater in pairs(OptionUpdaters) do
                    updater()
                end
                if Library.ConfigElements[flagId] then
                    Library.ConfigElements[flagId].Value = saveArr
                end
                if callback then callback(selectedItems) end
                Library:AutoSave()
            end

            Library.ConfigElements[flagId] = { Value = defaultSelections, Set = SetValue }
            UpdateButtonText()
            
            local function RenderOptions(list)
                for _, child in pairs(dropList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                OptionUpdaters = {}

                for _, opt in pairs(list) do
                    local dummyBtn = Instance.new("TextButton", dropList)
                    dummyBtn.Size = UDim2.new(1, -10, 0, 30)
                    dummyBtn.BackgroundTransparency = 1
                    dummyBtn.Text = opt
                    dummyBtn.Font = Enum.Font.GothamBold
                    ApplyTextGradient(dummyBtn)
                    dummyBtn.TextSize = 12
                    Instance.new("UICorner", dummyBtn).CornerRadius = UDim.new(0, 6)
                    
                    local isSelected = false
                    local function UpdateVisuals()
                        if isSelected then
                            dummyBtn.BackgroundTransparency = 0.85
                            dummyBtn.BackgroundColor3 = Themes[CurrentTheme] and Themes[CurrentTheme].ToggleActive or Color3.fromHex("#00BFFF")
                            local textGrad = dummyBtn:FindFirstChildOfClass("UIGradient")
                            if textGrad then textGrad.Enabled = false end
                            dummyBtn.TextColor3 = Color3.fromHex("#FFFFFF")
                        else
                            dummyBtn.BackgroundTransparency = 1
                            local textGrad = dummyBtn:FindFirstChildOfClass("UIGradient")
                            if textGrad then textGrad.Enabled = true end
                            dummyBtn.TextColor3 = Themes[CurrentTheme] and Themes[CurrentTheme].TextColor or Color3.fromHex("#FFFFFF")
                        end
                    end
                    
                    table.insert(OptionUpdaters, function()
                        isSelected = false
                        for _, v in pairs(selectedItems) do
                            if v == opt then isSelected = true break end
                        end
                        UpdateVisuals()
                    end)
                    
                    for _, v in pairs(selectedItems) do
                        if v == opt then isSelected = true break end
                    end
                    UpdateVisuals()
                    
                    dummyBtn.MouseButton1Click:Connect(function()
                        if isSelected then
                            isSelected = false
                            for i, v in ipairs(selectedItems) do
                                if v == opt then table.remove(selectedItems, i) break end
                            end
                        else
                            isSelected = true
                            table.insert(selectedItems, opt)
                        end
                        UpdateVisuals()
                        UpdateButtonText()
                        
                        if Library.ConfigElements[flagId] then
                            local currentSave = {}
                            for _, v in pairs(selectedItems) do table.insert(currentSave, v) end
                            Library.ConfigElements[flagId].Value = currentSave
                        end
                        
                        if callback then callback(selectedItems) end
                        Library:AutoSave()
                    end)
                end
            end
            
            RenderOptions(optionsList)

            dropBtn.MouseButton1Click:Connect(function()
                isDropped = not isDropped
                local targetHeight = isDropped and 165 or containerHeight
                
                if isDropped then
                    dropList.Visible = true
                    task.spawn(function()
                        while isDropped and container and container.Parent do
                            if container.AbsoluteSize.Y < targetHeight - 2 or container.AbsoluteSize.X < 20 then
                                dropList.Visible = true
                                task.wait(0.05)
                            else
                                break
                            end
                        end
                        if isDropped then
                            dropList.Visible = true
                        end
                    end)
                end
                
                local tween = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -4, 0, targetHeight)})
                tween:Play()
                
                if not isDropped then
                    local tweenConn
                    tweenConn = tween.Completed:Connect(function()
                        if not isDropped then
                            dropList.Visible = false
                        end
                        tweenConn:Disconnect()
                    end)
                end    
                
                TweenService:Create(arrow, TweenInfo.new(0.3), {Rotation = isDropped and 180 or 0}):Play()
            end)

            function MultiDropdown:Refresh(newList, newDefaultSelections)
                if newDefaultSelections then
                    SetValue(newDefaultSelections)
                else
                    local validSelections = {}
                    for _, sel in ipairs(selectedItems) do
                        for _, opt in ipairs(newList) do
                            if sel == opt then
                                table.insert(validSelections, sel)
                                break
                            end
                        end
                    end
                    SetValue(validSelections)
                end
                RenderOptions(newList)
            end
            
            return MultiDropdown
        end
---------
---------

---------
        function Tab:CreateButton(text, desc, callback)
            local rowHeight = (desc and desc ~= "") and 58 or 42
            local row = Instance.new("Frame", page)
            row.Size = UDim2.new(1, -4, 0, rowHeight)
            row.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
            row.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
            row.ClipsDescendants = true -- Thêm vào để Liquid Ripple không tràn ra ngoài
            table.insert(UI_Elements.Containers, row)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
            
            local rowStroke = Instance.new("UIStroke", row)
            rowStroke.Color = Themes[CurrentTheme].RowStroke
            rowStroke.Thickness = 1.2
            rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            table.insert(UI_Elements.RowStrokes, rowStroke)
            
            local rowGrad = Instance.new("UIGradient", rowStroke)
            rowGrad.Color = Themes[CurrentTheme].RowStrokeGrad
            table.insert(UI_Elements.RowStrokeGradients, rowGrad)
            table.insert(UI_Elements.AnimatedGradients, rowGrad)

            local title = Instance.new("TextLabel", row)
            title.Name = "Title"
            title.Size = UDim2.new(1, -70, 0, 42)
            title.Position = UDim2.new(0, 12, 0, 0)
            title.BackgroundTransparency = 1
            title.Font = Enum.Font.GothamBold
            title.Text = text
            ApplyTextGradient(title)
            title.TextSize = 14
            title.TextXAlignment = Enum.TextXAlignment.Left

            if desc and desc ~= "" then
                local descLabel = Instance.new("TextLabel", row)
                descLabel.Size = UDim2.new(1, -70, 0, 15)
                descLabel.Position = UDim2.new(0, 12, 0, 32)
                descLabel.BackgroundTransparency = 1
                descLabel.Font = Enum.Font.GothamBold
                descLabel.Text = desc
                descLabel.TextSize = 10
                descLabel.TextColor3 = Themes[CurrentTheme].DescTextColor
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                table.insert(UI_Elements.Descriptions, descLabel)
            end
            
            local btnContainer = Instance.new("TextButton", row)
            btnContainer.Name = "Button"
            btnContainer.Size = UDim2.new(0, 36, 0, 36)
            btnContainer.Position = UDim2.new(1, -10, 0.5, 0)
            btnContainer.AnchorPoint = Vector2.new(1, 0.5)
            btnContainer.BackgroundTransparency = 1
            btnContainer.Text = ""
            btnContainer.ZIndex = 10
            
            local coreContainer = Instance.new("Frame", btnContainer)
            coreContainer.AnchorPoint = Vector2.new(0.5, 0.5)
            coreContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
            coreContainer.Size = UDim2.new(1, 0, 1, 0)
            coreContainer.BackgroundTransparency = 1
            
            local uiScale = Instance.new("UIScale", coreContainer)
            uiScale.Scale = 1
            
            local coreLayers = {}
            local baseSizes = {8, 14, 20, 26, 32, 38} 
            local baseTransparencies = {0.1, 0.3, 0.5, 0.7, 0.85, 0.93}
            
            for i = 1, #baseSizes do
                local layer = Instance.new("Frame")
                layer.AnchorPoint = Vector2.new(0.5, 0.5)
                layer.Position = UDim2.new(0.5, 0, 0.5, 0)
                layer.BorderSizePixel = 0
                layer.ZIndex = 3
                
                Instance.new("UICorner", layer).CornerRadius = UDim.new(1, 0)
                layer.Parent = coreContainer
                table.insert(coreLayers, {frame = layer, baseSize = baseSizes[i], baseTrans = baseTransparencies[i]})
            end
            
            local r = 0
            local isClicked = false
            local clickTime = 0
            
            local renderConn
            renderConn = RunService.RenderStepped:Connect(function()
                if not btnContainer.Parent then
                    if renderConn then renderConn:Disconnect() end
                    return
                end
                
                r = (r + 1.5) % 360
                local t = Themes[CurrentTheme]
                
               local c1, c2
                if isClicked then
                    c1 = t.ToggleActive
                    c2 = t.ToggleActive
                else
                    c1 = Color3.fromRGB(150, 150, 150)
                    c2 = Color3.fromRGB(150, 150, 150)
                end
                
                local pulse = (math.sin(tick() * 3) + 1) / 2
                local coreColor = c1:Lerp(c2, math.abs(math.sin((r / 360) * math.pi)))
                
                for _, data in ipairs(coreLayers) do
                    local sizeOffset = pulse * 4
                    local targetSize = data.baseSize + sizeOffset
                    data.frame.Size = UDim2.new(0, targetSize, 0, targetSize)
                    data.frame.BackgroundColor3 = coreColor
                    data.frame.BackgroundTransparency = math.clamp(data.baseTrans + (pulse * 0.05), 0, 1)
                end
                
                if isClicked and tick() - clickTime >= 0.5 then
                    isClicked = false
                    TweenService:Create(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {Scale = 1}):Play()
                end
            end)
            
---------
            local lastMousePos = Vector2.new(0, 0)
            
            btnContainer.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    lastMousePos = Vector2.new(input.Position.X, input.Position.Y)
                    TweenService:Create(uiScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Scale = 0.8}):Play()
                    
                    -- 3D Glass Press (Chìm và nghiêng nhẹ, CHỈ mờ nền bên trong)
                    TweenService:Create(row, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                        Rotation = -0.5, 
                        BackgroundTransparency = math.clamp(Themes[CurrentTheme].ContainerTrans + 0.15, 0, 1)
                    }):Play()
                end
            end)
            
            btnContainer.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if not isClicked then
                        TweenService:Create(uiScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Scale = 1}):Play()
                    end
                    -- Phục hồi lại nền sau khi nhả chuột
                    TweenService:Create(row, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Rotation = 0, 
                        BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
                    }):Play()
                end
            end)
---------
            btnContainer.MouseButton1Click:Connect(function()
                isClicked = true
                clickTime = tick()
                TweenService:Create(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {Scale = 1.3}):Play()
                
                -- Liquid Ripple Effect (Neon Glassmorphism)
                local ripple = Instance.new("Frame")
                ripple.Name = "LiquidRipple"
                ripple.Parent = row
                ripple.BackgroundColor3 = Themes[CurrentTheme].ToggleActive
                ripple.BorderSizePixel = 0
                ripple.ZIndex = 4
                Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
                
                local ripGrad = Instance.new("UIGradient", ripple)
                ripGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Themes[CurrentTheme].ToggleActive),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                })
                ripGrad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(0.7, 0.4),
                    NumberSequenceKeypoint.new(1, 1)
                })
                
                -- Tính toán tâm Ripple chuẩn xác theo tọa độ chuột
                local relativeX = lastMousePos.X - row.AbsolutePosition.X
                local relativeY = lastMousePos.Y - row.AbsolutePosition.Y
                
                if lastMousePos.X == 0 and lastMousePos.Y == 0 then
                    relativeX = btnContainer.AbsolutePosition.X + btnContainer.AbsoluteSize.X / 2 - row.AbsolutePosition.X
                    relativeY = btnContainer.AbsolutePosition.Y + btnContainer.AbsoluteSize.Y / 2 - row.AbsolutePosition.Y
                end
                
                ripple.Position = UDim2.new(0, relativeX, 0, relativeY)
                ripple.Size = UDim2.new(0, 0, 0, 0)
                ripple.AnchorPoint = Vector2.new(0.5, 0.5)
                
                local maxDim = math.max(row.AbsoluteSize.X, row.AbsoluteSize.Y) * 1.5
                local ripTween = TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, maxDim, 0, maxDim),
                    BackgroundTransparency = 1
                })
                ripTween:Play()
                ripTween.Completed:Connect(function() ripple:Destroy() end)
                
                if callback then callback() end
            end)
        end
---------
---------
      ---------
        ---------
        function Tab:CreateSwitch(text, default, desc, callback, flag)
            local rowHeight = (desc and desc ~= "") and 58 or 42
            local row = Instance.new("Frame", page)
            row.Size = UDim2.new(1, -4, 0, rowHeight)
            row.Position = UDim2.new(0, 2, 0, 0)
            row.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
            row.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
            table.insert(UI_Elements.Containers, row)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
            
            local rowStroke = Instance.new("UIStroke", row)
            rowStroke.Color = Themes[CurrentTheme].RowStroke
            rowStroke.Thickness = 1.2
            table.insert(UI_Elements.RowStrokes, rowStroke)
            
            local rowGrad = Instance.new("UIGradient", rowStroke)
            rowGrad.Color = Themes[CurrentTheme].RowStrokeGrad
            table.insert(UI_Elements.RowStrokeGradients, rowGrad)
            table.insert(UI_Elements.AnimatedGradients, rowGrad)
            
            local label = Instance.new("TextLabel", row)
            label.Size = UDim2.new(0.7, -10, 0, 42)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold
            label.Text = text
            ApplyTextGradient(label)
            label.TextSize = 14.5
            label.TextXAlignment = Enum.TextXAlignment.Left

            if desc and desc ~= "" then
                local descLabel = Instance.new("TextLabel", row)
                descLabel.Size = UDim2.new(1, -80, 0, 15)
                descLabel.Position = UDim2.new(0, 15, 0, 32)
                descLabel.BackgroundTransparency = 1
                descLabel.Font = Enum.Font.GothamBold
                descLabel.Text = desc
                descLabel.TextSize = 10
                descLabel.TextColor3 = Themes[CurrentTheme].DescTextColor
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                table.insert(UI_Elements.Descriptions, descLabel)
            end
---------
            
         ---------
            local toggleFrame = Instance.new("TextButton", row)
            toggleFrame.Size = UDim2.new(0, 40, 0, 20)
            toggleFrame.Position = UDim2.new(1, -55, 0.5, 0)
            toggleFrame.AnchorPoint = Vector2.new(0, 0.5)
            toggleFrame.BackgroundColor3 = default and Themes[CurrentTheme].ToggleActive or Color3.fromHex("#969696")
            toggleFrame.Text = ""
            toggleFrame.ClipsDescendants = false 
            Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(1, 0)
            
            local flashFrame = Instance.new("Frame", toggleFrame)
            flashFrame.Size = UDim2.new(1, 0, 1, 0)
            flashFrame.BackgroundColor3 = Color3.fromHex("#FFFFFF")
            flashFrame.BackgroundTransparency = 1
            flashFrame.ClipsDescendants = true
            Instance.new("UICorner", flashFrame).CornerRadius = UDim.new(1, 0)
            
            local flashGrad = Instance.new("UIGradient", flashFrame)
            flashGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
                ColorSequenceKeypoint.new(0.5, Color3.fromHex("#FFFFFF")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
            })
            flashGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.5, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
            flashGrad.Rotation = 45
            flashGrad.Offset = Vector2.new(-1, 0)

            local ball = Instance.new("Frame", toggleFrame)
            ball.Size = UDim2.new(0, 16, 0, 16)
            ball.Position = default and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            ball.AnchorPoint = Vector2.new(0, 0.5)
            ball.BackgroundColor3 = Color3.fromHex("#FFFFFF")
            ball.ZIndex = 3
            Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)
            
            local active = default
            local switchData = {Frame = toggleFrame, Active = active}
            table.insert(UI_Elements.Switches, switchData)
            
            local flagId = GetSecureFlag(text, flag)
            local function SetState(v)
                active = v
                switchData.Active = active
                if Library.ConfigElements[flagId] then
                    Library.ConfigElements[flagId].Value = active
                end
                
                local targetColor = active and Themes[CurrentTheme].ToggleActive or Color3.fromHex("#969696")
                TweenService:Create(toggleFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = targetColor}):Play()
                
                local targetPos = active and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                
                TweenService:Create(ball, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(0, 22, 0, 12)}):Play()
                TweenService:Create(ball, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos}):Play()
                
                task.delay(0.1, function()
                    TweenService:Create(ball, TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Size = UDim2.new(0, 16, 0, 16)}):Play()
                end)

                flashFrame.BackgroundTransparency = 0.5
                flashGrad.Offset = Vector2.new(-1.5, 0)
                local flashTween = TweenService:Create(flashGrad, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {Offset = Vector2.new(1.5, 0)})
                flashTween:Play()
           flashTween.Completed:Connect(function()
                flashFrame.BackgroundTransparency = 1
            end)

            local pColor = active and Themes[CurrentTheme].ToggleActive or Color3.fromHex("#969696")
            for i = 1, 14 do
                task.delay(math.random(0, 10)/100, function()
                    if not ball or not toggleFrame then return end
                    local particle = Instance.new("Frame", toggleFrame)
                    particle.Size = UDim2.new(0, 10, 0, 10)
                    particle.AnchorPoint = Vector2.new(0.5, 0.5)
                    particle.Position = ball.Position + UDim2.new(0, 0, 0, 0)
                    particle.BackgroundColor3 = pColor
                    
                    particle.ZIndex = 5
                    
                    Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
                    
                    local angle = math.rad(math.random(0, 360))
                    local distance = math.random(15, 35)
                    local offsetX = math.cos(angle) * distance
                    local offsetY = math.sin(angle) * distance
                    
                    local pTween = TweenService:Create(particle, TweenInfo.new(math.random(3, 5)/10, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                        Position = particle.Position + UDim2.new(0, offsetX, 0, offsetY),
                        Size = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 1
                    })
                    pTween:Play()
                    pTween.Completed:Connect(function() particle:Destroy() end)
                end)
            end
            
            if callback then callback(active) end
                Library:AutoSave()
            end

            Library.ConfigElements[flagId] = { Value = default, Set = SetState }

            toggleFrame.MouseButton1Click:Connect(function()
                SetState(not active)
                local status = active and "Enabled" or "Disabled"
            end)
        end
---------
---------

       function Tab:CreateLabel(titleText, descText)
            local row = Instance.new("Frame", page)
            row.AutomaticSize = Enum.AutomaticSize.Y
            row.Size = UDim2.new(1, -4, 0, 42)
            row.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
            row.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
            table.insert(UI_Elements.Containers, row)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
            
            local rowStroke = Instance.new("UIStroke", row)
            rowStroke.Color = Themes[CurrentTheme].RowStroke
            rowStroke.Thickness = 1.2
            rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            table.insert(UI_Elements.RowStrokes, rowStroke)
            
            local rowGrad = Instance.new("UIGradient", rowStroke)
            rowGrad.Color = Themes[CurrentTheme].RowStrokeGrad
            table.insert(UI_Elements.RowStrokeGradients, rowGrad)
            table.insert(UI_Elements.AnimatedGradients, rowGrad)

            local layout = Instance.new("UIListLayout", row)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 2)
            layout.VerticalAlignment = Enum.VerticalAlignment.Center
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Left

            local padding = Instance.new("UIPadding", row)
            padding.PaddingLeft = UDim.new(0, 12)
            padding.PaddingRight = UDim.new(0, 12)
            padding.PaddingTop = UDim.new(0, 8)
            padding.PaddingBottom = UDim.new(0, 8)

            local labelTitle = nil
            if titleText and titleText ~= "" then
                labelTitle = Instance.new("TextLabel", row)
                labelTitle.Name = "Title"
                labelTitle.LayoutOrder = 1
                labelTitle.Size = UDim2.new(1, 0, 0, 20)
                labelTitle.BackgroundTransparency = 1
                labelTitle.Font = Enum.Font.GothamBold
                labelTitle.Text = titleText
                ApplyTextGradient(labelTitle)
                labelTitle.TextSize = 14
                labelTitle.TextXAlignment = Enum.TextXAlignment.Left
                labelTitle.AutomaticSize = Enum.AutomaticSize.Y
            end
            
            local labelDesc = nil
            if descText and descText ~= "" then
                labelDesc = Instance.new("TextLabel", row)
                labelDesc.Name = "Description"
                labelDesc.LayoutOrder = 2
                labelDesc.Size = UDim2.new(1, 0, 0, 0)
                labelDesc.BackgroundTransparency = 1
                labelDesc.Font = Enum.Font.GothamBold
                labelDesc.Text = descText
                labelDesc.TextColor3 = Themes[CurrentTheme].DescTextColor
                labelDesc.TextSize = 10
                labelDesc.TextXAlignment = Enum.TextXAlignment.Left
                labelDesc.TextWrapped = true
                labelDesc.AutomaticSize = Enum.AutomaticSize.Y
                table.insert(UI_Elements.Descriptions, labelDesc)
            end

            local LabelObj = {}
            function LabelObj:SetText(val)
                if labelDesc then
                    labelDesc.Text = tostring(val)
                elseif labelTitle then
                    labelTitle.Text = tostring(val)
                end
            end
            function LabelObj.SetText(self, val)
                if type(self) == "table" and val ~= nil then
                    self:SetText(val)
                else
                    LabelObj:SetText(self)
                end
            end
            function LabelObj:Set(title, desc)
                if title and labelTitle then labelTitle.Text = tostring(title) end
                if desc and labelDesc then labelDesc.Text = tostring(desc) end
            end
            return LabelObj
        end
---------

        ---------
        function Tab:CreateInput(text, placeholder, default, desc, numericOnly, callback, flag)
            local Input = {}
            local rowHeight = (desc and desc ~= "") and 64 or 48
            local row = Instance.new("Frame", page)
            row.Size = UDim2.new(1, -4, 0, rowHeight)
            row.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
            row.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
            row.ClipsDescendants = true
            table.insert(UI_Elements.Containers, row)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

            local rowStroke = Instance.new("UIStroke", row)
            rowStroke.Color = Themes[CurrentTheme].RowStroke
            rowStroke.Thickness = 1.2
            rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            table.insert(UI_Elements.RowStrokes, rowStroke)

            local rowGrad = Instance.new("UIGradient", rowStroke)
            rowGrad.Color = Themes[CurrentTheme].RowStrokeGrad
            table.insert(UI_Elements.RowStrokeGradients, rowGrad)
            table.insert(UI_Elements.AnimatedGradients, rowGrad)

            local title = Instance.new("TextLabel", row)
            title.Size = UDim2.new(1, -190, 0, 36)
            title.Position = UDim2.new(0, 15, 0, 4)
            title.BackgroundTransparency = 1
            title.Font = Enum.Font.GothamBold
            title.Text = text
            ApplyTextGradient(title)
            title.TextSize = 14
            title.TextXAlignment = Enum.TextXAlignment.Left

            if desc and desc ~= "" then
                local descLabel = Instance.new("TextLabel", row)
                descLabel.Size = UDim2.new(1, -190, 0, 16)
                descLabel.Position = UDim2.new(0, 15, 0, 36)
                descLabel.BackgroundTransparency = 1
                descLabel.Font = Enum.Font.GothamBold
                descLabel.Text = desc
                descLabel.TextSize = 10
                descLabel.TextColor3 = Themes[CurrentTheme].DescTextColor
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                table.insert(UI_Elements.Descriptions, descLabel)
            end

            local boxWrapper = Instance.new("Frame", row)
            boxWrapper.Size = UDim2.new(0, 120, 0, 32)
            boxWrapper.Position = UDim2.new(1, -15, 0.5, 0)
            boxWrapper.AnchorPoint = Vector2.new(1, 0.5)
            boxWrapper.BackgroundTransparency = 1

            local boxContainer = Instance.new("Frame", boxWrapper)
            boxContainer.Size = UDim2.new(1, 0, 1, 0)
            boxContainer.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
            boxContainer.BackgroundTransparency = math.clamp(Themes[CurrentTheme].ContainerTrans + 0.1, 0.2, 0.95)
            boxContainer.ZIndex = 2
            boxContainer.ClipsDescendants = true
            table.insert(UI_Elements.Containers, boxContainer)
            Instance.new("UICorner", boxContainer).CornerRadius = UDim.new(0, 8)

            local boxStroke = Instance.new("UIStroke", boxContainer)
            boxStroke.Color = Themes[CurrentTheme].RowStroke
            boxStroke.Thickness = 1.2
            boxStroke.Transparency = 0.4
            table.insert(UI_Elements.RowStrokes, boxStroke)

            local boxGrad = Instance.new("UIGradient", boxStroke)
            boxGrad.Color = Themes[CurrentTheme].RowStrokeGrad
            table.insert(UI_Elements.RowStrokeGradients, boxGrad)
            table.insert(UI_Elements.AnimatedGradients, boxGrad)

            local boxScale = Instance.new("UIScale", boxWrapper)
            boxScale.Scale = 1

            local iconHolder = Instance.new("Frame", boxContainer)
            iconHolder.Size = UDim2.new(0, 24, 1, 0)
            iconHolder.Position = UDim2.new(0, 4, 0, 0)
            iconHolder.BackgroundTransparency = 1
            iconHolder.ZIndex = 4

            local iconImg = Instance.new("ImageLabel", iconHolder)
            iconImg.Size = UDim2.new(0, 15, 0, 15)
            iconImg.Position = UDim2.new(0.5, 0, 0.5, 0)
            iconImg.AnchorPoint = Vector2.new(0.5, 0.5)
            iconImg.BackgroundTransparency = 1
            iconImg.Image = "rbxassetid://6031154871"
            iconImg.ImageColor3 = Themes[CurrentTheme].DescTextColor
            iconImg.ZIndex = 4

            local flashFrame = Instance.new("Frame", boxContainer)
            flashFrame.Size = UDim2.new(1, 0, 1, 0)
            flashFrame.BackgroundColor3 = Color3.fromHex("#FFFFFF")
            flashFrame.BackgroundTransparency = 1
            flashFrame.ClipsDescendants = true
            flashFrame.ZIndex = 6
            Instance.new("UICorner", flashFrame).CornerRadius = UDim.new(0, 8)

            local flashGrad = Instance.new("UIGradient", flashFrame)
            flashGrad.Color = Themes[CurrentTheme].LoopSeq
            flashGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.5, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
            flashGrad.Rotation = 35
            flashGrad.Offset = Vector2.new(-1, 0)

            local function PlayNeonFlash()
                flashFrame.BackgroundTransparency = 0.5
                flashGrad.Offset = Vector2.new(-1.8, 0)
                local flashTween = TweenService:Create(flashGrad, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Offset = Vector2.new(1.8, 0)})
                flashTween:Play()
                flashTween.Completed:Connect(function()
                    flashFrame.BackgroundTransparency = 1
                end)
            end

            local function EmitNeonParticles(amount)
                amount = amount or 10
                if not boxWrapper or not boxWrapper.Parent then return end
                for i = 1, amount do
                    local p = Instance.new("Frame", boxWrapper)
                    p.Size = UDim2.new(0, math.random(3, 6), 0, math.random(3, 6))
                    p.Position = UDim2.new(0.5, 0, 0.5, 0)
                    p.AnchorPoint = Vector2.new(0.5, 0.5)
                    p.BackgroundColor3 = Themes[CurrentTheme].ToggleActive
                    p.ZIndex = 20
                    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)

                    local angle = math.rad(math.random(0, 360))
                    local dist = math.random(15, 38)
                    local offX = math.cos(angle) * dist
                    local offY = math.sin(angle) * dist

                    local tw = TweenService:Create(p, TweenInfo.new(math.random(4, 7)/10, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Position = p.Position + UDim2.new(0, offX, 0, offY),
                        Size = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 1
                    })
                    tw:Play()
                    tw.Completed:Connect(function() p:Destroy() end)
                end
            end

            local textBox = Instance.new("TextBox", boxContainer)
            textBox.Size = UDim2.new(1, -34, 1, 0)
            textBox.Position = UDim2.new(0, 28, 0, 0)
            textBox.BackgroundTransparency = 1
            textBox.Font = Enum.Font.GothamBold
            textBox.Text = default and tostring(default) or ""
            textBox.PlaceholderText = placeholder or "Type here..."
            textBox.PlaceholderColor3 = Themes[CurrentTheme].DescTextColor
            textBox.TextSize = 12
            textBox.ClearTextOnFocus = true
            textBox.ClipsDescendants = true
            textBox.ZIndex = 4
            ApplyTextGradient(textBox)

            local flagId = GetSecureFlag(text, flag)
            local function SetValue(val)
                local strVal = tostring(val)
                if numericOnly then
                    strVal = strVal:gsub("%D+", "")
                end
                textBox.Text = strVal
                if Library.ConfigElements[flagId] then
                    Library.ConfigElements[flagId].Value = strVal
                end
                if callback then callback(strVal) end
                Library:AutoSave()
            end

            Library.ConfigElements[flagId] = { Value = default or "", Set = SetValue }

            local lastMousePos = Vector2.new(0, 0)
            row.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    lastMousePos = Vector2.new(input.Position.X, input.Position.Y)
                end
            end)

            textBox.Focused:Connect(function()
                TweenService:Create(boxScale, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Scale = 0.96}):Play()
                TweenService:Create(boxStroke, TweenInfo.new(0.25), {
                    Color = Themes[CurrentTheme].ToggleActive, 
                    Thickness = 1.6, 
                    Transparency = 0
                }):Play()
                TweenService:Create(iconImg, TweenInfo.new(0.25), {ImageColor3 = Themes[CurrentTheme].ToggleActive}):Play()
                
                TweenService:Create(row, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Rotation = -0.4,
                    BackgroundTransparency = math.clamp(Themes[CurrentTheme].ContainerTrans + 0.12, 0, 1)
                }):Play()

                local ripple = Instance.new("Frame")
                ripple.Name = "LiquidRipple"
                ripple.Parent = row
                ripple.BackgroundColor3 = Themes[CurrentTheme].ToggleActive
                ripple.BorderSizePixel = 0
                ripple.ZIndex = 1
                Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)

                local ripGrad = Instance.new("UIGradient", ripple)
                ripGrad.Color = Themes[CurrentTheme].LoopSeq
                ripGrad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.2),
                    NumberSequenceKeypoint.new(0.7, 0.5),
                    NumberSequenceKeypoint.new(1, 1)
                })

                local relativeX = lastMousePos.X - row.AbsolutePosition.X
                local relativeY = lastMousePos.Y - row.AbsolutePosition.Y
                if lastMousePos.X == 0 and lastMousePos.Y == 0 then
                    relativeX = boxWrapper.AbsolutePosition.X - row.AbsolutePosition.X
                    relativeY = boxWrapper.AbsolutePosition.Y - row.AbsolutePosition.Y
                end

                ripple.Position = UDim2.new(0, relativeX, 0, relativeY)
                ripple.Size = UDim2.new(0, 0, 0, 0)
                ripple.AnchorPoint = Vector2.new(0.5, 0.5)

                local maxDim = math.max(row.AbsoluteSize.X, row.AbsoluteSize.Y) * 1.6
                local ripTween = TweenService:Create(ripple, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, maxDim, 0, maxDim),
                    BackgroundTransparency = 1
                })
                ripTween:Play()
                ripTween.Completed:Connect(function() ripple:Destroy() end)
            end)

            textBox:GetPropertyChangedSignal("Text"):Connect(function()
                if numericOnly then
                    local clean = textBox.Text:gsub("%D+", "")
                    if clean ~= textBox.Text then
                        textBox.Text = clean
                    end
                end
            end)

            textBox.FocusLost:Connect(function()
                TweenService:Create(boxScale, TweenInfo.new(0.35, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Scale = 1}):Play()
                TweenService:Create(boxStroke, TweenInfo.new(0.3), {
                    Color = Themes[CurrentTheme].RowStroke, 
                    Thickness = 1.2, 
                    Transparency = 0.4
                }):Play()
                TweenService:Create(iconImg, TweenInfo.new(0.3), {ImageColor3 = Themes[CurrentTheme].DescTextColor}):Play()
                
                TweenService:Create(row, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Rotation = 0,
                    BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
                }):Play()

                PlayNeonFlash()
                EmitNeonParticles(12)
                SetValue(textBox.Text)
            end)

            function Input:Set(val)
                SetValue(val)
            end

            function Input:Get()
                return textBox.Text
            end

            return Input
        end
---------


        function Tab:CreateParagraph(titleText, descText)
            local Paragraph = {}
            local row = Instance.new("Frame", page)
            row.AutomaticSize = Enum.AutomaticSize.Y
            row.Size = UDim2.new(1, -4, 0, 0)
            row.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
            row.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
            table.insert(UI_Elements.Containers, row)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8) 
            
            local rowStroke = Instance.new("UIStroke", row)
            rowStroke.Color = Themes[CurrentTheme].RowStroke 
            rowStroke.Thickness = 1.2 
            rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border 
            table.insert(UI_Elements.RowStrokes, rowStroke)
            
            local rowGrad = Instance.new("UIGradient", rowStroke)
            rowGrad.Color = Themes[CurrentTheme].RowStrokeGrad 
            table.insert(UI_Elements.RowStrokeGradients, rowGrad)
            table.insert(UI_Elements.AnimatedGradients, rowGrad)

            local layout = Instance.new("UIListLayout", row)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 4)
            layout.VerticalAlignment = Enum.VerticalAlignment.Center
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Left

            local padding = Instance.new("UIPadding", row)
            padding.PaddingLeft = UDim.new(0, 12)
            padding.PaddingRight = UDim.new(0, 12)
            padding.PaddingTop = UDim.new(0, 10)
            padding.PaddingBottom = UDim.new(0, 10)

            local labelTitle = nil
            if titleText and titleText ~= "" then
                labelTitle = Instance.new("TextLabel", row)
                labelTitle.Name = "ParagraphTitle"
                labelTitle.LayoutOrder = 1
                labelTitle.Size = UDim2.new(1, 0, 0, 20)
                labelTitle.BackgroundTransparency = 1
                labelTitle.Font = Enum.Font.GothamBold 
                labelTitle.Text = titleText
                ApplyTextGradient(labelTitle)
                labelTitle.TextSize = 14 
                labelTitle.TextXAlignment = Enum.TextXAlignment.Left 
                labelTitle.AutomaticSize = Enum.AutomaticSize.Y
            end

            local labelDesc = nil
            if descText and descText ~= "" then
                labelDesc = Instance.new("TextLabel", row)
                labelDesc.Name = "ParagraphContent"
                labelDesc.LayoutOrder = 2
                labelDesc.Size = UDim2.new(1, 0, 0, 0)
                labelDesc.BackgroundTransparency = 1
                labelDesc.Font = Enum.Font.GothamBold
                labelDesc.Text = descText
                labelDesc.TextColor3 = Themes[CurrentTheme].DescTextColor
                labelDesc.TextSize = 10
                labelDesc.TextXAlignment = Enum.TextXAlignment.Left
                labelDesc.TextWrapped = true
                labelDesc.AutomaticSize = Enum.AutomaticSize.Y
                table.insert(UI_Elements.Descriptions, labelDesc)
            end
            
            function Paragraph:Set(arg1, arg2)
                if type(arg1) == "table" then
                    if arg1.Title and labelTitle then
                        labelTitle.Text = arg1.Title
                    end
                    if arg1.Content and labelDesc then
                        labelDesc.Text = arg1.Content
                    end
                elseif type(arg1) == "string" and type(arg2) == "string" then
                    if labelTitle then labelTitle.Text = arg1 end
                    if labelDesc then labelDesc.Text = arg2 end
                elseif type(arg1) == "string" and not arg2 then
                    if labelDesc then labelDesc.Text = arg1 end
                end
            end

            return Paragraph
        end
---------
    ---------
        function Tab:CreateSlider(text, min, max, default, desc, callback, flag)
            local rowHeight = (desc and desc ~= "") and 76 or 60
            local containerHeight = (desc and desc ~= "") and 81 or 65

            local container = Instance.new("Frame", page)
            container.Size = UDim2.new(1, -4, 0, containerHeight)
            container.BackgroundTransparency = 1
            
            local row = Instance.new("Frame", container)
            row.Size = UDim2.new(1, 0, 0, rowHeight)
            row.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
            row.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
            table.insert(UI_Elements.Containers, row)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
            
            local rowStroke = Instance.new("UIStroke", row)
            rowStroke.Color = Themes[CurrentTheme].RowStroke
            rowStroke.Thickness = 1.2
            table.insert(UI_Elements.RowStrokes, rowStroke)
            
            local rowGrad = Instance.new("UIGradient", rowStroke)
            rowGrad.Color = Themes[CurrentTheme].RowStrokeGrad
            table.insert(UI_Elements.RowStrokeGradients, rowGrad)
            table.insert(UI_Elements.AnimatedGradients, rowGrad)
            
            local label = Instance.new("TextLabel", row)
            label.Size = UDim2.new(0.6, 0, 0, 30)
            label.Position = UDim2.new(0, 15, 0, 5)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold
            label.Text = text
            ApplyTextGradient(label)
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            if desc and desc ~= "" then
                local descLabel = Instance.new("TextLabel", row)
                descLabel.Size = UDim2.new(1, -80, 0, 15)
                descLabel.Position = UDim2.new(0, 15, 0, 30)
                descLabel.BackgroundTransparency = 1
                descLabel.Font = Enum.Font.GothamBold
                descLabel.Text = desc
                descLabel.TextSize = 10
                descLabel.TextColor3 = Themes[CurrentTheme].DescTextColor
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                table.insert(UI_Elements.Descriptions, descLabel)
            end

            local inputField = Instance.new("TextBox", row)
            inputField.Size = UDim2.new(0, 50, 0, 22)
            inputField.Position = UDim2.new(1, -65, 0, 10)
            inputField.BackgroundColor3 = Color3.fromHex("#000000")
            inputField.BackgroundTransparency = 0.9
            inputField.Font = Enum.Font.GothamBold
            inputField.Text = tostring(default)
            ApplyTextGradient(inputField)
            inputField.TextSize = 12
            Instance.new("UICorner", inputField).CornerRadius = UDim.new(0, 5)
            
            local flashFrame = Instance.new("Frame", inputField)
            flashFrame.Size = UDim2.new(1, 0, 1, 0)
            flashFrame.BackgroundColor3 = Color3.fromHex("#FFFFFF")
            flashFrame.BackgroundTransparency = 1
            flashFrame.ClipsDescendants = true
            Instance.new("UICorner", flashFrame).CornerRadius = UDim.new(0, 5)
            
            local flashGrad = Instance.new("UIGradient", flashFrame)
            flashGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
                ColorSequenceKeypoint.new(0.5, Color3.fromHex("#FFFFFF")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
            })
            flashGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.5, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
            flashGrad.Rotation = 45
            flashGrad.Offset = Vector2.new(-1, 0)

            local function PlayNeonPulse()
                flashFrame.BackgroundTransparency = 0.4
                flashGrad.Offset = Vector2.new(-1.5, 0)
                local flashTween = TweenService:Create(flashGrad, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Offset = Vector2.new(1.5, 0)})
                flashTween:Play()
                flashTween.Completed:Connect(function()
                    flashFrame.BackgroundTransparency = 1
                end)
            end
            
            local sliderBg = Instance.new("Frame", row)
            sliderBg.Size = UDim2.new(1, -30, 0, 6)
            local sliderYPos = (desc and desc ~= "") and 60 or 45
            sliderBg.Position = UDim2.new(0, 15, 0, sliderYPos)
            sliderBg.BackgroundColor3 = Color3.fromHex("#FFFFFF")
            sliderBg.BackgroundTransparency = 0.9
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
            
            local sliderHitbox = Instance.new("TextButton", sliderBg)
            sliderHitbox.Size = UDim2.new(1, 0, 1, 20)
            sliderHitbox.Position = UDim2.new(0, 0, 0.5, 0)
            sliderHitbox.AnchorPoint = Vector2.new(0, 0.5)
            sliderHitbox.BackgroundTransparency = 1
            sliderHitbox.Text = ""
            sliderHitbox.ZIndex = 4

            local sliderFill = Instance.new("Frame", sliderBg)
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = Color3.fromHex("#FFFFFF")
            sliderFill.BorderSizePixel = 0
            Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
            
            local fillGrad = Instance.new("UIGradient", sliderFill)
            fillGrad.Color = Themes[CurrentTheme].TextGrad
            table.insert(UI_Elements.AnimatedGradients, fillGrad)

            local circle = Instance.new("Frame", sliderFill)
            circle.Size = UDim2.new(0, 65, 2, 60)
            circle.Position = UDim2.new(1, 0, 0.5, 0)
            circle.AnchorPoint = Vector2.new(0.5, 0.5)
            circle.BackgroundTransparency = 1
            circle.ZIndex = 5

            local circleVisual = Instance.new("Frame", circle)
            circleVisual.Size = UDim2.new(0, 14, 0, 14)
            circleVisual.Position = UDim2.new(0.5, 0, 0.5, 0)
            circleVisual.AnchorPoint = Vector2.new(0.5, 0.5)
            circleVisual.BackgroundColor3 = Color3.fromHex("#FFFFFF")
            Instance.new("UICorner", circleVisual).CornerRadius = UDim.new(1, 0)
            
            local function EmitParticles(amount)
                amount = amount or 15
                if not sliderBg or not sliderBg.Parent then return end
                for i = 1, amount do
                    local p = Instance.new("Frame", sliderBg)
                    p.Size = UDim2.new(0, math.random(3, 6), 0, math.random(3, 6))
                    p.Position = UDim2.new(sliderFill.Size.X.Scale, 0, 0.5, 0)
                    p.AnchorPoint = Vector2.new(0.5, 0.5)
                    p.BackgroundColor3 = Themes[CurrentTheme] and Themes[CurrentTheme].ToggleActive or Color3.fromHex("#FFFFFF")
                    p.ZIndex = 10
                    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
                    
                    local angle = math.rad(math.random(0, 360))
                    local dist = math.random(15, 35)
                    local offX = math.cos(angle) * dist
                    local offY = math.sin(angle) * dist
                    
                    local tw = TweenService:Create(p, TweenInfo.new(math.random(4, 8)/10, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Position = p.Position + UDim2.new(0, offX, 0, offY),
                        Size = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 1
                    })
                    tw:Play()
                    tw.Completed:Connect(function() p:Destroy() end)
                end
            end

            local flagId = GetSecureFlag(text, flag)
            local function SetValue(val)
                val = math.clamp(val, min, max)
                sliderFill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                inputField.Text = tostring(val)
                if Library.ConfigElements[flagId] then
                    Library.ConfigElements[flagId].Value = val
                end
                if callback then callback(val) end
            end

            Library.ConfigElements[flagId] = { Value = default, Set = SetValue }

            local lastEmit = 0
            local function move(input)
                local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                SetValue(value)
                
                if tick() - lastEmit > 0.06 then
                    lastEmit = tick()
                    EmitParticles(2)
                end
            end
            
            local dragging = false
            circle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
                    dragging = true 
                    EmitParticles(10)
                    TweenService:Create(circleVisual, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Size = UDim2.new(0, 10, 0, 10)}):Play()
                end
            end)
            
            sliderHitbox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true 
                    local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * pos)
                    
                    TweenService:Create(circleVisual, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                    
                    SetValue(value)
                    EmitParticles(10)
                    
                    TweenService:Create(circleVisual, TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Size = UDim2.new(0, 14, 0, 14)}):Play()
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if dragging then
                        dragging = false
                        TweenService:Create(circleVisual, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {Size = UDim2.new(0, 14, 0, 14)}):Play()
                        Library:AutoSave()
                    end
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
                    move(input) 
                end
            end)

            inputField.FocusLost:Connect(function()
                local val = tonumber(inputField.Text)
                if not val then val = default end
                val = math.clamp(val, min, max)
                
                inputField.Text = tostring(val)
                TweenService:Create(sliderFill, TweenInfo.new(0.2), {Size = UDim2.new((val - min) / (max - min), 0, 1, 0)}):Play()
                PlayNeonPulse()
                EmitParticles(15)
                
                if Library.ConfigElements[flagId] then
                    Library.ConfigElements[flagId].Value = val
                end
                if callback then callback(val) end
                Library:AutoSave()
            end)
        end
---------

        ---------
    function Tab:CreateCopy(titleText, contentToCopy, descText)
        local rowHeight = (descText and descText ~= "") and 65 or 50
        local row = Instance.new("Frame", page)
        row.Size = UDim2.new(1, -4, 0, rowHeight)
        row.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
        row.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
        row.ClipsDescendants = true
        table.insert(UI_Elements.Containers, row)
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
            
            local rowStroke = Instance.new("UIStroke", row)
            rowStroke.Color = Themes[CurrentTheme].RowStroke
            rowStroke.Thickness = 1.2
            rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            table.insert(UI_Elements.RowStrokes, rowStroke)
            
            local rowGrad = Instance.new("UIGradient", rowStroke)
            rowGrad.Color = Themes[CurrentTheme].RowStrokeGrad
            table.insert(UI_Elements.RowStrokeGradients, rowGrad)
            table.insert(UI_Elements.AnimatedGradients, rowGrad)

            local title = Instance.new("TextLabel", row)
            title.Size = UDim2.new(1, -50, 0, 30)
            title.Position = UDim2.new(0, 12, 0, 10)
            title.BackgroundTransparency = 1
            title.Font = Enum.Font.GothamBold
            title.Text = titleText
            ApplyTextGradient(title)
            title.TextSize = 13.5
            title.TextXAlignment = Enum.TextXAlignment.Left

            if descText and descText ~= "" then
                title.Position = UDim2.new(0, 12, 0, 5)
                local descLabel = Instance.new("TextLabel", row)
                descLabel.Size = UDim2.new(1, -60, 0, 20)
                descLabel.Position = UDim2.new(0, 12, 0, 28)
                descLabel.BackgroundTransparency = 1
                descLabel.Font = Enum.Font.GothamBold
                descLabel.Text = descText
                descLabel.TextSize = 10
                descLabel.TextColor3 = Themes[CurrentTheme].DescTextColor
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                descLabel.TextWrapped = true
                table.insert(UI_Elements.Descriptions, descLabel)
            end

            local copyBtn = Instance.new("TextButton", row)
            copyBtn.Size = UDim2.new(0, 30, 0, 30)
            copyBtn.Position = UDim2.new(1, -5, 0, 5)
            copyBtn.AnchorPoint = Vector2.new(1, 0)
            copyBtn.BackgroundTransparency = 1
            copyBtn.Text = ""
            
            local coreContainer = Instance.new("Frame", copyBtn)
            coreContainer.AnchorPoint = Vector2.new(0.5, 0.5)
            coreContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
            coreContainer.Size = UDim2.new(1, 0, 1, 0)
            coreContainer.BackgroundTransparency = 1
            
            local uiScale = Instance.new("UIScale", coreContainer)
            uiScale.Scale = 1
            
            local coreLayers = {}
            local baseSizes = {8, 12, 16, 20, 24, 28} 
            local baseTransparencies = {0.1, 0.3, 0.5, 0.7, 0.85, 0.93}
            
            for i = 1, #baseSizes do
                local layer = Instance.new("Frame")
                layer.AnchorPoint = Vector2.new(0.5, 0.5)
                layer.Position = UDim2.new(0.5, 0, 0.5, 0)
                layer.BorderSizePixel = 0
                layer.ZIndex = 3
                Instance.new("UICorner", layer).CornerRadius = UDim.new(1, 0)
                layer.Parent = coreContainer
                table.insert(coreLayers, {frame = layer, baseSize = baseSizes[i], baseTrans = baseTransparencies[i]})
            end
            
            local r = 0
            local isClicked = false
            local clickTime = 0
            
            local renderConn
            renderConn = RunService.RenderStepped:Connect(function()
                if not copyBtn.Parent then
                    if renderConn then renderConn:Disconnect() end
                    return
                end
                
                r = (r + 1.5) % 360
                local t = Themes[CurrentTheme]
                
               local c1, c2
                if isClicked then
                    c1 = t.ToggleActive
                    c2 = t.ToggleActive
                else
                    c1 = Color3.fromRGB(150, 150, 150)
                    c2 = Color3.fromRGB(150, 150, 150)
                end
                
                local pulse = (math.sin(tick() * 3) + 1) / 2
                local coreColor = c1:Lerp(c2, math.abs(math.sin((r / 360) * math.pi)))
                
                for _, data in ipairs(coreLayers) do
                    local sizeOffset = pulse * 3
                    local targetSize = data.baseSize + sizeOffset
                    data.frame.Size = UDim2.new(0, targetSize, 0, targetSize)
                    data.frame.BackgroundColor3 = coreColor
                    data.frame.BackgroundTransparency = math.clamp(data.baseTrans + (pulse * 0.05), 0, 1)
                end
                
                if isClicked and tick() - clickTime >= 0.5 then
                    isClicked = false
                    TweenService:Create(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {Scale = 1}):Play()
                end
            end)

           local lastMousePos = Vector2.new(0, 0)
        
        copyBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                lastMousePos = Vector2.new(input.Position.X, input.Position.Y)
                TweenService:Create(uiScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Scale = 0.8}):Play()
                
                TweenService:Create(row, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Rotation = -0.5, 
                    BackgroundTransparency = math.clamp(Themes[CurrentTheme].ContainerTrans + 0.15, 0, 1)
                }):Play()
            end
        end)
        
        copyBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if not isClicked then
                    TweenService:Create(uiScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Scale = 1}):Play()
                end
                TweenService:Create(row, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Rotation = 0, 
                    BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
                }):Play()
            end
        end)
        
        copyBtn.MouseButton1Click:Connect(function()
            isClicked = true
            clickTime = tick()
            TweenService:Create(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {Scale = 1.3}):Play()
            
            local ripple = Instance.new("Frame")
            ripple.Name = "LiquidRipple"
            ripple.Parent = row
            ripple.BackgroundColor3 = Themes[CurrentTheme].ToggleActive
            ripple.BorderSizePixel = 0
            ripple.ZIndex = 4
            Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
            
            local ripGrad = Instance.new("UIGradient", ripple)
            ripGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Themes[CurrentTheme].ToggleActive),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
            })
            ripGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.7, 0.4),
                NumberSequenceKeypoint.new(1, 1)
            })
            
            local relativeX = lastMousePos.X - row.AbsolutePosition.X
            local relativeY = lastMousePos.Y - row.AbsolutePosition.Y
            
            if lastMousePos.X == 0 and lastMousePos.Y == 0 then
                relativeX = copyBtn.AbsolutePosition.X + copyBtn.AbsoluteSize.X / 2 - row.AbsolutePosition.X
                relativeY = copyBtn.AbsolutePosition.Y + copyBtn.AbsoluteSize.Y / 2 - row.AbsolutePosition.Y
            end
            
            ripple.Position = UDim2.new(0, relativeX, 0, relativeY)
            ripple.Size = UDim2.new(0, 0, 0, 0)
            ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            
            local maxDim = math.max(row.AbsoluteSize.X, row.AbsoluteSize.Y) * 1.5
            local ripTween = TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, maxDim, 0, maxDim),
                BackgroundTransparency = 1
            })
            ripTween:Play()
            ripTween.Completed:Connect(function() ripple:Destroy() end)
            
            local clipboardFunc = setclipboard or toclipboard or function(text) warn("Clipboard: " .. tostring(text)) end
            clipboardFunc(contentToCopy)
            Library:SendNotification("Copied Successfully", titleText)
        end)
    end

---------
    function Tab:CreateConfigBoard(descText)
        local closedHeight = 96
        local expandedHeight = 310
        local isExpanded = true

        local container = Instance.new("Frame", page)
        container.Size = UDim2.new(1, -4, 0, expandedHeight)
        container.Position = UDim2.new(0, 2, 0, 0)
        container.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
        container.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
        container.ClipsDescendants = true
        table.insert(UI_Elements.Containers, container)
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)

        local containerStroke = Instance.new("UIStroke", container)
        containerStroke.Color = Themes[CurrentTheme].RowStroke
        containerStroke.Thickness = 1.2
        containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        table.insert(UI_Elements.RowStrokes, containerStroke)

        local containerGrad = Instance.new("UIGradient", containerStroke)
        containerGrad.Color = Themes[CurrentTheme].RowStrokeGrad
        table.insert(UI_Elements.RowStrokeGradients, containerGrad)
        table.insert(UI_Elements.AnimatedGradients, containerGrad)

        local headerBtn = Instance.new("TextButton", container)
        headerBtn.Size = UDim2.new(1, 0, 0, 52)
        headerBtn.Position = UDim2.new(0, 0, 0, 0)
        headerBtn.BackgroundTransparency = 1
        headerBtn.Text = ""

        local titleLabel = Instance.new("TextLabel", headerBtn)
        titleLabel.Size = UDim2.new(1, -65, 0, 24)
        titleLabel.Position = UDim2.new(0, 15, 0, 6)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Text = "Configuration Board"
        ApplyTextGradient(titleLabel)
        titleLabel.TextSize = 14
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left

        if descText and descText ~= "" then
            local descLabel = Instance.new("TextLabel", headerBtn)
            descLabel.Size = UDim2.new(1, -65, 0, 16)
            descLabel.Position = UDim2.new(0, 15, 0, 28)
            descLabel.BackgroundTransparency = 1
            descLabel.Font = Enum.Font.GothamBold
            descLabel.Text = descText
            descLabel.TextSize = 10
            descLabel.TextColor3 = Themes[CurrentTheme].DescTextColor
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            table.insert(UI_Elements.Descriptions, descLabel)
        end


        local arrowWrapper = Instance.new("Frame", headerBtn)
        arrowWrapper.Size = UDim2.new(0, 30, 0, 30)
        arrowWrapper.Position = UDim2.new(1, -15, 0.5, 0)
        arrowWrapper.AnchorPoint = Vector2.new(1, 0.5)
        arrowWrapper.BackgroundColor3 = Themes[CurrentTheme].ContainerBg
        arrowWrapper.BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
        table.insert(UI_Elements.Containers, arrowWrapper)
        Instance.new("UICorner", arrowWrapper).CornerRadius = UDim.new(0, 8)


        local arrowStroke = Instance.new("UIStroke", arrowWrapper)
        arrowStroke.Thickness = 1.2
        arrowStroke.Color = Themes[CurrentTheme].RowStroke
        arrowStroke.Transparency = 0.2
        table.insert(UI_Elements.RowStrokes, arrowStroke)

        local arrowGrad = Instance.new("UIGradient", arrowStroke)
        arrowGrad.Rotation = -90
        arrowGrad.Color = Themes[CurrentTheme].RowStrokeGrad
        table.insert(UI_Elements.RowStrokeGradients, arrowGrad)


        local arrowScale = Instance.new("UIScale", arrowWrapper)
        arrowScale.Scale = 1


        local arrow = Instance.new("TextLabel", arrowWrapper)
        arrow.Size = UDim2.new(1, 0, 1, 0)
        arrow.BackgroundTransparency = 1
        arrow.Font = Enum.Font.GothamBold
        arrow.Text = "▼"
        arrow.TextSize = 10
        arrow.Rotation = 180
        arrow.AnchorPoint = Vector2.new(0.5, 0.5)
        arrow.Position = UDim2.new(0.5, 0, 0.5, 0)
        ApplyTextGradient(arrow)

        local boardFrame = Instance.new("Frame", container)
        boardFrame.Size = UDim2.new(1, -26, 1, -66)
        boardFrame.Position = UDim2.new(0, 13, 0, 52)
        boardFrame.BackgroundColor3 = Color3.fromHex("#000000")
        boardFrame.BackgroundTransparency = 0.65
        boardFrame.ClipsDescendants = true
        local boardCorner = Instance.new("UICorner", boardFrame)
        boardCorner.CornerRadius = UDim.new(0, 8)

        local boardStroke = Instance.new("UIStroke", boardFrame)
        boardStroke.Color = Themes[CurrentTheme].RowStroke
        boardStroke.Thickness = 1
        boardStroke.Transparency = 0.5
        table.insert(UI_Elements.RowStrokes, boardStroke)

        local inputBox = Instance.new("TextBox", boardFrame)
        inputBox.Size = UDim2.new(1, 0, 1, 0)
        inputBox.BackgroundTransparency = 1
        inputBox.Font = Enum.Font.Code
        inputBox.Text = ""
        inputBox.PlaceholderText = "Paste your JSON config here to sync..."
        ApplyTextGradient(inputBox)
        inputBox.TextSize = 11
        inputBox.TextXAlignment = Enum.TextXAlignment.Left
        inputBox.TextYAlignment = Enum.TextYAlignment.Top
        inputBox.ClearTextOnFocus = false
        inputBox.MultiLine = true
        inputBox.TextWrapped = true


        local boxPadding = Instance.new("UIPadding", inputBox)
        boxPadding.PaddingLeft = UDim.new(0, 14)
        boxPadding.PaddingRight = UDim.new(0, 14)
        boxPadding.PaddingTop = UDim.new(0, 6)
        boxPadding.PaddingBottom = UDim.new(0, 6)

        local lastClickPos = Vector2.new(0, 0)
        headerBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                lastClickPos = Vector2.new(input.Position.X, input.Position.Y)
                TweenService:Create(arrowScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Scale = 0.8}):Play()
                TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Rotation = -0.5,
                    BackgroundTransparency = math.clamp(Themes[CurrentTheme].ContainerTrans + 0.15, 0, 1)
                }):Play()
            end
        end)

        headerBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                TweenService:Create(arrowScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Scale = 1}):Play()
                TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Rotation = 0,
                    BackgroundTransparency = Themes[CurrentTheme].ContainerTrans
                }):Play()
            end
        end)

        headerBtn.MouseButton1Click:Connect(function()
            isExpanded = not isExpanded
            local targetHeight = isExpanded and expandedHeight or closedHeight
            local targetRotation = isExpanded and 180 or 0
            local targetBoardHeight = isExpanded and UDim2.new(1, -26, 1, -66) or UDim2.new(1, -26, 0, 32)
            local targetCornerRadius = isExpanded and UDim.new(0, 8) or UDim.new(1, 0)

            inputBox.TextYAlignment = isExpanded and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center

            TweenService:Create(arrowScale, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {Scale = 1.3}):Play()
            task.delay(0.25, function()
                TweenService:Create(arrowScale, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Scale = 1}):Play()
            end)

            local ripple = Instance.new("Frame", container)
            ripple.Name = "LiquidRipple"
            ripple.BackgroundColor3 = Themes[CurrentTheme].ToggleActive
            ripple.BorderSizePixel = 0
            ripple.ZIndex = 4
            Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)

            local ripGrad = Instance.new("UIGradient", ripple)
            ripGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Themes[CurrentTheme].ToggleActive),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
            })
            ripGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.7, 0.4),
                NumberSequenceKeypoint.new(1, 1)
            })

            local relativeX = lastClickPos.X - container.AbsolutePosition.X
            local relativeY = lastClickPos.Y - container.AbsolutePosition.Y
            if lastClickPos.X == 0 and lastClickPos.Y == 0 then
                relativeX = arrowWrapper.AbsolutePosition.X + arrowWrapper.AbsoluteSize.X / 2 - container.AbsolutePosition.X
                relativeY = arrowWrapper.AbsolutePosition.Y + arrowWrapper.AbsoluteSize.Y / 2 - container.AbsolutePosition.Y
            end

            ripple.Position = UDim2.new(0, relativeX, 0, relativeY)
            ripple.Size = UDim2.new(0, 0, 0, 0)
            ripple.AnchorPoint = Vector2.new(0.5, 0.5)

            local maxDim = math.max(container.AbsoluteSize.X, 310) * 1.5
            local ripTween = TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, maxDim, 0, maxDim),
                BackgroundTransparency = 1
            })
            ripTween:Play()
            ripTween.Completed:Connect(function() ripple:Destroy() end)

            TweenService:Create(container, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -4, 0, targetHeight)}):Play()
            TweenService:Create(boardFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetBoardHeight}):Play()
            TweenService:Create(boardCorner, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {CornerRadius = targetCornerRadius}):Play()
            TweenService:Create(arrow, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()
        end)

        inputBox.FocusLost:Connect(function()
            local txt = inputBox.Text
            if txt ~= "" then
                local success, data = pcall(function()
                    return HttpService:JSONDecode(txt)
                end)
                if success and type(data) == "table" then
                    Library.IsLoading = true
                    for flag, value in pairs(data) do
                        if Library.ConfigElements[flag] then
                            Library.ConfigElements[flag].Set(value)
                        end
                    end
                    Library.IsLoading = false
                    Library:SendNotification("Config System", "Synced settings from pasted JSON!")
                    inputBox.Text = ""
                else
                    Library:SendNotification("Config Error", "Invalid JSON format!")
                end
            end
        end)
    end


        return Tab
    end




function Window:ApplyTheme(name)
        local t = Themes[name]
        if not t then return end
        CurrentTheme = name
        
        if m then 
            TweenService:Create(m, TweenInfo.new(0.3), {BackgroundColor3 = t.MainBg, BackgroundTransparency = t.MainBgTrans}):Play()
        end
        
        local AuraGlow = g:FindFirstChild("AuraGlow")
        if AuraGlow then
            local auraColor = Color3.fromHex("#E0E0E0")
            if name == "Ocean" then
                auraColor = Color3.fromHex("#00E5FF")
            elseif name == "Dream" then
                auraColor = Color3.fromHex("#B026FF")
            end
            TweenService:Create(AuraGlow, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageColor3 = auraColor}):Play()
        end
        
        for _, bg in pairs(UI_Elements.Containers) do
            if bg and bg.Parent then
                TweenService:Create(bg, TweenInfo.new(0.3), {BackgroundColor3 = t.ContainerBg, BackgroundTransparency = t.ContainerTrans}):Play()
            end
        end
        
        for _, tabBg in pairs(UI_Elements.TabBackgrounds) do
            if tabBg and tabBg.Parent then
                TweenService:Create(tabBg, TweenInfo.new(0.3), {BackgroundColor3 = t.ContainerBg}):Play()
            end
        end
        
for _, obj in pairs(UI_Elements.TextGradients) do
            if obj and obj.Parent then 
                obj.Color = t.TextContrast 
                if obj.Parent:IsA("TextLabel") or obj.Parent:IsA("TextButton") or obj.Parent:IsA("TextBox") then
                    obj.Parent.TextColor3 = t.TextColor
                elseif obj.Parent:IsA("ImageLabel") then
                    obj.Parent.ImageColor3 = t.TextColor
                end
            end
        end

        for _, item in pairs(UI_Elements.AnimatedStrokes) do
            if item.Obj and item.Obj.Parent then
                TweenService:Create(item.Obj, TweenInfo.new(0.3), {Color = t[item.Type]}):Play()
            end
        end
        
        for _, s in pairs(UI_Elements.RowStrokes) do
            if s and s.Parent then
                TweenService:Create(s, TweenInfo.new(0.3), {Color = t.RowStroke}):Play()
            end
        end
        
        for _, g in pairs(UI_Elements.AnimatedGradients) do
            if g and g.Parent then g.Color = t.TextGrad end
        end
        
        for _, g in pairs(UI_Elements.RowStrokeGradients) do
            if g and g.Parent then g.Color = t.RowStrokeGrad end
        end
        
        for _, g in pairs(UI_Elements.TabGradients) do
            if g and g.Parent then g.Color = t.TabGrad end
        end
        
        for _, d in pairs(UI_Elements.DivGradients) do
            if d and d.Parent then d.Color = t.DivGrad end
        end
        
        ---------
---------
        for _, sw in pairs(UI_Elements.Switches) do
            if sw.Active then
                TweenService:Create(sw.Frame, TweenInfo.new(0.3), {BackgroundColor3 = t.ToggleActive}):Play()
                if sw.Glow then
                    TweenService:Create(sw.Glow, TweenInfo.new(0.3), {Color = t.ToggleActive}):Play()
                end
            end
        end
---------
        
        for _, desc in pairs(UI_Elements.Descriptions) do
            if desc and desc.Parent then
                TweenService:Create(desc, TweenInfo.new(0.3), {TextColor3 = t.DescTextColor}):Play()
            end
        end
    end

    
    local r = 0
    RunService.RenderStepped:Connect(function(dt)
        r = (r + 1.5) % 360
        e.Rotation = r
        
        for _, rotGrad in pairs(UI_Elements.RotatingGradients) do
            if rotGrad and rotGrad.Parent then 
                rotGrad.Rotation = r 
                rotGrad.Color = Themes[CurrentTheme].LoopSeq
            end
        end
        
        local animatedOffset = Vector2.new(math.sin(tick() * 2) * 0.4, 0)
        for _, grad in pairs(UI_Elements.AnimatedGradients) do
            if grad and grad.Parent then grad.Offset = animatedOffset end
        end
        for _, grad in pairs(UI_Elements.RowStrokeGradients) do
            if grad and grad.Parent then grad.Offset = animatedOffset end
        end
        for _, grad in pairs(UI_Elements.TabGradients) do
            if grad and grad.Parent then grad.Offset = animatedOffset end
        end
        
---------
        if Mini3DIcon.Visible then
            angleY = angleY + dt * 0.6
            angleX = angleX + dt * 0.35
            
            local mousePos = UserInputService:GetMouseLocation()
            local iconCenter = Mini3DIcon.AbsolutePosition + Mini3DIcon.AbsoluteSize / 2
            local dist = (mousePos - iconCenter).Magnitude
            
            local targetTiltX, targetTiltY = 0, 0
            if dist < 250 then
                local delta = mousePos - iconCenter
                targetTiltY = (delta.X / 250) * 0.8
                targetTiltX = (delta.Y / 250) * 0.8
            end
            
            currentTiltX = currentTiltX + (targetTiltX - currentTiltX) * (dt * 8)
            currentTiltY = currentTiltY + (targetTiltY - currentTiltY) * (dt * 8)
            
            local finalAngleX = angleX + currentTiltX
            local finalAngleY = angleY + currentTiltY

            local pulse = (math.sin(tick() * 3) + 1) / 2
            local tVal = (r / 360)
            
            local c1 = Themes[CurrentTheme].TextGrad.Keypoints[1].Value
            local c2 = Themes[CurrentTheme].ToggleActive
            local coreColor = c1:Lerp(c2, math.abs(math.sin(tVal * math.pi)))
            
            for _, grad in ipairs(lineGradients) do
                grad.Rotation = r
                grad.Color = Themes[CurrentTheme].LoopSeq
            end
            
            for _, data in ipairs(coreLayers) do
                local sizeOffset = pulse * 12
                data.frame.Size = UDim2.new(0, data.baseSize + sizeOffset, 0, data.baseSize + sizeOffset)
                data.frame.BackgroundColor3 = coreColor
                data.frame.BackgroundTransparency = math.clamp(data.baseTrans + (pulse * 0.05), 0, 1)
            end
            
            for i, edge in ipairs(edges) do
                local p1, z1 = project3D(vertices[edge[1]], finalAngleX, finalAngleY)
                local p2, z2 = project3D(vertices[edge[2]], finalAngleX, finalAngleY)
                local line = lines[i]
---------
                local diff = p2 - p1
                line.Size = UDim2.new(0, diff.Magnitude, 0, 0.1)
                line.Position = UDim2.new(0, (p1.X + p2.X) / 2, 0, (p1.Y + p2.Y) / 2)
                line.Rotation = math.deg(math.atan2(diff.Y, diff.X))
                local avgZ = (z1 + z2) / 2
                line.BackgroundTransparency = 1 - math.clamp(1 - (avgZ / 2.5), 0.15, 1)
                
                local strk = line:FindFirstChildWhichIsA("UIStroke")
                if avgZ > 0 then
                    line.ZIndex = 2
                    if strk then strk.Transparency = 0.8 end
                else
                    line.ZIndex = 4
                    if strk then strk.Transparency = math.clamp(0.4 - (pulse * 0.2), 0, 1) end
                end
            end
        end
    end)

---------
    m.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(m, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 525)}):Play()
    Library:SendNotification("Status", "Hub Initialized!")
    
    task.spawn(function()
        -- config comes from the loadstring (Config table); do not load an old AutoSave file over it
        task.wait(1.5)
    end)

    local InfoTab = Window:CreateTab("Information", false, "rbxassetid://132312092981034")
    InfoTab:CreatePageTitle("Information")
            InfoTab:CreateLabel("System", "FLOWBR Kaitun")
    
---------
    local dfSettingsTab = Window:CreateTab("Config & Themes", false, "rbxassetid://136384267867469")
    
    dfSettingsTab:CreatePageTitle("Configuration")
    
    dfSettingsTab:CreateButton("Copy Configuration", "Copy to clipboard with beautiful format", function()
        local data = {}
        for flag, element in pairs(Library.ConfigElements) do
            data[flag] = element.Value
        end
        
        local function Beautify(tbl, indent)
            indent = indent or 1
            local formatting = string.rep("    ", indent)
            local json = "{\n"
            local isFirst = true
            for k, v in pairs(tbl) do
                if not isFirst then
                    json = json .. ",\n"
                end
                isFirst = false
                local valStr = ""
                if type(v) == "table" then
                    valStr = "["
                    for i, arrV in ipairs(v) do
                        valStr = valStr .. '"' .. tostring(arrV) .. '"'
                        if i < #v then valStr = valStr .. ", " end
                    end
                    valStr = valStr .. "]"
                elseif type(v) == "string" then
                    valStr = '"' .. tostring(v) .. '"'
                else
                    valStr = tostring(v)
                end
                json = json .. formatting .. '"' .. tostring(k) .. '": ' .. valStr
            end
            json = json .. "\n" .. string.rep("    ", indent - 1) .. "}"
            return json
        end

        local prettyJson = Beautify(data)
        local clipboardFunc = setclipboard or toclipboard or function(text) warn("Clipboard: " .. tostring(text)) end
        clipboardFunc(prettyJson)
        Library:SendNotification("Config System", "Copied beautiful JSON to clipboard!")
    end)
    
    dfSettingsTab:CreateConfigBoard("Paste JSON config below to sync all settings")

    dfSettingsTab:CreatePageTitle("Themes")
    dfSettingsTab:CreateDropdown("Select Theme", "", {"Ocean", "Dream", "Dark"}, "Change UI colors", function(selected)
        Window:ApplyTheme(selected)
    end)
    dfSettingsTab:CreatePageTitle("Fonts")
    local fontList = {
        "FredokaOne",
        "Bangers",
        "DenkOne",
        "Kalam",
        "Creepster",
        "AmaticSC",
        "PatrickHand",
        "Boogaloo",
        "PermanentMarker",
        "IndieFlower",
        "Fondamento",
        "LuckiestGuy",
        "SpecialElite",
        "Jura",
        "Sarpanch"
    }
    dfSettingsTab:CreateDropdown("Select Font", "FredokaOne", fontList, "Change UI font family", function(selected)
        Library:ApplyFont(selected)
    end)
    dfSettingsTab:CreateSlider("Text Size", 50, 300, 100, "Scale text size (Default: 100%, Max: 300%)", function(value)
        Library:ApplyFontScale(value)
    end)
    if TabsList[#TabsList] then
        TabsList[#TabsList].Btn.LayoutOrder = 9999
    end

    return Window
end
-- -------------------------
return Library
end)() --end UI Library

local Window = Library:CreateWindow({
    Title = "FLOWBR - Kaitun Leviathan"
})
if Cfg.UI.ShowSettings ~= true then
    pcall(function() getgenv().MainUI_Library.Enabled = false end)
end

local W = 0
local lastChange = tick()

local function RoundVector3Down(vec)
    return Vector3.new(math.floor(vec.X), math.floor(vec.Y), math.floor(vec.Z))
end

local function CaculateCircreDirection(PositionCFrame, distanceY, radius)
    radius = radius or 25
    if W > 50000 then W = 60000 end
    W = W + ((tick() - lastChange) > 0.4 and 80 or 0)
    if tick() - lastChange > 0.4 then lastChange = tick() end
    local TargetPosition = PositionCFrame.Position + Vector3.new(math.cos(math.rad(W)) * radius, distanceY, math.sin(math.rad(W)) * radius)
    return CFrame.new(RoundVector3Down(TargetPosition))
end

local function EquipGun(gunName)
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local targetPart = getgenv().CurrentTargetPart

    if hrp and targetPart then
        local myPos = hrp.Position
        local targetPos = targetPart.Position
        local distXZ = (Vector3.new(targetPos.X, 0, targetPos.Z) - Vector3.new(myPos.X, 0, myPos.Z)).Magnitude

        if distXZ > 200 then
            return 
        end
    end

    if not gunName then return end
    
    local char = LP.Character
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if char:FindFirstChild(gunName) then
        return
    end

    local toolInBackpack = LP.Backpack:FindFirstChild(gunName)
    if toolInBackpack and toolInBackpack:IsA("Tool") then
        humanoid:EquipTool(toolInBackpack)
        return
    end

    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("LoadItem", gunName)
end


local function equip(typeCheck)
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        while true do
            local tooClose = false
            local boats = workspace:FindFirstChild("Boats")
            if boats then
                for _, boat in pairs(boats:GetChildren()) do
                    for _, part in pairs(boat:GetDescendants()) do
                        if part:IsA("VehicleSeat") or part:IsA("Seat") then
                            if (part.Position - hrp.Position).Magnitude <= 20 then
                                tooClose = true
                                break
                            end
                        end
                    end
                    if tooClose then break end
                end
            end
            
            if not tooClose then
                break
            end
            task.wait(0.1)
        end
    end

    local tooltipToFind = typeCheck
    if typeCheck == "Fruit" then tooltipToFind = "Blox Fruit" end
    
    for _, item in pairs(LP.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.ToolTip == tooltipToFind then
            local humanoid = LP.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and not humanoid:IsDescendantOf(item) then
                humanoid:EquipTool(item)
                return item.Name
            end
        end
    end
    for _, item in pairs(LP.Character:GetChildren()) do
        if item:IsA("Tool") and item.ToolTip == tooltipToFind then
            return item.Name
        end
    end
    return nil
end

local function GetNearestSeaEvent()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil, nil end

    local target = nil
    local minDist = 2000
    local eventType = nil
    local targetPosition = nil

   local enemies = Workspace:FindFirstChild("Enemies")
    if enemies then
        local isFishBoatAlive = false
        for _, mob in ipairs(enemies:GetChildren()) do
            if mob.Name:find("FishBoat") then
                local healthVal = mob:FindFirstChild("Health")
                if healthVal and healthVal.Value > 0 then
                    isFishBoatAlive = true
                    break
                end
            end
        end

        for _, mob in ipairs(enemies:GetChildren()) do
            local n = mob.Name
            local mobPos = nil
            local isValid = false
            local eType = nil

            if n:find("Piranha") or n:find("Terrorshark") or n:find("Shark") or n:find("Fish Crew Member") then
                local hum = mob:FindFirstChild("Humanoid")
                local root = mob:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    mobPos = root.Position
                    if n:find("Piranha") and table.find(_G.SelectedEvents, "Piranha") then isValid = true; eType = "M1"
                    elseif n:find("Terrorshark") and table.find(_G.SelectedEvents, "Terrorshark") then isValid = true; eType = "M1"
                    elseif n:find("Shark") and table.find(_G.SelectedEvents, "Shark") then isValid = true; eType = "M1"
                    elseif n:find("Fish Crew Member") and table.find(_G.SelectedEvents, "FishBoat") then
                        if not isFishBoatAlive then
                            isValid = true; eType = "M1"
                        end
                    end
                end
            elseif n:find("PirateBrigade") or n:find("PirateGrandBrigade") or n:find("FishBoat") then
                local healthVal = mob:FindFirstChild("Health")
                if healthVal and healthVal.Value > 0 then
                    mobPos = mob:GetPivot().Position
                    if n:find("PirateGrandBrigade") then
                        if table.find(_G.SelectedEvents, "PirateGrandBrigade") then isValid = true; eType = "Skill" end
                    elseif n:find("PirateBrigade") then
                        if table.find(_G.SelectedEvents, "PirateBrigade") then isValid = true; eType = "Skill" end
                    elseif n:find("FishBoat") then
                        if table.find(_G.SelectedEvents, "FishBoat") then isValid = true; eType = "Skill" end
                    end
                end
            end

            if isValid and mobPos then
                local dist = (mobPos - hrp.Position).Magnitude
                if dist <= minDist then
                    minDist = dist
                    target = mob
                    eventType = eType
                    targetPosition = mobPos
                end
            end
        end
    end


	if workspace:FindFirstChild("SeaBeasts") then
		local seaBeastsFolder = workspace:FindFirstChild("SeaBeasts")
		local segmentFound = false

		for _, mob in ipairs(seaBeastsFolder:GetChildren()) do
			if mob.Name == "Leviathan Segment" then
				local isAlive = false
				local success, health = pcall(function()
					local healthObj = mob:FindFirstChild("Health")
					if healthObj and (healthObj.ClassName == "IntValue" or healthObj.ClassName == "IntConstrainedValue") then
						return healthObj.Value
					end
					return mob:FindFirstChild("Humanoid").Health
				end)

				local mobRoot = mob:FindFirstChild("HumanoidRootPart")
				if mobRoot then
					if success and health > 0 then
						isAlive = true
					elseif not success then
						isAlive = true
					end
				end

				if isAlive then
					segmentFound = true
					break
				end
			end
		end

		for _, mob in ipairs(seaBeastsFolder:GetChildren()) do
			if mob.Name:find("SeaBeast1") or mob.Name == "Leviathan Segment" or mob.Name == "Leviathan" then
				local isAlive = false
				local success, health = pcall(function()
					local healthObj = mob:FindFirstChild("Health")
					if healthObj and (healthObj.ClassName == "IntValue" or healthObj.ClassName == "IntConstrainedValue") then
						return healthObj.Value
					end
					return mob:FindFirstChild("Humanoid").Health
				end)

				local mobRoot = mob:FindFirstChild("HumanoidRootPart")
				if mobRoot then
					if success and health > 0 then
						isAlive = true
					elseif not success then
						isAlive = true
					end
				end

				if isAlive and mobRoot then
					local mobPos = mobRoot.Position

					local isLevi = (mob.Name == "Leviathan Segment" or mob.Name == "Leviathan")
					local isSB = mob.Name:find("SeaBeast1")
					
					local canAttack = false
					if isLevi and table.find(_G.SelectedEvents, "Leviathan") then canAttack = true end
					if isSB and table.find(_G.SelectedEvents, "Sea Beast") then canAttack = true end

					if canAttack then
						if mob.Name == "Leviathan" and segmentFound then
							continue
						end

						local dist = (mobPos - hrp.Position).Magnitude
						if dist <= minDist or mob.Name == "Leviathan Segment" or mob.Name == "Leviathan" then
							minDist = dist
							target = mob
							eventType = "SeaBeast"
							targetPosition = mobPos
						end
					end
				end
			end
		end
	end



    return target, eventType, targetPosition
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local FOLDER_NAME = "Flowbr_Leviathan_Kaitun"
local FILE_NAME = FOLDER_NAME .. "/Name.json"
local API_URL = "https://multi-api-web.onrender.com/api/leviathan" 
local SECRET_KEY = "iemnacutez.19.09.2011"

local function getHash(str)
    if syn and syn.crypt and syn.crypt.hash then return syn.crypt.hash(str, "sha256") end
    if crypt and crypt.hash then return crypt.hash(str, "sha256") end
    return "" -- Fallback nếu executor hông hỗ trợ hash
end

local function requestAPI(method, bodyInfo)
    if Cfg.PartyAPI == false then return false, nil end
    local req = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
    if not req then return false, nil end
    
    local groupId = tostring(_G.NguoiMuaThuyen)
    local timestamp = math.floor(os.time())
    
    local dataToHash = tostring(timestamp) .. groupId
    if method == "POST" and bodyInfo then
        dataToHash = dataToHash .. tostring(bodyInfo.Name or "")
    end
    
    local signature = getHash(dataToHash .. SECRET_KEY)
    
    local success, res = pcall(function()
        return req({
            Url = API_URL,
            Method = method,
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-group"] = groupId,
                ["x-timestamp"] = tostring(timestamp),
                ["x-signature"] = signature
            },
            Body = bodyInfo and HttpService:JSONEncode(bodyInfo) or nil
        })
    end)
    if success and res and type(res) == "table" and res.StatusCode == 200 then
        local s, d = pcall(function() return HttpService:JSONDecode(res.Body) end)
        if s and d then return true, d end
    end
    return false, nil
end

local function ReadJSONFile(path)
    if isfile and isfile(path) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if success and type(result) == "table" then
            return result
        end
    end
    return nil
end

local function WriteJSONFile(path, data)
    if writefile then
        pcall(function()
            writefile(path, HttpService:JSONEncode(data))
        end)
    end
end

getgenv().FetchUnifiedPartyData = function()
    local success, apiData = requestAPI("GET")
    if success and apiData then return apiData end
    return ReadJSONFile(FILE_NAME)
end

local function ManagePartyDatabase()
    if not makefolder or not isfolder or not writefile or not readfile then return end
    if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end

    local currentTime = os.time()
    local myName = LP.Name
    local myIDK = (_G.SpyCheckResult == -1)
    
    -- 1. Ưu tiên gửi Web API trước để đồng bộ liên máy
    local apiSuccess, finalApiData = requestAPI("POST", {Name = myName, LastTime = currentTime, IDK = myIDK})
    if apiSuccess and finalApiData then
        WriteJSONFile(FILE_NAME, finalApiData) -- Fallback backup ra workspace
        return
    end

    -- 2. Fallback Workspace nếu web down
    local rawData = ReadJSONFile(FILE_NAME)
    local accountList = {}

    if rawData then
        for _, info in pairs(rawData) do
            if type(info) == "table" and info.Name then
                table.insert(accountList, {
                    Name = tostring(info.Name),
                    LastTime = tonumber(info.LastTime) or 0,
                    IDK = (info.IDK == true)
                })
            end
        end
    end

    local isMeFound = false
    for _, acc in ipairs(accountList) do
        if acc.Name == myName then
            acc.LastTime = currentTime
            acc.IDK = myIDK
            isMeFound = true
            break
        end
    end

    if not isMeFound then
        table.insert(accountList, { Name = myName, LastTime = currentTime, IDK = myIDK })
    end

    local onlinePlayers = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        onlinePlayers[plr.Name] = true
    end

    local filteredList = {}
    for _, acc in ipairs(accountList) do
        local timeDiff = currentTime - acc.LastTime
        if not ((timeDiff > 300) and not onlinePlayers[acc.Name]) then
            table.insert(filteredList, acc)
        end
    end

    table.sort(filteredList, function(a, b) return a.LastTime < b.LastTime end)

    local finalOutput = {}
    for index, acc in ipairs(filteredList) do
        finalOutput["acc " .. tostring(index)] = {
            Name = acc.Name,
            LastTime = acc.LastTime,
            IDK = acc.IDK
        }
    end
    WriteJSONFile(FILE_NAME, finalOutput)
end

task.spawn(function()
    ManagePartyDatabase()
    while task.wait(10) do
        pcall(ManagePartyDatabase)
    end
end)

local function getFrozenWatcherPosition()
    local mapFolder = workspace:FindFirstChild("Map")
    
    if mapFolder then
        local frozenWatcher = mapFolder:FindFirstChild("FrozenWatcherPart", true)
        
        if frozenWatcher then
            local position = frozenWatcher.Position
            local waterPlane = mapFolder:FindFirstChild("WaterBase-Plane")
            local waterBaseY = waterPlane and waterPlane.Position.Y or 20
            
            if position.Y > waterBaseY then
                return true, position
            end
        end
    end
    
    return false, nil
end

---------
local MoveConnection = nil
local targetCFrame = nil
local targetAttachment = nil
local rootAttachment = nil
local alignPosition = nil
local isAligningY = false

local function DungDiChuyen()
    if not _G.ChoPhepDiChuyen and not MoveConnection and (not alignPosition or not alignPosition.Enabled) then
        return
    end

    _G.ChoPhepDiChuyen = false
    targetCFrame = nil
    
    if MoveConnection then
        MoveConnection:Disconnect()
        MoveConnection = nil
    end
    
    if alignPosition then
        alignPosition.Enabled = false
    end
    
    local character = LP.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if humanoid then
            local isBoat = humanoid.Sit or (humanoid.SeatPart ~= nil)
            if not isBoat then
                humanoid.PlatformStand = false
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
        
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

local function DiChuyenDen(mucTieuCFrame)
    if not mucTieuCFrame then DungDiChuyen() return end
    _G.ChoPhepDiChuyen = true
    targetCFrame = mucTieuCFrame
    local character = LP.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    
    local isBoat = humanoid.Sit or (humanoid.SeatPart ~= nil)
    local currentSpeed = isBoat and (_G.TocDoTweenBoat or 400) or (_G.TocDoTween or 400)

    if not isBoat then
        humanoid.PlatformStand = true
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    end

    if not alignPosition or alignPosition.Parent ~= hrp then
        if alignPosition then alignPosition:Destroy() end
        if targetAttachment then targetAttachment:Destroy() end
        if rootAttachment and rootAttachment.Name == "MeyyRootAtt" then rootAttachment:Destroy() end
        
        targetAttachment = Instance.new("Attachment")
        targetAttachment.Name = "MeyyTargetAtt"
        targetAttachment.Parent = workspace.Terrain
        
        rootAttachment = Instance.new("Attachment")
        rootAttachment.Name = "MeyyRootAtt"
        rootAttachment.Parent = hrp
        
        alignPosition = Instance.new("AlignPosition")
        alignPosition.Name = "MeyyAlign"
        alignPosition.Mode = Enum.PositionAlignmentMode.TwoAttachment
        alignPosition.Attachment0 = rootAttachment
        alignPosition.Attachment1 = targetAttachment
        alignPosition.MaxForce = 9e99
        alignPosition.MaxVelocity = currentSpeed 
        alignPosition.Responsiveness = 200
        alignPosition.ApplyAtCenterOfMass = true
        alignPosition.Parent = hrp
    end

    local mapFolder = workspace:FindFirstChild("Map")
    local waterPlane = mapFolder and mapFolder:FindFirstChild("WaterBase-Plane")
    local waterLevel = waterPlane and (waterPlane.Position.Y + (waterPlane.Size.Y / 2)) or 20

    local initialTargetPos = mucTieuCFrame.Position
    if initialTargetPos.Y < waterLevel then
        initialTargetPos = Vector3.new(initialTargetPos.X, hrp.Position.Y, initialTargetPos.Z)
    end

    local diffY = math.abs(initialTargetPos.Y - hrp.Position.Y)
    if diffY > 25 then
        isAligningY = true
        targetAttachment.WorldPosition = Vector3.new(hrp.Position.X, initialTargetPos.Y, hrp.Position.Z)
        alignPosition.MaxVelocity = currentSpeed
    else
        isAligningY = false
        targetAttachment.WorldPosition = initialTargetPos
        alignPosition.MaxVelocity = currentSpeed
    end

    alignPosition.Enabled = true
    
    if not MoveConnection then
        MoveConnection = RunService.PostSimulation:Connect(function(dt)
            if not _G.ChoPhepDiChuyen or not targetCFrame then 
                DungDiChuyen()
                return 
            end
            
            local cChar = LP.Character
            if not cChar then return end
            local cHrp = cChar:FindFirstChild("HumanoidRootPart")
            local cHum = cChar:FindFirstChild("Humanoid")
            if not cHrp or not cHum then return end
            
            local loopIsBoat = cHum.Sit or (cHum.SeatPart ~= nil)
            local loopSpeed = (loopIsBoat and not _G.DangKeoTim) and (_G.TocDoTweenBoat or 400) or (_G.TocDoTween or 400)
            cHrp.AssemblyAngularVelocity = Vector3.zero
            
            local currentPos = cHrp.Position
            local rawFinalPos = targetCFrame.Position
            
            local currentWaterPlane = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WaterBase-Plane")
            local currentWaterLevel = currentWaterPlane and (currentWaterPlane.Position.Y + (currentWaterPlane.Size.Y / 2)) or 20
            
            local finalPos = rawFinalPos
            if rawFinalPos.Y < currentWaterLevel then
                finalPos = Vector3.new(rawFinalPos.X, currentPos.Y, rawFinalPos.Z)
            end
            
            if isAligningY then
                local currentDiffY = math.abs(finalPos.Y - currentPos.Y)
                if currentDiffY <= 3 then
                    isAligningY = false
                    targetAttachment.WorldPosition = finalPos
                    alignPosition.MaxVelocity = loopSpeed
                else
                    targetAttachment.WorldPosition = Vector3.new(targetAttachment.WorldPosition.X, finalPos.Y, targetAttachment.WorldPosition.Z)
                    alignPosition.MaxVelocity = loopSpeed
                end
            else
                targetAttachment.WorldPosition = finalPos
                alignPosition.MaxVelocity = loopSpeed
            end
            local distance = (finalPos - currentPos).Magnitude
            if distance < 3 then
                DungDiChuyen()
            end
        end)
    end
end

RunService.Stepped:Connect(function()
    if _G.BatNoclip and LP.Character then
        for _, part in ipairs(LP.Character:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    
    if _G.XoaSuongMu then
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
    end
end)

task.spawn(function()
    while task.wait(2) do
        if _G.XoaSuongMu then
            local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmos then atmos:Destroy() end
        end
    end
end)

local function KiemTraThuyen()
    local thuyenMoi = workspace:FindFirstChild("Boats")
    if not thuyenMoi then return nil end
    
    for _, v in ipairs(thuyenMoi:GetChildren()) do
        if v:FindFirstChild("Owner") and tostring(v.Owner.Value) == _G.NguoiMuaThuyen then
            return v
        end
    end
    return nil
end
local function checkBoatJitter(boatModel, duration, threshold)
    duration = duration or 0.5
    threshold = threshold or 0.8

    local character = LP.Character
    if not character then
        return false
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp or not boatModel then
        return false
    end

    local boatPart = boatModel.PrimaryPart or boatModel:FindFirstChildWhichIsA("BasePart")
    if not boatPart then
        return false
    end

    local lastRelPos = boatPart.Position - hrp.Position
    local lastDir = 0
    local reversals = 0
    local samples = 0
    local startTime = tick()

    while tick() - startTime < duration do
        RunService.Heartbeat:Wait()
        
        if not hrp.Parent or not boatPart.Parent then
            break
        end

        local currentRelPos = boatPart.Position - hrp.Position
        local delta = currentRelPos - lastRelPos
        local mag = delta.Magnitude

        if mag > 0.05 and mag < 5 then
            local currentDir = math.sign(delta.Y ~= 0 and delta.Y or delta.Z)
            if lastDir ~= 0 and currentDir ~= 0 and currentDir ~= lastDir then
                reversals = reversals + 1
            end
            if currentDir ~= 0 then
                lastDir = currentDir
            end
        end

        lastRelPos = currentRelPos
        samples = samples + 1
    end

    local isJittering = (reversals >= 3)
    if isJittering then
        return true
    else
        return false
    end
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.NguoiMuaThuyen == LP.Name then
                local isFoundHeart, _ = GetFrozenHeartData()
                if _G.ShootHeart and isFoundHeart then
                    return
                end
                local thuyen = KiemTraThuyen()
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if thuyen and hum and hum.Sit then
                    local isJittering = checkBoatJitter(thuyen, 0.5, 0.8)
                    if isJittering then
                        hum.Sit = false
                        task.wait(0.1)
                        hum.Jump = true
                    end
                end
            end
        end)
    end
end)
local function DemNguoiTrenThuyen(thuyen)
    if not thuyen then return 0 end
    local dem = 0
    for _, part in ipairs(thuyen:GetDescendants()) do
        if (part:IsA("Seat") or part:IsA("VehicleSeat")) and part.Occupant then
            dem = dem + 1
        end
    end
    return dem
end

local RS = game:GetService("ReplicatedStorage")
local MaterialsList = {
    "Fool's Gold",       
    "Shark Tooth",      
    "Electric Wing",    
    "Mutant Tooth",     
    "Terror Eyes",    
    "Leviathan Scale",  
    "Leviathan Heart"    
}

local ScrollReqs = {
    CommonScroll    = {3, 2, 0, 0, 0, 0, 0},
    RareScroll      = {5, 4, 2, 0, 0, 0, 0},
    LegendaryScroll = {7, 0, 3, 1, 0, 5, 0},
    MythicalScroll  = {20, 0, 0, 0, 1, 15, 1}
}


local ScrollCaps = {
    CommonScroll    = Cfg.Scrolls.Caps.Common,
    RareScroll      = Cfg.Scrolls.Caps.Rare,
    LegendaryScroll = Cfg.Scrolls.Caps.Legendary,
    MythicalScroll  = Cfg.Scrolls.Caps.Mythical
}


local function AutoCraftScroll(scrollName)
    local rawName = tostring(scrollName):gsub("%s+", "")
    if not ScrollReqs[rawName] then 
        print(string.format("[Craft Debug] '%s' No ScrollReqs!", tostring(rawName)))
        return 0, {} 
    end
    
    local reqs = ScrollReqs[rawName]
    local currentScrolls = CountItem(rawName)
    local sliderCap = ScrollCaps[rawName]
    local capLimit = (sliderCap and sliderCap > 0) and sliderCap or 50
    local maxAllowed = capLimit - currentScrolls
    

    if maxAllowed <= 0 then
        print(string.format("[Craft Debug] STOP!! [%s] Max Cap!", rawName))
        return 0, {}
    end

    local maxCraft = math.huge
    local missingMaterials = {}

    for i = 1, #MaterialsList do
        local needAmount = reqs[i]
        if needAmount and needAmount > 0 then
            local matName = MaterialsList[i]
            local currentAmount = CountItem(matName)
            local canCraft = math.floor(currentAmount / needAmount)
            
            if canCraft < maxCraft then
                maxCraft = canCraft
            end
            if currentAmount < needAmount then
                missingMaterials[matName] = needAmount - currentAmount
            end
        end
    end
    
    if maxCraft == math.huge then
        maxCraft = 0
    end
    

    if maxCraft <= 0 then
        for mName, mDiff in pairs(missingMaterials) do
        end
        return 0, missingMaterials
    end

    if maxCraft > maxAllowed then
        maxCraft = maxAllowed
    end

    local args = {
        "Craft",
        rawName,
        maxCraft,
        {}
    }

    local ok, res = pcall(function()
        return RS:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/Craft"):InvokeServer(unpack(args))
    end)


    return maxCraft, {}
end
---------

local function KiemTraDieuKienSan()
    local thuyen = KiemTraThuyen()
    if thuyen then
        local soNguoi = DemNguoiTrenThuyen(thuyen)
        if soNguoi >= _G.SoNguoiCanThiet then
            return true
        end
    end
    return false
end

local function IsFrozenHeartHarpooned()
    local mapFolder = game:GetService("Workspace"):FindFirstChild("Map")
    if mapFolder then
        local frozenHeart = mapFolder:FindFirstChild("FrozenHeart")
        if frozenHeart then
            local inside = frozenHeart:FindFirstChild("Inside")
            if inside then
                return inside:GetAttribute("Harpooned") or false
            end
        end
    end
    return false
end


local function bypassSit(seat, humanoid)
    if not seat or not humanoid then return end
    
    local rootPart = humanoid.Parent:FindFirstChild("HumanoidRootPart")
    local touchPart = humanoid.Parent:FindFirstChild("LeftFoot") or humanoid.Parent:FindFirstChild("Torso") or rootPart
    
    if rootPart and touchPart then
        seat.CanTouch = true
        
        task.spawn(function()
            if firetouchtransmitter then
                firetouchtransmitter(seat, touchPart, 0)
                task.wait()
                firetouchtransmitter(seat, touchPart, 1)
            end
        end)
        
        local oldCFrame = rootPart.CFrame
        local tempTime = tick()
        
        repeat
            rootPart.CFrame = seat.CFrame * CFrame.new(0, 1, 0)
            seat:Sit(humanoid)
            task.wait()
        until humanoid.Sit or (tick() - tempTime > 1.5)
        
        if not humanoid.Sit then
            seat:Sit(humanoid)
        end
    end
end

local function GetFrozenHeartData()
    local mapFolder = game:GetService("Workspace"):FindFirstChild("Map")
    
    if mapFolder then
        local frozenHeart = mapFolder:FindFirstChild("FrozenHeart")
        
        if frozenHeart then
            return true, frozenHeart:GetPivot().Position, frozenHeart
        end
    end
    
    return false, nil, nil
end

local function IsFrozenHeartHarpooned()
    local mapFolder = game:GetService("Workspace"):FindFirstChild("Map")
    if mapFolder then
        local frozenHeart = mapFolder:FindFirstChild("FrozenHeart")
        if frozenHeart then
            local inside = frozenHeart:FindFirstChild("Inside")
            if inside then
                return inside:GetAttribute("Harpooned") or false
            end
        end
    end
    return false
end

local function GetWaterLevel()
    local waterPlane = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("WaterBase-Plane")
    if waterPlane then
        return waterPlane.Position.Y + (waterPlane.Size.Y / 2)
    end
    return 20 
end

local function KiemTraDaoIgnore()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return false end

    local prehistoric = mapFolder:FindFirstChild("PrehistoricIsland")
    if prehistoric then
        local p = prehistoric:GetPivot()
        if (Vector3.new(p.Position.X, 0, p.Position.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude <= 4500 then
            return true
        end
    end

    local mystic = mapFolder:FindFirstChild("MysticIsland")
    if mystic then
        local p = mystic:GetPivot()
        if (Vector3.new(p.Position.X, 0, p.Position.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude <= 4500 then
            return true
        end
    end

    return false
end

local function KiemTraQuaiKhongChon()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local minDist = 3500

    local enemies = Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in ipairs(enemies:GetChildren()) do
            local n = mob.Name
            local isUnselected = false
            if n:find("Piranha") and not table.find(_G.SelectedEvents, "Piranha") then isUnselected = true
            elseif n:find("Terrorshark") and not table.find(_G.SelectedEvents, "Terrorshark") then isUnselected = true
            elseif n:find("Shark") and not table.find(_G.SelectedEvents, "Shark") then isUnselected = true
            elseif n:find("Fish Crew Member") and not table.find(_G.SelectedEvents, "FishBoat") then isUnselected = true
            elseif n:find("PirateGrandBrigade") and not table.find(_G.SelectedEvents, "PirateGrandBrigade") then isUnselected = true
            elseif n:find("PirateBrigade") and not table.find(_G.SelectedEvents, "PirateBrigade") then isUnselected = true
            elseif n:find("FishBoat") and not table.find(_G.SelectedEvents, "FishBoat") then isUnselected = true
            end

            if isUnselected then
                local isAlive = false
                local hum = mob:FindFirstChild("Humanoid")
                local hpVal = mob:FindFirstChild("Health")
                
                if hum then
                    if hum:IsA("Humanoid") then
                        if hum.Health > 0 then isAlive = true end
                    elseif hum:IsA("NumberValue") or hum:IsA("IntValue") then
                        if hum.Value > 0 then isAlive = true end
                    end
                elseif hpVal and (hpVal:IsA("NumberValue") or hpVal:IsA("IntValue")) then
                    if hpVal.Value > 0 then isAlive = true end
                end

                local root = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("VehicleSeat") or mob.PrimaryPart
                if not root then
                    local ok, p = pcall(function() return mob:GetPivot() end)
                    if ok and p then
                        if isAlive and (p.Position - hrp.Position).Magnitude <= minDist then
                            return true
                        end
                    end
                elseif isAlive and root then
                    if (root.Position - hrp.Position).Magnitude <= minDist then
                        return true
                    end
                end
            end
        end
    end

    local sbFolder = workspace:FindFirstChild("SeaBeasts")
    if sbFolder then
        for _, mob in ipairs(sbFolder:GetChildren()) do
            local n = mob.Name
            local isUnselected = false
            if n:find("SeaBeast") and not table.find(_G.SelectedEvents, "Sea Beast") then isUnselected = true
            elseif (n == "Leviathan" or n == "Leviathan Segment") and not table.find(_G.SelectedEvents, "Leviathan") then isUnselected = true
            end
            
            if isUnselected then
                local isAlive = false
                local success, health = pcall(function()
                    local healthObj = mob:FindFirstChild("Health")
                    if healthObj and (healthObj.ClassName == "IntValue" or healthObj.ClassName == "NumberValue" or healthObj.ClassName == "IntConstrainedValue") then
                        return healthObj.Value
                    end
                    return mob:FindFirstChild("Humanoid").Health
                end)

                if success and health > 0 then
                    isAlive = true
                elseif not success then
                    local pivotSuccess = pcall(function() return mob:GetPivot() end)
                    if pivotSuccess then
                        isAlive = true
                    end
                end

                if isAlive then
                    local root = mob.PrimaryPart or mob:FindFirstChild("HumanoidRootPart")
                    local mobPos = nil
                    if root then
                        mobPos = root.Position
                    else
                        local ok, p = pcall(function() return mob:GetPivot() end)
                        if ok and p then mobPos = p.Position end
                    end

                    if mobPos and (mobPos - hrp.Position).Magnitude <= minDist then
                        return true
                    end
                end
            end
        end
    end
    return false
end

getgenv().LastTerrorY = nil
getgenv().LastTerrorMob = nil
getgenv().IsTerrorDodging = false

local function HandleTargetPositioning(seaEventTarget, eType, wName, targetPos)
    if not targetPos then return nil end

    local flyCFrame
    local yDist = 40
    local isM1 = getgenv().IsPureM1

    if wName == "Fruit" or wName == "Blox Fruit" then 
        yDist = 5
    elseif wName == "Gun" then 
        yDist = 100
    else 
        if seaEventTarget and seaEventTarget.Name:find("Terrorshark") and isM1 then
            yDist = 57
        else
            yDist = 40
        end
    end
    local waterTopY = GetWaterLevel()


    if eType == "SeaBeast" then
        local isLevi = seaEventTarget and (seaEventTarget.Name == "Leviathan Segment" or seaEventTarget.Name == "Leviathan")

        if isLevi then
            getgenv().MacroAimPos = CFrame.new(targetPos)

            if _G.SpinPosition then
                local radius = isM1 and 23 or 67
                flyCFrame = CaculateCircreDirection(CFrame.new(targetPos), 30, radius)
            else
                flyCFrame = CFrame.new(targetPos.X, targetPos.Y + 30, targetPos.Z)
            end
        else
            local waterBaseY = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("WaterBase-Plane") and Workspace.Map["WaterBase-Plane"].Position.Y or 20

            local aimPos = Vector3.new(targetPos.X, waterBaseY, targetPos.Z)
            getgenv().MacroAimPos = CFrame.new(aimPos)

            local yOffset = 150

            local standPos = Vector3.new(aimPos.X, waterTopY + yOffset, aimPos.Z)
            
            if _G.SpinPosition then
                local radius = isM1 and 23 or 67
                if seaEventTarget and seaEventTarget.Name:find("Terrorshark") then
                    radius = 0
                end
                flyCFrame = CaculateCircreDirection(CFrame.new(Vector3.new(aimPos.X, waterTopY, aimPos.Z)), yOffset, radius)
            else
                flyCFrame = CFrame.new(standPos)
            end
        end

    else
       local finalTargetPos = targetPos
            if (seaEventTarget.Name:find("Brigade") or seaEventTarget.Name == "FishBoat") and isM1 then
                if wName == "Fruit" or wName == "Blox Fruit" then
                    if seaEventTarget.Name == "PirateGrandBrigade" or seaEventTarget.Name == "FishBoat" then
                        local vehicleSeat = seaEventTarget:FindFirstChild("VehicleSeat")
                        if vehicleSeat then
                            finalTargetPos = vehicleSeat.Position
                        end
                    else
                        local engine = seaEventTarget:FindFirstChild("Engine")
                        if engine and engine:IsA("Part") then
                            finalTargetPos = engine.Position
                        end
                    end
                else
                    local mobCFrame = seaEventTarget:GetPivot()
                    finalTargetPos = finalTargetPos + (mobCFrame.LookVector * 10)
                end
            end

        getgenv().MacroAimPos = CFrame.new(finalTargetPos)
        flyCFrame = CFrame.new(finalTargetPos) * CFrame.new(0, yDist, 0)

        if _G.SpinPosition then
            local radius = isM1 and 23 or 67
            if seaEventTarget and seaEventTarget.Name:find("Terrorshark") then
                radius = 0
            end
            flyCFrame = CaculateCircreDirection(CFrame.new(finalTargetPos), yDist, radius)
        end

        if seaEventTarget.Name:find("Terrorshark") then
            local currentTerrorY = targetPos.Y
            
            if currentTerrorY > (waterTopY + 20) then
                getgenv().IsTerrorDodging = true
            else
                getgenv().IsTerrorDodging = false
            end

            if getgenv().IsTerrorDodging then
                flyCFrame = CFrame.new(flyCFrame.Position.X, flyCFrame.Position.Y + 250, flyCFrame.Position.Z)
                if khoiDiChuyen then
                    khoiDiChuyen.CFrame = CFrame.new(khoiDiChuyen.Position.X, flyCFrame.Position.Y, khoiDiChuyen.Position.Z)
                end
            end
        end
    end

    return flyCFrame
end



task.spawn(function()
    while true do
        local map = workspace:FindFirstChild("Map")
        if map then
            local model = map:FindFirstChild("Model")
            if model then
                model:Destroy()
            end
        end
        task.wait(5)
    end
end)

task.spawn(function()
	while true do
		local rocksFolder = workspace:FindFirstChild("Rocks")
		if rocksFolder then
			rocksFolder:Destroy()
		end
		task.wait(30)
	end
end)

_G.WaitResetBoat = false

task.spawn(function()
    while task.wait() do
        pcall(function()
            if _G.DangSan then
                local thuyen = workspace:FindFirstChild("Boats")
                if thuyen then
                    for _, v in ipairs(thuyen:GetChildren()) do
                        local ownerObj = v:FindFirstChild("Owner")
                        if ownerObj and (tostring(ownerObj.Value) == _G.NguoiMuaThuyen or tostring(ownerObj.Value) == LP.Name) then
                            local boatHp = v:FindFirstChild("Humanoid")
                            if boatHp and (boatHp:IsA("IntValue") or boatHp.ClassName == "IntValue") then
                                if boatHp.Value <= 0 then
                                    _G.WaitResetBoat = true
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)


task.spawn(function()
    local function setupResetLogic(char)
        _G.WaitResetBoat = false
        _G.PatrolState = 1
        local humanoid = char:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.Died:Connect(function()
                _G.WaitResetBoat = false
                _G.PatrolState = 1
            end)
        end
    end

    if LP.Character then
        setupResetLogic(LP.Character)
    end

    LP.CharacterAdded:Connect(function(char)
        setupResetLogic(char)
    end)
end)

local NpcPositions = {
    ["Uzoth"] = Vector3.new(5661.89794921875, 1210.876953125, 863.176025390625),
    ["Dragon Wizard"] = Vector3.new(5771.85302734375, 1208.89697265625, 804.2470092773438),
    ["Martial Arts Master"] = Vector3.new(-5004.72119140625, 370.42333984375, -3198.915283203125),
    ["Phoeyu, the Reformed"] = Vector3.new(-4999.23046875, 314.0144958496094, -3221.572265625),
    ["Sharkman Teacher"] = Vector3.new(-4971.2060546875, 313.8869323730469, -3223.0791015625),
    ["Previous Hero"] = Vector3.new(-10371.4716796875, 330.7640075683594, -10131.419921875),
    ["Ancient Monk"] = Vector3.new(-13774.0908203125, 333.7330017089844, -9879.9072265625),
    ["Shafi"] = Vector3.new(-16515.06640625, 22.811996459960938, -188.572998046875)
}

local function GetNpcPosition(npcName)
    return NpcPositions[npcName]
end

local function HandleBoatRespawnLogic(thuyen)
    local viTriMuaThuyen = CFrame.new(-16204.9668, 9.2812, 474.9888)
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local isBoatBroken = _G.WaitResetBoat

    if thuyen then
        local ownerObj = thuyen:FindFirstChild("Owner")
        local ownerName = ownerObj and tostring(ownerObj.Value) or ""
        local targetOwner = _G.NguoiMuaThuyen and tostring(_G.NguoiMuaThuyen) or LP.Name

        if ownerName == targetOwner or ownerName == LP.Name then
            local boatHp = thuyen:FindFirstChild("Humanoid")
            if boatHp and (boatHp:IsA("IntValue") or boatHp.ClassName == "IntValue") then
                if boatHp.Value <= 0 then
                    isBoatBroken = true
                    _G.WaitResetBoat = true
                    thuyen = nil
                end
            end
        end
    end

    if thuyen and thuyen.PrimaryPart then
        local dist = (thuyen.PrimaryPart.Position - hrp.Position).Magnitude
        if dist > 5000 then
            thuyen = nil 
        end
    end

    if not thuyen then
        local distToSpawn = (hrp.Position - viTriMuaThuyen.Position).Magnitude
        if isBoatBroken and distToSpawn > 1000 then
            local w = game:GetService("Players")
            local S = w.LocalPlayer
            if S.Character and S.Character:FindFirstChild("Humanoid") then
                print("Resetting character due to broken boat...")
                if getgenv().Meyy6Race_API then
                    getgenv().Meyy6Race_API.SetTask("Resetting Character")
                    getgenv().Meyy6Race_API.SetTheme("Sky")
                end
                S.Character.Humanoid.Health = 0
                _G.WaitResetBoat = false
            end
        else
            _G.WaitResetBoat = false
            if getgenv().Meyy6Race_API then
                getgenv().Meyy6Race_API.SetTask("Buying Boat")
                getgenv().Meyy6Race_API.SetTheme("Candy")
            end

            DiChuyenDen(viTriMuaThuyen)
            if distToSpawn < 15 then
                _G.PatrolState = 1
                ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBoat", _G.TenThuyen)
                task.wait(0.5)
            end
        end
        return true
    end

    return false 
end

---------

local NotifiedWatcher = false
local function HandleFrozenWatcherLogic(hrp, humanoid, watcherPos)
    local distToWatcher = (hrp.Position - watcherPos).Magnitude
    if not NotifiedWatcher then
        NotifiedWatcher = true
        task.spawn(function()
            sendLeviWebhook("Found Frozen Dimension", "Discovered Frozen Dimension at: " .. tostring(RoundVector3Down(watcherPos)))
        end)
    end
    
    if distToWatcher > 200 then
        local myBoat = KiemTraThuyen()
        if not myBoat then
            if _G.NguoiMuaThuyen == LP.Name then
                HandleBoatRespawnLogic(nil)
            end
        else
            if _G.NguoiMuaThuyen == LP.Name then
                local gheLai = myBoat:FindFirstChild("VehicleSeat")
                if gheLai then
                    if not humanoid.Sit then
                        DiChuyenDen(gheLai.CFrame * CFrame.new(0, 3, 0))
                        task.wait(0.5)
                        if (gheLai.Position - hrp.Position).Magnitude <= 10 then
                            gheLai:Sit(humanoid)
                        end
                    else
                        DiChuyenDen(CFrame.new(watcherPos) * CFrame.new(0, 10, 0))
                    end
                end
            else
                local gheTrong = nil
                local harpoon = myBoat:FindFirstChild("Harpoon")
                local harpoonSeat = harpoon and harpoon:FindFirstChild("Seat")
                for _, part in ipairs(myBoat:GetDescendants()) do
                    if part:IsA("Seat") and part.Name ~= "VehicleSeat" and part ~= harpoonSeat and not part.Occupant then
                        gheTrong = part
                        break
                    end
                end
                if gheTrong then
                    if not humanoid.Sit then
                        DiChuyenDen(gheTrong.CFrame * CFrame.new(0, 3, 0))
                        task.wait(0.5)
                        if (gheTrong.Position - hrp.Position).Magnitude <= 10 then
                            gheTrong:Sit(humanoid)
                        end
                    else
                        DungDiChuyen()
                    end
                end
            end
        end
    else
        if humanoid.Sit then
            humanoid.Sit = false
            task.wait(0.1)
        end
        
        if distToWatcher <= 100 then
            local tocDoCu = _G.TocDoTween
            _G.TocDoTween = 55
            DiChuyenDen(CFrame.new(watcherPos) * CFrame.new(0, 10, 0))
            _G.TocDoTween = tocDoCu
        else
            if getgenv().Meyy6Race_API then
                getgenv().Meyy6Race_API.SetTask("Moving to NPC")
                getgenv().Meyy6Race_API.SetTheme("Dark")
            end
            if khoiDiChuyen then
                local currentY = khoiDiChuyen.Position.Y
                local targetY = watcherPos.Y + 10
                if math.abs(currentY - targetY) > 5 then
                    khoiDiChuyen.CFrame = CFrame.new(khoiDiChuyen.Position.X, targetY, khoiDiChuyen.Position.Z)
                    task.wait(0.1)
                end
            end
            DiChuyenDen(CFrame.new(watcherPos) * CFrame.new(0, 10, 0))
        end
        
        if distToWatcher < 40 then
            if getgenv().Meyy6Race_API then
                getgenv().Meyy6Race_API.SetTask("Opening Gate")
                getgenv().Meyy6Race_API.SetTheme("Lavender")
            end
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("OpenLeviathanGate")
        end
    end
    return true
end

local function CalculateHarpoonAngles(harpoonFolder, targetPos)
    local seat = harpoonFolder:FindFirstChild("Seat")
    local baseCFrame
    
    if seat and seat:FindFirstChild("BoatWeld") and seat.BoatWeld.Part0 then
        baseCFrame = seat.BoatWeld.Part0.CFrame
    elseif seat and seat:IsA("BasePart") then
        baseCFrame = seat.CFrame
    else
        baseCFrame = harpoonFolder:GetPivot()
    end

    local localDir = baseCFrame:PointToObjectSpace(targetPos)

    local yaw = math.atan2(localDir.X, -localDir.Z)

    local x = math.sqrt(localDir.X^2 + localDir.Z^2)
    local y = localDir.Y

    local v = 400
    local g = workspace.Gravity

    local root = v^4 - g * (g * x^2 + 2 * y * v^2)
    local pitch = 0

    if root >= 0 then
        pitch = math.atan2(v^2 - math.sqrt(root), g * x)
    else
        pitch = math.atan2(y, x)
    end

    local clampedPitch = math.clamp(pitch, -0.17453292519943295, 0.7853981633974483)
    local clampedYaw = math.clamp(yaw, -1.1344640137963142, 1.1344640137963142)

    return clampedPitch, clampedYaw
end



local function FiringHarpoonLogic(harpoonFolder, harpoonSeat, heartPos)
    DungDiChuyen()
    if getgenv().Meyy6Race_API then
        getgenv().Meyy6Race_API.SetTask("Shooting Heart")
        getgenv().Meyy6Race_API.SetTheme("Dream")
    end
    
    local currentTime = tick()
    if not getgenv().LastHarpoonShoot or currentTime - getgenv().LastHarpoonShoot >= 1 then
        getgenv().LastHarpoonShoot = currentTime
        
        local pitch, yaw = CalculateHarpoonAngles(harpoonFolder, heartPos)
        local boatWeld = harpoonSeat:FindFirstChild("BoatWeld")
        local cannonWeld = harpoonSeat:FindFirstChild("CannonWeld")
        
        if boatWeld then
            pcall(function()
                boatWeld.C0 = CFrame.Angles(0, yaw, 0)
                boatWeld.C1 = CFrame.Angles(0, yaw * 2, 0)
            end)
        end
        
        if cannonWeld then
            pcall(function()
                local v21 = math.max(pitch - 0.4363323129985824, 0) / 0.6108652381980153 * 2.5
                cannonWeld.C0 = CFrame.new(0, v21, 0) * CFrame.Angles(pitch, 0, 0) * CFrame.new(0, 0, -v21 / 1.4142135623730951)
            end)
        end
        
        pcall(function()
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("FireHarpoon", pitch, yaw, harpoonFolder, workspace:GetServerTimeNow())
        end)
    end
end

---------
local function GetHeartData()
    local mapFolder = Workspace:FindFirstChild("Map")
    if mapFolder then
        local frozenHeart = mapFolder:FindFirstChild("FrozenHeart")
        if frozenHeart then
            local core = frozenHeart:FindFirstChild("Inside") 
                or frozenHeart:FindFirstChild("Cube") 
                or frozenHeart:FindFirstChild("Hitbox")
                or frozenHeart.PrimaryPart
                or frozenHeart:FindFirstChildWhichIsA("BasePart", true)
            if core then
                return core.CFrame, frozenHeart
            end
            return frozenHeart:GetPivot(), frozenHeart
        end
    end
    return nil, nil
end



---------
local function bypassSit(seat, humanoid)
    if not seat or not humanoid then return end
    
    local rootPart = humanoid.Parent:FindFirstChild("HumanoidRootPart")
    local touchPart = humanoid.Parent:FindFirstChild("LeftFoot") or humanoid.Parent:FindFirstChild("Torso") or rootPart
    
    if rootPart and touchPart then
        seat.CanTouch = true
        
        task.spawn(function()
            if firetouchtransmitter then
                firetouchtransmitter(seat, touchPart, 0)
                task.wait()
                firetouchtransmitter(seat, touchPart, 1)
            end
        end)
        
        local oldCFrame = rootPart.CFrame
        local tempTime = tick()
        
        repeat
            rootPart.CFrame = seat.CFrame * CFrame.new(0, 1, 0)
            seat:Sit(humanoid)
            task.wait()
        until humanoid.Sit or (tick() - tempTime > 1.5)
        
        if not humanoid.Sit then
            seat:Sit(humanoid)
        end
    end
end

local function HandleFrozenHeartLogic(hrp, humanoid, heartPosFallback)
    if not _G.ShootHeart then 
        return false 
    end
    
    local myBoat = KiemTraThuyen()
    if not myBoat or not hrp or not humanoid then 
        return false 
    end

    local heartCFrame, frozenHeart = GetHeartData()
    if not heartCFrame and heartPosFallback then
        if typeof(heartPosFallback) == "CFrame" then
            heartCFrame = heartPosFallback
        elseif typeof(heartPosFallback) == "Vector3" then
            heartCFrame = CFrame.new(heartPosFallback)
        end
    end

    local isHarpooned = IsFrozenHeartHarpooned()

    if _G.NguoiMuaThuyen == LP.Name then
        if not heartCFrame or isHarpooned then
            if isHarpooned then
                local vehicleSeat = myBoat:FindFirstChild("VehicleSeat")
                if vehicleSeat then
                    if humanoid.Sit and humanoid.SeatPart ~= vehicleSeat then
                        humanoid.Sit = false
                        task.wait(0.2)
                    end
                    if not humanoid.Sit then
                        bypassSit(vehicleSeat, humanoid)
                    end
                end
                DungDiChuyen()
                return true
            end
            return false
        end

        local heartPos = heartCFrame.Position
        local vehicleSeat = myBoat:FindFirstChild("VehicleSeat")
        local harpoonFolder = myBoat:FindFirstChild("Harpoon")
        local harpoonSeat = harpoonFolder and harpoonFolder:FindFirstChild("Seat")
        
        if not vehicleSeat or not harpoonSeat then return false end

        local targetPos = Vector3.new(heartPos.X, GetWaterLevel() + 27.5, heartPos.Z + 290)
        local aimCFrame = CFrame.new(targetPos, Vector3.new(heartPos.X, targetPos.Y, heartPos.Z))
        
        if not humanoid.Sit then
            if myBoat.PrimaryPart then
                myBoat:PivotTo(hrp.CFrame)
                task.wait(0.05)
            end
            bypassSit(vehicleSeat, humanoid)
        elseif humanoid.Sit and humanoid.SeatPart == vehicleSeat then
            local dist = (Vector3.new(vehicleSeat.Position.X, 0, vehicleSeat.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude
            if dist > 50 then
                DiChuyenDen(aimCFrame)
            else
                DungDiChuyen()
                if myBoat.PrimaryPart then
                    myBoat:PivotTo(aimCFrame)
                end
                humanoid.Sit = false
                task.wait(0.2)
                bypassSit(harpoonSeat, humanoid)
            end
        elseif humanoid.Sit and humanoid.SeatPart == harpoonSeat then
            FiringHarpoonLogic(harpoonFolder, harpoonSeat, heartPos)
            task.delay(1, function()
                if IsFrozenHeartHarpooned() and not getgenv().NotifiedHeartHarpooned then
                    getgenv().NotifiedHeartHarpooned = true
                    sendLeviWebhook("Heart Shooted", "Shoot Frozen Heart successfully! Preparing Drive.")
                end
            end)
        end
        
        return true
    else
        if isHarpooned then
            if getgenv().Meyy6Race_API then getgenv().Meyy6Race_API.SetTask("Boarding & Waiting") end
        end

        if not humanoid.Sit then
            local gheTrong = nil
            local harpoonSeat = myBoat:FindFirstChild("Harpoon") and myBoat.Harpoon:FindFirstChild("Seat")
            for _, part in ipairs(myBoat:GetDescendants()) do
                if part:IsA("Seat") and part.Name ~= "VehicleSeat" and part ~= harpoonSeat and not part.Occupant then
                    gheTrong = part
                    break
                end
            end
            if gheTrong then
                DiChuyenDen(gheTrong.CFrame * CFrame.new(0, 3, 0))
                if (gheTrong.Position - hrp.Position).Magnitude <= 5 then
                    gheTrong:Sit(humanoid)
                end
            elseif isHarpooned and myBoat.PrimaryPart then
                DiChuyenDen(myBoat.PrimaryPart.CFrame * CFrame.new(0, 15, 0))
            end
        else
            if humanoid.SeatPart and (hrp.Position - humanoid.SeatPart.Position).Magnitude > 10 then
                humanoid.Sit = false
            else
                DungDiChuyen()
            end
        end
        
        if isHarpooned then return true end
        return false
    end
end



---------
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()

            if IsFrozenHeartHarpooned() then
                return
            end

            local isFoundHeart, heartPos = GetFrozenHeartData()
            if not isFoundHeart or not heartPos then
                return
            end

            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not char or not hum or not hrp or not hum.Sit then
                return
            end

            local thuyen = KiemTraThuyen()
            if not thuyen then
                return
            end

            local gheLai = thuyen:FindFirstChild("VehicleSeat") or thuyen:FindFirstChildWhichIsA("VehicleSeat", true)
            if not gheLai then
                return
            end

            if hum.SeatPart ~= gheLai and (hrp.Position - gheLai.Position).Magnitude > 8 then
                return
            end

            local boatPivot = thuyen:GetPivot()
            local boatPos = boatPivot.Position
            local boatTarget = Vector3.new(heartPos.X, boatPos.Y, heartPos.Z)

            local lookVec = (boatPivot.LookVector * Vector3.new(1, 0, 1)).Unit
            local dirVec = ((boatTarget - boatPos) * Vector3.new(1, 0, 1)).Unit
            local dotP = math.clamp(lookVec:Dot(dirVec), -1, 1)
            local gocLech = math.deg(math.acos(dotP))

            if gocLech > 5 then
                thuyen:PivotTo(CFrame.lookAt(boatPos, boatTarget))
            end
        end)
    end
end)
---------



getgenv().DangSafeMode = false
getgenv().ViTriSafe = nil

task.spawn(function()
    while task.wait() do
        pcall(function()
            if _G.DangSan and getgenv().CurrentTarget then
                local char = LP.Character
                local hum = char and char:FindFirstChild("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if hum and hrp and hum.Health > 0 then
                    local hpPercent = hum.Health / hum.MaxHealth

                    if hpPercent < 0.30 and not getgenv().DangSafeMode then
                        getgenv().DangSafeMode = true
                        
                        local toaDoHienTai = hrp.CFrame
                        hrp.CFrame = toaDoHienTai * CFrame.new(0, 2000, 0)
                        
                        getgenv().ViTriSafe = toaDoHienTai * CFrame.new(0, 2500, 0)
                        
                    elseif hpPercent > 0.65 and getgenv().DangSafeMode then
                        getgenv().DangSafeMode = false
                        getgenv().ViTriSafe = nil
                    end
                end
            else
                getgenv().DangSafeMode = false
                getgenv().ViTriSafe = nil
            end
        end)
    end
end)

local function HandleSeaEventCombat(hrp, seaEventTarget, eType, targetPos, isLeviathan)
    if getgenv().Meyy6Race_API then
        if isLeviathan then
            getgenv().Meyy6Race_API.SetTask("Killing Leviathan")
            getgenv().Meyy6Race_API.SetTheme("Sky")
        else
            local mobName = seaEventTarget.Name
            mobName = string.gsub(mobName, "%d+", "")
            getgenv().Meyy6Race_API.SetTask("Killing " .. mobName)
            getgenv().Meyy6Race_API.SetTheme("Lavender")
        end
    end

    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        if LP.Character.Humanoid.Sit then
            LP.Character.Humanoid.Sit = false
            task.wait(0.1)
        end
    end

    getgenv().CurrentTarget = seaEventTarget
    getgenv().CurrentTargetPart = seaEventTarget:FindFirstChild("HumanoidRootPart", true)
        or seaEventTarget:FindFirstChild("VehicleSeat", true)
        or seaEventTarget.PrimaryPart
        or seaEventTarget:FindFirstChildWhichIsA("BasePart", true)

    local wName = _G.SelectedWeapon
    getgenv().IsPureM1 = false
    getgenv().UseOnlyGunSkill = false

    if _G.UseGunEvent and _G.UseM1FruitEvent then
        if seaEventTarget.Name:find("Sea Beast") or seaEventTarget.Name:find("Rumbling") or seaEventTarget.Name:find("Brigade") then
            wName = "Fruit"
            getgenv().IsPureM1 = true
        else
            wName = "Gun"
            getgenv().UseOnlyGunSkill = true
        end
    elseif _G.UseGunEvent then
        wName = "Gun"
        getgenv().UseOnlyGunSkill = true
    elseif _G.UseM1FruitEvent then
        wName = "Fruit"
        getgenv().IsPureM1 = true
    else
        if seaEventTarget.Name:find("Terrorshark") then
            wName = _G.SelectedWeapon
            getgenv().IsPureM1 = true
            getgenv().UseOnlyGunSkill = false
        else
            if eType == "M1" then getgenv().IsPureM1 = true end
            if wName == "Gun" then getgenv().UseOnlyGunSkill = true end
        end
    end


    local flyCFrame = HandleTargetPositioning(seaEventTarget, eType, wName, targetPos)

    if getgenv().DangSafeMode and getgenv().ViTriSafe then
        flyCFrame = getgenv().ViTriSafe
    end

    if flyCFrame then
        if khoiDiChuyen then
            local currentY = khoiDiChuyen.Position.Y
            local targetY = flyCFrame.Position.Y
            if math.abs(currentY - targetY) > 5 then
                khoiDiChuyen.CFrame = CFrame.new(khoiDiChuyen.Position.X, targetY, khoiDiChuyen.Position.Z)
                task.wait(0.1)
            end
        end
        DiChuyenDen(flyCFrame)
    end


    if wName == "Gun" and _G.UseGunEvent then
        local gunEquipName = (seaEventTarget.Name:find("Sea Beast") or seaEventTarget.Name:find("Rumbling")) and "Skull Guitar" or "Dragonstorm"
        EquipGun(gunEquipName)
    else
        if getgenv().IsPureM1 then
            equip(wName)
        end
    end
end
local Tiki_Points = {
    Vector3.new(4574.8701, 22.5545, -4429.2261),
    Vector3.new(-3904.3430, 22.5565, -287.6272),
    Vector3.new(-10974.2920, 22.5565, 245.2649),
    Vector3.new(-15071.9961, 22.5554, 373.7648),
    Vector3.new(-16204.4648, 22.5554, 438.3202)
}

local Hydra_Points = {
    Vector3.new(13560.2676, 27.5490, -5763.9375),
    Vector3.new(12969.5615, 27.5565, -2921.5220),
    Vector3.new(12027.5146, 27.5565, 412.7256),
    Vector3.new(8967.5996, 27.5565, 3901.3904),
    Vector3.new(6061.9238, 27.5565, 5328.6504),
    Vector3.new(4839.1465, 27.5561, 5212.8022),
    Vector3.new(4698.8105, 27.5565, 4252.9385),
    Vector3.new(5005.5952, 27.5557, 3725.4436),
    Vector3.new(5176.7275, 27.5540, 3269.4182),
    Vector3.new(5141.3120, 27.5525, 2943.8655),
    Vector3.new(5190.1035, 27.5564, 2052.7825),
    Vector3.new(5201.9844, 27.7811, 1589.3344)
}

local currentPathIndex = 0
local lastDest = nil
local daBatDauKeoTim = false
local doiTimBayGan = false

local function TinhGocLech(thuyen, mucTieu)
    local cframeThuyen = thuyen.PrimaryPart.CFrame
    local posThuyen = cframeThuyen.Position
    local lookVec = (cframeThuyen.LookVector * Vector3.new(1, 0, 1)).Unit
    local dirVec = ((mucTieu - posThuyen) * Vector3.new(1, 0, 1)).Unit
    local dotP = lookVec:Dot(dirVec)
    local goc = math.deg(math.acos(math.clamp(dotP, -1, 1)))
    local crossP = lookVec:Cross(dirVec)
    return crossP.Y < 0 and -goc or goc
end

local function XoayThuyen(thuyen, mucTieu)
    local pos = thuyen.PrimaryPart.Position
    local targetFlat = Vector3.new(mucTieu.X, pos.Y, mucTieu.Z)
    thuyen:SetPrimaryPartCFrame(CFrame.lookAt(pos, targetFlat))
end

local function NoclipThuyenKeoTim(thuyen)
    for _, v in ipairs(thuyen:GetDescendants()) do
        if (v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part")) and v.CanCollide then
            v.CanCollide = false
        end
    end
end

local function KeoTimVeDao()
    if not _G.DangSan or not _G.ShootHeart then 
        daBatDauKeoTim = false
        doiTimBayGan = false
        currentPathIndex = 0
        lastDest = nil
        return false 
    end
    if not _G.DriveToTiki and not _G.DriveToHydra then 
        daBatDauKeoTim = false
        doiTimBayGan = false
        currentPathIndex = 0
        lastDest = nil
        return false 
    end
    
    local isFoundHeart, heartPos = GetFrozenHeartData()
    if not isFoundHeart then
        if daBatDauKeoTim then
            DungDiChuyen()
            daBatDauKeoTim = false
            doiTimBayGan = false
            currentPathIndex = 0
            lastDest = nil

            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Sit then
                repeat
                    hum.Sit = false
                    task.wait(0.1)
                until not hum.Sit or not hum.Parent
            end
            task.wait(1)
            pcall(function()
                local thuyenCu = KiemTraThuyen()
                if thuyenCu then
                    thuyenCu:Destroy()
                end
            end)
            local destClaimed = _G.DriveToTiki and "Tiki Outpost" or "Hydra Island"
            task.spawn(function()
                sendLeviWebhook("Heart Delivered", "Heart dragged successfully to " .. destClaimed .. "!")
                task.wait(2)
                if sendLeviInventoryWebhook then
                    sendLeviInventoryWebhook(destClaimed)
                end
            end)
            getgenv().NotifiedHeartHarpooned = false
            if hum and hum.Parent then
                hum.Health = 0
            end
            if getgenv().Meyy6Race_API then
                getgenv().Meyy6Race_API.SetTask("Heart Claimed - Resetting")
                getgenv().Meyy6Race_API.SetTheme("Dark")
            end
        else
            currentPathIndex = 0
        end
        return false
    end
    
    local isHarpooned = IsFrozenHeartHarpooned()
    if not isHarpooned then
        currentPathIndex = 0
        return false
    end
    
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = LP.Character and LP.Character:FindFirstChild("Humanoid")
    local boat = KiemTraThuyen()
    
    if not boat or not boat.PrimaryPart or not hrp or not humanoid then return false end
    
    local vehicleSeat = boat:FindFirstChild("VehicleSeat")
    if not vehicleSeat then return false end

    if not humanoid.Sit or humanoid.SeatPart ~= vehicleSeat then
        return false
    end
    
    daBatDauKeoTim = true
    _G.DangKeoTim = true
    local currentDest = _G.DriveToTiki and "Tiki" or "Hydra"
    if lastDest ~= currentDest then
        lastDest = currentDest
        currentPathIndex = 0
    end
    
    local targetPath = _G.DriveToTiki and Tiki_Points or Hydra_Points
    local boatPos = boat.PrimaryPart.Position
    
    if currentPathIndex == 0 then
        local minDist = math.huge
        local nearestIdx = 1
        for i, point in ipairs(targetPath) do
            local dist = (Vector3.new(boatPos.X, 0, boatPos.Z) - Vector3.new(point.X, 0, point.Z)).Magnitude
            if dist < minDist then
                minDist = dist
                nearestIdx = i
            end
        end
        currentPathIndex = nearestIdx
    end

    local targetPoint = targetPath[currentPathIndex]
    local flyHeight = _G.PullYHeight or 35
    local distToTarget = (Vector3.new(boatPos.X, 0, boatPos.Z) - Vector3.new(targetPoint.X, 0, targetPoint.Z)).Magnitude
    
    if heartPos then
        local distToHeart = (boatPos - heartPos).Magnitude
        if distToHeart > 550 then
            doiTimBayGan = true
        elseif distToHeart < 225 then
            doiTimBayGan = false
        end
    end

    if doiTimBayGan then
        DungDiChuyen()
        task.spawn(function()
            vehicleSeat.MaxSpeed = 135
            NoclipThuyenKeoTim(boat)
        end)
        
        if boat.PrimaryPart then
            -- Lùi lại gần tim (Reverse)
            boat.PrimaryPart.ThrottleFloat = -1
            boat.PrimaryPart.Throttle = -1
        end
        if getgenv().Meyy6Race_API then
            getgenv().Meyy6Race_API.SetTask("Backing up to Heart")
            getgenv().Meyy6Race_API.SetTheme("Red")
        end
        return true
    end
    
    if getgenv().Meyy6Race_API then
        local destName = currentDest == "Tiki" and "Tiki" or "Hydra"
        local themeName = currentDest == "Tiki" and "Luxury" or "Mint"
        local finalPoint = targetPath[#targetPath]
        local distToFinal = math.floor((Vector3.new(boatPos.X, 0, boatPos.Z) - Vector3.new(finalPoint.X, 0, finalPoint.Z)).Magnitude)
        getgenv().Meyy6Race_API.SetTask("Driving to " .. destName .. " (" .. distToFinal .. "m)")
        getgenv().Meyy6Race_API.SetTheme(themeName)
    end

    if currentPathIndex < #targetPath and distToTarget <= 50 then
        currentPathIndex = currentPathIndex + 1
        targetPoint = targetPath[currentPathIndex]
    end

    local flatTargetPos = Vector3.new(targetPoint.X, flyHeight, targetPoint.Z)
    
    local gocLech = TinhGocLech(boat, flatTargetPos)
    
    task.spawn(function()
        vehicleSeat.MaxSpeed = _G.TocDoTweenBoat or 250
        NoclipThuyenKeoTim(boat)
    end)
    
    if currentPathIndex < #targetPath or distToTarget > 50 then
        DungDiChuyen()
        
        if math.abs(gocLech) > 5 then
            XoayThuyen(boat, flatTargetPos)
            boat.PrimaryPart.ThrottleFloat = 0
            boat.PrimaryPart.Throttle = 0
        else
            boat.PrimaryPart.ThrottleFloat = 1
            boat.PrimaryPart.Throttle = 1
        end
    else
        boat.PrimaryPart.ThrottleFloat = 0
        boat.PrimaryPart.Throttle = 0
        DungDiChuyen()
        if getgenv().Meyy6Race_API then
            getgenv().Meyy6Race_API.SetTask("Arrived at Destination")
            getgenv().Meyy6Race_API.SetTheme("Green")
        end
    end
    
    return true
end
local function HandlePatrolAndIdle(hrp, isLeviathan, isFoundWatcher)
    getgenv().CurrentTarget = nil
    getgenv().CurrentTargetPart = nil
    getgenv().MacroAimPos = nil
    getgenv().IsPureM1 = false
    getgenv().UseOnlyGunSkill = false
    if isFoundWatcher then
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            if LP.Character.Humanoid.Sit then
                LP.Character.Humanoid.Sit = false
            end
        end
        DungDiChuyen()
    else
        local thuyen = KiemTraThuyen()
        
        if _G.NguoiMuaThuyen == LP.Name then
            local dangMuaThuyen = false
            if not isLeviathan then
                dangMuaThuyen = HandleBoatRespawnLogic(thuyen)
            end

            if not dangMuaThuyen and thuyen then
                local gheLai = thuyen:FindFirstChild("VehicleSeat")
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if gheLai and hrp and hum then
                        if not hum.Sit then
                            if getgenv().Meyy6Race_API then
                            getgenv().Meyy6Race_API.SetTask("Boarding Boat")
                            getgenv().Meyy6Race_API.SetTheme("Dream")
                        end
                        DiChuyenDen(gheLai.CFrame * CFrame.new(0, 3, 0))
                        task.wait(0.2)
                        if (gheLai.Position - hrp.Position).Magnitude <= 10 and hum and hum.Parent then
                            gheLai:Sit(hum)
                        end
                    else 
                        if KiemTraDieuKienSan() then
                        local viTriXuatPhat = Vector3.new(-16204.9668, 0, 474.9888)
                        local distToSpawn = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - viTriXuatPhat).Magnitude

                        if not _G.PatrolState or distToSpawn < 500 then
                            _G.PatrolState = 1
                        end
                            local hrpPos = hrp.Position
                            local isIgnoring = _G.EnableIgnoreSeaEvent and KiemTraQuaiKhongChon()
                            local isIgnoringIsland = _G.EnableIgnoreIsland and KiemTraDaoIgnore()
                            local currentBay = isIgnoringIsland and _G.IgnoreIslandHeight or (isIgnoring and _G.IgnoreHeight or _G.ChieuCaoBay)
                            local yHigh = currentBay
                            local yNormal = currentBay
                            
                            local sea1 = Vector3.new(-14202.8643, yHigh, 447.1369)
                            local sea6 = Vector3.new(-16143.5469, yNormal, 37085.2148)
                            local sea9999 = Vector3.new(-16256.7344, yNormal, 106649.3828)
                            if _G.PatrolState == 1 then
                                if getgenv().Meyy6Race_API then
                                    getgenv().Meyy6Race_API.SetTask("Patrolling Sea")
                                    getgenv().Meyy6Race_API.SetTheme("Candy")
                                end
                                if math.abs(hrpPos.Y - yHigh) > 20 and khoiDiChuyen then
                                    khoiDiChuyen.CFrame = CFrame.new(khoiDiChuyen.Position.X, yHigh, khoiDiChuyen.Position.Z)
                                    task.wait(0.1)
                                end
                                DiChuyenDen(CFrame.new(sea1))
                                
                                if (Vector3.new(hrpPos.X, 0, hrpPos.Z) - Vector3.new(sea1.X, 0, sea1.Z)).Magnitude <= 200 then
                                    _G.PatrolState = 2
                                end
                            elseif _G.PatrolState == 2 then
                                if khoiDiChuyen then
                                    khoiDiChuyen.CFrame = CFrame.new(khoiDiChuyen.Position.X, yNormal, khoiDiChuyen.Position.Z)
                                    task.wait(0.1)
                                end
                                _G.PatrolState = 3
                            elseif _G.PatrolState == 3 then
                                if getgenv().Meyy6Race_API then
                                    getgenv().Meyy6Race_API.SetTask("Find Leviathan")
                                    getgenv().Meyy6Race_API.SetTheme("Dark")
                                end
                                DiChuyenDen(CFrame.new(sea6))
                                
                                if hrpPos.Z >= sea6.Z or (Vector3.new(hrpPos.X, 0, hrpPos.Z) - Vector3.new(sea6.X, 0, sea6.Z)).Magnitude <= 200 then
                                    _G.PatrolState = 4
                                end
                            elseif _G.PatrolState == 4 then
                                if getgenv().Meyy6Race_API then
                                    getgenv().Meyy6Race_API.SetTask("Find Leviathan")
                                    getgenv().Meyy6Race_API.SetTheme("Dark")
                                end
                                DiChuyenDen(CFrame.new(sea9999))
                                
                                if hrpPos.Z >= sea9999.Z or (Vector3.new(hrpPos.X, 0, hrpPos.Z) - Vector3.new(sea9999.X, 0, sea9999.Z)).Magnitude <= 200 then
                                    _G.PatrolState = 5
                                end
                            elseif _G.PatrolState == 5 then
                                if getgenv().Meyy6Race_API then
                                    getgenv().Meyy6Race_API.SetTask("Find Leviathan")
                                    getgenv().Meyy6Race_API.SetTheme("Dark")
                                end
                                DiChuyenDen(CFrame.new(sea6))
                                
                                if hrpPos.Z <= sea6.Z or (Vector3.new(hrpPos.X, 0, hrpPos.Z) - Vector3.new(sea6.X, 0, sea6.Z)).Magnitude <= 200 then
                                    _G.PatrolState = 4
                                end
                            end
                        else
                            if getgenv().Meyy6Race_API then
                                getgenv().Meyy6Race_API.SetTask("Waiting for Members")
                                getgenv().Meyy6Race_API.SetTheme("Lavender")
                            end
                            DungDiChuyen()
                        end
                    end
                end
            end
        else
            if thuyen and hrp then
                local dist = thuyen.PrimaryPart and (thuyen.PrimaryPart.Position - hrp.Position).Magnitude or 0
                if dist > 30000000000 then
                    DungDiChuyen()
                else
                    local quaiHienTai = GetNearestSeaEvent()
                    if LP.Character and LP.Character:FindFirstChild("Humanoid") and not LP.Character.Humanoid.Sit and not quaiHienTai then
                        local gheTrong = nil
                        local harpoon = thuyen:FindFirstChild("Harpoon")
                        local harpoonSeat = harpoon and harpoon:FindFirstChild("Seat")
                        for _, part in ipairs(thuyen:GetDescendants()) do
                            if part:IsA("Seat") and part.Name ~= "VehicleSeat" and part ~= harpoonSeat and not part.Occupant then
                                gheTrong = part
                                break
                            end
                        end
                        
                        if gheTrong then
                            if getgenv().Meyy6Race_API then
                                getgenv().Meyy6Race_API.SetTask("Boarding Boat")
                                getgenv().Meyy6Race_API.SetTheme("Dream")
                            end
                            DiChuyenDen(gheTrong.CFrame * CFrame.new(0, 3, 0))
                            task.wait(0.5)
                        local quaiSauKhiCho = GetNearestSeaEvent()
                            if (gheTrong.Position - hrp.Position).Magnitude <= 10 and not quaiSauKhiCho then
                                gheTrong:Sit(LP.Character.Humanoid)
                            end
                        else
                            if thuyen.PrimaryPart then
                                DiChuyenDen(thuyen.PrimaryPart.CFrame * CFrame.new(0, 5, 0))
                            end
                        end
                    elseif quaiHienTai then
                        if LP.Character and LP.Character.Humanoid.Sit then
                            LP.Character.Humanoid.Sit = false
                        end

                    else
                        DungDiChuyen()
                    end
                end
            else
                DungDiChuyen()
            end
        end
    end
end
---------
task.spawn(function()
    while task.wait() do
        if getgenv().DangDiMuaDo then
            continue
        end
        if _G.DangSan then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = LP.Character and LP.Character:FindFirstChild("Humanoid")

            local isFoundWatcher, watcherPos = getFrozenWatcherPosition()
            if isFoundWatcher then
                if HandleFrozenWatcherLogic(hrp, humanoid, watcherPos) then continue end
            end

            local isFoundHeart, heartPos, frozenHeartObj = GetFrozenHeartData()
            
            if _G.ShootHeart then
                if isFoundHeart or daBatDauKeoTim then
                    local isHarpooned = IsFrozenHeartHarpooned()
                    
                    if (_G.DriveToTiki or _G.DriveToHydra) and (isHarpooned or daBatDauKeoTim) then
                        if KeoTimVeDao() then continue end
                    end
                    
                    if isFoundHeart then
                        if HandleFrozenHeartLogic(hrp, humanoid, heartPos) then continue end
                    end
                end
            end
            
            if daBatDauKeoTim then continue end
            
            local seaEventTarget, eType, targetPos = GetNearestSeaEvent()
            local skipSeaEvents = false
            
            if _G.DestroyIDK then
                local allCleared = true
                local rawData = nil
                
                if getgenv().FetchUnifiedPartyData then
                    rawData = getgenv().FetchUnifiedPartyData()
                end
                
                if rawData then
                    for _, acc in pairs(rawData) do
                        if acc.IDK == true then
                            allCleared = false
                            break
                        end
                    end
                else
                    allCleared = (_G.SpyCheckResult > -1 and _G.SpyCheckResult <= 5)
                end

                if allCleared then
                    skipSeaEvents = true
                end
            end
            local isLeviathan = false
            if seaEventTarget and (seaEventTarget.Name == "Leviathan Segment" or seaEventTarget.Name == "Leviathan") then 
                isLeviathan = true 
                task.wait() 
            end

            if getgenv().DangSafeMode and getgenv().ViTriSafe then
                if getgenv().Meyy6Race_API then
                    getgenv().Meyy6Race_API.SetTask("Low HP - Healing")
                end
                DiChuyenDen(getgenv().ViTriSafe)
            elseif seaEventTarget and targetPos and (not skipSeaEvents or isLeviathan) then
                HandleSeaEventCombat(hrp, seaEventTarget, eType, targetPos, isLeviathan)
            else
                HandlePatrolAndIdle(hrp, isLeviathan, isFoundWatcher)
            end
        else
            getgenv().CurrentTarget = nil
            getgenv().CurrentTargetPart = nil
            getgenv().MacroAimPos = nil
            getgenv().IsPureM1 = false
            getgenv().UseOnlyGunSkill = false
            if getgenv().Meyy6Race_API then
                getgenv().Meyy6Race_API.SetTask("Idle")
                getgenv().Meyy6Race_API.SetTheme("Dark")
            end
            DungDiChuyen()
        end
    end
end)
---------

local function down(use, waitTime)
    pcall(function()
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            VirtualInputManager:SendKeyEvent(true, use, false, LP.Character.HumanoidRootPart)
            task.wait(waitTime or 0.1)
            VirtualInputManager:SendKeyEvent(false, use, false, LP.Character.HumanoidRootPart)
        end
    end)
end

local function Useskills(weapon, skill)
    if weapon == "nil" and skill == "Y" then
        VirtualInputManager:SendKeyEvent(true, "Y", false, game)
        VirtualInputManager:SendKeyEvent(false, "Y", false, game)
    end
end

local SkillConfig = {
    ["Auto Enable V3"] = false, 
    ["Auto Enable V4"] = false,
    ["Custom Health"] = true,
    ["Health"] = 3000,
    ["Melee"] = {
        ["Enable"] = true,
        ["Z"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 1, ["Count"] = 30},
        ["X"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 2, ["Count"] = 30},
        ["C"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 3, ["Count"] = 30}
    },        
    ["Sword"] = {
        ["Enable"] = true,
        ["Z"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 4, ["Count"] = 20},
        ["X"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 5, ["Count"] = 20}
    },        
    ["Gun"] = {
        ["Enable"] = true,
        ["GunMode"] = false,
        ["Z"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 6, ["Count"] = 20},
        ["X"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 7, ["Count"] = 20}
    },        
    ["Fruit"] = {
        ["Enable"] = true,
        ["Z"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 8, ["Count"] = 20},
        ["X"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 9, ["Count"] = 20},
        ["C"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 10, ["Count"] = 20},
        ["V"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 11, ["Count"] = 20},
        ["F"] = {["Enable"] = false, ["HoldTime"] = 0.1, ["Priority"] = 12, ["Count"] = 20}
    }
}

local function getDelay(toolName)
    if _G.NoSkillDelay then return 0.05 end
    local delayMs = 100
    if toolName == "Melee" then delayMs = _G.SkillDelayMelee or 100 end
    if toolName == "Sword" then delayMs = _G.SkillDelaySword or 100 end
    if toolName == "Gun" then delayMs = _G.SkillDelayGun or 100 end
    if toolName == "Fruit" then delayMs = _G.SkillDelayFruit or 100 end
    return delayMs / 1000
end

task.spawn(function()
    while task.wait() do 
        pcall(function()
            if getgenv().CurrentTarget and getgenv().CurrentTargetPart and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                if (getgenv().CurrentTargetPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude < 50 then
                    if SkillConfig["Auto Enable V3"] then
                        if SkillConfig["Custom Health"] and LP.Character:FindFirstChild("Humanoid") and LP.Character.Humanoid.Health <= SkillConfig["Health"] then
                            down("T", 0.1)
                        end
                    end
                    if SkillConfig["Auto Enable V4"] then
                        if LP.Character:FindFirstChild("RaceEnergy") and LP.Character.RaceEnergy.Value == 1 then
                            Useskills("nil", "Y")
                        end
                    end
                end
            end
        end)
    end
end)

local HttpService = game:GetService("HttpService")
local FILE_NAME = "Meyy_Leviathan_Kaitun/Name.json"

local function GetPartyFromJSON()
    if getgenv().FetchUnifiedPartyData then
        return getgenv().FetchUnifiedPartyData()
    end
    return nil
end

getgenv().LastSpawnTime = os.time()

task.spawn(function()
    local LP = game:GetService("Players").LocalPlayer
    if LP.Character then
        getgenv().LastSpawnTime = os.time()
    end
    LP.CharacterAdded:Connect(function()
        getgenv().LastSpawnTime = os.time()
    end)
end)

task.spawn(function()
    while task.wait() do
        pcall(function()
            if not _G.DangSan then
                return
            end
            if os.time() - getgenv().LastSpawnTime < 20 then
                return
            end
            local w = game:GetService("Players")
            local S = w.LocalPlayer
            local isSomeoneDead = false
            local rawData = GetPartyFromJSON()

            if rawData then
                for _, acc in pairs(rawData) do
                    local memberName = acc.Name
                    if memberName ~= S.Name then
                        local member = w:FindFirstChild(memberName)
                        if member then
                            local mChar = member.Character
                            local mHum = mChar and mChar:FindFirstChild("Humanoid")
                            if mChar and mHum and mHum.Health <= 0 then
                                isSomeoneDead = true
                                break
                            end
                        end
                    end
                end
            end

            if isSomeoneDead then
                local target = GetNearestSeaEvent()
                local isLeviathan = target and (target.Name == "Leviathan Segment" or target.Name == "Leviathan")
                local isFoundWatcher, _ = getFrozenWatcherPosition()
                local isFoundHeart, _1, _2 = GetFrozenHeartData()
                
                if not isLeviathan and not isFoundWatcher and not isFoundHeart then
                    print("Someone in the party is dead. Attempting to kill self to respawn.")
                    if S.Character and S.Character:FindFirstChild("Humanoid") then
                        if S.Character.Humanoid.Health > 0 then
                            S.Character.Humanoid.Health = 0
                            getgenv().LastSpawnTime = os.time()
                        end
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait() do
        pcall(function()
            if getgenv().DangSafeMode then return end
            if not getgenv().CurrentTarget or not getgenv().CurrentTargetPart then return end
            if getgenv().IsPureM1 then return end
            
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local targetPos = getgenv().CurrentTargetPart.Position
            local myPos = hrp.Position
            local distXZ = (Vector3.new(targetPos.X, 0, targetPos.Z) - Vector3.new(myPos.X, 0, myPos.Z)).Magnitude
            
            if distXZ > 150 then return end

            local toolMappings = {
                ["Melee"] = _G.SelectedMelee or {},
                ["Sword"] = _G.SelectedSword or {},
                ["Gun"] = _G.SelectedGun or {},
                ["Fruit"] = _G.SelectedFruit or {}
            }
            
            local queue = {}
            for typeName, selectedList in pairs(toolMappings) do
                if getgenv().UseOnlyGunSkill and typeName ~= "Gun" then
                    continue
                end
                
                if SkillConfig[typeName] and SkillConfig[typeName].Enable then
                    for skillKey, skillData in pairs(SkillConfig[typeName]) do
                        if type(skillData) == "table" and skillData.Priority then
                            skillData.Enable = table.find(selectedList, skillKey) ~= nil
                            
                            if skillData.Enable then
                                table.insert(queue, {
                                    Type = typeName,
                                    Key = skillKey,
                                    Data = skillData
                                })
                            end
                        end
                    end
                end
            end
            
            table.sort(queue, function(a, b) return a.Data.Priority < b.Data.Priority end)
            
            for _, item in ipairs(queue) do
                local toolName = equip(item.Type)
                if toolName then
                    local skillGui = LP.PlayerGui.Main.Skills:FindFirstChild(toolName)
                    if skillGui and skillGui:FindFirstChild(item.Key) then
                        local titleLabel = skillGui[item.Key]:FindFirstChild("Title")
                        if titleLabel and titleLabel:IsA("TextLabel") and titleLabel.TextColor3 == Color3.fromRGB(255, 255, 255) then
                            local cdGui = skillGui[item.Key]:FindFirstChild("Cooldown")
                            if cdGui and cdGui.AbsoluteSize.X <= 0 then
                                local useDelay = getDelay(item.Type)
                                for i = 1, (item.Data.Count or 1) do
                                    if cdGui.AbsoluteSize.X > 0 then
                                        break
                                    end
                                    down(item.Key, item.Data.HoldTime)
                                    task.wait(useDelay)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

local PlayerMouse = game:GetService("Players").LocalPlayer:GetMouse()
local MT = getrawmetatable(game)
local OldNameCall = MT.__namecall
local OldIndex = MT.__index
setreadonly(MT, false)

MT.__index = newcclosure(function(self, key)
    if (key == "Hit" or key == "Target") then
        if not checkcaller() and self == PlayerMouse then
            local targetPart = getgenv().CurrentTargetPart
            if targetPart then
                if key == "Hit" then
                    return getgenv().MacroAimPos or CFrame.new(targetPart.Position)
                elseif key == "Target" then
                    return targetPart
                end
            end
        end
    end
    return OldIndex(self, key)
end)

MT.__namecall = newcclosure(function(self, ...)
    local Method = getnamecallmethod()
    
    if (Method == "FireServer" or Method == "InvokeServer") and not checkcaller() and getgenv().MacroAimPos then
        local Args = {...}
        local rawTarget = getgenv().CurrentTargetPart
        local fireAimPos = getgenv().MacroAimPos.Position

        if Method == "FireServer" and typeof(self) == "Instance" and (self.Name == "RemoteEvent" or self.ClassName == "RemoteEvent") then
            local arg1str = tostring(Args[1])
            if arg1str ~= "true" and arg1str ~= "false" then
                for i, v in ipairs(Args) do
                    local t1 = typeof(v)
                    if t1 == "Vector3" then
                        Args[i] = fireAimPos
                    elseif t1 == "vector" then
                        Args[i] = vector.create(fireAimPos.X, fireAimPos.Y, fireAimPos.Z)
                    elseif t1 == "CFrame" then
                        Args[i] = getgenv().MacroAimPos or CFrame.new(fireAimPos)
                    end
                end
                return OldNameCall(self, unpack(Args))
            end
            
        elseif Method == "InvokeServer" and typeof(self) == "Instance" and self.ClassName == "RemoteFunction" then
            local skill = tostring(Args[1])
            local isSkill = (typeof(skill) == "string" and string.len(skill) == 1 and skill:match("%u"))
            
            if isSkill then
                local function scanTable(t)
                    for tk, tv in pairs(t) do
                        local typeTv = typeof(tv)
                        if typeTv == "Vector3" then
                            t[tk] = fireAimPos
                        elseif typeTv == "CFrame" then
                            t[tk] = getgenv().MacroAimPos or CFrame.new(fireAimPos)
                        elseif typeTv == "table" then
                            scanTable(tv)
                        end
                    end
                end

                for i, v in ipairs(Args) do
                    local typeV = typeof(v)
                    if typeV == "Vector3" then
                        Args[i] = fireAimPos
                    elseif typeV == "vector" then
                        Args[i] = vector.create(fireAimPos.X, fireAimPos.Y, fireAimPos.Z)
                    elseif typeV == "CFrame" then
                        Args[i] = getgenv().MacroAimPos or CFrame.new(fireAimPos)
                    elseif typeV == "Instance" and (v:IsA("BasePart") or v:IsA("Model")) then
                        if rawTarget then Args[i] = rawTarget end
                    elseif typeV == "table" then
                        scanTable(v)
                    end
                end
                
                if typeof(Args[2]) == "Vector3" or typeof(Args[2]) == "CFrame" then
                    if rawTarget then
                        Args[3] = rawTarget
                    end
                end
                
                return OldNameCall(self, unpack(Args))
            else
                for i, v in ipairs(Args) do
                    local typeV = typeof(v)
                    if typeV == "Vector3" then
                        Args[i] = fireAimPos
                    elseif typeV == "vector" then
                        Args[i] = vector.create(fireAimPos.X, fireAimPos.Y, fireAimPos.Z)
                    elseif typeV == "CFrame" then
                        Args[i] = getgenv().MacroAimPos or CFrame.new(fireAimPos)
                    end
                end
                return OldNameCall(self, unpack(Args))
            end
        end
    end
    
    return OldNameCall(self, ...)
end)

setreadonly(MT, true)

local GunValidator = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Validator2")
local AimBotSkillPosition = nil 

pcall(function()
    local gg = getrawmetatable(game);
    local old = gg.__namecall;
    setreadonly(gg, false);

    gg.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod();
        local args = { ... }
        
        if _G.UseGunEvent and tostring(method) == "FireServer" and tostring(self) == "ShootGunEvent" then
            if AimBotSkillPosition then
                args[1] = AimBotSkillPosition 
                return old(self, unpack(args))
            end
        end
        return old(self, ...)
    end);
end)

local function FindNearestMob()
    return getgenv().CurrentTarget 
end

local function GetValidator2(shootFunc)
    if not getupvalue or not setupvalue or not shootFunc then return nil, nil end
    local success, v1_val, v7_val = pcall(function()
        local u27 = getupvalue(shootFunc, 13)
        local u23 = getupvalue(shootFunc, 14)
        local u26 = getupvalue(shootFunc, 15)
        local u22 = getupvalue(shootFunc, 16)
        local u24 = getupvalue(shootFunc, 17)
        local u25 = getupvalue(shootFunc, 18)
        local u28 = getupvalue(shootFunc, 19)
        
        local u81 = u27 * u23
        local u82 = (u26 * u23 + u27 * u22) % u24
        u82 = (u82 * u24 + u81) % u25
        u26 = math.floor(u82 / u24)
        u27 = u82 - u26 * u24
        u28 = u28 + 1
        
        setupvalue(shootFunc, 13, u27)
        setupvalue(shootFunc, 14, u23)
        setupvalue(shootFunc, 15, u26)
        setupvalue(shootFunc, 16, u22)
        setupvalue(shootFunc, 17, u24)
        setupvalue(shootFunc, 18, u25)
        setupvalue(shootFunc, 19, u28)
        
        return math.floor(u82 / u25 * 16777215), u28
    end)
    if success and v1_val and v7_val then 
        return v1_val, v7_val 
    end
    return nil, nil
end

task.spawn(function()
    while true do
        if _G.UseGunEvent then
            local targetMob = FindNearestMob()
            if targetMob and getgenv().CurrentTargetPart then
                local targetPos = getgenv().CurrentTargetPart.Position
                local partToShoot = getgenv().CurrentTargetPart
                
                if targetPos then
                    AimBotSkillPosition = targetPos 
                    pcall(function()
                        local NetModule = require(ReplicatedStorage.Modules.Net)
                        NetModule:RemoteEvent("ShootGunEvent"):FireServer(targetPos, {partToShoot})
                    end)
                end
            end
        else
            AimBotSkillPosition = nil 
        end
        task.wait()
    end
end)

task.spawn(function()
    local CombatController, ShootFunction
    pcall(function()
        local Modules = ReplicatedStorage:WaitForChild("Modules")
        CombatController = require(ReplicatedStorage.Controllers.CombatController)
        if getupvalue then
            ShootFunction = getupvalue(CombatController.Attack, 9)
        end
    end)

    while true do
        if _G.UseGunEvent then
            local targetMob = FindNearestMob()
            if targetMob and getgenv().CurrentTargetPart then
                local targetPos = getgenv().CurrentTargetPart.Position
                
                if targetPos then
                    pcall(function()
                        if ShootFunction and GunValidator then
                            local val1, val2 = GetValidator2(ShootFunction)
                            if val1 and val2 then
                                GunValidator:FireServer(val1, val2)
                            end
                        end
                        local NetModule = require(ReplicatedStorage.Modules.Net)
                        NetModule:RemoteEvent("ShootGunEvent"):FireServer(targetPos)
                    end)
                end
            end
            task.wait(1.95) 
        else
            task.wait(1) 
        end
    end
end)

local SettingsTab = Window:CreateTab("Settings", true, "rbxthumb://type=Asset&id=125575515639947&w=420&h=420")
SettingsTab:CreatePageTitle("General Config")

SettingsTab:CreateDropdown("Select Team", "Marines", {"Marines", "Pirates"}, "Select your default team", function(val)
    _G.ChonPhe = val
    Library:SendNotification("Team Setup", "Auto team set to " .. val)
end)
SettingsTab:CreateDropdown("Select Weapon", "Melee", {"Melee", "Sword", "Blox Fruit", "Gun"}, "Select weapon for M1 sea events", function(val)
    _G.SelectedWeapon = val
end)
SettingsTab:CreateSwitch("Spin Position", true, "Spin around sea events target", function(val)
    _G.SpinPosition = val
end)
SettingsTab:CreateSwitch("Enable Ignore Sea Event", true, "Fly up if unselected event spawns", function(val)
    _G.EnableIgnoreSeaEvent = val
end)
SettingsTab:CreateSwitch("Enable Ignore Island", true, "Fly up when near Prehistoric or Mystic Island", function(val)
    _G.EnableIgnoreIsland = val
end)
_G.SafeFlyingBoat = true
SettingsTab:CreateSwitch("Safe Flying Boat", true, "Auto fly and orbit to dodge when unsit", function(val)
    _G.SafeFlyingBoat = val
end)
SettingsTab:CreateSwitch("Enable Noclip", true, "Prevent getting stuck", function(val)
    _G.BatNoclip = val
    Library:SendNotification("Noclip Status", val and "Enabled" or "Disabled")
end)
_G.AutoBuso = true
SettingsTab:CreateSwitch("Auto Buso Haki", true, "Auto turn on buso haki", function(val)
    _G.AutoBuso = val
end)

_G.AutoV3 = true
SettingsTab:CreateSwitch("Auto V3", true, "Auto turn on v3", function(val)
    _G.AutoV3 = val
end)

_G.AutoKen = true
SettingsTab:CreateSwitch("Auto Observation Haki", true, "Auto turn on Observation haki", function(val)
    _G.AutoKen = val
end)
SettingsTab:CreateSlider("Tween Speed", 50, 500, 170, "Movement speed (studs/s)", function(val)
    _G.TocDoTween = val 
end)

SettingsTab:CreateSlider("Tween Boat Speed", 50, 500, 250, "Boat movement speed (studs/s)", function(val)
    _G.TocDoTweenBoat = val 
end)

SettingsTab:CreateSlider("Flight Height", 10, 500, 20, "Set Y axis for boat flying", function(val)
    _G.ChieuCaoBay = val
end)
SettingsTab:CreateSlider("Ignore Height", 50, 1500, 500, "Y axis when ignoring monsters", function(val)
    _G.IgnoreHeight = val
end)
SettingsTab:CreateSlider("Ignore Island Height", 50, 2000, 800, "Y axis when ignoring islands", function(val)
    _G.IgnoreIslandHeight = val
end)
_G.SafeHeightY = 400
SettingsTab:CreateSlider("Safe Height Y", 50, 1000, 400, "Y-axis height for boat to dodge", function(val)
    _G.SafeHeightY = val
end)

_G.SafeRadius = 250
SettingsTab:CreateSlider("Safe Orbit Radius", 0, 500, 250, "Radius to orbit around sea event", function(val)
    _G.SafeRadius = val
end)
local ShopTab = Window:CreateTab("Shop & Status", false, "rbxassetid://130982467998100")
ShopTab:CreatePageTitle("Server Status")

local SpyPara = ShopTab:CreateParagraph("Spy Status", "Loading...")
local FrozenPara = ShopTab:CreateParagraph("Frozen Dimension", "Loading...")

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local spyText = "I Don't Know"
            if _G.SpyCheckResult == -1 then
                spyText = "I Don't Know"
            elseif _G.SpyCheckResult >= 1 and _G.SpyCheckResult <= 4 then
                spyText = "Done Destroy - Can Bride " .. tostring(5 - _G.SpyCheckResult) .. " More"
            elseif _G.SpyCheckResult == 5 then
                spyText = "Done Bride - Can Find Levi"
            end

            if SpyPara and SpyPara.Set then
                pcall(function() SpyPara:Set({Title = "Spy Status", Content = spyText}) end)
                pcall(function() SpyPara:Set("Spy Status", spyText) end)
            end

            local isFoundWatcher, _ = getFrozenWatcherPosition()
            local frozenText = isFoundWatcher and "Have Frozen Dimension In Server" or "No Frozen Dimension In Server"

            if FrozenPara and FrozenPara.Set then
                pcall(function() FrozenPara:Set({Title = "Frozen Dimension", Content = frozenText}) end)
                pcall(function() FrozenPara:Set("Frozen Dimension", frozenText) end)
            end
        end)
    end
end)
---------
ShopTab:CreatePageTitle("Random Fruit")



ShopTab:CreateSwitch("Auto Random Fruit", true, "Automatically roll fruit every 60s", function(val)
    _G.AutoRandomFruit = val
end)

ShopTab:CreateSwitch("Auto Store Fruit", true, "Automatically store fruits to inventory", function(val)
    _G.AutoStoreFruit = val
end)

task.spawn(function()
    while task.wait(60) do
        if _G.AutoRandomFruit then
            pcall(function()
                local args1 = {
                    {
                        BoxName = "ZiolesGacha",
                        Context = "Check",
                        SpokeNPC = "Blox Fruit Gacha"
                    }
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/GachaNetworkRF"):InvokeServer(unpack(args1))

                task.wait(1)

                local args2 = {
                    {
                        Context = "Purchase",
                        BoxName = "ZiolesGacha"
                    }
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/GachaNetworkRF"):InvokeServer(unpack(args2))
            end)
        end
    end
end)

local lastStoredFruit = nil
local fruitStoreAttempts = 0

task.spawn(function()
    while task.wait(1) do
        if _G.AutoStoreFruit then
            pcall(function()
                local char = LP.Character
                local backpack = LP:FindFirstChild("Backpack")
                local targetFruitTool = nil

                if char then
                    for _, item in ipairs(char:GetChildren()) do
                        if item:IsA("Tool") and (item:GetAttribute("Fruit") or string.find(item.Name, "Fruit")) then
                            targetFruitTool = item
                            break
                        end
                    end
                end

                if not targetFruitTool and backpack then
                    for _, item in ipairs(backpack:GetChildren()) do
                        if item:IsA("Tool") and (item:GetAttribute("Fruit") or string.find(item.Name, "Fruit")) then
                            targetFruitTool = item
                            break
                        end
                    end
                end

                if targetFruitTool then
                    if lastStoredFruit ~= targetFruitTool then
                        lastStoredFruit = targetFruitTool
                        fruitStoreAttempts = 0
                    end

                    if fruitStoreAttempts < 10 then
                        local fruitInternalName = targetFruitTool:GetAttribute("OriginalName") or targetFruitTool:GetAttribute("FruitName") or targetFruitTool.Name
                        local storeArgs = {
                            "StoreFruit",
                            fruitInternalName,
                            targetFruitTool
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(storeArgs))
                        fruitStoreAttempts = fruitStoreAttempts + 1
                    end
                else
                    lastStoredFruit = nil
                    fruitStoreAttempts = 0
                end
            end)
        end
    end
end)
ShopTab:CreatePageTitle("Shop")

ShopTab:CreateButton("Reroll Race", "change race ", function()
    local args1 = {
        "BlackbeardReward",
        "Reroll",
        "1"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args1))
    
    local args2 = {
        "BlackbeardReward",
        "Reroll",
        "2"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args2))
end)

ShopTab:CreateButton("Reset Stats", "reset stats", function()
    local args1 = {
        "BlackbeardReward",
        "Refund",
        "1"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args1))

    local args2 = {
        "BlackbeardReward",
        "Refund",
        "2"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args2))
end)

ShopTab:CreateButton("Buy Ghoul Race", "Change To Ghoul Race", function()
    local args = {
        "Ectoplasm",
        "Change",
        4
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
end)

ShopTab:CreateButton("Buy Cyborg Race", "Change To Cyborg Race", function()
    local args = {
        "CyborgTrainer",
        "Buy"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
end)


ShopTab:CreateButton("Buy Draco Race", "Change To Draco Race", function()
    task.spawn(function()
        local npcPos = GetNpcPosition("Dragon Wizard")
        if npcPos then
            getgenv().DangDiMuaDo = true
            if getgenv().Meyy6Race_API then
                getgenv().Meyy6Race_API.SetTask("Moving to NPC")
                getgenv().Meyy6Race_API.SetTheme("Dark")
            end
            DiChuyenDen(CFrame.new(npcPos))
            while task.wait(0.1) do
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then break end
                
                if (hrp.Position - npcPos).Magnitude <= 15 then
                    DungDiChuyen()
                    local args1 = {{NPC = "Dragon Wizard", Command = "Speak"}}
                    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/InteractDragonQuest"):InvokeServer(unpack(args1))
                    task.wait(0.5)
                    local args2 = {{NPC = "Dragon Wizard", Command = "DragonRace"}}
                    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/InteractDragonQuest"):InvokeServer(unpack(args2))
                    getgenv().DangDiMuaDo = false
                    break
                end
            end
        end
    end)
end)

ShopTab:CreatePageTitle("Buy Melee")

local MeleeConfig = {
    {Name = "Sanguine Art", NPC = "Shafi", Remote = "BuySanguineArt", Extra = nil},
    {Name = "Godhuman", NPC = "Ancient Monk", Remote = "BuyGodhuman", Extra = nil},
    {Name = "Dragon Talon", NPC = "Uzoth", Remote = "BuyDragonTalon", Extra = nil},
    {Name = "Electric Claw", NPC = "Previous Hero", Remote = "BuyElectricClaw", Extra = nil},
    {Name = "Sharkman Karate", NPC = "Sharkman Teacher", Remote = "BuySharkmanKarate", Extra = nil},
    {Name = "Death Step", NPC = "Phoeyu, the Reformed", Remote = "BuyDeathStep", Extra = nil},
    {Name = "Superhuman", NPC = "Martial Arts Master", Remote = "BuySuperhuman", Extra = nil}
}

for _, melee in ipairs(MeleeConfig) do
    local toggleVar = "AutoBuy_" .. string.gsub(melee.Name, " ", "")
    _G[toggleVar] = false
    
    ShopTab:CreateSwitch("Buy " .. melee.Name, false, "Go To Buying Melee " .. melee.Name, function(val)
        _G[toggleVar] = val
        if val then
            task.spawn(function()
                local npcPos = GetNpcPosition(melee.NPC)
                if npcPos then
                    getgenv().DangDiMuaDo = true
                    DiChuyenDen(CFrame.new(npcPos))
                    while _G[toggleVar] do
                        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            if (hrp.Position - npcPos).Magnitude <= 15 then
                                DungDiChuyen()
                                local args = {melee.Remote}
                                if melee.Extra ~= nil then
                                    table.insert(args, melee.Extra)
                                end
                                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
                                _G[toggleVar] = false
                                getgenv().DangDiMuaDo = false
                                break
                            end
                        end
                        task.wait(0.2)
                    end
                end
            end)
        else
            getgenv().DangDiMuaDo = false
            DungDiChuyen()
        end
    end)
end

local HuntTab = Window:CreateTab("Hunt Leviathan", false, "rbxassetid://110509017095259")
HuntTab:CreatePageTitle("Boost Fps & Remove Fog")
repeat
    task.wait(0.5)
until LP.Team ~= nil and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

HuntTab:CreateSwitch("Remove Fog", true, "Clear all fog for better vision", function(val)
    _G.XoaSuongMu = val
end)
_G.BoostFPS_Executed = false
HuntTab:CreateSwitch("Boost Fps", false, "Extreme FPS boost & Remove Sound", function(val)
    if val and not _G.BoostFPS_Executed then
        _G.BoostFPS_Executed = true
        task.spawn(function()
            local CFG = {
                disable3D       = true,
                soundOff        = true,
                disableCoreGui  = true,
                lowQuality      = true,
                postFXOff       = true,
                zeroWater       = true,
                hide = {
                    geometry      = true,
                    castShadowOff = true,
                    reflectance0  = true,
                    materialPlastic = true,
                    includeCharacter = true,
                },
                kill = {
                    particles     = true,
                    lights        = true,
                    decals        = true,
                    ui3d          = true,
                    prompts       = true,
                    highlights    = true,
                    clothes       = true,
                    accessories   = true,
                },
                batchSize       = 2000,
                hookNewSpawn    = true,
                antiAFK         = true,
            }

            local S = setmetatable({}, {__index=function(t,k)local s=game:GetService(k) rawset(t,k,s) return s end})
            local RunService, Workspace, Lighting, Players, StarterGui, SoundService, UIS, ReplicatedStorage =
                S.RunService, S.Workspace, S.Lighting, S.Players, S.StarterGui, S.SoundService, S.UserInputService, S.ReplicatedStorage

            local LP = Players.LocalPlayer

            local function safe(_, f) local ok = pcall(f); return ok end

            if CFG.soundOff then safe(nil, function() UserSettings():GetService("UserGameSettings").MasterVolume = 0 end) end
            if CFG.lowQuality then safe(nil, function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end) end

            local t = Workspace.Terrain
            if CFG.zeroWater then
                t.WaterWaveSize, t.WaterWaveSpeed = 0, 0
                t.WaterReflectance = 0
                t.WaterTransparency = 1
            end

            sethiddenproperty(Lighting, "Technology", 2)
            sethiddenproperty(t, "Decoration", false)
            Lighting.GlobalShadows = 0
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 0

            local function killPostFX()
                for _, e in ipairs(Lighting:GetChildren()) do
                    if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                        e.Enabled = false
                    end
                end
            end
            if CFG.postFXOff then killPostFX() end

            local function EnableFastMode()
                if _G.FastMode then return end
                _G.FastMode = true
                _G.reducing = true
                _G.FastModeCache = {}

                local Map = Workspace:FindFirstChild("Map")
                local Unloaded = ReplicatedStorage:FindFirstChild("Unloaded")
                local SmoothPlastic = Enum.Material.SmoothPlastic

                local function optimize(descendants)
                    local start = os.clock()
                    for _, obj in ipairs(descendants) do
                        if obj:IsA("BasePart") then
                            _G.FastModeCache[obj] = obj.Material
                            obj.Material = SmoothPlastic
                        elseif obj:IsA("Texture") and not obj:GetAttribute("Offset") then
                            obj:Destroy()
                        end
                        if os.clock() - start > 0.008 then
                            task.wait()
                            start = os.clock()
                        end
                    end
                end

                if Map then optimize(Map:GetDescendants()) end
                if Unloaded then optimize(Unloaded:GetDescendants()) end

                local Optimizer = LP.PlayerScripts:FindFirstChild("OptimizerClientActor")
                if Optimizer and Optimizer.SendMessage then
                    Optimizer:SendMessage("Optimize", true)
                end
            end

            local function DisableVFX()
                LP:SetAttribute("DisableAllyEffects", true)
            end

            local function DisableCameraShake()
                pcall(function()
                    local cs1 = require(ReplicatedStorage.Util.CameraShake)
                    if cs1.SetEnabled then cs1:SetEnabled(false) end
                end)
                pcall(function()
                    local cs2 = require(ReplicatedStorage.Util.CameraShaker)
                    if cs2.SetEnabled then cs2:SetEnabled(false) end
                end)
                pcall(function()
                    ReplicatedStorage.Remotes.ChangeSetting:FireServer("CameraShake", false)
                end)
            end

            local function DisableMusic()
                pcall(function() game.ReplicatedStorage.Events.ToggleMusic.Event:Fire(true) end)
                for _, s in pairs(Workspace._WorldOrigin.Sounds.Locations:GetChildren()) do
                    if s:IsA("Sound") then s:Pause() end
                end
            end

            EnableFastMode()
            DisableVFX()
            DisableCameraShake()
            DisableMusic()

            local function hideGeometry(inst)
                if not CFG.hide.geometry then return end
                if inst:IsA("BasePart") then
                    if inst.Transparency == 1 then 
                        return 
                    end 
                    if CFG.hide.castShadowOff and inst.CastShadow ~= false then inst.CastShadow = false end
                    if CFG.hide.reflectance0 and inst.Reflectance ~= 0 then inst.Reflectance = 0 end
                    if inst.Material ~= Enum.Material.Plastic then
                        inst.Material = Enum.Material.Plastic
                    end
                end
            end

            local function cull(inst)
                if not inst or inst.Parent == nil then return end
                hideGeometry(inst)

                if CFG.kill.particles and (inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles")) then
                    if inst:IsA("ParticleEmitter") or inst:IsA("Trail") then
                        inst.Lifetime = NumberRange.new(0)
                        if inst:IsA("ParticleEmitter") then inst.Rate = 0 end
                    else
                        if inst.Enabled ~= nil then inst.Enabled = false end
                    end
                    return
                end

                if CFG.kill.lights and (inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight")) then
                    inst.Enabled = false
                    return
                end

                if CFG.kill.decals then
                    if inst:IsA("Decal") or inst:IsA("Texture") then inst.Transparency = 1; return end
                    if inst:IsA("SurfaceAppearance") then
                        safe(nil, function() inst.ColorMap = "rbxassetid://0" end)
                        return
                    end
                end

                if inst:IsA("Explosion") then
                    inst.BlastPressure = 1
                    inst.BlastRadius = 1
                    return
                end
            end

            local processed = setmetatable({}, {__mode="k"})
            local queue = {}

            local function push(x) 
                if x and not processed[x] then 
                    queue[#queue+1] = x; processed[x] = true 
                end 
            end

            local function pop()
                local n = #queue
                if n == 0 then return end
                local v = queue[n]; queue[n] = nil; return v
            end

            for _, v in ipairs(Workspace:GetDescendants()) do push(v) end
            for _, v in ipairs(Lighting:GetDescendants()) do push(v) end

            if CFG.hookNewSpawn then
                Workspace.DescendantAdded:Connect(push)
                Lighting.DescendantAdded:Connect(push)
            end

            RunService.Heartbeat:Connect(function()
                local n = 0
                while n < CFG.batchSize do
                    local obj = pop()
                    if not obj then break end
                    if obj.Parent ~= nil then cull(obj) end
                    n += 1
                end
            end)

            local function simplifyCharacter(char)
                if not char then return end
                if CFG.kill.accessories then
                    for _, ch in ipairs(char:GetChildren()) do
                        if ch:IsA("Accessory") then safe(nil, function() ch:Destroy() end) end
                    end
                end
                if CFG.kill.clothes then
                    for _, ch in ipairs(char:GetChildren()) do
                        if ch:IsA("Shirt") or ch:IsA("Pants") or ch:IsA("ShirtGraphic") then
                            safe(nil, function() ch:Destroy() end)
                        end
                    end
                end
                local animate = char:FindFirstChild("Animate")
                if animate and animate:IsA("LocalScript") then
                    safe(nil, function() animate.Disabled = true end)
                end
            end

            if LP then
                if LP.Character then simplifyCharacter(LP.Character) end
                LP.CharacterAdded:Connect(function(c)
                    c:WaitForChild("HumanoidRootPart", 10)
                    simplifyCharacter(c)
                end)
            end
        end)
    end
end)
HuntTab:CreatePageTitle("Sea Event & Setup")

HuntTab:CreateSwitch("Use Gun For Sea Event", false, "Auto use Dragonstorm or Skull Guitar", function(val)
    _G.UseGunEvent = val
end)

HuntTab:CreateSwitch("Use M1 Fruit For Sea Event", false, "Auto use M1 Fruit for all sea events", function(val)
    _G.UseM1FruitEvent = val
end)

HuntTab:CreateMultiDropdown("Select Sea Events", {"Leviathan"}, {"Piranha", "Terrorshark", "Shark", "PirateBrigade", "PirateGrandBrigade", "FishBoat", "Sea Beast", "Leviathan"}, "Select events to hunt", function(val)
    _G.SelectedEvents = val
end)
local danhSachNguoiChoi = {}
for _, p in ipairs(Players:GetPlayers()) do
    table.insert(danhSachNguoiChoi, p.Name)
end


local danhSachNguoiChoi = {}
for _, p in ipairs(Players:GetPlayers()) do
    table.insert(danhSachNguoiChoi, p.Name)
end

---------
local function FormatBoatForRemote(boatDisplayName)
    if boatDisplayName == "Beast Hunter" then
        return "Beast Hunter"
    end
    return string.gsub(boatDisplayName, "%s+", "")
end

local function GetBoatDisplayList()
    local teamPrefix = (_G.ChonPhe == "Marines" or _G.ChonPhe == "Marine") and "Marine " or "Pirate "
    return {
        teamPrefix .. "Sloop",
        teamPrefix .. "Brigade",
        teamPrefix .. "Grand Brigade",
        "Beast Hunter"
    }
end

local CurrentBoatDisplay = "Beast Hunter"
_G.TenThuyen = FormatBoatForRemote(CurrentBoatDisplay)

local BoatDropdown = HuntTab:CreateDropdown("Select Boat", CurrentBoatDisplay, GetBoatDisplayList(), "Select boat to buy", function(val)
    CurrentBoatDisplay = val
    _G.TenThuyen = FormatBoatForRemote(val)
end)

task.spawn(function()
    local lastTeam = _G.ChonPhe
    while task.wait(1) do
        if _G.ChonPhe ~= lastTeam then
            lastTeam = _G.ChonPhe
            local newOptions = GetBoatDisplayList()
            if BoatDropdown and BoatDropdown.Refresh then
                BoatDropdown:Refresh(newOptions)
            end
            CurrentBoatDisplay = "Beast Hunter"
            _G.TenThuyen = FormatBoatForRemote(CurrentBoatDisplay)
        end
    end
end)
---------

local BoatBuyerDropdown = HuntTab:CreateDropdown("Account Buy Boat", LP.Name, danhSachNguoiChoi, "Select the boat buyer account", function(val)
    _G.NguoiMuaThuyen = val
    if val == LP.Name then
        Library:SendNotification("Role Update", "You are the boat buyer")
    else
        Library:SendNotification("Role Update", "You are the helper clone")
    end
end)

HuntTab:CreateButton("Refresh Player List", "Update players in server", function()
    local newList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(newList, p.Name)
    end
    if BoatBuyerDropdown and BoatBuyerDropdown.Refresh then
        BoatBuyerDropdown:Refresh(newList)
        Library:SendNotification("System Update", "Player list refreshed")
    end
end)


HuntTab:CreateDropdown("Required Players", "5", {"1", "2", "3", "4", "5", "6"}, "Players needed on boat to start", function(val)
    _G.SoNguoiCanThiet = tonumber(val)
    Library:SendNotification("Hunt Config", "Required players set to " .. val)
end)
HuntTab:CreatePageTitle("Drive Boat & Shoot Heart")

HuntTab:CreateSwitch("Drive Boat To Tiki", false, "Auto Shoot & drive to Tiki with heart", function(val)
    _G.DriveToTiki = val
    if val then 
        _G.DriveToHydra = false 
    end
end)

HuntTab:CreateSwitch("Drive Boat To Hydra", false, "Auto Shoot & drive to Hydra with heart", function(val)
    _G.DriveToHydra = val
    if val then 
        _G.DriveToTiki = false 
    end
end)
HuntTab:CreateSlider("Pull Y Height", 0, 100, 35, "Set flight height for dragging heart", function(val)
    _G.PullYHeight = val
end)
HuntTab:CreateSwitch("Shoot Heart", false, "Enable shooting and dragging heart", function(val)
    _G.ShootHeart = val
end)
HuntTab:CreatePageTitle("Hunt Leviathan")
HuntTab:CreateSwitch("Destroy IDK", false, "Destroy IDK to hunt Leviathan if spy says I Don't Know", function(val)
    _G.DestroyIDK = val
end)

HuntTab:CreateParagraph("Destroy IDK Explanation", 
    "🇻🇳 [VIETNAMESE]\n" ..
    "• Khi BẬT: Bỏ qua Sea Event, tập trung 100% tìm/đánh Leviathan. Đánh xong nếu bị IDK sẽ tự đi phá IDK.\n" ..
    "• Khi TẮT: Chạy đa nhiệm (Multi-task), vừa đi tìm Leviathan vừa tự động đánh sạch các Sea Event xuất hiện trên đường.\n\n" ..
    "🇬🇧 [ENGLISH]\n" ..
    "• When ON: Ignores minor Sea Events, focuses 100% on finding/killing Leviathan. Destroy IDK if stuck after killing.\n" ..
    "• When OFF: Multi-tasks by hunting all nearby Sea Events while simultaneously searching for Leviathan."
)

HuntTab:CreateSwitch("Start Hunt", false, "Start hunting Leviathan process", function(val)
    _G.DangSan = val
    if val then
        Library:SendNotification("Hunt Status", "Hunting Started")
    else
        Library:SendNotification("Hunt Status", "Hunting Stopped")
    end
end)

local CraftTab = Window:CreateTab("Craft Scrolls", false, "rbxassetid://92082782484537")
CraftTab:CreatePageTitle("Auto Craft Config")

CraftTab:CreateMultiDropdown("Select Scrolls", {}, {"Common Scroll", "Rare Scroll", "Legendary Scroll", "Mythical Scroll"}, "Select which scrolls to auto craft", function(val)
    _G.SelectedScrolls = val
end)

CraftTab:CreateSwitch("Enable Auto Craft", false, "Toggle auto craft for selected scrolls", function(val)
    _G.AutoCraftScrollSwitch = val
end)

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            if _G.AutoCraftScrollSwitch and type(_G.SelectedScrolls) == "table" then
                for _, scrollName in ipairs(_G.SelectedScrolls) do
                    AutoCraftScroll(scrollName)
                end
            end
        end)
    end
end)

CraftTab:CreateSlider("Common Scroll Cap", 0, 50, 0, "Max limit for Common Scrolls", function(val)
    ScrollCaps.CommonScroll = val
end)

CraftTab:CreateSlider("Rare Scroll Cap", 0, 50, 0, "Max limit for Rare Scrolls", function(val)
    ScrollCaps.RareScroll = val
end)

CraftTab:CreateSlider("Legendary Scroll Cap", 0, 15, 15, "Max limit for Legendary Scrolls", function(val)
    ScrollCaps.LegendaryScroll = val
end)

CraftTab:CreateSlider("Mythical Scroll Cap", 0, 10, 10, "Max limit for Mythical Scrolls", function(val)
    ScrollCaps.MythicalScroll = val
end)

local WebhookTab = Window:CreateTab("Webhook Config", false, "rbxassetid://7733779610")
WebhookTab:CreatePageTitle("Discord Webhook")

WebhookTab:CreateSwitch("Enable Webhook", false, "Turn on/off webhook notifications", function(val)
    _G.WebhookLevi.Enabled = val
end)

WebhookTab:CreateInput("Webhook URL", "Paste your webhook link here...", "", "URL to send discord messages", false, function(val)
    _G.WebhookLevi.Url = val
end)

WebhookTab:CreateInput("Discord User ID", "E.g: 123456789012345678", "", "Leave blank to ping everyone", true, function(val)
    _G.WebhookLevi.DiscordID = val
end)

WebhookTab:CreateSwitch("Enable Ping", false, "Ping everyone or specific user ID", function(val)
    _G.WebhookLevi.PingEnabled = val
end)

WebhookTab:CreatePageTitle("Notification Events")

WebhookTab:CreateSwitch("Notify Found Dimension", false, "Send alert when Frozen dimension is found", function(val)
    _G.WebhookLevi.NotifyWatcher = val
end)

WebhookTab:CreateSwitch("Notify Shoot Heart", false, "Send alert when successfully shooted heart", function(val)
    _G.WebhookLevi.NotifyShoot = val
end)

WebhookTab:CreateSwitch("Notify Heart Delivered", false, "Send alert when boat dragged heart to island", function(val)
    _G.WebhookLevi.NotifyDelivered = val
end)

WebhookTab:CreateSwitch("Notify Material Stats", false, "Send material summary after heart claimed", function(val)
    _G.WebhookLevi.NotifyInventory = val
end)

local SkillTab = Window:CreateTab("Selection Skill", false, "rbxassetid://88966134653623")
SkillTab:CreatePageTitle("Auto Skill Config")

SkillTab:CreateMultiDropdown("Melee Skills", {"Z", "X", "C"}, {"Z", "X", "C"}, "Select Melee Skills", function(val)
    _G.SelectedMelee = val
end)

SkillTab:CreateMultiDropdown("Blox Fruit Skills", {"Z", "X", "C", "F"}, {"Z", "X", "C", "V", "F"}, "Select Blox Fruit Skills", function(val)
    _G.SelectedFruit = val
end)

SkillTab:CreateMultiDropdown("Gun Skills", {"Z", "X"}, {"Z", "X"}, "Select Gun Skills", function(val)
    _G.SelectedGun = val
end)

SkillTab:CreateMultiDropdown("Sword Skills", {"Z", "X"}, {"Z", "X"}, "Select Sword Skills", function(val)
    _G.SelectedSword = val
end)
SkillTab:CreatePageTitle("Delay Skill Config")
_G.SkillDelayMelee = 100
SkillTab:CreateSlider("Melee Delay (ms)", 0, 1000, 100, "Delay for Melee Skills (ms)", function(val)
    _G.SkillDelayMelee = val
end)

_G.SkillDelayFruit = 100
SkillTab:CreateSlider("Fruit Delay (ms)", 0, 1000, 100, "Delay for Fruit Skills (ms)", function(val)
    _G.SkillDelayFruit = val
end)

_G.SkillDelayGun = 100
SkillTab:CreateSlider("Gun Delay (ms)", 0, 1000, 100, "Delay for Gun Skills (ms)", function(val)
    _G.SkillDelayGun = val
end)

_G.SkillDelaySword = 100
SkillTab:CreateSlider("Sword Delay (ms)", 0, 1000, 100, "Delay for Sword Skills (ms)", function(val)
    _G.SkillDelaySword = val
end)

_G.NoSkillDelay = true
SkillTab:CreateSwitch("Use Skill No Delay", true, "Use 0.05s ultra fast delay", function(val)
    _G.NoSkillDelay = val
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.AutoBuso then
                local char = LP.Character
                if char and not char:FindFirstChild("HasBuso") then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if _G.AutoV3 then
                ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility")
            end
        end)
    end
end)

_G.DaResetLeviathan = false
local dangResetLevi = false

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if dangResetLevi then return end

            if not _G.DangSan then
                _G.DaResetLeviathan = false
                return
            end

            local target, eType, targetPos = GetNearestSeaEvent()
            local isLeviathan = target and (target.Name == "Leviathan Segment" or target.Name == "Leviathan")

            if isLeviathan then
                if not _G.DaResetLeviathan then
                    dangResetLevi = true
                    _G.DaResetLeviathan = true
                    
                    task.wait()
                    if _G.DangSan then 
                        _G.DangSan = false
                        if getgenv().Meyy6Race_API then
                            getgenv().Meyy6Race_API.SetTask("Waiting Leviathan")
                            getgenv().Meyy6Race_API.SetTheme("Mint")
                        end
                        task.wait(9)
                        _G.DangSan = true
                    end
                    
                    dangResetLevi = false
                end
            else
                _G.DaResetLeviathan = false
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.AutoKen then
                local char = LP.Character
                if char and not char:FindFirstChild("HasObservation") then
                    local args = {
                        "Ken",
                        true
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommE"):FireServer(unpack(args))
                end
            end
        end)
    end
end)

local dodgeAngle = 0
local isFlyingSafe = false

local function RestoreBoatPhysics(seat)
    if not seat or not seat.Parent then return end

    local bg = seat:FindFirstChild("BodyGyro")
    if not bg or not bg:IsA("BodyGyro") then
        if bg then bg:Destroy() end
        bg = Instance.new("BodyGyro")
        bg.Name = "BodyGyro"
        bg.Parent = seat
    end
    bg.MaxTorque = Vector3.new(165942064, 165942064, 165942064)
    bg.P = 10000
    bg.D = 300
    bg.CFrame = seat.CFrame

    local bp = seat:FindFirstChild("BodyPosition")
    if not bp or not bp:IsA("BodyPosition") then
        if bp then bp:Destroy() end
        bp = Instance.new("BodyPosition")
        bp.Name = "BodyPosition"
        bp.Parent = seat
    end
    bp.MaxForce = Vector3.new(0, 165942064, 0)
    bp.P = 10000
    bp.D = 300
    local waterPlane = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WaterBase-Plane")
    local waterY = waterPlane and (waterPlane.Position.Y + (waterPlane.Size.Y / 2)) or 24
    bp.Position = Vector3.new(seat.Position.X, waterY, seat.Position.Z)

    local bv = seat:FindFirstChild("BodyVelocity")
    if not bv or not bv:IsA("BodyVelocity") then
        if bv then bv:Destroy() end
        bv = Instance.new("BodyVelocity")
        bv.Name = "BodyVelocity"
        bv.Parent = seat
    end
    bv.MaxForce = Vector3.new(165942064, 0, 165942064)
    bv.P = 10000
    bv.Velocity = Vector3.zero
end

task.spawn(function()
    while task.wait() do
        pcall(function()
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local thuyen = KiemTraThuyen()
            local vehicleSeat = thuyen and (thuyen:FindFirstChild("VehicleSeat") or thuyen:FindFirstChildWhichIsA("VehicleSeat", true))
            local mainPart = thuyen and (thuyen.PrimaryPart or vehicleSeat or thuyen:FindFirstChild("Engine"))

            local targetPart = getgenv().CurrentTargetPart or (getgenv().CurrentTarget and (getgenv().CurrentTarget:FindFirstChild("HumanoidRootPart") or getgenv().CurrentTarget.PrimaryPart))

            if _G.SafeFlyingBoat and _G.DangSan and hrp and hum and thuyen and vehicleSeat and mainPart and targetPart then
                local distToSeat = (hrp.Position - vehicleSeat.Position).Magnitude
                local isSeated = (hum.Sit and hum.SeatPart == vehicleSeat)

                if not isSeated and distToSeat > 20 then
                    isFlyingSafe = true

                    for _, v in ipairs(thuyen:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                            pcall(function()
                                v.CanTouch = false
                                v.CanQuery = false
                            end)
                        end
                    end

                    local bv = vehicleSeat:FindFirstChild("SafeFlyBV")
                    local bg = vehicleSeat:FindFirstChild("SafeFlyBG")

                    if not bv or not bg or bv.Parent ~= vehicleSeat or bg.Parent ~= vehicleSeat then
                        if bv then bv:Destroy() end
                        if bg then bg:Destroy() end

                        for _, v in pairs(vehicleSeat:GetChildren()) do
                            if (v:IsA("BodyVelocity") and v.Name ~= "SafeFlyBV") or (v:IsA("BodyPosition") and v.Name ~= "SafeFlyBP") or (v:IsA("BodyGyro") and v.Name ~= "SafeFlyBG") then
                                v:Destroy()
                            end
                        end

                        bv = Instance.new("BodyVelocity")
                        bv.Name = "SafeFlyBV"
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.P = 9e9
                        bv.Velocity = Vector3.zero
                        bv.Parent = vehicleSeat

                        bg = Instance.new("BodyGyro")
                        bg.Name = "SafeFlyBG"
                        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                        bg.P = 9e9
                        bg.D = 500
                        bg.Parent = vehicleSeat
                    end

                    dodgeAngle = dodgeAngle + (math.rad(_G.TocDoTween or 170) * 0.015)
                    if dodgeAngle >= math.pi * 2 then dodgeAngle = 0 end

                    local targetCenter = targetPart.Position
                    local rad = tonumber(_G.SafeRadius) or 100
                    local targetY = tonumber(_G.SafeHeightY) or 200

                    local orbitX = targetCenter.X + (math.cos(dodgeAngle) * rad)
                    local orbitZ = targetCenter.Z + (math.sin(dodgeAngle) * rad)
                    local orbitPos = Vector3.new(orbitX, targetY, orbitZ)

                    local currentBoatPos = mainPart.Position
                    local speed = tonumber(_G.TocDoTween) or 170

                    if currentBoatPos.Y < targetY - 10 then
                        bv.Velocity = Vector3.new(0, speed, 0)
                        local flatAngle = CFrame.Angles(0, math.atan2(vehicleSeat.CFrame.LookVector.X, vehicleSeat.CFrame.LookVector.Z), 0)
                        bg.CFrame = CFrame.new(currentBoatPos) * flatAngle
                    else
                        local toTargetVec = orbitPos - currentBoatPos
                        local distToOrbit = toTargetVec.Magnitude
                        local moveDir = distToOrbit > 0 and toTargetVec.Unit or Vector3.zero
                        
                        bv.Velocity = moveDir * speed
                        if Vector3.new(moveDir.X, 0, moveDir.Z).Magnitude > 0 then
                            bg.CFrame = CFrame.lookAt(currentBoatPos, currentBoatPos + Vector3.new(moveDir.X, 0, moveDir.Z))
                        end
                    end

                    mainPart.AssemblyLinearVelocity = bv.Velocity
                    mainPart.AssemblyAngularVelocity = Vector3.zero
                    
                    if vehicleSeat:IsA("BasePart") then
                        vehicleSeat.AssemblyLinearVelocity = bv.Velocity
                        vehicleSeat.AssemblyAngularVelocity = Vector3.zero
                    end
                else
                    if isFlyingSafe then
                        isFlyingSafe = false
                        local bv = vehicleSeat:FindFirstChild("SafeFlyBV")
                        local bg = vehicleSeat:FindFirstChild("SafeFlyBG")
                        if bv then bv:Destroy() end
                        if bg then bg:Destroy() end
                        
                        RestoreBoatPhysics(vehicleSeat)

                        for _, v in ipairs(thuyen:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.CanCollide = true
                            end
                        end
                    end
                end
            else
                if isFlyingSafe and vehicleSeat then
                    isFlyingSafe = false
                    local bv = vehicleSeat:FindFirstChild("SafeFlyBV")
                    local bg = vehicleSeat:FindFirstChild("SafeFlyBG")
                    if bv then bv:Destroy() end
                    if bg then bg:Destroy() end
                    
                    RestoreBoatPhysics(vehicleSeat)

                    if thuyen then
                        for _, v in ipairs(thuyen:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.CanCollide = true
                            end
                        end
                    end
                end
            end
        end)
    end
end)




local plr = game:GetService("Players").LocalPlayer

task.spawn(function()
    while task.wait(0.2) do
        local char = plr.Character
        if char and char:FindFirstChild("RaceEnergy") and char.RaceEnergy.Value >= 1 then
            pcall(function()
                local awakening = plr.Backpack:FindFirstChild("Awakening") or char:FindFirstChild("Awakening")
                if awakening and awakening:FindFirstChild("RemoteFunction") then
                    awakening.RemoteFunction:InvokeServer(true)
                end
            end)
        end
    end
end)


end

local function RunWeapon(...)
--[[
    FLOWBR | WEAPON KAITUN module.
    Auto-obtains the weapons selected in the user Config (loadstring).
]]
local UserConfig = ...

local WEAPON_ORDER = {
    "Saber", "Pole (1st Form)", "Bisento", "Wardens Sword", "Trident", "Magma Blaster", "Bazooka",
    "Longsword", "Gravity Blade", "Dragon Trident", "Flail", "Shizu", "Oroshi", "Saishi", "True Triple Katana",
    "Skull Guitar", "Tushita", "Canvander", "Twin Hooks", "Buddy Sword", "Venom Bow", "Hallow Scythe",
    "Soul Cane", "Dual-Headed Blade", "Pipe", "Cutlass", "Dual Katana", "Katana", "Iron Mace", "Triple Katana",
    "Slingshot", "Cannon", "Refined Slingshot", "Flintlock", "Dual Flintlock", "Musket", "Bizarre Rifle",
}

local Defaults = {
    Team = "Marines",                    -- "Marines" or "Pirates"
    Weapons = {},                        -- filled below: every weapon = true
    Hop = { MinPlayers = 6, MaxPlayers = 10 },
    Combat = {
        Weapon = "Melee",                -- tool type used to fight bosses: "Melee" / "Sword" / "Gun" / "Blox Fruit"
        TweenSpeed = 170,
        HoverHeight = 40,
    },
    WebHook = { Enable = false, Url = "", Interval = 3600 },
}
for _, w in ipairs(WEAPON_ORDER) do Defaults.Weapons[w] = true end

local function MergeConfig(def, usr)
    local out = {}
    for k, v in pairs(def) do
        local u = type(usr) == "table" and usr[k] or nil
        if type(v) == "table" then
            out[k] = MergeConfig(v, type(u) == "table" and u or nil)
        elseif u ~= nil and type(u) == type(v) then
            out[k] = u
        elseif type(v) == "number" and tonumber(u) then
            out[k] = tonumber(u)
        else
            out[k] = v
        end
    end
    return out
end
local Cfg = MergeConfig(Defaults, type(UserConfig) == "table" and UserConfig or {})
do
    local legacy
    pcall(function() legacy = (getgenv and getgenv().logs_webhook) or _G.logs_webhook end)
    if Cfg.WebHook.Url == "" and type(legacy) == "string" and legacy ~= "" then
        Cfg.WebHook.Url = legacy
        if not (type(UserConfig) == "table" and type(UserConfig.WebHook) == "table" and UserConfig.WebHook.Enable ~= nil) then
            Cfg.WebHook.Enable = true
        end
    end
end
-- selected weapons (ordered) -> internal list used by the farm loop and the UI
local SelectedWeapons = {}
for _, w in ipairs(WEAPON_ORDER) do
    local flag = type(UserConfig) == "table" and type(UserConfig.Weapons) == "table" and UserConfig.Weapons[w]
    if flag == nil then flag = true end
    if flag == true then table.insert(SelectedWeapons, w) end
end
local WeaponSeaData = { { Weapons = SelectedWeapons } }
local function WeaponEnabled(name)
    for _, w in ipairs(SelectedWeapons) do if w == name then return true end end
    return false
end
local TeamName = tostring(Cfg.Team):lower():sub(1, 3) == "pir" and "Pirates" or "Marines"
-- UI is created FIRST so it always opens, even while the rest is still loading / joining the team
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

getgenv().MainTaskStatus = "INITIALIZING..."
getgenv().SubTaskStatus = "Loading..."

local Theme = {
    Text = Color3.fromRGB(248, 240, 244),
    TextDim = Color3.fromRGB(156, 150, 160),
}
local AllWeaponsList = SelectedWeapons

-- ============================================================================
-- WEAPON STATUS UI  (farm-dashboard look: small, centered, draggable, "-" / "+" collapse button)
-- ============================================================================
local RED_DARK   = Color3.fromRGB(185, 28, 45)
local RED_DIM    = Color3.fromRGB(140, 24, 38)
local RED_LINE   = Color3.fromRGB(150, 22, 36)
local GRAY_BG    = Color3.fromRGB(30, 29, 33)
local GRAY_PANEL = Color3.fromRGB(46, 44, 50)
local GRAY_CELL  = Color3.fromRGB(60, 57, 64)
local GRAY_LINE  = Color3.fromRGB(104, 99, 110)
local BG_IMAGE   = "rbxassetid://134924508387467"

local KaitunGui = Instance.new("ScreenGui")
KaitunGui.Name = "FlowbrWeaponHub"
KaitunGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KaitunGui.ResetOnSpawn = false
KaitunGui.IgnoreGuiInset = true
do
    local parented = false
    if gethui then parented = pcall(function() KaitunGui.Parent = gethui() end) end
    if not parented or not KaitunGui.Parent then
        local ok = pcall(function() KaitunGui.Parent = CoreGui end)
        if not ok or not KaitunGui.Parent then KaitunGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
    end
end

local WIN_W, HEADER_H, LIST_H = 290, 38, 150
local BODY_H = 10 + 44 + 6 + 28 + 8 + LIST_H + 10
local WIN_H = HEADER_H + BODY_H

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(WIN_W, WIN_H)
MainFrame.Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2)
MainFrame.BackgroundColor3 = GRAY_BG
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = KaitunGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
do
    local st = Instance.new("UIStroke", MainFrame)
    st.Color = RED_LINE
    st.Thickness = 1.6
    local bg = Instance.new("ImageLabel")
    bg.Name = "Bg"
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundTransparency = 1
    bg.Image = BG_IMAGE
    bg.ScaleType = Enum.ScaleType.Crop
    bg.Parent = MainFrame
    local dim = Instance.new("Frame")
    dim.Name = "Dim"
    dim.Size = UDim2.fromScale(1, 1)
    dim.BackgroundColor3 = Color3.new(0, 0, 0)
    dim.BackgroundTransparency = 0.45
    dim.BorderSizePixel = 0
    dim.Parent = MainFrame
end

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.fromOffset(WIN_W, HEADER_H)
Header.BackgroundTransparency = 1
Header.Active = true
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.fromOffset(14, 0)
Title.BackgroundTransparency = 1
Title.Text = "flowbr | weapon kaitun"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextColor3 = RED_DARK
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.fromOffset(WIN_W, 1)
HeaderLine.Position = UDim2.fromOffset(0, HEADER_H - 1)
HeaderLine.BackgroundColor3 = GRAY_LINE
HeaderLine.BackgroundTransparency = 0.4
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local CollapseBtn = Instance.new("TextButton")
CollapseBtn.Size = UDim2.fromOffset(30, 24)
CollapseBtn.Position = UDim2.fromOffset(WIN_W - 40, 7)
CollapseBtn.BackgroundColor3 = GRAY_PANEL
CollapseBtn.AutoButtonColor = false
CollapseBtn.Text = "-"
CollapseBtn.Font = Enum.Font.GothamBold
CollapseBtn.TextSize = 18
CollapseBtn.TextColor3 = RED_DARK
CollapseBtn.Parent = Header
Instance.new("UICorner", CollapseBtn).CornerRadius = UDim.new(0, 8)
do
    local st = Instance.new("UIStroke", CollapseBtn)
    st.Color = RED_LINE
    st.Thickness = 1.2
end

local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Position = UDim2.fromOffset(0, HEADER_H)
Body.Size = UDim2.fromOffset(WIN_W, BODY_H)
Body.BackgroundTransparency = 1
Body.Parent = MainFrame

-- task block
local StatusCard = Instance.new("Frame")
StatusCard.Position = UDim2.fromOffset(10, 10)
StatusCard.Size = UDim2.fromOffset(WIN_W - 20, 44)
StatusCard.BackgroundColor3 = GRAY_PANEL
StatusCard.BackgroundTransparency = 0.1
StatusCard.BorderSizePixel = 0
StatusCard.Parent = Body
Instance.new("UICorner", StatusCard).CornerRadius = UDim.new(0, 8)

local MainTaskLbl = Instance.new("TextLabel")
MainTaskLbl.Size = UDim2.new(1, -20, 0, 22)
MainTaskLbl.Position = UDim2.fromOffset(10, 3)
MainTaskLbl.BackgroundTransparency = 1
MainTaskLbl.Text = "Main: " .. tostring(getgenv().MainTaskStatus)
MainTaskLbl.Font = Enum.Font.GothamBold
MainTaskLbl.TextSize = 12
MainTaskLbl.TextColor3 = Theme.Text
MainTaskLbl.TextTruncate = Enum.TextTruncate.AtEnd
MainTaskLbl.TextXAlignment = Enum.TextXAlignment.Left
MainTaskLbl.Parent = StatusCard

local SubTaskLbl = Instance.new("TextLabel")
SubTaskLbl.Size = UDim2.new(1, -20, 0, 16)
SubTaskLbl.Position = UDim2.fromOffset(10, 24)
SubTaskLbl.BackgroundTransparency = 1
SubTaskLbl.Text = "Sub: " .. tostring(getgenv().SubTaskStatus)
SubTaskLbl.Font = Enum.Font.GothamMedium
SubTaskLbl.TextSize = 11
SubTaskLbl.TextColor3 = Theme.TextDim
SubTaskLbl.TextTruncate = Enum.TextTruncate.AtEnd
SubTaskLbl.TextXAlignment = Enum.TextXAlignment.Left
SubTaskLbl.Parent = StatusCard

-- owned / missing
local function StatCell(x, w, caption)
    local cell = Instance.new("Frame")
    cell.Position = UDim2.fromOffset(x, 10 + 44 + 6)
    cell.Size = UDim2.fromOffset(w, 28)
    cell.BackgroundColor3 = GRAY_CELL
    cell.BackgroundTransparency = 0.2
    cell.BorderSizePixel = 0
    cell.Parent = Body
    Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 7)
    local c = Instance.new("TextLabel")
    c.Size = UDim2.new(0.45, 0, 1, 0)
    c.Position = UDim2.fromOffset(8, 0)
    c.BackgroundTransparency = 1
    c.Text = caption
    c.Font = Enum.Font.GothamMedium
    c.TextSize = 11
    c.TextColor3 = RED_DARK
    c.TextXAlignment = Enum.TextXAlignment.Left
    c.Parent = cell
    local v = Instance.new("TextLabel")
    v.Size = UDim2.new(0.55, -8, 1, 0)
    v.Position = UDim2.new(0.45, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.Text = "-"
    v.Font = Enum.Font.GothamBold
    v.TextSize = 12
    v.TextColor3 = Theme.Text
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.Parent = cell
    return v
end
local half = (WIN_W - 20 - 6) / 2
local ProgValue = StatCell(10, half, "Owned:")
local MissingValue = StatCell(10 + half + 6, half, "Missing:")
ProgValue.Text = "0 / " .. tostring(#AllWeaponsList)
MissingValue.Text = tostring(#AllWeaponsList)

-- weapon list
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Position = UDim2.fromOffset(10, 10 + 44 + 6 + 28 + 8)
ListFrame.Size = UDim2.fromOffset(WIN_W - 20, LIST_H)
ListFrame.BackgroundColor3 = GRAY_PANEL
ListFrame.BackgroundTransparency = 0.25
ListFrame.BorderSizePixel = 0
ListFrame.ScrollBarThickness = 3
ListFrame.ScrollBarImageColor3 = RED_DARK
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ListFrame.Parent = Body
Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 8)
do
    local lay = Instance.new("UIListLayout", ListFrame)
    lay.Padding = UDim.new(0, 3)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", ListFrame)
    pad.PaddingTop = UDim.new(0, 5)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 5)
end

local WeaponRows = {}
for i, name in ipairs(AllWeaponsList) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 20)
    row.BackgroundTransparency = 1
    row.LayoutOrder = i
    row.Parent = ListFrame
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0.68, 0, 1, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.Font = Enum.Font.GothamMedium
    nameLbl.TextSize = 12
    nameLbl.TextColor3 = Theme.TextDim
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.Parent = row
    local stLbl = Instance.new("TextLabel")
    stLbl.Size = UDim2.new(0.32, 0, 1, 0)
    stLbl.Position = UDim2.new(0.68, 0, 0, 0)
    stLbl.BackgroundTransparency = 1
    stLbl.Text = "MISSING"
    stLbl.Font = Enum.Font.GothamBold
    stLbl.TextSize = 10
    stLbl.TextColor3 = Color3.fromRGB(200, 90, 90)
    stLbl.TextXAlignment = Enum.TextXAlignment.Right
    stLbl.Parent = row
    WeaponRows[name] = { name = nameLbl, status = stLbl }
end

-- drag (header) - mouse + touch
do
    local dragging, dragStart, startPos, dragInput
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local d = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

local expanded = true
CollapseBtn.MouseButton1Click:Connect(function()
    expanded = not expanded
    Body.Visible = expanded
    HeaderLine.Visible = expanded
    CollapseBtn.Text = expanded and "-" or "+"
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.fromOffset(WIN_W, expanded and WIN_H or HEADER_H) }):Play()
end)

task.spawn(function()
    while task.wait(0.3) do
        if not KaitunGui.Parent then break end
        MainTaskLbl.Text = "Main: " .. tostring(getgenv().MainTaskStatus)
        SubTaskLbl.Text = "Sub: " .. tostring(getgenv().SubTaskStatus)
    end
end)

local WeaponUI_API = {
    SetOwned = function(val, total)
        local txt = tostring(val) .. " / " .. tostring(total)
        if ProgValue.Text ~= txt then ProgValue.Text = txt end
    end,
    SetMissing = function(val)
        local txt = tostring(val)
        if MissingValue.Text ~= txt then MissingValue.Text = txt end
    end
}


local Services = setmetatable({}, {__index = function(self, name)
    local s, c = pcall(function() return cloneref(game:GetService(name)) end)
    if s then rawset(self, name, c) return c
    else error("Invalid Roblox Service: " .. tostring(name))
    end
end})
pcall(function()
    -- [INLINE Weapon Tween/TP — original: https://pastefy.app/aBWBIAry/raw]
(function() --begin Weapon Tween/TP

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local CommF_ = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

local place_check = game.PlaceId
local sea1 = (place_check == 2753915549 or place_check == 85211729168715)
local sea2 = (place_check == 4442272183 or place_check == 79091703265657)
local sea3 = (place_check == 7449423635 or place_check == 100117331123089)
local newsea = (place_check == 73902483975735)

if not (sea1 or sea2 or sea3 or newsea) then
    LocalPlayer:Kick("You are not in the correct game!")
end

local SeaIndex = sea3 and 3 or sea2 and 2 or sea1 and 1 or newsea and 4

---------
-- BIẾN HỖ TRỢ VÀ TỌA ĐỘ
---------
local newdao = CFrame.new(10641.09, -1953.92, 9825.07)
local cframenpc = CFrame.new(-16271.12, 25.58, 1371.98)

local currentTweenId = 0
local TPLoop = nil
local NoclipLoop = nil
local TP_Speed = Cfg.Combat.TweenSpeed

_G.Config_ = _G.Config_ or {}

---------
-- HÀM TIỆN ÍCH (UTILITIES)
---------
local function GetTargetCFrame(Target)
    if typeof(Target) == "CFrame" then
        return Target
    elseif typeof(Target) == "Vector3" then
        return CFrame.new(Target)
    elseif typeof(Target) == "Instance" then
        if Target:IsA("BasePart") then
            return Target.CFrame
        elseif Target:IsA("Model") and Target.PrimaryPart then
            return Target.PrimaryPart.CFrame
        elseif Target:IsA("Player") and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
            return Target.Character.HumanoidRootPart.CFrame
        end
    end
    return nil
end

local function GetDistance(Target, IgnoreY)
    local targetPos = GetTargetCFrame(Target)
    if not targetPos then return math.huge end
    
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return math.huge end
    
    if IgnoreY then
        return (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(targetPos.Position.X, 0, targetPos.Position.Z)).Magnitude
    end
    return (hrp.Position - targetPos.Position).Magnitude
end

local function WaitForHumanoid()
    local character = LocalPlayer.Character
    if not character then return nil end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then return humanoid end
    
    local timeout = tick() + 5
    while tick() < timeout do
        humanoid = character:FindFirstChild("Humanoid")
        if humanoid then return humanoid end
        task.wait(0.1)
    end
    return nil
end

local function CheckItem(ITEM_NAME)
    for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA('Tool') and string.find(v.Name, ITEM_NAME) then return v end
    end
    local character = LocalPlayer.Character
    if character then
        for _, v in pairs(character:GetChildren()) do
            if v:IsA('Tool') and string.find(v.Name, ITEM_NAME) then return v end
        end
    end
    return nil
end

local function CheckLegendaryItems()
    local items = {"God's Chalice", "Fist of Darkness", "Sweet Chalice", "Hallow Essence", "Flower1", "Flower2", "Flower3", "Fire Essence", "Sweet Chalice"}
    for _, item in ipairs(items) do
        if CheckItem(item) then return true end
    end
    return false
end

local function InArea(POS)
    local targetCFrame = GetTargetCFrame(POS)
    if not targetCFrame then return {Name = ""} end
    
    local WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
    if not WorldOrigin or not WorldOrigin:FindFirstChild("Locations") then return {Name = ""} end
    
    for _, v in pairs(WorldOrigin.Locations:GetChildren()) do
        if v:FindFirstChild("Mesh") and (targetCFrame.Position - v.Position).Magnitude <= v.Mesh.Scale.X then
            return v
        end
    end
    return {Name = ""}
end

local function GetSpawnPoint(x)
    local origin = workspace:FindFirstChild("_WorldOrigin")
    if not origin then return nil end
    local spawns = origin:FindFirstChild("PlayerSpawns") and origin.PlayerSpawns:FindFirstChild("Pirates")
    if not spawns then return nil end
    
    for _, v in pairs(spawns:GetChildren()) do
        if (v.Part.Position - x.Position).Magnitude <= 2500 then
            return v
        end
    end
    return nil
end



local function RequestEntrance(targetPos)
    local targetCFrame = GetTargetCFrame(targetPos)
    if not targetCFrame then return end
    
    local tpPoints = {}
    if SeaIndex == 1 then
        tpPoints = {
            ["Sky3"] = Vector3.new(-7894, 5547, -380),
            ["Sky3Exit"] = Vector3.new(-4607, 874, -1667),
            ["UnderWater"] = Vector3.new(61163, 11, 1819),
            ["UnderwaterExit"] = Vector3.new(4050, -1, -1814)
        }
    elseif SeaIndex == 2 then
        tpPoints = {
            ["Swan Mansion"] = Vector3.new(-390, 332, 673),
            ["Swan Room"] = Vector3.new(2285, 15, 905),
            ["Cursed Ship"] = Vector3.new(923, 126, 32852),
            ["Zombie Island"] = Vector3.new(-6509, 83, -133)
        }
    elseif SeaIndex == 3 then
        tpPoints = {
            ["Hydra Island"] = Vector3.new(5657.88, 1013.07, -335.49),
            ["Mansion"] = Vector3.new(-12462, 375, -7552),
            ["Castle"] = Vector3.new(-5036, 315, -3179),
            ["Temple of Time"] = Vector3.new(28286, 14897, 103),
            ["Greate Tree"] = Vector3.new(3024.17, 2280.69, -7325.12)
        }
    end
    
    local closestPoint, minDistance = nil, math.huge
    for _, pos in pairs(tpPoints) do
        local dist = (pos - targetCFrame.Position).Magnitude
        if dist < minDistance then
            minDistance = dist
            closestPoint = pos
        end
    end
    
    if closestPoint and minDistance < GetDistance(targetCFrame) then
        CollectionService:AddTag(LocalPlayer, "Teleporting")
        CommF_:InvokeServer("requestEntrance", closestPoint)
        task.wait(1)
        CollectionService:RemoveTag(LocalPlayer, "Teleporting")
    end
end

local function EnableNoclip(hrp)
    if not NoclipLoop then
        NoclipLoop = RunService.Stepped:Connect(function()
            local character = LocalPlayer.Character
            if character then
                for _, v in pairs(character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        end)
    end
end

local function DisableNoclip(hrp)
    if hrp then
        local align = hrp:FindFirstChild("TP_Align")
        if align then
            align.Enabled = false
        end
    end
    
    if NoclipLoop then
        NoclipLoop:Disconnect()
        NoclipLoop = nil
    end
end
function old_tp(TargetInput)
    local targetCFrame = GetTargetCFrame(TargetInput)
    if not targetCFrame then return end
    
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end

    currentTweenId = currentTweenId + 1
    local thisTween = currentTweenId
    
    if TPLoop then TPLoop:Disconnect() end

    EnableNoclip(hrp)
    
    local isBoat = humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat")
    if not isBoat then
        humanoid.PlatformStand = true
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    end
    
    local alignPosition = hrp:FindFirstChild("TP_Align")
    local targetAttachment = workspace.Terrain:FindFirstChild("TP_TargetAtt")
    local rootAttachment = hrp:FindFirstChild("TP_RootAtt")
    
    if not alignPosition then
        if targetAttachment then targetAttachment:Destroy() end
        if rootAttachment then rootAttachment:Destroy() end
        
        targetAttachment = Instance.new("Attachment")
        targetAttachment.Name = "TP_TargetAtt"
        targetAttachment.Parent = workspace.Terrain
        
        rootAttachment = Instance.new("Attachment")
        rootAttachment.Name = "TP_RootAtt"
        rootAttachment.Parent = hrp
        
        alignPosition = Instance.new("AlignPosition")
        alignPosition.Name = "TP_Align"
        alignPosition.Mode = Enum.PositionAlignmentMode.TwoAttachment
        alignPosition.Attachment0 = rootAttachment
        alignPosition.Attachment1 = targetAttachment
        alignPosition.MaxForce = 9e99
        alignPosition.MaxVelocity = TP_Speed or 250
        alignPosition.Responsiveness = 200
        alignPosition.ApplyAtCenterOfMass = true
        alignPosition.Parent = hrp
    end

    targetAttachment.WorldPosition = targetCFrame.Position
    alignPosition.MaxVelocity = TP_Speed or 250
    alignPosition.Enabled = true

    TPLoop = RunService.Heartbeat:Connect(function(deltaTime)
        if currentTweenId ~= thisTween then
            if TPLoop then TPLoop:Disconnect() end
            return
        end
        
        local currentTarget = GetTargetCFrame(TargetInput)
        if not currentTarget or humanoid.Health <= 0 then
            DisableNoclip(hrp)
            local isBoatNow = humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat")
            if not isBoatNow then
                humanoid.PlatformStand = false
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            if TPLoop then TPLoop:Disconnect() end
            return
        end

        local currentPos = hrp.Position
        local finalPos = currentTarget.Position
        local distance = (finalPos - currentPos).Magnitude
        
        if distance <= 10 then
            hrp.CFrame = currentTarget
            DisableNoclip(hrp)
            local isBoatNow = humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat")
            if not isBoatNow then
                humanoid.PlatformStand = false
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            if TPLoop then TPLoop:Disconnect() end
            return
        end
        
        hrp.AssemblyAngularVelocity = Vector3.zero
        
        targetAttachment.WorldPosition = finalPos
        alignPosition.MaxVelocity = TP_Speed or 250
    end)
    
    return thisTween
end
---------
getgenv().TP = function(TargetInput, ...)
    local targetCFrame = GetTargetCFrame(TargetInput)
    if not targetCFrame then return end
    
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local currentArea = InArea(hrp.Position).Name
    local targetArea = InArea(targetCFrame).Name

    local isRisk = false
    pcall(function()
        local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if mainGui then
            for _, v in pairs(mainGui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible and string.find(string.lower(v.Text), "risk") then
                    isRisk = true
                    break
                end
            end
        end
    end)

    local tpPoints = {}
    if SeaIndex == 1 then
        tpPoints = {
            ["Sky3"] = Vector3.new(-7894, 5547, -380),
            ["Sky3Exit"] = Vector3.new(-4607, 874, -1667),
            ["UnderWater"] = Vector3.new(61163, 11, 1819),
            ["UnderwaterExit"] = Vector3.new(4050, -1, -1814)
        }
    elseif SeaIndex == 2 then
        tpPoints = {
            ["Swan Mansion"] = Vector3.new(-390, 332, 673),
            ["Swan Room"] = Vector3.new(2285, 15, 905),
            ["Cursed Ship"] = Vector3.new(923, 126, 32852),
            ["Zombie Island"] = Vector3.new(-6509, 83, -133)
        }
    elseif SeaIndex == 3 then
        tpPoints = {
            ["Hydra Island"] = Vector3.new(5657.88, 1013.07, -335.49),
            ["Mansion"] = Vector3.new(-12462, 375, -7552),
            ["Castle"] = Vector3.new(-5036, 315, -3179),
            ["Temple of Time"] = Vector3.new(28286, 14897, 103),
            ["Greate Tree"] = Vector3.new(3024.17, 2280.69, -7325.12)
        }
    end

    local entranceDist = math.huge
    local distToClosestEntrance = math.huge

    for _, pos in pairs(tpPoints) do
        local distTarget = (pos - targetCFrame.Position).Magnitude
        if distTarget < entranceDist then
            entranceDist = distTarget
        end
        
        local distPlayer = (pos - hrp.Position).Magnitude
        if distPlayer < distToClosestEntrance then
            distToClosestEntrance = distPlayer
        end
    end

    local currentDist = (hrp.Position - targetCFrame.Position).Magnitude
    local useEntrance = false

    if currentArea == targetArea and targetArea ~= "" then
        useEntrance = false
    else
        if entranceDist < currentDist then
            useEntrance = true
        end
    end

    if distToClosestEntrance < 1000 then
        useEntrance = false
    end

    if useEntrance then
        RequestEntrance(targetCFrame)
        task.wait(0.5)
    end
    
    if SeaIndex == 3 and GetDistance(newdao.Position) < 2000 then
        hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and math.abs(newdao.Position.Y - hrp.CFrame.Y) > 1000 then
            repeat
                task.wait()
                old_tp(cframenpc)
                if GetDistance(cframenpc) < 10 then
                    local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
                    if net then
                        net["RF/SubmarineWorkerSpeak"]:InvokeServer("AskKilledTikiBoss")
                        task.wait(0.5)
                        net["RF/SubmarineWorkerSpeak"]:InvokeServer("TravelToSubmergedIsland")
                    end
                end
            until GetDistance(targetCFrame) < 2000
            task.wait(0.6)
            if hrp:FindFirstChild("TP_BodyVelocity") then
                hrp.TP_BodyVelocity:Destroy()
            end
        end
    end
    
    return old_tp(TargetInput, ...)
end
---------
---------
getgenv().stoptp = function()
    currentTweenId = currentTweenId + 1 
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    DisableNoclip(hrp)
end

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

print("Tp Engine Optimized - Loaded successfully!")
end)() --end Weapon Tween/TP
end)
replicated = game.ReplicatedStorage
local plr = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local HttpService = game:GetService("HttpService")

    local LocalPlayer = Players.LocalPlayer
    local RS = ReplicatedStorage


getgenv().CachedJobIds = {}
getgenv().ScanPage = 15
getgenv().UseApiFallback = false
getgenv().IsScanning = false

local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local function StartBackgroundScan(minP, maxP)
    if getgenv().IsScanning or (#getgenv().CachedJobIds > 0) or getgenv().UseApiFallback then return end
    getgenv().IsScanning = true
    getgenv().ScanPage = 15
    
    task.spawn(function()
        local minPlayers = minP or 6
        local maxPlayers = maxP or 10
        local maxPages = 150
        
        while getgenv().IsScanning and getgenv().ScanPage <= maxPages do
            local success, servers = pcall(function()
                return RS:WaitForChild("__ServerBrowser"):InvokeServer(getgenv().ScanPage)
            end)

            if success and type(servers) == "table" then
                for jobId, serverData in pairs(servers) do
                    if type(serverData) == "table" and jobId ~= game.JobId and serverData["Count"] and serverData["Count"] > minPlayers and serverData["Count"] < maxPlayers then
                        local alreadyExists = false
                        for _, id in ipairs(getgenv().CachedJobIds) do
                            if id == jobId then alreadyExists = true break end
                        end
                        
                        if not alreadyExists then
                            table.insert(getgenv().CachedJobIds, jobId)
                        end
                        
                        -- Lưu tối đa 5 server để dành, đủ rồi thì ngắt quét ngầm cho mượt
                        if #getgenv().CachedJobIds >= 5 then
                            getgenv().IsScanning = false
                            return
                        end
                    end
                end
            end

            getgenv().ScanPage = getgenv().ScanPage + 1
            task.wait()
        end
        
        if getgenv().ScanPage > maxPages and #getgenv().CachedJobIds == 0 then
            getgenv().UseApiFallback = true
            getgenv().IsScanning = false
        end
    end)
end
StartBackgroundScan(6, 10)

local function HopServer(minP, maxP)
    if getgenv().IsHopping then return end
    getgenv().IsHopping = true
    getgenv().HopMinP = minP or Cfg.Hop.MinPlayers
    getgenv().HopMaxP = maxP or Cfg.Hop.MaxPlayers
    getgenv().HopServerFunc = HopServer 
    
    getgenv().MainTaskStatus = "SERVER HOPPING"

    task.spawn(function()
        while #getgenv().CachedJobIds == 0 and not getgenv().UseApiFallback do
            getgenv().SubTaskStatus = "Searching Server (Page " .. tostring(getgenv().ScanPage) .. ")"
            task.wait(0.1)
        end

        if getgenv().UseApiFallback then
            getgenv().SubTaskStatus = "Using API Fallback..."
            pcall(function()
                local servers = HttpService:JSONDecode(
                    game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
                ).data
                for _, server in pairs(servers) do
                    if server.playing < getgenv().HopMaxP and server.id ~= game.JobId then
                        RS:WaitForChild("__ServerBrowser"):InvokeServer("teleport", server.id)
                        task.wait(4)
                        break
                    end
                end
            end)
        elseif #getgenv().CachedJobIds > 0 then
            getgenv().SubTaskStatus = "Teleporting..."
            
            while #getgenv().CachedJobIds > 0 do
                local targetJobId = table.remove(getgenv().CachedJobIds, 1)
                pcall(function()
                    RS:WaitForChild("__ServerBrowser"):InvokeServer("teleport", targetJobId)
                end)
                
                task.wait(2)
            end
        end

        task.wait(2)
        if getgenv().IsHopping then
            getgenv().IsHopping = false
            StartBackgroundScan(getgenv().HopMinP, getgenv().HopMaxP)
        end
    end)
end
---------
    local function StartAttack()
        task.spawn(function()
        -- [INLINE FastAttack — original: https://pastefy.app/45hCw1JE/raw]
(function() --begin FastAttack
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Modules = ReplicatedStorage:FindFirstChild("Modules")
local Net = Modules and Modules:FindFirstChild("Net")
local RegisterAttack = Net and Net:FindFirstChild("RE/RegisterAttack")
local RegisterHit = Net and Net:FindFirstChild("RE/RegisterHit")
local ShootGunEvent = Net and Net:FindFirstChild("RE/ShootGunEvent")
local GunValidator = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Validator2")

local LocalPlayer = Players.LocalPlayer
local NetModule
pcall(function()
    if Modules and Modules:FindFirstChild("Net") then
        NetModule = require(Modules.Net)
    end
end)

local Remotes = {}
local Assets = ReplicatedStorage:WaitForChild("Assets")

local RemoteFolder = ReplicatedStorage:FindFirstChild("Remotes")
if RemoteFolder then
    for _, child in ipairs(RemoteFolder:GetChildren()) do
        if child:IsA("RemoteEvent") then
            local id = child:GetAttribute("Id")
            if id then
                Remotes[id] = child
            end
        end
    end

    RemoteFolder.ChildAdded:Connect(function(child)
        if child:IsA("RemoteEvent") then
            local id = child:GetAttribute("Id")
            if id then
                Remotes[id] = child
            end
        end
    end)
end

local KillTrap = {
    LockedTargets = {}, 
    StuckTimeout = 1.5
}

function KillTrap:Process(enemy)
    local hum = enemy:FindFirstChild("Humanoid")
    if not hum then 
        if self.LockedTargets[enemy] then
            self.LockedTargets[enemy] = nil
        end
        return false 
    end
    
    local currentHealth = hum.Health
    local data = self.LockedTargets[enemy]

    if currentHealth <= 0 then
        if self.LockedTargets[enemy] then
            self.LockedTargets[enemy] = nil
        end
        return false
    end

    if not data then
        self.LockedTargets[enemy] = {
            lastHealth = currentHealth,
            lastChangeTime = tick()
        }
        return true
    end

    if currentHealth < data.lastHealth then
        data.lastHealth = currentHealth
        data.lastChangeTime = tick()
        return true
    elseif currentHealth == data.lastHealth then
        if tick() - data.lastChangeTime > self.StuckTimeout then
            self.LockedTargets[enemy] = nil
            return false
        end
        return true
    else
        data.lastHealth = currentHealth
        data.lastChangeTime = tick()
        return true
    end
end

---------
local function GetClosestEnemy()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local closestEnemy = nil
    local shortestDistance = math.huge

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    local charsFolder = workspace:FindFirstChild("Characters")
    local seaBeastsFolder = workspace:FindFirstChild("SeaBeasts")
    
    local function Scan(folder)
        if not folder then return end
        for _, enemy in ipairs(folder:GetChildren()) do
            if enemy:IsA("Model") and enemy ~= character then
                local n = enemy.Name
                local isSeaBeast = (folder.Name == "SeaBeasts") or n:find("SeaBeast") or n == "Leviathan Segment" or n == "Leviathan"
                local isShip = n:find("PirateBrigade") or n:find("PirateGrandBrigade") or n:find("Brigade")
                
                if isSeaBeast then
                    local pivotSuccess, pivot = pcall(function() return enemy:GetPivot() end)
                    if pivotSuccess and pivot then
                        local dist = (rootPart.Position - pivot.Position).Magnitude
                        if dist <= 6000 and dist < shortestDistance then
                            closestEnemy = enemy
                            shortestDistance = dist
                        end
                    end
                elseif isShip then
                    local healthVal = enemy:FindFirstChild("Health")
                    if healthVal and healthVal.Value > 0 then
                        local pivotSuccess, pivot = pcall(function() return enemy:GetPivot() end)
                        if pivotSuccess and pivot then
                            local dist = (rootPart.Position - pivot.Position).Magnitude
                            if dist <= 6000 and dist < shortestDistance then
                                closestEnemy = enemy
                                shortestDistance = dist
                            end
                        end
                    end
                else
                    local root = enemy:FindFirstChild("HumanoidRootPart")
                    local hum = enemy:FindFirstChild("Humanoid")
                    if root and hum and hum.Health > 0 then
                        local dist = (rootPart.Position - root.Position).Magnitude
                        if dist <= 6000 then
                            KillTrap:Process(enemy)
                        end
                    end
                end
            end
        end
    end

    Scan(enemiesFolder)
    Scan(seaBeastsFolder)
    Scan(charsFolder)

    for enemy, _ in pairs(KillTrap.LockedTargets) do
        if KillTrap:Process(enemy) then
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
            if enemyRoot then
                local distance = (rootPart.Position - enemyRoot.Position).Magnitude
                if distance < shortestDistance then
                    closestEnemy = enemy
                    shortestDistance = distance
                end
            end
        end
    end
    
    return closestEnemy
end

local function Attack()
    local character = LocalPlayer.Character
    if not character then return end
    
    ---------
    local tool = character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    ---------
    if not tool or tool:GetAttribute("WeaponType") ~= "Melee" then return end

    local enemy = GetClosestEnemy()
    if enemy then
        local regAttack = Remotes["RE/RegisterAttack"] or RegisterAttack
        if regAttack then
            regAttack:FireServer()
        end

        local hitPart = enemy:FindFirstChild("Head") or enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart or enemy:FindFirstChildWhichIsA("BasePart")
        if hitPart then
            local regHit = Remotes["RE/RegisterHit"] or RegisterHit
            if regHit then
                regHit:FireServer(enemy, hitPart)
            end
            if NetModule and NetModule.RemoteEvent then
                NetModule:RemoteEvent("RegisterHit"):FireServer(enemy, hitPart)
            end
        end
    end
end

local function GetBladeHits()
    local targets = {}
    local char = game.Players.LocalPlayer.Character
    if not char then return targets end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return targets end

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    local charsFolder = workspace:FindFirstChild("Characters")
    local seaBeastsFolder = workspace:FindFirstChild("SeaBeasts")
    
    local function CheckFolder(folder)
        if not folder then return end
        for _, v in pairs(folder:GetChildren()) do
            if v:IsA("Model") and v ~= char then
                local n = v.Name
                local isSeaBeast = (folder.Name == "SeaBeasts") or n:find("SeaBeast") or n == "Leviathan Segment" or n == "Leviathan"
                local isShip = n:find("PirateBrigade") or n:find("PirateGrandBrigade") or n:find("Brigade")

                if isSeaBeast then
                    local pivotSuccess, pivot = pcall(function() return v:GetPivot() end)
                    if pivotSuccess and pivot then
                        if (pivot.Position - root.Position).Magnitude <= 6000 then
                            table.insert(targets, v)
                        end
                    end
                elseif isShip then
                    local healthVal = v:FindFirstChild("Health")
                    if healthVal and healthVal.Value > 0 then
                        local pivotSuccess, pivot = pcall(function() return v:GetPivot() end)
                        if pivotSuccess and pivot then
                            if (pivot.Position - root.Position).Magnitude <= 6000 then
                                table.insert(targets, v)
                            end
                        end
                    end
                elseif v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
                    local dist = (v.HumanoidRootPart.Position - root.Position).Magnitude
                    if dist <= 6000 then
                        KillTrap:Process(v)
                    end
                end
            end
        end
    end

    CheckFolder(enemiesFolder)
    CheckFolder(seaBeastsFolder)
    CheckFolder(charsFolder)

    for enemy, _ in pairs(KillTrap.LockedTargets) do
        if KillTrap:Process(enemy) then
            table.insert(targets, enemy)
        end
    end

    return targets
end

local function AttackAll()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end

    ---------
    local equippedWeapon = character:FindFirstChild("EquippedWeapon") or player.Backpack:FindFirstChildOfClass("Tool")
    ---------
    if not equippedWeapon then return end

    local regAttack = Remotes["RE/RegisterAttack"] or RegisterAttack
    local regHit = Remotes["RE/RegisterHit"] or RegisterHit
    
    local enemies = GetBladeHits()
    if #enemies > 0 then
        if regAttack then
            regAttack:FireServer(-math.huge)
        end
        
        local args = {nil, {}}
        for i, v in pairs(enemies) do
            local hitPart = v:FindFirstChild("Head") or v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
            if not args[1] then
                args[1] = hitPart
            end
            args[2][i] = {v, hitPart}
        end
        
        if args[1] and regHit then
            regHit:FireServer(unpack(args))
        end
    end
end
---------

---------
RunService.Stepped:Connect(function()
    AttackAll()
end)
---------

local Config = {
    AttackDistance = 65,
    AttackMobs = true,
    AttackPlayers = true,
    AttackCooldown = 0,
    ComboResetTime = 0,
    MaxCombo = 2,
    HitboxLimbs = {"RightLowerArm", "RightUpperArm", "LeftLowerArm", "LeftUpperArm", "RightHand", "LeftHand"},
    AutoClickEnabled = true
}

local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        Debounce = 0,
        ComboDebounce = 0,
        ShootDebounce = 0,
        M1Combo = 0,
        EnemyRootPart = nil,
        Connections = {},
        Overheat = {Dragonstorm = {MaxOverheat = 3, Cooldown = 0, TotalOverheat = 0, Distance = 350, Shooting = false}},
        ShootsPerTarget = {["Dual Flintlock"] = 2},
        SpecialShoots = {["Skull Guitar"] = "TAP", ["Bazooka"] = "Position", ["Cannon"] = "Position", ["Dragonstorm"] = "Overheat"}
    }, FastAttack)
    
    pcall(function()
        local CombatController = require(ReplicatedStorage.Controllers.CombatController)
        if getupvalue then
            self.ShootFunction = getupvalue(CombatController.Attack, 9)
        end
        
        local Flags = Modules:FindFirstChild("Flags")
        if Flags then
            self.CombatFlags = require(Flags).COMBAT_REMOTE_THREAD
        end

        local LocalScript = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if LocalScript and getsenv then
            local env = getsenv(LocalScript)
            if env._G and env._G.SendHitsToServer then
                self.HitFunction = env._G.SendHitsToServer
            end
        end
    end)
    
    return self
end

function FastAttack:IsEntityAlive(entity)
    local humanoid = entity and entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

function FastAttack:CheckStun(Character, Humanoid, ToolTip)
    local Stun = Character:FindFirstChild("Stun")
    local Busy = Character:FindFirstChild("Busy")
    if Humanoid.Sit and (ToolTip == "Sword" or ToolTip == "Melee" or ToolTip == "Blox Fruit") then
        return false
    elseif (Stun and Stun.Value > 0) or (Busy and Busy.Value) then
        return false
    end
    return true
end

function FastAttack:GetBladeHits(Character, Distance)
    local Position = Character:GetPivot().Position
    local BladeHits = {}
    local MaxDist = Distance or 6000
    
    local function ScanForNewTargets(Folder)
        if not Folder then return end
        for _, Enemy in ipairs(Folder:GetChildren()) do
            if Enemy ~= Character then
                local n = Enemy.Name
                local isSeaBeast = (Folder.Name == "SeaBeasts") or n:find("SeaBeast") or n == "Leviathan Segment" or n == "Leviathan"
                local isShip = n:find("PirateBrigade") or n:find("PirateGrandBrigade") or n:find("Brigade")
                
                if isSeaBeast or isShip then
                    local pivotSuccess, pivot = pcall(function() return Enemy:GetPivot() end)
                    if pivotSuccess and pivot then
                        if (Position - pivot.Position).Magnitude <= MaxDist then
                            local BasePart = Enemy:FindFirstChild("Head") or Enemy:FindFirstChild("Hitbox") or Enemy:FindFirstChild("HumanoidRootPart") or Enemy.PrimaryPart or Enemy:FindFirstChildWhichIsA("BasePart")
                            if BasePart then
                                if not self.EnemyRootPart then
                                    self.EnemyRootPart = BasePart
                                else
                                    table.insert(BladeHits, {Enemy, BasePart})
                                end
                            end
                        end
                    end
                elseif self:IsEntityAlive(Enemy) then
                    local root = Enemy:FindFirstChild("HumanoidRootPart")
                    if root and (Position - root.Position).Magnitude <= MaxDist then
                        KillTrap:Process(Enemy)
                    end
                end
            end
        end
    end

    if Config.AttackMobs then 
        ScanForNewTargets(Workspace:FindFirstChild("Enemies")) 
        ScanForNewTargets(Workspace:FindFirstChild("SeaBeasts")) 
    end
    if Config.AttackPlayers then ScanForNewTargets(Workspace:FindFirstChild("Characters")) end

    for Enemy, _ in pairs(KillTrap.LockedTargets) do
        if KillTrap:Process(Enemy) then
            local BasePart = Enemy:FindFirstChild(Config.HitboxLimbs[math.random(#Config.HitboxLimbs)]) or Enemy:FindFirstChild("HumanoidRootPart")
            if BasePart then
                if not self.EnemyRootPart then
                    self.EnemyRootPart = BasePart
                else
                    table.insert(BladeHits, {Enemy, BasePart})
                end
            end
        end
    end
    
    return BladeHits
end

function FastAttack:GetClosestEnemy(Character, Distance)
    local BladeHits = self:GetBladeHits(Character, Distance)
    local Closest, MinDistance = nil, math.huge
    
    for _, Hit in ipairs(BladeHits) do
        local Magnitude = (Character:GetPivot().Position - Hit[2].Position).Magnitude
        if Magnitude < MinDistance then
            MinDistance = Magnitude
            Closest = Hit[2]
        end
    end
    return Closest
end

function FastAttack:GetCombo()
    self.ComboDebounce = tick()
    self.M1Combo = 3
    return 3
end

function FastAttack:ShootInTarget(TargetPosition)
    local Character = Player.Character
    if not Character then return end
    
    local Equipped = Character:FindFirstChildOfClass("Tool") or Player.Backpack:FindFirstChildOfClass("Tool")
    if not Equipped or Equipped.ToolTip ~= "Gun" then return end
    
    local Cooldown = Equipped:FindFirstChild("Cooldown") and Equipped.Cooldown.Value or 0.3
    if (tick() - self.ShootDebounce) < Cooldown then return end
    
    local ShootType = self.SpecialShoots[Equipped.Name] or "Normal"
    if ShootType == "Position" or (ShootType == "TAP" and Equipped:FindFirstChild("RemoteEvent")) then
        Equipped:SetAttribute("LocalTotalShots", (Equipped:GetAttribute("LocalTotalShots") or 0) + 1)
        
        if self.ShootFunction and getupvalue and GunValidator then
            GunValidator:FireServer(self:GetValidator2())
        end
        
        if ShootType == "TAP" and Equipped:FindFirstChild("RemoteEvent") then
            Equipped.RemoteEvent:FireServer("TAP", TargetPosition)
        elseif ShootGunEvent then
            ShootGunEvent:FireServer(TargetPosition)
        end
        self.ShootDebounce = tick()
    else
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        self.ShootDebounce = tick()
    end
end

function FastAttack:GetValidator2()
    if not getupvalue or not setupvalue or not self.ShootFunction then return 0, 0 end
    
    local u27 = getupvalue(self.ShootFunction, 13)
    local u23 = getupvalue(self.ShootFunction, 14)
    local u26 = getupvalue(self.ShootFunction, 15)
    local u22 = getupvalue(self.ShootFunction, 16)
    local u24 = getupvalue(self.ShootFunction, 17)
    local u25 = getupvalue(self.ShootFunction, 18)
    local u28 = getupvalue(self.ShootFunction, 19)
    
    local u81 = u27 * u23
    local u82 = (u26 * u23 + u27 * u22) % u24
    u82 = (u82 * u24 + u81) % u25
    u26 = math.floor(u82 / u24)
    u27 = u82 - u26 * u24
    u28 = u28 + 1
    
    setupvalue(self.ShootFunction, 13, u27)
    setupvalue(self.ShootFunction, 14, u23)
    setupvalue(self.ShootFunction, 15, u26)
    setupvalue(self.ShootFunction, 16, u22)
    setupvalue(self.ShootFunction, 17, u24)
    setupvalue(self.ShootFunction, 18, u25)
    setupvalue(self.ShootFunction, 19, u28)
    
    return math.floor(u82 / u25 * 16777215), u28
end

function FastAttack:UseNormalClick(Character, Humanoid, Cooldown)
    self.EnemyRootPart = nil
    local BladeHits = self:GetBladeHits(Character)
    
    local regAttack = Remotes["RE/RegisterAttack"] or RegisterAttack
    local regHit = Remotes["RE/RegisterHit"] or RegisterHit

    if self.EnemyRootPart or #BladeHits > 0 then
        if regAttack then
            regAttack:FireServer(-math.huge) 
        end

        if self.EnemyRootPart then
            local HitTable = {}
            if self.EnemyRootPart.Parent then
                table.insert(HitTable, {self.EnemyRootPart.Parent, self.EnemyRootPart})
            end
            for _, hitData in ipairs(BladeHits) do
                table.insert(HitTable, {hitData[1], hitData[2]})
            end

            if self.CombatFlags and self.HitFunction then
                self.HitFunction(self.EnemyRootPart, HitTable)
            elseif regHit then
                regHit:FireServer(self.EnemyRootPart, HitTable)
            end
        end
    end
end

function FastAttack:UseFruitM1(Character, Equipped, Combo)
    local Targets = self:GetBladeHits(Character)
    
    if #Targets > 0 or self.EnemyRootPart then
        local Direction
        if Targets[1] then
            Direction = (Targets[1][2].Position - Character:GetPivot().Position).Unit
        else
            Direction = Character:GetPivot().LookVector
        end
        local remote = Equipped:FindFirstChild("LeftClickRemote")
        if remote then
            remote:FireServer(Direction, Combo)
        end
    end
end

function FastAttack:Attack()
    if not Config.AutoClickEnabled or (tick() - self.Debounce) < Config.AttackCooldown then return end
    local Character = Player.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    
    local Equipped = Character:FindFirstChildOfClass("Tool") or Player.Backpack:FindFirstChildOfClass("Tool")
    if not Equipped then return end
    
    local ToolTip = Equipped.ToolTip
    if not table.find({"Melee", "Blox Fruit", "Sword", "Gun"}, ToolTip) then return end
    
    local CooldownVal = Equipped:FindFirstChild("Cooldown")
    local Cooldown = CooldownVal and CooldownVal.Value or Config.AttackCooldown
    if not self:CheckStun(Character, Humanoid, ToolTip) then return end
    
    local Combo = self:GetCombo()
    Cooldown = Cooldown + (Combo >= Config.MaxCombo and 0.05 or 0)
    self.Debounce = Combo >= Config.MaxCombo and ToolTip ~= "Gun" and (tick() + 0.05) or tick()
    
    if ToolTip == "Blox Fruit" and Equipped:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(Character, Equipped, Combo)
    elseif ToolTip == "Gun" then
        local Target = self:GetClosestEnemy(Character, 120)
        if Target then
            self:ShootInTarget(Target.Position)
        end
    else
        self:UseNormalClick(Character, Humanoid, Cooldown)
    end
end

local AttackInstance = FastAttack.new()

table.insert(AttackInstance.Connections, RunService.Stepped:Connect(function()
    AttackInstance:Attack()
end))

if getgc and hookfunction then
    for _, v in pairs(getgc(true)) do
        if typeof(v) == "function" and iscclosure(v) then
            local info = debug.getinfo(v)
            local name = info and info.name
            if name == "Attack" or name == "attack" or name == "RegisterHit" then
                pcall(function()
                    hookfunction(v, function(...)
                        AttackInstance:Attack()
                        return v(...)
                    end)
                end)
            end
        end
    end
end
end)() --end FastAttack
        end)
    end

---------
---------
task.spawn(function()
    while task.wait(0.25) do
        pcall(function()
            replicated.Remotes.CommF_:InvokeServer("ColorsDealer", "2")
        end)
        pcall(function()
            replicated.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "1")
            replicated.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "2")
        end)
    end
end)
---------
---------
local HttpService = game:GetService("HttpService")

local function FormatForAPI(str)
if not str then return "" end
return string.gsub(str, "[%s_%(%)%[%]%%]", "")
end

local function GetHistoryFileName(filter)
return "meyy_history_" .. tostring(filter) .. ".json"
end

local function LoadHistory(filter)
local fileName = GetHistoryFileName(filter)
if isfile and isfile(fileName) then
local success, data = pcall(function()
return HttpService:JSONDecode(readfile(fileName))
end)
if success and type(data) == "table" then
return data
end
end
return {}
end

local function SaveHistory(filter, historyTable)
local fileName = GetHistoryFileName(filter)
if writefile then
pcall(function()
writefile(fileName, HttpService:JSONEncode(historyTable))
end)
end
end

getgenv().FailedJobIds = getgenv().FailedJobIds or {}
getgenv().LastApiRefresh = 0
local joinFailed = false

local isHopping = false
local isFighting = false
---------
---------
local function HopToServerByAPI(filterNames, maxPlayers, waitTime)
    maxPlayers = maxPlayers or 12
    waitTime   = waitTime or 25
    local apiUrl = "https://api-meomeo.up.railway.app/?key=" .. filterNames
    local CURRENT_PLACE_ID = game.PlaceId
    local maxRetries = math.max(1, math.floor(waitTime / 3))

    getgenv().MainTaskStatus = "SERVER HOPPING"
    getgenv().SubTaskStatus = "Requesting API: " .. tostring(filterNames)

    for attempt = 1, maxRetries do
        getgenv().SubTaskStatus = "Fetching API (" .. tostring(filterNames) .. ") [" .. attempt .. "/" .. maxRetries .. "]"
        
        local historyList = LoadHistory(filterNames)
        local oldJobIds = {}
        for _, jobId in ipairs(historyList) do oldJobIds[jobId] = true end

        local ok, result = pcall(function()
            local responseBody
            pcall(function() responseBody = game:HttpGet(apiUrl) end)
            if not responseBody then
                local reqFunc = (syn and syn.request) or request or http.request
                if reqFunc then
                    local req = reqFunc({ Url = apiUrl, Method = "GET" })
                    if req then responseBody = req.Body end
                end
            end
            if not responseBody then
                getgenv().SubTaskStatus = "API Request Failed (Attempt " .. attempt .. "/" .. maxRetries .. ")"
                return "ERROR"
            end
            
            local data
            local decodeOk, decodeRes = pcall(function() return HttpService:JSONDecode(responseBody) end)
            if not decodeOk or type(decodeRes) ~= "table" then
                getgenv().SubTaskStatus = "JSON Decode Error (Attempt " .. attempt .. "/" .. maxRetries .. ")"
                return "ERROR"
            end
            data = decodeRes
            
            local dataList = data["Make By Dragons Toro"] or data.servers or data.data or data.Servers or data
            if type(dataList) ~= "table" then
                getgenv().SubTaskStatus = "Invalid API Response (Attempt " .. attempt .. "/" .. maxRetries .. ")"
                return "ERROR"
            end

            local seen, servers, currentJobIds = {}, {}, {}
            for _, entry in pairs(dataList) do
                if type(entry) == "table" then
                    local jobId   = entry.joinId or entry.jobId or entry.jobid or entry.id
                    local placeId = tonumber(entry.placeId) or tonumber(entry.placeid) or CURRENT_PLACE_ID
                    
                    local players = 99
                    local rawPlayers = entry.players or entry.playing or entry.Players or entry.Playing
                    
                    if type(rawPlayers) == "string" then
                        local currentP = string.match(rawPlayers, "(%d+)/")
                        if currentP then
                            players = tonumber(currentP)
                        else
                            players = tonumber(rawPlayers) or 99
                        end
                    elseif type(rawPlayers) == "number" then
                        players = rawPlayers
                    end

                    if jobId and placeId and not seen[jobId] then
                        seen[jobId] = true
                        table.insert(currentJobIds, jobId)
                        table.insert(servers, { jobid = jobId, placeid = placeId, players = players })
                    end
                end
            end
            SaveHistory(filterNames, currentJobIds)

---------
            local newServers, allFiltered = {}, {}
            for _, s in ipairs(servers) do
                if s.placeid == CURRENT_PLACE_ID and s.players >= 2 and s.players < maxPlayers then
                    table.insert(allFiltered, s)
                    if not oldJobIds[s.jobid] then table.insert(newServers, s) end
                end
            end

            if #newServers == 0 or #historyList > 20 then
                SaveHistory(filterNames, {})
                oldJobIds = {}
                newServers = allFiltered
            end

            local targetServers = newServers
            if #targetServers == 0 then
                getgenv().SubTaskStatus = "No Valid Server (" .. tostring(filterNames) .. ")"
                return "NO_SERVER"
            end
---------
            getgenv().SubTaskStatus = "Found " .. #targetServers .. " Servers | Filtering Candidates..."

            for index, server in ipairs(targetServers) do
                local jobId = server.jobid
                if jobId == game.JobId then continue end
                if getgenv().FailedJobIds[jobId] and (tick() - getgenv().FailedJobIds[jobId] < 60) then continue end

                getgenv().SubTaskStatus = "Connecting: " .. string.sub(jobId, 1, 8) .. "... (" .. tostring(server.players) .. "P) [" .. index .. "/" .. #targetServers .. "]"

                local localJoinFailed = false
                local teleportService = game:GetService("TeleportService")
                local guiService = game:GetService("GuiService")
                local coreGui = game:GetService("CoreGui")

                local tpConn
                tpConn = teleportService.TeleportInitFailed:Connect(function()
                    localJoinFailed = true
                    getgenv().FailedJobIds[jobId] = tick()
                    getgenv().SubTaskStatus = "Teleport Failed: " .. string.sub(jobId, 1, 8) .. "..."
                end)

                local errConn
                errConn = guiService.ErrorMessageChanged:Connect(function()
                    localJoinFailed = true
                    getgenv().FailedJobIds[jobId] = tick()
                    getgenv().SubTaskStatus = "Roblox Error Prompt: " .. string.sub(jobId, 1, 8) .. "..."
                    pcall(function() teleportService:CancelQueuedTeleports() end)
                    pcall(function() guiService:ClearError() end)
                end)

                local errUIConn
                pcall(function()
                    local promptOverlay = coreGui:WaitForChild("RobloxPromptGui", 2):WaitForChild("promptOverlay", 2)
                    if promptOverlay then
                        if promptOverlay:FindFirstChild("ErrorPrompt") then
                            localJoinFailed = true
                            getgenv().FailedJobIds[jobId] = tick()
                            getgenv().SubTaskStatus = "Error Prompt Detected: " .. string.sub(jobId, 1, 8) .. "..."
                            pcall(function() teleportService:CancelQueuedTeleports() end)
                            pcall(function() promptOverlay.ErrorPrompt:Destroy() end)
                        end

                        errUIConn = promptOverlay.ChildAdded:Connect(function(child)
                            if child.Name == "ErrorPrompt" or string.find(string.lower(child.Name), "error") then
                                localJoinFailed = true
                                getgenv().FailedJobIds[jobId] = tick()
                                getgenv().SubTaskStatus = "Error UI Detected: " .. string.sub(jobId, 1, 8) .. "..."
                                pcall(function() teleportService:CancelQueuedTeleports() end)
                                pcall(function() child:Destroy() end)
                            end
                        end)
                    end
                end)

                local teleportOk = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser"):InvokeServer("teleport", jobId)
                end)

                if teleportOk then
                    local startTime = tick()
                    while (tick() - startTime < 3) do
                        if localJoinFailed then break end
                        getgenv().SubTaskStatus = "Teleporting to " .. string.sub(jobId, 1, 8) .. "... (" .. string.format("%.1fs", 3 - (tick() - startTime)) .. ")"
                        task.wait(0.2)
                    end
                else
                    localJoinFailed = true
                    getgenv().FailedJobIds[jobId] = tick()
                    getgenv().SubTaskStatus = "Teleport Invoke Failed: " .. string.sub(jobId, 1, 8) .. "..."
                end

                if tpConn then tpConn:Disconnect() end
                if errConn then errConn:Disconnect() end
                if errUIConn then errUIConn:Disconnect() end

                if not localJoinFailed then 
                    getgenv().SubTaskStatus = "Joining Server: " .. string.sub(jobId, 1, 8) .. "..."
                    return true 
                end
                
                getgenv().SubTaskStatus = "Hop Failed (" .. string.sub(jobId, 1, 8) .. "...), trying next..."
                task.wait(0.25)
            end
            return "RETRY"
        end)

        if ok and result == true then return true end
        if ok and result == "ALL_CACHED" then return "ALL_CACHED" end
        getgenv().SubTaskStatus = "API Attempt " .. attempt .. " Failed. Retrying..."
        task.wait(0.5)
    end

    getgenv().SubTaskStatus = "API Hop Failed! Falling back to Normal Hop..."
    task.wait(0.5)
    if HopServer then
        HopServer()
    elseif getgenv().HopServerFunc then
        getgenv().HopServerFunc()
    end
    return false
end
---------

---------
    local function JoinSea(targetSea)
    getgenv().MainTaskStatus = "TRAVELING"
    getgenv().SubTaskStatus = "Joining Sea " .. tostring(targetSea)
    local placeId = game.PlaceId
    local commF = Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
    
    if targetSea == 1 then
        if placeId == 4442272183 or placeId == 79091703265657 or placeId == 7449423635 or placeId == 100117331123089 then
            commF:InvokeServer("TravelMain")
        end
    elseif targetSea == 2 then
        if placeId == 2753915549 or placeId == 85211729168715 or placeId == 7449423635 or placeId == 100117331123089 then
            commF:InvokeServer("TravelDressrosa")
        end
    elseif targetSea == 3 then
        if placeId == 4442272183 or placeId == 79091703265657 or placeId == 2753915549 or placeId == 85211729168715 then
            commF:InvokeServer("TravelZou")
        end
    end
end

local function joinMarines()
    local args = {
        [1] = "SetTeam",
        [2] = TeamName
    }
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
    remote:InvokeServer(unpack(args))
end


local __teamTries = 0
while task.wait(0.5) do
    if LocalPlayer.Team and LocalPlayer.Team.Name == TeamName then
        break
    end
    __teamTries = __teamTries + 1
    getgenv().MainTaskStatus = "JOINING TEAM"
    getgenv().SubTaskStatus = TeamName .. " (try " .. __teamTries .. ")"
    if __teamTries > 60 then
        warn("[Weapon Kaitun] could not confirm team '" .. TeamName .. "', continuing anyway")
        break
    end
    
    local success, err = pcall(function()
        joinMarines()
    end)
    
    if LocalPlayer.Team and LocalPlayer.Team.Name == TeamName then
        break
    end
end

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local char = LocalPlayer.Character or plr.Character
            if char and not char:FindFirstChild("HasBuso") then
                replicated.Remotes.CommF_:InvokeServer("Buso")
            end
        end)
    end
end)

---------
task.spawn(function()
    local lastPosition = nil
    local lastMoveTime = tick()

    while task.wait(1) do
        local isWaitingForBoss = false
        if getgenv().MainTaskStatus and string.find(tostring(getgenv().MainTaskStatus), "WAITING BOSS SPAWN TIME") then
            isWaitingForBoss = true
        end

        if isWaitingForBoss then
            lastMoveTime = tick() 
            continue
        end

        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local currentPos = char.HumanoidRootPart.Position

            if lastPosition then
                local distance = (currentPos - lastPosition).Magnitude
                if distance > 5 then
                    lastPosition = currentPos
                    lastMoveTime = tick()
                else
                    if tick() - lastMoveTime > 120 then 
                        getgenv().MainTaskStatus = "ANTI-BUG"
                        getgenv().SubTaskStatus = "Stuck for 2 mins, hopping server!"
                        
                        if type(HopServer) == "function" then
                            HopServer()
                        elseif type(getgenv().HopServerFunc) == "function" then
                            getgenv().HopServerFunc()
                        end
                        
                        lastMoveTime = tick() 
                    end
                end
            else
                lastPosition = currentPos
                lastMoveTime = tick()
            end
        else
            lastMoveTime = tick() 
        end
    end
end)
---------
-- Soul Cane
if WeaponEnabled("Soul Cane") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BuyItem", "Soul Cane") end) end
-- Bisento
if WeaponEnabled("Bisento") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BuyItem", "Bisento") end) end
-- Dual-Headed Blade
if WeaponEnabled("Dual-Headed Blade") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BuyItem", "Dual-Headed Blade") end) end
-- Pipe
if WeaponEnabled("Pipe") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BuyItem", "Pipe") end) end
-- Sword
if WeaponEnabled("Cutlass") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BuyItem", "Cutlass") end) end
-- Sword
if WeaponEnabled("Dual Katana") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BuyItem", "Dual Katana") end) end
-- Sword
if WeaponEnabled("Katana") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BuyItem", "Katana") end) end
-- Sword
if WeaponEnabled("Iron Mace") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BuyItem", "Iron Mace") end) end
-- Sword
if WeaponEnabled("Triple Katana") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BuyItem", "Triple Katana") end) end
-- kabucha 
if WeaponEnabled("Slingshot") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BlackbeardReward", "Slingshot", "2") end) end
-- Cannon
if WeaponEnabled("Cannon") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BuyItem", "Cannon") end) end
-- Refined Flintlock
if WeaponEnabled("Refined Slingshot") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BuyItem", "Refined Slingshot") end) end
-- Flintlock
if WeaponEnabled("Flintlock") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BuyItem", "Flintlock") end) end
--  Dual Flintlock
if WeaponEnabled("Dual Flintlock") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BuyItem", "Dual Flintlock") end) end
-- Musket
if WeaponEnabled("Musket") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BuyItem", "Musket") end) end
-- Slingshot
if WeaponEnabled("Slingshot") then pcall(function() replicated.Remotes.CommF_:InvokeServer("BuyItem", "Slingshot") end) end
-- Bizarre Rifle
if WeaponEnabled("Bizarre Rifle") then pcall(function() replicated.Remotes.CommF_:InvokeServer("Ectoplasm", "Buy", 1) end) end


local Config = {
    TargetBossName = "iemnaieudau", 
    TweenSpeed = Cfg.Combat.TweenSpeed,
    HoverHeight = Cfg.Combat.HoverHeight
}

local BossDrops = {
    ["Bisento"] = {Boss = "Greybeard", Sea = 1},
    ["Wardens Sword"] = {Boss = "Chief Warden", Sea = 1},
    ["Magma Blaster"] = {Boss = "Magma Admiral", Sea = 1},
    ["Bazooka"] = {Boss = "Wysper", Sea = 1},
    ["Pole (1st Form)"] = {Boss = "Thunder God", Sea = 1},
    ["Trident"] = {Boss = "Fishman Lord", Sea = 1},
    ["Longsword"] = {Boss = "Diamond", Sea = 2},
    ["Gravity Blade"] = {Boss = "Orbitus", Sea = 2},
    ["Dragon Trident"] = {Boss = "Tide Keeper", Sea = 2},
    ["Flail"] = {Boss = "Smoke Admiral", Sea = 2},
    ["Twin Hooks"] = {Boss = "Captain Elephant", Sea = 3},
    ["Canvander"] = {Boss = "Beautiful Pirate", Sea = 3},
    ["Buddy Sword"] = {Boss = "Cake Queen", Sea = 3},
    ["Venom Bow"] = {Boss = "Hydra Leader", Sea = 3},
    ["Hallow Scythe"] = {Boss = "Soul Reaper", Sea = 3},
    ["Shizu"] = {Boss = "Legendary Sword Dealer", Sea = 2},
    ["True Triple Katana"] = {Boss = "MysteriousMan", Sea = 2},
    ["Oroshi"] = {Boss = "Legendary Sword Dealer", Sea = 2},
    ["Saishi"] = {Boss = "Legendary Sword Dealer", Sea = 2}
    
}



---------
    local function EquipWeapon()
        local char = LocalPlayer.Character
        if not char then return end
        
        if getgenv().MasteryWeapon then
            local tool = char:FindFirstChild(getgenv().MasteryWeapon) or LocalPlayer.Backpack:FindFirstChild(getgenv().MasteryWeapon)
            if tool and tool:IsA("Tool") then
                tool.Parent = char
                return
            end
        end
        
        local targetTooltip = Cfg.Combat.Weapon or "Melee"
        
        local function CheckParent(parent)
            for _, item in pairs(parent:GetChildren()) do
                if item:IsA("Tool") and item.ToolTip == targetTooltip then
                    item.Parent = char
                    return true
                end
            end
            return false
        end
        
        if not CheckParent(char) then
            CheckParent(LocalPlayer.Backpack)
        end
    end
---------

    
    


---------
    local function IsBossMatch(name)
        if Config.TargetBossName == nil or Config.TargetBossName == "" then return false end
        if Config.TargetBossName == "Elite" then
            return name == "Urban" or name == "Deandre" or name == "Diablo"
        elseif Config.TargetBossName == "rip_indra" then
            return name == "rip_indra True Form"
        else
            return string.find(name, Config.TargetBossName) ~= nil
        end
    end

    local function GetBoss()
        local searchTargets = {}
        local enemiesDir = Workspace:FindFirstChild("Enemies")
        if enemiesDir then
            table.insert(searchTargets, enemiesDir)
        end
        
        local fortFolder = ReplicatedStorage:FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
        if fortFolder then
            table.insert(searchTargets, fortFolder)
        end
        
        table.insert(searchTargets, ReplicatedStorage)
        
        for _, target in pairs(searchTargets) do
            for _, enemy in pairs(target:GetChildren()) do
                if IsBossMatch(enemy.Name) then
                    local hum = enemy:FindFirstChild("Humanoid")
                    local root = enemy:FindFirstChild("HumanoidRootPart")
                    
                    if hum and root and hum.Health > 0 then
                        return enemy 
                    end
                end
            end
        end
        
        return nil 
    end


---------

local function CuteGetBossSpawn()
    local worldOrigin = Workspace:FindFirstChild("_WorldOrigin")
    if worldOrigin then
        local enemySpawns = worldOrigin:FindFirstChild("EnemySpawns")
        if enemySpawns then
            for _, spawnPart in pairs(enemySpawns:GetChildren()) do
                if string.find(string.lower(spawnPart.Name), string.lower(Config.TargetBossName), 1, true) then
                    return spawnPart
                end
            end
        end
    end
    return nil
end

    

---------
    local function ExecuteFarm()
        local boss = GetBoss()
        
        if boss then
            getgenv().MainTaskStatus = "FARMING BOSS"
            getgenv().SubTaskStatus = "Attacking: " .. tostring(Config.TargetBossName)
            StartAttack()
            
            while boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and boss.Parent do
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") and boss:FindFirstChild("HumanoidRootPart") then
                    EquipWeapon()
                    local bossRoot = boss.HumanoidRootPart
                    local targetCFrame = bossRoot.CFrame * CFrame.new(0, Config.HoverHeight, 0)
                    
                    if getgenv().TP then
                        getgenv().TP(targetCFrame)
                    end
                end
                task.wait()
            end
            
            if getgenv().stoptp then getgenv().stoptp() end
            task.wait(2)
            
            local requireApiHop = false
            if Config.TargetBossName == "Darkbeard" then
                local hasDarkFrag = false
                pcall(function()
                    local IRS = require(game:GetService("ReplicatedStorage"):WaitForChild("ItemReplicationService"))
                    local KEYS = require(game:GetService("ReplicatedStorage").ItemReplicationService.KEYS)
                    for _, item in pairs(IRS:GetItems(KEYS.QUANTITY) or {}) do
                        local ok, conf = pcall(function() return require(game:GetService("ReplicatedStorage"):WaitForChild("ItemConfig")).match(item.ItemId):unwrap() end)
                        if ok and conf and conf.Index.DebugLabel and string.find(conf.Index.DebugLabel, "Dark Fragment") then
                            if item.Value and item.Value > 0 then
                                hasDarkFrag = true
                            end
                            break
                        end
                    end
                end)
            if not hasDarkFrag then
                    requireApiHop = true
                    apiName = "Darkbeard"
                end
            elseif Config.TargetBossName == "Soul Reaper" then
                requireApiHop = true
                apiName = "SoulReaper"
            end

            if requireApiHop then
                HopToServerByAPI(apiName, 12, 2)
            else
                HopServer()
            end
        else
            getgenv().MainTaskStatus = "KILL BOSS"
            getgenv().SubTaskStatus = "Waiting for boss spawn..."
            local bossSpawn = CuteGetBossSpawn()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if bossSpawn and root then
                local distanceToSpawn = (root.Position - bossSpawn.Position).Magnitude
                
                if distanceToSpawn <= 100 then
            if Config.TargetBossName == "Darkbeard" then
                        HopToServerByAPI("Darkbeard", 12, 2)
                    elseif Config.TargetBossName == "Soul Reaper" then
                        HopToServerByAPI("SoulReaper", 12, 2)
                    else
                        HopServer()
                    end
                else
                    local targetCFrame = bossSpawn.CFrame * CFrame.new(0, Config.HoverHeight, 0)
                    
                    local foundBoss = false
                    while task.wait() do
                        if getgenv().TP then getgenv().TP(targetCFrame) end
                        
                        if GetBoss() then
                            if getgenv().stoptp then getgenv().stoptp() end
                            foundBoss = true
                            break
                        end
                        
                        local currentRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if currentRoot and (currentRoot.Position - targetCFrame.Position).Magnitude <= 20 then
                            if getgenv().stoptp then getgenv().stoptp() end
                            break
                        end
                    end
                    
                    if foundBoss then
                        ExecuteFarm()
                    else
                        local waitStart = tick()
                        while tick() - waitStart < 5 do
                            if GetBoss() then
                                foundBoss = true
                                break
                            end
                            task.wait(0.1)
                        end

                        if foundBoss then
                            ExecuteFarm()
                        else
                            if Config.TargetBossName == "Darkbeard" then
                                HopToServerByAPI("Darkbeard", 12, 2)
                            elseif Config.TargetBossName == "Soul Reaper" then
                                HopToServerByAPI("SoulReaper", 12, 2)
                            else
                                HopServer()
                            end
                        end
                    end
                end
            else
                if Config.TargetBossName == "Darkbeard" then
                    getgenv().MainTaskStatus = "SOUL GUITAR"
                    getgenv().SubTaskStatus = "Hopping for Darkbeard"
                    HopToServerByAPI("Darkbeard", 12, 2)
                elseif Config.TargetBossName == "Soul Reaper" then
                    getgenv().MainTaskStatus = "HALLOW SCYTHE"
                    getgenv().SubTaskStatus = "Hopping for Soul Reaper"
                    HopToServerByAPI("SoulReaper", 12, 2)
                else
                    HopServer()
                end
            end
        end
    end

local function AutoFarmBoss()
    ExecuteFarm()
end

---------
    local function get_hallow_scythe()
        Config.TargetBossName = "Soul Reaper"
        
        local boss = (typeof(GetBoss) == "function" and GetBoss()) or nil
        if boss then
            getgenv().MainTaskStatus = "HALLOW SCYTHE"
            getgenv().SubTaskStatus = "Attacking Soul Reaper"
            if typeof(AutoFarmBoss) == "function" then
                AutoFarmBoss()
            elseif typeof(ExecuteFarm) == "function" then
                ExecuteFarm()
            end
        else
            getgenv().MainTaskStatus = "HALLOW SCYTHE"
            getgenv().SubTaskStatus = "Hopping for Soul Reaper"
            if typeof(HopToServerByAPI) == "function" then
                HopToServerByAPI("SoulReaper", 12, 2)
            elseif typeof(getgenv().HopToServerByAPI) == "function" then
                getgenv().HopToServerByAPI("SoulReaper", 12, 2)
            elseif typeof(HopServer) == "function" then
                HopServer()
            elseif typeof(getgenv().HopServerFunc) == "function" then
                getgenv().HopServerFunc()
            end
        end
    end
---------

local World1, World2, World3 = false, false, false
local placeId = game.PlaceId

if placeId == 2753915549 or placeId == 85211729168715 then World1 = true
elseif placeId == 4442272183 or placeId == 79091703265657 then World2 = true
elseif placeId == 7449423635 or placeId == 100117331123089 then World3 = true end



RunService.Stepped:Connect(function()
    if getgenv().AutoMaterial and plr.Character then
        for _, v in pairs(plr.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)



local function TweenObject(Object, Pos, Speed)
    Speed = Speed or 350
    if not Object or not Pos then return end
    local Distance = (Pos.Position - Object.Position).Magnitude
    local info = TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(Object, info, {CFrame = Pos})
    tween:Play()
end



local function MoveTo(targetCFrame)
    if getgenv().TP then
        getgenv().TP(targetCFrame)
    else
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = targetCFrame end
    end
end


local ItemReplicationService = require(RS:WaitForChild("ItemReplicationService"))
local KEYS = require(RS.ItemReplicationService.KEYS)
local ItemConfig = require(RS:WaitForChild("ItemConfig"))

local function getItemName(itemId)
    local ok, name = pcall(function()
        return ItemConfig.match(itemId):unwrap().Index.DebugLabel
    end)
    if ok and name then
        return name
    end
    return "Unknown_" .. tostring(itemId)
end

local function GetIdItem(targetName)
    local quantityItems = ItemReplicationService:GetItems(KEYS.QUANTITY)
    if not quantityItems then return nil end

    for _, item in pairs(quantityItems) do
        local rawName = getItemName(item.ItemId)
        local cleanName = string.match(rawName, "^(.-)%s*%[") or rawName
        
        if cleanName == targetName or string.find(rawName, targetName, 1, true) then
            return item.ItemId
        end
    end
    return nil
end

local function getItemCount(targetItemId)
    local quantityItems = ItemReplicationService:GetItems(KEYS.QUANTITY)
    if quantityItems then
        for _, item in pairs(quantityItems) do
            if item.ItemId == targetItemId then
                return item.Value or 0
            end
        end
    end
    return 0
end

-- Ownership detection (rewritten): several sources, all protected, normalized exact-name matching.
--   1) Tools in Backpack / Character   2) ItemReplicationService (Quantity + Mastery)
--   3) ItemReplicationService._UserCache   4) CommF_ "getInventory"
local function _NormName(s)
    s = tostring(s or "")
    s = s:gsub("%s*%[.-%]", "")
    s = s:gsub("[%s%p]", "")
    return s:lower()
end
local _OwnedAliases = {
    [_NormName("Pole (1st Form)")] = { _NormName("Pole (2nd Form)") },
    [_NormName("Bisento")] = { _NormName("Bisento V2") },
    [_NormName("Skull Guitar")] = { _NormName("Soul Guitar") },
}
local _OwnedCache, _OwnedAt = {}, 0
local function _BuildOwned()
    local owned = {}
    local function add(name, count)
        local n = _NormName(name)
        if n ~= "" then owned[n] = math.max(owned[n] or 0, tonumber(count) or 1) end
    end
    -- 1) tools
    pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        for _, holder in ipairs({ lp:FindFirstChild("Backpack"), lp.Character }) do
            if holder then
                for _, v in ipairs(holder:GetChildren()) do
                    if v:IsA("Tool") then add(v.Name, 1) end
                end
            end
        end
    end)
    -- 2 + 3) item replication
    pcall(function()
        local irs = require(RS:WaitForChild("ItemReplicationService", 5))
        local cfg = require(RS:WaitForChild("ItemConfig", 5))
        local tries = tick() + 5
        while irs.IsInitialized ~= true and tick() < tries do task.wait() end
        local sources = { irs }
        pcall(function()
            local cache = irs._UserCache and irs._UserCache[game:GetService("Players").LocalPlayer.UserId]
            if cache then table.insert(sources, cache) end
        end)
        local keys = {}
        pcall(function() table.insert(keys, require(RS.ItemReplicationService.KEYS).QUANTITY) end)
        table.insert(keys, "Quantity")
        table.insert(keys, "Mastery")
        for _, src in ipairs(sources) do
            for _, key in ipairs(keys) do
                pcall(function()
                    local list = src:GetItems(key)
                    if type(list) == "table" then
                        for _, item in pairs(list) do
                            local ok, label = pcall(function() return cfg.match(item.ItemId):unwrap().Index.DebugLabel end)
                            if ok and label then add(label, item.Value or 1) end
                        end
                    end
                end)
            end
        end
    end)
    -- 4) inventory remote
    pcall(function()
        local inv = RS:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("getInventory")
        if type(inv) == "table" then
            for _, v in pairs(inv) do
                if type(v) == "table" and v.Name then add(v.Name, v.Count or v.Value or 1) end
            end
        end
    end)
    return owned
end

local function CheckItem(itemName)
    if itemName == "None" or not itemName then return false, 0 end
    if tick() - _OwnedAt > 3 then
        _OwnedAt = tick()
        local ok, res = pcall(_BuildOwned)
        if ok and type(res) == "table" then _OwnedCache = res end
    end
    local want = _NormName(itemName)
    if _OwnedCache[want] then return true, _OwnedCache[want] end
    for _, alias in ipairs(_OwnedAliases[want] or {}) do
        if _OwnedCache[alias] then return true, _OwnedCache[alias] end
    end
    return false, 0
end


local function GetMaterialData(matName)
    local MMon, MPos = {}, nil
    if World1 then
        if matName == "Angel Wings" then MMon = {"Shanda", "Royal Squad", "Royal Soldier", "Wysper", "Thunder God"} MPos = CFrame.new(-4698, 845, -1912)
        elseif matName == "Leather" or matName == "Scrap Metal" then MMon = {"Brute", "Pirate"} MPos = CFrame.new(-1145, 15, 4350)
        elseif matName == "Magma Ore" then MMon = {"Military Soldier", "Military Spy", "Magma Admiral"} MPos = CFrame.new(-5815, 84, 8820)
        elseif matName == "Fish Tail" then MMon = {"Fishman Warrior", "Fishman Commando", "Fishman Lord"} MPos = CFrame.new(61123, 19, 1569) end
    elseif World2 then
        if matName == "Leather" or matName == "Scrap Metal" then MMon = {"Marine Captain"} MPos = CFrame.new(-2010.5, 73, -3326.6)
        elseif matName == "Magma Ore" then MMon = {"Magma Ninja", "Lava Pirate"} MPos = CFrame.new(-5428, 78, -5959)
        elseif matName == "Ectoplasm" then MMon = {"Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer"} MPos = CFrame.new(911.3, 125.9, 33159.5)
        elseif matName == "Mystic Droplet" then MMon = {"Water Fighter"} MPos = CFrame.new(-3385, 239, -10542)
        elseif matName == "Radioactive Material" then MMon = {"Factory Staff"} MPos = CFrame.new(295, 73, -56)
        elseif matName == "Vampire Fang" then MMon = {"Vampire"} MPos = CFrame.new(-6033, 7, -1317) end
    elseif World3 then
        if matName == "Scrap Metal" then MMon = {"Jungle Pirate", "Forest Pirate"} MPos = CFrame.new(-11975.7, 331.7, -10620)
        elseif matName == "Fish Tail" then MMon = {"Fishman Raider", "Fishman Captain"} MPos = CFrame.new(-10993, 332, -8940)
        elseif matName == "Conjured Cocoa" then MMon = {"Chocolate Bar Battler", "Cocoa Warrior"} MPos = CFrame.new(620.6, 78.9, -12581.3)
        elseif matName == "Dragon Scale" then MMon = {"Dragon Crew Archer", "Dragon Crew Warrior"} MPos = CFrame.new(6594, 383, 139)
        elseif matName == "Gunpowder" then MMon = {"Pistol Billionaire"} MPos = CFrame.new(-84.8, 85.6, 6132)
        elseif matName == "Mini Tusk" then MMon = {"Mythological Pirate"} MPos = CFrame.new(-13545, 470, -6917)
        elseif matName == "Demonic Wisp" then MMon = {"Demonic Soul"} MPos = CFrame.new(-9495.6, 453.5, 5977.3)
        elseif matName == "Bones" then MMon = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"} MPos = CFrame.new(-9495.6, 453.5, 5977.3) end
    end
    return MMon, MPos
end



local function GetMobPosition(EnemiesName)
    local pos = Vector3.zero
    local count = 0
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v.Name == EnemiesName and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            if (v.HumanoidRootPart.Position - hrp.Position).Magnitude <= 0 then
                pos += v.HumanoidRootPart.Position
                count += 1
            end
        end
    end
    if count == 0 then
        return nil
    end
    return pos / count
end


local function BringMob(enable)
    if not enable then return end
    local enemies = workspace.Enemies:GetChildren()
    if #enemies == 0 then return end
    local totalpos = {}
    for _, v in pairs(enemies) do
        if not totalpos[v.Name] then
            totalpos[v.Name] = GetMobPosition(v.Name)
        end
    end
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local hrp = v.HumanoidRootPart
            local humanoid = v.Humanoid
            if humanoid.Health > 0 and (hrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 10 then
                local mobPos = totalpos[v.Name]
                if mobPos then
                    local TargetCFrame = CFrame.new(mobPos.X, mobPos.Y, mobPos.Z)
                    local Distance = (hrp.Position - TargetCFrame.Position).Magnitude
                    if Distance > 3 and Distance <= 10 then
                        TweenObject(hrp, TargetCFrame, 300)
                        hrp.CanCollide = false
                        if humanoid:FindFirstChild("Animator") then
                            humanoid.Animator:Destroy()
                        end
                        pcall(function()
                            sethiddenproperty(plr, "SimulationRadius", math.huge)
                        end)
                    end
                end
            end
        end
    end
end


local lastCampedSpawn = nil

local function GetEnemiesSpawn(enemyNames) 
    local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
    local bestSpawn = nil
    local minDistance = math.huge
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    
    if not hrp then return nil end

    if worldOrigin then
        local enemySpawns = worldOrigin:FindFirstChild("EnemySpawns")
        if enemySpawns then
            for _, spawnPart in pairs(enemySpawns:GetChildren()) do
                for _, eName in ipairs(enemyNames or {}) do
                    if string.find(spawnPart.Name, eName) then
                        if spawnPart ~= lastCampedSpawn then
                            local dist = (hrp.Position - spawnPart.Position).Magnitude
                            if dist < minDistance then
                                minDistance = dist
                                bestSpawn = spawnPart
                            end
                        end
                    end
                end
            end
        end
    end
    
    if bestSpawn then
        lastCampedSpawn = bestSpawn
    end
    
    return bestSpawn
end

local function FarmMaterialLogic(matName, targetAmount)
    StartAttack()
    getgenv().AutoMaterial = true
    getgenv().MainTaskStatus = "FARMING MATERIAL"
    getgenv().SubTaskStatus = "Gathering: " .. tostring(matName)
    task.spawn(function()
        while getgenv().AutoMaterial do
            task.wait()
            
            local char = plr.Character
            if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
                plr.CharacterAdded:Wait()
                task.wait(1)
                continue
            end

            local hasItem, currentAmount = CheckItem(matName)
            if currentAmount >= targetAmount then
                getgenv().AutoMaterial = false
                if getgenv().stoptp then getgenv().stoptp() end
                break
            end

            local MMon, MPos = GetMaterialData(matName)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            local targetMob = nil
            local closestDist = 1000
            
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                local isTarget = false
                for _, en in ipairs(MMon or {}) do 
                    if v.Name == en then isTarget = true break end 
                end
                
                if isTarget and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                    local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist <= closestDist then
                        closestDist = dist
                        targetMob = v
                    end
                end
            end
            
            if targetMob then
                local startTime = tick()
                
                repeat
                    task.wait()
                    
                    local currentGhChar = plr.Character
                    if not currentGhChar or not currentGhChar:FindFirstChild("Humanoid") or currentGhChar.Humanoid.Health <= 0 then
                        break
                    end

                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") and targetMob:FindFirstChild("Humanoid") and targetMob.Humanoid.Health > 0 then
                        local targetCFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 35, 0)
                        if getgenv().TP then
                            getgenv().TP(targetCFrame)
                        end
                    else
                        break
                    end

                    BringMob(true)
                    
                    local toolChar = plr.Character
                    if toolChar then
                        if getgenv().MasteryWeapon then
                            local tool = toolChar:FindFirstChild(getgenv().MasteryWeapon) or plr.Backpack:FindFirstChild(getgenv().MasteryWeapon)
                            if tool and tool:IsA("Tool") then
                                tool.Parent = toolChar
                            end
                        else
                            local targetTooltip = Cfg.Combat.Weapon or "Melee"
                            local function equip(parent)
                                for _, item in pairs(parent:GetChildren()) do
                                    if item:IsA("Tool") and item.ToolTip == targetTooltip then
                                        item.Parent = toolChar
                                        return true
                                    end
                                end
                                return false
                            end
                            if not equip(toolChar) and plr.Backpack then equip(plr.Backpack) end
                        end
                    end
                    
                    hasItem, currentAmount = CheckItem(matName)
                    if currentAmount >= targetAmount or not getgenv().AutoMaterial then 
                        if getgenv().stoptp then getgenv().stoptp() end
                        break 
                    end
                    
                    if tick() - startTime > 4 then
                        break
                    end
                    
                until not targetMob or not targetMob.Parent or not targetMob:FindFirstChild("Humanoid") or targetMob.Humanoid.Health <= 0
            else
                local nextSpawn = GetEnemiesSpawn(MMon)
                if nextSpawn then
                    if getgenv().TP then getgenv().TP(nextSpawn.CFrame * CFrame.new(0, 35, 0)) end
                    task.wait()
                elseif MPos then
                    if getgenv().TP then getgenv().TP(MPos) end
                end
            end
        end
    end)
end
local function EquipItemInv(itemName)
    if itemName then
        replicated.Remotes.CommF_:InvokeServer("LoadItem", itemName)
    end
end


local function GetCurrentSea()
    local pId = game.PlaceId
    if pId == 2753915549 or pId == 85211729168715 then return 1
    elseif pId == 4442272183 or pId == 79091703265657 then return 2
    elseif pId == 7449423635 or pId == 100117331123089 then return 3 end
    return 1
end
---------
local BlankTablets = {"Segment6", 'Segment2', 'Segment8', "Segment9", 'Segment5'}
local Trophy = {["Segment1"] = "Trophy1", ["Segment3"] = "Trophy2", ['Segment4'] = "Trophy3", ['Segment7'] = "Trophy4", ["Segment10"] = "Trophy5"}
local Pipes = {['Part1'] = 'Really black', ['Part2'] = 'Really black', ["Part3"] = "Dusty Rose", ['Part4'] = "Storm blue", ['Part5'] = 'Really black', ['Part6'] = "Parsley green", ["Part7"] = 'Really black', ["Part8"] = "Dusty Rose", ["Part9"] = 'Really black', ['Part10'] = 'Storm blue'}

local function CheckFullMoon()
    return game:GetService("Lighting"):GetAttribute("MoonPhase") == 5
end

local function CheckSoulGuitarStage()
    local commF = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
    local success, progress = pcall(function()
        return commF:InvokeServer("GuitarPuzzleProgress", "Check")
    end)

    if not success or not progress or type(progress) ~= "table" then
        return 0
    end

    if not progress.Swamp then return 1 end
    if not progress.Gravestones then return 2 end
    if not progress.Ghost then return 3 end
    if not progress.Trophies then return 4 end
    if not progress.Pipes then return 5 end
    
    return 6
end

---------
local function AutoSoulGuitar()
    while task.wait() do
        local hasGuitar, _ = CheckItem("Skull Guitar")
        if hasGuitar then break end

        local plrData = LocalPlayer:FindFirstChild("Data")
        local level = plrData and plrData:FindFirstChild("Level") and plrData.Level.Value or 0
        local fragments = plrData and plrData:FindFirstChild("Fragments") and plrData.Fragments.Value or 0

        if fragments < 5000 or level < 2300 then break end

        local hasDarkFrag, _ = CheckItem("Dark Fragment")
        if not hasDarkFrag then
            if GetCurrentSea() ~= 2 then
                getgenv().MainTaskStatus = "SOUL GUITAR"
                getgenv().SubTaskStatus = "Travelling to Sea 2 for Dark Fragment"
                JoinSea(2)
                task.wait(10)
                return
            else
               Config.TargetBossName = "Darkbeard"
                local darkbeardFound = false
                local searchTargets = {
                    workspace:FindFirstChild("Enemies"),
                    game:GetService("ReplicatedStorage"):FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder"),
                    game:GetService("ReplicatedStorage")
                }
                for _, target in pairs(searchTargets) do
                    if target then
                        for _, enemy in pairs(target:GetChildren()) do
                            if string.find(enemy.Name, "Darkbeard") then
                                local hum = enemy:FindFirstChild("Humanoid")
                                if hum and hum.Health > 0 then
                                    darkbeardFound = true
                                    break
                                end
                            end
                        end
                    end
                    if darkbeardFound then break end
                end

                if darkbeardFound then
                    getgenv().MainTaskStatus = "SOUL GUITAR"
                    getgenv().SubTaskStatus = "Attacking Darkbeard"
                    AutoFarmBoss()
                else
                    getgenv().MainTaskStatus = "SOUL GUITAR"
                    getgenv().SubTaskStatus = "Hopping for Darkbeard"
                    HopToServerByAPI("Darkbeard", 12, 2)
                end
                return
            end
        end
        
        local hasEcto, ectoCount = CheckItem("Ectoplasm")
        if ectoCount < 250 then
            if GetCurrentSea() ~= 2 then
                getgenv().MainTaskStatus = "SOUL GUITAR"
                getgenv().SubTaskStatus = "Teleporting to Sea 2 for Ectoplasm"
                JoinSea(2)
                task.wait(10)
                return
            else
                if not getgenv().AutoMaterial then
                    FarmMaterialLogic("Ectoplasm", 250)
                end
            end
            continue
        end

        if GetCurrentSea() ~= 3 then 
            getgenv().MainTaskStatus = "SOUL GUITAR"
            getgenv().SubTaskStatus = "Travelling to Sea 3"
            JoinSea(3)
            task.wait(10)
            return 
        end

        local commF = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
        local currentStage = CheckSoulGuitarStage()
        
        if currentStage == 0 then
            commF:InvokeServer("gravestoneEvent", 2)
            if not CheckFullMoon() then
                getgenv().MainTaskStatus = "SOUL GUITAR"
                getgenv().SubTaskStatus = "Hopping for Full Moon"
                HopToServerByAPI("FullMoon", 12, 2)
                return
            else
                local targetPos = CFrame.new(-8654.0, 140, 6167)
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - targetPos.Position).Magnitude > 5 then
                    MoveTo(targetPos)
                    task.wait()
                end
                commF:InvokeServer("gravestoneEvent", 2, true)
                task.wait(5)
            end
---------
elseif currentStage == 1 then
        getgenv().TTL9 = getgenv().TTL9 or 0
        getgenv().LastestTime1 = getgenv().LastestTime1 or os.time()
        if os.time() ~= getgenv().LastestTime1 then
            getgenv().TTL9 = getgenv().TTL9 + 1
            getgenv().LastestTime1 = os.time()
        end
        
        if getgenv().TTL9 > 90 then 
            HopServer() 
            return 
        end
        
        local zombieList = {}
        for _, obj in pairs(workspace.Enemies:GetChildren()) do
            if obj.Name == "Living Zombie" and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then 
                table.insert(zombieList, obj) 
            end
        end
        
        if #zombieList == 0 then
            getgenv().SyncKillingZombies = false
        end
        
        local killPos = Vector3.new(-10172.2529, 138.6893, 6002.4512)
        local standCFrame = CFrame.new(killPos) * CFrame.new(0, 35, 0)
        
        if #zombieList < 6 and not getgenv().SyncKillingZombies then
            getgenv().MainTaskStatus = "SOUL GUITAR"
            getgenv().SubTaskStatus = "Task 1/5: Waiting for Living Zombies (" .. #zombieList .. "/6)"
            MoveTo(standCFrame)
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.zero
                hrp.CFrame = standCFrame
            end
        else
            getgenv().MainTaskStatus = "SOUL GUITAR"
            
            local Net = game:GetService("ReplicatedStorage"):FindFirstChild("Modules") and game:GetService("ReplicatedStorage").Modules:FindFirstChild("Net")
            local regAttack = (Remotes and Remotes["RE/RegisterAttack"]) or (Net and Net:FindFirstChild("RE/RegisterAttack"))
            local regHit = (Remotes and Remotes["RE/RegisterHit"]) or (Net and Net:FindFirstChild("RE/RegisterHit"))
            
            for _, zombie in pairs(zombieList) do
                local root = zombie:FindFirstChild("HumanoidRootPart")
                local hum = zombie:FindFirstChild("Humanoid")
                if root and hum and hum.Health > 0 then
                    root.CFrame = CFrame.new(killPos)
                    root.CanCollide = false
                    if hum:FindFirstChild("Animator") then
                        hum.Animator:Destroy()
                    end
                    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                end
            end
            
            MoveTo(standCFrame)
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - standCFrame.Position).Magnitude <= 20 then
                local bv = hrp:FindFirstChild("FreezeBV") or Instance.new("BodyVelocity")
                bv.Name = "FreezeBV"
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bv.Velocity = Vector3.zero
                bv.Parent = hrp
                hrp.CFrame = standCFrame
            end
            
            EquipWeapon()
            
            table.sort(zombieList, function(a, b)
                local hA = a:FindFirstChild("Humanoid") and a.Humanoid.Health or 0
                local hB = b:FindFirstChild("Humanoid") and b.Humanoid.Health or 0
                return hA > hB
            end)

            local mobsAbove, allBelowThreshold = {}, true
            for _, m in ipairs(zombieList) do
                local hum = m:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    if (hum.Health / hum.MaxHealth) * 100 > 30 then
                        if #mobsAbove < 2 then table.insert(mobsAbove, m) end
                        allBelowThreshold = false
                    end
                end
            end
            
            if allBelowThreshold then
                getgenv().SyncKillingZombies = true
            end

            local targetGroup = getgenv().SyncKillingZombies and zombieList or mobsAbove
            local hitTable, primaryHead = {}, nil
            for _, mob in ipairs(targetGroup) do
                local head = mob:FindFirstChild("Head") or mob:FindFirstChild("HumanoidRootPart")
                if head then
                    if not primaryHead then primaryHead = head end
                    table.insert(hitTable, {mob, head})
                end
            end

            if primaryHead and #hitTable > 0 then
                local net = RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Net")
                local regAttack = (net and net:FindFirstChild("RE/RegisterAttack")) or RS:FindFirstChild("RE/RegisterAttack", true)
                local regHit = (net and net:FindFirstChild("RE/RegisterHit")) or RS:FindFirstChild("RE/RegisterHit", true)

                if regAttack then pcall(function() regAttack:FireServer(-math.huge) end) end
                if not getgenv().SyncKillingZombies then
                    getgenv().SubTaskStatus = "Task 1/5: Balancing health down to 30%"
                    if regHit then pcall(function() regHit:FireServer(primaryHead, hitTable) end) end
                    task.wait(0.2)
                else
                    getgenv().SubTaskStatus = "Task 1/5: Sync Killing All Zombies!"
                    for i = 1, 15 do
                        if regHit then pcall(function() regHit:FireServer(primaryHead, hitTable) end) end
                    end
                    task.wait(0.1)
                end
            end
        end
---------
        elseif currentStage == 2 then
            getgenv().MainTaskStatus = "SOUL GUITAR"
            getgenv().SubTaskStatus = "Task 2/5: Completing placards"
            local W = workspace.Map:FindFirstChild("Haunted Castle")
            if W then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    while (hrp.Position - Vector3.new(-8800.0, 178, 6033)).Magnitude > 10 do
                        task.wait()
                        MoveTo(CFrame.new(-8800.0, 178, 6033))
                    end
                    for h, X in pairs({Placard1 = "Right", Placard2 = "Right", Placard3 = "Left", Placard4 = 'Right', Placard5 = 'Left', Placard6 = 'Left', Placard7 = "Left"}) do
                        if W:FindFirstChild(h) and W[h]:FindFirstChild(X) and W[h][X]:FindFirstChild("ClickDetector") then
                            fireclickdetector(W[h][X].ClickDetector)
                        end
                    end
                    task.wait(5)
                end
            end
        elseif currentStage == 3 then
            commF:InvokeServer("GuitarPuzzleProgress", "Ghost")
            task.wait(5)
        elseif currentStage == 4 then
            getgenv().MainTaskStatus = "SOUL GUITAR"
            getgenv().SubTaskStatus = "Task 4/5: Completing Trophies"
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                while (hrp.Position - Vector3.new(-9530.0126953125, 6.104853630065918, 6054.83349609375)).Magnitude > 30 do
                    task.wait()
                    MoveTo(CFrame.new(-9530.0126953125, 6.104853630065918, 6054.83349609375))
                end
                local W = workspace.Map:FindFirstChild("Haunted Castle")
                if W and W:FindFirstChild("Tablet") then
                    for _, h in pairs(BlankTablets) do
                        local X = W.Tablet:FindFirstChild(h)
                        if X and X:FindFirstChild("Line") and X.Line.Rotation.Z ~= 0 then
                            repeat 
                                task.wait() 
                                if X:FindFirstChild("ClickDetector") then
                                    fireclickdetector(X.ClickDetector)
                                end
                            until X.Line.Rotation.Z == 0
                        end
                    end
                    for h, X in pairs(Trophy) do
                        if W:FindFirstChild("Trophies") and W.Trophies:FindFirstChild("Quest") and W.Trophies.Quest:FindFirstChild(X) then
                            local w = tostring(W.Trophies.Quest[X].Handle.CFrame)
                            w = w:split(", ")[4]
                            local targetZ = "180"
                            if w == "1" or w == "-1" then targetZ = "90" end
                            
                            local tabObj = W.Tablet:FindFirstChild(h)
                            if tabObj and tabObj:FindFirstChild("Line") and not string.find(tostring(tabObj.Line.Rotation.Z), targetZ) then
                                repeat 
                                    task.wait() 
                                    if tabObj:FindFirstChild("ClickDetector") then
                                        fireclickdetector(tabObj.ClickDetector)
                                    end
                                until string.find(tostring(tabObj.Line.Rotation.Z), targetZ)
                            end
                        end
                    end
                    task.wait(5)
                end
            end
        elseif currentStage == 5 then
            getgenv().MainTaskStatus = "SOUL GUITAR"
            getgenv().SubTaskStatus = "Task 5/5: Connecting Pipes"
            local W = workspace.Map:FindFirstChild("Haunted Castle")
            if W and W:FindFirstChild("Lab Puzzle") and W["Lab Puzzle"]:FindFirstChild("ColorFloor") and W["Lab Puzzle"].ColorFloor:FindFirstChild("Model") then
                for pKey, pColor in pairs(Pipes) do
                    pcall(function()
                        local X = W['Lab Puzzle'].ColorFloor.Model:FindFirstChild(pKey)
                        if X and X.BrickColor.Name ~= pColor then
                            repeat 
                                task.wait() 
                                if X:FindFirstChild("ClickDetector") then
                                    fireclickdetector(X.ClickDetector)
                                end
                            until X.BrickColor.Name == pColor
                        end
                    end)
                end
            end
            commF:InvokeServer('soulGuitarBuy')
            task.wait(5)
        elseif currentStage == 6 then
            local hasBones, bonesCount = CheckItem("Bones")
            if bonesCount >= 500 then
                commF:InvokeServer('soulGuitarBuy')
                task.wait(5)
            else
                if not getgenv().AutoMaterial then
                    FarmMaterialLogic("Bones", 500)
                end
            end
        end
    end
end
---------
---------
---------
local function getItemMastery(itemName)
    local targetItemId = nil
    if type(itemName) == "number" then
        targetItemId = itemName
    elseif type(itemName) == "string" then
        targetItemId = GetIdItem(itemName)
    end

    if not targetItemId then return 0 end

    local masteryItems = ItemReplicationService:GetItems(KEYS.MASTERY)
    if masteryItems then
        for _, item in pairs(masteryItems) do
            if item.ItemId == targetItemId then
                return item.Value or 0
            end
        end
    end
    return 0
end

local function _3SwordLegend()
    local missingSwords = {}
    if not CheckItem("Shizu") then table.insert(missingSwords, "swordshizu") end
    if not CheckItem("Oroshi") then table.insert(missingSwords, "swordoroshi") end
    if not CheckItem("Saishi") then table.insert(missingSwords, "swordsaishi") end

    if #missingSwords > 0 then
        if GetCurrentSea() ~= 2 then
            getgenv().MainTaskStatus = "3 SWORD LEGEND"
            getgenv().SubTaskStatus = "Travelling to Sea 2"
            JoinSea(2)
            task.wait(10)
            return true
        end
        
        getgenv().MainTaskStatus = "3 SWORD LEGEND"
        getgenv().SubTaskStatus = "Hopping for Swords: " .. tostring(#missingSwords)
        
        local allCached = true
        for _, hopKey in ipairs(missingSwords) do
            local status = HopToServerByAPI(hopKey, 12, 2)
            if status == true then 
                allCached = false
                return true
            elseif status == "ALL_CACHED" then
                continue
            else
                allCached = false
                return true
            end
        end
        
        if allCached then
            getgenv().SubTaskStatus = "All caches full! Resetting histories..."
            for _, hopKey in ipairs(missingSwords) do
                SaveHistory(hopKey, {}) 
            end
        end
        return true
    end

    local legendSwords = {"Shizu", "Oroshi", "Saishi"}
    local targetSword = nil

    for _, sword in ipairs(legendSwords) do
        local mas = getItemMastery(sword)
        if mas and mas < 300 then
            targetSword = sword
            break
        end
    end

    if targetSword then
        getgenv().MasteryWeapon = targetSword 
        local args = {
            "LoadItem",
            targetSword
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
        
        local allOtherDone = true
        for _, seaData in ipairs(WeaponSeaData) do
            if type(seaData) == "table" and seaData.Weapons then
                for _, wName in ipairs(seaData.Weapons) do
                    local isLegend = false
                    for _, ls in ipairs(legendSwords) do
                        if wName == ls then isLegend = true break end
                    end
                    if not isLegend and wName ~= "True Triple Katana" then
                        local hasItem, _ = CheckItem(wName)
                        if not hasItem then
                            allOtherDone = false
                            break
                        end
                    end
                end
            end
            if not allOtherDone then break end
        end
        
        if allOtherDone then
            if GetCurrentSea() ~= 3 then
                getgenv().MainTaskStatus = "3 SWORD LEGEND"
                getgenv().SubTaskStatus = "Travelling to Sea 3 for Mastery"
                JoinSea(3)
                task.wait(10)
                return true
            end

            getgenv().MainTaskStatus = "FARMING MASTERY"
            getgenv().SubTaskStatus = targetSword .. " Mastery Fallback"
            Config.TargetBossName = "Beautiful Pirate" 
            AutoFarmBoss()
            return true
        else
            return false
        end
    else
        getgenv().MasteryWeapon = nil 
        
        if not CheckItem("True Triple Katana") then
            if GetCurrentSea() ~= 2 then
                getgenv().MainTaskStatus = "3 SWORD LEGEND"
                getgenv().SubTaskStatus = "Travelling to Sea 2 for True Triple Katana"
                JoinSea(2)
                task.wait(10)
                return true
            end
            
            getgenv().MainTaskStatus = "3 SWORD LEGEND"
            getgenv().SubTaskStatus = "Getting True Triple Katana"
            

            local targetPos = CFrame.new(-2572.5742, 1624.5582, -3744.1216)
            local char = LocalPlayer.Character or plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                if (hrp.Position - targetPos.Position).Magnitude > 10 then
                    MoveTo(targetPos)
                else
            if getgenv().stoptp then getgenv().stoptp() end
                    pcall(function()
                        local commF = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
                        local args1 = {
                            "MysteriousMan",
                            "1"
                        }
                        commF:InvokeServer(unpack(args1))
                        
                        task.wait(0.5)
                        
                        local args2 = {
                            "MysteriousMan",
                            "2"
                        }
                        commF:InvokeServer(unpack(args2))
                    end)
                    task.wait(1)
                end
            else
                MoveTo(targetPos)
            end

            return true
        end
        return false
    end
end

local function get_tushita()
    while task.wait(1) do
        local hasItem, _ = CheckItem("Tushita")
        if hasItem then
            break
        end

        local plrData = LocalPlayer:FindFirstChild("Data")
        local level = plrData and plrData:FindFirstChild("Level") and plrData.Level.Value or 0
        if level < 2000 then return end

        if GetCurrentSea() ~= 3 then
            getgenv().MainTaskStatus = "TUSHITA"
            getgenv().SubTaskStatus = "Travelling to Sea 3"
            JoinSea(3)
            task.wait(10)
            return
        end

        local TushitaProgress = replicated.Remotes.CommF_:InvokeServer("TushitaProgress")

        if type(TushitaProgress) == "table" and not TushitaProgress.OpenedDoor then
            Config.TargetBossName = "rip_indra True Form"
            local indra = GetBoss()

            if not indra then
                getgenv().MainTaskStatus = "TUSHITA"
                getgenv().SubTaskStatus = "Hopping for Rip Indra"
                HopToServerByAPI("ripindra", 12, 2)
                return
            else
                getgenv().MainTaskStatus = "TUSHITA"
                getgenv().SubTaskStatus = "Placing Torches"
                local targetPos = CFrame.new(5714, 20, 256)
                if getgenv().TP then
                    getgenv().TP(targetPos)
                else
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = targetPos end
                end

                local hasTorch = false
                if LocalPlayer.Backpack:FindFirstChild("Holy Torch") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Holy Torch")) then
                    hasTorch = true
                end

                if hasTorch then
                    for W = 1, 5 do
                        replicated.Remotes.CommF_:InvokeServer("TushitaProgress", "Torch", W)
                        task.wait(0.5)
                    end
                end
            end
        else
            Config.TargetBossName = "Longma"
            local longma = GetBoss()
            if longma then
                getgenv().MainTaskStatus = "TUSHITA"
                getgenv().SubTaskStatus = "Defeating Longma"
                AutoFarmBoss()
            else
                HopServer()
                return
            end
        end
    end
end

local function checkBisentoVersion()
    local isV2 = LocalPlayer:GetAttribute("BisentoEvolution")
    
    if isV2 then
        print("Bisento: V2")
        return "V2"
    else
        print("Bisento: V1")
        return "V1"
    end
end

local function GetGreybeardRespawnTime()
    local ws = game:GetService("Workspace")
    local worldOrigin = ws:FindFirstChild("_WorldOrigin")
    if not worldOrigin then
        return nil
    end
    
    local marker = worldOrigin:FindFirstChild("GREYBEARD Respawn Marker")
    if not marker then
        return nil
    end
    
    local respawnTimer = marker:FindFirstChild("RespawnTimer")
    if respawnTimer then
        local frame = respawnTimer:FindFirstChild("Frame")
        if frame then
            local timerLabel = frame:FindFirstChild("Timer")
            if timerLabel and timerLabel:IsA("TextLabel") then
                local rawText = timerLabel.Text
                
                local cleanText = string.gsub(rawText, "<[^>]+>", "")
                cleanText = string.gsub(cleanText, "%s+", "")
                
                local hourStr, minStr, secStr = string.match(cleanText, "(%d+):(%d+):(%d+)")
                if hourStr and minStr and secStr then
                    local hours = tonumber(hourStr)
                    local minutes = tonumber(minStr)
                    local seconds = tonumber(secStr)
                    return (hours * 3600) + (minutes * 60) + seconds
                end
                
                local mStr, sStr = string.match(cleanText, "(%d+):(%d+)")
                if mStr and sStr then
                    local minutes = tonumber(mStr)
                    local seconds = tonumber(sStr)
                    return (minutes * 60) + seconds
                end
                
                local singleNumber = tonumber(string.match(cleanText, "%d+"))
                if singleNumber then
                    return singleNumber
                end
            end
        end
    end
    
    return nil
end

local function get_bisento_v2()
    Config.TargetBossName = "Greybeard"
    
    local boss = GetBoss()
    if not boss then
        local timeLeft = GetGreybeardRespawnTime()
        if timeLeft and timeLeft <= 900 then
            while task.wait(1) do
                local t = GetGreybeardRespawnTime()
                if GetBoss() then 
                    break 
                end
                
                if t then
                    getgenv().MainTaskStatus = "WAITING BOSS SPAWN TIME < 15Min"
                    getgenv().SubTaskStatus = "Greybeard spawns in: " .. tostring(t) .. "s"
                else
                    break
                end
            end
        end
    end
    EquipItemInv("Bisento")
    AutoFarmBoss()
    task.wait(1)
    if checkBisentoVersion() == "V2" then
        print("Bisento has evolved to V2!")
    end
end
---------
---------
local function get_saber()
    while true do
        local hasSaber, _ = CheckItem("Saber")
        if hasSaber then
            break
        end

        local plrData = LocalPlayer:FindFirstChild("Data")
        local level = plrData and plrData:FindFirstChild("Level") and plrData.Level.Value or 0
        if level < 200 then
            break
        end

        if GetCurrentSea() ~= 1 then
            getgenv().MainTaskStatus = "SABER QUEST"
            getgenv().SubTaskStatus = "Travelling to Sea 1"
            JoinSea(1)
            task.wait(10)
            return
        end

        local commF = replicated:WaitForChild("Remotes"):WaitForChild("CommF_")
        local progress = commF:InvokeServer("ProQuestProgress")
        
        local stage = 0
        if type(progress) == "table" then
            local allPlates = true
            if type(progress.Plates) == "table" then
                for _, pressed in pairs(progress.Plates) do
                    if pressed == false then
                        allPlates = false
                        break
                    end
                end
            else
                allPlates = false
            end

            if not allPlates then
                stage = 1
            elseif not progress.UsedTorch then
                stage = 2
            elseif not progress.UsedCup then
                stage = 3
            elseif not progress.TalkedSon then
                stage = 4
            elseif not progress.KilledMob then
                stage = 5
            elseif not progress.UsedRelic then
                stage = 6
            elseif not progress.KilledShanks then
                stage = 7
            end
        end

        if stage == 1 then
            getgenv().MainTaskStatus = "SABER QUEST"
            getgenv().SubTaskStatus = "Touching Quest Plates"
            local jungleMap = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Jungle")
            if jungleMap and jungleMap:FindFirstChild("QuestPlates") then
                for _, plate in pairs(jungleMap.QuestPlates:GetChildren()) do
                    local btn = plate:FindFirstChild("Button")
                    if btn then
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            while (hrp.Position - btn.Position).Magnitude > 5 do
                                MoveTo(btn.CFrame)
                                task.wait()
                                hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if not hrp then break end
                            end
                            task.wait(0.5)
                        end
                    end
                end
            end
            task.wait(1)
        elseif stage == 2 then
            getgenv().MainTaskStatus = "SABER QUEST"
            getgenv().SubTaskStatus = "Using Torch"
            commF:InvokeServer("ProQuestProgress", "GetTorch")
            task.wait(1)
            commF:InvokeServer("ProQuestProgress", "DestroyTorch")
            task.wait(1)
        elseif stage == 3 then
            getgenv().MainTaskStatus = "SABER QUEST"
            getgenv().SubTaskStatus = "Filling Cup for Sick Man"
            commF:InvokeServer("ProQuestProgress", "GetCup")
            task.wait(0.5)
            
            local char = LocalPlayer.Character
            local cupTool = LocalPlayer.Backpack:FindFirstChild("Cup") or (char and char:FindFirstChild("Cup"))
            if cupTool and char and char:FindFirstChild("Humanoid") then
                char.Humanoid:EquipTool(cupTool)
                task.wait(0.5)
                commF:InvokeServer("ProQuestProgress", "FillCup", cupTool)
                task.wait(0.5)
            end
            commF:InvokeServer("ProQuestProgress", "SickMan")
            task.wait(1)
        elseif stage == 4 then
            getgenv().MainTaskStatus = "SABER QUEST"
            getgenv().SubTaskStatus = "Talking to Rich Son"
            commF:InvokeServer("ProQuestProgress", "RichSon")
            task.wait(1)
        elseif stage == 5 then
            getgenv().MainTaskStatus = "SABER QUEST"
            getgenv().SubTaskStatus = "Defeating Mob Leader"
            Config.TargetBossName = "Mob Leader"
            AutoFarmBoss()
            task.wait(1)
        elseif stage == 6 then
            getgenv().MainTaskStatus = "SABER QUEST"
            getgenv().SubTaskStatus = "Placing Relic"
            commF:InvokeServer("ProQuestProgress", "RichSon")
            task.wait(1)
            commF:InvokeServer("ProQuestProgress", "PlaceRelic")
            task.wait(1)

        elseif stage == 7 then
            Config.TargetBossName = "Saber Expert"
            local boss = GetBoss()
            if boss then
                getgenv().MainTaskStatus = "SABER QUEST"
                getgenv().SubTaskStatus = "Defeating Saber Expert"
                AutoFarmBoss()
            else
                getgenv().MainTaskStatus = "SABER QUEST"
                getgenv().SubTaskStatus = "Hopping for Saber Expert"
                if type(HopServer) == "function" then
                    HopServer()
                elseif type(getgenv().HopServerFunc) == "function" then
                    getgenv().HopServerFunc()
                end
                return
            end
        end
        task.wait(1)
    end
end

local function StartKaitunWeapons()
    local function WeaponStep()
            for _, seaData in ipairs(WeaponSeaData) do
                if type(seaData) == "table" and seaData.Weapons then
                    for _, weaponName in ipairs(seaData.Weapons) do
                        local hasItem, _ = CheckItem(weaponName)
                        getgenv().MainTaskStatus = "WEAPON TRACKER"
                        getgenv().SubTaskStatus = "Checking: " .. tostring(weaponName)
                        if weaponName == "Saber" and not hasItem then
                            get_saber()
                            return
                        end
                        if weaponName == "Tushita" and not hasItem then
                            get_tushita()
                            return
                        end
                        if weaponName == "Skull Guitar" and not hasItem then
                            AutoSoulGuitar()
                            return
                        end
                        if weaponName == "Bisento" and hasItem and checkBisentoVersion() == "V1" then
                            local bossData = BossDrops["Bisento"]
                            if bossData then
                                if GetCurrentSea() ~= bossData.Sea then
                                    JoinSea(bossData.Sea)
                                    task.wait()
                                    return
                                else
                                    get_bisento_v2()
                                    return
                                end
                            end
                        end

                    if weaponName == "Hallow Scythe" and not hasItem then
                            local bossData = BossDrops["Hallow Scythe"]
                            if bossData then
                                if GetCurrentSea() ~= bossData.Sea then
                                    JoinSea(bossData.Sea)
                                    task.wait()
                                    return
                                else
                                    get_hallow_scythe()
                                    return
                                end
                            end
                        end

                        if weaponName == "Shizu" or weaponName == "Oroshi" or weaponName == "Saishi" or weaponName == "True Triple Katana" then
                            local hasShizu = CheckItem("Shizu")
                            local hasOroshi = CheckItem("Oroshi")
                            local hasSaishi = CheckItem("Saishi")

                            local masShizu = getItemMastery("Shizu")
                            local masOroshi = getItemMastery("Oroshi")
                            local masSaishi = getItemMastery("Saishi")

                            local needLegend = (not hasShizu) or (not hasOroshi) or (not hasSaishi) or (hasShizu and masShizu < 300) or (hasOroshi and masOroshi < 300) or (hasSaishi and masSaishi < 300)

                            if needLegend then
                                local isBlocking = _3SwordLegend()
                                if isBlocking then return end
                            elseif weaponName == "True Triple Katana" and not hasItem then
                                local isBlocking = _3SwordLegend()
                                if isBlocking then return end
                            end
                            
                        elseif not hasItem then
                            local bossData = BossDrops[weaponName]
                            if bossData then
                                print("Target Weapon: " .. weaponName)
                                if GetCurrentSea() ~= bossData.Sea then
                                    JoinSea(bossData.Sea)
                                    task.wait() 
                                    return
                                else
                                    Config.TargetBossName = bossData.Boss
                                    AutoFarmBoss()
                                    return 
                                end
                            end
                        end
                    end
                end
            end
            getgenv().MainTaskStatus = "WEAPON TRACKER"
            getgenv().SubTaskStatus = "All selected weapons obtained"
    end
    task.spawn(function()
        while task.wait(1) do
            local ok, err = pcall(WeaponStep)
            if not ok then warn("[Weapon Kaitun] " .. tostring(err)) end
        end
    end)
end
---------

StartKaitunWeapons()


-- webhook (optional)
local function SendWeaponWebhook(title, desc)
    if not (Cfg.WebHook.Enable and Cfg.WebHook.Url ~= "") then return end
    task.spawn(function()
        pcall(function()
            local req = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
            if not req then return end
            req({
                Url = Cfg.WebHook.Url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = game:GetService("HttpService"):JSONEncode({
                    username = "FLOWBR Weapon Kaitun",
                    embeds = {{
                        title = title,
                        description = desc,
                        color = 0xFFFFFF,
                        footer = {text = "FLOWBR | " .. game:GetService("Players").LocalPlayer.Name},
                        timestamp = DateTime.now():ToIsoDate(),
                    }}
                })
            })
        end)
    end)
end

task.spawn(function()
    local lastOwned = -1
    local total = #AllWeaponsList
    local ownedMap = {}
    local firstScan = true
    local lastReport = 0

    while task.wait(1) do
    local __okT, __errT = pcall(function()
        local countOwned = 0
        local newly = {}
        local currentFound = false

        for _, weaponName in ipairs(AllWeaponsList) do
            local hasItem, _ = CheckItem(weaponName)
            local row = WeaponRows[weaponName]
            if hasItem then
                countOwned = countOwned + 1
                if not ownedMap[weaponName] then
                    ownedMap[weaponName] = true
                    if not firstScan then table.insert(newly, weaponName) end
                end
            end
            if row then
                if hasItem then
                    row.status.Text = "OWNED"
                    row.status.TextColor3 = Color3.fromRGB(90, 220, 130)
                    row.name.TextColor3 = Theme.Text
                elseif not currentFound then
                    currentFound = true
                    row.status.Text = "FARMING"
                    row.status.TextColor3 = Color3.fromRGB(255, 205, 90)
                    row.name.TextColor3 = Color3.fromRGB(255, 205, 90)
                else
                    row.status.Text = "MISSING"
                    row.status.TextColor3 = Color3.fromRGB(200, 90, 90)
                    row.name.TextColor3 = Theme.TextDim
                end
            end
        end

        if countOwned ~= lastOwned then
            lastOwned = countOwned
            local missing = total - countOwned
            local curOwned = countOwned

            task.defer(function()
                WeaponUI_API.SetOwned(curOwned, total)
                WeaponUI_API.SetMissing(missing)
            end)
        end

        for _, w in ipairs(newly) do
            SendWeaponWebhook("New weapon obtained", "**" .. w .. "**\nOwned: " .. countOwned .. " / " .. total)
        end
        firstScan = false

        if Cfg.WebHook.Enable and os.time() - lastReport >= Cfg.WebHook.Interval then
            lastReport = os.time()
            local missingList = {}
            for _, w in ipairs(AllWeaponsList) do if not ownedMap[w] then table.insert(missingList, w) end end
            SendWeaponWebhook("Weapon Kaitun status",
                "Owned: " .. countOwned .. " / " .. total ..
                "\nMissing: " .. (#missingList > 0 and table.concat(missingList, ", ") or "none") ..
                "\nTask: " .. tostring(getgenv().MainTaskStatus) .. " | " .. tostring(getgenv().SubTaskStatus))
        end
    end)
    if not __okT then warn("[Weapon Kaitun] tracker: " .. tostring(__errT)) end
    end
end)

end


if __Mode == "leviathan" then
    RunLeviathan(__UserConfig)
elseif __Mode == "weapon" then
    RunWeapon(__UserConfig)
else
    if __Mode ~= "farm" then warn("[FLOWBR] unknown mode '" .. __Mode .. "', using farm") end
    RunFarm(__UserConfig)
end
