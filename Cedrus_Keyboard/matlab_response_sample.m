%This is a basic sample showing how to collect keypresses from and send
%digital output via an RB-x40 or a Lumina 3G

%An exhaustive list of all commands written to the serial port in this
%example see https://cedrus.com/support/xid/commands.htm

%The key ...............................                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   values returned by XID firmware dont necessarily match the
%physical button you'd expect, so these are needed to translate them into
%something more straightforward. These arrays simply map the keys by using
%the returned value (adjusted, as MatLab array are indexed from 1) as the
%index. The resulting values are counted from 0 for the sake of
%consistency with other Cedrus software (so 0 in the array refers to the
%first button). -1 indicates an error of some sort, as the device shouldn't
%return that key value.
%For example, a key value of 3 returned from a 540 means that button 2 was
%pressed (seen as 1 in the array).
rb_540_keymap = [-1, 0, -1, 1, 2, 3, 4, -1]; % /530-
rb_740_keymap = [-1, 0, 1, 2, 3, 4, 5, 6]; %/730
rb_840_keymap = [7, 3, 4, 1, 2, 5, 6, 0]; % /830
rb_834_keymap = [7, 0, 1, 2, 3, 4, 5, 6]; %/844
lumina_keymap = [-1, 0, 1, 2, 3, 4, -1, -1];
keymap = [];

clear device

ports = serialportlist("available");
for p = 1:length(ports)
    device = serialport(ports(p),115200,"Timeout",1);
    %In order to identify an XID device, you need to send it "_c1", to
    %which it will respond with "_xid" followed by a protocol value. 0 is
    %"XID", and we will not be covering other protocols.
    device.flush()
    write(device,"_c1","char")
    query_return = read(device,5,"char");
    if length(query_return) > 0 && query_return == "_xid0"
        break
    end
end

%Next, we need to identify which XID model we connected to.
write(device,"_d2","char")
device_id = read(device,1,"char");
write(device,"_d3","char")
model_id = read(device,1,"char");

if device_id == '2'
    if model_id == '1'
        keymap = rb_540_keymap;
    elseif model_id == '2'
        keymap = rb_740_keymap;
    elseif model_id == '3'
        keymap = rb_840_keymap;
    elseif model_id == '4'
        keymap = rb_834_keymap;
    else
        disp("An unknown RB model was detected. Very strange.")
        return
    end
elseif device_id == '0'
    keymap = lumina_keymap;
else
    disp("Couldnt find an RB or a Lumina. Exiting.")
    return
end

%Keep in mind that pressing a button returns two keypresses: one for press,
%and one for release.
disp("You have two seconds to press a key!")

pause(2)

readKeypress(device, keymap)
readKeypress(device, keymap)

disp("Raising all output lines for 1 second.")

%By default the pulse duration is set to 0, which is "indefinite".
%You can either set the necessary pulse duration, or simply lower the lines
%manually when desired.
setPulseDuration(device, 1000)

%mh followed by two bytes of a bitmask is how you raise/lower output lines.
%Not every XID device supports 16 bits of output, but you need to provide
%both bytes every time.
write(device,sprintf("mh%c%c", 255, 0), "char")

pause(1)

clear device

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

function setPulseDuration(device, duration)
%mp sets the pulse duration on the XID device. The duration is a four byte
%little-endian integer.
    write(device, sprintf("mp%c%c%c%c", getByte(duration,1),...
        getByte(duration,2), getByte(duration,3),...
        getByte(duration,4)), "char")
end

%Helper function to isolate parts of an integer.
function byte = getByte(val, index)
    byte = bitand(bitshift(val,-8*(index-1)), 255);
end
