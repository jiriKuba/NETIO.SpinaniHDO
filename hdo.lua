------------Section 1------------
local region = "Vychod" -- options: Vychod, Stred, Sever, Zapad, Morava
local code = "A1B6DP1" -- povel, kód, nebo kód povelu
local baseApiUrl = "https://www.cez.cz/edee/content/sysutf/ds3/data/hdo_data.json" -- CEZ api for getting hdo by parameters (obtained by monitoring of request from the CEZ web site)

local states = {} 
local initialState = "0000" -- state to which outputs will be set after restart (0-5) 
local onState = "1111" -- state when HDO is on 
local offState = "0000" -- state when HDO is off  
local shortTimeMs = 1000 -- time used for action 2 and 3 [milliseconds]
local sortedStates = {}
local swapped = false
---------End of Section 1---------

-- uncomment this for VS Code debug
---------NETIO MOCK METHODS-------
-- require "netioMock"
-- local cezValidJsonString = "[{\"id\":\"6280\",\"validFrom\":\"1. 4. 2019\",\"validTo\":\"1. 1. 2099\",\"dumpId\":\"27\",\"povel\":\"181\",\"kodPovelu\":\"A1B6Dp1\",\"sazba\":\"D45d\",\"info\":\"sazba\",\"platnost\":\"Po - Pá\",\"doba\":\"20\",\"casZap1\":\"00:00\",\"casVyp1\":\"01:30\",\"casZap2\":\"02:25\",\"casVyp2\":\"07:00\",\"casZap3\":\"08:00\",\"casVyp3\":\"13:50\",\"casZap4\":\"14:50\",\"casVyp4\":\"17:30\",\"casZap5\":\"18:30\",\"casVyp5\":\"23:59\",\"casZap6\":\"\",\"casVyp6\":\"\",\"casZap7\":\"\",\"casVyp7\":\"\",\"casZap8\":\"\",\"casVyp8\":\"\",\"casZap9\":\"\",\"casVyp9\":\"\",\"casZap10\":\"\",\"casVyp10\":\"\",\"date\":\"2019-03-22 07:21:55.688\",\"description\":\"2019_jaro_vychod\"},{\"id\":\"6281\",\"validFrom\":\"1. 4. 2019\",\"validTo\":\"1. 1. 2099\",\"dumpId\":\"27\",\"povel\":\"181\",\"kodPovelu\":\"A1B6Dp1\",\"sazba\":\"D45d\",\"info\":\"sazba\",\"platnost\":\"So - Ne\",\"doba\":\"20\",\"casZap1\":\"00:00\",\"casVyp1\":\"00:40\",\"casZap2\":\"01:40\",\"casVyp2\":\"03:50\",\"casZap3\":\"04:50\",\"casVyp3\":\"11:35\",\"casZap4\":\"12:30\",\"casVyp4\":\"18:20\",\"casZap5\":\"19:20\",\"casVyp5\":\"23:59\",\"casZap6\":\"\",\"casVyp6\":\"\",\"casZap7\":\"\",\"casVyp7\":\"\",\"casZap8\":\"\",\"casVyp8\":\"\",\"casZap9\":\"\",\"casVyp9\":\"\",\"casZap10\":\"\",\"casVyp10\":\"\",\"date\":\"2019-03-22 07:21:55.688\",\"description\":\"2019_jaro_vychod\"}]"
-- local cezInvalidJsonString = "[]"
-- cgiGetResult.response = cezValidJsonString
-----End of NETIO MOCK METHOD-----

local function buildUrl()
  return string.format(baseApiUrl .. "?&code=%s&region%s=1", code, region)
end

local function call() -- send request to CEZ API
  local cezUrl = buildUrl()
  log("API url: " ..cezUrl)
  cgiGet{url=cezUrl, callback=getCalendar }
end

function getCalendar(o)
  local isError = true
  if o.result == 0 then
    isError = false
    local myjson = o.buffer
    local jsonCalendar = json.decode(myjson)
    if next(jsonCalendar) == nil then
      isError = true
      o.errorInfo = "Response is empty JSON"    
    else
      setNetioCalendar(jsonCalendar)
    end
  end

  if isError == true then
    log(string.format("CGI get failed with error %d: %s. Next attempt in 10s.", o.result, o.errorInfo))
    delay(10, function() call() end)  
  end
end

function setNetioCalendar(jsonCalendar)
  transformJsonCalendarToNetioCalendar(jsonCalendar)
  checkFormat()
  loadStates()
  startScheduler()
end

function transformJsonCalendarToNetioCalendar(jsonCalendar)
  local workingDays = jsonCalendar[1]
  local weekends = jsonCalendar[2]
  insertState(workingDays, "1111100")
  insertState(weekends, "0000011")
end

function insertState(calTable, dayString)
  for i=1,10 do
    local onTime = calTable["casZap" .. i]
    local offTime = calTable["casVyp" .. i]
    if onTime ~= nil and onTime ~= "" and offTime ~= nil and offTime ~= "" then      
      table.insert(states, onState .. "," .. onTime .. ":00," .. dayString)
      table.insert(states, offState .. "," .. offTime .. ":00," .. dayString)
    end
  end
end

