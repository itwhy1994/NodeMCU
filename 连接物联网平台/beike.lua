--[[
--NodeMCU连接贝壳物联程序，作者Why，整理时间2017.09.07
--作品说明：NodeMCU连接到贝壳，并可以接受其控制（主要是开关预警功能）。
--打开预警功能后，如果有人体进入热释电红外传感器的探测范围会自动向平台发送预警信息。
--关闭预警后则不会触发。
--为了方便解释和查看，整理时添加了很多注释和空行等，使用时建议删除
--]]

--设定与贝壳物联相关的信息，设备ID、APIKEY、INPUTID、贝壳服务器信息（ip、port）
DEVICEID = "000"
APIKEY = "000000000"
INPUTID = "000"
host = "121.42.180.30"
port = 8181

--设定相关设备对应IO口
Alert = 0--蜂鸣器和强光灯以及NodeMCU板载指示灯
Pir = 1--热释电红外传感器
LED = 4--NodeMCU板载Wifi指示灯,此处作为预警功能是否开启的指示灯

--设置相关IO口模式和初始电平
gpio.mode(Alert, gpio.OUTPUT)
gpio.write(Alert, gpio.HIGH)
gpio.mode(Pir, gpio.OUTPUT)
gpio.write(Pir, gpio.LOW)
gpio.mode(LED, gpio.OUTPUT)
gpio.write(LED, gpio.HIGH)

--创建一个TCP连接
cu = net.createConnection(net.TCP)

--按IP和端口连接到贝壳
cu:connect(port, host)

--构造认证消息并发送
ok, s = pcall(cjson.encode, {M="checkin",ID=DEVICEID,K=APIKEY})
cu:send(s.."\n")

--使用闹钟函数每30秒钟发送一次认证消息保持设备在线
tmr.alarm(1, 30000, 1, function()
	cu:send(s.."\n")
end)

--TCP连接接收到消息的回调函数及处理
cu:on("receive", function(cu, c)--参数为发送者连接和发送内容，课直接利用此连接回复消息
	r = cjson.decode(c)--解析收到的消息，消息结构和内容由贝壳统一构造
	if r.M == "say" then--判断消息类型
		--判断消息内容
		if r.C == "play" then--打开预警功能
            gpio.write(LED, gpio.LOW)--点亮预警指示灯
			ok, played = pcall(cjson.encode, {M="say",ID="U000",C="turn on"})--构造回复信息
			cu:send( played.."\n" )--发送回复信息
            gpio.mode(Pir,gpio.INT)--设置热释电红外传感器连接的IO口为中断模式
            gpio.trig(Pir, "both", function(level)--为中断设置回调函数
                if level == gpio.HIGH then--触发报警
                    gpio.write(Alert, gpio.LOW)--启动本地声光报警
					ok, warning = pcall (cjson.encode, { M = "say", ID = "D0000", C = "warning" })--构造预警信息
					cu:send (warning .. "\n")----发送预警信息
				elseif level == gpio.LOW then--没有报警信息
					gpio.write (Alert, gpio.HIGH)--关闭本地声光报警
				end
            end)        
        elseif r.C == "stop" then--关闭预警功能
			gpio.write (LED, gpio.HIGH)--熄灭预警指示灯
			gpio.write (Alert, gpio.HIGH)--关闭本地声光报警
			gpio.mode (Pir, gpio.OUTPUT)--设置热释电红外传感器连接的IO口为输出模式，即关闭其中断功能
			ok, stoped = pcall (cjson.encode, { M = "say", ID = "U000", C = "turn off" })--构造回复信息
			cu:send (stoped .. "\n")--发送回复信息
		end
    end
end)

--TCP连接被断开的回调函数及处理
cu:on('disconnection',function()
	--Do something here what you want to do
end)