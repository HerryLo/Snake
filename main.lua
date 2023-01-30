-------------------------------------------init--------------------------------
local updateCD=0.5
local timer=0.5
local dir={x=0,y=1}
local lastDir={x=0,y=0}
local map={}
local food={x=0,y=0}
------------------------for map---------------------------
local function setupMap()
	map={}
	for x=1,15 do
		map[x]={}
		for y=1,15 do
			if x==1 or x==15 or y==1 or y==15 then
				map[x][y]=true 
			else
				map[x][y]=false
			end
		end
	end 
end
local function drawMap()
	love.graphics.setColor(255,255,255)
    for x=1,15 do
	for y=1,15 do
		local how=map[x][y] and "fill" or "line"
		love.graphics.rectangle(how, x*32+100, y*32, 30, 30, 5, 5)
	end
	end
end
local function check(x,y)
	return map[x][y]
end
-----------------------for food-----------------------
local function newFood()
	repeat 
		food.x= love.math.random(2,14)
		food.y= love.math.random(2,14)
	until check(food.x,food.y)==false
	map[food.x][food.y]=true
end
-----------------------for snake------------------------------
local snake={}
local function setupSnake()
	snake={}
	for i=1,5 do
		snake[i]={x=i+5,y=7} 
	end
end
local function drawSnake(toggle)
	for i,v in ipairs(snake) do
		map[v.x][v.y]=toggle
	end
end
--------------------game over--------------------------------
local function gameover()
	local title = "Game Over"
	local message = "Your Score is "..tostring(#snake-5)
	local buttons = {"Restart!", "Quit!", escapebutton = 2}
	 
	local pressedbutton = love.window.showMessageBox(title, message, buttons)
	if pressedbutton == 1 then
	   	setupMap()
		setupSnake()
		drawSnake(true)
		newFood()
		timer=0.5
		dir={x=0,y=1}
		lastDir={x=0,y=0}
	elseif pressedbutton == 2 then
	    love.event.quit()
	    -- exf.resume()
	end
end
local function eat()
	table.insert(snake, {x=snake[1].x,y=snake[1].y})
	updateCD=updateCD*0.9
	newFood()
end
---------------------for update -------------------------
local function updateSnake()
	lastDir.x=dir.x
	lastDir.y=dir.y
	local targetX,targetY=snake[1].x+dir.x,snake[1].y+dir.y
	if check(targetX,targetY) then
		if targetX==food.x and targetY==food.y then --eat
			eat()
		else --hit
			gameover()
			return
		end
	end
	drawSnake(false)
	for i=#snake,2,-1 do
		snake[i].x=snake[i-1].x
		snake[i].y=snake[i-1].y
	end
	snake[1].x=targetX
	snake[1].y=targetY
	
	drawSnake(true)
end
-----------------------for input-------------------
local function input()
	if love.keyboard.isDown("up") then
		if lastDir.y==0 then
			dir.x,dir.y=0,-1
		end
	elseif love.keyboard.isDown("down") then
		if lastDir.y==0 then
			dir.x,dir.y=0,1
		end
	elseif love.keyboard.isDown("left") then
		if lastDir.x==0 then
			dir.x,dir.y=-1,0
		end
	elseif love.keyboard.isDown("right") then
		if lastDir.x==0 then
			dir.x,dir.y=1,0
		end
	end
end
-------------------------------------the main frame------------------------------------
function love.load()
    love.window.setTitle('Snake 贪吃蛇')
	setupMap()
	setupSnake()
	drawSnake(true)
	newFood()
end
function love.update(dt)
	--print(dir.x,dir.y)
	input()
	timer=timer-dt
	if timer<0 then
		timer=updateCD
		updateSnake()
	end
	
end
function love.draw()
    drawMap()
end