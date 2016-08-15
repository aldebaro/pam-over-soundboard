dt_setGlobalConstants %set global variables
global txBitStream tailLength preamble const; %globals used in this code

showPlots=1;%in case want to overwrite value in dt_setGlobalConstants

inputWaveFile = 'recorded_pam.wav'; %signal file to be demodulated
%inputWaveFile = 'c:\temp\output.wav';

[r,Fs2]=wavread(inputWaveFile); %file with recorded PAM
if Fs2 ~= Fs
    error('Discrepant sampling frequency!') %just to check
end

%% Get the baseband complex envelope
r=r(:); %r is received signal. Make sure it is a column vector
n=transpose(0:length(r)-1); %generate the "time" axis
ybb = r.*cos(wc*n); %frequency downconversion (to baseband)
ybb_filtered = conv(ybb,hrx); %matched filtering

%% Symbol timing synchronization: find where preamble starts
maxAbsR=-1; %maximum crosscorrelation, initialize with negative value
%define a range of samples to search (assume a valid frame is not far
%from the beginning of the file. You may increase the number below:
preambleLength=length(preamble); %defined at dt_setGlobalConstants.m
windowSearchLength=2*L*(preambleLength + S + tailLength);
if windowSearchLength > length(ybb_filtered) %check if small segment
    windowSearchLength = length(ybb_filtered);
end
ws=ybb_filtered(1:windowSearchLength); %extract segment to work with
for d=1:L %hypothesize the best sampling instant (symbol timing)
    temp=ws(d:L:end); %downsampling from Fs to baud rate
    [R,lags]=xcorr(temp,preamble); %cross-correlation with preamble
    maxR=max(abs(R)); %find maximum
    if (maxR > maxAbsR) %update if best option
        dbest = d;
        maxlag = lags(find(abs(R)==maxR,1)); %choose first maximum
        maxAbsR = maxR;
    end
    if showPlots==1
        if 0 %show eye diagrams (use 0 to disable)
            clf
            title(['Start = ' num2str(d)])
            ak_plotEyeDiagram(d,L,temp);
            pause
        end
    end
end
if showPlots==1
    clf
    subplot(221)
    plot(0:length(r)-1,r);
    xlabel('n (samples)'), ylabel('x[n]')
    title('Received PAM signal');
    axis tight
    subplot(223)
    temp=ybb_filtered(dbest:L:end);%downsampling from Fs to baud rate
    [R,lags]=xcorr(temp,preamble); %cross-correlation with preamble
    plot(lags,real(R)) %plot real part of crosscorrelation
    title('Crosscorrelation: x[n] and preamble');
    xlabel('lag m'), ylabel('Real part of Rxy(m)'), grid
end

ys=ybb_filtered(dbest+maxlag*L:L:end); %sample at baud rate
recoveredPreamble=ys(1:preambleLength); %get the preamble
recoveredSymbols=ys(preambleLength+1:preambleLength+S); %and symbols

%% Compensate gain and phase incorporated by the channel
%correct the gain and phase using the preamble information:
gainPhaseAdjustment=mean(recoveredPreamble./preamble);
%phaseCorrection=mean(angle(recoveredPreamble)-angle(preamble))
%temp=recoveredPreamble*exp(-j*phaseCorrection); %only phase, no gain
%phaseCorrection=angle(gainPhaseAdjustment); %alternative
if showPlots==1
    subplot(222)
    plot(real(recoveredSymbols), imag(recoveredSymbols), 'x', ...
        'markersize',16);
    title('Received symbols before equalization'); grid
end
recoveredSymbols=recoveredSymbols/gainPhaseAdjustment;

%% Decisions (find nearest constellation symbol) and bit conversion
recoveredSymbols = real(recoveredSymbols); %discard imaginary part
%perform AGC (automatic gain control) to compensate any channel gain
receivedSymbolsPower=mean(recoveredSymbols.^2);
constellationPower = mean(const.^2);
recoveredSymbols = sqrt(constellationPower/receivedSymbolsPower)*recoveredSymbols;

symbolIndicesRx=ak_pamdemod(recoveredSymbols,M);
%convert from symbol indices to bits
rxBitStream = ak_unsliceBitStream(symbolIndicesRx, log2(M));
%estimate BER (both vectors must have the same length)
BER=ak_estimateBERFromBits(txBitStream, rxBitStream)

baud = Fs/L  %symbol rate (bauds)
%total rate (bits per second), information and overhead:
gross_rate_bps = baud*b
%only information bits:
net_rate_bps = gross_rate_bps * (S/(S+preambleLength+tailLength))

if showPlots==1
    subplot(224)
    %try N=200 and carrier offset does not hurt too much
    N=length(recoveredSymbols); 
    plot(real(recoveredSymbols(1:N)), imag(recoveredSymbols(1:N)),...
        'x', 'markersize',16);
    title('Equalized received symbols'); grid
end

disp(['Finished processing file ' inputWaveFile]);