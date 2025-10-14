# MogMover

A Windower addon for FFXI that automatically moves items from your inventory to designated storage locations when you receive them.

## Features

- **Automatic Item Movement**: Automatically moves configured items to specified storage locations
- **Toggle On/Off**: Easily disable auto-moving when you need to use items
- **Item Mapping**: Build a list of item-to-storage mappings
- **Queue System**: Safely queues and processes moves with configurable delays
- **Multiple Storage Support**: Supports all Mog storage locations

## Installation

1. Place the `MogMoverMover` folder in your `Windower/addons/` directory
2. Load the addon with: `//lua load autoitemmover`
3. Add to your `Windower/scripts/init.txt` to load automatically on startup

## Commands

All commands can be used with `//mogmover`, `//mm`:

### Basic Commands

- `//mm on` - Enable automatic item moving
  - **Note:** Automatically checks inventory and queues any items matching your mappings!
- `//mm off` - Disable automatic item moving (use when you need the items)
- `//mm toggle` - Toggle the enabled state
  - **Note:** When toggling on, automatically checks inventory for items to move
- `//mm help` - Display help information

### Managing Mappings

- `//mm add <item name> <storage>` - Add an item mapping
  - Example: `//mm add "Ra'Kaznar Starstone" "mog case"`
  - Example: `//mm add "Copper Ore" safe`
  - **Note:** If the item is currently in your inventory, it will be automatically queued to move!
  
- `//mm remove <item name>` - Remove an item mapping
  - Example: `//mm remove "Ra'Kaznar Starstone"`
  - Aliases: `rem`, `delete`, `del`
  
- `//mm list` - List all configured item mappings
  - Alias: `show`

### Other Commands

- `//mm check` - Manually check inventory and queue items
- `//mm delay [seconds]` - View or set the delay between moves (default: 1.5)
  - Example: `//mm delay 2.0` - Set delay to 2 seconds
  - Example: `//mm delay` - View current delay

## Storage Locations

The following storage locations are supported:

### Primary Storage
- `safe` or `mog safe` - Mog Safe
- `safe2` or `mog safe 2` - Mog Safe 2
- `storage` or `mog storage` - Mog Storage
- `locker` or `mog locker` - Mog Locker
- `satchel` or `mog satchel` - Mog Satchel
- `sack` or `mog sack` - Mog Sack
- `case` or `mog case` - Mog Case

### Wardrobes
- `wardrobe` - Mog Wardrobe
- `wardrobe2` through `wardrobe8` - Mog Wardrobe 2-8

## Usage Examples

### Example 1: Auto-store Omen cards
```
//mm add "Fu's Scale" case
//mm add "Kei's Scale" case
//mm add "Kyou's Scale" case
//mm add "Kin's Scale" case
```

### Example 2: Auto-store crafting materials
```
//mm add "Copper Ore" storage
//mm add "Iron Ore" storage
//mm add "Mythril Ore" storage
```

### Example 3: Temporarily disable for using items
```
//mm off
// ... do your synthesis or use items ...
//mm on
```

### Example 4: List all configured items
```
//mm list
```

### Example 5: Add mapping and immediately move items you already have
```
// If you have "Ra'Kaznar Starstone" in your inventory right now:
//mm add "Ra'Kaznar Starstone" case
// The item will be automatically queued and moved!
```

### Example 6: Add mappings while disabled, then enable to move them all
```
//mm off
//mm add "Copper Ore" storage
//mm add "Iron Ore" storage
//mm add "Mythril Ore" storage
// Items are mapped but won't move yet since it's disabled
//mm on
// Now all three items (if in inventory) are automatically queued and moved!
```

## How It Works

1. When enabled, the addon monitors your inventory for new items
2. When an item is received that matches a configured mapping, it's added to a move queue
3. The queue is processed automatically with a delay between moves to prevent server issues
4. Items are moved from inventory to the configured storage location
5. **When you add a mapping:** If the item is in your inventory and auto-move is enabled, it's immediately queued
6. **When you enable the addon:** It automatically checks your inventory and queues all items matching your mappings

## Configuration

Settings are automatically saved to `Windower/addons/AutoItemMover/data/settings.xml`

The configuration includes:
- `enabled` - Whether auto-moving is currently enabled
- `mappings` - Table of item ID to storage location mappings
- `delay` - Delay in seconds between item moves (default: 1.5)

## Tips

- Use quotes around item names with spaces or special characters
- Storage location names are case-insensitive
- The addon will warn you if a storage location is full or not available
- Use `//mm off` before doing any activities where you need to use the items
- Queue is cleared on zone changes to prevent issues

## Troubleshooting

**Items aren't moving:**
- Check that the addon is enabled: `//mm list` should show your mappings
- Verify the storage location is available and has space
- Make sure you're not in an event or cutscene

**"Invalid storage location" error:**
- Check the spelling of the storage name
- Use the supported storage names listed above
- Try using aliases like "case" instead of "mog case"

**Items move too fast or slow:**
- Adjust the delay: `//mm delay 2.0` (for 2 seconds)
- Lower delay = faster moves (but may cause issues)
- Higher delay = safer but slower

## Version History

### v1.0.0
- Initial release
- Automatic item moving with configurable mappings
- Toggle on/off functionality
- Support for all Mog storage locations
- Queue system with configurable delays

## Credits

Created for the FFXI Windower community.

## License

This addon is free to use and modify.
