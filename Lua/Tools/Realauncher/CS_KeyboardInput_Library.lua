--[[
@noindex
]]--


kbInput = {}


kbInput["!"] = 33
kbInput["\""] = 34
kbInput["#"] = 35
kbInput["$"] = 36
kbInput["%"] = 37
kbInput["&"] = 38
kbInput["'"] = 39
kbInput["("] = 40
kbInput[")"] = 41
kbInput["*"] = 42
kbInput["+"] = 43
kbInput[","] = 44
kbInput["-"] = 45
kbInput["."] = 46
kbInput["/"] = 47
kbInput["0"] = 48
kbInput["1"] = 49
kbInput["2"] = 50
kbInput["3"] = 51
kbInput["4"] = 52
kbInput["5"] = 53
kbInput["6"] = 54
kbInput["7"] = 55
kbInput["8"] = 56
kbInput["9"] = 57
kbInput[":"] = 58
kbInput[";"] = 59
kbInput["<"] = 60
kbInput["="] = 61
kbInput[">"] = 62
kbInput["?"] = 63
kbInput["@"] = 64
kbInput["A"] = 65
kbInput["B"] = 66
kbInput["C"] = 67
kbInput["D"] = 68
kbInput["E"] = 69
kbInput["F"] = 70
kbInput["G"] = 71
kbInput["H"] = 72
kbInput["I"] = 73
kbInput["J"] = 74
kbInput["K"] = 75
kbInput["L"] = 76
kbInput["M"] = 77
kbInput["N"] = 78
kbInput["O"] = 79
kbInput["P"] = 80
kbInput["Q"] = 81
kbInput["R"] = 82
kbInput["S"] = 83
kbInput["T"] = 84
kbInput["U"] = 85
kbInput["V"] = 86
kbInput["W"] = 87
kbInput["X"] = 88
kbInput["Y"] = 89
kbInput["Z"] = 90
kbInput["["] = 91
kbInput["\\"] = 92
kbInput["]"] = 93
kbInput["^"] = 94
kbInput["_"] = 95
kbInput["`"] = 96

kbInput["a"] = 97
kbInput["b"] = 98
kbInput["c"] = 99
kbInput["d"] = 100
kbInput["e"] = 101
kbInput["f"] = 102
kbInput["g"] = 103
kbInput["h"] = 104
kbInput["i"] = 105
kbInput["j"] = 106
kbInput["k"] = 107
kbInput["l"] = 108
kbInput["m"] = 109
kbInput["n"] = 110
kbInput["o"] = 111
kbInput["p"] = 112
kbInput["q"] = 113
kbInput["r"] = 114
kbInput["s"] = 115
kbInput["t"] = 116
kbInput["u"] = 117
kbInput["v"] = 118
kbInput["w"] = 119
kbInput["x"] = 120
kbInput["y"] = 121
kbInput["z"] = 122

kbInput.a = 97
kbInput.b = 98
kbInput.c = 99
kbInput.d = 100
kbInput.e = 101
kbInput.f = 102
kbInput.g = 103
kbInput.h = 104
kbInput.i = 105
kbInput.j = 106
kbInput.k = 107
kbInput.l = 108
kbInput.m = 109
kbInput.n = 110
kbInput.o = 111
kbInput.p = 112
kbInput.q = 113
kbInput.r = 114
kbInput.s = 115
kbInput.t = 116
kbInput.u = 117
kbInput.v = 118
kbInput.w = 119
kbInput.x = 120
kbInput.y = 121
kbInput.z = 122

kbInput["{"] = 123
kbInput["|"] = 124
kbInput["}"] = 125
kbInput["~"] = 126

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
kbInput.interrogation = 63
kbInput.equal = 61
kbInput.escape = 27
kbInput.circumflex = 94
kbInput.dollarSign = 36
kbInput.pipe = 124
kbInput.ampersand = 38
kbInput.semicolon = 59

kbInput["&"] = kbInput.ampersand
kbInput["|"] = kbInput.pipe
kbInput["$"] = kbInput.dollarSign
kbInput["!"] = kbInput.exclamation
kbInput["^"] = kbInput.circumflex
kbInput["?"] = kbInput.interrogation
kbInput["_"] = 95 
kbInput[","] = 44 
kbInput["("] = 45 
kbInput["\\"] = 92 
kbInput["/"]  = 47 
kbInput["."] = 46 
kbInput[":"] = 58
kbInput[";"] = kbInput.semicolon 
kbInput["\""] = 34 
kbInput["("] = 40 
kbInput[")"] = 41 

kbInput.copy = 3
kbInput.paste = 22

function kbInput.isAnyPrintableSymbol(char)
	if 
		(
	        (char >= 32
	        and char <= 126)
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

kbInput[97] = "a"