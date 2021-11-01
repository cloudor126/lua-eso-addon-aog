--[[aogCanvasData = {


    type = "aogCanvas",


    loadFunc = function() return data end,


    saveFunc = function(data) end,


    width = "full", -- or "half" (optional)


    disabled = function() return db.someBooleanSetting end, -- or boolean (optional)


    reference = "MyAddonButton", -- unique global reference to control (optional)


} ]]

local widgetVersion = 1
local LAM = LibAddonMenu2
if not LAM:RegisterWidget("aogCanvas", widgetVersion) then return end
local wm = WINDOW_MANAGER

function LAMCreateControl.aogCanvas(parent, aogCanvasData, controlName)
  local control = LAM.util.CreateBaseControl(parent, aogCanvasData, controlName) -- Control#Control
  control:SetMouseEnabled(true)

  -- container
  local width = control:GetWidth()
  if control.isHalfWidth then
    control:SetDimensions(width / 2, width / 2)
  else
    control:SetDimensions(width, width*0.8)
  end
  
  -- background
  local background = wm:CreateControl(nil, control, CT_TEXTURE) -- TextureControl#TextureControl
  background:SetAnchor(TOPLEFT,nil,TOPLEFT,0,0)
  background:SetAnchor(BOTTOMRIGHT,nil,BOTTOMRIGHT,0,0)
  background:SetColor(.2,.2,.2,1)

  -- palette
  local palette = wm:CreateControl(nil, control, CT_TEXTURE) -- TextureControl#TextureControl
  palette:SetAnchor(TOPLEFT,nil,TOPLEFT,0,0)
  palette:SetAnchor(BOTTOMLEFT,nil,BOTTOMLEFT,0,0)
  palette:SetWidth(width*0.2)
  palette:SetColor(.3,.3,.3,1)

  return control
end
