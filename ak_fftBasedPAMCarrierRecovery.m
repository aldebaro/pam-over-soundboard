%This script estimates the frequency and phase offsets of a PAM
%signal with respect to the transmitter carrier. This requires
%a relatively large oversampling factor
%clear *; close all %clear all but breakpoints, close all figures
dt_setGlobalConstants
global Fs L BW
showPlots=0;
%% 0) Define simulation parameters and also check some choices
fc=wc*Fs/(2*pi); %nominal (transmitter's) carrier frequency in Hz
worstFreqOffset=(fc/1e6)*800; %worst accuracy is 800 ppm
desiredResolutionHz=1/1e6*fc; %desired max error/FFT resolution,1 ppm
%force freqOffset to coincide with a FFT bin via Rsym => Fs
Rsym=Fs/L; %symbol rate in bauds
%fIF = 5000; %chosen intermediate frequency in Hz
fIF = (wc/4)*Fs/(2*pi); %chosen intermediate frequency in Hz
P=2; %power the signal will be raised to: x^P(t)
%choose a high enough sampling frequency to represent x^2(t):
maxSquaredSignalFreq = 4*fc+fIF+worstFreqOffset+2*BW;
newL=ceil(3*maxSquaredSignalFreq/Rsym); % oversampling factor
newFs=newL*Rsym; %sampling frequency in Hz

inputWaveFile = 'recorded_pam.wav'; %signal file to be demodulated
%inputWaveFile = 'c:\temp\output.wav';

[r,Fs2]=wavread(inputWaveFile); %file with recorded PAM
if Fs2 ~= Fs
    error('Discrepant sampling frequency!') %just to check
end
if showPlots==1
    ak_psd(r,Fs); title('Received signal PSD')
    pause
end
if newL > L
    %r=resample(r,newL,L); %resample signal
    %newFs=(newL/L)*Fs;
end
if showPlots==1
    ak_psd(r,newFs); title('Upsampled signal PSD')
    pause
end

fIFmin = worstFreqOffset + BW; %minimum intermediate frequency
fIFmax = 0.5*(fc-BW)-worstFreqOffset; %max intermediate frequency
if fIF > fIFmax || fIF < fIFmin
    error('fIF is out of suggested range!')
end
if freqOffset > worstFreqOffset %based on accuracy of oscillator
    error('freqOffset > worstFreqOffset')
end

%% 3) Estimate and correct offsets:
r_carrierRecovery = r.^P; %raise to power P
if showPlots==1
    ak_psd(r_carrierRecovery,newFs); title('Squared signal PSD')
    pause
end
%Will use at least desired resolution:
Nfft = max(ceil(newFs/desiredResolutionHz),length(r_carrierRecovery));
if Nfft > 2^24 %avoid too large FFT size. 2^24 is an arbitrary number 
    Nfft = 2^24; %Modify according to your computer's RAM
end
if rem(Nfft,2) == 1 %force Nfft to be an even number
    Nfft=Nfft+1;
end
minFreqOffset=P*(fIF-worstFreqOffset); %range for search using ...
maxFreqOffset=P*(fIF+worstFreqOffset); %the FFT (in Hz)
resolutionHz = newFs/Nfft; %FFT analysis resolution
minIndexOfInterestInFFT = floor(minFreqOffset/resolutionHz);%min ind.
maxIndexOfInterestInFFT = ceil(maxFreqOffset/resolutionHz);%max ind.
R=fft(r_carrierRecovery,Nfft); %calculate FFT of the squared signal
R(1:minIndexOfInterestInFFT-1)=0; %eliminate values at the left (DC)
%strongest peak within the range of interest (start from index 1):
[maxPeak,indexMaxPeak]=max(abs(R(1:maxIndexOfInterestInFFT)));
estPhaseOffset=angle(R(indexMaxPeak))/P; %obtain phase in rad
%R=[]; %maybe useful, to discard R (invite for freeing memory)
estDigitalFreqOffset=(2*pi/Nfft*(indexMaxPeak-1))/P; %frequen. in rad
wIF=(2*pi*fIF)/newFs; %convert fIF from Hz to radians
estDigitalFreqOffset=estDigitalFreqOffset-wIF; %deduct IF
estFrequencyOffset = estDigitalFreqOffset*Fs/(2*pi); %from rad to Hz
%% 4) Demodulate and estimate symbol error rate (SER)
%correct carrier offsets (taking in account the imposed wIF):
carOffSet=exp(-1j*((estDigitalFreqOffset+wIF)*n+estPhaseOffset));
%rc=r.*carOffSet; %generates complex signal with offsets subtracted
%rc2=2*real(rc); %convert to real signal, take factor of 2 in account
%% 5) Evaluate results
%Information about the simulation
disp(['Symbol rate = ' num2str(Rsym) ' bauds'])
disp(['Product of freq. offset by Tsym = ' num2str(freqOffset/Rsym)])
disp(['(this product above varies from 0.001 to 0.2 in papers)'])
disp(['Nominal (transmitter) carrier frequency in Hz = ' num2str(fc)])
disp(['Searched freq. offset in range: [' num2str(minFreqOffset) ...
      ', ' num2str(maxFreqOffset) '] Hz']);
disp(['Desired FFT resolution=' num2str(desiredResolutionHz) ' Hz'])
disp(['Used FFT resolution = ' num2str(resolutionHz) ' Hz'])
disp(['IF=' num2str(fIF) '. Allowed range=[' ...
    num2str(fIFmin) ', ' num2str(fIFmax) '] (all in Hz)']);
disp(['Estimat. phase offset=' num2str(estPhaseOffset) ' rad'])
disp(['Estimated frequency offset = ' ...
    num2str(estFrequencyOffset) ' Hz'])
