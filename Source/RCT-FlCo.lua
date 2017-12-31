--[[
	---------------------------------------------------------
    RCT Flight Counter 
    
    RCT Flight Counter is a simple flight counter that
    uses any switch. When switch have been active for set
    time flight counter-value is added with one.
    
    Requires transmitter firmware 4.22 or higher.
    
    Works in DC/DS-14/16/24 woth firmware 4.22 and up
	---------------------------------------------------------
	Localisation-file has to be as /Apps/Lang/RCT-FlCo.jsn
	---------------------------------------------------------
	RCT Flight Counter is part of RC-Thoughts Jeti Tools.
	---------------------------------------------------------
	Released under MIT-license by Tero @ RC-Thoughts.com 2017
	---------------------------------------------------------
--]]
--------------------------------------------------------------------------------
-- Locals for application
local flightCount, actTime, countSet, counterSw = 0, 1, 0
local startTime, curTime, timeSet = 0, 0, 0
--------------------------------------------------------------------------------
-- Read and set translations
local function setLanguage()
    local lng=system.getLocale()
    local file = io.readall("Apps/Lang/RCT-FlCo.jsn")
    local obj = json.decode(file)
    if(obj) then
        trans21 = obj[lng] or obj[obj.default]
    end
end
----------------------------------------------------------------------
-- Draw telemetry screen for main display
local function printCounter1()
	lcd.drawText(145 - lcd.getTextWidth(FONT_BIG,string.format("%.0f", flightCount)),0,string.format("%.0f", flightCount),FONT_BIG)
end
----------------------------------------------------------------------
-- Actions when settings changed
local function counterSwChanged(value)
    local pSave = system.pSave
	counterSw = value
	pSave("counterSw", value)
end

local function actTimeChanged(value)
    local pSave = system.pSave
	actTime = value
	pSave("actTime", value)
end

local function flightCountChanged(value)
    local pSave = system.pSave
	flightCount = value
	pSave("flightCount", value)
end
--------------------------------------------------------------------------------
-- Draw the main form (Application inteface)
local function initForm()
    local form, addRow, addLabel = form, form.addRow ,form.addLabel
    local addIntbox, addCheckbox = form.addIntbox, form.addCheckbox
    local addSelectbox, addInputbox = form.addSelectbox, form.addInputbox
    
    addRow(1)
    addLabel({label="---     RC-Thoughts Jeti Tools      ---",font=FONT_BIG})
    
    addRow(2)
    addLabel({label=trans21.swCount, width=220})
    addInputbox(counterSw, true, counterSwChanged)
    
    addRow(2)
    addLabel({label=trans21.actTime, width=220})
    addIntbox(actTime, 1, 600, 0, 0, 1, actTimeChanged)
    
    addRow(2)
    addLabel({label=trans21.curCount, width=220})
    addIntbox(flightCount, -0, 10000, 0, 0, 1, flightCountChanged)
    
    addRow(1)
    addLabel({label="Powered by RC-Thoughts.com - v."..flightCounterVersion.." ", font=FONT_MINI, alignRight=true})
    collectgarbage()
end
--------------------------------------------------------------------------------
local function loop()
	local switchState  = system.getInputsVal(counterSw)
    curTime = system.getTime()
    if(counterSw and switchState == 1) then
        if(timeSet == 0) then
            startTime = system.getTime()
            timeSet = 1
        end
        if (curTime >= (startTime + actTime) and countSet == 0) then
            flightCount = flightCount + 1
            system.pSave("flightCount", flightCount)
            countSet = 1
        end
        else
        countSet = 0
        timeSet = 0
    end
    collectgarbage()
end
--------------------------------------------------------------------------------
local function init()
    local pLoad, registerForm = system.pLoad, system.registerForm
	counterSw = pLoad("counterSw")
    actTime = pLoad("actTime", 1)
    flightCount = pLoad("flightCount", 0)
    counterLabel = pLoad("cntLb1",trans21.appName)
    system.registerTelemetry(1,counterLabel,1,printCounter1)
    registerForm(1, MENU_APPS, trans21.appName, initForm)
    collectgarbage()
end
--------------------------------------------------------------------------------
flightCounterVersion = "1.0"
setLanguage()
collectgarbage()
return {init=init, loop=loop, author="RC-Thoughts", version=flightCounterVersion, name=trans21.appName}
