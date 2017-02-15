return function ()

    local server = sock.newServer("*", 8000)
    server:setSerialization(bitser.dumps, bitser.loads)

    return server

end