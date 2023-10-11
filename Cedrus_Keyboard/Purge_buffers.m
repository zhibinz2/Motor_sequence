% Empty extra taps in the memory before the trial begin
i=1;
while i<100 % purge 50 key presses
    try
     [pressedL1, RBkeyL1]=readCedrusRB(deviceL, keymapL);% extract first key press  
     [pressedR1, RBkeyR1]=readCedrusRB(deviceR, keymapR);% extract first key press  
    catch
        % do nothing
    end
    i=i+1;
end