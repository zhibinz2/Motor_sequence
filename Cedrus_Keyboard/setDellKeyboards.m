%% set keyboard
% Update the while loop
% [ keyIsDown, seconds, keyCode ] = KbCheck;
[keyboardIndices, productNames, allInfos] = GetKeyboardIndices
% Examine keyboards names and keyboardIndices
productNames';
% Examie keyboard device index
keyboardIndices';
% Show Keyboard names and device index side by side
strcat(productNames',' ------(',num2str(keyboardIndices'),' )')

% % Pick 'Dell Dell USB Entry Keyboard' as Left
% deviceNumberL=input('Pick the number for "Dell Dell USB Entry Keyboard" for player on the left:');% deviceNumberL=8;
% % Pick 'Dell KB216 Wired Keyboard' as right
% deviceNumberR=input('Pick the number for "Dell KB216 Wired Keyboard" for player on the right:');% deviceNumberR=9;

% deviceNumberL = keyboardIndices(find(contains(productNames, 'Dell Dell USB Entry Keyboard')));
% deviceNumberR = keyboardIndices(find(contains(productNames, 'Dell KB216 Wired Keyboard')));

deviceNumberL = keyboardIndices(find(ismember(productNames, 'Dell Dell USB Entry Keyboard')));
deviceNumberR = keyboardIndices(find(ismember(productNames, 'Dell KB216 Wired Keyboard')));