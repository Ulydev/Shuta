local Assets = {}
Assets.__index = Assets

Assets.path = "assets/"
local p = Assets.path

function Assets.load()
    return Assets.loadFonts(), Assets.loadImages(), Assets.loadSounds()
end

function Assets.loadFonts()
    local fonts = {}

    fonts.small = love.graphics.newFont(p .. "fonts/unilight.ttf", 36)
    fonts.medium = love.graphics.newFont(p .. "fonts/unilight.ttf", 48)
    fonts.big = love.graphics.newFont(p .. "fonts/unilight.ttf", 64)
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