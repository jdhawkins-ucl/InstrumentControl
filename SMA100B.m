% J.D. Hawkins
% 25/6/19
% Networked Instrumenation Control for SMA100B Signal Generator
clear all; close all;

% Signal Generator IP
sma100bIP = '169.254.2.20';

% Check Driver Installation
try 
    hwobj = instrhwinfo('vxipnp','rssmx');
    sma100b = icdevice('rssmx',['TCPIP::' sma100bIP '::INSTR']);
catch
    error('Check correct driver installation. Have you set the rssmx path?');
    quit;
end

% Connect to Signal Generator
connect(sma100b);

try
% Enable Signal Generator Output
disp('Enabling Signal Generator Output');
invoke(sma100b, 'ConfigureOutputEnabled', 1);

% Pause
disp('Waiting 2 Seconds');
pause(2);

% Disable Signal Generator Output
disp('Disabling Signal Generator Output');
invoke(sma100b, 'ConfigureOutputEnabled', 0);
catch
    error('An unexpected error occured.');
    disconnect(sma100b);
    delete(sma100b);
end

% Disconnect
disconnect(sma100b);
delete(sma100b);

