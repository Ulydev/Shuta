local Class = class("GameStateSimulation")

function Class:initialize(state)

    self.state = state

    return self
end

--FIXME: a lot of redundant code
function Class:updateData( stateData )
    for i = 1, #stateData.objects do
        local object = stateData.objects[i]
        if object.class and _G[object.class] then
            self:addObject( _G[object.class]:new(object) ) --TODO: ugly code, needs class name to be declared exactly that way
        end
    end
    --once we've added all objects we don't need them anymore
    stateData.objects = nil

    table.populate(self, stateData)
end

function Class:update(dt)
    if self:hasStarted() then
        local objects = self:getObjects()
        for i = 1, #objects do
            local object = objects[i]
            if object.update then object:update(dt) end
        end
    end
end

function Class:draw(alpha)
    local objects = self:getObjects()
    for i = 1, #objects do
      local object = objects[i]
      object:draw(alpha)
    end
end

function Class:fixedupdate(dt)

    if self:hasStarted() then

        if self.frame < self.targetFrame then

            self.frame = self.frame + 1
            self.engine:update(dt)

        end

    end

end

--

function Class:nextTurnFrame()

    if client then network:getRoom():getState():getTurns():setTimer(0) end

    self.targetFrame = self.targetFrame + self:getRoom():getSettings().turnLength / fixed:getRate() --e.g. 2 * 30 = 60 frames to update
end

function Class:getCurrentFrame()
    return self.frame
end

function Class:addObject(object)
    table.insert(self.objects, object)
end

function Class:removeObject(object)
    table.remove(self.objects, self:getObjectIndex(object))
end

function Class:getObjectIndex(object) --TODO: maybe give each object a .id attribute
    for i = 1, self:getObjectCount() do
        if self:getObject(i) == object then
            return i
        end
    end
end

function Class:getObjects()
    return self.objects
end

--Filters

function Class:filterObject(filter)
    for i = 1, self:getObjectCount() do
        if filter( self:getObject(i) ) then return self:getObject(i) end
    end
    --if not found return nothing
end

function Class:filterObjects(filter)
    local objects = {}
    for i = 1, self:getObjectCount() do
        if filter( self:getObject(i) ) then table.insert( objects, self:getObject(i) ) end
    end
    return objects
end

function Class:getObject(index)
    return self.objects[index]
end

function Class:getObjectCount()
    return #self.objects
end

--

function Class:hasStarted()
    return self.started
end
function Class:isRunning()
    return self.frame < self.targetFrame
end

--

function Class:getRoom()
    return self.state:getRoom()
end

function Class:getSettings()
    return self:getRoom():getSettings()
end

function Class:getTurns()
    return self.state:getTurns()
end

--

return Class