--[[
--OpenWRT与贝壳物联通信程序（Lua）
--Data:2017.09.10
--By:CUITWhy
--]]
local socket = require("socket")--引入Luasocket
local json = require("json")--引入Json4lua
local util = require "luci.util"--引入luci,调用cup负载
DEVICEID = "0000" --设备ID
APIKEY = "00000000" --设备APIKEY
INPUTID = "000" --数据接口ID
host = host or "121.42.180.30"
port = port or 8181
lastTime = 0
if arg then
    host = arg[1] or host
    port = arg[2] or port
end
print("Attempting connection to host '" ..host.. "' and port " ..port.. "...")
c = socket.connect(host, port)
c:settimeout(0)
s = json.encode({M='checkin',ID=DEVICEID,K=APIKEY})
while true do
    if ((os.time() - lastTime) > 30) then
        print( os.time() )
        c:send( s.."\n" )
        lastTime=os.time()
    end
    recvt, sendt, status = socket.select({c}, nil, 1)
    --#获取table长度，即元素数
    if #recvt > 0 then
        local response, receive_status = c:receive()
        if receive_status ~= "closed" and response then
            print(response)
            r = json.decode(response)
            if r.C=="warning" then
				os.execute ("wget " .. "http://localhost:8080/?action=snapshot" .. " -O /www/test.jpg")--使用wget命令获取本地挂载摄像头当前图像并保存到/www/test.jpg
				--使用curl上传到贝壳物联，注意修改相关参数
				os.execute ("curl --request POST -F " .. "data=@/www/test.jpg" .. " --header " ..
				"API-KEY:000000000" .. " http://www.bigiot.net/pubapi/uploadImg/did/0000/inputid/000")
			end
        end
    end
end