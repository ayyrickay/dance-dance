-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
require "pubnub"
require "PubnubUtil"
require "Json"

local dancepubnub

local grouppubnub = pubnub.new({
	    publish_key   = "pub-c-8dcab5dd-7e8e-4db3-bf4f-52a77a5bfeae",             -- YOUR PUBLISH KEY
	    subscribe_key = "sub-c-c42b881a-9ae6-11e5-9a49-02ee2ddab7fe",             -- YOUR SUBSCRIBE KEY
	    secret_key    = nil,                -- YOUR SECRET KEY
	    ssl           = nil,                -- ENABLE SSL?
	    --origin        = "pubsub.pubnub.com" -- PUBNUB CLOUD ORIGIN
	})

local testpubnub = pubnub.new({
	    publish_key   = "pub-c-0e06bb2f-0f4a-4983-af67-b299b6cc9676",             -- YOUR PUBLISH KEY
	    subscribe_key = "sub-c-5d740548-9b9a-11e5-9a49-02ee2ddab7fe",             -- YOUR SUBSCRIBE KEY
	    secret_key    = nil,                -- YOUR SECRET KEY
	    ssl           = nil,                -- ENABLE SSL?
	    --origin        = "pubsub.pubnub.com" -- PUBNUB CLOUD ORIGIN
	})


dancepubnub = testpubnub
chan = "Test"
local channel = "Channel1"
local status = display.newText( "Connecting...", 100, 15, native.systemFont, 12 )
status.anchorX = 0
local rec_count = display.newText( "0", 100, 31, native.systemFont, 12 )
rec_count.anchorX = 0
gain = 1/15
print(0.342*gain)
local acc_count = 0   -- Number of accelerometers
receivedcount = 0
message_array = {}
acc_size_array = {}
t_now = system.getTimer()
t_last = t_now

function subscribe(channel)
	print("\n\nTrying to connect")
	dancepubnub:subscribe({
		channel  = channel,
		connect = function()
			print("Connected to channel")
			status.text = "Connected"
			print(channel)
			-- Test the parser using the output format of the sweater
			--publish(channel,"{ \"acc-xyz\":[0.0323,0.3134,0.1232]}")
		end,
		callback = function(message)
			receivedcount = receivedcount + 1
			rec_count.text = string.format(receivedcount)
			--mess = string.sub(mess,index,0)
			
			mess=Json.Encode(message)
			index = string.find(mess,':',1)
			index2 = string.find(mess,'}',10)
			if Index~=nil and index2~=nil then
				mess=string.sub(mess,index+2,index2-2)
			end
			print(mess)
			t={}
			count = 1
			cd = {"x1", "y1", "z1", 
				  "x2", "y2", "z2",
				  "x3", "y3", "z3"}
			
			acc = {}
			mess2 = string.format(mess)
			for k, v in string.gmatch(mess2, "(%w+).(%w+)") do
				value = tonumber(string.format("%s.%s",k,v))
				acc[count] = value
				--print (cd[count], ": " .. value )
				count = count + 1
 			end
 			acc_size = table.getn(acc)/3
 			if acc_size == 0 then
 				print("Bad message! ")
 			else
	 			if acc_count ~= acc_size then
	 				acc_count = acc_size
	 				setup_labels(acc_size)
	 			end
				if not smooth then
					s = apply_acceleration(acc,acc_size,100)
				else 
					t_now = system.getTimer()
					len=table.getn(message_array)+1
					message_array[len] =  acc
					acc_size_array[len] =  acc_size
					dt = t_now-t_last
					if dt > 500 then
						if dt > 1100 then dt = 1000 end
						c = table.getn(message_array)
						timestep = dt/c
						print("Releasing ".. c .. " messages with dt="..dt .. ", ts = "..timestep)
						temp_ma = message_array
						temp_accs = acc_size_array
						message_array = {}
						acc_size_array = {}
						for i = 1,c,1 do
							apply_acceleration(temp_ma[i],temp_accs[i],timestep)	
						end

					end
				end

 			end
			t_last = t_now
		end,
		error = function()
			print("Connection error")
		end,
		errorback = function()
		  print("Oh no!!! Dropped internet connection!")
		end
	})
