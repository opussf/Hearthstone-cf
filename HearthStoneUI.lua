HS_SLUG, HS      = ...
HS.displayList = {}

function HS.ShowConfig()
	HSConfig:ClearAllPoints()
	HSConfig:SetPoint("CENTER", "$parent", "CENTER")
	HSConfig:Show()
	HS.UpdateUI()
	EventRegistry:RegisterCallback("CollectionsJournal.TabSet", function(event, _, tabIndex)
		if tabIndex == 3 then
			HSConfig:ClearAllPoints()
			HSConfig:SetPoint("LEFT", "CollectionsJournal", "RIGHT")
		end
	end, HS_SLUG )
end
HS.commandList[HS.L["config"]] = {
	["func"] = HS.ShowConfig,
	["help"] = {"", HS.L["config"]}
}

function HS.UIInit()
	HS.TagDropDownBuild( HSConfig_TagDropDownMenu )
	HS.ModifierDropDownBuild( HSConfig_ModifierDropDownMenu )
	HS.BuildBars()
end
function HS.TagDropDownBuild( self )
	UIDropDownMenu_Initialize( self, HS.TagDropDownPopulate )
	UIDropDownMenu_JustifyText( self, "LEFT" )
end
function HS.TagDropDownPopulate( self, level, menuList )
	local tagList = {}

	for hash in pairs( HS_settings.tags ) do
		table.insert( tagList, hash )
	end
	table.sort( tagList )
	for _, tag in ipairs( tagList ) do
		info = UIDropDownMenu_CreateInfo()
		info.text = tag
		info.notCheckable = true
		-- info.arg1 = tag
		info.func = HS.SetTagForEdit
		UIDropDownMenu_AddButton( info, level )
	end
	UIDropDownMenu_SetText( self, tagList[1] )
	HS.editTag = tagList[1]
end
function HS.SetTagForEdit( info )
	-- takes the info table
	-- print( "SetTagForEdit( "..info.value.." )" )
	-- UIDropDownMenu_SetText( )
	HS.editTag = info.value
	UIDropDownMenu_SetText( HSConfig_TagDropDownMenu, info.value )
	HSConfig_TagEditBox:SetText( info.value )
	HS.UpdateUI()
end
function HS.ModifierDropDownBuild( self )
	UIDropDownMenu_Initialize( self, HS.ModifierDropDownInit )
	UIDropDownMenu_JustifyText( self, "LEFT" )
end
function HS.ModifierDropDownInit( self, level, menuList )
	local modList = { "normal" }
	for _, mod in ipairs( HS.modOrder ) do
		table.insert( modList, mod )
	end
	for _, mod in ipairs( modList ) do
		info = UIDropDownMenu_CreateInfo()
		info.text = mod
		info.notCheckable = true
		info.func = HS.SetModForEdit
		UIDropDownMenu_AddButton( info, level )
	end
	UIDropDownMenu_SetText( self, "normal" )
end
function HS.SetModForEdit( info )
	-- print( "SetModForEdit( "..info.value.." )" )
	-- UIDropDownMenu_SetText( )
	UIDropDownMenu_SetText( HSConfig_ModifierDropDownMenu, info.value )
	HS.UpdateUI()
end
-------
function HS.TagButtonOnClick( self, action )
	-- print( "TagButtonOnClick( ", self, ", ", action, " )" )
	if action == "add" then
		local newTag = HSConfig_TagEditBox:GetText()
		if string.len( newTag ) > 0 then
			if string.sub( newTag, 1, 1 ) ~= "#" then
				newTag = "#"..newTag
			end
			if not HS_settings.tags[newTag] then
				-- print( "add: ", newTag )
				HS_settings.tags[newTag] = {}
				HS.TagDropDownBuild( HSConfig_TagDropDownMenu )
			end
		end
	elseif action == "edit" then
		local selectedTag = UIDropDownMenu_GetText( HSConfig_TagDropDownMenu )
		local newTag = HSConfig_TagEditBox:GetText()
		if string.len( newTag ) > 0 then
			if string.sub( newTag, 1, 1 ) ~= "#" then
				newTag = "#"..newTag
			end
			if not HS_settings.tags[newTag] then
				-- print( "rename: ", selectedTag, "=>", newTag )
				HS_settings.tags[newTag] = HS_settings.tags[selectedTag]
				HS_settings.tags[selectedTag] = nil
				HS.TagDropDownBuild( HSConfig_TagDropDownMenu )
				HS.editTag = newTag
				UIDropDownMenu_SetText( HSConfig_TagDropDownMenu, HS.editTag )
				HSConfig_TagEditBox:SetText( HS.editTag )
			end
		end
	elseif action == "del" then
		local selectedTag = UIDropDownMenu_GetText( HSConfig_TagDropDownMenu )
		if selectedTag then
			-- print( "delete:", selectedTag )
			HS_settings.tags[selectedTag] = nil
			HS.TagDropDownBuild( HSConfig_TagDropDownMenu )
			HS.UpdateUI()
		end
	end
