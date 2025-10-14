_addon.name = 'MogMover'
_addon.author = 'Kaius @Bahamut'
_addon.version = '1.0.0'
_addon.commands = {'autoitemmover', 'mm'}

require('logger')
require('sets')
require('tables')
config = require('config')
res = require('resources')

-- Default settings
defaults = {}
defaults.enabled = true
defaults.mappings = T{}
defaults.delay = 1.5  -- Delay in seconds between item moves

settings = config.load(defaults)

-- State variables
local enabled = settings.enabled
local move_queue = T{}
local last_move_time = 0
local processing = false

-- Valid storage locations mapping
local storage_map = T{
    ['inventory'] = 0,
    ['safe'] = 1,
    ['storage'] = 2,
    ['temporary'] = 3,
    ['locker'] = 4,
    ['satchel'] = 5,
    ['sack'] = 6,
    ['case'] = 7,
    ['wardrobe'] = 8,
    ['safe2'] = 9,
    ['wardrobe2'] = 10,
    ['wardrobe3'] = 11,
    ['wardrobe4'] = 12,
    ['wardrobe5'] = 13,
    ['wardrobe6'] = 14,
    ['wardrobe7'] = 15,
    ['wardrobe8'] = 16,
}

-- Aliases for storage names
local storage_aliases = T{
    ['mog safe'] = 'safe',
    ['mogsafe'] = 'safe',
    ['mog storage'] = 'storage',
    ['mogstorage'] = 'storage',
    ['mog locker'] = 'locker',
    ['moglocker'] = 'locker',
    ['mog satchel'] = 'satchel',
    ['mogsatchel'] = 'satchel',
    ['mog sack'] = 'sack',
    ['mogsack'] = 'sack',
    ['mog case'] = 'case',
    ['mogcase'] = 'case',
    ['mog safe 2'] = 'safe2',
    ['mogsafe2'] = 'safe2',
    ['inv'] = 'inventory',
    ['temp'] = 'temporary',
    ['tmp'] = 'temporary',
}

-- Normalize storage name
local function normalize_storage_name(name)
    local lower_name = name:lower():trim()
    return storage_aliases[lower_name] or lower_name
end

-- Get storage bag ID from name
local function get_storage_id(storage_name)
    local normalized = normalize_storage_name(storage_name)
    return storage_map[normalized]
end

-- Check if storage is available
local function is_storage_available(bag_id)
    if bag_id == nil then return false end
    local bag_info = windower.ffxi.get_bag_info(bag_id)
    return bag_info and bag_info.enabled and (bag_info.max - bag_info.count) > 0
end

-- Find item in inventory by ID
local function find_item_in_inventory(item_id)
    local items = windower.ffxi.get_items()
    if not items then return nil end
    
    for index, item in ipairs(items.inventory) do
        if type(item) == 'table' and item.id == item_id and item.status == 0 then
            return index, item
        end
    end
    return nil
end

-- Move item to storage
local function move_item(item_id, storage_name)
    local bag_id = get_storage_id(storage_name)
    
    if not bag_id then
        warning('Invalid storage location: %s':format(storage_name))
        return false
    end
    
    if not is_storage_available(bag_id) then
        warning('Storage location not available or full: %s':format(storage_name))
        return false
    end
    
    local index, item = find_item_in_inventory(item_id)
    if not index then
        return false
    end
    
    local item_name = res.items[item_id] and res.items[item_id].name or 'Unknown'
    log('Moving %s to %s':format(item_name, storage_name))
    
    windower.ffxi.put_item(bag_id, index, item.count)
    return true
end

-- Process move queue
local function process_queue()
    if processing then return end
    
    local current_time = os.clock()
    if current_time - last_move_time < settings.delay then
        return
    end
    
    if move_queue:length() == 0 then
        return
    end
    
    processing = true
    local move_data = move_queue:remove(1)
    
    if move_item(move_data.item_id, move_data.storage) then
        last_move_time = current_time
    end
    
    processing = false
