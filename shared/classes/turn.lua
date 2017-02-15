local Class = class('Turn')

function Class:initialize(args)
    self.actions = {}

    if args then
        if args.actions then --reconstruct from serialized object
            for index, action in pairs(args.actions) do 
                self:addAction( Action:new(action) )
            end
        end
    end
  
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

--

function Class:serialize()
    local res = { actions = {} }
    for index = 1, self:getActionCount() do
        table.insert( res.actions, self:getAction(index):serialize() )
    end
    return res
end

return Class