% The scipt aims to calculate dV map for Earth-Mars transfer

consts.AU = 149597870;                             % astronomical unit in km
consts.mu = 132712440018.8;                        % gravitational parameter of the Sun
consts.T_0 = juliandate(datetime(2030,1,1,0,0,0)); % start of schedule in JD
consts.T_f = 20*365;                               % length of schedule - Campaign duration (days)
consts.dT = 7;                                     % schedule search increment (days)
consts.T_t_0 = 200;                                % transfer search start (days)
consts.T_t_f = 300;                                % transfer search end (days)
consts.dT_t = 7;                                % transfer search increment (days)
LEO = 500;                                         % LEO start orbit
LMO = 500;                                         % LMO start orbit

% orbital elements with epoch appended (JD), gravitational parameter of a
% Body and 
oes_ep = [1.000*consts.AU, 0.0167, 0.000, -11.261, 102.947, 100.464, 2451545.0, 398600.44158, 6317, LEO;... % Earth
          1.524*consts.AU, 0.094, 1.851, 49.579, 336.041, 355.453, 2451545.0, 42828, 3398.5, LMO];          % Mars

% update orbitals elements to start of schedule
oes = oes_update(oes_ep, consts.T_0);

% Calculating dV map
tic;
dV_map_Earth_Mars = transfer_list(oes(1,:),oes(2,:), consts);
toc;

%% Plot DVmap
T_w = 1:consts.dT:consts.T_f;
T_w_vec_JD = T_w + consts.T_0;
T_w_vec_GD = datetime(T_w_vec_JD,'convertfrom','juliandate');
T_t_vec = consts.T_t_0:consts.dT_t:consts.T_t_f;

figure(1);
contour(T_w/365, T_t_vec, dV_map_Earth_Mars', 'fill', 'on');
colorbar;
title('Delta-V map');
xlabel('Years since mission start');
ylabel('Time of transfer, days');