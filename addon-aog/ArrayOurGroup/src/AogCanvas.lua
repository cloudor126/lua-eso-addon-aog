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
  background:SetAnchor(TOPRIGHT,nil,TOPRIGHT,0,0)
  background:SetAnchor(BOTTOMRIGHT,nil,BOTTOMRIGHT,0,0)
  background:SetWidth(width*0.8)
  background:SetTexture('/ArrayOurGroup/src/bg.dds')

  -- palette
  local palette = wm:CreateControl(nil, control, CT_TEXTURE) -- TextureControl#TextureControl
  palette:SetAnchor(TOPLEFT,nil,TOPLEFT,0,0)
  palette:SetAnchor(BOTTOMLEFT,nil,BOTTOMLEFT,0,0)
  palette:SetWidth(width*0.2)
  palette:SetColor(.3,.3,.3,1)

  -- axis
  local axisX = wm:CreateControl(nil, background, CT_TEXTURE) -- TextureControl#TextureControl
  axisX:SetAnchor(LEFT,nil,LEFT,0,0)
  axisX:SetAnchor(RIGHT,nil,RIGHT,0,0)
  axisX:SetHeight(2)
  axisX:SetColor(.3,.3,.3,1)
  local axisY = wm:CreateControl(nil, background, CT_TEXTURE) -- TextureControl#TextureControl
  axisY:SetAnchor(TOP,nil,TOP,0,0)
  axisY:SetAnchor(BOTTOM,nil,BOTTOM,0,0)
  axisY:SetWidth(2)
  axisY:SetColor(.3,.3,.3,1)

  -- me
  local me =  wm:CreateControl(nil, background, CT_TEXTURE) -- TextureControl#TextureControl
  me:SetAnchor(CENTER,nil,CENTER,0,0)
  me:SetDimensions(26,26)
  me:SetTexture('/esoui/art/mappins/ui-worldmapplayerpip.dds')
  --  me:SetColor(.4,.4,.8,1)

  -- distance labels
  local _8m = wm:CreateControl(nil, background, CT_LABEL) -- LabelControl#LabelControl
  _8m:SetAnchor(CENTER,nil,CENTER,-40,40)
  _8m:SetText('8m')
  _8m:SetFont('$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin')

  local _16m = wm:CreateControl(nil, background, CT_LABEL) -- LabelControl#LabelControl
  _16m:SetAnchor(CENTER,nil,CENTER,-80,80)
  _16m:SetText('16m')
  _16m:SetFont('$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin')
  local _24m = wm:CreateControl(nil, background, CT_LABEL) -- LabelControl#LabelControl
  _24m:SetAnchor(CENTER,nil,CENTER,-120,120)
  _24m:SetText('24m')
  _24m:SetFont('$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin')

  local memberList = {} -- #list<#Member>
  local fList = {}
  fList.createMember -- #()->(TextureControl#TextureControl)
  = function()
    local member =  wm:CreateControl(nil, background, CT_TEXTURE) -- TextureControl#TextureControl
    local x,y = fList.findNewMemberPosition()

    member:SetAnchor(CENTER,nil,CENTER,x,y)
    member:SetDimensions(21,21)
    member:SetTexture('/esoui/art/mappins/map_assistedareapin_32.dds')
    member:SetMovable(true)
    member:SetMouseEnabled(true)
    member:SetHandler('OnMoveStop',function() fList.onMemberMoveStop(member) end)
    return member
  end

  fList.findNewMemberPosition -- #()->(#number, #number)
  = function()
    local meX, meY = me:GetCenter()
    for y=-200, 200,40 do
      for x=-200, 200,40 do
        local stacked = false
        for i, m in ipairs(memberList) do
        	local mX,mY = m:GetCenter()
        	mX = mX-meX
        	mY = mY-meY
        	if math.abs(x-mX)<20 and math.abs(y-mY)<20 then stacked = true end
        end
        if not stacked then d('ok') return x,y end
      end
    end
    return 0,0
  end

  fList.onMemberMoveStop -- #(TextureControl#TextureControl:member)->()
  = function(member)
    -- delete if out of range
    local x,y = member:GetCenter()
    local meX,meY = me:GetCenter()
    x = x-meX
    y = y-meY
    if (x>220 or x<-220 or y>220 or y<-220) then
      member:SetHidden(true)
      for i, m in ipairs(memberList) do
        if (m==member) then table.remove(memberList,i) end
      end
    end
  end

  -- tool.1 add
  local toolAdd = wm:CreateControl(nil, palette, CT_BUTTON) -- ButtonControl#ButtonControl
  toolAdd:SetDimensions(42, 42)
  toolAdd:SetNormalTexture('/esoui/art/guildfinder/tabicon_recruitment_down.dds')
  toolAdd:SetPressedOffset(2, 2)
  toolAdd:SetAnchor(TOP,nil,TOP,0,10)
  toolAdd:SetClickSound("Click")
  toolAdd:SetHandler("OnClicked", function(...)
    if #memberList >= 11 then return end
    table.insert(memberList,fList.createMember())
  end)



  return control
end
