script_name("Training Funcs")
script_version("1.0")
script_authors("default.zone", "Gerald.myr") -- кто поменяет тот завтра умрет

require "lib.moonloader"

local scriptVersion = 2
local updState = false

local scriptPath = thisScript().path
local scriptUrl = 'https://raw.githubusercontent.com/santerroDZONE/trainingfuncs/main/Trainingfuncs.lua'
local updatePath = getWorkingDirectory() .. '/tfUpdate.ini'
local updateUrl = 'https://raw.githubusercontent.com/santerroDZONE/trainingfuncs/main/tfUpdate.ini'

local dlstatus = require('moonloader').download_status

local fa = require("fAwesome5")
local sampev = require "lib.samp.events"
local vk = require "vkeys"
local ffi = require 'ffi'

local imgui = require 'mimgui'
local tf, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local main_window = tf.bool()

local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local inicfg = require "inicfg"
local iniSettings = inicfg.load({
    settings = {
        password = "",
        hidecursor = false,
        autoads = false,
        autoworld = false,
        autoupdate = true,
    },
    veh = {
        vehFirst = false,
        vehSecond = false,
    },
}, "../trainingfuncs")
local direct = "..//trainingfuncs.ini"

function tochat(arg)
    sampAddChatMessage("[Training Funcs]:{FFFFFF} " .. arg, 0x25D500)
end

--[[WORLD DIALOG 32700 id, 2 style, title nil, button first Y, button second X
    VW DIALOG 32700 id, style 4, title nil, button first Y, button second X]]

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    if sampGetCurrentServerAddress() ~= "37.230.162.117" then
        tochat("Скрипт работает только на {25D500}TRAINING - SANDBOX{FFFFFF}.")
        script:unload()
    else
        tochat("Скрипт загружен! Авторы: {25D500}default.zone{FFFFFF} и {25D500}Gerald.myr{FFFFFF} | Активация {25D500}/tfuncs")
    end

    if not doesFileExist("trainingfuncs.ini") then inicfg.save(iniSettings, direct) end


	downloadUrlToFile(updateUrl, updatePath, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			local updCfg = inicfg.load(nil, updatePath)
			if tonumber(updCfg.info.version) > scriptVersion then
				tochat('Найдена новая версия скрипта!')
				updState = true
			end
			os.remove(updatePath)
		end
	end)

    while true do
        wait(0)

        if updState then
			downloadUrlToFile(scriptUrl, scriptPath, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					tochat('Скрипт успешно обновлён!')
					thisScript():reload()
				end
			end)
			break
		end
        
        if iniSettings.veh.vehFirst == true and isKeyJustPressed(VK_L) and not sampIsChatInputActive() and not sampIsDialogActive() then
            if isKeyDown(VK_L) and not sampIsChatInputActive() and not sampIsDialogActive() then
                sampSendChat("/lock")
            end
        end
    end
end

