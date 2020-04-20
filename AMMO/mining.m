% Main script for AMMO.
%
% Searches for the highest-return mining schedule for a single spacecraft. 
% Initializes constants and dynamic program.

AU = 149597870;                 % astronomical unit in km
consts.mu = 1.327124e11;        % gravitational parameter
consts.T_0 = 2462502.5;         % start of schedule (JD): 1/1/2030
consts.T_f = 20*365;            % length of schedule (days)
consts.dT = 7;                  % schedule search increment (days)
consts.T_t_0 = 100;             % transfer search start (days)
consts.T_t_f = 2*365;           % transfer search end (days)
consts.dT_t = 7;                % transfer search increment (days)
consts.dV_max = 10;             % maximum dV capability per transfer
consts.k = 1;					% number of future transfers to explore (k = 1 for extra speed)

% algorithmic constants: determine value computation and algorithmic feasibility
M_pl = 10; 						% mass of payload
a = 2.5; 						% > 2 to encourage maximum exploration
p = a*consts.dV_max/M_pl; 		% price of material
consts.V_ret = p*M_pl; 			% calculated value of payload
b = a; 							% must be > a-1
consts.r_op = b*consts.dV_max/consts.T_t_0; % opportunity cost

% orbital elements with epoch appended (JD)
oes_ep = ...
    [1.524*AU, 0.094, 1.851, 49.579, 336.041, 355.453, 2451545.0;...  % Mars
    1.000*AU, 0.0167, 0.000, -11.261, 102.947, 100.464, 2451545.0;... % Earth
    1.190*AU, 0.190, 5.884, 251.620, 211.430, 3.983, 2455907.5;...    % Ryugu
    1.272*AU, 0.137, 4.378, 104.409, 183.283, 125.941, 2453667.5;...  % 1989 ML
    1.489*AU, 0.360, 1.432, 314.459, 158.019, 253.789, 2457400.5;...  % Nereus
    1.645*AU, 0.384, 3.408, 73.209, 319.300, 204.190, 2458000.5;...   % Didymos
    1.566*AU, 0.292, 7.087, 88.653, 275.551, 319.670, 2457400.5];     % 1992 TC

% update orbitals elements to start of schedule
oes = oes_update(oes_ep, consts);
consts.M = size(oes, 1) - 1;    % number of asteroids

% preprocessing
tic;
consts.transfers = preprocess(oes, consts);
toc;

% exploration
tic;
[C, H] = explore(0, 0, 0, Inf, [], [], consts);
toc;

% postprocessing
postprocess(H, consts)
