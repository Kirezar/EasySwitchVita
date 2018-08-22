--Initializing Global Variables

config = {} -- Config values for each plugin
colors = {} -- Color values for the plugins, also describes the state (On, Off, Not Found)

timerObj = Timer.new()

file = nil -- Backup File
configFile = nil -- ez_config file
tai_config = nil -- ur0:tai/config.txt file

configText = "" -- text from the ez_config file
text = "" -- text from the main config file and backup file

pad = 0 -- Controller
previousPad = 0 -- Controller previous state, used to check if a button was just pressed, or if it is held down

-- Selection Rectangle Variables
selectionRectX = 3
selectionRectY = 115
selectionWidth = 140
selectionHeight = 30

-- Selected Button
selectedButton = 0

-- Prints Initial Text to screen
function InitText()
  Graphics.debugPrint(5, 10, "This app will toggle some plugins on your Vita", Color.new(255,255,255))
  Graphics.debugPrint(5, 30, "Press X to change the plugins.", Color.new(255,255,255))
  Graphics.debugPrint(5, 50, "Plugins marked with an X will be toggled on/off depending on their previous state", Color.new(255,255,255))
  Graphics.debugPrint(5, 85, "Currently On", Color.new(0,255,0))
  Graphics.debugPrint(150, 85, "Currently Off", Color.new(255,0,0))
 
end

-- Creates data/EasySwitchVita if it doesn't exist
function DirectoryInit()
  
  System.createDirectory("ux0:/data/EasySwitchVita")
  
end

-- Grabs the config.txt file in ur0:tai/
function TaiConfigInit()
  
  -- If the backup file exists, delete it so we can recreate it later
  if System.doesFileExist("ux0:/data/EasySwitchVita/config_backup_switch.txt") then
    System.deleteFile("ux0:/data/EasySwitchVita/config_backup_switch.txt")
  end
  
  -- Create new backup file
  local createFile = System.openFile("ux0:/data/EasySwitchVita/config_backup_switch.txt", FCREATE)
  file = System.openFile("ur0:tai/config.txt", FREAD)
  System.seekFile(file, 0, SET)
  text = System.readFile(file, System.sizeFile(file))
  System.closeFile(file)
  System.writeFile(createFile, text, string.len(text))
  
  System.closeFile(createFile)
  file = System.openFile("ux0:/data/EasySwitchVita/config_backup_switch.txt", FREAD)
  
  
  -- Set Config text
  text = System.readFile(file, System.sizeFile(file))
end

-- Finds if the plugin is on, off, or unavailable in the config
function GetState(plugin)
  local text_to_find = "ur0:tai/" .. plugin .. ".skprx"
  local i,j = string.find(text, text_to_find)
  
  if i == nil then
    colors[plugin] = Color.new(150,150,150)
    return
  end
  
  local findText = string.sub(text, i, j)
  
  -- Check if there's a comment char before the plugin name, that means it's off, if the char doesn't exist, then it's on
  if string.match(string.sub(text,i-1,i-1), "#") then
    colors[plugin] = Color.new(255,0,0)
  else
    colors[plugin] = Color.new(0,255,0)
  end
end

-- Sets the colors for the buttons, indicating state
function SetColors()
  colors["udcd_uvc"] = nil
  colors["ds3vita"] = nil
  colors["ds4vita"] = nil
  colors["ds3"] = nil
  colors["minivitatv"] = nil
  GetState("udcd_uvc")
  GetState("ds3vita")
  GetState("ds4vita")
  GetState("ds3")
  GetState("minivitatv")
end

-- Gets configuration from the ez_config file
function SwitchConfigInit()
  
  -- If the file exists, use that one
  if (System.doesFileExist("ux0:/data/EasySwitchVita/ez_config.txt")) then
    configFile = System.openFile("ux0:/data/EasySwitchVita/ez_config.txt", FREAD)
    
  -- Else we create a new one, by copying the ez_config file from the app folder into the data folder
  else
    local createFile = System.openFile("ux0:/data/EasySwitchVita/ez_config.txt", FCREATE)
    local basefile = System.openFile("app0:/ez_config.txt", FREAD)
    System.seekFile(basefile, 0, SET)
    local config_text = System.readFile(basefile, System.sizeFile(basefile))
    System.closeFile(basefile)
    System.writeFile(createFile, config_text, string.len(config_text))
    System.closeFile(createFile)
    configFile = System.openFile("ux0:/data/EasySwitchVita/ez_config.txt", FREAD)
  end
  
  -- Reads the text from the ez_config file and sets the configText. This variable will be used to update the config file, and read from it to show the initial state
  System.seekFile(configFile, 0, SET)
  configText = System.readFile(configFile, System.sizeFile(configFile))
  System.closeFile(configFile)
