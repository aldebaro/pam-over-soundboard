# pam-over-soundboard
Pulse amplitude modulation (PAM) digital transmission using a PC sound board with Octave / Matlab code. There is code for simulation-only (no sound board involved) and to transmit PAM over a sound board and process the received signal offline.

## Simulation-only

1) Edit the file dt_setGlobalConstants.m and get familiar with the main simulation parameters. 

2) Then execute the main script dt_main_transmission_simulation.m, which invokes the following functions
dt_setGlobalConstants.m ==> ak_transmitter.m ==> dt_channel.m ==> ak_receiver.m

## PAM over sound board
1) Edit the file dt_setGlobalConstants.m and get familiar with the main simulation parameters. 

2) Use an audio cable to connect your sound board digital-to-analog converter (DAC) to an analog-to-digital converter (ADC), which may be at the same or in another computer. The computer using the DAC is the transmitter (Tx) and the one using the ADC is the receiver (Rx)

3) Tell the Tx to output the PAM signal using soundBoard_continuouslyTransmitPAM.m. With the Rx, using Audacity, start recording the ADC input as a mono (not stereo) signal, with the sampling frequency Fs you are using. Stop at some point and save the received signal at Rx as a WAV file.

4) Having the recorded WAV, edit soundBoard_offlineReceivePAM.m to provide the WAV file name and then execute soundBoard_offlineReceivePAM.m to demodulate the PAM signal.

Obs: you can use soundBoard_continuouslyTransmitPAM.m to save a signal segment (frame) in a WAV file without transmitting it throught an audio cable. This allows a more controlled operation because there is no channel (no distortion nor noise) and is useful for learning and debugging.

# Additional software

Audacity sound editor: http://www.audacityteam.org/

Aldebaro's book ( http://aldebaro.ufpa.br/ ) software (for functions such as ak_psd.m): https://github.com/aldebaro/dsp-telecom-book-code

# Documentation

Playlist at youtube discussing PAM:
https://www.youtube.com/playlist?list=PLlPCaGk10CBs3vBQAvw9oJ1VBGikjYJJX

Playlist at youtube discussing digital filtering:
https://www.youtube.com/playlist?list=PLlPCaGk10CBs7YCYKnVmsRMj1K8H1kjay

# Troubleshooting

warning: the 'pwelch' function belongs to the signal package from Octave Forge
which seems to not be installed in your system.

When running dt_main_transmission_simulation on Octave, you will need to install the signal package. It is recommended that you install only the packages that you need. But in case you want to install all packages, google it. For example, assuming Octave on Ubuntu, check https://ubuntuforums.org/showthread.php?t=1552607 that suggests using at the terminal prompt:

sudo apt-get install $( apt-cache search octave-forge | awk '{print $1; printf " "}' )

(this corresponds to more than 160 MB)


