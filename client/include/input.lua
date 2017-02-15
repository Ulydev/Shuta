local Input = {}
Input.__index = Input

Input.bindings = {
  
}

--[[ Check touch area ]]--

local function checkArea( x, y, area )
  if not x or not y then return false end
  return (x > area[1] and x < area[3]) and (y > area[2] and y < area[4])
end

--[[ Input methods ]]--

function Input:bind(key, binding)
  Input.bindings[key] = binding
end

function Input:isDown(key)

  if phoneMode then
    if not Input.bindings[key].mobile then return false end
    
    local touches = love.touch.getTouches()
    for i = 1, #touches do
      local x, y = love.touch.getPosition( touches[i] )
      local scale = love.window.getPixelScale()
      x, y = push:toGame( x / scale, y / scale ) --hacky
      if checkArea( x, y, Input.bindings[key].mobile ) then
        return true
      end
    end
    return false
    
  else
    
    return love.keyboard.isDown(Input.bindings[key].keyboard)
    
  end

end

--[[ Bindings ]]--

Input:bind("left", {
    ["keyboard"] = { "left", "a" }
})
Input:bind("right", {
  ["keyboard"] = { "right", "d" }
})
Input:bind("up", {
  ["keyboard"] = { "up", "w" }
})
Input:bind("down", {
  ["keyboard"] = { "down", "s" }
})

return Input