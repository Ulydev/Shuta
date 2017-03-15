local Class = class('RadialPhysicsEngine', BaseEngine)

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

function Class:getPlanet()
    return self:getState():filterObject(function(o)
        local isPlanet = o:isInstanceOf(Planet)
        return isPlanet
    end)
end

local planet

--vvv update order

function Class:applyAction(index, action)

    local player = self:getPlayer(index)
    if not player then return true end

    if action.type == "move" or action.type == "shoot" then --FIXME: state is super desync

        local velocity = {}

        local mouseAngle = math.atan2( action.data.y, action.data.x )
        local mouseDist = math.sqrt( action.data.x^2 + action.data.y^2 ) --FIXME: this is for centered planet ONLY

        local playerAngle = math.atan2( player.y, player.x )
        local playerDist = math.sqrt( player.x^2 + player.y^2 )

        velocity.x = math.clamp(-2, math.adist(playerAngle, mouseAngle), 2) * .2
        velocity.y = math.clamp(-10, playerDist - mouseDist, 10) * 6

        --

        if action.type == "move" then

            player.velocity.x, player.velocity.y = velocity.x * 2, velocity.y * 4

        elseif action.type == "shoot" then

            local bullet = Bullet:new({
                x = player.x + math.cos(mouseAngle) * player.radius,
                y = player.y + math.sin(mouseAngle) * player.radius,
                velocity = {
                    x = velocity.x * 2,
                    y = velocity.y * 2
                },
                client = player.client
            })

            self:getState():addObject(bullet)

        end

    end

end

function Class:updateFrame(dt)

    planet = self:getPlanet()

end

function Class:updateObject(dt, object)

    if object.velocity then
        object.velocity.y = object.velocity.y + 100 * dt --FIXME: dynamic mass?
        
        local dx, dy = planet.x - object.x, planet.y - object.y
        local angle = math.atan2( -dy, -dx )
        local distance = math.sqrt( dx^2 + dy^2 )
        
        angle = angle + object.velocity.x / ((distance) * .1) * 60 * dt
        distance = distance - object.velocity.y * dt
        
        local minDistance = object.radius + planet.radius
        if distance < minDistance then --touching planet
            distance = minDistance
            object.velocity.y = -object.velocity.y * .3
            object.velocity.x = object.velocity.x * (1 - .4)
        end
        
        object.x = planet.x + math.cos(angle) * distance
        object.y = planet.y + math.sin(angle) * distance
    end

    if object.radius then
        print(object.radius)
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