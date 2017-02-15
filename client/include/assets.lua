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
    fonts.big = love.graphics.newFont(p .. "fonts/unilight.ttf", 48)

    return fonts
end

function Assets.loadImages()
    local images = {}



    return images
end

function Assets.loadSounds()
    local sounds = {}



    return sounds
end

return Assets