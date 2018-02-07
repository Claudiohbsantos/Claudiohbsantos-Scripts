kbInput = {}

kbInput.leftArrow = 1818584692
kbInput.upArrow = 30064
kbInput.rightArrow = 1919379572
kbInput.downArrow = 1685026670
kbInput.deleteKey = 6579564
kbInput.backspace = 8
kbInput.minus = 45
kbInput.plus = 43
kbInput.asterisk = 42
kbInput.spacebar = 32
kbInput.enter = 13
kbInput.quotes = 34
kbInput.parenthesesOpen = 40
kbInput.parenthesesClose = 41
kbInput.tab = 9
kbInput.exclamation = 33
kbInput.equal = 61

kbInput["!"] = kbInput.exclamation
kbInput["_"] = 95 
kbInput[","] = 44 
kbInput["("] = 45 
kbInput["\\"] = 92 
kbInput["/"]  = 47 
kbInput["."] = 46 
kbInput[":"] = 58 
kbInput["\""] = 34 
kbInput["("] = 40 
kbInput[")"] = 41 

kbInput.copy = 3
kbInput.paste = 22

function kbInput.isAnyPrintableSymbol(char)
	if 
		(
	        (char >= 65 -- a
	        and char <= 90) --z
	        or (char >= 97 -- a
	        and char <= 122) --z
	        or ( char >= 212 -- A
	        and char <= 223) --Z
	        or ( char >= 48 -- 0
	        and char <= 57) --Z
	        or char == 95 -- _
	        or char == 44 -- ,
	        or char == 32 -- (space)
	        or char == 45 -- (-)
	        or char == 92 -- \
	        or char == 47 -- / 
	        or char == 46 --.
	        or char == 58 -- :
	        or char == 34 -- "
	        or char == 40 -- (
	        or char == 41 -- )
	        or char == kbInput.exclamation
	        or char == kbInput.equal
	        or char == kbInput.plus
	        or char == kbInput.asterisk
	    )
	then
		return true
	end
end

function kbInput.isNumber(char)
	if  -- regular input
    (
      ( char >= 48 -- 0
      and char <= 57) -- 9
    )
    then 
    	return true
    end
end

-- Combinations

kbInput.ctrl = {}
kbInput.ctrl.ctrl = 4
kbInput.ctrl.s = 19
kbInput.ctrl.t = 20
