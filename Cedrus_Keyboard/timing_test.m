clear
rb_740_keymap = [-1, 0, 1, 2, 3, 4, 5, 6];
keymap=rb_740_keymap; 

ports = serialportlist("available")



deviceL = serialport('/dev/ttyUSB0',115200,"Timeout",0.0001);
% deviceL = serialport('/dev/ttyUSB0',115200,"Timeout",0.003);
% deviceL = serialport('/dev/ttyUSB0',921600,"Timeout",0.0001);

tic
k = read(deviceL,12,"char") % if no key pressed or release, k will be empty
% read(dev,6,"char") is standard, it reads one key press or one key release each call
% read(dev,12,"char") is standard, it reads two events (either key press or release) each call
toc
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
key = int8(respInfo(3) + respInfo(2)*2 + respInfo(1)*4); % which key
RBkey=keymap(key+1)% which key 
pressed = respInfo(4) % pressed or released