# pam-over-soundboard
Pulse amplitude modulation (PAM) digital transmission using a PC sound board with Octave / Matlab code. There is code for simulation-only (no sound board involved) and to transmit PAM over a sound board and process the received signal offline.

## Simulation-only

1) Edit the file dt_setGlobalConstants.m and get familiar with the main simulation parameters. 

2) Then execute the main script dt_main_transmission_simulation.m, which invokes the following functions
dt_setGlobalConstants.m ==> ak_transmitter.m ==> dt_channel.m ==> ak_receiver.m

## PAM over sound board
1) Edit the file dt_setGlobalConstants.m and get familiar with the main simulation parameters. 

2) Use an audio cable to connect your sound board digital-to-analog converter (DAC) to an analog-to-digital converter (ADC), which may be at the same or in another computer. The computer using the DAC is the transmitter (Tx) and the one using the ADC is the receiver (Rx). Test things trasmitting a song from Tx and listening it after recording with Rx, to proper set the audio volume to avoid signal saturation.

3) Use soundBoard_savePAMFrameToTransmitWithAudacity.m to save a WAV file with a PAM signal.

4) Using Audacity (menu Transport => Loop play) at Tx, playback in a loop the file recored in the previous step. Using another copy of Audacity at Rx, start recording the ADC input as a mono (not stereo) signal, with the sampling frequency Fs you are using at Tx. Stop at some point and save the received signal at Rx as a WAV file. Avoid having silence or noise at the beginning or end of file.

5) Having the recorded WAV, edit soundBoard_offlineReceivePAM.m to provide the WAV file name and then execute soundBoard_offlineReceivePAM.m to demodulate the PAM signal.

Obs: You can process a WAV file without transmitting it throught an audio cable. This allows a more controlled operation because there is no channel (no distortion nor noise) and is useful for learning and debugging.

# Additional software

Audacity sound editor: http://www.audacityteam.org/

Aldebaro's book ( http://aldebaro.ufpa.br/ ) software (for functions such as ak_psd.m): https://github.com/aldebaro/dsp-telecom-book-code

# Documentation

Playlist at youtube discussing PAM:
https://www.youtube.com/playlist?list=PLlPCaGk10CBs3vBQAvw9oJ1VBGikjYJJX

Playlist at youtube discussing digital filtering:
https://www.youtube.com/playlist?list=PLlPCaGk10CBs7YCYKnVmsRMj1K8H1kjay

# Example

The file recorded_pam.wav is a binary (M=2 symbols) PAM, recorded with the Tx being a Sony laptop and the Rx a Dell laptop. The computers were connected via an audio cable. The PAM signal has a symbol rate of Rsym = 551.25 bauds, which coincides with the rate R = 551.25 bps (bits / sec). The original script soundBoard_offlineReceivePAM.m is not able to decode without errors because Tx and Rx have a frequency offset. Script ak_fftBasedPAMCarrierRecovery.m gives an idea on how to find the offset but it is not complete.

# Troubleshooting

1) warning: the 'pwelch' function belongs to the signal package from Octave Forge
which seems to not be installed in your system.

When running dt_main_transmission_simulation on Octave, you will need to install the signal package. It is recommended that you install only the packages that you need. But in case you want to install all packages, google it. For example, assuming Octave on Ubuntu, check https://ubuntuforums.org/showthread.php?t=1552607 that suggests using at the terminal prompt:

sudo apt-get install $( apt-cache search octave-forge | awk '{print $1; printf " "}' )

(this corresponds to more than 160 MB)


