version = "0.0.2"
client = true --required

io.stdout:setvbuf('no') --fixes print issues

--//////////////////////////////////--
--//-\\-//-[[- SETTINGS -]]-\\-//-\\--
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--

WWIDTH, WHEIGHT = 1920, 1080 --16/9 aspect ratio

debug = false --various debug utils
remote_debug = false --enables lovebird
local_debug = false --connects to localhost
nosound_debug = false --set volume to 0 from start
nofx_debug = false --disable effects and improve performance

for i = 2, 6 do
  if arg[i] == "-debug" then debug = true end
  if arg[i] == "-remote" then remote_debug = true end
  if arg[i] == "-local" then local_debug = true end
  if arg[i] == "-nosound" then nosound_debug = true end
  if arg[i] == "-nofx" then nofx_debug = true end
end

--//////////////////////////////////--
--//-\\-//-[[- INCLUDES -]]-\\-//-\\--
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--

local sharedpath = require("sharedpath")
function shared(path) return require(sharedpath .. path) end

local function lib(path) return require("lib." .. path) end
local function include(path) return require("include." .. path) end
local function reqclass(path) return require("include.classes." .. path) end
local function sharedclass(path) return shared("classes." .. path) end

--Libraries
utf8 = require "utf8"

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
Target = sharedclass          "target"
Bullet = sharedclass          "bullet"
Planet = sharedclass          "planet"

TurnManager = sharedclass     "turnmanager"
Turn = sharedclass            "turn"
Action = sharedclass          "action"

--
StateEngine = shared          "engine.state" --global engine
--
SimplePhysicsEngine = shared  "engine.simplephysics" --inherits from StateEngine -> custom functions
RadialPhysicsEngine = shared  "engine.radialphysics"

--UI components
HUD = reqclass                "ui.hud"
Chat = reqclass               "ui.chat"
TurnEditor = reqclass         "ui.turneditor"

Button = reqclass             "ui.button"



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
  highdpi = true,
  canvas = not nofx_debug
})

fixed:setRate( 1 / 30 ):setFunction(function(dt) love.fixedupdate(dt) end) --30 fps

event = lem:new()

--///////////////////////////////////--
--//-\\-//-[[- FUNCTIONS -]]-\\-//-\\--
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--

function love.load()

  --load assets
  Assets.load()
  fonts, images, sounds, shaders = Assets.fonts, Assets.images, Assets.sounds, Assets.shaders

  if nosound_debug then
    Assets.setVolume(0)
  else
    Assets.setVolume(.5)
  end

  --colors
  lue:setColor("main", { 200, 0, 0 })
  lue:setColor("back", { 255, 255, 255 })
  lue:setColor("mid", { 100, 100, 100, 100 })

  --transitions
  ease:add("sin", "math.sin(x * math.pi / 2)")

  --shaders
  if not nofx_debug then push:setShader( shaders.vignette ) end

  --create client
  network.init = include        "network.init"
  network.bindings = include    "network.bindings"

  client = network.init()
  network.bindings.init( client )
  client:connect()
  --/
  
  screen:setDimensions(push:getDimensions())
  
  state:push("scenes/connect")
  
end

function love.update(dt)
  
  if remote_debug then lovebird.update() end

  client:update()
  
  screen:update(dt)
  lue:update(dt)
  soft:update(dt)
  --trail:update(dt)
  --^ update manually for pause effect
  
  state:update(dt)

  --fixed timestep
  fixed:update(dt)

  --

  Assets.update(dt)

  network:update(dt)
  
end

function love.fixedupdate(dt)

  state:fixedupdate(dt)

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

function love.mousepressed(x, y, button)
  x, y = push:toGame(x, y)
  if not (x and y) then return true end

  return state.mousepressed(x, y, button)
end
function love.mousereleased(...) return state.mousereleased(...) end

function love.messagereceived(message)
  if type(message) == "string" then
    return state.messagereceived({ text = message, sender = 0 }) --id 0 stands for server
  else
    return state.messagereceived(message)
  end
end

--FIXME: quick hack
local oldpos, mx, my = love.mouse.getPosition, 0, 0
function love.mouse.getPosition()
  local x, y = oldpos()
  x, y = push:toGame(x, y)
  if not (x and y) then return mx, my end
  mx, my = x, y
  return x, y
end