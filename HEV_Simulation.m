%% Series-Parallel HEV Power Flow Simulation

clc;
clear;
close all;

%% Simulation time
t = (0:0.01:15)';

%% Operating Mode
% 1 = Regenerative Braking
% 2 = Full Acceleration
% 3 = Battery Only

OperatingMode = zeros(size(t));

OperatingMode(t >= 0  & t < 5)  = 3;
OperatingMode(t >= 5  & t < 10) = 2;
OperatingMode(t >= 10 & t <= 15) = 1;

%% Wheel Power Request
WheelPowerRequest = zeros(size(t));

WheelPowerRequest(t >= 0 & t < 5) = 30000;
WheelPowerRequest(t >= 5 & t < 10) = 60000;
WheelPowerRequest(t >= 10 & t <= 15) = -40000;

%% Convert to timeseries
OperatingMode = timeseries(OperatingMode,t);
WheelPowerRequest = timeseries(WheelPowerRequest,t);

%% Simulation time
simTime = 15;