-- Each function handles drawing, collisions, and returns the value.

function button(x, y, text, trigger)
    -- Render
    width, height = text_box(x, y, text)

    local mx, my = love.mouse.getPosition()
    if love.mouse.isDown(1) and fired <= 0 then
        if mx > x and mx < x + width + 10 and my > y and my < y + height + 10 then
            fired = 0.5
            return trigger()
        end
    end
end

function text_box(x, y, text)
    local text_object = love.graphics.newText(love.graphics.getFont(), text)
    local width, height = text_object:getWidth(), text_object:getHeight()
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", x, y, width + 10, height + 10)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", x, y, width + 10, height + 10)
    love.graphics.print(text, x + 5, y + 5)
    return width, height
end

function input(x, y, starter_text, current_text, selected) -- Currently number-only
    if selected then -- Render
        width, height = text_box(x, y, starter_text..current_text.."|")

        -- And perform function in this loop to avoid redundant `if` statements
        if fired <= 0 then
            if love.keyboard.isDown("1") then
                current_text = current_text.."1"
                fired = .1
            end
            if love.keyboard.isDown("2") then
                current_text = current_text.."2"
                fired = .1
            end
            if love.keyboard.isDown("3") then
                current_text = current_text.."3"
                fired = .1
            end
            if love.keyboard.isDown("4") then
                current_text = current_text.."4"
                fired = .1
            end
            if love.keyboard.isDown("5") then
                current_text = current_text.."5"
                fired = .1
            end
            if love.keyboard.isDown("6") then
                current_text = current_text.."6"
                fired = .1
            end
            if love.keyboard.isDown("7") then
                current_text = current_text.."7"
                fired = .1
            end
            if love.keyboard.isDown("8") then
                current_text = current_text.."8"
                fired = .1
            end
            if love.keyboard.isDown("9") then
                current_text = current_text.."9"
                fired = .1
            end
            if love.keyboard.isDown("0") then
                current_text = current_text.."0"
                fired = .1
            end
            if love.keyboard.isDown("backspace") then
                current_text = string.sub(current_text, 1, string.len(current_text) - 1)
                fired = .1
            end
        end
    else
        width, height = text_box(x, y, starter_text..current_text)
    end

    -- Selection
    local mx, my = love.mouse.getPosition()
    if love.mouse.isDown(1) and fired <= 0 then
        if mx > x and mx < x + width + 10 and my > y and my < y + height + 10 then
            fired = 0.5
            selected = true
        else
            selected = false
        end
    end

    return current_text, selected
end