end

-- Creates the variables tied to the plugins in the config array
function ConfigVariableInit()
  config["udcd_uvc"] = false
  config["ds3vita"] = false
  config["ds4vita"] = false
  config["ds3"] = false
  config["minivitatv"] = false
  config["reboot_timer"] = 3
  config["auto_reboot"] = false
end

-- Get the value from the configText for one variable. Either true, false, or a number in the case of the auto_reboot
function GetValue(str)
  local i,j = string.find(configText, str)
  local value = ""
  
  if (string.match(string.lower(string.sub(configText, j+2, j+5)), "true")) then
    value = true
  elseif (string.match(string.lower(string.sub(configText, j+2, j+6)), "false")) then
    value = false
  elseif(string.match(str, "reboot_timer")) then
    local k,w = string.find(configText, '%d+', j)
    value = tonumber(string.sub(configText, k, w))
  end

  return value
end

-- Sets the values for the plugins using the GetValue function
function ReadSwitchConfig()
  config["udcd_uvc"] = GetValue("udcd_uvc")
  config["ds3vita"] = GetValue("ds3vita")
  config["reboot_timer"] = GetValue("reboot_timer")
  config["auto_reboot"] = GetValue("auto_reboot")
  config["ds4vita"] = GetValue("ds4vita")
  config["minivitatv"] = GetValue("minivitatv")
  config["ds3"] = GetValue("ds3")
end

-- Updates a value in the ez_config file
function ChangeConfigParameter(str)
  local i,j = string.find(configText, str)
  
  
  if(string.match(str, "reboot_timer")) then
    configText = string.gsub(configText, "reboot_timer=%d+", "reboot_timer="..config["reboot_timer"])
  elseif config[str] then
    if (string.match(string.lower(string.sub(configText, i, j+6)), str .. "=false")) then
      configText = string.gsub(configText, str .. "=false", str .. "=true")
    end
  else
    if (string.match(string.lower(string.sub(configText, i, j+5)), str .. "=true")) then
      configText = string.gsub(configText, str .. "=true", str .. "=false")
    end
  end
  
end

-- Updates the ez_config File
function SaveConfig()
  
  System.deleteFile("ux0:/data/EasySwitchVita/ez_config.txt")
  configFile = System.openFile("ux0:/data/EasySwitchVita/ez_config.txt", FCREATE)
  
  ChangeConfigParameter("udcd_uvc")
  ChangeConfigParameter("ds3vita")
  ChangeConfigParameter("ds4vita")
  ChangeConfigParameter("ds3")
  ChangeConfigParameter("minivitatv")
  ChangeConfigParameter("reboot_timer")
  ChangeConfigParameter("auto_reboot")
  
  System.writeFile(configFile, configText, string.len(configText))
  System.closeFile(configFile)
  
end


-- Draw the selection rect
function DrawSelectionRect()
  Graphics.fillRect(selectionRectX, selectionRectX + selectionWidth, selectionRectY, selectionRectY + selectionHeight, Color.new(0,0,255)) 
end

