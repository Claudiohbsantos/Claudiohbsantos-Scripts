function renameItemAndSource(arguments)
	if arguments then
		local selItem = reaper.GetSelectedMediaItem(0,0)
		if selItem then
			local activeTake = reaper.GetActiveTake(selItem)
			local source = reaper.GetMediaItemTake_Source(activeTake)

			local sourceFilename = ""
			sourceFilename = reaper.GetMediaSourceFileName(source,sourceFilename)
			local currentName = reaper.GetTakeName(activeTake)
			realauncher.argSuggestion = currentName

			if char == enter then
				local extension = string.sub(sourceFilename,-4)
				local newName = arguments..extension

				reaper.Main_OnCommand(40440,0) -- set selected media offline

				reaper.GetSetMediaItemTakeInfo_String(activeTake,"P_NAME",newName,true)
				local cmd = [[ren "]]..sourceFilename..[[" "]]..newName..[["]]
				os.execute(cmd)

				local sourceDirectory = string.match(sourceFilename,"(.+\\)[^\\].+$")
				local newSourceFilename = sourceDirectory..newName
				reaper.BR_SetTakeSourceFromFile2(activeTake,newSourceFilename,false,true)

				reaper.Main_OnCommand(40441,0) -- rebuild peaks for selected items
			end
		end
	end
end

registeredCommands.rensource = {renameItemAndSource,runImediatelly}