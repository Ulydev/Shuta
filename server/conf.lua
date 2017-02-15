function love.conf(t)
  
  --disable all unnecessary modules
  t.modules.joystick = false
  t.modules.keyboard = false
  t.modules.mouse = false
  t.modules.touch = false
  t.modules.physics = false
  t.modules.graphics = false
  t.modules.audio = false
  t.modules.font = false
  t.modules.video = false
  t.modules.window = false

  t.window = nil
  
end