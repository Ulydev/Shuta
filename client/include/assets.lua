local Assets = {}
Assets.__index = Assets

Assets.path = "assets/"
local p = Assets.path

function Assets.load()
    Assets.fonts = Assets.loadFonts()
    Assets.images = Assets.loadImages()
    Assets.sounds = Assets.loadSounds()
    Assets.shaders = Assets.loadShaders()
end

function Assets.loadFonts()
    local fonts = {}

    fonts.light = {
        small = love.graphics.newFont(p .. "fonts/unilight.ttf", 36),
        medium = love.graphics.newFont(p .. "fonts/unilight.ttf", 48),
        big = love.graphics.newFont(p .. "fonts/unilight.ttf", 64),
    }

    fonts.bold = {
        small = love.graphics.newFont(p .. "fonts/unibold.ttf", 36),
        medium = love.graphics.newFont(p .. "fonts/unibold.ttf", 48),
        big = love.graphics.newFont(p .. "fonts/unibold.ttf", 64),
    }
    
    fonts.title = love.graphics.newFont(p .. "fonts/unibold.ttf", 128)

    return fonts
end

function Assets.loadImages()
    local images = {}

    --trail
    local canvas = love.graphics.newCanvas(64, 64)
    love.graphics.setCanvas(canvas)
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", canvas:getWidth(), canvas:getHeight() * .5, canvas:getHeight() * .5)
    love.graphics.setCanvas()
    images.trail = love.graphics.newImage( canvas:newImageData() )

    --

    return images
end

function Assets.loadSounds()
    local sounds = { ui = {} }

    sounds.ui.confirm1 = audio:newSource(p .. "sounds/ui/confirm1.wav", "static")
    sounds.ui.confirm2 = audio:newSource(p .. "sounds/ui/confirm2.wav", "static")



    return sounds
end

function Assets.loadShaders()
    local shaders = {}

    shaders.default = love.graphics.newShader(p .. "shaders/default.frag")

    shaders.vignette = love.graphics.newShader(p .. "shaders/vignette.fsh")

    shaders.values = {
        vignette = soft:new(0):to(1)
    }

    return shaders
end

--

function Assets.update(dt)

    local cos = math.cos( love.timer.getTime() * 10 )

    shaders.default:send("setting1", cos * .1 + 2)
    shaders.default:send("setting2", cos * .2 + 100)

    shaders.vignette:send("setting", 1 + shaders.values.vignette:get() * -.3)

end

--

function Assets.setVolume(volume, table)
    local table = table or sounds
    for k, v in pairs(table) do
        if v.volume then
            v:setVolume(volume)
        elseif type(v) == "table" then --keep searching
            Assets.setVolume(volume, v)
        end
    end
    Assets.volume = volume
end
function Assets.getVolume(volume)
    return Assets.volume
end

return Assets