% IMPORTANT: the signal generated with this script seems to have
% more distortion than the one using Audacity to playback in loop
% a wav file. Suggestion: use the script below instead of this:
%soundBoard_savePAMFrameToTransmitWithAudacity.m

%transmission of PAM through the sound board DAC
%The bits are organized in frames, with a preamble.

maximumNumberOfIterations = 100; %avoid an eternal loop

%% Invoke script to generate a segment (frame) of PAM signal
soundBoard_savePAMFrameToTransmitWithAudacity

%% Continuously playback frame
iteration=1; %track iteration number
while iteration < maximumNumberOfIterations  %Can break loop with CTRL + C
    sound(s,Fs); %send to the sound board DAC, do not use soundsc
    iteration = iteration+1 %update counter
end