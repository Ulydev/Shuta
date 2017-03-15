version = "0.0.2"
server = true --required

local sharedpath = require("sharedpath")
function shared(path) return require(sharedpath .. path) end

local function lib(path) return require("lib."..path) end
local function include(path) return require("include."..path) end
local function reqclass(path) return require("include.classes."..path) end
local function sharedclass(path) return shared("classes."..path) end

--Libraries
cmd = lib                           "lovecmd"

class = shared                      "lib.middleclass"

fixed = shared                      "lib.fixed"
pprint = shared                     "lib.pprint"



--Networking
sock = shared                       "lib.sock"
bitser = shared                     "lib.spec.bitser"

NetworkManager = reqclass           "networkmanager" --network manager (manages rooms/etc.)
Room = reqclass                     "room"
GameState = sharedclass             "gamestate"
GameSettings = reqclass             "gamesettings"

TurnManager = sharedclass           "turnmanager"
Turn = sharedclass                  "turn"
Action = sharedclass                "action"

network = NetworkManager:new()
network.init = require              "include.network.init"
network.bindings = require          "include.network.bindings"

log = require                       "include.log"



--Includes - Custom libraries
shared                              "helpers"



--Classes
--[[ Some classes are shared to avoid code redundancy,
as they share structs and some methods
(e.g. draw is client-specific)
]]--
Object = sharedclass                "object" --base class
DynamicObject = sharedclass         "dynamicobject" --updated by server
StaticObject = sharedclass          "staticobject" --not updated

Character = sharedclass             "character" --controlled by client
Target = sharedclass                "target"
Bullet = sharedclass                "bullet"
Planet = sharedclass                "planet"



--
BaseEngine = shared                "engine.engine" --global engine
--
SimplePhysicsEngine = shared        "engine.simplephysics" --inherits from BaseEngine -> custom functions
RadialPhysicsEngine = shared        "engine.radialphysics"



--

fixed:setRate( 1 / 30 ):setFunction(function(dt) love.fixedupdate(dt) end) --30 fps by default <-> sync client/server

include                             "commands" ( cmd ) --register commands
--

function love.load()
    cmd.load()

    server = network.init()

    log("Server started on port " .. server:getPort())

    network.bindings.init( server )

    log("Ready to operate!")

    --DEBUG:
    local spots = {
        { x = 0, y = -350 },
        { x = 0, y = 350 }
    }
    network:createRoom({
        name = "Regular",
        settings = { turnTimer = 8, turnLength = 2.5 },
        map = { spots = spots, objects = {
            StaticObject:new({ x = -300, y = -300, width = 100, height = 50 }),
            StaticObject:new({ x = -300, y = -250, width = 50, height = 50 }),

            StaticObject:new({ x = 200, y = -300, width = 100, height = 50 }),
            StaticObject:new({ x = 250, y = -250, width = 50, height = 50 }),

            StaticObject:new({ x = -300, y = 200, width = 50, height = 50 }),
            StaticObject:new({ x = -300, y = 250, width = 100, height = 50 }),

            StaticObject:new({ x = 250, y = 200, width = 50, height = 50 }),
            StaticObject:new({ x = 200, y = 250, width = 100, height = 50 }),

            StaticObject:new({ x = -50, y = -50, width = 100, height = 100 }),
        } }
    })
    network:createRoom({
        name = "Fast-paced",
        settings = { turnTimer = 3.5, turnLength = 1.5 },
        map = { spots = spots, objects = {
            StaticObject:new({ x = -300, y = -300, width = 100, height = 50 }),
            StaticObject:new({ x = -300, y = -250, width = 50, height = 50 }),

            StaticObject:new({ x = 200, y = -300, width = 100, height = 50 }),
            StaticObject:new({ x = 250, y = -250, width = 50, height = 50 }),

            StaticObject:new({ x = -300, y = 200, width = 50, height = 50 }),
            StaticObject:new({ x = -300, y = 250, width = 100, height = 50 }),

            StaticObject:new({ x = 250, y = 200, width = 50, height = 50 }),
            StaticObject:new({ x = 200, y = 250, width = 100, height = 50 }),

            StaticObject:new({ x = -50, y = -50, width = 100, height = 100 }),
        } }
    })
    network:createRoom({
        name = "Physics",
        settings = { turnTimer = 8, turnLength = 2.5 },
        engineType = "RadialPhysicsEngine",
        map = { spots = spots, objects = {
            Planet:new({ x = 0, y = 0, radius = 200 })
        } }
    })
    --[[
    network:createRoom({
        name = "Soccer (experimental)",
        settings = { turnTimer = 6, turnLength = 2.5 },
        engineType = "FootballEngine",
        map = { spots = spots, objects = {
            Planet:new({ x = 0, y = 0, radius = 250 })
        } }
    })
    --]]
    
  
end

function love.update(dt)
    cmd.update()

    server:update()
    network:update(dt)
end

function love.fixedupdate(dt)
    network:fixedupdate(dt)
end