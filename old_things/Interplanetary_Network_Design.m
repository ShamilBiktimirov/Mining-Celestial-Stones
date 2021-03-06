% Main script for Interplanetary Network Design

global AU
global muSun
global year2day

input.Modeling_Start = juliandate(datetime(2050,1,1,0,0,0));            % Modeling start JD 
input.Modeling_time = 10*year2day;                                      % Modeling time (days)
input.LD_dt = 7;                                                        % start date search step (days)
input.min_TOF = 300;                                                    % minimum time of flight (days)
input.max_TOF = 800;                                                    % maximum time of flight (days)
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

clear data_orbit data_diameter % the data is now stored in variable data

%% Asteroid selection
% - The goal is to find a list of asteroids - potential mining sites corresponding to specific simulation parameters
% - The output � list potential mining sites & optimal transfer trajectories corresponding to the local minimums of dV map

% Step 1: we calculate dV for Mars-Asteroid(i) transfer using Hohmann like transfer to evaluate minimum possible dV
% If the dV is greated than spacecraft dV capacity we eliminate the asteroid from the list of potential mining sites

[dV_Shoemaker, data, textdata] = asteroid_selection(data, textdata, input);

% Step 2: building dV map for transfers from and to Mars to define Launch
% windows that will be utilized to combine a transportation schedule

% Matrix structure [sma [km], ecc [-], inc[deg], RAAN [deg], AOP[deg], MA[deg], Epoch[JD], muPlanet[km3/s2], rPlanet [km], LowPlanetOrbitRadius[km]]
oe_table = [1.524*AU, 0.094, 1.851, 49.579, 336.041, 355.453, 2451545.0, 42828, 3389.5, input.LMO;...       % Mars
          1.000*AU, 0.0167, 0.000, -11.261, 102.947, 100.464, 2451545.0, 398600.44158, 6371, input.LEO];  % Earth
oe = data(:,1:7);
oe(:,8:10) = zeros (length(oe),3);
oe(:,9:10) = 1;
oe(:,1) = AU*oe(:,1);

oe_table = [oe_table; oe];

oe_table = oes_update(oe_table, input.Modeling_Start); % Update orbital elements 
N_Material_source = size(oe_table, 1) - 1;    % number of material sources

% The parameters are used as an input to preprocess function
consts.T_0 = input.Modeling_Start;                 % start of schedule in JD
consts.T_f = input.Modeling_time;                  % length of schedule - Campaign duration (days)
consts.dT = input.LD_dt;                              % schedule search increment (days)
consts.T_t_0 = input.min_TOF;                      % transfer search start (days)
consts.T_t_f = input.max_TOF;                      % transfer search end (days)
consts.dT_t = input.TOF_dt;                                   % transfer search increment (days)
consts.dV_max = input.dV_max;
consts.Material_source = N_Material_source;
consts.k = 1;					% number of future transfers to explore (k = 1 for extra speed)
consts.M = N_Material_source;

% Calculating dV maps for forward and backwards transfers between Mars and potential mining sites
tic;
transfers = multisite_transfer_list(oe_table, consts);
toc;

dV_map = calculate_dV_map(oe_table(1,:), oe_table(2,:), consts);
plot_dV_map(dV_map, input, 20);

% % LD = linspace(input.Modeling_Start, input.Modeling_Start + input.Modeling_time, input.Modeling_time/input.LD_dt);
% % TOF = linspace(input.min_TOF, input.max_TOF, (input.max_TOF-input.min_TOF)/input.TOF_dt);
% 
% % % algorithmic constants: determine value computation and algorithmic feasibility
% % M_pl = 10; 						% mass of payload
% % a = 2.5; 						% > 2 to encourage maximum exploration
% % p = a*consts.dV_max/M_pl; 		% price of material
% % consts.V_ret = p*M_pl; 			% calculated value of payload
% % b = a; 							% must be > a-1
% % consts.r_op = b*consts.dV_max/consts.T_t_0; % opportunity cost
% 
% 
% % Sorting all maps to the one corresponding to forward or backward transfers
% for i = 1:N_Material_source
%     forw_transfers{1,i} = transfers{1,i};
% end
% 
% for i = 1:N_Material_source
%     back_transfers{1,i} = transfers{1,N_Material_source + i};
% end
 
