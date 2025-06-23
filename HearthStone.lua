HS_SLUG, HS      = ...
HS_MSG_ADDONNAME = C_AddOns.GetAddOnMetadata( HS_SLUG, "Title" )
HS_MSG_VERSION   = C_AddOns.GetAddOnMetadata( HS_SLUG, "Version" )
HS_MSG_AUTHOR    = C_AddOns.GetAddOnMetadata( HS_SLUG, "Author" )

COLOR_RED = "|cffff0000"
COLOR_GREEN = "|cff00ff00"
COLOR_BLUE = "|cff0000ff"
COLOR_PURPLE = "|cff700090"
COLOR_YELLOW = "|cffffff00"
COLOR_ORANGE = "|cffff6d00"
COLOR_GREY = "|cff808080"
COLOR_GOLD = "|cffcfb52b"
COLOR_NEON_BLUE = "|cff4d4dff"
COLOR_END = "|r"

-- saved log file
HS_log = {}
HS_settings = {}
HS_settings.tags = { ["#hs"] = { ["normal"] = {6948}, } }  -- default to get you going.   Can remove
HS.modOrder = {
	"shiftctrlalt", "shiftctrl", "shiftalt", "shift", "ctrlalt", "ctrl", "alt"
}
HS.hashIgnore = {
	["#show"] = true,
	["#showtooltip"] = true,
	["#showtooltips"] = true,
}

function HS.Print( msg, showName )
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = COLOR_NEON_BLUE..HS_MSG_ADDONNAME.."> "..COLOR_END..msg
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg )
end
function HS.LogMsg( msg, alsoPrint )
	-- alsoPrint, if set to true, prints to console
	local now = time()
	if HS_log[now] then
		table.insert( HS_log[now], msg )
	else
		HS_log[now] = {msg}
	end
	--table.insert( HS_log, { [time()] = msg } )
	if( alsoPrint ) then HS.Print( msg ); end
end
function HS.PruneLog()
	local now = time()
	for ts,_ in pairs( HS_log ) do
		if ts + 3600 < now then
			HS_log[ts] = nil
		end
	end
end
function HS.OnLoad()
	SLASH_HS1 = "/hs"
	SlashCmdList["HS"] = function(msg) HS.Command(msg); end
	HSFrame:RegisterEvent( "PLAYER_LOGIN" )
	HSFrame:RegisterEvent( "LOADING_SCREEN_DISABLED" )
	HSFrame:RegisterEvent( "PLAYER_STARTED_MOVING" )
	HSFrame:RegisterEvent( "PLAYER_REGEN_DISABLED" )
	HSFrame:RegisterEvent( "PLAYER_REGEN_ENABLED" )
	HSFrame:RegisterEvent( "UPDATE_MACROS" )
	HSFrame:RegisterEvent( "GET_ITEM_INFO_RECEIVED" )

	-- HSFrame:RegisterEvent( "NEW_TOY_ADDED" )
	-- HSFrame:RegisterEvent( "TOYS_UPDATED" )
end
function HS.PLAYER_LOGIN( )
	if not HS_settings.tags then  -- version 2 has a different structure
		HS_settings.tags = {}
		HS_settings.tags["#hs"] = {}
		HS_settings.tags["#hs"].normal = HS_settings.normal
		for _, mod in pairs( HS.modOrder ) do
			HS_settings.tags["#hs"][mod] = HS_settings[mod]
		end
	end
	HS.UIInit()
end
function HS.GET_ITEM_INFO_RECEIVED( _, itemID, success )
	-- print( "GET_ITEM_INFO_RECEIVED:", itemID, type(itemID), success )
	if HS.toCache then
		if HS.toCache[itemID] then
			-- print( "Was in the cache" )
			HS.toCache[itemID] = nil
			HS.UpdateUI()
		else
			local cacheCount = 0
			for i in pairs( HS.toCache ) do
				cacheCount = cacheCount + 1
				local name = GetItemInfo( i )
				-- print( "re-request:", i, type(i), name )
			end
			-- print( "toCacheSize:", cacheCount )
			-- if cacheCount == 0 then
			-- 	print( "Cache is empty" )
			-- end
		end
	end