sampRegisterChatCommand("tfuncs", function()
    main_window[0] = not main_window[0]
end)

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local col = imgui.Col
    
    local designText = function(text__)
        local pos = imgui.GetCursorPos()
        if sampGetChatDisplayMode() == 2 then
            for i = 1, 1 --[[Степень тени]] do
                imgui.SetCursorPos(imgui.ImVec2(pos.x + i, pos.y))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
                imgui.SetCursorPos(imgui.ImVec2(pos.x - i, pos.y))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
                imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y + i))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
                imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y - i))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
            end
        end
        imgui.SetCursorPos(pos)
    end
    
    
    
    local text = text:gsub('{(%x%x%x%x%x%x)}', '{%1FF}')

    local color = colors[col.Text]
    local start = 1
    local a, b = text:find('{........}', start)   
    
    while a do
        local t = text:sub(start, a - 1)
        if #t > 0 then
            designText(t)
            imgui.TextColored(color, t)
            imgui.SameLine(nil, 0)
        end

        local clr = text:sub(a + 1, b - 1)
        if clr:upper() == 'STANDART' then color = colors[col.Text]
        else
            clr = tonumber(clr, 16)
            if clr then
                local r = bit.band(bit.rshift(clr, 24), 0xFF)
                local g = bit.band(bit.rshift(clr, 16), 0xFF)
                local b = bit.band(bit.rshift(clr, 8), 0xFF)
                local a = bit.band(clr, 0xFF)
                color = imgui.ImVec4(r / 255, g / 255, b / 255, a / 255)
            end
        end

        start = b + 1
        a, b = text:find('{........}', start)
    end
    imgui.NewLine()
    if #text >= start then
        imgui.SameLine(nil, 0)
        designText(text:sub(start))
        imgui.TextColored(color, text:sub(start))
    end
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function imgui.TextQuestionSameLine(label, description)
    imgui.SameLine()
    imgui.TextDisabled(label)

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextColoredRGB("{25D500}"..fa.ICON_FA_INFO_CIRCLE..u8" Подсказка:")
                imgui.TextUnformatted("\n"..description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

imgui.OnInitialize(function()
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local iconRanges = imgui.new.ImWchar[3](fa.min_range, fa.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromFileTTF('trebucbd.ttf', 14.0, nil, glyph_ranges)
    icon = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 14.0, config, iconRanges)
    
    imgui.GetIO().IniFilename = nil
    green_theme()
end)

local selectedTab = 1
local setPassword_input, autoads_inputBuffer, notepad = tf.char[32](""), tf.char[144](""), tf.char[65535]("")
local vehFirst, vehSecond = tf.bool(iniSettings.veh.vehFirst), tf.bool(iniSettings.veh.vehSecond) 

local main_window = imgui.OnFrame(

    function() return main_window[0] end,
    function(player)
        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(700, 500), imgui.Cond.FirstUseEver)
        
        imgui.Begin("Training funcs", main_window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.BeginGroup()
            imgui.BeginChild('Select', imgui.ImVec2(100, 0), true)
            if imgui.Selectable(u8'Настройки', selectedTab == 1) then selectedTab = 1 end
            if imgui.Selectable(u8'Информация', selectedTab == 2) then selectedTab = 2 end
            if imgui.Selectable(u8'Блокнот', selectedTab == 3) then selectedTab = 3 end
            imgui.EndChild()
        imgui.EndGroup()
        imgui.SameLine()

        if selectedTab == 1 then
                imgui.BeginChild('Settings', imgui.ImVec2(0, 0), true)
                imgui.BeginGroup()
                    -- 
                    imgui.BeginGroup()
                        imgui.BeginChild('##autologin', imgui.ImVec2(0, 100), true)
                        local hideCursor_checkbox, autoads_checkbox, autoworld_checkbox = tf.bool(iniSettings.settings.hidecursor), tf.bool(iniSettings.settings.autoads), tf.bool(iniSettings.settings.autoworld)
                            if imgui.Checkbox(u8"Убирать курсор после входа на сервер", hideCursor_checkbox) then
                                iniSettings.settings.hidecursor = hideCursor_checkbox[0]
                                inicfg.save(iniSettings, direct)
                            end
                            imgui.TextQuestionSameLine("( ? )", u8"Убирает курсор после входа на сервер.\nРаботает только если стоит пинкод.")
                            if imgui.Checkbox(u8"Автореклама", autoads_checkbox) then
                                iniSettings.settings.autoads = autoads_checkbox[0]
                                inicfg.save(iniSettings, direct)
                            end
                            imgui.TextQuestionSameLine("( ? )", u8"Автореклама. Задержка 120 секунд.")
                            if imgui.Checkbox(u8"/world при заходе на сервер", autoworld_checkbox) then
                                iniSettings.settings.autoworld = autoworld_checkbox[0]
                                inicfg.save(iniSettings, direct)
                            end
                            imgui.TextQuestionSameLine("( ? )", u8"/world при заходе на сервер\nСоздает виртуальный мир при заходе на сервер.")
                        imgui.EndChild()
                        --[[ INPUT PASSWORD ]]--
                        dontshow = true
                        imgui.InputText(u8'Введите пароль от карты', pass, dontshow and imgui.InputTextFlags.Password or 0)
                        imgui.SameLine()
                        if imgui.Button("ShowPass") then
                            dontshow = not dontshow
                        end
                        imgui.BeginChild('vehfuncs_t', imgui.ImVec2(0, 62), true)
                        if imgui.Checkbox(u8"Закрыть/открыть транспорт на L", vehFirst) then
                            iniSettings.veh.vehFirst = vehFirst[0]
                            inicfg.save(iniSettings, direct)
                        end
                        if imgui.Checkbox(u8"Автоматически завести двигатель при посадке в т/c", vehSecond) then
                            iniSettings.veh.vehSecond = vehSecond[0]
                            inicfg.save(iniSettings, direct)
                        end
                        imgui.TextQuestionSameLine('( ? )', u8"Автоматически завести двигатель при посадке в т/c.\nНе работает если машина, в которой вы находитесь\nбыла только что создана командой /veh <car>.\n\nСпасибо lester'у за идею для двух функций.")
                    imgui.EndChild()
                imgui.EndGroup()
                    --
                imgui.EndChild()
            imgui.EndGroup()
        end

        if selectedTab == 2 then
            imgui.BeginGroup()
                imgui.BeginChild('About', imgui.ImVec2(0, 0), true)
                imgui.Text('About')
                imgui.EndChild()
            imgui.EndGroup()
        end
        
        if selectedTab == 3 then
            imgui.BeginGroup()
                imgui.BeginChild('notepad', imgui.ImVec2(0, 0), true)
                imgui.InputTextMultiline('##notepad', notepad, 65535, imgui.ImVec2(0, 0), imgui.Cond.FirstUseEver)
                imgui.EndChild()
            imgui.EndGroup()
        end

        imgui.End()
    end
)

function sampev.onShowDialog(dialogid, dialogstyle, dialogtitle, button1, button2, text)
	if dialogstyle == 0 and button1 == "Принимаю" then
		sampSendDialogResponse(dialogid, 0, nil, nil)
        return false
	end
	if dialogstyle == 3 and button1 == "Войти" and button2 == "Уйти" and iniSettings.settings.password ~= "" then
        if iniSettings.settings.hidecursor and sampIsCursorActive() then setVirtualKeyDown(27, true) end
		sampSendDialogResponse(dialogid, 3, nil, iniSettings.settings.password)
        if iniSettings.settings.autoworld then
            sampSendChat("/world")
            sampSendDialogResponse(sampGetCurrentDialogId(), 2, 1, nil)
        end
		return false
	end
end

function onSendRpc(id, bs)
    if iniSettings.veh.vehSecond then
        if id == 26 --[[ EnterVehicle ]] then
            lua_thread.create(function()
                while not isCharInAnyCar(PLAYER_PED) do wait(0) end
                sampSendChat('/en')
            end)
        end
    end
end

function green_theme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    imgui.GetStyle().WindowPadding = imgui.ImVec2(8, 8)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 3)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 4)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(4, 4)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 21
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 8

    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 1
    imgui.GetStyle().ChildBorderSize = 1
    imgui.GetStyle().PopupBorderSize = 1
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 1

    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 6
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().FrameRounding = 3
    imgui.GetStyle().PopupRounding = 3
    imgui.GetStyle().ScrollbarRounding = 13
    imgui.GetStyle().GrabRounding = 1
    imgui.GetStyle().TabRounding = 1

    colors[clr.FrameBg]                = ImVec4(0.25, 0.29, 0.20, 1.00)
    colors[clr.FrameBgHovered]         = ImVec4(0.12, 0.20, 0.28, 1.00)
    colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00)
    colors[clr.TitleBg]                = ImVec4(0.09, 0.12, 0.14, 0.65)
    colors[clr.TitleBgActive]          = ImVec4(0.35, 0.58, 0.06, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.72, 1.00, 0.28, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.43, 0.57, 0.05, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.55, 0.67, 0.15, 1.00)
    colors[clr.Button]                 = ImVec4(0.40, 0.57, 0.01, 1.00)
    colors[clr.ButtonHovered]          = ImVec4(0.45, 0.69, 0.07, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.27, 0.50, 0.00, 1.00)
    colors[clr.Header]                 = ImVec4(0.20, 0.25, 0.29, 0.55)
    colors[clr.HeaderHovered]          = ImVec4(0.72, 0.98, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.74, 0.98, 0.26, 1.00)
    colors[clr.Separator]              = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.60, 0.60, 0.70, 1.00)
    colors[clr.SeparatorActive]        = ImVec4(0.70, 0.70, 0.90, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.68, 0.98, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.72, 0.98, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.25, 1.00, 0.00, 0.43)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 0.78)
    colors[clr.TextDisabled]           = ImVec4(0.36, 0.42, 0.47, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.11, 0.15, 0.17, 1.00)
    colors[clr.ChildBg]                = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39)
    colors[clr.ScrollbarGrab]          = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.09, 0.21, 0.31, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
end
