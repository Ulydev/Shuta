local Class = class('Turn')

function Class:initialize(args)
    self:reset()
    --[[
    self.actions = {
        action1, --each action has a frame attribute
        action2,
        ...
    }
    --]]

    if args then
        if args.actions then --reconstruct from serialized object
            for i = 1, #args.actions do 
                self:addAction( Action:new( args.actions[i] ) )
            end
        end
    end
  
end

function Class:reset()
    self.actions = {}
end

--

function Class:getActionCount()
    return #self.actions
end

function Class:addAction(action)
    table.insert(self.actions, action)
end

function Class:getAction(index)
    return self.actions[index]
end

function Class:getActionsAt(time)
    local actions = {}
    for i = 1, #self.actions do
        local action = self.actions[i]
        if action.time == time then
            table.insert(actions, action)
        end
    end
    return actions
end

--

function Class:serialize()
    local res = { actions = {} }
    for index = 1, self:getActionCount() do
        table.insert( res.actions, self:getAction(index):serialize() )
    end
    return res
end

return Class