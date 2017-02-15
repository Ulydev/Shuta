local Class = class('Object')

function Class:initialize(args)
  
  self.x, self.y = args.x, args.y
  
end

function Class:serialize()
  return {
    class = self.class,
    x = self.x,
    y = self.y,
  }
end

return Class