% Main script for Asteroid mining

global AU
global muSun
global year2day

Astrea = load('ASTRAEA.mat');

input.Modeling_Start = juliandate(datetime(2040,1,1,0,0,0));          % Modeling start JD 
input.Modeling_time = 20*year2day;                                    % Modeling time (days)
input.LD_dt = 7;                                                      % start date search step (days)
input.min_TOF = 60;                                                   % minimum time of flight (days)
input.max_TOF = 2*year2day;                                           % maximum time of flight (days)
input.TOF_dt = 1;                                                     % time of flight search step (days)
input.dV_max = 6.4;                                                   % Maximum dV capability of the spacecraft
input.LEO = 500;                                                      % LEO orbit
input.LMO = 500;                                                      % LMO orbit

data_raw = readtable('data1.txt'); 
data_diameter = table2array(data_raw(:,9)); % [diameter [km]]
non_feasible = data_diameter(:) < 0.5; 
data_raw(non_feasible,:) = [];
data_raw = data_raw(2,:);

data_orbit = table2array(data_raw(:,2:8)); % [sma [AU], ecc [-], inc [deg], RAAN [deg], AOP [deg], MA [deg], epoch [JD]]
data_diameter = table2array(data_raw(:,9));

% final data to use
data = [data_orbit,data_diameter];

clear data_orbit data_diameter % the data is now stored in the variable called data

%% Asteroid selection & transfer list calculation
% - The goal is to find a list of asteroids - potential mining sites corresponding to specific simulation parameters
% - The output — list potential mining sites & optimal transfer trajectories corresponding to the local minimums of a dV map

% Step 1: calculating dV for Mars-Mining_site(i) transfer using Hohmann like transfer to evaluate minimum possible dV
% If the dV is greated than spacecraft dV capacity we eliminate the asteroid from the list of potential mining sites

% [dV_Shoemaker, data] = asteroid_selection(data, input);

% Step 2: building dV map for transfers from and to Mars to define launch windows that will be utilized to combine a transportation schedule

% Matrix structure [sma [km], ecc [-], inc[deg], RAAN [deg], AOP[deg], MA[deg], Epoch[JD], muPlanet[km3/s2], rPlanet [km], LowPlanetOrbitRadius[km]]
% oe_table = [1.524*AU, 0.094, 1.851, 49.579, 336.041, 355.453, 2451545.0, 42828, 3389.5, input.LMO;...       % Mars
%           1.000*AU, 0.0167, 0.000, -11.261, 102.947, 100.464, 2451545.0, 398600.44158, 6371, input.LEO];  % Earth
oe_table = [1.524*AU, 0.094, 1.851, 49.579, 336.041, 355.453, 2451545.0, 42828, 3389.5, input.LMO];       % Mars

oe = data(:,1:7);
oe(:,8:10) = zeros (size(oe,1),3);
oe(:,9:10) = 1;
oe(:,1) = AU*oe(:,1);

oe_table = [oe_table; oe];

oe_table = oe_update(oe_table, input.Modeling_Start);    % Update orbital elements 
input.n_mining_sites = size(oe_table, 1) - 1;            % number of material sources

% Calculating dV maps for forward and backwards transfers between Mars and potential mining sites
tic;
[transfers, dV_maps] = multisite_transfer_list(oe_table, input);
toc;

forward_transfers = transfers(1,1:input.n_mining_sites);
backward_transfers = transfers(1,input.n_mining_sites+1:end);

for i = 1:input.n_mining_sites
    non_feasible(i) = isempty(forward_transfers{1,i}) || isempty(backward_transfers{1,i});
end

data_raw_preprocessed1 = data_raw;
data_raw_preprocessed1(non_feasible,:) = [];

data_preprocessed1 = data;
data_preprocessed1(non_feasible,:) = [];

forward_transfers_processed1 = forward_transfers;
forward_transfers_processed1(non_feasible) = [];

backward_transfers_processed1 = backward_transfers;
backward_transfers_processed1(non_feasible) = [];

for i = 1:size(data_preprocessed1,1)
    feasible_dV(i) = (min(forward_transfers_processed1{1,i}(:,3)) + min(backward_transfers_processed1{1,i}(:,3))) < input.dV_max;
end

N_asteroids = sum(feasible_dV)


% dV_map = calculate_dV_map(oe_table(1,:), oe_table(2,:), input);
plot_dV_map(dV_maps{1,1}, input, NaN);
dV_min = min(min(dV_map));