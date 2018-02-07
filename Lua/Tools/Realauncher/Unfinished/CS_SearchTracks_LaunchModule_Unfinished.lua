function SearchTracks(arguments)
	if arguments then
		local  matched_tr_guids = {}
	    for i = 1, reaper.CountTracks(0) do
	      track = reaper.GetTrack(0,i-1)
	      _, tr_name = reaper.GetSetMediaTrackInfo_String( track, 'P_NAME', '', 0 )
	      if tr_name:lower():find(arguments:lower()) then
	        matched_tr_guids[#matched_tr_guids+1] = reaper.GetTrackGUID( track )
	      end
	    end
	    matched = matched_tr_guids

	        -- get id
	        if char ==  rightArrow then  
	          matched_id = matched_id + 1
	          if matched_id > #matched then matched_id = #matched end
	         elseif char == leftArrow then
	          matched_id = matched_id - 1    
	          if    matched_id < 1 then matched_id = 1 end 
	        end
	        
	      if not matched_id then matched_id = 1 end          
	      if last_char and matched_id and last_char > 0 and char == 0 and matched then  
	        sel_track = reaper.BR_GetMediaTrackByGUID( 0, matched[matched_id] )
	        if sel_track then 
	          reaper.SetMixerScroll( sel_track )
	          reaper.Main_OnCommand(40297,0) -- unselect all tracks
	          reaper.SetTrackSelected( sel_track, true )
	          reaper.Main_OnCommand(40913,0)-- vert scroll sel track into view
	        end
	        --
	      end
     end
end

registeredCommands.tr =  {SearchTracks, runImediatelly}