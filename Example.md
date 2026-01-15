# Valkyrie UI Library

A modern, clean UI library for Roblox with a sleek dark theme and comprehensive components.

## Installation

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/notefate/valkyrie-ui-Library/refs/heads/main/ui.lua"))()
```

## Quick Start

```lua
local Valkyrie = loadstring(game:HttpGet("https://raw.githubusercontent.com/notefate/valkyrie-ui-Library/refs/heads/main/ui.lua"))()

local window = Valkyrie:CreateWindow({
    title = "My Script",
    size = UDim2.fromOffset(550, 600),
    toggleKey = Enum.KeyCode.RightControl
})
```

## Functions

### Window Functions

#### `Valkyrie:CreateWindow(options)`
Creates a new window with the specified options.

**Options:**
- `title` - Window title (string)
- `size` - Window size (UDim2)
- `toggleKey` - Keybind to toggle UI (KeyCode)

**Returns:** Window object

```lua
local window = Valkyrie:CreateWindow({
    title = "Example Script",
    size = UDim2.fromOffset(550, 600),
    toggleKey = Enum.KeyCode.RightControl
})
```

#### `window:CreateTab(name)`
Creates a new tab in the sidebar.

**Returns:** Tab object

```lua
local mainTab = window:CreateTab("Main")
```

#### `window:Notify(options)`
Displays a notification.

**Options:**
- `title` - Notification title
- `text` - Notification message
- `duration` - Display duration in seconds

```lua
window:Notify({
    title = "Success",
    text = "Feature enabled!",
    duration = 3
})
```

#### `window:SetVisible(bool)`
Shows or hides the window.

```lua
window:SetVisible(true)
```

#### `window:ToggleVisible()`
Toggles window visibility.

```lua
window:ToggleVisible()
```

#### `window:Destroy()`
Destroys the window completely.

```lua
window:Destroy()
```

---

### Tab Functions

#### `tab:CreatePage(name)`
Creates a new page within the tab.

**Returns:** Page object

```lua
local mainPage = mainTab:CreatePage("Main")
```

---

### Page Functions

#### `page:CreateSection(name)`
Creates a new section on the page.

**Returns:** Section object

```lua
local section = mainPage:CreateSection("Features")
```

---

### Section Functions

#### `section:AddButton(text, callback)`
Adds a clickable button.

```lua
section:AddButton("Click Me", function()
    print("Button clicked!")
end)
```

#### `section:AddToggle(text, default, callback)`
Adds a toggle switch.

```lua
section:AddToggle("Enable Feature", false, function(enabled)
    print("Toggle:", enabled)
end)
```

#### `section:AddTextbox(text, default, callback)`
Adds a text input box.

```lua
section:AddTextbox("Enter Text", "", function(text, enterPressed)
    print("Input:", text)
end)
```

#### `section:AddSlider(options)`
Adds a draggable slider.

**Options:**
- `name` - Slider label
- `min` - Minimum value
- `max` - Maximum value
- `default` - Starting value
- `step` - Increment step
- `suffix` - Text suffix (e.g., "%")
- `callback` - Function called on change

```lua
section:AddSlider({
    name = "Speed",
    min = 0,
    max = 100,
    default = 50,
    step = 1,
    suffix = "%",
    callback = function(value)
        print("Speed:", value)
    end
})
```

#### `section:AddKeybind(text, default, callback)`
Adds a keybind selector.

```lua
section:AddKeybind("Toggle Key", Enum.KeyCode.E, function(key)
    print("New key:", key.Name)
end)
```

#### `section:AddDropdown(options)`
Adds a dropdown menu.

**Options:**
- `name` - Dropdown label
- `items` - List of options
- `default` - Default selection
- `callback` - Function called on selection

```lua
section:AddDropdown({
    name = "Select Mode",
    items = {"Mode 1", "Mode 2", "Mode 3"},
    default = "Mode 1",
    callback = function(selected)
        print("Selected:", selected)
    end
})
```

#### `section:AddMultiDropdown(options)`
Adds a multi-selection dropdown.

**Options:**
- `name` - Dropdown label
- `items` - List of options
- `default` - Default selections (table)
- `callback` - Function called on change

```lua
section:AddMultiDropdown({
    name = "Select Multiple",
    items = {"Option 1", "Option 2", "Option 3"},
    default = {"Option 1"},
    callback = function(selected)
        print("Selected:", table.concat(selected, ", "))
    end
})
```

#### `section:AddColorpicker(options)`
Adds a color picker with HSV support.

**Options:**
- `name` - Color picker label
- `default` - Default color (Color3)
- `callback` - Function called on color change

```lua
section:AddColorpicker({
    name = "ESP Color",
    default = Color3.fromRGB(255, 0, 0),
    callback = function(color)
        print("Color:", color)
    end
})
```

#### `section:AddLabel(text)`
Adds a text label.

```lua
section:AddLabel("This is informational text")
```

---

## Complete Example

```lua
local Valkyrie = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/ui.lua"))()

local window = Valkyrie:CreateWindow({
    title = "Example Script",
    size = UDim2.fromOffset(550, 600),
    toggleKey = Enum.KeyCode.RightControl
})

local mainTab = window:CreateTab("Main")
local mainPage = mainTab:CreatePage("Main")
local section = mainPage:CreateSection("Features")

section:AddButton("Teleport to Spawn", function()
    game.Players.LocalPlayer.Character:MoveTo(Vector3.new(0, 50, 0))
end)

section:AddToggle("Speed Boost", false, function(enabled)
    if enabled then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
    else
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

section:AddSlider({
    name = "FOV",
    min = 70,
    max = 120,
    default = 90,
    step = 1,
    callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end
})

section:AddDropdown({
    name = "Game Mode",
    items = {"Normal", "Speed", "Stealth"},
    default = "Normal",
    callback = function(mode)
        print("Mode:", mode)
    end
})

section:AddColorpicker({
    name = "Highlight Color",
    default = Color3.fromRGB(255, 0, 0),
    callback = function(color)
        print("Color changed:", color)
    end
})

window:Notify({
    title = "Welcome",
    text = "Script loaded successfully!",
    duration = 3
})
```
