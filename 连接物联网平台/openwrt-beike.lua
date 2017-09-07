local socket = require("socket")--引入Luasocket
local json = require("json")--引入Json4lua
local util = require "luci.util"--引入luci,调用cup负载
DEVICEID = "1081" --设备ID
APIKEY = "de39f7177" --设备APIKEY
INPUTID = "894" --数据接口ID
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
                os.execute("wget ".."http://localhost:8080/?action=snapshot".." -O /www/test.jpg")
                os.execute("curl --request POST -F ".."data=@/www/test.jpg".." --header ".."API-KEY:de39f7177".." http://www.bigiot.net/pubapi/uploadImg/did/1081/inputid/894")
            end
        end
    end
end