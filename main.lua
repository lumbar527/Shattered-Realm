-- SETUP

function _init()
    -- System Variables
    WIDTH, HEIGHT = love.window.getMode()
    SCALE = 200

    z_dist = 15
    player = {x = 0, y = 1, z = 0, rx = 0, ry = 0, rz = 0, jump = 0, grounded = true}
    deltaTime = 0

    blocks = {{0, -2, 0, 100, 2, 100}, {0, 0, 10, 10, 10, 10}, {0, 0, 20, 8, 8, 12}, {10, 0, 13, 9, 4, 10}, {0, 10, 30, 8, 4, 12}}
end

-- FUNCTIONS

-- Transform Points
function originate(x, y, z, ox, oy, oz) -- center around point o-
    return x - ox, y - oy, z - oz
end

function rotate(x, y, z, rx, ry, rz) -- rotate around origin
    -- x = (x * math.cos(rz) - y * math.sin(rz))
    -- y = (x * math.sin(rz) + y * math.cos(rz))

    -- x = (x * math.cos(ry) - z * math.sin(ry))
    -- z = (x * math.sin(ry) + z * math.cos(ry))

    -- y = (z * math.sin(rx) + y * math.cos(rx))
    -- z = (y * math.sin(rx) + z * math.cos(rx))

    local distance=math.sqrt(x^2+y^2)
    local current_angle=math.atan2(y, x)
    local new_angle=current_angle+rz
    x=math.cos(new_angle)*distance
    y=math.sin(new_angle)*distance

    local distance=math.sqrt(x^2+z^2)
    local current_angle=math.atan2(z,x)
    local new_angle=current_angle+ry
    x=math.cos(new_angle)*distance
    z=math.sin(new_angle)*distance

    local distance=math.sqrt(y^2+z^2)
    local current_angle=math.atan2(z,y)
    local new_angle=current_angle+rx
    y=math.cos(new_angle)*distance
    z=math.sin(new_angle)*distance

    return x, y, z
end

function rotate_around_point(x, y, z, ox, oy, oz, rx, ry, rz)
    x, y, z = originate(x, y, z, ox, oy, oz)
    x, y, z = rotate(x, y, z, rx, ry, rz)
    return originate(x, y, z, -ox, -oy, -oz) -- return to orginal position
end

function center_to_player(x, y, z)
    x, y, z = originate(x, y, z, player.x, player.y + 5, player.z) -- Originate to player *head*
    return rotate(x, y, z, player.rx, player.ry, player.rz)
end

function get_point(x, y, z, from_player) -- z is distance in this engine, sadly
    if from_player then
        x, y, z = center_to_player(x, y, z)
    end
    local x_prime, y_prime = x/z * SCALE, y/z * SCALE -- Apply formula
    x_prime = x_prime + WIDTH / 2
    y_prime = - y_prime + HEIGHT / 2 -- Fit to screen
    if z <= 0 then
        x_prime, y_prime = x*100 * SCALE, y*100 * SCALE -- Pretend it's just right on the edge.
        x_prime = x_prime + WIDTH / 2
        y_prime = - y_prime + HEIGHT / 2 -- Fit to screen
    end
    return x_prime, y_prime
end

function collide_rect(px, py, pz, x, y, z, width, height, depth)
    return (px > x - width / 2 and px < x + width / 2) and (py > y - height / 2 and py < y + height / 2) and (pz > z - depth / 2 and pz < z + depth / 2)
end

function simple(n) -- Returns -1, 0, or 1
    if n > 0 then return 1 elseif n < 0 then return -1 else return 0 end
end

function render_rectangle(x, y, z, width, height, depth, from_player) -- Scale values are ordered repsectively
    -- Calculate the points:
    ax, ay = get_point(x - width / 2, y - height / 2, z - depth / 2, from_player)
    bx, by = get_point(x + width / 2, y - height / 2, z - depth / 2, from_player)
    cx, cy = get_point(x + width / 2, y + height / 2, z - depth / 2, from_player)
    dx, dy = get_point(x - width / 2, y + height / 2, z - depth / 2, from_player)

    ex, ey = get_point(x - width / 2, y - height / 2, z + depth / 2, from_player)
    fx, fy = get_point(x + width / 2, y - height / 2, z + depth / 2, from_player)
    gx, gy = get_point(x + width / 2, y + height / 2, z + depth / 2, from_player)
    hx, hy = get_point(x - width / 2, y + height / 2, z + depth / 2, from_player)

    -- Render points to test:
    love.graphics.setColor(width%1.2,height%1.2,depth%1.2,1)
    if depth > 99 then
        love.graphics.setColor(1,1,1,0)
    end
    love.graphics.points(ax, ay, bx, by, cx, cy, dx, dy, ex, ey, fx, fy, gx, gy, hx, hy)
    love.graphics.line(ax, ay, bx, by)
    love.graphics.line(cx, cy, bx, by)
    love.graphics.line(cx, cy, dx, dy)
    love.graphics.line(ax, ay, dx, dy)

    love.graphics.line(ex, ey, fx, fy)
    love.graphics.line(gx, gy, fx, fy)
    love.graphics.line(gx, gy, hx, hy)
    love.graphics.line(ex, ey, hx, hy)

    love.graphics.line(ax, ay, ex, ey)
    love.graphics.line(fx, fy, bx, by)
    love.graphics.line(cx, cy, gx, gy)
    love.graphics.line(hx, hy, dx, dy)

    -- Group by faces:
    love.graphics.polygon("fill", ax, ay, bx, by, cx, cy, dx, dy)
    love.graphics.polygon("fill", ex, ey, fx, fy, gx, gy, hx, hy)
    love.graphics.polygon("fill", ax, ay, ex, ey, fx, fy, bx, by)
    love.graphics.polygon("fill", bx, by, fx, fy, gx, gy, cx, cy)
    love.graphics.polygon("fill", cx, cy, gx, gy, hx, hy, dx, dy)
    love.graphics.polygon("fill", dx, dy, hx, hy, ex, ey, ax, ay)

    -- love.graphics.print("x: "..(cx - WIDTH / 2).." y: "..(-cy + HEIGHT / 2))
