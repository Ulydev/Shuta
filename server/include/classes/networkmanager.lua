local Class = class("NetworkManager")

function Class:initialize()
  self.rooms = {}

  return self
end

function Class:createRoom(args)
    args.id = self:getRoomCount() + 1
    local room = Room:new( args )
    self.rooms[room.id] = room
    return room.id
end

function Class:getRoomList()
    local rooms = {}
    for id, room in pairs( self:getRooms() ) do
        table.insert(rooms, room:serializeList())
    end
    return rooms
end

function Class:getRooms()
    return self.rooms
end

function Class:getRoom(roomId)
    return roomId and self.rooms[roomId] or nil
end

function Class:getRoomCount() --TODO: check if there are closed rooms (room = nil)
    return #self:getRooms()
end

--

function Class:update(dt)
    for id, room in pairs(self.rooms) do
        room:update(dt)
    end
end

function Class:fixedupdate(dt)
    for id, room in pairs(self.rooms) do
        room:fixedupdate(dt)
    end
end

return Class