end

-- Check inventory for items to move
local function check_inventory()
    if not enabled then return end
    if not windower.ffxi.get_info().logged_in then return end
    
    local items = windower.ffxi.get_items()
    if not items then return end
    
    for index, item in ipairs(items.inventory) do
        if type(item) == 'table' and item.id ~= 0 and item.status == 0 then
            local item_id_str = tostring(item.id)
            if settings.mappings[item_id_str] then
                local storage_name = settings.mappings[item_id_str]
                
                -- Check if already in queue
                local already_queued = false
                for _, queued in ipairs(move_queue) do
                    if queued.item_id == item.id then
                        already_queued = true
                        break
                    end
                end
                
                if not already_queued then
                    move_queue:append({item_id = item.id, storage = storage_name})
                end
            end
        end
    end
end

-- Add item mapping
local function add_mapping(item_name, storage_name)
    -- Find item by name
    local item_ids = S{}
    for id, item in pairs(res.items) do
        if item.name:lower() == item_name:lower() or item.name_log:lower() == item_name:lower() then
            item_ids:add(id)
        end
    end
    
    if item_ids:empty() then
        error('Item not found: %s':format(item_name))
        return false
    end
    
    -- Validate storage name
    local bag_id = get_storage_id(storage_name)
    if not bag_id then
        error('Invalid storage location: %s':format(storage_name))
        return false
    end
    
    -- Add mapping for all matching items
    local items_found_in_inventory = S{}
    for item_id in item_ids:it() do
        settings.mappings[tostring(item_id)] = normalize_storage_name(storage_name)
        local item_data = res.items[item_id]
        log('Added mapping: %s -> %s':format(item_data.name, storage_name))
        
        -- Check if this item is currently in inventory
        local index, item = find_item_in_inventory(item_id)
        if index then
            items_found_in_inventory:add(item_id)
        end
    end
    
    settings:save('all')
    
    -- If we found any of these items in inventory and auto-move is enabled, queue them
    if not items_found_in_inventory:empty() then
        if enabled then
            for item_id in items_found_in_inventory:it() do
                -- Check if already in queue
                local already_queued = false
                for _, queued in ipairs(move_queue) do
                    if queued.item_id == item_id then
                        already_queued = true
                        break
                    end
                end
                
                if not already_queued then
                    move_queue:append({item_id = item_id, storage = normalize_storage_name(storage_name)})
                    local item_data = res.items[item_id]
                    log('Queued %s for moving':format(item_data.name))
                end
            end
        else
            log('Note: Item(s) found in inventory but auto-move is disabled. Use //mm on to enable.')
        end
    end
    
    return true
end

-- Remove item mapping
local function remove_mapping(item_name)
    -- Find item by name
    local item_ids = S{}
    for id, item in pairs(res.items) do
        if item.name:lower() == item_name:lower() or item.name_log:lower() == item_name:lower() then
            item_ids:add(id)
        end
    end
    
    if item_ids:empty() then
        error('Item not found: %s':format(item_name))
        return false
    end
    
    -- Remove mapping
    for item_id in item_ids:it() do
        local item_id_str = tostring(item_id)
        if settings.mappings[item_id_str] then
            local item_data = res.items[item_id]
            log('Removed mapping: %s':format(item_data.name))
            settings.mappings[item_id_str] = nil
        end
    end
    
    settings:save('all')
    return true
end

-- List all mappings
local function list_mappings()
    if table.empty(settings.mappings) then
        log('No item mappings configured.')
        return
    end
    
    log('Current item mappings:')
    for item_id_str, storage in pairs(settings.mappings) do
        local item_id = tonumber(item_id_str)
        local item = res.items[item_id]
        if item then
            log('  %s -> %s':format(item.name, storage))
        end
    end
end

