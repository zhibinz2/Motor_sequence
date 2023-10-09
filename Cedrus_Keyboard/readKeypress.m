function readKeypress(dev, keymap)
    k = read(dev,6,"char");
    if isempty(k)
        return
    end
    
    stamp = typecast(int8(k(3:6)),'int32');
    
    %Convert the bits to an array
    respInfo = logical(dec2bin(k(2))-'0');
    %Pad out the array with zeroes
    respInfo = [zeros(1, 8-length(respInfo)), respInfo];
    
    %Here is how the response packet breaks down:
    % The first byte is simply the letter “k”, lower case
    % The second byte consists is divided into the following bits:
    %  Bits 0-3 store the port number.
    %  Bit 4 stores whether the key was pressed (1) or released(0)
    %  Bits 5-7 indicate which push button was pressed.
    key = int8(respInfo(3) + respInfo(2)*2 + respInfo(1)*4);
    pressed = respInfo(4);
    port = respInfo(8) + respInfo(7)*2 + respInfo(6)*4 + respInfo(5)*8;
    
    fprintf("Key: %d\n", keymap(key+1))
    fprintf("Pressed: %d\n", pressed)
    fprintf("Port: %d\n", port)
    fprintf("Timestamp: %d\n\n",stamp)
end