% deleterow = false(1, N_Material_source);
% deleterow1 = false(1, N_Material_source);
% deleterow2 = false(1, N_Material_source);
% 
% for i = 1:N_Material_source
%     deleterow1(1,i) = isempty(forw_transfers{1,i});
%     deleterow2(1,i) = isempty(back_transfers{1,i});
% end
% 
% for i = 1:N_Material_source
%     if deleterow1(1,i) == true || deleterow2(1,i) == true
%     deleterow(1,i) = true;
%     end
% end
% 
% deleterow_data = deleterow(1,2:end);
%  
% data_orbit(deleterow_data,:) = [];
% textdata(deleterow_data,:) = [];
% 
% oe = data_orbit(:,1:7);
% oe(:,8:10) = zeros (length(oe),3);
% oe(:,9:10) = 1;
% oe(:,1) = consts.AU*oe(:,1);
% 
% % Final list of elements in Interplanetary Network
% oe_table = [1.524*consts.AU, 0.094, 1.851, 49.579, 336.041, 355.453, 2451545.0, 42828, 3398.5, input.LMO;...       % Mars
%           1.000*consts.AU, 0.0167, 0.000, -11.261, 102.947, 100.464, 2451545.0, 398600.44158, 6317, input.LEO];  % Earth
% 
% oe_table = [oe_table;oe];
% 
% LD = linspace(input.Modeling_Start, input.Modeling_Start + input.Modeling_time, input.Modeling_time/input.LD_dt);
% TOF = linspace(input.min_TOF, input.max_TOF, (input.max_TOF-input.min_TOF)/input.TOF_dt);
% 
% oe_table = oes_update(oe_table, input.Modeling_Start); % Update orbital elements 
% N_Material_source = size(oe_table, 1) - 1;    % number of material sources
% 
% % Feature (should be updated)
% consts.T_0 = input.Modeling_Start;                 % start of schedule in JD
% consts.T_f = input.Modeling_time;              % length of schedule - Campaign duration (days)
% consts.dT = input.dT;                              % schedule search increment (days)
% consts.T_t_0 = input.min_TOF;                      % transfer search start (days)
% consts.T_t_f = input.max_TOF;                      % transfer search end (days)
% consts.dT_t = input.dt_TOF;                                   % transfer search increment (days)
% consts.dV_max = input.dV_max;
% consts.Material_source = N_Material_source;
% consts.k = 1;					% number of future transfers to explore (k = 1 for extra speed)
% consts.M = N_Material_source;
% 
% % % algorithmic constants: determine value computation and algorithmic feasibility
% % M_pl = 10; 						% mass of payload
% % a = 2.5; 						% > 2 to encourage maximum exploration
% % p = a*consts.dV_max/M_pl; 		% price of material
% % consts.V_ret = p*M_pl; 			% calculated value of payload
% % b = a; 							% must be > a-1
% % consts.r_op = b*consts.dV_max/consts.T_t_0; % opportunity cost
% 
% tic;
% transfers = preprocess(oes, consts);
% toc;
% 
% consts.transfers = transfers;
% 
% for i = 1:N_Material_source
%     forw_transfers_upd{1,i} = transfers{1,i};
% end
% 
% for i = 1:N_Material_source
%     back_transfers_upd{1,i} = transfers{1,N_Material_source + i};
% end
% 
% %% Split asteroids for supply with primary and secondary consumables
% deleterow_pr = false(1,N_Material_source-1);
% 
% for i = 2:6
%     deleterow_pr(i) = true;
% end
% for i = 8:15
%     deleterow_pr(i) = true;
% end
% 
% primary_consumables_data = data_orbit;
% primary_consumables_textdata = data_textdata;
% 
% primary_consumables_data(deleterow_pr,:) = []; 
% primary_consumables_textdata (deleterow_pr,:) = []; 
% 
% deleterow_sec = false(1,N_Material_source-1);
% 
% deleterow_sec(1,7) = true;
% deleterow_sec(1,8) = true;
% deleterow_sec(1,10) = true;
% deleterow_sec(1,15) = true;
% deleterow_sec(1,16) = true;
% 
% secondary_consumables_data = data_orbit;
% secondary_consumables_textdata = data_textdata;
% 
% secondary_consumables_data(deleterow_sec,:) = []; 
% secondary_consumables_textdata (deleterow_sec,:) = []; 
% 
% % %% transfers for supply with primary and secondary consumables
% % oe = primary_consumables_data(:,1:7);
% % oe(:,8:10) = zeros (3,3);
% % oe(:,9:10) = 1;
% % oe(:,1) = consts.AU*oe(:,1);
% % % Final list of elements in Interplanetary Network
% % oes_ep = [1.524*consts.AU, 0.094, 1.851, 49.579, 336.041, 355.453, 2451545.0, 42828, 3398.5, input.LMO;...       % Mars
% %           1.000*consts.AU, 0.0167, 0.000, -11.261, 102.947, 100.464, 2451545.0, 398600.44158, 6317, input.LEO];  % Earth
% % oes_ep = [oes_ep;oe];
% % LD = linspace(input.Modeling_Start, input.Modeling_Start + input.Modeling_time, input.Modeling_time/input.dT);
% % TOF = linspace(input.min_TOF, input.max_TOF, (input.max_TOF-input.min_TOF)/input.dt_TOF);
% % oes = oes_update(oes_ep, input.Modeling_Start); % Update orbital elements 
% % N_Material_source = size(oes, 1) - 1;    % number of material sources
% % 
% % tic;
% % transfers_primary = preprocess(oes, consts);
% % toc;
% % 
% %% transfers for supply with primary and secondary consumables
% consts.M = length(12);
% oe = secondary_consumables_data(:,1:7);
% oe(:,8:10) = zeros (length(oe),3);
% oe(:,9:10) = 1;
% oe(:,1) = consts.AU*oe(:,1);
% 
% % Final list of elements in Interplanetary Network
% oes_ep = [1.524*consts.AU, 0.094, 1.851, 49.579, 336.041, 355.453, 2451545.0, 42828, 3398.5, input.LMO;...       % Mars
%           1.000*consts.AU, 0.0167, 0.000, -11.261, 102.947, 100.464, 2451545.0, 398600.44158, 6317, input.LEO];  % Earth
% oes_ep = [oes_ep;oe];
% LD = linspace(input.Modeling_Start, input.Modeling_Start + input.Modeling_time, input.Modeling_time/input.dT);
% TOF = linspace(input.min_TOF, input.max_TOF, (input.max_TOF-input.min_TOF)/input.dt_TOF);
% oes = oes_update(oes_ep, input.Modeling_Start); % Update orbital elements 
% N_Material_source = size(oes, 1) - 1;    % number of material sources
% consts.M = N_Material_source;
% 
% tic;
% transfers_secondary = preprocess(oes, consts);
% consts.transfers = transfers_secondary;
% toc;
% 
% %%
% % exploration
% tic;
% [C, H] = explore(0, 0, 0, Inf, [], [], consts);
% toc;
% 
% 
% % postprocessing
% postprocess(H, consts);
% 
% Supply_Schedule_t = [0, 36, 486, 771, 1046, 1289, 1648, 1688, 2143, 2262, 2785, 3123,...
%     3482, 3802, 4105, 4635, 4959, 5244, 5841, 6049, 6338, 7300];
% Supply_Schedule_Date = Supply_Schedule_t + juliandate(datetime(2050,1,1,0,0,0));
% Supply_Schedule_dest = [0, 0, 5, 5, 0, 0, 12, 12, 0, 0, 12, 12, 0, 0, 1, 1,...
%     0, 0, 2, 2, 0, 0];
% 
% Supply_schedule = [Supply_Schedule_t; Supply_Schedule_dest];
% 
% figure(5);
% plot(Supply_Schedule_Date, Supply_Schedule_dest);
% grid on;
% xlabel('Date');
% ylabel('Destination');
% 
% % %% Colony modeling
% % Pld = 1e3;
% % ISRU_rate = 3; % kg/day
% % Consumption_rate = 5; % kg/day
% % 
% % M_storage = zeros(consts.T_f,1);
% % M_storage(1) = 10e3;
% % 
% % for i = 1:1:1044
% %     M_storage(i+1) = M_storage(i) + ISRU_rate - Consumption_rate;
% % end
% % M_storage(1046) = M_storage(1045) + Pld + ISRU_rate - Consumption_rate;
% % 
% % for i = 1046:1:2141
% %     M_storage(i+1) = M_storage(i) + ISRU_rate - Consumption_rate;
% % end
% % M_storage(2143) = M_storage(2142) + Pld + ISRU_rate - Consumption_rate;
% % 
% % for i = 2143:1:3480
% %     M_storage(i+1) = M_storage(i) + ISRU_rate - Consumption_rate;
% % end
% % M_storage(3482) = M_storage(3481) + Pld + ISRU_rate - Consumption_rate;
% % 
% % 
% % for i = 3482:1:4957
% %     M_storage(i+1) = M_storage(i) + ISRU_rate - Consumption_rate;
% % end
% % M_storage(4959) = M_storage(4958) + Pld + ISRU_rate - Consumption_rate;
% % 
% % for i = 4959:1:6336
% %     M_storage(i+1) = M_storage(i) + ISRU_rate - Consumption_rate;
% % end
% % M_storage(6338) = M_storage(6337) + Pld + ISRU_rate - Consumption_rate;
% % 
% % for i = 6338:1:7299
% %     M_storage(i+1) = M_storage(i) + ISRU_rate - Consumption_rate;
% % end
% % 
% % plot(M_storage);
% % grid on;
% % xlabel('Date');
% % ylabel('Mass of materials in storage, kg');
% % legend('Consumption rate = 5 kg/d, ISRU = 3 kg/d, Payload mass = 1 ton');
% 
% %%
% % %% Plot DVmap
% % % Set the number of Arc you wanna plot
% % ArcNumber = 2;
% % for i = 1:length(LD)
% %     for j = 1:length(TOF)
% %         DV_map_with_threshold(i,j) = transfers(ArcNumber,i,j);     
% %         
% % %         if DV_map_with_threshold(i,j) > input.dV_max + 30;
% % %               DV_map_with_threshold(i,j) = NaN;  
% % %         end
% %         
% %     end
% % end
% % figure(1);
% % contour(LD, TOF, DV_map_with_threshold', 'fill', 'on');
% % colorbar;
% % grid on;
% % title('Delta-V map');
% % xlabel('Launch date, JD');
% % ylabel('Time of transfer, days');