------------NETIO AN07 Section------------
function checkFormat()
  for i=1,4 do
    local test = tonumber(initialState:sub(i,i))
    if test == nil or test>5 or test<0 then
      logf("Action in initialState for outlet %d is invalid!", i)        
      return false
    end
  end
  for i=1,#states do
    for j=1,4 do
      local test = tonumber(states[i]:sub(j,j))
      if test == nil or test>5 or test<0 then
        logf("Action in state %d for outlet %d is invalid!", i,j)        
        return false
      end
    end
    if states[i]:sub(5,5) ~= "," or states[i]:sub(14,14) ~= "," then
      logf("Time or days in state %d are not separated by comma!", i)
      return false
    end
    local hours = tonumber(states[i]:sub(6,6))
    local minutes = tonumber(states[i]:sub(9,9))
    local seconds = tonumber(states[i]:sub(12,12))
    if hours == nil or hours > 2 or hours < 0 or
      tonumber(states[i]:sub(7,7)) == nil or
      states[i]:sub(8,8) ~= ":" or
      minutes == nil or minutes > 5 or minutes < 0 == nil or
      tonumber(states[i]:sub(10,10)) == nil or
      states[i]:sub(11,11) ~= ":" or
      seconds == nil or seconds > 5 or seconds < 0 == nil or
      tonumber(states[i]:sub(13,13)) == nil then
      logf("Time in state %d is invalid!",i)
      return false
    end
    for j=15,21 do
      local day = tonumber(states[i]:sub(j,j))
      if day == nil or (day ~= 0 and day ~= 1) then
        logf("Value for day %d in state %d is invalid", (j-14), i)        
        return false
      end
    end
  end
  log("FORMAT OK")
  return true
end
 
function loadStates()
  for i=1,#states do
    sortedStates[i] = {state,time}
    sortedStates[i].state = states[i]
    sortedStates[i].time = (3600*tonumber(states[i]:sub(6,7)) + 60*tonumber(states[i]:sub(9,10)) + tonumber(states[i]:sub(12,13)))
  end
end
 
function startScheduler()
  -- Current time
  local stringTime = os.date("%X")
  local time = (3600*tonumber(stringTime:sub(1,2)) + 60*tonumber(stringTime:sub(4,5)) + tonumber(stringTime:sub(7,8)))
  local nextState = sortedStates[1].state
  local timeLeft = (86400-time+sortedStates[1].time)

  local stateIndex = 1
  for i=1,#sortedStates do
    if time < sortedStates[i].time and i ~= 1 then
      -- i = next state, we need i - 1 to set current state
      prevIndex = i - 1

      -- check today is day from state
      if checkDay(sortedStates[prevIndex].state) then
        nextState = sortedStates[prevIndex].state
        timeLeft = (sortedStates[prevIndex].time - time)
        stateIndex = prevIndex
      end
      break
    end
  end
   
  -- Delay between states must be at least 1s
  if timeLeft <= 0 then timeLeft = 1 end
  delay(timeLeft,function() scheduler(nextState,stateIndex) end)
end
 
function scheduler(currentState, stateIndex)
  if checkDay(currentState) then
    setOutputs(currentState:sub(1,4))
  end
  local nextIndex = stateIndex%#sortedStates + 1
   
  local currentTime = sortedStates[stateIndex].time
  local stringTime = os.date("%X")
  local realTime = (3600*tonumber(stringTime:sub(1,2)) + 60*tonumber(stringTime:sub(4,5)) + tonumber(stringTime:sub(7,8))) 
  if currentTime ~= realTime then
    currentTime = realTime 
  end
 
  local timeLeft = 0
  if nextIndex == 1 then
    timeLeft = (86400-currentTime+sortedStates[nextIndex].time)
  else
    timeLeft = sortedStates[nextIndex].time - currentTime
  end
     
  -- Delay between states must be at least 1s
  if timeLeft <= 0 then timeLeft = 1 end
  delay(timeLeft,function() scheduler(sortedStates[nextIndex].state,nextIndex) end)
end
 
function checkDay(state)
  local day = tonumber(os.date("%w"))
  -- os.date("%w") returns 0 for Sunday
  if day == 0 then day = 7 end
    if tonumber(state:sub(14+day,14+day)) == 1 then
      return true
    end
  return false
end
 
function setOutputs(state)
  for i=1,4 do
    value = tonumber(state:sub(i,i))
    if value == 0 then -- turn off
      devices.system.SetOut{output = i, value = false}
    elseif value == 1 then -- turn on
      devices.system.SetOut{output = i, value = true}
    elseif value == 2 then -- short off
      devices.system.SetOut{output = i, value = false}
      milliDelay(shortTimeMs,function() devices.system.SetOut{output=i,value=true} end)
    elseif value == 3 then -- short on
      devices.system.SetOut{output = i, value = true}
      milliDelay(shortTimeMs,function() devices.system.SetOut{output=i,value=false} end)   
    elseif value == 4 then -- toggle
      if devices.system["output" ..i.. "_state"] == 'on' then
        devices.system.SetOut{output=i,value=false}
      else
        devices.system.SetOut{output=i, value=true}
      end
    elseif value == 5 then
      -- do nothing
    end
  end
end
 
function initiate()
  setOutputs(initialState)
end

------------End NETIO AN07 Section------------
------------Start Section------------
function start()
  initiate()
  call()
end
start()
------------End of Start Section------------