end

function unsubscribe(channel)
	dancepubnub:unsubscribe({
		channel = channel,
		})
end

function publish(channel, message)
	print("Trying to publish ",message)
    dancepubnub:publish({
        channel = channel,
		message = message,
        callback = function(r) 
			print( "Callback")
			if r[1] then
				print("Message delivered: " .. Json.Encode(message))
				--print(Json.Encode(message))
			else
				print("Message failed:")
				print(r[2])
			end
        end,
        error = function(r)
			print("Publishing error: ")
			print(r)
        end
    })
end

local gradient = {
    type="gradient",
    color1={ 0.7, 0.2, 0 }, 
    color2={ 0.2, 0.7, 0.0 }, 
    direction="down"
}

display.setDefault( "anchorX", 0 )
display.setDefault( "background", 0, 0.2, 0.3)

local havedot = true
local goffset = 150+50
phoneacc_allowed = false  -- Disallow the phone's built-in accelerometer
smooth = false -- Allow temporal smoothing of the Pubnub data
smoothlist = {}

local statusLabel = display.newText( "Status:", 10, 15, native.systemFontBold, 12 )
local receivedcountLabel = display.newText( "Messages:", 10, 31, native.systemFontBold, 12 )

local Magnitudebanner = display.newText( "MAGNITUDE", 10, 120, native.systemFontBold, 30)
local Caloriesbanner = display.newText( "CALORIES", 10, 400, native.systemFontBold, 30)
Magnitudebanner:setFillColor(0.2,0.5,0.4)
Caloriesbanner:setFillColor(0.2,0.5,0.4)

local Calorieslabel = display.newText( "Calories:", 10, goffset+15, native.systemFontBold, 20 )

local l = 175
local accMagnitudeLabel = {}
local accMagnitude = {}
accMagnitudeLabel[1] = display.newText( "Magnitude[1]:", 10+l, 15, native.systemFontBold, 12)
accMagnitude[1] = display.newText( "", 100+l, 15, native.systemFont, 12 )
accMagnitude.anchorX = 0

local Calories = display.newText( "", 100, goffset+15, native.systemFont, 20 )

local lockLabel = display.newText( "Locked:", 10, 47, native.systemFontBold, 12 )
local chanLabel = display.newText( "Channel:", 10, 63, native.systemFontBold, 12 )

local locktext = display.newText( "True", 100, 47, native.systemFont, 12 )
local chantext = display.newText( chan, 100, 63, native.systemFont, 12 )

local tlast = system.getTimer()
local tnow = tlast

local xzoom = 0.05
local yzoom = 30
local threshold = 0.3
display.newLine(0,goffset,330,goffset)
local lastmagnitude = 0
local screenx = display.pixelWidth
screenx = 330
--print(screenx)
local horoffset = 0
lineGroup = display.newGroup()

local cal_count = 0
local lastcal_count = 0
local gathering = false

-- Add the magnitude labels for each accelerometer
function setup_labels(count)
	print("Count:" .. count)
	for i = 1,count,1 do
		text = string.format("Magnitude[%i]:",i)
		accMagnitudeLabel[i] = display.newText( text, 10+l, 15+i*16-16, native.systemFontBold, 12)
		accMagnitude[i] = display.newText( "", 100+l, 15+i*16-16, native.systemFont, 12 )
		accMagnitude.anchorX = 0
	end
end

