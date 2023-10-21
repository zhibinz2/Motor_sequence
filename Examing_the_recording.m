addpath(genpath('../TMSi_SAGA_matlab'))
addpath(genpath('./util'))

clear
[EEGfileNameR]=uigetfile('*.Poly5');% select the Right player EEG
Path_filenameR=[pwd '/' EEGfileNameR];
[timeR,samplesR,TRIGGERindR,srR,channels_infoR,labelsR] = LoadTMSi(Path_filenameR);

cd ./Recordings_test/
load('20231016R.mat')

%% Processing button presses from Trigger channel
TriggersR=samplesR(TRIGGERindR,:)';valuesR=unique(TriggersR)'

% Check if values are as expected
% ([valuesL] ==[0 119 127 183 191 247 255])
% ([valuesR] ==[0 119 127 183 191 247 255])

figure;
clf;
plot(timeR,Triger_dataR,'r.')

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

% ScreenSize=get(0,'MonitorPositions');
% FigureXpixels=ScreenSize(3);FigureYpixels=ScreenSize(4);
% figure('units','pixels','position',[0 0 FigureXpixels/2 FigureYpixels/4]);

PresIndR=unique(find(TriggersR == 253)); 

figure('units','normalized','outerposition',[0 0 1 0.3]);
plot(PresIndR,ones(1,length(PresIndR)),'bo'); % look at the above Index (one press produced several indices)

% determine a threshold of numbers of frames in the button press interval
threshold = 1*1.5; % interval larger than 1 consecutive samples

BottonPresTimeIndR=PresIndR(find([0 diff(PresIndR')]>threshold)); % exact index of key press onset in datatimes (reduce several indices into one)
% create a time series that assign botton presses as 1, all other as 0
BottonPresTimeR01=zeros(size(timeR));
BottonPresTimeR01(BottonPresTimeIndR)=1;
figure('units','normalized','outerposition',[0 0 1 0.3]);
plot(BottonPresTimeR01,'b.')
numPresR=sum(BottonPresTimeR01) % num of button presses



%% Processing photocell from Aux channel
% look for the second ISO aux channel for the photocell 
ISOauxindR=find(channels_infoR.labels=='ISO aux');


% examine the Right
figure('units','normalized','outerposition',[0 0 1 0.3]);
subplot(2,1,1);
plot(samplesR(ISOauxindR(1),:),'r'); title('ISOauxind(1)')%  ISO aux = analog
subplot(2,1,2);
plot(samplesR(ISOauxindR(2),:),'b'); title('ISOauxind(2)')
% select a good one
Photocell_R=samplesR(ISOauxindR(1),:)';
Photocell_R=samplesR(ISOauxindR(1),:)'.*-1;
Photocell_R=samplesR(ISOauxindR(2),:)';

% for photocell
% view the time course of photocell signals
figure('units','normalized','outerposition',[0 0 1 0.3]);
plot(Photocell_R);xlabel('time');ylabel('photocell signal');
% plot EEG on top
% hold on; plot(time,samples(2:33,:)'); % it zoom out the phtocell amplitude, too small to see

% click and select the start and end point for peak extraction (optional)
[x, y] = ginput(2); % read two mouse clicks on the plot % x were index, y were real values
Startpoint=round(x(1));Endpoint=round(x(2)); % Startpoint and Endpoint are sample number or index in time
hold on;xline(x(1),'r');xline(x(2),'r');hold off;

% replace the beginning and end with baseline value (optional)
Photocell(1:Startpoint)=mean(y);Photocell(Endpoint:end)=mean(y); % plot(Photocell');
plot(time,Photocell,'b'); 

% Examine peaks detection in analog1
Halfhigh1=3/4*(max(Photocell_R)-min(Photocell_R)); % value for 'MinPeakProminence'
% Check if need to adjust the Halfhigh cutoff
close;figure('units','normalized','outerposition',[0 0 1 0.3]);
findpeaks(Photocell_R,1:length(timeR),'MinPeakProminence',Halfhigh1,'Annotate','extents');
yline(Halfhigh1,'m','MinPeakProminence');

% locate the trial sessions % pks=value of the peak % locs=time of the peak
[pksR,locsR] = findpeaks(Photocell_R,1:length(timeR),'MinPeakProminence',Halfhigh1,'Annotate','extents');
% 12 blocks *230 taps = 2760

% examine pks and locs (both are values of analog1data and datatimes, not indices)
% i=1;
% find(Photocell==pks(i)) % return the index of peak in time
% find(datatimes==locs(i)) % return the same "index" in datatimes (ie, i=1, index=4226)
% so, infer from above, beacause the above "find values" for the same "index" works
% pks are values in analog1data
% locs are values in datatimes ((ie, i=1, value=4225))

% figure;plot(locs,'bo');
% figure;bar(locs);
% figure;plot(pks,'bo');
% figure;bar(pks);
% figure;plot(locs,pks,'bo');ylim([min(analog1data) max(analog1data)]);

% locsDurations=diff(locs);% time durations between peaks
% close;figure;
% plot(locsDurations,'ro');% look at distribution of these durations   
% xlabel('each peak');ylabel('locsDurations = Between-peaks time duration (ms)');
% Lowcutoff=5*mean(locsDurations);% cutoff standard of the between-peak duarations to separate between trials
% Highcutoff=180*mean(locsDurations);
% hold on; yline(Lowcutoff,'m--','lowcut');hold off; % examine the cutoff line
% hold on; yline(Highcutoff,'m--','highcut');hold off;

