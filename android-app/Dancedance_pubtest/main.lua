-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
require "pubnub"
require "PubnubUtil"
require "Json"

dance = pubnub.new({
    publish_key   = "pub-c-8dcab5dd-7e8e-4db3-bf4f-52a77a5bfeae",             -- YOUR PUBLISH KEY
    subscribe_key = "sub-c-c42b881a-9ae6-11e5-9a49-02ee2ddab7fe",             -- YOUR SUBSCRIBE KEY
    secret_key    = nil,                -- YOUR SECRET KEY
    ssl           = nil,                -- ENABLE SSL?
    --origin        = "pubsub.pubnub.com" -- PUBNUB CLOUD ORIGIN
})
dancepubnub = pubnub.new({
    publish_key   = "pub-c-0e06bb2f-0f4a-4983-af67-b299b6cc9676",             -- YOUR PUBLISH KEY
    subscribe_key = "sub-c-5d740548-9b9a-11e5-9a49-02ee2ddab7fe",             -- YOUR SUBSCRIBE KEY
    secret_key    = nil,                -- YOUR SECRET KEY
    ssl           = nil,                -- ENABLE SSL?
    --origin        = "pubsub.pubnub.com" -- PUBNUB CLOUD ORIGIN
})
local status = display.newText( "Connecting...", 100, 15, native.systemFont, 12 )
status.anchorX = 0
local rec_count = display.newText( "0", 100, 31, native.systemFont, 12 )
rec_count.anchorX = 0
channel = "Channel1"
local acc_count = 0   -- Number of accelerometers
sentcount = 0
function subscribe(channel)
	print("\n\nTrying to connect")
	dancepubnub:subscribe({
		channel  = channel,
		connect = function()
			print("Connected to channel")
			status.text = "Connected"
			print(channel)
		end,
		callback = function(message)
			print("Message received: ", Json.Encode(message))
			--for k in testmess do print(k) end
			mess=Json.Encode(message)
			t={}
			count = 1
			cd = {"x1", "y1", "z1", 
				  "x2", "y2", "z2",
				  "x3", "y3", "z3"}
			
			acc = {}
			--for word in string.gmatch(mess ,"%w+") do
			mess2 = string.format(mess)
			for k, v in string.gmatch(mess2, "(%w+).(%w+)") do
				--print(word)
				--print("Number: " .. k+v*0.001)
				value = tonumber(string.format("%s.%s",k,v))
				acc[count] = value
				--print (cd[count], ": " .. value )
				count = count + 1
				
   				--t[k] = word
 			end
 			acc_size = table.getn(acc)/3
 			if acc_size == 0 then
 				print("Bad message! ")
 			else
	 			if acc_count ~= acc_size then
	 				print ("acc_count = ".. acc_count .. "acc size: "..acc_size)
	 				acc_count = acc_size
	 				setup_labels(acc_size)
	 			end
				print("size: ",acc_size, " message: ",mess)
				s = apply_acceleration(acc,acc_size)
 			end
		end,
		error = function()
			print("Connection error")
		end,
		errorback = function()
		  print("Oh no!!! Dropped internet connection!")
		end
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

display.setDefault( "anchorX", 0 )
display.setDefault( "background", 0, 0.2, 0.3)

local havedot = true
local goffset = 150+50

local statusLabel = display.newText( "Status:", 10, 15, native.systemFontBold, 12 )
local receivedcountLabel = display.newText( "Messages:", 10, 31, native.systemFontBold, 12 )
--local zGravityLabel = display.newText( "zGravity:", 10, 47, native.systemFontBold, 12 )


local Magnitudebanner = display.newText( "MAGNITUDE", 10, 120, native.systemFontBold, 30)
local Caloriesbanner = display.newText( "CALORIES", 10, 400, native.systemFontBold, 30)
Magnitudebanner:setFillColor(0.2,0.5,0.4)
Caloriesbanner:setFillColor(0.2,0.5,0.4)

local Calorieslabel = display.newText( "Calories:", 10, goffset+15, native.systemFontBold, 20 )

local accMagnitudeLabel = display.newText( "Magnitude[1]:", 10, 47, native.systemFontBold, 12)
local accMagnitude = display.newText( "", 100, 47, native.systemFont, 12 )
accMagnitude.anchorX = 0

local Calories = display.newText( "", 100, goffset+15, native.systemFont, 20 )

local xInstantLabel = display.newText( "xAcc:", 200, 15, native.systemFontBold, 12 )
local yInstantLabel = display.newText( "yAcc:", 200, 31, native.systemFontBold, 12 )
local zInstantLabel = display.newText( "zAcc:", 200, 47, native.systemFontBold, 12 )

local xInstant = display.newText( "", 270, 15, native.systemFont, 12 )
local yInstant = display.newText( "", 270, 31, native.systemFont, 12 )
local zInstant = display.newText( "", 270, 47, native.systemFont, 12 )

local tlast = system.getTimer()
local tnow = tlast

local xzoom = 0.05
local yzoom = 30
local threshold = 0.3
display.newLine(0,goffset,330,goffset)
local lastmagnitude = 0
local screenx = display.pixelWidth
screenx = 330
local horoffset = 0
lineGroup = display.newGroup()
local cal_count = 0
local lastcal_count = 0

local accMagnitudeLabel
local accMagnitude = {}
function setup_labels(count)
	print("Count:" .. count)
	for i = 1,count,1 do
		text = string.format("Magnitude[%i]:",i)
		accMagnitudeLabel = display.newText( text, 10, 31+i*16, native.systemFontBold, 12)
		accMagnitude[i] = display.newText( "", 100, 31+i*16, native.systemFont, 12 )
		accMagnitude.anchorX = 0
	end
end

local n = 500

function bogusdata()
	told = system.getTimer()
	acc = {}
	sentcount = sentcount + 1
	rec_count.text = string.format(sentcount)
	for j = 1,9,1 do
		acc[j] = math.random()
	end
	publish(channel,acc)
	if sentcount >= n then status.text = "Finished" end
end

status.text = "Publishing..."
timer.performWithDelay(100,bogusdata, n)