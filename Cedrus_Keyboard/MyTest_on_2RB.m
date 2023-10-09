clear

rb_840_keymap = [7, 3, 4, 1, 2, 5, 6, 0]; % /830 (DeviceL) /dev/ttyUSB0
rb_834_keymap = [7, 0, 1, 2, 3, 4, 5, 6]; % /844 (DeviceR) /dev/ttyUSB1

ports = serialportlist("available")

%    "/dev/ttyUSB1"    "/dev/ttyS0"    "/dev/ttyUSB0"

%% FOR RB 834/844 on the Right (DeviceR) /dev/ttyUSB1
deviceR = serialport('/dev/ttyUSB0',115200,"Timeout",0.02);
keymapR=rb_834_keymap;

%In order to identify an XID device, you need to send it "_c1", to
%which it will respond with "_xid" followed by a protocol value. 0 is
%"XID", and we will not be covering other protocols.
deviceR.flush()
write(deviceR,"_c1","char")
query_return = read(deviceR,5,"char");

%Next, we need to identify which XID model we connected to.
write(deviceR,"_d2","char")
deviceR_id = read(deviceR,1,"char");
write(deviceR,"_d3","char")
modelR_id = read(deviceR,1,"char");

%By default the pulse duration is set to 0, which is "indefinite".
%You can either set the necessary pulse duration, or simply lower the lines
%manually when desired.
setPulseDuration(deviceR, 1000)

%mh followed by two bytes of a bitmask is how you raise/lower output lines.
%Not every XID device supports 16 bits of output, but you need to provide
%both bytes every time.
write(deviceR,sprintf("mh%c%c", 255, 0), "char")
%% Right
disp("You have two seconds to press a key!")

pause(2)
tic
readKeypress(deviceR, keymapR)
readKeypress(deviceR, keymapR)
toc
%% FOR RB 830/840 on the Left (DeviceL) /dev/ttyUSB0
deviceL = serialport('/dev/ttyUSB1',115200,"Timeout",0.02);
keymapL=rb_840_keymap;
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
tic
readKeypress(deviceL, rb_840_keymap)
readKeypress(deviceL, rb_840_keymap)
toc


%% Psychtoolbox function CedrusResponseBox
CedrusResponseBox