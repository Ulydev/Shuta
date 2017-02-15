return function ()

    local connect_ip = local_debug and "localhost" or "138.68.131.87" --TODO: don't hardcode IP

    local client = sock.newClient(connect_ip, 8000)
    client:setSerialization(bitser.dumps, bitser.loads)
    return client
    
end