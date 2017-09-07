sg=0 jxkg = 1 hw = 2 LED = 4 kgbj=0
gpio.write(sg, gpio.HIGH) gpio.write(jxkg, gpio.LOW) gpio.write(hw, gpio.LOW) 
gpio.mode(sg, gpio.OUTPUT) gpio.mode(LED, gpio.OUTPUT) gpio.mode(jxkg, gpio.INT)
cu = net.createConnection(net.TCP, 0)
cu:connect(80, "42.96.164.52")
cu:on("connection", function(sck, res) 
    cu:send("GET /v1.0/device/352321/sensor/396595/datapoints HTTP/1.1\r\n"
    .."Host:api.yeelink.net\r\n"
    .."Accept:*/*\r\n"
    .."U-ApiKey:d04763cc04a9065298cbb6f26ccf410f\r\n"
    .."\r\n") 
    end )
cu:on("receive", function(sck, res) i, j=string.find(res, "value") fhkg=string.sub(res,j+3,j+3)
    if kgbj==0 and fhkg=="1" then print("1") kgbj=1 qd()
    elseif kgbj==1 and fhkg=="0" then print("0") kgbj=0 gb()
    else end
    tmr.delay(10000000) end )
cu:on("disconnection", function() dofile("kg.lua") end )
--[[
gpio.trig(jxkg, "both", function(level)
    if level == gpio.HIGH then qd()
    elseif level == gpio.LOW then gb()
    else end
end)
--]]
function qd()
    gpio.write(LED, gpio.LOW) gpio.mode(hw,gpio.INT)
    gpio.trig(hw, "both", function(level)
        if level == gpio.HIGH then
            gpio.write(sg, gpio.LOW)
            
        elseif level == gpio.LOW then gpio.write(sg, gpio.HIGH)
        else end
    end)
end
function gb()
    gpio.write(LED, gpio.HIGH) gpio.mode(hw, gpio.OUTPUT)
end
