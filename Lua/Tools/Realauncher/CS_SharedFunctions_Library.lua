function ismacos()
	return reaper.GetOS():find('OSX') ~= nil
end

function iswindows()
	return reaper.GetOS():find('Win') ~= nil
end

function copyToClipboard(text)
	reaper.CF_SetClipboard(text)
end

function pasteFromClipboard()
	local fastString = reaper.SNM_CreateFastString("")
	local text = reaper.CF_GetClipboardBig(fastString)
	reaper.SNM_DeleteFastString(fastString)
	return text
end

function calcRelativeNumber(number,currentValue)
	local calc = {}

	calc["+"] = function  (val1,val2) val2 = val2 or 1 ; return val1 + val2	end

	calc["-"] = function  (val1,val2)
		val2 = val2 or 1 return val1 - val2 end

	calc["/"] = function  (val1,val2) return val1 / val2 end

	calc["*"] = function  (val1,val2) return val1 * val2 end

	calc["set"] = function (val1,val2) return val2 or val1 end

	local operator,value = string.match(number,"^([%+%-/%*]?)([%d%.]*)")
	if operator == "" then operator = "set"	end
	if value == "" then value = nil end

	return calc[operator](currentValue,value)
end

function list(title,table)

	local md = "#"..title.."\n\n"
	for key,value in pairs(table) do
		if type(value) == "table" then
			md = md.."##"..key.."\n\n"
			for subkey,subvalue in pairs(value) do
				md = md.."- **"..subkey.."** = "..subvalue.."\n"
			end
			md = md.."\n"
		else
			md = md.."- **"..key.."** = "..value.."\n"
		end
	end

	viewMarkdown(md)
end