# Quick Start Guide

## Getting Started with MogMover

### 1. Load the Addon
```
//lua load mogmover
```

Or add to your `Windower/scripts/init.txt`:
```
lua load mogmover
```

### 2. Add Your First Item Mapping
```
//mm add "Ra'Kaznar Starstone" case
```

This will automatically move "Ra'Kaznar Starstone" to your Mog Case when you receive it.

**Bonus:** If you already have this item in your inventory, it will be immediately queued to move!

### 3. Check Your Mappings
```
//mm list
```

### 4. Test It
- Go get the item you configured
- Watch as it automatically moves to the storage location!

### 5. When You Need to Use the Items
```
//mm off
```

Use your items, then turn it back on:
```
//mm on
// Any items matching your mappings will be automatically queued!
```

## Common Use Cases

### Omen Farm Setup
```
//mm add "Fu's Scale" case
//mm add "Kei's Scale" case
//mm add "Kyou's Scale" case
//mm add "Kin's Scale" case
//mm add "Gin's Scale" case
```

### Crafting Materials
```
//mm add "Copper Ore" satchel
//mm add "Iron Ore" satchel
//mm add "Mythril Ore" satchel
```

### Setting Up Multiple Mappings While Disabled
```
//mm off
//mm add "Copper Ore" satchel
//mm add "Iron Ore" satchel
//mm add "Mythril Ore" satchel
//mm on
// All three items (if in inventory) are now queued and moving!
```

## Important Tips

1. **Always use quotes** around item names with spaces or apostrophes
2. **Turn off before using items** - Use `//mm off` when you need to use the items
3. **Check spelling** - Item names must match exactly (case-insensitive)
4. **Verify storage space** - Make sure the target storage has room
5. **Instant move when adding** - Items in inventory are automatically queued when you add a mapping
6. **Instant move when enabling** - When you turn the addon on, it checks your entire inventory and queues all matching items!

## Need Help?

Use `//mm help` to see all available commands.

See `examples.lua` for more example item mappings.

Check `README.md` for full documentation.
