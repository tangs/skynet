package.path = package.path .. ";lualib/?.lua;examples/?.lua;test/?.lua"

local skynet = require "skynet"
local socket = require "skynet.socket"
local service = require "skynet.service"
local websocket = require "http.websocket"
local json = require "json"

local handle = {}
local MODE = ...
-- local serviceLogin

if MODE == "agent" then
    function handle.connect(id)
        print("ws connect from: " .. tostring(id))
    end

    function handle.handshake(id, header, url)
        local addr = websocket.addrinfo(id)
        print("ws handshake from: " .. tostring(id), "url", url, "addr:", addr)
        print("----header-----")
        for k,v in pairs(header) do
            print(k,v)
        end
        print("--------------")
    end

    function handle.message(id, msg)
        print("received msg:" .. msg)
        if #data < 2 then 
            print("invalid msg:" .. msg)
            return 
        end
        local cmdLen = (msg:byte() << 8) & (msg:byte(1))
        local cmd = msg:sub(3, 3 + cmdLen)
        local data = json.decode(msg:sub(3 + cmdLen))
        print("cmd:" .. cmd)
        print("json data:" .. data)
        serviceLogin = skynet.newservice("test/login")
        if serviceLogin ~= nil then
            local resCmd, ret, err = skynet.call(serviceLogin, "lua", cmd, data)
            local res = {}
            res.cmd = resCmd
            if ret then
                res.ret_code = 0
                res.err_msg = ""
            else
                res.ret_code = 1
                res.err_msg = err or ""
            end
            websocket.write(id, json.encode(res))
        end
        -- websocket.write(id, "ret:" .. msg)
    end

    function handle.ping(id)
        print("ws ping from: " .. tostring(id) .. "\n")
    end

    function handle.pong(id)
        print("ws pong from: " .. tostring(id))
    end

    function handle.close(id, code, reason)
        print("ws close from: " .. tostring(id), code, reason)
    end

    function handle.error(id)
        print("ws error from: " .. tostring(id))
    end

    skynet.start(function ()
        skynet.dispatch("lua", function (_,_, id, protocol, addr)
            local ok, err = websocket.accept(id, handle, protocol, addr)
            if not ok then
                print(err)
            end
        end)
    end)

else
    local function simple_echo_client_service(protocol)
        local skynet = require "skynet"
        local websocket = require "http.websocket"
        local url = string.format("%s://127.0.0.1:9948/test_websocket", protocol)
        local ws_id = websocket.connect(url)
        while true do
            local msg = "hello world!"
            websocket.write(ws_id, msg)
            print(">: " .. msg)
            local resp, close_reason = websocket.read(ws_id)
            print("<: " .. (resp and resp or "[Close] " .. close_reason))
            if not resp then
                print("echo server close.")
                break
            end
            websocket.ping(ws_id)
            skynet.sleep(100)
        end
    end

    skynet.start(function ()
        local agent = {}
        for i= 1, 20 do
            agent[i] = skynet.newservice(SERVICE_NAME, "agent")
        end
        local balance = 1
        local protocol = "ws"
        local id = socket.listen("0.0.0.0", 9948)
        skynet.error(string.format("Listen websocket port 9948 protocol:%s", protocol))
        socket.start(id, function(id, addr)
            print(string.format("accept client socket_id: %s addr:%s", id, addr))
            skynet.send(agent[balance], "lua", id, protocol, addr)
            balance = balance + 1
            if balance > #agent then
                balance = 1
            end
        end)
        -- test echo client
        -- service.new("websocket_echo_client", simple_echo_client_service, protocol)
        -- serviceLogin = skynet.newservice("test/login")
    end)
end