end

function move_with_collisions(mx, my, mz)
    for i = 1, #blocks do
        if collide_rect(player.x + mx, player.y + my, player.z + mz, blocks[i][1], blocks[i][2], blocks[i][3], blocks[i][4], blocks[i][5], blocks[i][6]) then
            if collide_rect(player.x, player.y, player.z, blocks[i][1], blocks[i][2], blocks[i][3], blocks[i][4], blocks[i][5], blocks[i][6]) then
                -- if not collide_rect(player.x - mx * 2, player.y - my * 2, player.z - my * 2, 0, 0, 10, 10, 10, 10) then
                --     return player.x - mx * 2, player.y - my * 2, player.z - mz * 2
                -- end
                love.graphics.print("Help I'm stuck!"..player.x.." "..player.z.." "..mx.." "..mz)
            end
            return player.x, player.y, player.z
        end
    end
    return player.x + mx, player.y + my, player.z + mz
end

function distance(block)
    return math.sqrt(
        (block[1] - player.x + block[4] / 2)^2 +
        (block[2] - player.y + block[5] / 2)^2 +
        (block[3] - player.z + block[6] / 2)^2
    )
end

function blocks_closer(a, b)
    return distance(a) > distance(b)
end

-- BEGIN

_init()

function love.update(dt)
    deltaTime = dt
end

function love.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill",0,0, WIDTH, HEIGHT)

    table.sort(blocks, blocks_closer)
    for i = 1, #blocks do
        render_rectangle(blocks[i][1], blocks[i][2], blocks[i][3], blocks[i][4], blocks[i][5], blocks[i][6], true)
    end
    -- render_rectangle(5, 5, 5, 2, 2, 2, true)
    -- render_rectangle(0, 0, 10, 10, 10, 10, true)

    -- Player Movement
    if love.keyboard.isDown("w") then
        player.x, player.y, player.z = move_with_collisions(math.sin(player.ry), 0, math.cos(player.ry))
    end
    if love.keyboard.isDown("s") then
        player.x, player.y, player.z = move_with_collisions(-math.sin(player.ry), 0, -math.cos(player.ry))
    end
    if love.keyboard.isDown("a") then
        player.x, player.y, player.z = move_with_collisions(math.sin(player.ry - math.pi/2), 0, math.cos(player.ry - math.pi/2))
    end
    if love.keyboard.isDown("d") then
        player.x, player.y, player.z = move_with_collisions(-math.sin(player.ry - math.pi/2), 0, -math.cos(player.ry - math.pi/2))
    end
    if love.keyboard.isDown("space") then
        if player.jump <= 0 and player.grounded then
            player.jump = .3
            player.grounded = false
        end
    end
    if love.keyboard.isDown("lshift") then
        player.y = player.y - deltaTime*10
    end
    if love.keyboard.isDown("left") then
        player.ry = player.ry - deltaTime
    end
    if love.keyboard.isDown("right") then
        player.ry = player.ry + deltaTime
    end
    if love.keyboard.isDown("up") then
        player.rx = player.rx + deltaTime
    end
    if love.keyboard.isDown("down") then
        player.rx = player.rx - deltaTime
    end
    if player.jump > 0 then
        player.x, player.y, player.z = move_with_collisions(0, deltaTime * 50, 0)
        player.jump = player.jump - deltaTime
    else
        local oldy = player.y
        player.x, player.y, player.z = move_with_collisions(0, - deltaTime * 50, 0)
        player.grounded = oldy == player.y
    end
    -- if collide_rect(player.x, player.y, player.z, 0, 0, 10, 10, 10, 10) then
    --     love.graphics.print("Collision!")
    -- end
end