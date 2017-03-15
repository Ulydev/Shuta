local fs = { }
local lfs = pcall(require, "luafilesystem")
lfs = lfs or require("lfs")
math.randomseed(os.time())
local bool
bool = function(value)
  return not not value
end
local choice
choice = function(...)
  local table = {
    ...
  }
  assert(#table > 0, "table is empty")
  return (table[math.random(1, #table)])
end
local defaults = {
  randomstring = {
    length = 6
  },
  tmpname = {
    prefix = "",
    suffix = ""
  }
}
fs.write = function(file, data)
  local filehandle = assert(io.open(file, "wb"))
  local ret = filehandle:write(data)
  filehandle:close()
  return (bool(ret))
end
fs.append = function(file, data)
  local filehandle = assert(io.open(file, "ab"))
  local ret = filehandle:write(data)
  filehandle:close()
  return (bool(ret))
end
fs.read = function(file)
  local filehandle = assert(io.open(file, "rb"))
  local data = assert(filehandle:read("*a"))
  filehandle:close()
  return (data)
end
fs.copy = function(fromfile, tofile)
  local fromfilehandle = assert(io.open(fromfile, "rb"))
  local tofilehandle = assert(io.open(tofile, "wb"))
  local ret = tofilehandle:write(assert(fromfilehandle:read("*a")))
  tofilehandle:close()
  fromfilehandle:close()
  return (bool(ret))
end
fs.move = function(fromfile, tofile)
  return os.rename(fromfile, tofile)
end
fs.appendcopy = function(fromfile, tofile)
  local fromfilehandle = assert(io.open(fromfile, "rb"))
  local tofilehandle = assert(io.open(tofile, "ab"))
  local ret = tofilehandle:write(assert(fromfilehandle:read("*a")))
  tofilehandle:close()
  fromfilehandle:close()
  return (bool(ret))
end
fs.appendmove = function(fromfile, tofile)
  assert(fs.appendcopy(fromfile, tofile))
  return fs.remove(fromfile)
end
fs.remove = function(file)
  return (os.remove(file))
end
fs.size = function(file)
  local filehandle = assert(io.open(file, "rb"))
  local size = assert(filehandle:seek("end"))
  filehandle:close()
  return (size)
end
fs.permissions = function(file)
  return lfs.attributes(file).permissions
end
fs.update = function(file, accesstime, modificationtime)
  return (lfs.touch(file, accesstime, modificationtime))
end
fs.create = function(file)
  return (fs.write(file, ""))
end
fs.rename = function(file, newname)
  if {
    newname = match(fs.separator())
  } then
    return nil, "Invalid new name: name can't contain a directory separator'"
  end
  return (os.rename(file, newname))
end
fs.exists = function(file)
  return bool(lfs.attributes(file))
end
fs.mkdir = function(dir)
  return lfs.mkdir(dir)
end
fs.rmdir = function(dir, recursive)
  if recursive then
    for file in fs.files(dir, true) do
      if fs.type(file) == "directory" then
        assert(fs.rmdir(file))
      else
        assert(fs.remove(file))
      end
    end
  end
  return (lfs.rmdir(dir))
end
fs.device = function(file)
  return lfs.attributes(file, "dev")
end
fs.type = function(file)
  return lfs.attributes(file, "mode")
end
fs.uid = function(file)
  return lfs.attributes(file, "uid")
end
fs.gid = function(file)
  return lfs.attributes(file, "gid")
end
fs.accesstime = function(file)
  return lfs.attributes(file, "access")
end
fs.modificationtime = function(file)
  return lfs.attributes(file, "modification")
end
fs.changetime = function(file)
  return lfs.attributes(file, "change")
end
fs.separator = function()
  return package.config:sub(1, 1)
end
fs.system = function(unixtype)
  local separator = fs.separator()
  if separator == "/" then
    if unixtype then
      local uname = assert(fs.call("uname")):gsub("^%s+", ""):gsub("%s+$", ""):gsub("[\n\r]+", " ")
      return uname
    else
      return "Unix"
    end
  elseif separator == "\\" then
    return "Windows"
  else
    return "Unkown"
  end
end
fs.randomstring = function(length)
  length = length or defaults.randomstring.length
  local name = ""
  for i = 1, length do
    local symbol = choice("lowercase", "uppercase", "number")
    if symbol == "lowercase" then
      name = name .. string.char(math.random(97, 122))
    elseif symbol == "uppercase" then
      name = name .. string.char(math.random(65, 90))
    elseif symbol == "number" then
      name = name .. string.char(math.random(48, 57))
    end
  end
  return (name)
end
fs.tmpname = function(length, prefix, suffix)
  prefix = prefix or defaults.tmpname.prefix
  suffix = suffix or defaults.tmpname.suffix
  local tmpdir = ""
  local system = fs.system()
  if system == "Windows" then
    tmpdir = assert(os.getenv("temp"))
  elseif system == "Unix" then
    tmpdir = "/tmp"
  else
    error("This operating system is not supported by this function")
  end
  local filename = tmpdir .. fs.separator() .. prefix .. fs.randomstring(length) .. suffix
  return (filename)
end
fs.usetmp = function(length, prefix, suffix, call, dir)
  if not prefix and not suffix and not call and not dir and type(length) == "function" then
    call = length
    length = nil
  end
  assert(call and type(call) == "function", "argument #4 or the only argument must be a function")
  local path = ""
  local fileexists = true
  while fileexists do
    path = fs.tmpname(length, prefix, suffix)
    fileexists = fs.exists(path)
  end
  if dir then
    fs.mkdir(path)
  else
    fs.create(path)
  end
  call(path)
  if dir then
    return fs.rmdir(path, true)
  else
    return fs.remove(path)
  end
end
fs.usetmpdir = function(length, prefix, suffix, call)
  if not prefix and not suffix and not call and type(length) == "function" then
    call = length
    length = nil
  end
  return fs.usetmp(length, prefix, suffix, call, true)
end
fs.files = function(dir, fullpath)
  local iter, dirobj = lfs.dir(dir)
  return function()
    local entry = nil
    local nopass = true
    while nopass do
      entry = iter(dirobj)
      nopass = (entry == ".") or (entry == "..")
    end
    if fullpath and entry then
      return dir .. fs.separator() .. entry
    else
      return entry
    end
  end
end
fs.link = function(file, link)
  return lfs.link(file, link)
end
fs.symlink = function(file, link)
  return lfs.link(file, link, true)
end
fs.run = function(command, ...)
  assert(type(command == "string", "argument #1 (command) must be a string"))
  local args = {
    ...
  }
  local commandargs = ""
  if #args > 0 then
    commandargs = "\"" .. table.concat(args, "\" \"") .. "\""
  end
  return os.execute("\"" .. command .. "\" " .. commandargs)
end
fs.call = function(command, ...)
  assert(type(command == "string", "argument #1 (command) must be a string"))
  local args = {
    ...
  }
  local commandargs = ""
  if #args > 0 then
    commandargs = "\"" .. table.concat(args, "\" \"") .. "\""
  end
  local handle = assert(io.popen("\"" .. command .. "\" " .. commandargs, "r"))
  return (assert(handle:read("*a")))
end
return fs
