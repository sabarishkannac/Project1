clc;
clear;
close all;

% Frequencies to generate
frequencies = [25, 50, 100]; % Hz

% Number of cycles to generate
num_cycles = 25;

% Struct to hold all scenarios
all_scenarios = struct();

for i = 1:length(frequencies)
    f = frequencies(i);
    T = 1/f;
    
    % Time vector
    t = linspace(0, num_cycles*T, 3000); 
    
    % Define one cycle
    d_rise   = 0.25*T;
    d_flat   = 0.25*T;
    d_fall   = 0.25*T;
    d_bottom = 0.25*T;
    
    % Trapezoidal profile over one period
    t_cycle = [0 d_rise d_rise+d_flat d_rise+d_flat+d_fall T];
    y_cycle = [-0.5 0.5 0.5 -0.5 -0.5];
    
    % Shift base time so that Va starts at 0
    t_base = mod(t + d_bottom, T);
    
    % Generate each phase
    Va = interp1(t_cycle, y_cycle, t_base, 'linear');
    Vb = interp1(t_cycle, y_cycle, mod(t_base - T/3, T), 'linear');
    Vc = interp1(t_cycle, y_cycle, mod(t_base - 2*T/3, T), 'linear');

    % Package as timeseries
    Va_ts = timeseries(Va', t');
    Vb_ts = timeseries(Vb', t');
    Vc_ts = timeseries(Vc', t');

    % Package into Dataset
    ds = Simulink.SimulationData.Dataset;
    ds = addElement(ds, Va_ts, 'Va');
    ds = addElement(ds, Vb_ts, 'Vb');
    ds = addElement(ds, Vc_ts, 'Vc');

    % Store into struct using frequency-based scenario name
    scenario_name = sprintf('f%d', f);
    all_scenarios.(scenario_name) = ds;
end

% Save all scenarios into a single .mat file
save('trapezoidal_3phase_multiFreq.mat', '-struct', 'all_scenarios');
