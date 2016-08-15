function [s,symbols]=ak_transmitter(bitStream)
% function [s,symbols]=ak_transmitter(bitStream)
%From input bit stream (bitStream), create the symbols (symbols)
%sampled at baud rate Rsym and the transmit waveform s, sampled at
%the sampling frequency Fs, where L=Rsym/Fs is the oversampling

global b S L const showPlots htx wc delayInSamples Fs

%assumes that setGlobalConstants was executed
%slice the bits into the symbol indices:
symbolIndicesTx = ak_sliceBitStream(bitStream, b);
symbols=const(symbolIndicesTx+1); %random symbols
x=zeros(1,S*L); %pre-allocate space
x(1:L:end)=symbols; %complete upsampling operation
txWaveform=conv(htx,x); %convolution by shaping pulse
delayInSamples=delayInSamples + round((length(htx)-1)/2);
txSignalPower = mean(abs(txWaveform).^2); %power of baseband signal
%modulate by carrier at wc rad:
n=0:length(txWaveform)-1; %"time" axis
s=txWaveform.*cos(wc*n); %upconvert and obtain transmit signal
s=s(:); %force s to be a column vector

modulatedSignalPower = mean(s.^2); %power of modulated signal
%Note that, due to the cosine multiplication
%modulatedSignalPower = txSignalPower/2;
%this will be compensated at the receiver by AGC (auto. gain control)

if showPlots 
    clf
    N=5*L;
    start=delayInSamples+5*L;
    t=(start:start+N)/Fs;
    subplot(211)
    plot(t,txWaveform(start:start+N))
    title('Baseband signal')
    ylabel('Amplitude')
    axis tight
    subplot(212)
    plot(t,s(start:start+N))
    title('Upconverted Tx signal');
    axis tight
    ylabel('Amplitude')
    xlabel('Time (s)')
    pause
    
    clf
    subplot(311)
    plot(real(const), imag(const), 'x', 'markersize',16);
    title('Tx Constellation'); grid
    subplot(312)
    ak_psd(txWaveform,Fs);
    title('PSD of baseband Tx signal');
    xlabel('Frequency (Hz)')
    subplot(313)
    ak_psd(s,Fs);
    title('PSD of modulated Tx signal');            
    xlabel('Frequency (Hz)')
    pause
end

