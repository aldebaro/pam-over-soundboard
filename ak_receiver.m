function [br, ys]=ak_receiver(r)
% function [br, ys]=ak_receiver(r)
%From received signal r, recover the bitstream br and the received
%symbols ys, where ys is at the baud rate.

global showPlots wc M hrx L S delayInSamples const Fs

r=r(:); %make sure it is a column vector

n=transpose(0:length(r)-1); %"time" axis

carrier = cos(wc*n); %create carrier
ybb = r .* carrier; %downconversion, r2 has images at DC and twice wc

ybb_filtered = conv(ybb,hrx); %matched filtering
delayInSamples=delayInSamples + round((length(hrx)-1)/2);

firstSample = delayInSamples; %to start getting symbols
ys=ybb_filtered(firstSample:L:end); %sample at baud rate
ys=ys(1:S); %get only the first S symbols

%perform AGC (automatic gain control) to compensate any channel gain
receivedSymbolsPower=mean(ys.^2);
constellationPower = mean(const.^2);
ys = sqrt(constellationPower/receivedSymbolsPower)*ys;
symbolIndicesRx=ak_pamdemod(ys,M);

%convert from symbol indices to bits
br = ak_unsliceBitStream(symbolIndicesRx, log2(M));

%if user wants to visualize, organize binary codewords along columns
%reshape(br,log2(M),length(br)/log2(M)); %column is a codeword

if showPlots
    subplot(221)
    pwelch(r,[],[],[],Fs)
    title('PSD at receiver input');
    subplot(222)
    pwelch(ybb,[],[],[],Fs)
    title('PSD after downconversion');
    subplot(223)
    pwelch(ybb_filtered,[],[],[],Fs)
    title('PSD after matched filter');
    subplot(224)
    plot(real(ys), imag(ys), 'x', 'markersize',16);
    title('Received symbols'); grid
    if showPlots == 1
        pause
    end
end
