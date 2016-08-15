%Example of digital transmission
close all %close all figures
dt_setGlobalConstants %set global variables
temp=rand(Nbits,1); %random numbers ~[0,1[
txBitStream=temp>0.5; %bits: 0 or 1
[s,txSymbols]=ak_transmitter(txBitStream); %transmitter
%choose channel:
if useIdealChannel==1
    r=s;
else
    r=dt_channel(s);
end
[rxBitStream,rxSymbolsBeforeDecision]=ak_receiver(r); %receiver

txSymbols=transpose(txSymbols); %make it a column vector

normalize=1; %AGC: force signals to have the same power
EVMrms = ak_evm(txSymbols, rxSymbolsBeforeDecision, normalize)

[symbolIndicesRx,rxSymbols]=ak_pamdemod(rxSymbolsBeforeDecision,M);
SER = sum(rxSymbols~=txSymbols)/length(txSymbols)
%estimate BER (both vectors must have the same length)
BER=ak_estimateBERFromBits(txBitStream, rxBitStream)
baud = Fs/L  %symbol rate (bauds)
rate_bps = baud*b  %rate (bits per second)