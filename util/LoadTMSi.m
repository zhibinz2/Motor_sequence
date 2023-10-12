%% Local function
% https://www.mathworks.com/help/matlab/matlab_prog/local-functions-in-scripts.html
function [time,samples,TRIGGERind,sr,channels_info,labels] = LoadTMSi(Path_filename);
    % d = TMSiSAGA.Poly5.read([pwd '/L20220804-20220804T144725.DATA.Poly5']);
    d = TMSiSAGA.Poly5.read(Path_filename);

    samples=d.samples;
    sr=d.sample_rate;

    channels=d.channels;
    numbers=num2str([1:length(channels)]');
    labels=strings(length(channels),1);
    units=strings(length(channels),1);
    for i=1:length(channels);
        labels(i)=channels{i}.alternative_name;
        units(i)=channels{i}.unit_name;
    end
    channels_info=table(numbers,labels,units);

    % Create time stamps
    % num2str(d.time)
    time=[1/sr:1/sr:d.time]';

    % Plot channels of Key presses, photocells, EMG
    % look for TRIGGERS channel;
    TRIGGERind=find(labels=='TRIGGERS');
    % plot(samples(TRIGGERind,:),'ro');
    % unique(samples(TRIGGERind,:))
    % feedback from other = 251 (255-2^2); 
    % self key presses = 239 (255-2^4); 
    % stimulus photocell = 127 (255-2^7); 

    % BottonPres=samples(TRIGGERind,:)';
    % EEG=samples(1:32,:)';
end
