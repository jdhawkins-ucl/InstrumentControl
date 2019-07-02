% J.D. Hawkins
% 25/06/19
% Swept Frequency and Acquisition
clear all; close all;

%% Parameters
% Oscilloscope IP Address
rtoIP = '169.254.233.65';
% Signal Generator IP Address
smaIP = '169.254.2.20';

% Channels to save
chx = [1 2];

% Define Frequency Sweep, Step
fstart = 100e6;
fstop = 500e6;
fstep = 20e6;
% RF Power
rfpower = -10; % dBm

% Define Acquisition Pause and Period (ms)

% Acquisition pause is time to let waveform settle before taxing
% measurement.
aqPause = 1000;

% Acquisition period is time period to acquire sample over (i.e. 10 *
% timeBase)
aqPeriod = 1/(fstart*5);

% Vertical resolution (V)
aqVertical = 0.05;

%% Setup Instrument Objects

% Add drivers to path
addpath('C:\Program Files\IVI Foundation\VISA\Win64\rsscope')
addpath('C:\Program Files\IVI Foundation\VISA\Win64\rssmx')

try 
    hwObjOsc = instrhwinfo('vxipnp','rsscope');
    hwObjSgn = instrhwinfo('vxipnp','rssmx');
    oscObj = icdevice('rsscope', ['TCPIP::' rtoIP '::INSTR']);
    sgnObj = icdevice('rssmx',   ['TCPIP::' smaIP '::INSTR']);
catch
    error('Check correct driver isntallation.  Have you added the rsscope and rssmx directories to the MATLAB path?');
    quit;
end

%% Setup Oscilloscope
% Connect to oscilloscope
connect(oscObj);
% Set time base
invoke(oscObj, 'ConfigureTimeBase', aqPeriod, 0, 0);

for k = 1:length(chx)
    % Set channel enabled
    invoke(oscObj, 'ConfigureChannel', chx(k), 1, 0.05*10, 0, 0);
end

%% Setup Signal Generator
% Connect to signal generator
connect(sgnObj);

%% Perform Sweep

% Define frequency vector
f = fstart:fstep:fstop;

% Determine initial record length
arl = invoke(oscObj, 'ActualRecordLength');
% Setup empty data matrix
dataM = zeros(length(chx), arl, length(f));
% Setup empty data vector
dataV = zeros(arl, 1);

% Enable signal generator
invoke(sgnObj, 'ConfigureOutputEnabled', 1);

disp('Starting Frequency Sweep...')
% Start Sweep
for k = 1:length(f)
    
    disp([' - ' num2str(f(k)/1e6, '%0.3f') ' MHz']);
    % Configure frequency
    invoke(sgnObj, 'ConfigureRF', f(k), rfpower);
    % Hold
    pause(aqPause/1000);
    
    % Acquire data
    [dataV, actualPoints, initialX, xIncrement] = invoke(oscObj, 'ReadWaveform', 1, 1, arl, 5000, dataV);
    dataM(1,:,k) = dataV;
    
    % Fetch data from remaining datasets
    if length(chx) > 1
        for m = 2:length(chx)
            [dataV, actualPoints, initialX, xIncrement] = invoke(oscObj, 'FetchWaveform', chx(m), 1, arl, dataV);
            dataM(m,:,k) = dataV;
        end
    end
    
end
disp('Finished Frequency Sweep.');

% Disable signal generator
invoke(sgnObj, 'ConfigureOutputEnabled', 0);

% Reset trigger
invoke(oscObj, 'InitiateAcquisition', 1);
invoke(oscObj, 'ConfigureTriggerModifier', 1, 1);

disconnect(oscObj);
disconnect(sgnObj);

%% Plot Results
ch1Data = squeeze(dataM(1,:,:));
ch2Data = squeeze(dataM(2,:,:));
subplot(2,1,1)
imagesc(ch1Data')
subplot(2,1,2)
imagesc(ch2Data')
colormap('jet');


