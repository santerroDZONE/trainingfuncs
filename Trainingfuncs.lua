script_name("Training Funcs")
script_version("1.0")
script_author("default.zone") -- кто поменяет тот завтра умрет

require "lib.moonloader"
local sampev = require "lib.samp.events"
local vk = require "vkeys"
local ffi = require 'ffi'

local imgui = require 'mimgui'
local tf = imgui.new 
local main_window = tf.bool()

local ffi, str, sizeof = imgui.new, ffi.string, ffi.sizeof

local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local inicfg = require "inicfg"
local iniSettings = inicfg.load({
    settings = {
        password = "",
        hidecursor = false,
    },
}, "../trainingfuncs")
local direct = "..//trainingfuncs.ini"

function tochat(arg)
    sampAddChatMessage("[Training Funcs]:{FFFFFF} " .. arg, 0x007D1C)
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    if sampGetCurrentServerAddress() ~= "37.230.162.117" then
        tochat("Скрипт работает только на {007D1C}TRAINING - SANDBOX{FFFFFF}.")
        script:unload()
    else
        tochat("Скрипт загружен! Автор {007D1C}default.zone{FFFFFF} | Активация {007D1C}/tfuncs{FFFFFF}.")
    end

    if not doesFileExist("trainingfuncs.ini") then
        inicfg.save(iniSettings, direct)
    end
    
    imgui.Process = false

    while true do
        wait(0)
    end
end

sampRegisterChatCommand("tfuncs", function()
    main_window[0] = not main_window[0]
    imgui.Process = main_window[0]
end)

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function imgui.TextQuestion(label, description)
    imgui.TextDisabled(label)

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    green_theme()
end)

local selectedTab = 1
local setPassword_input = tf.char[32]("")
local hideCursor_checkbox = tf.bool(iniSettings.settings.hidecursor)
local autoads_inputBuffer = tf.char[144]("")
local autoads_checkbox = tf.bool(true)

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
            imgui.BeginGroup()
                imgui.BeginChild('Settings', imgui.ImVec2(0, 0), true)
                    imgui.BeginChild("setpassword_0x1", imgui.ImVec2(264, 60), true)
                        imgui.PushItemWidth(175)
                        imgui.InputText("##setpassword", setPassword_input, sizeof(setPassword_input))
                        imgui.SameLine()
                        imgui.SetCursorPosX(180)
                        if imgui.Button(u8"Установить") then
                            if setPassword_input == nil then
                                tochat("Введите свой пароль.")
                            else
                                iniSettings.settings.password = setPassword_input.v
                                if inicfg.save(iniSettings, direct) then
                                    tochat("Пароль установлен:{007D1C} " .. iniSettings.settings.password)
                                end
                            end
                        end
                        if imgui.Button(u8"Текущий пароль") then
                            if iniSettings.settings.password ~= "" then
                                tochat("Текущий пароль:{007D1C} " .. iniSettings.settings.password)
                            else
                                tochat("Пароль не установлен.")
                            end
                        end
                        imgui.SameLine()
                        if imgui.Button(u8"Сбросить пароль") then
                            if iniSettings.settings.password ~= "" then
                                iniSettings.settings.password = ""
                                if inicfg.save(iniSettings, direct) then
                                    tochat("Пароль сброшен.")
                                end
                            else
                                tochat("Пароль не установлен.")
                            end
                        end
                        imgui.SameLine()
                        imgui.TextQuestion("( ? )", u8"Автоматическая авторизация, скорость захода на сервер зависит от текущего пинга.")
                    imgui.EndChild()
                    imgui.SameLine()
                    imgui.BeginChild("autoads", imgui.ImVec2(0, 60), true)
                        imgui.InputText("##autoads_inputText", autoads_inputBuffer, sizeof(autoads_inputBuffer))
                        imgui.SameLine()
                        if imgui.Button(u8"Установить##autoads_setButton") then

                        end
                        if imgui.Button(u8"Текст рекламы##autoads_printText") then

                        end
                        imgui.SameLine()
                        if imgui.Button(u8"Сбросить текст##autoads_resetText") then

                        end
                        imgui.SameLine()
                    imgui.EndChild()
                    if imgui.Checkbox(u8"Убирать курсор после входа на сервер", hideCursor_checkbox) then
                        iniSettings.settings.hidecursor = hideCursor_checkbox.v
                        inicfg.save(iniSettings, direct)
                    end
                    imgui.SameLine()
                    imgui.TextQuestion("( ? )", u8"Убирает курсор после входа на сервер. Работает только если стоит пинкод!")
                    imgui.SameLine()
                    if imgui.Checkbox(u8"Автореклама", autoads_checkbox) then

                    end
                    imgui.SameLine()
                    imgui.TextQuestion("( ? )", u8"Автореклама. Задержка 120 секунд.")
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
		return false
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