end

---------
function HS.BuildBars()
	-- print( "HS.BuildBars" )
	if not HS.bars then
		HS.bars = {}
	end
	showNumBars = 9
	local count = #HS.bars
	for idx = count+1, showNumBars do
		HS.bars[idx] = {}
		local item = CreateFrame( "Frame", "HS_ItemBar"..idx, HSConfig_ToyList, "HSToy_template" )
		HS.bars[idx].bar = item
		if idx == 1 then
			item:SetPoint( "TOPLEFT", "HSConfig_ToyList", "TOPLEFT", 5, -5 )
		else
			item:SetPoint( "TOPLEFT", HS.bars[idx-1].bar, "BOTTOMLEFT", 0, 0 )
		end
		item:Hide()
	end
end
--------
function HS.UpdateUI()
	if HSConfig:IsVisible() and HS_settings.tags then
		local tag = UIDropDownMenu_GetText( HSConfig_TagDropDownMenu )
		local mod = UIDropDownMenu_GetText( HSConfig_ModifierDropDownMenu )
		if tag and mod then
			local count = ( ( HS_settings.tags[tag] and HS_settings.tags[tag][mod] ) and #HS_settings.tags[tag][mod] or 0 )
			HSConfig_ToyListVSlider:SetMinMaxValues( 0, max( 0, count-9 ) )
			if count > 0 then
				local offset = math.floor( HSConfig_ToyListVSlider:GetValue() )
				local name, icon, barName
				for i = 1, 9 do
					local idx = i + offset
					if idx <= count then
						name, _, _, _, _, _, _, _, _, icon = GetItemInfo(HS_settings.tags[tag][mod][idx])
						if name then
							barName = HS.bars[i].bar:GetName()
							_G[barName.."ToyName"]:SetText( name )
							_G[barName.."Icon"]:SetTexture( icon )
							HS.bars[i].bar.itemID = HS_settings.tags[tag][mod][idx]
							HS.bars[i].bar.itemIdx = idx
							HS.bars[i].bar:Show()
						else
							-- print( "name:", name, icon )
							HS.toCache = HS.toCache or {}
							HS.toCache[tonumber(HS_settings.tags[tag][mod][idx])] = true
						end
					else
						HS.bars[i].bar:Hide()
					end
				end
			elseif( HS.bars and count == 0 ) then
				for i = 1, 9 do
					HS.bars[i].bar:Hide()
				end
			end
			HSConfig_Preview:SetText( HS.MakeUseLine( tag ) )
			HSConfig_Preview:SetCursorPosition(0)
		end
	end
end
function HS.UIMouseWheel( delta )
	HSConfig_ToyListVSlider:SetValue(
		HSConfig_ToyListVSlider:GetValue() - delta
	)
end
function HS.UIBarOnMouseDown()
	local focus = GetMouseFoci()[1]
	if focus then
		local _, itemLink = GetItemInfo( focus.itemID )
		SetItemRef( "item:"..focus.itemID, itemLink )  -- button?
	end
end
function HS.UIOnMouseDown()
	HSConfig:StartMoving()
end
function HS.UIOnMouseUp()
	HSConfig:StopMovingOrSizing()
end
function HS.UIOnHide()
	EventRegistry:UnregisterCallback("CollectionsJournal.TabSet", HS_SLUG)
end
function HS.UIOnReceiveDrag( self )
	-- print( "HS.UIOnReceiveDrag( ", self, " )" )
	local type, itemID, itemLink = GetCursorInfo()
	-- print( type, itemID, itemLink )
	if type == "item" then
		local tag = UIDropDownMenu_GetText( HSConfig_TagDropDownMenu )
		local mod = UIDropDownMenu_GetText( HSConfig_ModifierDropDownMenu )
		if HS_settings.tags[tag][mod] then
			table.insert( HS_settings.tags[tag][mod], itemID )
		else
			HS_settings.tags[tag][mod] = {itemID}
		end
	end
	ClearCursor()
	HS.UpdateUI()
end
function HS.DelToyButtonOnClick( self )
	-- print( "HS.BarOnMouseDown( ", self, " )" )
	local tag = UIDropDownMenu_GetText( HSConfig_TagDropDownMenu )
	local mod = UIDropDownMenu_GetText( HSConfig_ModifierDropDownMenu )
	local idx = self:GetParent().itemIdx

	table.remove( HS_settings.tags[tag][mod], idx )
	if #HS_settings.tags[tag][mod] == 0 then
		HS_settings.tags[tag][mod] = nil
	end
	HS.UpdateUI()
end
-------
function HS.ToyBoxButtonOnClick( self )
	ToggleCollectionsJournal(3)
end
function HS.UIAdjustButton( self )
	self:SetWidth( self.Text:GetStringWidth() + 24 )
end
-------
function HS.BuildExportString()
	local hashStruct = HS_settings.tags[UIDropDownMenu_GetText( HSConfig_TagDropDownMenu )]
	local modList = { [0]="normal" }
	for _, mod in ipairs( HS.modOrder ) do
		table.insert( modList, mod )
	end
	local itemBitWidth=1
	local dataEntries = { { value=itemBitWidth, bitWidth=5 } }  -- come back and set this with the right bitWidth
	local l2 = math.log(2)
	for idx = 0, #modList do
		local itemCount = ( hashStruct[modList[idx]] and #hashStruct[modList[idx]] or 0 )
		table.insert( dataEntries, { value=itemCount, bitWidth=8 } )  -- 8 bits (0-255)
		if itemCount > 0 then
			for _, itemID in ipairs( hashStruct[modList[idx]] ) do
				itemID = tonumber( itemID )
				itemBitWidth = math.max( itemBitWidth, math.log( itemID )/l2 )
				table.insert( dataEntries, { value=itemID, bitWidth=0 } )
			end
		end
	end
	itemBitWidth = math.ceil( itemBitWidth )
	dataEntries[1].value = itemBitWidth
	for _, struct in ipairs( dataEntries ) do
		if struct.bitWidth == 0 then
			struct.bitWidth = itemBitWidth
		end
	end
	return ExportUtil.ConvertToBase64( dataEntries )
end
function HS.ExportOnClick()
	HSImport:Hide()
	HSExport_EditBox:SetText(HS.BuildExportString())
	HSExport_EditBox:HighlightText()
	HSExport_EditBox:SetFocus()
	HSExport:Show()
end
function HS.ExportLink()
	local exportHash = HS.BuildExportString() -- rebuilt in case the editbox is corrupted
	ChatFrame_OpenChat( string.format( "HearthStone Import: %s", exportHash ) )
end
---------
function HS.ImportOnClick()
	HSExport:Hide()
	HSImport:Show()
end
function HS.ImportFromString()
	local newTag = HSImport_TagEditBox:GetText()
	local importString = HSImport_EditBox:GetText()
	if string.len( newTag ) > 0 and string.len( importString ) > 0 then
		local modList = { [0]="normal" }
		for _, mod in ipairs( HS.modOrder ) do
			table.insert( modList, mod )
		end
		if string.sub( newTag, 1, 1 ) ~= "#" then
			newTag = "#"..newTag
		end
		if not HS_settings.tags[newTag] then
			local itemID
			HS_settings.tags[newTag] = {}
			local IDS = CreateFromMixins( ImportDataStreamMixin )
			IDS:Init( importString )
			-- print( "-bits:", IDS:GetNumberOfBits(), IDS.currentExtractedBits, IDS.currentRemainingValue )
			local itemBitWidth = IDS:ExtractValue( 5 )
			for idx = 0, #modList do
				local itemCount = IDS:ExtractValue( 8 )
				-- print( "--bits:", IDS:GetNumberOfBits(), IDS.currentExtractedBits, IDS.currentRemainingValue )
				for i = 1,( itemCount or 0 ) do
					itemID = IDS:ExtractValue( itemBitWidth )
					-- print( "---bits:", IDS:GetNumberOfBits(), IDS.currentExtractedBits, IDS.currentRemainingValue )
					HS_settings.tags[newTag][modList[idx]] = HS_settings.tags[newTag][modList[idx]] or {}
					table.insert( HS_settings.tags[newTag][modList[idx]], itemID )
				end
			end
		end
		HS.TagDropDownBuild( HSConfig_TagDropDownMenu )
		UIDropDownMenu_SetText( HSConfig_TagDropDownMenu, newTag )
		HSConfig_TagEditBox:SetText( newTag )
		HS.UpdateUI()
	end
end
