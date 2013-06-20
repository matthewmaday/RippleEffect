-- ripple panel

LoadRipple = {}
local widget = require( "widget" )

function LoadRipple:new(params)

	local screen = display.newGroup()

	------------------------------------------------------------------------------------------
	-- Primary Views
	------------------------------------------------------------------------------------------

	-- initialize()
	-- show()
	-- hide()

	function screen:initialize(params)

	screen.state = 1   -- 0 = idle, 1 = active, 2 = paused

	-- params
		-- (int) speed 				the speed in which all intersection points move. normally 1-10
		-- (int) resolution  		the number of total cells within the matrix. normal range 5-20
		-- (int) magnitude 			the amount of distortion normal range 3-10
		-- (str) source 			the path to the source image
		-- (int) xCellCnt	  		the number of horizontal divisions in the effect. normal range 5-20
		-- (int) yCellCnt			the number of vertical divisions in the effect. normal range 5-20
		-- (int) sheetContentWidth	the width of the source image
		-- (int) sheetContentHeight	the height of the source image

		local width,height = params.sheetContentWidth/params.xCellCnt, params.sheetContentHeight/params.yCellCnt
		local options = {
			width     = width,                                -- width of one frame
			height    = height,                               -- height of one frame
			numFrames = params.xCellCnt*params.yCellCnt,      -- total number of frames in spritesheet
		    sheetContentWidth = params.sheetContentWidth,     -- width of original 1x size of entire sheet
    		sheetContentHeight = params.sheetContentHeight    -- height of original 1x size of entire sheet
		}

		-- initialize the image sheet
		self.image = graphics.newImageSheet(params.source, options)

		-- create matrix array
		self.matrix  = {}
		local cnt    = 1
		
		for y = 1,params.xCellCnt, 1 do
			local column = {}
			for x=1,params.yCellCnt, 1 do

				local img =  display.newImageRect(self.image, cnt, width, height)

				column[#column+1] = {image=nil,properties=nil}
				column[#column].image      = img
				column[#column].properties = {
					tl = {x=0,y=0}, 
					tr = {x=width,y=0},
					br = {x=width,y=height},
					bl = {x=0,y=height},
					angle = math.random(360),
					magnitude = params.magnitude,
					speed = params.speed
				}

				img.x, img.y = (x-1)*width, (y-1)*height
				cnt = cnt+1
				self:insert(img)
			end
			self.matrix[#self.matrix+1] = column
		end

		self.alpha = 1

		screen:addEventListener("touch", function()
			screen:pause()
		end
		)
		Runtime:addEventListener("enterFrame", function() 
			screen:process() 
		end
			)
	end
	--------
	function screen:show(time)
		transition.to(self, {time = time, alpha = 1, onComplete = function()
			screen.state = 0
		end
		})
	end
	--------
	function screen:hide()


	end	
	--------
	function screen:process()
		
		if self.state == 0 then

		local xEnd, yEnd, rads = #self.matrix, #self.matrix[1], 0
			
			-- update transformations
			for y = 1,xEnd, 1 do
				for x=1,yEnd, 1 do
					local ang = self.matrix[y][x].properties.angle + self.matrix[y][x].properties.speed
					
					if ang > 360 then
						ang = ang-360
					elseif ang < 0 then 
						ang = ang + 360
					end

					self.matrix[y][x].properties.angle = ang
				end
			end

			-- render transformations
			for y = 1,xEnd, 1 do
				for x=1,yEnd, 1 do

					local props = nil

					local xPos, yPos = x+1, y+1

					if xPos > xEnd then xPos = x end
					if yPos > yEnd then yPos = y end

					-- upper left
					props = self.matrix[y][x].properties
					rads = props.angle * (math.pi / 180.0)
					self.matrix[y][x].image.x1 = props.magnitude/2 * math.cos(rads) 
					self.matrix[y][x].image.y1 = props.magnitude/2 * math.sin(rads)

					-- lower left
					props = self.matrix[yPos][x].properties
					rads = props.angle * (math.pi / 180.0)
					self.matrix[y][x].image.x2 = self.matrix[y][x].properties.magnitude/2 * math.cos(rads)
					self.matrix[y][x].image.y2 = self.matrix[y][x].properties.magnitude/2 * math.sin(rads)

					-- lower right
					props = self.matrix[yPos][xPos].properties
					rads = props.angle * (math.pi / 180.0)
					self.matrix[y][x].image.x3 = self.matrix[y][x].properties.magnitude/2 * math.cos(rads)
					self.matrix[y][x].image.y3 = self.matrix[y][x].properties.magnitude/2 * math.sin(rads)

					-- lower right
					props = self.matrix[y][xPos].properties
					rads = props.angle * (math.pi / 180.0)
					self.matrix[y][x].image.x4 = self.matrix[y][x].properties.magnitude/2 * math.cos(rads)
					self.matrix[y][x].image.y4 = self.matrix[y][x].properties.magnitude/2 * math.sin(rads)

				end
			end

		end 
	end
	--------
	function screen:pause()

		if self.state == 0 then
			self.state = 2
		elseif self.state == 2 then
			self.state = 0
		end 
	end	
	--------
	function screen:destory()


	end	
	
	screen:initialize(params)
	return screen

end

return LoadRipple


-- -- ripple effect script


-- property pList, pBuffer, pRotations, pCalculations

-- on beginSprite me
  
--   pMember       = "source"
--   pResolution   = 10
--   w             = member(pMember).width
--   h             = member(pMember).height
--   pList         = []
--   pBuffer       = image(member(pMember).width, member(pMember).height, the colorDepth)
--   pRotations    = []
--   pCalculations = []
--   pBuffer.copyPixels(member(pMember).image, member(pMember).rect, member(pMember).rect)
  
--   x = w / pResolution + ((w MOD float(pResolution)) > 0 )
--   y = h / pResolution + ((h MOD float(pResolution)) > 0 )
  
--   repeat with ypos = 1 to y+1
    
--     subList  = []
--     subangle = []
--     subCal   = []
    
--     repeat with xpos =  1 to x+1
--       append subList, point(pResolution * (xpos-1),pResolution * (ypos-1))
--       append subAngle, random(360)
--       append subcal, point(0,0)
--     end repeat 
    
--     append pList, duplicate(subList)
--     append pRotations, duplicate(subangle)
--     append pCalculations, duplicate(subcal)
    
--   end repeat
  
-- end
-- --------
-- on exitFrame me

--   pMember    = "source"
--   pIntensity = 5
--   pSpeed     = 10
  
--   if NOT listP(pList) or pList.count = 0 then exit
  
--   x   = pList[1].count
--   y   = pList.count
--   inc = 360 / pSpeed
  
--   -- new calculations
--   repeat with ypos = 1 to y
--     repeat with xpos =  1 to x
--       pRotations[yPos][xPos] = pRotations[yPos][xPos] + inc
--       if pRotations[yPos][xPos] > 360 then pRotations[yPos][xPos] = pRotations[yPos][xPos]-360
      
--       radians = ((2*pi())*pRotations[yPos][xPos])/360.0
--       pCalculations[yPos][xpos] = point( pIntensity * sin(radians), pIntensity * cos(radians) )
--     end repeat 
--   end repeat
  
--   x = x - 1
--   y = y - 1
  
--   -- draw
--   repeat with ypos = 1 to y
--     repeat with xpos =  1 to x
      
      
--       l = pCalculations[ypos][xpos]     + pList[ypos][xpos]
--       t = pCalculations[ypos][xpos+1]   + pList[ypos][xpos+1]
--       r = pCalculations[ypos+1][xpos+1] + pList[ypos+1][xpos+1]
--       b = pCalculations[ypos+1][xpos]   + pList[ypos+1][xpos]
      
--       q = [ l, t, r, b ]
      
--       r = rect(pList[ypos][xpos][1], pList[ypos][xpos][2], pList[ypos+1][xpos+1][1], pList[ypos+1][xpos+1][2])
--       pBuffer.copyPixels(member(pMember).image, q, r)
--     end repeat 
--   end repeat
  
--   member("display").image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
  
  
-- end