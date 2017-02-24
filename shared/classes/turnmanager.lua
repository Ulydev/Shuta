local Class = class("TurnManager")

local approxLag = .5 --TODO: move to global settings

function Class:initialize(state)
    
    self.turns = {}

    self.currentTurnIndex = 0
    self:nextTurn() --go to first turn

    self.state = state

    self:resetTimer( approxLag )

    return self
end

function Class:update(dt)
    self:updateTimer(dt)
end

--TODO: the class name and methods are confusing 

function Class:addTurn(id, turn, force)
    local el = self:getTurn( self:getCurrentTurnIndex() )

    if force or not el[id] then --if there already is a turn for that client just skip it - no cheating!
        el[id] = turn
        return true
    end
    return false
end

function Class:getTurn(index)
    return self.turns[index]
end

function Class:getTurns()
    return self.turns
end

function Class:getCurrentTurnIndex()
    return self.currentTurnIndex
end

function Class:getTurnCount(roundIndex)
    local count = 0
    for index, turn in pairs( self:getTurn(roundIndex) ) do
        if turn then count = count + 1 end --we got a turn
    end
    return count
end

--timer
function Class:updateTimer(dt)

    self.time = math.max( self.time - dt, 0 )
    --on client, just wait for server to broadcast turns

    if server then

        if self.time == 0 then

            --TODO: move code
            local room = self:getState():getRoom()

            self:resetTimer( room:getSettings().turnLength + approxLag ) --.5 is approx lag

            server:sendToAllInRoom( room.id, "turnList", self:serialize(self:getCurrentTurnIndex()) )

            --set next target frame
            self:getState():nextTurnFrame()

            log("[#" .. room.id .. "] Simulating to frame " .. self:getState().targetFrame )

            --update state
            self:getState():fullUpdate()

            self:nextTurn() --once everything has been updated, go to next turn

        end

    end
end
function Class:getTimer()
    return self.time
end
function Class:setTimer(time)
    self.time = time
end
function Class:resetTimer(offset)
    self:setTimer( self.state:getRoom():getSettings().turnTimer + (offset or 0) )
end

function Class:previousTurn()
    self.currentTurnIndex = math.max(self.currentTurnIndex - 1, 1)
end

function Class:nextTurn()
    self.currentTurnIndex = self.currentTurnIndex + 1
    local index = self:getCurrentTurnIndex()
    if not self.turns[index] then self.turns[index] = {} end
end

--

function Class:isReady()
    --TODO: should turnManager be part of gameState (currently is) or room?
    return self:isTurnFull( self:getCurrentTurnIndex() )
end

function Class:isTurnFull(roundIndex)
    local limit = self:getState():getRoom():getSettings().playingClients
    local count = self:getTurnCount( roundIndex )
    return count >= limit
end

--

function Class:getState()
    return self.state
end

--

function Class:serialize(turnIndex)
    local res = {}
    if not turnIndex then --TODO: serialize all turns for clients who have just joined

    else --serialize a specific turn

        local turn = self:getTurn( turnIndex )
        for k, v in pairs(turn) do
            table.insert(res, {
                id = k,
                turn = v:serialize() --TODO: SOOOO CONFUSING fix that sh*t
            })
        end

    end
    return res
end

return Class