-- Draws the GUI elements other than the initial text
function GUI()
  
  -- Update the selection rectangle to the position of the selected button and draw it
  selectionRectY = 115 + 30*selectedButton
  DrawSelectionRect()
  
  -- Draw the text for each plugin, with the color corresponding to the state, and whether they should be toggled or not
  Graphics.debugPrint(5, 120, "Switch!", Color.new(255,255,255))
  Graphics.debugPrint(5, 150, "udcd_uvc:", colors["udcd_uvc"])
  Graphics.debugPrint(5, 180, "ds3vita:", colors["ds3vita"])
  Graphics.debugPrint(5, 210, "ds4vita:", colors["ds4vita"])
  Graphics.debugPrint(5, 240, "ds3:", colors["ds3"])
  Graphics.debugPrint(5, 270, "minivitatv:", colors["minivitatv"])
  Graphics.debugPrint(5, 300, "Reboot Timer:", Color.new(255,255,255))
  Graphics.debugPrint(5, 330, "Auto Reboot:", Color.new(255,255,255))
  
  -- Compare the color, if it's (150, 150, 150)/Grey, then the plugin has not been found in the config, else, show if the plugin is to be toggled or not
  if colors["udcd_uvc"] == Color.new(150,150,150) then
    Graphics.debugPrint(150, 150, "Not Found", Color.new(150,150,150))
  elseif config["udcd_uvc"] then
    Graphics.debugPrint(150, 150, "X", Color.new(255,255,255))
  else
    Graphics.debugPrint(150, 150, "_", Color.new(255,255,255))
  end
  
  if colors["ds3vita"] == Color.new(150,150,150) then
    Graphics.debugPrint(150, 180, "Not Found", Color.new(150,150,150))
  elseif config["ds3vita"] then
    Graphics.debugPrint(150, 180, "X", Color.new(255,255,255))
  else
    Graphics.debugPrint(150, 180, "_", Color.new(255,255,255))
  end
  
  if colors["ds4vita"] == Color.new(150,150,150) then
    Graphics.debugPrint(150, 210, "Not Found", Color.new(150,150,150))
  elseif config["ds4vita"] then
    Graphics.debugPrint(150, 210, "X", Color.new(255,255,255))
  else
    Graphics.debugPrint(150, 210, "_", Color.new(255,255,255))
  end
  
  if colors["ds3"] == Color.new(150,150,150) then
    Graphics.debugPrint(150, 240, "Not Found", Color.new(150,150,150))
  elseif config["ds3"] then
    Graphics.debugPrint(150, 240, "X", Color.new(255,255,255))
  else
    Graphics.debugPrint(150, 240, "_", Color.new(255,255,255))
  end
  
  if colors["minivitatv"] == Color.new(150,150,150) then
    Graphics.debugPrint(150, 270, "Not Found", Color.new(150,150,150))
  elseif config["minivitatv"] then
    Graphics.debugPrint(150, 270, "X", Color.new(255,255,255))
  else
    Graphics.debugPrint(150, 270, "_", Color.new(255,255,255))
  end
  
  -- Draw the reboot timer
  Graphics.debugPrint(150, 300, tostring(config["reboot_timer"]), Color.new(255,255,255))
  
  if config["auto_reboot"] then
    Graphics.debugPrint(150, 330, "X", Color.new(255,255,255))
  else
    Graphics.debugPrint(150, 330, "_", Color.new(255,255,255))
  end
  
end

-- Draw functions
function BeginDraw ()
  Graphics.initBlend()
  Screen.clear()
end

function EndDraw()
  Screen.flip() 
  Graphics.termBlend() 
end

-- Update one plugin in ur0:tai/config.txt
function ChangeText(plugin)
  
  if config[plugin] then
    
    local text_to_find = "ur0:tai/" .. plugin .. ".skprx"
    local i,j = string.find(text, text_to_find)
    
    if i == nil then
      return
    end
    
    local findText = string.sub(text, i, j)
    
    
    
    if string.match(string.sub(text,i-1,i-1), "#") then
      text = string.gsub(text, "#ur0:tai/" .. plugin .. ".skprx", "ur0:tai/" .. plugin .. ".skprx")
    else
      text = string.gsub(text, "ur0:tai/" .. plugin .. ".skprx", "#ur0:tai/" .. plugin .. ".skprx")
    end
  end
end

-- Update the ur0:tai/config.txt file, save the ez_config file, show the reboot timer, and reboot
function DoChanges()
  tai_config = System.openFile("ur0:tai/config_new.txt", FCREATE)
  
  ChangeText("udcd_uvc")
  ChangeText("ds3vita")
  ChangeText("ds4vita")
  ChangeText("ds3")
  ChangeText("minivitatv")
  System.writeFile(tai_config, text, string.len(text))
  
  if System.doesFileExist("ur0:tai/config_backup_switch.txt") then
    System.deleteFile("ur0:tai/config_backup_switch.txt")
  end
  
  System.rename("ur0:tai/config.txt", "ur0:tai/config_backup_switch.txt")
  System.rename("ur0:tai/config_new.txt", "ur0:tai/config.txt")
  
  
  SaveConfig()
  
  Timer.reset(timerObj)
  EndDraw()
  
  
  for i = 0, config["reboot_timer"]-1 do
    BeginDraw()
    Graphics.debugPrint(400, 252, "Rebooting in ".. config["reboot_timer"] - i .. "s", Color.new(255,255,255))
    EndDraw()

    System.wait(1000000)
  end
  
  System.reboot()
