%% BUILD SERIES-PARALLEL HEV SIMULINK MODEL
clc;

model = 'Series_Parallel_HEV_PowerFlow_Simulink';

% Close model if already open
if bdIsLoaded(model)
    close_system(model,0);
end

% Create new model
new_system(model);
open_system(model);

%% ---------------- INPUTS ----------------

add_block('simulink/Sources/From Workspace', ...
    [model '/OperatingMode'], ...
    'VariableName','OperatingMode', ...
    'Position',[50 100 180 130]);

add_block('simulink/Sources/From Workspace', ...
    [model '/WheelPowerRequest'], ...
    'VariableName','WheelPowerRequest', ...
    'Position',[50 180 180 210]);

%% ---------------- HEV CONTROLLER ----------------

add_block('simulink/User-Defined Functions/MATLAB Function', ...
    [model '/HEV_Controller'], ...
    'Position',[270 100 470 260]);

controllerCode = [
"function [P_engine,P_direct,P_gen_mech,P_gen_dc,P_motor_mech,P_motor_dc,P_battery,P_friction] = fcn(OperatingMode,WheelPowerRequest)"
newline
"% HEV power-flow controller"
newline
""
newline
"% Efficiencies"
newline
"eta_engine = 0.90;"
newline
"eta_generator = 0.90;"
newline
"eta_motor = 0.90;"
newline
"eta_battery = 0.95;"
newline
""
newline
"% Initialize outputs"
newline
"P_engine = 0;"
newline
"P_direct = 0;"
newline
"P_gen_mech = 0;"
newline
"P_gen_dc = 0;"
newline
"P_motor_mech = 0;"
newline
"P_motor_dc = 0;"
newline
"P_battery = 0;"
newline
"P_friction = 0;"
newline
""
newline
"switch OperatingMode"
newline
""
newline
"case 3"
newline
"% Battery Only"
newline
"P_motor_mech = WheelPowerRequest;"
newline
"P_motor_dc = P_motor_mech/eta_motor;"
newline
"P_battery = P_motor_dc/eta_battery;"
newline
""
newline
"case 2"
newline
"% Full Acceleration"
newline
"P_engine = WheelPowerRequest/eta_engine;"
newline
"P_direct = 0.5*P_engine;"
newline
"P_gen_mech = P_engine-P_direct;"
newline
"P_gen_dc = P_gen_mech*eta_generator;"
newline
"P_motor_dc = P_gen_dc;"
newline
"P_motor_mech = P_motor_dc*eta_motor;"
newline
"P_battery = WheelPowerRequest-P_direct-P_motor_mech;"
newline
""
newline
"case 1"
newline
"% Regenerative Braking"
newline
"braking_power = abs(WheelPowerRequest);"
newline
"P_motor_mech = -braking_power;"
newline
"P_motor_dc = P_motor_mech*eta_motor;"
newline
"P_battery = P_motor_dc*eta_battery;"
newline
"P_friction = braking_power-abs(P_battery);"
newline
""
newline
"otherwise"
newline
"% Invalid mode"
newline
"end"
];

chart = find(sfroot, ...
    '-isa','Stateflow.EMChart', ...
    'Path',[model '/HEV_Controller']);

chart.Script = char(controllerCode);

%% ---------------- DEMUX ----------------

add_block('simulink/Signal Routing/Demux', ...
    [model '/PowerSignals'], ...
    'Outputs','8', ...
    'Position',[530 105 560 255]);

%% ---------------- POWER DISPLAYS ----------------

names = { ...
    'ICE_Power', ...
    'Direct_Mechanical', ...
    'Generator_Mechanical', ...
    'Generator_DC', ...
    'Traction_Motor_Mechanical', ...
    'Motor_DC_Input', ...
    'Battery_Power', ...
    'Friction_Brake'};

y = 80;

for k = 1:8

    add_block('simulink/Math Operations/Gain', ...
        [model '/' names{k} '_kW'], ...
        'Gain','1/1000', ...
        'Position',[620 y 700 y+30]);

    add_block('simulink/Sinks/Display', ...
        [model '/' names{k} '_Display'], ...
        'Position',[750 y 820 y+30]);

    add_line(model, ...
        ['PowerSignals/' num2str(k)], ...
        [names{k} '_kW/1']);

    add_line(model, ...
        [names{k} '_kW/1'], ...
        [names{k} '_Display/1']);

    y = y + 65;
end

%% ---------------- SCOPE ----------------

add_block('simulink/Signal Routing/Mux', ...
    [model '/Mux'], ...
    'Inputs','9', ...
    'Position',[1050 100 1080 300]);

add_block('simulink/Sinks/Scope', ...
    [model '/Scope'], ...
    'Position',[1130 150 1240 250]);

%% ---------------- SOC CALCULATION ----------------

add_block('simulink/Math Operations/Gain', ...
    [model '/Battery_Current_Effect'], ...
    'Gain','-1/(20*3.6e6)', ...
    'Position',[620 650 730 690]);

add_block('simulink/Continuous/Integrator', ...
    [model '/SOC_Integrator'], ...
    'InitialCondition','0.70', ...
    'Position',[780 650 830 690]);

add_block('simulink/Discontinuities/Saturation', ...
    [model '/SOC_Saturation'], ...
    'UpperLimit','1', ...
    'LowerLimit','0', ...
    'Position',[880 650 940 690]);

add_block('simulink/Math Operations/Gain', ...
    [model '/SOC_Percent'], ...
    'Gain','100', ...
    'Position',[980 650 1050 690]);

add_block('simulink/Sinks/Display', ...
    [model '/SOC_Display'], ...
    'Position',[1080 650 1150 680]);

%% ---------------- CONNECTIONS ----------------

add_line(model,'OperatingMode/1','HEV_Controller/1');
add_line(model,'WheelPowerRequest/1','HEV_Controller/2');

add_line(model,'HEV_Controller/1','PowerSignals/1');

%% Battery power to SOC
add_line(model,'HEV_Controller/7','Battery_Current_Effect/1');
add_line(model,'Battery_Current_Effect/1','SOC_Integrator/1');
add_line(model,'SOC_Integrator/1','SOC_Saturation/1');
add_line(model,'SOC_Saturation/1','SOC_Percent/1');
add_line(model,'SOC_Percent/1','SOC_Display/1');

%% Connect first 8 signals to Mux
for k = 1:8
    add_line(model, ...
        ['PowerSignals/' num2str(k)], ...
        ['Mux/' num2str(k)]);
end

%% SOC to Mux
add_line(model,'SOC_Percent/1','Mux/9');

add_line(model,'Mux/1','Scope/1');

%% Simulation settings
set_param(model,'StopTime','15');

%% Save
save_system(model);

disp(' ');
disp('HEV MODEL CREATED SUCCESSFULLY!');
disp('Open the Simulink model and press RUN.');
disp(' ');