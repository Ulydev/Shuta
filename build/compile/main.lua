function love.load(args)
  
  io.stdout:setvbuf 'no'

  local fs = require "minifs"
  
  local filecount = 0

  local function compileFile( path )
    
    if fs.type( path ) == "directory" then
      local files = fs.files( path, true )
      local file = files()
      while file do
        compileFile( file )
        file = files()
      end
    elseif string.match( path, ".lua" ) and fs.type( path ) == "file" then
      fs.write( path, string.dump( loadstring( fs.read( path ) ) ) )
      filecount = filecount + 1
    end
    
  end

  local path = args and args[2] or "../release/tmp"
  compileFile( path )

  print("Successfully compiled " .. filecount .. " files in " .. path)

  love.event.quit()
  
end