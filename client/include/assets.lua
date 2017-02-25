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
    fonts.title = love.graphics.newFont(p .. "fonts/unilight.ttf", 128)

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
    local sounds = {}



    return sounds
end

return Assets