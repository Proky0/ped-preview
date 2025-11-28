# Ped Preview Interface

A Lua interface for FiveM that allows you to create, manipulate and display a real-time ped preview in front of the player's camera with advanced features like animations, scenarios, and dynamic positioning.

## Features

- ✨ Creates a clone of the player's ped in front of the camera
- 🎥 Keeps the ped synchronized with camera movements
- 📏 Applies customizable scaling to the ped
- 🎭 Support for both animations and scenarios
- 🔄 Dynamic rotation based on offset position
- 🎯 Pre-defined positioning (LEFT, RIGHT, CENTER)
- 🧹 Automatic cleanup of scenario objects
- 🚫 Handles collision and network visibility
- 📦 Exportable functions for easy integration

## Usage

### Available Exports

#### Create Preview Ped

```lua
-- Create the preview ped with options
local options = {
    animation = {
        dict = "anim@amb@nightclub@peds@",
        name = "rcmme_amanda1_stand_loop_cop"
    },
    -- OR use a scenario instead
    scenario = "WORLD_HUMAN_SMOKING",
    -- Optional: Custom offset
    offset = { x = 0.5, y = 0.0, z = 0.0 }
}

exports['ped-preview']:createPed(PlayerPedId(), options)

-- Create with preset position
exports['ped-preview']:createPed(PlayerPedId(), {
    offset = Interface.positions.LEFT,
    scenario = "WORLD_HUMAN_AA_COFFEE"
})
```

#### Delete Preview Ped

```lua
-- Delete the preview ped
exports['ped-preview']:deletePed()
```

#### Set Animation

```lua
-- Set the preview ped animation
local animation = {
    dict = "anim@amb@nightclub@peds@",
    name = "rcmme_amanda1_stand_loop_cop"
}

exports['ped-preview']:setPedAnimation(animation)
```

#### Set Scenario

```lua
-- Set the preview ped scenario
exports['ped-preview']:setPedScenario("WORLD_HUMAN_SMOKING")

-- Popular scenarios:
-- WORLD_HUMAN_SMOKING
-- WORLD_HUMAN_AA_COFFEE
-- WORLD_HUMAN_DRINKING
-- WORLD_HUMAN_GUARD_STAND
-- WORLD_HUMAN_CLIPBOARD
-- WORLD_HUMAN_MUSICIAN
```

#### Set Offset

```lua
-- Set custom offset (x = left/right, y = forward/back, z = up/down)
exports['ped-preview']:setPedOffset({ x = 0.5, y = 0.0, z = 0.0 })

-- Use preset positions
exports['ped-preview']:setPedOffset(Interface.positions.LEFT)   -- Left side
exports['ped-preview']:setPedOffset(Interface.positions.RIGHT)  -- Right side

-- Reset to center
exports['ped-preview']:setPedOffset({ x = 0.0, y = 0.0, z = 0.0 })
```

### Configuration

You can adjust these parameters in the code:

```lua
Interface.distance = 1.10   -- Distance from camera
Interface.scalePed = 0.30   -- Ped scale (size: 0.1 = 10%, 1.0 = 100%)

-- Preset positions
Interface.positions = {
    LEFT = vector3(-0.5, 0.0, 0.0),
    RIGHT = vector3(0.5, 0.0, 0.0)
}
```

### Advanced Features

#### Dynamic Rotation

The ped automatically rotates towards the center of the screen when positioned on the sides:

- **Right offset**: Ped turns 50° left per unit
- **Left offset**: Ped turns 50° right per unit
- **Center**: No rotation adjustment

#### Scenario Object Cleanup

When using scenarios, the system automatically detects and cleans up scenario objects (coffee cups, cigarettes, clipboards, etc.) to prevent duplication or persistence issues.

### Example Usage

```lua
-- Example 1: Simple animation preview
exports['ped-preview']:createPed(PlayerPedId(), {
    animation = {
        dict = "anim@amb@nightclub@peds@",
        name = "rcmme_amanda1_stand_loop_cop"
    }
})

-- Example 2: Scenario with offset
exports['ped-preview']:createPed(PlayerPedId(), {
    scenario = "WORLD_HUMAN_SMOKING",
    offset = Interface.positions.RIGHT
})

-- Example 3: Custom positioning
exports['ped-preview']:createPed(PlayerPedId(), {
    animation = {
        dict = "mp_player_inteat@burger",
        name = "mp_player_int_eat_burger"
    },
    offset = { x = -0.3, y = 0.2, z = 0.1 }
})

-- Change animation on the fly
exports['ped-preview']:setPedAnimation({
    dict = "amb@world_human_aa_smoke@male@idle_a",
    name = "idle_c"
})

-- Switch to scenario
exports['ped-preview']:setPedScenario("WORLD_HUMAN_AA_COFFEE")

-- Adjust position
exports['ped-preview']:setPedOffset({ x = 0.5, y = 0.0, z = 0.0 })

-- Clean up
exports['ped-preview']:deletePed()
```

## Requirements

- [FiveM](https://fivem.net/)

## Installation

1. Download or clone this repository
2. Add the `ped-preview` folder to your `resources` directory
3. Add `ensure ped-preview` to your `server.cfg`
4. Restart your server or use `refresh` and `ensure ped-preview`

## Technical Details

### Performance

- Optimized update loop running at 0ms intervals
- Cached math functions for better performance
- Efficient entity scaling using matrix operations

### Compatibility

- Works with any ped model
- Compatible with scenarios and animations
- Handles vehicle camera adjustments
- Network-invisible to other players
- Automatic cleanup on resource stop

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

## Troubleshooting

**Ped disappears or teleports:**

- Check if another script is deleting entities
- Ensure the update thread is running properly

**Scenario objects persist:**

- The script automatically cleans scenario objects
- If issues persist, check the `scenarioObjects` table includes the object hash

**Ped scale is wrong:**

- Adjust `Interface.scalePed` value (0.1 to 1.0)
- Scale is applied every frame, so changes take effect immediately

## Contribution

Contributions are welcome! To suggest an improvement, open an _issue_ or submit a _pull request_ on GitHub. Please follow these steps:

1. Fork the repository and create a dedicated branch (`feature/your-feature`)
2. Clearly describe your changes in the _pull request_
3. Make sure your code follows the project's style
4. Test thoroughly before submitting

Thank you for helping improve this project!

## Credits

Special thanks to:

- [rpemotes-reborn](https://github.com/alberttheprince/rpemotes-reborn) for scenario object cleanup implementation ❤

## License

You are free to use and modify this resource, but you must provide credit to the original author. All rights reserved.

---

**Made with ❤️ for the FiveM community**
