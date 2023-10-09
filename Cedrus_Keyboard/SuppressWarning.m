%https://www.mathworks.com/help/matlab/matlab_prog/suppress-warnings.html
%suppress warning
% w = warning ('on','all');
% [pressedL1, RBkeyL1, portL1, stampL1]=readCedrusRB(deviceL, keymapL);
% warning(w)

% w = warning('query','last')

% id = w.identifier;
id = 'serialport:serialport:ReadWarning';
% lastwarn

warning('off',id)