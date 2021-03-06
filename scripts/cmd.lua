local cmd = {}

local json = require('json')

function cmd.main (obj, mcmd, params) 
  mcmd = mcmd:lower()
  
  if (mcmd ~= "iotr" and mcmd ~= "twitchmod" and mcmd ~= "twitch") then
    return
  end
  
  lines = {}
  for s in params:gmatch("[^\r\n ]+") do
      table.insert(lines, s)
  end
  
  if (cmd[lines[1]] ~= nil) then
    cmd[lines[1]](lines)
  else
    cmd.send("Command "..lines[1] .. " not found")
  end
end

function cmd.send(text)
  Isaac.DebugString("IOTR: " ..text.. "\n")
  Isaac.ConsoleOutput("IOTR: " ..text.. "\n")
end
  

function cmd.test ()
  Isaac.ConsoleOutput("\nHell yeah, it's working!")
end

-- Show active dynamic callbacks
function cmd.showcallbacks () 
  
  local text = "Dynamic callbacks\n"
  for key,value in pairs(IOTR.DynamicCallbacks) do
    
    if (type(value) ~= "function") then
      text = text .. key .. ": "
      local subtext = ""
      for ckey,cvalue in pairs(value) do
        if (#subtext > 0) then subtext = subtext..", " end
        subtext = subtext .. ckey
      end
      
      if (subtext ~= "") then text = text .. subtext .. "\n" else text = text .. "none\n" end
    end
  end
  
  cmd.send(text)
end


-- Show current storage data in JSON
function cmd.storage () 
  
  local text = "Storage\n" .. json.encode(IOTR.Storage)
  
  cmd.send(text)
end

-- Spawn all Twitch mod passive items
function cmd.allpassive () 
  
  local room = Game():GetRoom()
  local count = 0
  
  for key,value in pairs(IOTR.Items.Passive) do
    count = count + 1
    Isaac.Spawn(5, 100, value.id, room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true), Vector(0, 0), p)
  end
  
  cmd.send("Spawned "..count.." passive items")
end

-- Spawn all Twitch mod active items
function cmd.allactive () 
  
  local room = Game():GetRoom()
  local count = 0
  
  for key,value in pairs(IOTR.Items.Active) do
    if (value.devOnly == nil or not value.devOnly) then
      count = count + 1
      Isaac.Spawn(5, 100, value.id, room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true), Vector(0, 0), p)
    end
  end
  
  cmd.send("Spawned "..count.." active items")
end

-- Enable shader
function cmd.toggleshader (params) 
  
  if (IOTR.Shaders[params[2]] == nil) then
    cmd.send("Shader "..params[2].." not found")
    return
  end
  
  IOTR.Shaders[params[2]].enabled = not IOTR.Shaders[params[2]].enabled
  
  if (IOTR.Shaders[params[2]].enabled) then
    cmd.send("Shader "..params[2].." enabled")
  else
    cmd.send("Shader "..params[2].." disabled")
  end
end

-- Set shader param
function cmd.setshader (params) 
  
  if (IOTR.Shaders[params[2]] == nil) then
    cmd.send("Shader "..params[2].." not found")
    return
  end
  
  if (IOTR.Shaders[params[2]].params[params[3]] == nil) then
    cmd.send("Shader "..params[2].." do not have " .. params[3] .. " param")
    return
  end
  
  IOTR.Shaders[params[2]].params[params[3]] = tonumber(params[4])
end

-- Test following text render system
function cmd.debugtextfollow (params)
  if (params[2] == nil) then
    params[2] = "hello"
  end
  
  local e = Isaac.GetRoomEntities()
  
  for k, v in pairs(e) do
    IOTR.Text.add("debugtextfollow"..k, params[2])
    IOTR.Text.follow("debugtextfollow"..k, v)
  end
end

-- Launch event
function cmd.launchevent (params)
  IOTR._.launchEvent("EV_"..params[2])
end

-- Get current gridEntity variant
function cmd.getgridentity (params)
  local p = Isaac.GetPlayer(0)
  local room = Game():GetRoom()
  
  local curPos = room:GetGridIndex(p.Position)
  
  cmd.send(json.encode(room:GetGridEntity(curPos):GetType()))
end

-- Get current room size
function cmd.getroomsize (params)
  local room = Game():GetRoom()
  
  cmd.send(room:GetGridWidth() .. "x" .. room:GetGridHeight() .. "(" .. room:GetGridSize() .. ")")
end

return cmd