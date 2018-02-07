function foo1()
	return "Hello"
end

function foo2()

end

function test()
dofile([[K:\Programs\Reaperportable\Scripts\Claudiohbsantos-Scripts\Lua\Tools\testprint.lua]])

end



rl.registeredCommands.test = {main = test,waitForEnter = true,description = "tester"}	