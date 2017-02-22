local Class = class("GameSettings")

local defaultGameSettings = shared "default.gamesettings"

function Class:initialize(args)

    --first populate default fields...
    table.populate(self, defaultGameSettings)

    --then use args
    if args then table.populate(self, args) end

    return self
end

function Class:serialize()
    return { --TODO: add every attribute
        maxClients = self.maxClients,
        playingClients = self.playingClients,
        maxTurns = self.maxTurns,
        turnLength = self.turnLength,
        turnTimer = self.turnTimer
    }
end

return Class