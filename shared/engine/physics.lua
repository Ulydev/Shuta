local Class = class('PhysicsEngine', StateEngine)

function Class:initialize(state)
    StateEngine.initialize(self, state)

    --custom stuff
  
end

--vvv update order

function Class:applyAction(index, action)

    if action.type == "move" then

        local player = self:getState():filterObject(
            function(o)
                local isCharacter = (o.class == "Character")
                if not isCharacter then return false end

                local isChosen = (o:getClient().id or o:getClient():getIndex()) == index
                return isChosen
            end
        )
        player.target = Target:new({
            x = action.data.x,
            y = action.data.y
        })

    end

end

function Class:updateFrame(dt)



end

function Class:updateObject(dt, object)

    if object.target then
        object.x = math.to(object.x, object.target.x, 200 * dt)
        object.y = math.to(object.y, object.target.y, 200 * dt)
    end

end

--

return Class