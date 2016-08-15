%Write a WAV file with PAM signal. Then later play it with Audacity,
%on loop, through the sound board DAC
%The bits are organized in frames, with a preamble.

dt_setGlobalConstants %set global variables
global showPlots txBitStream tailLength preamble; %used variables
showPlots=0;

outputWavFile = 'pam_transmit.wav';

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
wavwrite(s,Fs,outputWavFile ); %write file with frame
disp(['Wrote file ' outputWavFile])
