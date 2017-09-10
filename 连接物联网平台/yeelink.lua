--[[
--NodeMCU与yeelink物联网平台通信的代码
--作品说明：NodeMCU连接到yeelink，并可以接受其控制（主要是开关预警功能）。
--打开预警功能后，如果有人体进入热释电红外传感器的探测范围会自动向平台发送预警信息。
--关闭预警后则不会触发。
--为了方便解释和查看，整理时添加了很多注释和空行等，使用时建议删除
--]]

Alert = 0
Pir = 2
LED = 4
gpio.write(Alert, gpio.HIGH)
gpio.write(Pir, gpio.LOW) 
gpio.mode(Alert, gpio.OUTPUT)
gpio.mode(LED, gpio.OUTPUT)
cu = net.createConnection(net.TCP, 0)
cu:connect(80, "42.96.164.52")
cu:on("connection", function(sck, res) 
    cu:send("GET /v1.0/device/000000/sensor/000000/datapoints HTTP/1.1\r\n"
    .."Host:api.yeelink.net\r\n"
    .."Accept:*/*\r\n"
    .."U-ApiKey:00000000000000000000000000000000\r\n"
    .."\r\n") 
    end )
cu:on("receive", function(sck, res) 
	i, j=string.find(res, "value") 
	fhkg=string.sub(res,j+3,j+3)
	if kgbj==0 and fhkg=="1" then 
		print("1") 
		Start()
	elseif kgbj==1 and fhkg=="0" then 
		print("0")
		Stop()
    end
    tmr.delay(10000000) end )
cu:on("disconnection", function()

end )
function Start()
	gpio.write(LED, gpio.LOW)
	gpio.mode(Pir,gpio.INT)
    gpio.trig(Pir, "both", function(level)
        if level == gpio.HIGH then
            gpio.write(Alert, gpio.LOW)
		elseif level == gpio.LOW then 
			gpio.write(Alert, gpio.HIGH)
        end
    end)
end
function Stop()
	gpio.write (LED, gpio.HIGH)
	gpio.mode(Pir, gpio.OUTPUT)
end