end

-- Function called when X is pressed on a button
function CrossPressed()
  
  -- If it's the "Switch!" button, save configs and reboot
  if (selectedButton == 0) then
    DoChanges()
    
  -- Else, change if a plugin is to be toggled or not
  elseif (selectedButton == 1) then
    config["udcd_uvc"] = not config["udcd_uvc"]
  elseif (selectedButton == 2) then
    config["ds3vita"] = not config["ds3vita"]
  elseif (selectedButton == 3) then
    config["ds4vita"] = not config["ds4vita"]
  elseif (selectedButton == 4) then
    config["ds3"] = not config["ds3"]
  elseif (selectedButton == 5) then
    config["minivitatv"] = not config["minivitatv"]
  
  elseif (selectedButton == 7) then
    config["auto_reboot"] = not config["auto_reboot"]
  end
end

-- When the cursor is moved, check if next position is available, if it isn't move cursor and check again
function CheckIfAvailable(button, direction)
  
  if button == 1 then
    if colors["udcd_uvc"] == Color.new(150,150,150) then
      selectedButton = button + direction
      CheckIfAvailable(selectedButton, direction)
    end
  elseif button == 2 then
    if colors["ds3vita"] == Color.new(150,150,150) then
      selectedButton = button + direction
      CheckIfAvailable(selectedButton, direction)
    end
  elseif button == 3 then
    if colors["ds4vita"] == Color.new(150,150,150) then
      selectedButton = button + direction
      CheckIfAvailable(selectedButton, direction)
    end
  elseif button == 4 then
    if colors["ds3"] == Color.new(150,150,150) then
      selectedButton = button + direction
      CheckIfAvailable(selectedButton, direction)
    end
  elseif button == 5 then
    if colors["minivitatv"] == Color.new(150,150,150) then
      selectedButton = button + direction
      CheckIfAvailable(selectedButton, direction)
    end
  end
  
end

-- Check if the L trigger is pressed at the start
function CheckForInterrupt()
  
  pad = Controls.read()
  if Controls.check(pad, SCE_CTRL_LTRIGGER) then
    return true
  else
    return false
  end
end

-- Start Function
function Start()
  
  DirectoryInit()
  TaiConfigInit()
  SwitchConfigInit()
  ConfigVariableInit()
  ReadSwitchConfig()
  SetColors()
  
  -- if auto_reboot is true, save configs and reboot automatically, unless L is pressed, if it is, skip the auto_reboot
  if config["auto_reboot"] and not CheckForInterrupt() then
    DoChanges()
  end
  
end

------------------------------------------------------------------------------------------------- Code Execution ----------------------------------------------------------------------------


Start()

-- Update Loop
while true do
  
  -- Run the update at 60 FPS
  if (Timer.getTime(timerObj) >= 16.7) then
    
    Timer.reset(timerObj)
    
    -- Start drawing objects to screen
    BeginDraw()
    
    -- Display initial text
    InitText()
    
    -- Display GUI text
    GUI()
    
    -- Read what controls are pressed
    pad = Controls.read()
    
    -- Check if a button was just pressed and not held
    if(previousPad ~= pad) then
      
      -- X was pressed
      if Controls.check(pad, SCE_CTRL_CROSS) then
          CrossPressed()
      end
      
      -- Down was pressed
      if Controls.check(pad, SCE_CTRL_DOWN) then
        if selectedButton < 7 then
          selectedButton = selectedButton + 1
          CheckIfAvailable(selectedButton, 1)
        end
      end
      
      -- Up was pressed
      if Controls.check(pad, SCE_CTRL_UP) then
        if selectedButton > 0 then
          selectedButton = selectedButton - 1
          CheckIfAvailable(selectedButton, -1)
        end
      end
      
      -- If on the reboot timer button check what direction was pressed to change the time
      
      -- Left was pressed, reduce time
      if Controls.check(pad, SCE_CTRL_LEFT) then
        if selectedButton == 6 and config["reboot_timer"] > 0 then
          config["reboot_timer"] = config["reboot_timer"]-1
        end
      end
      
      -- Right was pressed, increase time
      if Controls.check(pad, SCE_CTRL_RIGHT) then
        if selectedButton == 6 then
          config["reboot_timer"] = config["reboot_timer"]+1
        end
      end
      
    end
    
    -- Update previous pad state to this frame's pad state
    previousPad = pad
    
    -- End the object drawing
    EndDraw()
    
  end
end