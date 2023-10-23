% This version is demostration of the framework for motor sequence learning task 
% Zhibin 10/09/23

% Clear the screen display and all variables in the workspace
sca; clc; close all; clear all; clearvars; 

%% set keyboards
% exp_dir  = pwd;
addpath Cedrus_Keyboard/
run setCedrusRB840.m % plug in the left RB pad first then the right RB pad
% Suppress Warning
id = 'serialport:serialport:ReadWarning';
warning('off',id)

% set the random number seed as the date of today in formate such as 20220505
seed=input('enter the date in format YYYYMMDD:');
rng(seed);

% Break and issue an error message if the installed Psychtoolbox is not
% based on OpenGL or Screen() is not working properly.
AssertOpenGL;

%% ########################################################################
try      % if anything went wrong, exit the display and show the error on the Command window
    
    % Here we call some default settings for setting up Psychtoolbox 
    PsychDefaultSetup(2);

    % Start with black screen
    % Removes the blue screen flash and minimize extraneous warnings.
    Screen('Preference', 'VisualDebugLevel', 0); % disable all visual alerts
    Screen('Preference', 'SkipSyncTests', 1); %  shorten the maximum duration of the sync tests to 3 seconds worst case
    Screen('Preference', 'SuppressAllWarnings', 1); %disable all output to the command window 
    % The use of “mirror mode”, or “clone mode”, where multiple displays show the
    % same content, will almost always cause  timing and performance problems.

    % Get the screen numbers. This gives us a number for each of the screens
    % attached to our computer. For help see: Screen Screens?
    screens = Screen('Screens');

    % Draw we select the maximum of these numbers. So in a situation where we
    % have two screens attached to our monitor we will draw to the external
    % screen. When only one screen is attached to the monitor we will draw to
    % this. For help see: help max
    screenNumber = max(screens);

    % Define black and white (white will be 1 and black 0). This is because 
    % luminace values are (in general) defined between 0 and 1.0
    % For help see: help WhiteIndex and help BlackIndex
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    white = [white white white];
    black = [black black black];
    % Initialize some other colors
    green = [0 1 0];
    red = [1 0 0];
    blue = [0 0 1];

    % Open an on screen window and color it black
    % For help see: Screen Openwindow?
    % This will draw on a black backgroud with a size of [0 0 800 600] or
    % full screen, and then return a window pointer windowPtr
    % [windowPtr, windowRect] = PsychImaging('Openwindow', screenNumber, black, [0 0 800 600]); 
    [windowPtr, windowRect] = PsychImaging('Openwindow', screenNumber, black); % show on a full screen

        % Get the size of the on screen windowPtr in pixels
    % For help see: Screen windowSize?
    [screenXpixels, screenYpixels] = Screen('windowSize', windowPtr);
    buttom_radius=screenYpixels/35;

    % Get the centre coordinate of the window in pixels
    % For help see: help RectCenter
    [xCenter, yCenter] = RectCenter(windowRect); 

    % Enable alpha blending for anti-aliasing
    % For help see: Screen BlendFunction?
    % Also see: Chapter 6 of the OpenGL programming guide
    Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('ColorRange', windowPtr, 1, -1,1);

    % Set text display options for operating system other than Linux.
    % For help see: Screen TextFont?
    if ~IsLinux
        Screen('TextFont', windowPtr, 'Arial');
        Screen('TextSize', windowPtr, 18);
    end

    % Retreive the maximum priority number
    topPriorityLevel = MaxPriority(windowPtr) ; 
    % topPriorityLevel0 = MaxPriority(windowPtr0); 
    % set Priority once at the start of a script after setting up onscreen window.
    Priority(topPriorityLevel);

    % Hide the cursor of the mouse in the display*****************
    % Get handles for all virtual pointing devices, aka cursors:
    typeOnly='masterPointer'; 
    mice = GetMouseIndices(typeOnly);  
    HideCursor(windowPtr,mice);


    % IMAGES
    objIm = './Pictures/display.png';
    [objLoad,map,alpha] = imread(objIm);
    % texture1 = Screen('MakeTexture', w, objLoad);
    objLoad(:, :, 4) = alpha;
    texture2 = Screen('MakeTexture', windowPtr, objLoad);

    % Measure the vertical refresh rate of the monitor
    ifi = Screen('GetFlipInterval', windowPtr);
    % Check if ifi=0.0167 second (60Hz)
    if round(1/ifi)~=60
      error('Error: Screen flash frequency is not set at 60Hz.');    
    end


    %% Set size of the squares for photocell ##############################
    PhotosensorSize=60; 
    % Positions of the photocell at he bottom rihgt corner of the screen
    LeftUpperSquare = [0 0 PhotosensorSize PhotosensorSize];
    RightUpperSquare= [screenXpixels-PhotosensorSize 0 screenXpixels PhotosensorSize];

    %% Numer of frames to wait in order to achieve good timing. 
    % Note: the use of wait frames is to show a generalisable coding. 
    % For example, by using waitframes = 2 one would flip on every other frame. See the PTB
    % documentation for details. In what follows we flip every frame. 
    % In order to flip with feedback at 50 Hz
    % We have to filp every (1/50)/ifi frames or 1/50 ms/frame
    waitframes=2;

    %% Set trial conditions ****************************************************
    conditions = [1 2];
    
    % Block & Trial number of the experiment **********************************
    % number of taps per trial/condition
    numTaps=24; 
    % number of trials per block
    numTrials=4;
    % number of blocks/repeats
    numBlock=12;
    % total trial number
    numtotal=numTrials*numBlock; 
    % num of conditions in the experiment
    numconditions=length(conditions);

    % Mean stimulus interval for 1.3Hz pacing (750ms per tap)
    MeanTapInterval13Hz=0.75; % second
    NumFramesInterval13Hz=round(MeanTapInterval13Hz/(ifi*waitframes)); % how many frames in each tapping interval of 750 ms
    numFrames = NumFramesInterval13Hz*numTaps 

    % condition 1-2 (paced the frist 30 taps, set the rest of the frames with value zeros)
    Showframes=[1:NumFramesInterval13Hz:NumFramesInterval13Hz*numTaps]; % showing the stimulus every 750 milliseconds
    numFrames200ms=round(0.2/(ifi*waitframes)); % how many frames in 200 ms

    % **********************************Block & Trial number of the experiment

    %% Tell subject to start
    instructionStart=['Press any key to start!']; 
    DrawFormattedText2(instructionStart,'win',windowPtr,...
        'sx','center','sy','center','xalign','center','yalign','center','baseColor',white);
    Screen('Flip',windowPtr);
    % hit a key to continue
    KbStrokeWait;
    % Flip Black Screen
    Screen('Flip',windowPtr);

    % get a timestamp by flip a black screen at the start of resting 
    vbl = Screen('Flip', windowPtr);

    %%
    for block=1:numBlock
        for t=1:numTrials 
            % purge RB key press buffer 
            run Purge_buffers.m

            % initalize the while loop for each trial
            n=1;
            while n < numFrames % either one reach 600 taps  @@@@@@@@
                tic
                % If esc is pressed, break out of the while loop and close the screen
                [keyIsDown, keysecs, keyCode] = KbCheck;
                if keyCode(KbName('escape'));
                    Screen('CloseAll');
                    break;
                end
                % If F1 is pressed, exit and continue to the next condition
                if keyCode(KbName('F1'));
                    n=numFrames;
                end

                % Response keys layout Design*************************************************
                % show buttoms and two hands
                Screen('DrawTexture', windowPtr, texture2,[],windowRect); % draw the object 
                % show center buttom
                Screen('FrameOval', windowPtr,white, [xCenter-buttom_radius yCenter-buttom_radius xCenter+buttom_radius yCenter+buttom_radius],1,1);

                % Show stimulus
                if any(Showframes(:) == n)
                    previous_stimulus_frame = n;
                    if previous_stimulus_frame < Showframes(end)
                    next_stimulus_frame = Showframes(find(Showframes==previous_stimulus_frame)+1);
                    Screen('DrawDots', windowPtr, [xCenter;yCenter], buttom_radius-2, white, [0 0], 2); 
                    Screen('FillRect', windowPtr, white, LeftUpperSquare); % photocell
                    Screen('FillRect', windowPtr, white, RightUpperSquare); % photocell
                    end
                end

                % Detect response and show feedback
                % Read button press from the right cubicle
                try
                    % Right player
                    % initialize / reset variables
                    pressedR1=[]; RBkeyR1=[];
                    [pressedR1, RBkeyR1]=readCedrusRB(deviceR, keymapR);
                catch
                    % do nothing; 
                end

                if pressedR1 == 1 % at least one key press detected in the frist two events of the previous buffer
                    if RBkeyR1==4
                        if ((n - previous_stimulus_frame) < 0.5*numFrames200ms) || ((next_stimulus_frame - n)< 0.5*numFrames200ms)% 100ms
                            Screen('DrawDots', windowPtr, [xCenter;yCenter], buttom_radius-2, green, [0 0], 2); 
                        elseif (((n - previous_stimulus_frame) > 0.5*numFrames200ms) && ((n - previous_stimulus_frame) < numFrames200ms) ) || ( ...
                                ((next_stimulus_frame - n) > 0.5*numFrames200ms) && ((next_stimulus_frame - n) < numFrames200ms)) % 100-200ms
                            Screen('DrawDots', windowPtr, [xCenter;yCenter], buttom_radius-2, blue, [0 0], 2); 
                        elseif (((n - previous_stimulus_frame) > numFrames200ms) && ((n - previous_stimulus_frame) < 1.5*numFrames200ms) ) || ( ...
                                ((next_stimulus_frame - n) > numFrames200ms) && ((next_stimulus_frame - n) < 1.5*numFrames200ms)) % 200-300ms
                            Screen('DrawDots', windowPtr, [xCenter;yCenter], buttom_radius-2, red, [0 0], 2); 
                        end
                    end
                end

                %% Flip to the screen
                vbl  = Screen('Flip', windowPtr, vbl + (waitframes -0.5) * ifi);
                % update n
                n = n+1;
            end
        end
    end




    %% Show The End
    TheEnd = ['The End. \nThank you!'];
    DrawFormattedText2(TheEnd,'win',windowPtr,...
        'sx','center','sy', 'center','xalign','center','yalign','top','baseColor',white);
    vbl=Screen('Flip',windowPtr);
    WaitSecs(3)
    % hit a key to continue
    KbStrokeWait;     
    
    %*************************************
    Priority(0);   
    sca;

catch
    sca;
    psychrethrow(psychlasterror);
end  


%% save data
cd ./Exp_data
filename=[num2str(seed) '.mat'];
save(filename);
