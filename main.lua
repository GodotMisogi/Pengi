function love.run()
 
	if love.math then
		love.math.setRandomSeed(os.time())
	end
 
	if love.load then love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
 
	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
 
		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end
 
		if love.timer then love.timer.sleep(0.001) end
	end
 
end

function love.load()

	-- Window Dimensions
	screen = {width = 800, height = 600}

	-- Window Setup
	love.window.setTitle('Pengi!')
	love.window.setMode(screen.width, screen.height)
	background = love.graphics.newImage("wallpaper.png")
	quad = love.graphics.newQuad(270, 0, screen.width, screen.height - 100, background:getWidth(), background:getHeight())
	-- Scoring
	score = {}
	score.player = 0
	score.enemy = 0

	function updateScore(player, enemy)
		if player == 1 then
			score.player = score.player + 1
		elseif enemy == 1 then
			score.enemy = score.enemy + 1
		end
	end

	-- Paddle Definitions
	player = {}
	player.dimension = {width = 20, height = 100}
	player.position = {x = 0, y}
	player.style = {x_curve = 10, y_curve = 10}
	player.color = {0, 100, 255, 255}

	enemy = {}
	enemy.dimension = {width = 20, height = 100}
	enemy.position = {x = screen.width - enemy.dimension.width, y}
	enemy.style = {x_curve = 10, y_curve = 10}
	enemy.color = {255, 100, 0, 255}

	function updatePlayerPosition()
		player.position.y = love.mouse.getY() - player.dimension.height/2
		if player.position.y < 0 then
			player.position.y = 0
		elseif player.position.y > screen.height - player.dimension.height then
			player.position.y = screen.height - player.dimension.height
		end
	end

	function updateEnemyPosition(t)
		damper = 0.87
		enemy.position.y = ball.position.y*damper
		enemy.position.y = enemy.position.y - enemy.dimension.height/2
		if enemy.position.y < 0 then
			enemy.position.y = 0
		elseif enemy.position.y > screen.height - enemy.dimension.height then
			enemy.position.y = screen.height - enemy.dimension.height
		end
	end

	-- Ball Definition
	ball = {}
	ball.position = {x = screen.width/2, y = screen.height/2}
	ball.radius = 8
	ball.color = {0, 255, 0, 255}
	ball.velocity = {x = love.math.random(300, 400), y = love.math.random(80, 200)}

	function updateBallPosition(t)
		ball.position.x = ball.position.x + ball.velocity.x*t
		ball.position.y = ball.position.y + ball.velocity.y*t
	end

	function resetBall()
		ball.position.x = screen.width/2
		ball.position.y = love.math.random(20, 580)
	end

	function absoluteValue(x)
		if x > 0 then
			return x
		else
			return -x
		end
	end

	function invertVelocityX(t)
		ball.velocity.x = -ball.velocity.x
		updateBallPosition(t)
	end

	function invertVelocityY(t)
		ball.velocity.y = -ball.velocity.y
		updateBallPosition(t)
	end

	function ballControl(t)
		if (ball.position.x < player.dimension.width) and (absoluteValue(ball.position.y - (player.position.y + player.dimension.height/2)) <= player.dimension.height/2) then
			invertVelocityX(t)
		elseif (ball.position.x > enemy.position.x) and (absoluteValue(ball.position.y - (enemy.position.y + enemy.dimension.height/2)) <= enemy.dimension.height/2)  then
			invertVelocityX(t)
		elseif (ball.position.x < 0) and not (absoluteValue(ball.position.y - (player.position.y + player.dimension.height/2)) <= player.dimension.height/2)  then
			updateScore(0,1)
			resetBall()
			invertVelocityX(t)
		elseif (ball.position.x > screen.width) and not (absoluteValue(ball.position.y - (player.position.y + player.dimension.height/2)) <= enemy.dimension.height/2)  then
			updateScore(1,0)
			resetBall()
			invertVelocityX(t)
		elseif ball.position.y < 0 or ball.position.y > screen.height then
			invertVelocityY(t)
		else
			updateBallPosition(t)
		end
	end

end

function love.update(dt)
	-- Player Movement
	updatePlayerPosition()
	updateEnemyPosition(dt)
	-- Ball Movement
	ballControl(dt)
end

function love.draw()
	--Background
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(background, quad, 0, 50)
	-- Player paddle
	love.graphics.setColor(player.color)
	love.graphics.rectangle("fill", player.position.x, player.position.y, player.dimension.width, player.dimension.height)
	-- Enemy paddle
	love.graphics.setColor(enemy.color)
	love.graphics.rectangle("fill", enemy.position.x, enemy.position.y, enemy.dimension.width, enemy.dimension.height)
	-- Ball
	love.graphics.setColor(ball.color)
	love.graphics.circle("fill", ball.position.x, ball.position.y, ball.radius, 20)
	-- Scoreboard
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("Player Score: "..score.player, 10, 10, 0)
	love.graphics.print("Enemy Score: "..score.enemy, 690, 10, 0)

end
