server = true --required

shared = require "./../shared.require"

local function lib(path) return require("lib."..path) end
local function include(path) return require("include."..path) end
local function reqclass(path) return require("include.classes."..path) end
local function sharedclass(path) return shared("classes."..path) end

--Libraries
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



--

fixed:setRate( 1 / 30 ):setFunction(love.fixedupdate)

--

function love.load()

    server = network.init()

    log("Server started on port " .. server:getPort())

    network.bindings.init( server )

    log("Ready to operate!")

    --DEBUG FIXME:
    for i = 1, 3 do
        network:createRoom()
    end
  
end

function love.update(dt)
    server:update()
    network:update(dt)
end

function love.fixedupdate(dt)
    network:fixedupdate(dt)
end