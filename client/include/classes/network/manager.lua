local Class = class('NetworkManager')

function Class:initialize(args)
  
    self.room = nil
    self.localIndex = nil

end

--localIndex

function Class:setLocalData(data)
    self.localIndex = data.id or self.localIndex
    self.localName = data.name or self.localName
end

function Class:getLocalIndex()
    return self.localIndex
end

function Class:getLocalName()
    return self.localName
end

--roomList

function Class:setRoomList(roomList)
    self.roomList = roomList
end

function Class:getRoomList()
    return self.roomList
end

--room

function Class:setRoom(room)
    self.room = room
end

function Class:getRoom()
    return self.room
end

--

return Class