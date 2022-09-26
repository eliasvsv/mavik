-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"

--------------------------------------------

-- forward declarations and other locals
local lives = 10
local score = 0
local livesText
local scoreText
local screenW, screenH, halfW ,speed= display.actualContentWidth, display.actualContentHeight, display.contentCenterX,3
local nayik = display.newImageRect( "assets/nayib.png", 90, 60 )
local bg1 = display.newImageRect( "assets/background.png",screenW, screenH )
local bullet = display.newImageRect("assets/shoot.png",100,10)
local bombs = display.newImageRect( "assets/gorgojo.png" ,30,30)
local bombs2 = display.newImageRect( "assets/gorgojo.png",30,30 )
local bombs3 = display.newImageRect( "assets/gorgojo.png" ,30,30)
local bg2 = display.newImageRect( "assets/background.png",screenW, screenH )
local soundFile = audio.loadSound("assets/sounds/stage-1-the-jungle-.wav")
local uiGroup = display.newGroup()    -- Display group for UI objects like the score

speed= 4--math.random(2,6)
	bg1.x =screenW*0.5
	bg1.y =0
	bg1.anchorX = 0
	bg1.anchorY = 0


	bg2.x =screenW*0.5
	bg2.y = bg1.y+320
	bg2.anchorX = 0+screenW
	bg2.anchorY = 0+halfW


-- explostion
local explosionOptions=
{
	width = 192,
	height = 192,
	numFrames = 10
}	
local explosion_sheet =  graphics.newImageSheet( "assets/explosion.png", explosionOptions )
local explosion_bombs = {

	{
		name = "explosion",
		frames = { 1,2,3,4,5 },
		time = 100,
		loopCount=1
	},
}
local explosion=  display.newSprite( explosion_sheet, explosion_bombs )
function updateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
end	 
function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()



	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	
	
	-- make a nayik (off-screen), position it, and rotate slightly

	nayik.x, nayik.y = 160, 30
	nayik.rotation = 0
	
	-- add physics to the nayik
	physics.addBody( nayik,"static", { density=1.0, friction=0.3, bounce=0.2, radius=45 } )
	

	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)

	-- bombas 
	physics.addBody( bombs,"dynamic", { density=.1, friction=0.9, bounce=0.1, radius=15 } )
	bombs.x=-580
	bombs.y=150
	bombs.speed= speed
	bombs.initY=bombs.y
	bombs.amp = math.random(20,100)
	bombs.angle = math.random(60,360)
	-- bomba 2
	physics.addBody( bombs2,"dynamic", { density=.1, friction=0.9, bounce=0.2,radius=15  } )
	bombs2.x=-580
	bombs2.y=150
	bombs2.speed= speed+1
	bombs2.initY=bombs2.y
	bombs2.amp = math.random(20,100)
	bombs2.angle = math.random(60,360)

	-- bomba 3
	physics.addBody( bombs3,"dynamic", { density=.1, friction=0.9, bounce=0.1,radius=15  } )
	bombs3.x=-530
	bombs3.y=150
	bombs3.speed= speed+2
	bombs3.initY=bombs3.y
	bombs3.amp = math.random(20,100)
	bombs3.angle = math.random(60,360)
	----------------------

	explosion.x=0
	explosion.y=0
	explosion:setSequence("explosion")
	explosion.isVisible=false
	explosion:scale(0.5,0.5)

	-- music
audio.play(soundFile,{
	channel=2,
	loops=-1,
	fadein=500
})
livesText = display.newText(  "Vidas: " .. lives, 150, 40, native.systemFont, 12 )
scoreText = display.newText(  "Puntos: " .. score, 350, 40, native.systemFont, 12 )

	-- all display objects must be inserted into group
	
	sceneGroup:insert( bg1 )
	sceneGroup:insert( bg2 )
--	sceneGroup:insert( grass)
	sceneGroup:insert( nayik )
	sceneGroup:insert( bombs )
	sceneGroup:insert( bombs2 )
	sceneGroup:insert( bombs3)
	sceneGroup:insert( explosion )
	sceneGroup:insert( livesText )
	sceneGroup:insert( scoreText )
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
end


local function dragShip( event )
 
	local ship = event.target
    local phase = event.phase
	if ( "began" == phase ) then
        -- Set touch focus on the ship
        display.currentStage:setFocus( ship )
		ship.touchOffsetX = event.x - ship.x 
		ship.touchOffsetY = event.y - ship.y
	elseif ("moved"==phase) then
		ship.x = event.x - ship.touchOffsetX
		ship.y = event.y - ship.touchOffsetY
	elseif ("ended" == phase or "cancelled" == phase ) then
		display.currentStage:setFocus(nil)		
    end
 
end
local function fireLaser()
 

	physics.addBody(bullet, "static", {density = 1, friction = 0, bounce = 0});
	bullet.x = nayik.x +100
	bullet.y = nayik.y + 15
	bullet.myName = "bullet"

	transition.to ( bullet, { time = 500, x = nayik.y, x =1000} )

end
local function gameLoop()
	fireLaser()
	updateText()
end
gameLoopTimer= timer.performWithDelay(300,gameLoop,0)

function moveBackground(event)
bg1.x=bg1.x-3
bg2.x=bg2.x-3

	if (bg1.x ) < -90 then
		bg1:translate(screenW,0)
	
	end
	if (bg2.x )< -90 then
		bg2:translate(screenW,0)
	end


end

function moveBombs(self,event)
	self:applyForce(-.1,0, self.x, self.y)
	if 	self.collided== true then
		self.x=500
		self.collided=false
	end
if self.x<-50 then
	self.x=500
	self.isVisible=true

else

	self.x=self.x-self.speed
	self.angle=self.angle+.1
	self.y=self.amp*math.sin(self.angle)+self.initY

end
if self.x>600 then	
	self:applyForce(-.9,0, self.x, self.y)
end
end
function onCollision(self ,event)
	if  event.other ==bullet or event.other ==nayik  then
		if event.phase == "ended" then
			explosion.x=self.x
			explosion.y=self.y
			if event.other == bullet then
					-- Increase score
					score = score + 100
					scoreText.text = "Score: " .. score	
			elseif event.other == nayik then
					lives=lives -1
			end

		end
	
	
		if event.phase == "ended" then
			
			explosion.isVisible=true
			explosion:play()
			self.collided=true	
			 
		end
	end
	
end
-- sprite listener function
	local function spriteListener( event )
 
		local thisSprite = event.target  -- "event.target" references the sprite
			if ( event.phase == "ended" ) then 
				explosion.isVisible=false
			
			end

	
		
	end



--------------------------------------------------------------------------------
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
nayik:addEventListener("touch",dragShip)
Runtime:addEventListener("enterFrame",moveBackground)
bombs.enterFrame=moveBombs
bombs.collision = onCollision
bombs:addEventListener( "sprite", spriteListener )
--------------------------------------------------------------------------------
bombs2.enterFrame=moveBombs
bombs2.collision = onCollision
bombs2:addEventListener( "sprite", spriteListener )
--------------------------------------------------------------------------------
bombs3.enterFrame=moveBombs
bombs3.collision = onCollision
bombs3:addEventListener( "sprite", spriteListener )
--------------------------------------------------------------------------------
explosion:addEventListener( "sprite", spriteListener )
Runtime:addEventListener("enterFrame",bombs)
Runtime:addEventListener("enterFrame",bombs2)
Runtime:addEventListener("enterFrame",bombs3)
bombs:addEventListener("collision")
bombs2:addEventListener("collision")
bombs3:addEventListener("collision")



-----------------------------------------------------------------------------------------

return scene