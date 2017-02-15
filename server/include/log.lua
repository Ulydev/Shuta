return function(message, level)
    if not level then
        print(message)
    elseif level == 1 then
        print(message)
        --TODO: save to log file
    end
end