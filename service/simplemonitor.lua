local skynet = require "skynet"

-- It's a simple service exit monitor, you can do something more when a service exit.

local service_map = {}

skynet.register_protocol {
	name = "client",
	id = 3,
	unpack = function() end,
	dispatch = function(_, address)
		local w = service_map[address]
		if w then
			for watcher in pairs(w) do
				skynet.send(watcher, "error", address)
			end
			service_map[address] = false
		end
		print(string.format("[:%x] exit", address))
	end
}

local function monitor(session, watcher, command, service)
	assert(command, "WATCH")
	local w = service_map[service]
	if not w then
		if w == false then
			skynet.ret(skynet.pack(false))
			return
		end
		w = {}
		service_map[service] = w
	end
	w[watcher] = true
	skynet.ret(skynet.pack(true))
end

skynet.start(function()
	skynet.dispatch("lua", monitor)
end)