end
-- function HS.TOYS_UPDATED()
-- 	HS.lastToysUpdated = time()
-- 	HS.LogMsg( "TOYS_UPDATED - "..HS.lastToysUpdated, HS_settings.debug )
-- end
function HS.PLAYER_REGEN_DISABLED()
	-- combat start
	HS.inCombat = true
end
function HS.PLAYER_REGEN_ENABLED()
	-- combat end
	HS.inCombat = nil
	if HS.combatUpdate then
		HS.UpdateMacros()
		HS.combatUpdate = nil
	end
end
function HS.LOADING_SCREEN_DISABLED()
	HS.LogMsg( "LOADING_SCREEN_DISABLED", HS_settings.debug )
	HS.PruneLog()
	HS.shouldUpdateMacros = true
	HSFrame:RegisterEvent( "GET_ITEM_INFO_RECEIVED" )
	for tag, mods in pairs( HS_settings.tags ) do
		-- print( "tag:"..tag )
		for mod, items in pairs( mods ) do
			-- print( "mod:"..mod )
			for i,item in pairs( items ) do
				name = GetItemInfo( item )
				-- print( i, item, name )
				if not name then
					HS.toCache = HS.toCache or {}
					HS.toCache[tonumber(item)] = true
				end
			end
		end
	end
end
function HS.PLAYER_STARTED_MOVING()
	if HS.shouldUpdateMacros then
		HS.LogMsg( "PLAYER_STARTED_MOVING and shouldUpdateMacros", HS_settings.debug )
		HS.shouldUpdateMacros = nil
		HS.UpdateMacros()
	end
end
function HS.UPDATE_MACROS()
	if HS.suspendUpdateEvent then return; end
	HS.LogMsg( "UPDATE_MACROS", HS_settings.debug )
	HS.UpdateMacros()
end
function HS.MakeUseLine( hash )
	if HS_settings.tags[hash] then
		local hsLine = "/use "
		for _, modKey in ipairs( HS.modOrder ) do
			if HS_settings.tags[hash][modKey] then
				HS.LogMsg( "List: "..modKey, HS_settings.debug )
				hsLine = hsLine.."[mod:"..modKey.."]"..HS.GetItemFromList(HS_settings.tags[hash][modKey])..";"
			end
		end
		hsLine = hsLine..(HS.GetItemFromList(HS_settings.tags[hash].normal) or "")..hash
		return hsLine
	end
end
function HS.UpdateMacros()
	if HS.inCombat then
		HS.combatUpdate = true
		return
	end
	-- Update Macros
	-- HS.LogMsg( "Update Macro", HS_settings.debug )
	HS.suspendUpdateEvent = true

	-- loop through all macros
	-- look for #hash comments at the end of the line.
	local numGlobal, numCharacter = GetNumMacros()
	for macroIndex = 1, 120+numCharacter do  -- can do 2 loops, or 1 loop and not update unnamed macros.
		local name, _, body = GetMacroInfo( macroIndex )
		if name then
			-- HS.LogMsg( macroIndex..":"..(name or "?")..":"..(body or "nil") )
			HS.macroTable = {}
			HS.ListToTable( body, HS.macroTable )
			for lnum, line in ipairs( HS.macroTable ) do
				s, e, hash = strfind( line, "(#%S+)$" )
				if hash and not HS.hashIgnore[hash] and HS_settings.tags[hash] then
					-- HS.LogMsg( lnum.."> "..line.." "..(s or "").."->"..(e or "").."="..(hash or "nil") )
					HS.macroTable[lnum] = HS.MakeUseLine( hash )
				end
			end
			local macroText = table.concat( HS.macroTable, "\n" )
			if strlen( macroText ) <= 255 then
				-- HS.LogMsg( "Edit macro", HS_settings.debug )
				EditMacro( macroIndex, nil, nil, macroText)
			else
				HS.LogMsg( string.format( HS.L["ERROR"].." ("..name.."-"..(hash or "").."): "..HS.L["Macro length > 255 chars."].." "..HS.L["Please edit source macro."] ), true )
			end
		end
	end
	HS.suspendUpdateEvent = nil
