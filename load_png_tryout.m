rb_840_Im='./Pictures/rb840_layout.png';
left_hand20='./Pictures/left_hand20degree.png';
right_hand20='./Pictures/right_hand20degree.png';
display='./Pictures/display.png'

% screen setup
PsychDefaultSetup(2); 
Screen('Preference', 'SkipSyncTests', 1);
screenNum = max(Screen('Screens')); % set screen 
Screen('Preference','VisualDebugLevel',3);
% [w,rect] = Screen('OpenWindow',screenNum);
% slightly modified boilerplate -- non-fullscreen by default,
% and set the background color (no need for all the FillRects)
[w, rect] = Screen('OpenWindow', screenNum, [100 100 100], [0 0 400 400]);



% Activate for alpha
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% image presentation rectangles
% bigImSq = [0 0 500 500];
% [bigIm, xOffsetsigB, yOffsetsigB] = CenterRect(bigImSq, rect);
smImSq = [0 0 250 250];
[smallIm, xOffsetsigS, yOffsetsigS] = CenterRect(smImSq, rect);

% IMAGES
% sceneIm = './Pictures/rb840_layout.png';
objIm = './Pictures/display.png';
% sceneLoad = imread(sceneIm); 
[objLoad,map,alpha] = imread(objIm);
% texture1 = Screen('MakeTexture', w, objLoad);
objLoad(:, :, 4) = alpha;
texture2 = Screen('MakeTexture', w, objLoad);

% final textures for display
% scene = Screen('MakeTexture',w,sceneLoad); 
% object = Screen('MakeTexture',w,objLoad); 

% Image presentation
grey = [100 100 100];

Screen('FillRect',w,grey); 
Screen('Flip',w); 
WaitSecs(0.5);

Screen('FillRect',w,grey);
% Screen('DrawTexture', w, scene,[],bigIm); % draw the scene 
Screen('DrawTexture', w, texture2,[],smallIm); % draw the object 
% Screen('TransformTexture', w, object,[],smallIm); % draw the object 
Screen('Flip',w); 
WaitSecs(3);

Screen('CloseAll');