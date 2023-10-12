
addpath(genpath('../TMSi_SAGA_matlab'))
addpath(genpath('./util'))

[EEGfileNameR]=uigetfile('*.Poly5');% select the Right player EEG
Path_filenameR=[pwd '/' EEGfileNameR];
[timeR,samplesR,TRIGGERindR,srR,channels_infoR,labelsR] = LoadTMSi(Path_filenameR);

Triger_data=samplesR(TRIGGERindR,:);
figure;
clf;
plot(timeR,Triger_data,'r.')


% Line 0: Key 0  (output = 255-2^0 = 255-1 =254)
% Line 1: Key 1  (output = 255-2^1 = 255-2 =253)
% Line 2: Key 2  (output = 255-2^2 = 255-4 =251)
% Line 3: Key 3  (output = 255-2^3 = 255-8 =247) middle key
% Line 4: Key 4  (output = 255-2^4 = 255-16 =239)
% Line 5: Key 5  (output = 255-2^5 = 255-32 =223)
% Line 6: Key 6  (output = 255-2^6 = 255-64 =191)
% Line 7: Key 7  (output = 255-2^7 = 255-128 =127)
% Line 8: Light Sensor 1 (Back light sensor) (output = 255-2^8 = -1)
% Line 9: Light Sensor 2 (White light sensor) (output = 255-2^9 = -257)
