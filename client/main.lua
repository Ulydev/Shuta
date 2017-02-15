io.stdout:setvbuf('no') --fixes print issues
utf8 = require "utf8"
client = true --required

--//////////////////////////////////--
--//-\\-//-[[- SETTINGS -]]-\\-//-\\--
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--

WWIDTH, WHEIGHT = 1920, 1080 --16/9 aspect ratio

debug = true
remote_debug = false

--//////////////////////////////////--
--//-\\-//-[[- INCLUDES -]]-\\-//-\\--
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--

local shared = require "./../shared.require"

local function lib(path) return require("lib."..path) end
local function include(path) return require("include."..path) end
local function reqclass(path) return require("include.classes."..path) end
local function sharedclass(path) return shared("classes."..path) end

--Libraries
push = lib                    "push"
screen = lib                  "shack" --Screen effects (shake, rotate, shear, scale)
lem = lib                     "lem" --Events
lue = lib                     "lue" --Hue
state = lib                   "stager" --Scenes and transitions
audio = lib                   "wave" --Audio
trail = lib                   "trail" --Trails
soft = lib                    "soft" --Lerp
ease = lib                    "easy" --Easing

gamera = lib                  "gamera" --Camera
class = shared                "lib.middleclass"

fixed = shared                "lib.fixed"
pprint = shared               "lib.pprint"



--Networking
sock = shared                 "lib/sock"
bitser = shared               "lib/spec/bitser"

NetworkManager = reqclass     "network.manager"
Room = reqclass               "network.room"
GameState = sharedclass       "gamestate"

network = NetworkManager:new()
network.init = include        "network.init"
network.bindings = include    "network.bindings"



--Includes - Custom libraries
Input = include               "input"
shared                        "helpers"

--Assets
Assets = include              "assets"



--Classes
Object = sharedclass          "object" --base class
DynamicObject = sharedclass   "dynamicobject" --updated by server
StaticObject = sharedclass    "staticobject" --not updated

Character = sharedclass       "character"

HUD = reqclass                "hud"
Chat = reqclass               "chat"

TurnManager = sharedclass     "turnmanager"
Turn = sharedclass            "turn"
Action = sharedclass          "action"



--Debug
if remote_debug then
  lovebird = require "debug.lovebird"
  lovebird.whitelist = nil
end

--///////////////////////////////--
--//-\\-//-[[- SETUP -]]-\\-//-\\--
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--

local os = love.system.getOS()

phoneMode = (os == "iOS" or os == "Android") and true or false --handles mobile platforms
fullscreenMode = phoneMode and true or false --enables fullscreen if on mobile

local windowWidth, windowHeight = love.window.getDesktopDimensions()

if fullscreenMode then
  RWIDTH, RHEIGHT = windowWidth, windowHeight
else
  RWIDTH = windowWidth*.4 RHEIGHT = windowHeight*.4
end

push:setupScreen(WWIDTH, WHEIGHT, RWIDTH, RHEIGHT, {
  fullscreen = fullscreenMode,
  resizable = not phoneMode,
  highdpi = true
})

fixed:setRate( 1 / 30 ):setFunction(love.fixedupdate) --30 fps

event = lem:new()

--///////////////////////////////////--
--//-\\-//-[[- FUNCTIONS -]]-\\-//-\\--
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--

function love.load()

  --load assets
  fonts, images, sounds = Assets.load()
  love.graphics.setFont(fonts.small)

  --lib config
  lue:setColor("main", { 200, 0, 0 })
  lue:setColor("back", { 255, 255, 255 })
  ease:add("sin", "math.sin(x * math.pi / 2)")

  --create client
  client = network.init()
  network.bindings.init( client )
  client:connect()
  
  screen:setDimensions(push:getDimensions())
  
  state:push("scenes/connect")
  
end

function love.update(dt)
  
  if remote_debug then lovebird.update() end

  client:update()
  
  screen:update(dt)
  lue:update(dt)
  soft:update(dt)
  trail:update(dt)
  
  state:update(dt)

  --fixed timestep
  fixed:update(dt)
  
end

function love.draw()
  
  push:apply("start")
  screen:apply()
  
  state:draw()
  
  push:apply("end")
  
end

if not phoneMode then
  function love.resize(w, h)
    return push:resize(w, h)
  end
end

function love.keypressed(...) return state.keypressed(...) end
function love.keyreleased(...) return state.keyreleased(...) end
function love.textinput(...) return state.textinput(...) end
function love.fixedupdate(...) return state.fixedupdate(...) end
function love.mousepressed(...) return state.mousepressed(...) end
function love.mousereleased(...) return state.mousereleased(...) end