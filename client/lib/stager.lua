-- stager.lua v0.1

-- Copyright (c) 2016 Ulysse Ramage
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local stager = {
  stack = {},
  _stack = {}, --temporary stack
  __index = function(self, key, args)
    return function(...)
      for i = #self.stack, 1, -1 do
        if self.stack[i][key] then
          if self.stack[i][key](...) == true then break; end --return true -> block event propagation
        end
      end
    end
  end
}
setmetatable(stager, stager)

local function loadPath(path)

  local matches = {}
  for match in string.gmatch(path,"[^;]+") do
    matches[#matches+1] = match
  end
  path = matches[1]
  
  package.loaded[path] = false

  return require(path)

end

--[[ Public ]]--

function stager:new() --create new state
  return {}
end

function stager:push(path, params)

  local scene = loadPath(path)

  table.insert( self.stack, scene )

  if scene.load then scene.load(params) end

end

function stager:pop()

  local scene = self.stack[#self.stack]

  if scene.unload then scene.unload() end

  if scene.removeReady then table.insert(self._stack, scene) end --insert in temporary stack
  table.remove(self.stack, #self.stack)

end

function stager:switch(path, params)

  for i = 1, #self.stack do --remove all overlays
    self:pop()
  end

  self:push(path, params)
  
end

function stager:getStack()
  return #self.stack
end

function stager:getName(index)
  return self.stack[index].name
end

--correct update order
function stager:update(dt)

  for i = #self.stack, 1, -1 do
    if self.stack[i].update then self.stack[i].update(dt) end
  end

  for i = #self._stack, 1, -1 do
    if self._stack[i].update then self._stack[i].update(dt) end
    if self._stack[i].removeReady() then table.remove(self._stack, i) end
  end

end

--custom update function
function stager:fixedupdate(dt)

  for i = #self.stack, 1, -1 do
    if self.stack[i].fixedupdate then self.stack[i].fixedupdate(dt) end
  end

  for i = #self._stack, 1, -1 do
    if self._stack[i].fixedupdate then self._stack[i].fixedupdate(dt) end
  end

end

--draw
function stager:draw()

  for i = 1, #self.stack do
    if self.stack[i].draw then self.stack[i].draw() end
  end

  for i = 1, #self._stack do
    if self._stack[i].draw then self._stack[i].draw() end
  end
  
end

return stager