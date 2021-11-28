--========================================
--        vars
--========================================
local addon = ArrayOurGroup -- Addon#M
local l = {} -- #L
local m = {l=l} -- #M
local SV_NAME = "AOGSV"
local SV_VER = "1.0"

---
--@type SavedVars
local savedVarsDefaults = {
  settingsAccountWide = false,
  settingsProfiles= {'profile1','profile2','profile3'} --#list<#string>
  ,
  settingsProfilesSchemes = {} --#list<#string>
}

local SPECIAL_CHOICES = {'<add...>','<edit current>','<remove current>','<move up current>','<move down current>'}

---
--@type MenuOption
--@field #string type
--@field #string name
--@field #()->(#any) getFunc
--@field #(#any:value)->() setFunc
--@field #string width
--@field #any default

--========================================
--        l
--========================================
l.accountSavedVars = {}  --#SavedVars
l.characterSavedVars = {}  --#SavedVars
l.menuOptions = {} --#list<#MenuOption>
l.selectedProfile = nil -- #string
l.selectedScheme = nil --#string

l.getProfilesChoices -- #()->(#list<#string>)
= function()
  return {unpack(l.getSavedVars().settingsProfiles), unpack(SPECIAL_CHOICES)}
end

l.getSavedVars -- #()->(#SavedVars)
= function()
  return l.characterSavedVars.settingsAccountWide and l.accountSavedVars or l.characterSavedVars
end

l.getSelectedProfile -- #()->(#string)
= function()
  return l.selectedProfile or (l.getSavedVars().settingsProfiles or {'profile1'})[1]
end

l.getSelectedScheme -- #()->(#string)
= function()
  return l.selectedScheme or (l.getSavedVars().settingsProfilesSchemes[l.getSelectedProfile()] or {'sheme1'})[1]
end

l.handleInputName -- #(#string:name)->()
= nil

l.initDialogs --#()->()
= function()
  local control = AOG_InputNameDialog
  ZO_Dialogs_RegisterCustomDialog("AOG_INPUT_NAME_DIALOG", {
    customControl = control,
    title = { text = "Input Name" },
    setup = function() l.setupDialog(control) end,
    buttons =
    {
      {
        control =   GetControl(control, "Accept"),
        text =      SI_DIALOG_ACCEPT,
        keybind =   "DIALOG_PRIMARY",
        callback =  function(dialog)
          local name = GetControl(control, "ContentName")
          l.handleInputName(name:GetText())
        end,
      },
      {
        control =   GetControl(control, "Cancel"),
        text =      SI_DIALOG_CANCEL,
        keybind =   "DIALOG_NEGATIVE",
        callback =  function(dialog)
        end,
      },

    },
  })
end

l.onStart -- #()->()
= function()
  -- load saved vars with defaults
  addon.callExtension(m.EXTKEY_ADD_DEFAULTS)
  l.accountSavedVars = ZO_SavedVars:NewAccountWide(SV_NAME, SV_VER, nil, savedVarsDefaults)
  l.characterSavedVars = ZO_SavedVars:New(SV_NAME, SV_VER, nil, savedVarsDefaults)
  -- register addon panel
  local LAM2 = LibAddonMenu2
  if LAM2 == nil then return end
  local panelData = {
    type = 'panel',
    name = addon.title or addon.name,
    displayName = "AOG Settings",
    author = "Cloudor",
    version = addon.version,
    --    website = "https://www.esoui.com/downloads/info1536-ActionDurationReminder.html",
    --    feedback = "https://www.esoui.com/downloads/info1536-ActionDurationReminder.html#comments",
    slashCommand = "/aogset",
    registerForRefresh = true,
    registerForDefaults = true,
  }
  LAM2:RegisterAddonPanel('AOGAddonOptions', panelData)
  -- init menu options
  m.addMenuOptions({
    type = "checkbox",
    name = addon.text("Account Wide Configuration"),
    getFunc = function() return l.characterSavedVars.settingsAccountWide end,
    setFunc = function(value)
      l.characterSavedVars.settingsAccountWide = value
    end,
    width = "full",
    default = true,
  },{
    type = 'dropdown',
    name = 'profile',
    choices = l.getProfilesChoices(),
    getFunc = function() return l.getSelectedProfile() end,
    setFunc = l.selectProfile,
    reference = 'AogSettingsProfileDropdown',
    width = 'half',
  },{
    type = 'dropdown',
    name = 'scheme',
    choices = l.getSavedVars().settingsProfilesSchemes[l.getSelectedProfile()] or {l.getSelectedProfile()..'scheme1',l.getSelectedProfile()..'scheme2',l.getSelectedProfile()..'scheme3'},
    getFunc = function() return l.getSelectedScheme() end,
    setFunc = function(value) l.selectedScheme = value end,
    reference = 'AogSettingsSchemeDropdown',
    width = 'half',
  },{
    type = 'aogCanvas',
    name = 'canvas',

  }
  )
  addon.callExtension(m.EXTKEY_ADD_MENUS)
  LAM2:RegisterOptionControls('AOGAddonOptions', l.menuOptions)
  l.initDialogs()
end

l.selectProfile -- #(#string:value)->()
= function(value)
  if value==SPECIAL_CHOICES[1] then
    -- add
    l.handleInputName -- #(#string:name)->()
    = function(name)
      if name:find('<',1,true) then
        -- TODO
        return
      end
      local profiles = l.getSavedVars().settingsProfiles
      table.insert(profiles,name)
      l.selectedProfile = name
      l.getSavedVars().settingsProfiles = profiles
      AogSettingsProfileDropdown:UpdateChoices(profiles)
      AogSettingsProfileDropdown:UpdateValue()
      l.selectProfile(name)
    end
    ZO_Dialogs_ShowDialog("AOG_INPUT_NAME_DIALOG", {})
    return
  elseif value == SPECIAL_CHOICES[2] then
    -- edit
    return
  elseif value == SPECIAL_CHOICES[3] then
    -- remove
    return
  elseif value == SPECIAL_CHOICES[4] then
    -- up
    return
  elseif value == SPECIAL_CHOICES[5] then
    -- down
    return
  end
  l.selectedProfile = value
  AogSettingsSchemeDropdown:UpdateChoices(l.getSavedVars().settingsProfilesSchemes[l.selectedProfile] or {l.getSelectedProfile()..'scheme1',l.getSelectedProfile()..'scheme2',l.getSelectedProfile()..'scheme3'})
  AogSettingsSchemeDropdown:UpdateValue()
end

l.setupDialog -- #(Control#Control:dialog)->()
= function(dialog)
-- TODO
end

--========================================
--        m
--========================================
m.EXTKEY_ADD_DEFAULTS = "Settings:addDefaults"
m.EXTKEY_ADD_MENUS = "Settings:addMenus"

m.addDefaults -- #(#any:...)->()
= function(...)
  zo_mixin(savedVarsDefaults,...)
end

m.addMenuOptions -- #(#MenuOption:...)->()
= function(...)
  for i=1,select('#',...) do
    local option = select(i, ...)
    table.insert(l.menuOptions, option)
  end
end

m.getAccountSavedVars -- #()->(#SavedVars)
= function()
  return l.accountSavedVars
end

m.getCharacterSavedVars -- #()->(#SavedVars)
= function()
  return l.characterSavedVars
end

m.getSavedVars -- #()->(#SavedVars)
= function()
  return l.getSavedVars()
end

--========================================
--        register
--========================================
addon.register("Settings#M",m)
addon.hookStart(l.onStart)
