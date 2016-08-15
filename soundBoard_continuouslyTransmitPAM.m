%non-stopping transmission of PAM through the sound board DAC
%The bits are organized in frames, with a preamble.

dt_setGlobalConstants %set global variables
global showPlots txBitStream tailLength preamble; %used variables

showPlots=0;
saveWavFile = 1; %use 1 to save one frame as a WAV file
outputWavFile = 'pam_transmit.wav';
%use the same data for all frames, to simplify BER estimation
temp=rand(Nbits,1); %random numbers ~[0,1]
txBitStream=temp>0.5; %bits: 0 or 1

%cannot send preamble like that because it has too large BW
preambleLength=length(preamble);
upsampledPreamble=zeros(1,preambleLength*L); %pre-allocate space
upsampledPreamble(1:L:end)=preamble; %complete upsampling operation

baud = Fs/L  %symbol rate (bauds)
gross_rate_bps=baud*b  %total rate (bps), information and overhead
net_rate_bps=gross_rate_bps*(S/(S+preambleLength+tailLength)) %infor.

%% Create the frame with preamble and data
%slice the bits into the symbol indices:
symbolIndicesTx = [ak_sliceBitStream(txBitStream, b) ...
    zeros(1,tailLength)]; %add the tail, always the first symbol
symbols=const(symbolIndicesTx+1); %random symbols
x=zeros(1,(S+tailLength)*L); %pre-allocate space
x(1:L:end)=symbols; %complete upsampling operation
%Add preamble
xbb=conv(htx,[upsampledPreamble x]);%convolution by shaping pulse
%modulate by carrier at wc rad:
n=0:length(xbb)-1; %"time" axis
s=xbb .* cos(wc*n); %transmitted signal
s=s(:); %use column vector
%ak_psd(s,Fs); pause
if saveWavFile ==1
    wavwrite(s,Fs,outputWavFile ); %write file with frame
    disp(['Wrote file ' outputWavFile])
end

%% Continuously playback frame
iteration=1; %track iteration number
while 1 %eternal loop. Break it with CTRL + C
    sound(s,Fs); %send to the sound board DAC, do not use soundsc
    iteration = iteration+1 %update counter
end