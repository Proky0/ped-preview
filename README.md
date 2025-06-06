# Ped Preview Interface

A Lua interface for FiveM that allows you to create, manipulate and display a real-time ped preview in front of the player's camera.

## Features

- Creates a clone of the player's ped in front of the camera
- Keeps the ped synchronized with camera movements
- Applies customizable scaling to the ped
- Automatic animation (crossed arms)
- Handles collision and network visibility
- Exportable functions for easy integration

## Usage

### Available Exports

```lua
-- Create the preview ped
exports['ped-preview']:createPed()

-- Delete the preview ped
exports['ped-preview']:deletePed()

-- Refresh the ped (update appearance)
exports['ped-preview']:refreshPed()
```

### Configuration

You can adjust these parameters in the code:

```lua
Interface.distance = 0.38  -- Distance from camera
Interface.scalePed = 0.10  -- Ped scale (size)
```

## Requirements

- [FiveM](https://fivem.net/)
- Lua scripting environment (like ESX, vRP or standalone)

## Installation

1. Add this script to your `resources` folder
2. Add `ensure ped-preview` to your `server.cfg`
3. Restart your server

## Integration Example

```lua
-- Create preview when player opens a menu
RegisterCommand("showped", function()
  local playerPed = PlayerPedId()
  exports['ped-preview']:createPed( playerPed )
end)

-- Delete preview when menu closes
RegisterCommand("hideped", function()
  exports['ped-preview']:deletePed()
end)
```

## Preview

<table>
  <tr>
    <td align="center">
      <strong>Standard Ped Preview</strong><br>
      <img src="./assets/preview.gif" alt="Ped Preview"/>
    </td>
    <td align="center">
      <strong>Inventory Ped Preview</strong><br>
      <img src="./assets/preview_ox_inventory.gif" alt="Ped Inventory Preview"/>
    </td>
  </tr>
</table>


## Contribution

Contributions are welcome! To suggest an improvement, open an *issue* or submit a *pull request* on GitHub. Please follow these steps:

1. Fork the repository and create a dedicated branch (`feature/your-feature`).
2. Clearly describe your changes in the *pull request*.
3. Make sure your code follows the project's style.

Thank you for helping improve this project!

## License

You are free to use and modify this resource, but you must provide credit to the original author. All rights reserved.