
addpath(genpath('../TMSi_SAGA_matlab'))

[EEGfileNameR]=uigetfile('*.Poly5');% select the Right player EEG
Path_filenameR=[pwd '/' EEGfileNameR];
[timeR,samplesR,TRIGGERindR,srR,channels_infoR,labelsR] = LoadTMSi(Path_filenameR);