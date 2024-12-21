-- Default localization (fallback)
if not ResourceBarLocalization then
  ResourceBarLocalization = {
    Health = "Health",
    Mana = "Mana",
    Rage = "Rage",
    Energy = "Energy"
  }
end

-- Create a bar with a consistent border, background, and embedded StatusBar
local function CreateBar(parent, width, height, texture, r, g, b)
  -- Container frame for all elements
  local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  container:SetSize(width, height)

  -- Border (Layer 3: Top layer)
  container:SetBackdrop({
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Border texture
      edgeSize = 12,
      insets = { left = 2, right = 2, top = 2, bottom = 2 }
  })
  container:SetBackdropBorderColor(1, 1, 1, 1) -- White border

  -- Background (Layer 1: Transparent background)
  local bg = container:CreateTexture(nil, "BACKGROUND")
  bg:SetPoint("TOPLEFT", container, "TOPLEFT", 3, -3) -- Adjust position to fit inside border
  bg:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -3, 3) -- Adjust position to fit inside border
  bg:SetColorTexture(0, 0, 0, 0.5) -- Semi-transparent black background

  -- StatusBar (Layer 2: The bar itself)
  local bar = CreateFrame("StatusBar", nil, container)
  bar:SetSize(width - 8, height - 8) -- Fit inside the border
  bar:SetPoint("CENTER", container, "CENTER", 0, 0)
  bar:SetStatusBarTexture(texture)
  bar:SetStatusBarColor(r, g, b)
  bar:SetFrameLevel(container:GetFrameLevel() + 1) -- Ensure it's above the background

  -- Return the container and the bar
  return container, bar
end

-- Create the main frame
local frame = CreateFrame("Frame", "ResourceBarFrame", UIParent)
frame:SetSize(200, 50) -- Adjusted size for both bars
frame:SetPoint("CENTER", UIParent, "CENTER", 0, -100)

-- Health Bar
local hpContainer, hpBar = CreateBar(frame, 200, 20, "Interface\\TargetingFrame\\UI-StatusBar", 0, 1, 0)
hpContainer:SetPoint("TOP", frame, "TOP", 0, 0) -- Kein Abstand nach unten

local hpText = hpBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
hpText:SetPoint("CENTER", hpBar, "CENTER")

-- Resource Bar
local resourceContainer, resourceBar = CreateBar(frame, 200, 20, "Interface\\TargetingFrame\\UI-StatusBar", 0, 0, 1)
resourceContainer:SetPoint("TOP", hpContainer, "BOTTOM", 0, 0) -- Kein Abstand zum oberen Balken

local resourceText = resourceBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
resourceText:SetPoint("CENTER", resourceBar, "CENTER")

-- Update Bars
local function UpdateBars()
  local health = UnitHealth("player")
  local maxHealth = UnitHealthMax("player")
  local healthPercent = (health / maxHealth) * 100
  hpBar:SetMinMaxValues(0, maxHealth)
  hpBar:SetValue(health)
  hpText:SetText(string.format("%s: %d/%d (%.1f%%)", ResourceBarLocalization.Health, health, maxHealth, healthPercent))

  local power = UnitPower("player")
  local maxPower = UnitPowerMax("player")
  local powerType = UnitPowerType("player")

  if powerType == 0 then
    resourceBar:SetStatusBarColor(0, 0, 1)
    resourceBar:SetMinMaxValues(0, maxPower)
    resourceText:SetText(
      string.format("%s: %d/%d (%.1f%%)", ResourceBarLocalization.Mana, power, maxPower, (power / maxPower) * 100)
    )
  elseif powerType == 1 then
    resourceBar:SetStatusBarColor(1, 0, 0)
    resourceBar:SetMinMaxValues(0, 100)
    resourceText:SetText(string.format("%s: %d", ResourceBarLocalization.Rage, power))
  elseif powerType == 3 then
    resourceBar:SetStatusBarColor(1, 1, 0)
    resourceBar:SetMinMaxValues(0, maxPower)
    resourceText:SetText(string.format("%s: %d/%d", ResourceBarLocalization.Energy, power, maxPower))
  else
    resourceBar:SetStatusBarColor(0.5, 0.5, 0.5)
    resourceBar:SetMinMaxValues(0, maxPower)
    resourceText:SetText(string.format("Resource: %d/%d", power, maxPower))
  end
  resourceBar:SetValue(power)
end

-- Register Events
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_POWER_UPDATE")

frame:SetScript(
  "OnEvent",
  function(_, event, arg1)
    if event == "PLAYER_ENTERING_WORLD" or arg1 == "player" then
      UpdateBars()
    end
  end
)

-- Initial Update
UpdateBars()
