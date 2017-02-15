local Class = class("TurnManager")

function Class:initialize(state)
    
    self.turns = {
    }

    self:nextTurn()

    self.state = state

    return self
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
    return #self.turns
end

function Class:getTurnCount(roundIndex)
    return #self.turns[roundIndex]
end

function Class:nextTurn()
    table.insert(self.turns, {})
end

--

function Class:isReady()
    --TODO: should turnManager be part of gameState (currently is) or room?
    return self:getTurnCount( self:getCurrentTurnIndex() ) >= self:getState():getRoom():getSettings().playingClients
end

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