%set global constants
global Fs M S b L const showPlots htx hrx ...
    wc useQAM delayInSamples useIdealChannel BW tailLength ...
    preamble txBitStream

%% Set path to find the folder MatlabOctaveFunctions with functions
% such as ak_psd.m and folder MatlabOctaveThirdPartyFunctions with
% mseq.m
addpath('../dsp-telecom-book-code/MatlabOctaveFunctions');
addpath('../dsp-telecom-book-code/MatlabOctaveThirdPartyFunctions');

%% General parameters
showPlots=1; %use 1 to show plots
%shouldWriteEPS=1; %write output EPS files (with print -depsc)
Fs=44100; %sampling frequency in Hz
S=1000; %number of symbols per frame
L=80; %oversampling factor

%% Channel parameters for simulation
useIdealChannel = 0; %set 1 if want ideal channel

%% Transmitter and receiver parameters
wc=pi/2; %carrier frequency: 0.5*pi rad (or Fs/4 Hz)
M=2; %number of symbols in alphabet
useQAM=0; %use QAM or PAM
if useQAM==1
    const=ak_qamSquareConstellation(M); %QAM const.
else %PAM
    const=-(M-1):2:M-1;
end
b=log2(M); %num of bits per symbol
Nbits=b*S; %total number of bits to be transmitted

%htx=ak_rcosine(1,L,'fir/normal',0.5,10); %raised cosine
%Instead, use pair of square root cosines at Tx and Rx:
rolloff=1; %roll-off factor for sqrt raised cosine
delayInSymbols=3; %delay at symbol rate
htx=ak_rcosine(1,L,'fir/sqrt',rolloff,delayInSymbols); %sqrt raised cosine
hrx=conj(fliplr(htx)); %matched filter

%% Estimate bandwidth of baseband signal 
Rsym = Fs/L; %symbol rate (in bauds)
BW = (Rsym/2)*(1+rolloff); %approximate null-to-null bandwidth, in Hz

%the number of samples the receiver should skip. Each
%processing block such as filtering should update this
%variable
delayInSamples = 0;

%% Initialization procedures
rand('twister',0); %reset uniform random number generator
randn('state',0); %reset Gaussian random number generator

%% Create a preamble based on a M-sequence. 
%The code is from a third party and can also be found at:
%Code\MatlabThirdPartyFunctions\mseq.m
%you need to make sure you have it in your Matlab "path"
preambleLength = 1023; %approximate number of preamble samples
powerVal=floor(log2(preambleLength+1)); %needs to be a power of 2
preamble=mseq(2,powerVal);
preambleLength=length(preamble) %update the length value
Ec=mean(abs(const).^2); %energy constellation in Joules
preamble = sqrt(Ec/mean(abs(preamble).^2))*preamble;%normalize energy
tailLength = 10; %add this number of symbols at the end of each frame

%use the same data for all frames, to simplify BER estimation
temp=rand(Nbits,1); %random numbers ~[0,1]
txBitStream=temp>0.5; %bits: 0 or 1
