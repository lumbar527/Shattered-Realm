-- SETUP

function _init()
    -- System Variables
    WIDTH, HEIGHT = love.window.getMode()
    SCALE = 200
    z_dist = 15
    player = {x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0}
end

-- FUNCTIONS

-- Transform Points
function originate(x, y, z, ox, oy, oz) -- center around point o-
    return x - ox, y - oy, z - oz
end

function rotate(x, y, z, rx, ry, rz) -- rotate around origin
    x = x * math.cos(rz) - y * math.sin(rz)
    y = x * math.sin(rz) + y * math.cos(rz)

    x = x * math.cos(ry) - z * math.sin(ry)
    z = x * math.sin(ry) + z * math.cos(ry)

    y = z * math.sin(rx) + y * math.cos(rx)
    z = y * math.sin(rx) + z * math.cos(rx)

    return x, y, z
end

function rotate_around_point(x, y, z, ox, oy, oz, rx, ry, rz)
    x, y, z = originate(x, y, z, ox, oy, oz)
    x, y, z = rotate(x, y, z, rx, ry, rz)
    return originate(x, y, z, -ox, -oy, -oz) -- return to orginal position
end

function center_to_player(x, y, z)
    x, y, z = originate(x, y, z, player.x, player.y, player.z)
    return rotate(x, y, z, player.rx, player.ry, player.rz)
end

function get_point(x, y, z, from_player) -- z is distance in this engine, sadly
    if from_player then
        x, y, z = center_to_player(x, y, z)
    end
    x_prime, y_prime = x/z * SCALE, y/z * SCALE -- Apply formula
    x_prime = x_prime + WIDTH / 2
    y_prime = - y_prime + HEIGHT / 2 -- Fit to screen
    if z <= 0 then
        x_prime = simple(x/z) * WIDTH / 2
        y_prime = simple(y/z) * HEIGHT / 2
    end
    return x_prime, y_prime
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
    love.graphics.setColor(0,0,0)
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
end

-- BEGIN

_init()

function love.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill",0,0, WIDTH, HEIGHT)
    render_rectangle(5, 5, z_dist, 2, -2, 2, true)
    -- z_dist = z_dist + 1/10
    player.ry = player.ry - 1/100
    -- if player.rx > math.pi * 2 then player.rx = player.rx - math.pi * 2 end
end