-- Handle touch actions
-- Horizontal swipes: toggle on-board accelerometer
-- Vertical swipes: toggle group or test pubnubs
local function handleSwipe (event)
	if (event.phase == "moved") then
		local dX = event.x - event.xStart
		local dY = event.y - event.yStart
		--print (event.x, event.xStart, dX)
		if (dX > 30) then
			if phoneacc_allowed == false then print("Phone input allowed") end
			phoneacc_allowed = true
			locktext.text = "False"
		elseif (dX < -30) then
			if phoneacc_allowed == true then print("Phone input prohibited") end
			phoneacc_allowed = false
			locktext.text = "True"
		end
		if (dY > 30) then
			if chan == "Group" then 
				print("Switch to test")
				unsubscribe(channel)
				chan = "Test"
				chantext.text = chan
				dancepubnub = testpubnub
				channel = "Channel1"
				subscribe(channel)
				status.text = "Switching..."
			end
		elseif (dY < -30) then
			if chan == "Test" then 
				print("Switch to group") 
				unsubscribe(channel)
				chan = "Group"
				dancepubnub = grouppubnub
				chantext.text = chan
				
				channel = "p2-demo"
				subscribe(channel)
				status.text = "Switching..."
			end
		end
	end
end

function apply_acceleration( acc, len, ts )
	tnow = tlast + ts
	magnitude = {}
	dt = ts/1000
    print(len)
    for i = 1,len,1 do
    	j = i -1
    	magnitude[i] = math.sqrt(acc[1+j*3]^2 + acc[2+j*3]^2 + acc[3+j*3]^2)
    	accMagnitude[i].text = string.format("%.4f",magnitude[i])
    end
    --print(len)
    for i = len+1,acc_count,1 do
    	accMagnitude[i].text = ""
    	accMagnitudeLabel[i].text = ""
    end
    avg_mag = 0
    for i = 1,len,1 do
    	avg_mag = avg_mag + magnitude[i]/len
    end
    --print("Avg mag: " .. avg_mag)
	if avg_mag > threshold then
		cal_count = cal_count + 0.4*dt --0.4*magnitude*event.deltaTime
	end
	Calories.text = string.format("%.1f",cal_count)
    
	drawgraph(0, avg_mag, lastmagnitude,0)
	drawgraph(4, cal_count, lastcal_count,9.5)

    lastmagnitude = avg_mag
    lastcal_count = cal_count
    tlast = tnow

    return nil
end

local function onTilt( event )
    if phoneacc_allowed then
    	acc = {	event.xRaw-event.xGravity, 
    			event.yRaw-event.yGravity,
    			event.zRaw-event.zGravity}
    	apply_acceleration(acc, table.getn(acc)/3,event.deltaTime*1000)
    end
    if dot ~= nil then movedot(event) end
    return true
end

function movedot(event)
	if havedot then
		dot.x = dot.x + 5*event.xGravity
		dot.y = dot.y - 5*event.yGravity

		if dot.x > display.contentWidth then
			dot.x = display.contentWidth
		end
		if dot.x < 0 then
			dot.x = 0
		end
		if dot.y > display.contentHeight then
			dot.y = display.contentHeight
		end
		if dot.y < 0 then 
			dot.y = 0
		end

		if event.isShake then
			if dot.color == "blue" then
				dot:setFillColor( 1, 0, 0 )
				dot.color = "red"
			else
				dot:setFillColor( 0, 0, 1 )
				dot.color = "blue"
			end
		end
	end
end

function drawgraph( id, mag, lastmag,scale)
    if xzoom*tnow > screenx then
        horoffset = horoffset + screenx/xzoom
        tnow = tnow - screenx/xzoom
        tlast = tlast - screenx/xzoom
        
        lineGroup:removeSelf()
        lineGroup = display.newGroup()
    end
	if (scale > 0 and mag > scale) then
		-- todo: scale down the graph
	end
    local linesegment = display.newLine(xzoom*tlast, -30+goffset-yzoom*lastmag + id*85 ,xzoom*tnow,-30+goffset + id*85 -yzoom*mag)
    linesegment:setStrokeColor(0,1,0)
    lineGroup:insert(linesegment)
end

function bogusdata()
	print("bodus")
	acc = {}
	for j = 1,9,1 do
		acc[j] = math.random()
	end
	apply_acceleration( acc, 3, 100 )
end
Runtime:addEventListener( "touch", handleSwipe )
--"Channel-tw6aghkw4"
--ch = "p2-demo"
subscribe(channel) 
Runtime:addEventListener( "accelerometer", onTilt )