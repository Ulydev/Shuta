return function ()

    local client = sock.newClient("localhost", 8000)
    client:setSerialization(bitser.dumps, bitser.loads)
    return client
    
end