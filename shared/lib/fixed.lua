-- fixed.lua v0.1

-- Copyright (c) 2017 Ulysse Ramage
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local fixed = {
    time = 0,
    rate = 1/30 --default 30fps
}

function fixed:getRate()
    return fixed.rate
end

function fixed:setRate(rate)
    fixed.rate = rate
    return fixed
end

function fixed:setFunction(f)
    fixed.callback = f
    return fixed
end

--

function fixed:update(dt)
    self.time = self.time + dt
    while self.time >= self.rate do
        if self.callback then self.callback( self.rate ) end
        self.time = self.time - self.rate
    end
end

--

return fixed