end
function HS.GetItemFromList( list )
	if list then
		local returnItem
		if #list == 1 then
			HS.LogMsg( "Only 1 item found in given list: "..list[1], HS_settings.debug )
			returnItem = list[1]
		else
			local r
			local limit = #list * 10 -- give it a while to choose
			local count = 0
			while( not r and count <= limit ) do
				r = random(#list)
				HS.LogMsg( "Picking "..r.."/"..#list.." ("..list[r]..") "..(select(2, GetItemInfo(list[r])) or "nil"), HS_settings.debug )
				count = count + 1
				if list[r] == "6948" then
					HS.LogMsg("HearthStone: "..(GetItemCount(list[r]) or "no count"), HS_settings.debug)
					r = (GetItemCount(list[r]) == 1 and r or nil) -- HearthStone is an item, clear the selection if not in bags
				else
					-- HS.LogMsg( "PlayerHasToy: "..(PlayerHasToy(list[r]) and "true" or "false" ), HS_settings.debug)
					-- HS.LogMsg( "IsToyUsable : "..(C_ToyBox.IsToyUsable(list[r]) and "true" or "false"), HS_settings.debug)
					-- @TODO: Determine when to not select an item in a list
					-- if not PlayerHasToy(list[r]) or not C_ToyBox.IsToyUsable(list[r]) then
						-- r = nil
					-- end
				end
			end
			if r then
				HS.LogMsg( "Choice of "..r.." is valid." )
				returnItem = list[r]
			end
		end
		if returnItem then
			return( "item:"..returnItem )
		end
	end
end
function HS.ListToTable( list, t )
	for item in string.gmatch( list, '[^\n]+' ) do
		item = item:gsub( '^%s*(.-)%s*$', '%1' )
		table.insert( t, item )
	end
	return t
end

function HS.ParseCmd(msg)
	if msg then
		local a,b,c = strfind(msg, "(%S+)")  --contiguous string of non-space characters
		if a then
			-- c is the matched string, strsub is everything after that, skipping the space
			return c, strsub(msg, b+2)
		else
			return ""
		end
	end
end
function HS.Command( msg )
	local cmd, param = HS.ParseCmd(msg)
	if cmd then
		cmd = string.lower( cmd )
	end
	if HS.commandList[cmd] and HS.commandList[cmd].alias then
		cmd = HS.commandList[cmd].alias
	end
	local cmdFunc = HS.commandList[cmd]
	if cmdFunc and cmdFunc.func then
		cmdFunc.func(param)
	else
		HS.ShowConfig()
	end
end
function HS.PrintHelp()
	HS.Print( string.format(HS.L["%s (%s) by %s"], HS_MSG_ADDONNAME, HS_MSG_VERSION, HS_MSG_AUTHOR ) )
	for cmd, info in pairs(HS.commandList) do
		if info.help then
			local cmdStr = cmd
			for c2, i2 in pairs(HS.commandList) do
				if i2.alias and i2.alias == cmd then
					cmdStr = string.format( "%s / %s", cmdStr, c2 )
				end
			end
			HS.Print(string.format("%s %s %s -> %s",
				SLASH_HS1, cmdStr, info.help[1], info.help[2]))
		end
	end
end
HS.commandList = {
	[HS.L["help"]] = {
		["func"] = HS.PrintHelp,
		["help"] = {"", HS.L["Print this help."]}
	},
	[HS.L["update"]] = {
		["func"] = HS.UpdateMacros,
		["help"] = {"", HS.L["Update macro."]}
	},
	[HS.L["debug"]] = {
		["func"] = function() HS_settings.debug = not HS_settings.debug; HS.Print( "Debug is now: "..(HS_settings.debug and "on" or "off")); end,
		--["help"] = {"", "Toggle Debug"}
	},
}
