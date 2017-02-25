version = "0.0.1"
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



StateEngine = shared                "engine.state" --global engine
PhysicsEngine = shared              "engine.physics" --inherits from StateEngine -> custom functions



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
    for i = 1, 3 do
        local name
        if i == 1 then name = "Regular" end
        if i == 2 then name = "Fast-paced" end
        if i == 3 then name = "Slow-paced" end
        network:createRoom({ name = name })
    end
  
end

function love.update(dt)
    cmd.update()

    server:update()
    network:update(dt)
end

function love.fixedupdate(dt)
    network:fixedupdate(dt)
end