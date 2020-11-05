% Main script for Asteroid Selection

global AU
global year2day
global muEarth
global muMars
global rEarth
global rMars

Planet_ephemerides = importdata('Earth_Mars_ephemerides.txt');
Planet_ephemerides = reshape(Planet_ephemerides, [7,2]);
Planet_ephemerides = Planet_ephemerides';

input.Modeling_Start = juliandate(datetime(2040,1,1,0,0,0));          % Modeling start JD 
input.Modeling_time = 20*year2day;                                    % Modeling time (days)
input.LD_dt = 7;                                                      % start date search step (days)
input.min_TOF = 100;                                                   % minimum time of flight (days)
input.max_TOF = 1000;                                           % maximum time of flight (days)
input.TOF_dt = 7;                                                     % time of flight search step (days)
input.dV_max = 6.4;                                                   % Maximum dV capability of the spacecraft
input.LEO = 500;                                                      % LEO orbit
input.LMO = 500;                                                      % LMO orbit

data_raw = readtable('data_metallic_asteroids.txt'); 
data_diameter = table2array(data_raw(:,9)); % [diameter [km]]
non_feasible = data_diameter(:) < 0.5; 
data_raw(non_feasible,:) = [];

data_orbit = table2array(data_raw(:,2:8)); % [sma [AU], ecc [-], inc [deg], RAAN [deg], AOP [deg], MA [deg], epoch [JD]]
data_diameter = table2array(data_raw(:,9));

% final data to use
data = [data_orbit,data_diameter];

clear data_orbit data_diameter % the data is now stored in the variable called data

%% Asteroid selection & transfer list calculation
% - The goal is to find a list of asteroids - potential mining sites corresponding to specific simulation parameters
% - The output — list potential mining sites & optimal transfer
% trajectories corresponding to the local minimums of dV maps

% Building dV maps

% oe_table format [sma [km], ecc [-], inc[deg], RAAN [deg], AOP[deg], MA[deg], Epoch[JD], muPlanet[km3/s2], rPlanet [km], LowPlanetOrbitRadius[km]]

oe_Earth = [Planet_ephemerides(1,:), muEarth, rEarth, input.LEO];  
oe_Mars = [Planet_ephemerides(2,:), muMars, rMars, input.LMO];  
% 
oe = data(:,1:7);
oe(:,8:10) = zeros (size(oe,1),3);
oe(:,9:10) = 1;
oe(:,1) = AU*oe(:,1);

oe_table = [oe_Mars; oe];

oe_table = oe_update(oe_table, input.Modeling_Start);    % Update orbital elements 
input.n_mining_sites = size(oe_table, 1) - 1;            % number of material sources

% Calculating dV maps for forward and backwards transfers between Mars and asteroids - potential mining sites

tic;
dV_maps = multisite_dV_maps_patched_conic(oe_table, input);
toc;
 
counter = 0;

for i = 1:input.n_mining_sites
    if min(dV_maps{1,i},[],'all') < input.dV_max && min(dV_maps{1,input.n_mining_sites+i},[],'all') < input.dV_max
        counter = counter + 1;
        non_feasible(i) = false;
    else
        non_feasible(i) = true;
    end
    
end

non_feasible = non_feasible';
non_feasible = [non_feasible; non_feasible];
feasible_dV_maps = dV_maps;
feasible_dV_maps(non_feasible) = [];
Number_of_feasible_asteroids = size(feasible_dV_maps,2)/2

%% One the ways to find local minima
% for q = 1:size(feasible_asteroids_table,1)*2
% 
%     local_mins = islocalmin(feasible_dV_maps{1,q});
%     Launch_windows = [];
% 
%     LD = 1:input.LD_dt:input.Modeling_time;
%     LD = LD(:) + input.Modeling_Start - delta_mjd;
%     TOF = input.min_TOF:input.TOF_dt:input.max_TOF;
% 
%     for i = 1:size(feasible_dV_maps{1,q},1)
%         for j = 1:size(feasible_dV_maps{1,q},2)
%             if local_mins(i,j) == 1 && feasible_dV_maps{1,q}(i,j) <= input.dV_max
%                 Launch_window = [LD(i) , TOF(j), feasible_dV_maps{1,q}(i,j)];
%                 Launch_windows = [Launch_windows; Launch_window];
%             end
%         end
%     end
%     LW{1,q} = Launch_windows;
% end

for i = 1:size(feasible_asteroids_table,1)*2
   LW{1,i} = calculate_transfer_list(feasible_dV_maps{1,i},input);    
end

map_to_build = 100;
plot_dV_map(feasible_dV_maps{1,map_to_build}, input, 20);
hold on;
plot(LW{1,map_to_build}(:,1), LW{1,map_to_build}(:,2), 'or', 'MarkerFaceColor', 'r');
legend('dV map', 'Launch windows');
title('Mars-Asteroid dV map');