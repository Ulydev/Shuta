return function ()

    local connect_ip = local_debug and "localhost" or "server.shuta.ulydev.com"

    local client = sock.newClient(connect_ip, 8000)
    client:setSerialization(bitser.dumps, bitser.loads)
    return client
    
end