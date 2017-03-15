local function _fonts(p)
    local _style = "bold"

    return {
        light = {
            small = love.graphics.newFont(p .. "fonts/uni".._style..".ttf", 36),
            medium = love.graphics.newFont(p .. "fonts/uni".._style..".ttf", 48),
            big = love.graphics.newFont(p .. "fonts/uni".._style..".ttf", 64),
        },
        bold = {
            small = love.graphics.newFont(p .. "fonts/unibold.ttf", 36),
            medium = love.graphics.newFont(p .. "fonts/unibold.ttf", 48),
            big = love.graphics.newFont(p .. "fonts/unibold.ttf", 64),
        },
        title = love.graphics.newFont(p .. "fonts/unibold.ttf", 128)
    }
end

local function _images(p)

    --trail
    local canvas = love.graphics.newCanvas(64, 64)
    love.graphics.setCanvas(canvas)
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", canvas:getWidth(), canvas:getHeight() * .5, canvas:getHeight() * .5)
    love.graphics.setCanvas()

    return {
        trail = love.graphics.newImage( canvas:newImageData() ),
    
        ui = {
            editor = {
                actions = {
                    move = love.graphics.newImage(p .. "images/ui/editor/actions/move.png"),
                    shoot = love.graphics.newImage(p .. "images/ui/editor/actions/shoot.png")
                }
            },
            controls = {
                mouseleft = love.graphics.newImage(p .. "images/ui/controls/mouseleft.png"),
                mouseright = love.graphics.newImage(p .. "images/ui/controls/mouseright.png")
            }
        }
    }
end

local function _sounds(p)
    return {
        ui = {
            turn = {
                confirm = audio:newSource(p .. "sounds/ui/turn/confirm.wav", "static"),
                start = audio:newSource(p .. "sounds/ui/turn/start.wav", "static")
            },
            select = audio:newSource(p .. "sounds/ui/select.wav", "static"):setPitch(2),
            confirm = audio:newSource(p .. "sounds/ui/confirm.wav", "static"):setPitch(1)
        }
    }
end

local function _shaders(p)
    return {
        screen = love.graphics.newShader(p .. "shaders/default.frag"),

        vignette = love.graphics.newShader(p .. "shaders/vignette.frag"),

        ghost = love.graphics.newShader(p .. "shaders/ghost.frag"),

        values = {
            vignette = soft:new(0):to(1)
        }
    }
end

--

local Class = class('AssetManager')

function Class:initialize()
    
    self.path = "assets/"

    self.assets = {}

end

function Class:load()
    --TODO:
    self.assets = {
        fonts = _fonts(self.path),
        images = _images(self.path),
        sounds = _sounds(self.path),
        shaders = _shaders(self.path)
    }
end

function Class:get(assetType)
    return self.assets[assetType]
end

--

function Class:update(dt)

    local cos = math.cos( love.timer.getTime() * 10 )

    shaders.screen:send("setting1", cos * .1 + 2)
    shaders.screen:send("setting2", cos * .2 + 100)

    shaders.vignette:send("setting", 1 + shaders.values.vignette:get() * -.3)

end

--

function Class:apply(table, f, ...)
    local table = type(table) == "table" and table or self:get(table) --table can be a string
    for k, v in pairs(table) do
        if v[f] then
            v[f](v, ...)
        elseif type(v) == "table" then --keep searching
            self:apply(v, f, ...)
        end
    end
end

--volume
function Class:setVolume(volume)
    self.volume = volume
    self:apply("sounds", "setVolume", volume)
end
function Class:getVolume(volume)
    return self.volume
end
--

return Class