local Class = class('SimplePhysicsEngine', BaseEngine)

function Class:initialize(state)
    BaseEngine.initialize(self, state)

    --custom stuff
  
end

--util

function Class:getPlayer(index)
    return self:getState():filterObject(function(o)
        local isCharacter = o:isInstanceOf(Character)
        if not isCharacter then return false end

        local isChosen = (o:getClient().id or o:getClient().id) == index
        return isChosen
    end)
end

--vvv update order

function Class:applyAction(index, action)

    local player = self:getPlayer(index)
    if not player then return true end

    if action.type == "move" then

        player.target = Target:new({
            x = action.data.x,
            y = action.data.y
        })

    elseif action.type == "shoot" then

        local angle = math.atan2( action.data.y - player.y, action.data.x - player.x )
        local bullet = Bullet:new({
            x = player.x + math.cos(angle) * player.radius,
            y = player.y + math.sin(angle) * player.radius,
            angle = angle,
            client = player.client
        })

        self:getState():addObject(bullet)

    end

end

function Class:updateFrame(dt)

    --

end

function Class:updateObject(dt, object)

    if object.target then
        local dx, dy = object.target.x - object.x, object.target.y - object.y
        local angle = math.atan2(dy, dx)
        local speed = math.min( math.sqrt(dx^2 + dy^2)^1.2, object.speed ) --FIXME: lerp effect not desired
        local velocity = { x = math.cos(angle) * speed, y = math.sin(angle) * speed }
        object.x = object.x + velocity.x * dt
        object.y = object.y + velocity.y * dt --FIXME: remove redundant code
    elseif object.velocity then
        object.x = object.x + object.velocity.x * dt
        object.y = object.y + object.velocity.y * dt
    end

    if object.radius then
        local dist = math.sqrt(object.x^2 + object.y^2)
        local maxDist = 750 - object.radius
        if dist > maxDist then
            local angle = math.atan2(object.y, object.x)
            object.x, object.y = math.cos(angle) * maxDist, math.sin(angle) * maxDist
            if object:isInstanceOf(Bullet) then
                if server then
                    self:getState():removeObject(object)
                elseif client then
                    self:getState():removeObject(object) --TODO: add to remove queue (keep drawing w/ fade effect)
                end
            end
        end
    end

    --

    if client and self.state:isInstanceOf(GameStateSimulation) then return true end --don't handle collision on ghost prediction
    --TODO: better collision handling
    if object:isInstanceOf(Character) then --check for collision w/ enemy bullet
        local bullets = self:getState():filterObjects(function(o)
            return o:isInstanceOf(Bullet) and (o.client.id or o.client.id) ~= (object.client.id or object.client.id)
        end)
        for i = 1, #bullets do
            local bullet = bullets[i]
            local radius = object.radius + bullet.radius
            if math.dist(object.x, object.y, bullet.x, bullet.y) < radius then
                --collision
                local _first = self:getState():getWinner() == nil
                self:getState():setWinner( bullet.client )

                if client and _first then --visual hints
                    g.speedFactor:to(.75)
                    object:kill()

                    local winnerName
                    local room = network:getRoom()
                    for i = 1, room:getClientCount() do
                        if room:getClient(i).id == room:getState():getWinner().id then winnerName = room:getClient(i).name; break; end
                    end
                    love.messagereceived(winnerName and (winnerName .. " wins") or "Draw") --FIXME:
                end
            end
        end
    end

end

--

return Class