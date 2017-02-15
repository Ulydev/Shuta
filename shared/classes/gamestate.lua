local Class = class("GameState")

function Class:initialize(room)
    
    self.started = false

    self.objects = {
        --clients, bullets (dynamic objects) -> dynamic objects
        --static objects
    }

    self.room = room

    self.turns = TurnManager:new(self)

    return self
end

--SERVER
function Class:setupMap() --TODO: this is for 2 players only, make it customizable
    local map = {
        { x = 0, y = 0, width = 1000, height = 50 }, --up
        { x = 0, y = 950, width = 1000, height = 50 }, --down
        { x = 0, y = 50, width = 50, height = 900 }, --left
        { x = 950, y = 50, width = 50, height = 900 }, --right
    }
    local spots = {
        { x = 500, y = 150 }, --up
        { x = 500, y = 850 }, --down
    }

    for i = 1, #map do
        local object = map[i]
        self:addObject( StaticObject:new( object ) )
    end

    for i = 1, #spots do
        local spot = spots[i]
        self:addObject( Character:new( {
            client = self:getRoom():getClient(i),
            x = spot.x,
            y = spot.y,
            radius = 40,
            --friction, speed, etc.? TODO:
        } ) ) --Character is controlled by client
    end
end
--/SERVER

--CLIENT
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
--/CLIENT

--COMMON
function Class:addObject(object)
    table.insert(self.objects, object)
end

function Class:removeObject(object)
    table.remove(self.objects, self:getObjectIndex(object))
end

function Class:getObjectIndex(object)
    for i = 1, self:getObjectCount() do
        if self:getObject(i) == object then
            return i
        end
    end
end

function Class:getObjects()
    return self.objects
end

function Class:getObject(index)
    return self.objects[index]
end

function Class:getObjectCount()
    return #self.objects
end

--

function Class:start()
    self.started = true

    self:setupMap()
end

function Class:stop()
    self.started = false

end

--

function Class:forward(time) --run the game for *time* seconds

end

--

function Class:hasStarted()
    return self.started
end

--

function Class:getRoom()
    return self.room
end

function Class:getSettings()
    return self:getRoom():getSettings()
end

function Class:getTurns()
    return self.turns
end

--

function Class:serialize(withMap)
    local serialized = {}
    serialized.started = self.started
    serialized.objects = {}

    for i = 1, self:getObjectCount() do
        local object = self:getObject(i)
        --

        local skip = false

        if object.class == "StaticObject" and not withMap then --do not send static objects unless needed
            skip = true
        end

        if not skip then
            serialized.objects[i] = object:serialize()
        end
    end

    return serialized
end

return Class