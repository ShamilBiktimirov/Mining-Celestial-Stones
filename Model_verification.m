% Script aims at verifying the code 
% The results are compared with NASA Mission design tool
% We verify our code on example of Ceres asteroid
% https://ssd.jpl.nasa.gov/?mdesign_server&sstr=Ceres

global AU
global year2day
global muEarth
global muMars
global rEarth
global rMars

Planet_ephemerides = importdata('Earth_Mars_ephemerides.txt');
Planet_ephemerides = reshape(Planet_ephemerides, [7,2]);
Planet_ephemerides = Planet_ephemerides';

input.Modeling_Start = juliandate(datetime(2020,1,1,0,0,0));          % Modeling start JD 
input.Modeling_time = 5*year2day;                                    % Modeling time (days)
input.LD_dt = 7;                                                      % start date search step (days)
input.min_TOF = 100;                                                   % minimum time of flight (days)
input.max_TOF = 1600;                                           % maximum time of flight (days)
input.TOF_dt = 7;                                                     % time of flight search step (days)
input.dV_max = 34;                                                   % Maximum dV capability of the spacecraft
input.LEO = 500;                                                      % LEO orbit
input.LMO = 500;                                                      % LMO orbit

data_raw = readtable('data1.txt'); 
data_diameter = table2array(data_raw(:,9)); % [diameter [km]]
non_feasible = data_diameter(:) < 0.5; 
data_raw(non_feasible,:) = [];

Ceres_oe = table2array(data_raw(1,2:8));
data_orbit = table2array(data_raw(:,2:8)); % [sma [AU], ecc [-], inc [deg], RAAN [deg], AOP [deg], MA [deg], epoch [JD]]
data_diameter = table2array(data_raw(:,9));

% final data to use
data = [data_orbit,data_diameter];

clear data_orbit data_diameter % the data is now stored in the variable called data

%% Building dV maps

% oe matrix format: [sma [km], ecc [-], inc[deg], RAAN [deg], AOP[deg], MA[deg], Epoch[JD], muPlanet[km3/s2], rPlanet [km], LowPlanetOrbitRadius[km]]

oe_Earth = [Planet_ephemerides(1,:), muEarth, rEarth, input.LEO];  
oe_Mars = [Planet_ephemerides(2,:), muMars, rMars, input.LMO];  
 
Ceres_oe(1,8:10) = 0;
Ceres_oe(:,9:10) = 1;
Ceres_oe(:,1) = AU*Ceres_oe(:,1);

oe_table = [oe_Earth; Ceres_oe];

oe_table = oe_update(oe_table, input.Modeling_Start);    % Update orbital elements 
input.n_mining_sites = size(oe_table, 1) - 1;            % number of material sources

% Calculating dV maps and launch windows for Earth to Ceres transfer

tic;
[transfers, dV_maps] = multisite_transfer_list_lambert_multiple_revolutions(oe_table, input);
toc;

local_mins = islocalmin(dV_maps{1,1});
Launch_windows = [];

LD = 1:input.LD_dt:input.Modeling_time;
LD = LD(:) + input.Modeling_Start - delta_mjd;
TOF = input.min_TOF:input.TOF_dt:input.max_TOF;

for i = 1:size(dV_maps{1,1},1)
    for j = 1:size(dV_maps{1,1},2)
        if local_mins(i,j) == 1 && dV_maps{1,1}(i,j) <= input.dV_max
            Launch_window = [LD(i) , TOF(j), dV_maps{1,1}(i,j)];
            Launch_windows = [Launch_windows; Launch_window];
        end
    end
end

global_min = min(dV_maps{1,1},[],'all');
transfers_min = min(transfers{1,1}(:,3));

% visualizing results

plot_dV_map(dV_maps{1,1}, input, 34);
hold on;
plot(transfers{1,1}(:,1), transfers{1,1}(:,2), 'or', 'MarkerFaceColor', 'r');
legend('dV map', 'Launch windows');
title('Earth to Ceres dV map');
 