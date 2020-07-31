% Main script for Asteroid mining

global AU
global muSun
global year2day

input.Modeling_Start = juliandate(datetime(2050,1,1,0,0,0));            % Modeling start JD 
input.Modeling_time = 1*year2day;                                      % Modeling time (days)
input.LD_dt = 7;                                                        % start date search step (days)
input.min_TOF = 300;                                                    % minimum time of flight (days)
input.max_TOF = 500;                                                    % maximum time of flight (days)
input.TOF_dt = 7;                                                       % time of flight search step (days)
input.dV_max = 6.3;                                                     % Maximum dV capability of the spacecraft
input.LEO = 500;                                                        % LEO orbit
input.LMO = 500;                                                        % LMO orbit

data_raw = importdata('Oct22_target_asteroids.csv'); 

% reorganizing data matrix
data_orbit = data_raw.data(:,2:8); % [sma [AU], ecc [-], inc [deg], RAAN [deg], AOP [deg], MA [deg], epoch [JD]]
data_diameter = data_raw.data(:,1); % [diameter [km]]

% final data to use
data = [data_orbit,data_diameter];
textdata = data_raw.textdata(2:end, 1:2);

clear data_orbit data_diameter % the data is now stored in the variable called data

%% Asteroid selection & transfer list calculation
% - The goal is to find a list of asteroids - potential mining sites corresponding to specific simulation parameters
% - The output — list potential mining sites & optimal transfer trajectories corresponding to the local minimums of a dV map

% Step 1: calculating dV for Mars-Mining_site(i) transfer using Hohmann like transfer to evaluate minimum possible dV
% If the dV is greated than spacecraft dV capacity we eliminate the asteroid from the list of potential mining sites

[dV_Shoemaker, data, textdata] = asteroid_selection(data, textdata, input);

% Step 2: building dV map for transfers from and to Mars to define launch windows that will be utilized to combine a transportation schedule

% Matrix structure [sma [km], ecc [-], inc[deg], RAAN [deg], AOP[deg], MA[deg], Epoch[JD], muPlanet[km3/s2], rPlanet [km], LowPlanetOrbitRadius[km]]
oe_table = [1.524*AU, 0.094, 1.851, 49.579, 336.041, 355.453, 2451545.0, 42828, 3389.5, input.LMO;...       % Mars
          1.000*AU, 0.0167, 0.000, -11.261, 102.947, 100.464, 2451545.0, 398600.44158, 6371, input.LEO];  % Earth

oe = data(:,1:7);
oe(:,8:10) = zeros (length(oe),3);
oe(:,9:10) = 1;
oe(:,1) = AU*oe(:,1);

oe_table = [oe_table; oe];

oe_table = oe_update(oe_table, input.Modeling_Start);    % Update orbital elements 
input.n_mining_sites = size(oe_table, 1) - 1;            % number of material sources

% Calculating dV maps for forward and backwards transfers between Mars and potential mining sites
tic;
transfers = multisite_transfer_list(oe_table, input);
toc;

dV_map = calculate_dV_map(oe_table(1,:), oe_table(2,:), input);
plot_dV_map(dV_map, input, NaN);