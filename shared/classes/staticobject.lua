local Class = class('StaticObject', Object)

--can reconstruct an identical copy of a Class using Class:new( Class:serialize() )
function Class:initialize(args)
  Object.initialize(self, args)

  self.width, self.height = args.width, args.height
  
  self.class = "StaticObject"
  
end

--CLIENT
function Class:draw()
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end
--/CLIENT

function Class:serialize() --assuming a static object is just a wall TODO: add support for custom shapes
    return table.merge(
        Object.serialize(self),
        {
            width = self.width,
            height = self.height,
        }
    )
end

return Class