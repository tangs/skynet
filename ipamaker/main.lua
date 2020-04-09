local skynet = require "skynet"

skynet.start(function()
	skynet.error("Server start")
	if not skynet.getenv "daemon" then
		local console = skynet.newservice("console")
	end
	-- local mysql = skynet.uniqueservice("mysql")
	local apple_accs = skynet.uniqueservice("apple_accs")
	print(skynet.call(apple_accs, "lua", "app1", {
		udid = "12345678910"
	}))
	print(skynet.call(apple_accs, "lua", "app1", {
		udid = "123456789101"
	}))
	skynet.newservice("debug_console", 8000)
	skynet.newservice("simpleweb")
end)
