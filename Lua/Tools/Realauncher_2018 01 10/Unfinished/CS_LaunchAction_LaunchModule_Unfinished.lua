function ReaperAction(arguments)
	if arguments and string.len(arguments) >= 1 then
		local script_path = get_script_path() 

		main_section_list = script_path.."Main_Section.txt"

		if not action then
			action = {}
			for line in io.lines(main_section_list) do
				local id = string.match(line,"[^\t]*	([^\t]*)	[^\t]*")
				local name = string.match(line,"[^\t]*	[^\t]*	([^\t]*)")
				if id and name then
					action[#action + 1] = {}
					action[#action].id = id 
					action[#action].name = name:lower() 
				end
			end
		end

		local matches = searchMatrixAndReturnMatchesTable(action,realauncher.argumentElement,"name")
		if #matches > 0 then matches = sortMatches(matches) end

		if #matches ~= 0 then

			if not currentAction then 
				currentMatch = 1
			else
				if char == leftArrow then
					currentMatch = currentMatch - 1
					if currentMatch < 1 then currentMatch = 1 end
				end
				if char == rightArrow then
					currentMatch = currentMatch + 1
					if currentMatch > #matches then currentMatch = #matches end
				end
			end

			currentAction = matches[currentMatch]

			local matchesIndex = ""
			if #matches > 1 then matchesIndex = "["..currentMatch.."/"..#matches.."] " end 

			realauncher.argSuggestion = matchesIndex..currentAction.name
		else
			currentAction = nil
		end

		if char == 13 and currentAction then reaper.Main_OnCommand(currentAction.id,0) end
	end
end

registeredCommands.act = {ReaperAction, runImediatelly}