-- Command handler
windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'help'
    local args = {...}
    
    if command == 'on' then
        enabled = true
        settings.enabled = true
        settings:save('all')
        log('MogMover enabled')
        -- Check inventory for any items that match mappings
        coroutine.schedule(function()
            check_inventory()
            if move_queue:length() > 0 then
                log('Found %d item(s) in inventory to move':format(move_queue:length()))
            end
        end, 0.5)
        
    elseif command == 'off' then
        enabled = false
        settings.enabled = false
        settings:save('all')
        log('MogMover disabled')
        
    elseif command == 'toggle' then
        enabled = not enabled
        settings.enabled = enabled
        settings:save('all')
        log('MogMover %s':format(enabled and 'enabled' or 'disabled'))
        -- If we just enabled it, check inventory
        if enabled then
            coroutine.schedule(function()
                check_inventory()
                if move_queue:length() > 0 then
                    log('Found %d item(s) in inventory to move':format(move_queue:length()))
                end
            end, 0.5)
        end
        
    elseif command == 'add' then
        if #args < 2 then
            error('Usage: //mm add <item name> <storage location>')
            return
        end
        
        -- Join all args except last as item name (handles multi-word items)
        local storage_name = args[#args]
        table.remove(args)
        local item_name = table.concat(args, ' ')
        
        add_mapping(item_name, storage_name)
        
    elseif command == 'remove' or command == 'rem' or command == 'delete' or command == 'del' then
        if #args < 1 then
            error('Usage: //mm remove <item name>')
            return
        end
        
        local item_name = table.concat(args, ' ')
        remove_mapping(item_name)
        
    elseif command == 'list' or command == 'show' then
        list_mappings()
        
    elseif command == 'check' then
        check_inventory()
        log('Inventory check complete. Queue size: %d':format(move_queue:length()))
        
    elseif command == 'delay' then
        if #args > 0 then
            local new_delay = tonumber(args[1])
            if new_delay and new_delay > 0 then
                settings.delay = new_delay
                settings:save('all')
                log('Delay set to %.1f seconds':format(new_delay))
            else
                error('Invalid delay value. Must be a positive number.')
            end
        else
            log('Current delay: %.1f seconds':format(settings.delay))
        end
        
    elseif command == 'help' then
        log('MogMover Commands:')
        log('  //mm on          - Enable auto-moving')
        log('  //mm off         - Disable auto-moving')
        log('  //mm toggle      - Toggle enabled state')
        log('  //mm add <item> <storage> - Add item mapping')
        log('  //mm remove <item> - Remove item mapping')
        log('  //mm list        - List all mappings')
        log('  //mm check       - Manually check inventory')
        log('  //mm delay [sec] - View/set move delay')
        log('')
        log('Storage locations: safe, safe2, storage, locker, satchel, sack, case')
        log('                   wardrobe, wardrobe2-8')
        log('')
        log('Example: //mm add "Ra\'Kaznar Starstone" "mog case"')
        
    else
        error('Unknown command: %s. Use //mm help for help.':format(command))
    end
end)

-- Monitor inventory changes via packet
windower.register_event('incoming chunk', function(id, data)
    -- 0x01D = Item update packet (when item is added to inventory)
    if id == 0x01D then
        -- Delay check slightly to allow packet processing
        coroutine.schedule(function()
            check_inventory()
        end, 0.5)
    end
end)

-- Regular heartbeat to process queue
windower.register_event('prerender', function()
    process_queue()
end)

-- Check on load
windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        coroutine.schedule(function()
            log('MogMover loaded. Current state: %s':format(enabled and 'enabled' or 'disabled'))
            log('Use //mm help for commands.')
        end, 2)
    end
end)

-- Check on login
windower.register_event('login', function()
    coroutine.schedule(function()
        log('MogMover loaded. Current state: %s':format(enabled and 'enabled' or 'disabled'))
    end, 2)
end)

-- Check on zone
windower.register_event('zone change', function()
    move_queue = T{}  -- Clear queue on zone change
end)
