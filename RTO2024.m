% J.D. Hawkins
% 25/6/19
% Networked Instrumenation Control for SMA100B Signal Generator
clear all; close all;

% Signal Generator IP
rto2024IP = '169.254.233.65';

% Check Driver Installation
try 
    hwobj = instrhwinfo('vxipnp','rsscope');
    rto2024 = icdevice('rsscope',['TCPIP::' rto2024IP '::INSTR']);
catch
    error('Check correct driver installation. Have you set the rssmx path?');
    quit;
end

% Connect to Oscilloscope
connect(rto2024);

% Specify test signal frequency
ftest = 300e6;
% Determine test signal period
ptest = 1/ftest;
% Set time base
timeBase = ptest/5;

% Set time base (2 * T)
invoke(rto2024, 'ConfigureTimeBase', timeBase, 0, 0);

% Set vertical scale (50 mV/div)
invoke(rto2024, 'ConfigureChannelVerticalScale', 1, 0.05);

% Query record length
arl = invoke(rto2024, 'ActualRecordLength');

% Acquire waveform
data = zeros(arl, 1);
[data, actualPoints, initialX, xIncrement] = invoke(rto2024, 'ReadWaveform', 1, 1, arl, 5000, data);

% Return to continuous acquisition
invoke(rto2024, 'InitiateAcquisition', 1);

% Disconnect from oscilloscope
disconnect(rto2024);
delete(rto2024);

% Plot data
t = initialX + (0:arl-1)*xIncrement;
plot(t, data);

