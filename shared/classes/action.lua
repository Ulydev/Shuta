local Class = class('Action')

function Class:initialize(args) --Turn:new( { type = "move", data = { x = 100, y = 200 } } )
    self.time = args.time
    self.type = args.type
    self.data = args.data
end

--

function Class:serialize()
    return {
        time = self.time,
        type = self.type,
        data = self.data,
    }
end

return Class