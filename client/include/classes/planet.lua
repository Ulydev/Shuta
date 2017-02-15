local Class = class('Planet', DynamicObject)

function Class:draw()
  DynamicObject.draw(self, 100)
end

return Class