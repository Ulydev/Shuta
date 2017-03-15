local Class = class("GameState")

function Class:initialize(args)

    self.room = args.room
    self.engineType = args.engineType

    self:reset()

    self.map = args.map

    if args.room and args.room.state and args.room.state.currentTurn then
        for i = 1, args.room.state.currentTurn - 1 do
            self:getTurns():nextTurn()
        end
    end

    return self
end

function Class:reset()
    self.started = false
    self.objects = {}
    self.turns = TurnManager:new(self)

    self.frame = 0
    self.targetFrame = 0

    self.engine = _G[self.engineType]:new(self)

    self.winner = nil --FIXME: what about multiple winners
end

--

--SERVER
function Class:setupMap() --TODO: this is for 2 players only, make it customizable
    local spots = {
        { x = 0, y = -350 }, --up
        { x = 0, y = 350 }, --down
    }

    for i = 1, #self.map.objects do
        self:addObject( self.map.objects[i] )
    end

    for i = 1, #self.map.spots do
        local spot = self.map.spots[i]
        self:addObject( Character:new( {
            client = self:getRoom():getClient(i),
            x = spot.x,
            y = spot.y
            --friction, speed, etc.? TODO:
        } ) ) --Character is controlled by client
    end
end
--/SERVER

--CLIENT
function Class:updateData( stateData )
    if stateData.objects then
        for i = 1, #stateData.objects do
            local object = stateData.objects[i]
            if object.class and _G[object.class] then
                self:addObject( _G[object.class]:new(object) ) --TODO: ugly code, needs class name to be declared exactly that way
            end
        end
        --once we've added all objects we don't need them anymore
        stateData.objects = nil
    end

    table.populate(self, stateData)
end

function Class:update(dt)
    if self:hasStarted() then

        local objects = self:getObjects()
        for i = 1, #objects do
            local object = objects[i]
            if object.update then object:update( dt ) end
        end

        self:getTurns():update( dt )

    else --TODO: move update code to fixedupdate, make update() client-side only?
        if server then
            if self.restartTime then
                self.restartTime = self.restartTime - dt
                if self.restartTime < 0 then --restart game
                    self.restartTime = nil
                    self:reset()
                    self:getRoom():checkNewGame()
                end
            end
        end
    end
end

function Class:draw()
    love.graphics.setColor( lue:getColor("main", 100) )
    love.graphics.setLineWidth(15)
    love.graphics.circle("line", 0, 0, 750) --TODO: custom boundaries - default is 750

    love.graphics.setColor(255, 255, 255)
    local objects = self:getObjects()
    for i = 1, #objects do
      local object = objects[i]
      object:draw()
    end
end
--/CLIENT

--update start/end events

if client then

    function Class:onStopRunning()
        if self:getWinner() then
            self:stop()
            return true
        end

        local remainingTurns = network:getRoom():getSettings().maxTurns - network:getRoom():getState():getTurns():getCurrentTurnIndex()
        if remainingTurns == 1 then return true end --let's wait for the final server answer

        network:getRoom():getState():getTurns():resetTimer()
        network:getRoom():getState():getTurns():nextTurn()

        g.hud.editor:resetTurn() --TODO: better organization
        g.simulation:resetFromState()
        g.simulation:startSimulation()
    end

elseif server then

    function Class:onStopRunning()

        local _draw = self:getTurns():getCurrentTurnIndex() == self:getRoom():getSettings().maxTurns - 1
        if self:getWinner() or _draw then
            if not self:getWinner() then self:setWinner({ id = 0 }) end --0 is draw
            self:stop()
            self.restartTime = self:getRoom():getSettings().turnLength + 4 --FIXME:
            if _draw then
                server:sendToAllInRoom(self:getRoom().id, "gameState", self:serializeWinner())
            end
            log("[#" .. self:getRoom().id .. "] Game ended, winner is " .. self:getWinner().id ..". Restarting in " .. self.restartTime)
        end

    end

end

--

function Class:fixedupdate(dt)

    if self:hasStarted() then

        if self.frame < self.targetFrame then

            self.frame = self.frame + 1
            self.engine:update(dt)

            if self.frame == self.targetFrame and self.onStopRunning then
                self:onStopRunning()
            end

        end

    end

end

--SERVER
function Class:fullUpdate()
    while self.frame < self.targetFrame do
        self:fixedupdate( fixed:getRate() )
    end
end
--

function Class:nextTurnFrame()

    if client then network:getRoom():getState():getTurns():setTimer(0) end

    self.targetFrame = self.targetFrame + self:getRoom():getSettings().turnLength / fixed:getRate() --e.g. 2 * 30 = 60 frames to update
end
--TODO: once turn is updated, clear all those fucking turns and prevent it from doing complete bullshit

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

--[[
e.g. to find local player,

state:getObject( state:filterObjects(function(o)
    return o:isInstanceOf(Character) and o.id == network:getLocalIndex()
end)[1] )

TODO: weird
-—]]

function Class:getObject(index)
    return self.objects[index]
end

function Class:getObjectCount()
    return #self.objects
end

--

function Class:start()
    self.started = true

    self:setupMap( self.map ) --TODO: custom system
end

function Class:stop()
    self.started = false

end

--

function Class:setWinner(winner)
    self.winner = winner
end
function Class:getWinner()
    return self.winner
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
    return self.room
end

function Class:getSettings()
    return self:getRoom():getSettings()
end

function Class:getTurns()
    return self.turns
end

--

function Class:serializeWinner()
    return {
        winner = { id = self.winner.id or self.winner.id } --winner is a client table containing id (already got name client-side)
    }
end --FIXME: ugly

function Class:serialize(withMap)
    local serialized = {}
    serialized.frame = self.frame
    serialized.started = self.started
    serialized.engineType = self.engineType --FIXME: maybe just "gameMode"?
    serialized.objects = {}

    for i = 1, self:getObjectCount() do
        local object = self:getObject(i)
        --

        local skip = false

        if object:isInstanceOf(StaticObject) and not withMap then --do not send static objects unless needed
            skip = true
        end

        if not skip then
            serialized.objects[i] = object:serialize()
        end
    end

    if server then serialized.currentTurn = self:getTurns():getCurrentTurnIndex() end

    return serialized
end

return Class