clear

rb_740_keymap = [-1, 0, 1, 2, 3, 4, 5, 6]; %/730

ports = serialportlist("available")

% "/dev/ttyS0"    "/dev/ttyUSB0"

%% FOR RB 730/740 on the Left (DeviceL) /dev/ttyUSB0
deviceL = serialport('/dev/ttyUSB0',115200,"Timeout",0.02);
keymapR=rb_740_keymap;

%In order to identify an XID device, you need to send it "_c1", to
%which it will respond with "_xid" followed by a protocol value. 0 is
%"XID", and we will not be covering other protocols.
deviceL.flush()
write(deviceL,"_c1","char")
query_return = read(deviceL,5,"char");

%Next, we need to identify which XID model we connected to.
write(deviceL,"_d2","char")
deviceL_id = read(deviceL,1,"char");
write(deviceL,"_d3","char")
modelL_id = read(deviceL,1,"char");

%By default the pulse duration is set to 0, which is "indefinite".
%You can either set the necessary pulse duration, or simply lower the lines
%manually when desired.
setPulseDuration(deviceL, 1000)

%mh followed by two bytes of a bitmask is how you raise/lower output lines.
%Not every XID device supports 16 bits of output, but you need to provide
%both bytes every time.
write(deviceL,sprintf("mh%c%c", 255, 0), "char")

%% Left
disp("You have two seconds to press a key!")

pause(2)
readKeypress(deviceL, rb_740_keymap)
readKeypress(deviceL, rb_740_keymap)


%% Psychtoolbox function CedrusResponseBox
CedrusResponseBox