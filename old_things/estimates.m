clear all;

% The script aims to define requirements for asteroids group

% 1. https://cneos.jpl.nasa.gov/about/neo_groups.html

% We consider different NEAs types [1] 
% Atiras a < 1.0 au; Q < 0.983 au (named after asteroid 163693 Atira)
% For atira the most suitable orbit is circular with 0.983 sma

% Atens a < 1.0 au; Q > 0.983 au (named after asteroid 2062 Aten)
% Apollos a > 1.0 au; q < 1.017 au (named after asteroid 1862 Apollo)
% Amors a > 1.0 au; 1.017 < q < 1.3 au (named after asteroids 1221 Amor)
% PHAs MOID <= 0.05 ; H > 140 m (Potential Hazardous asteroids)

% Mars q = 1.382, Q = 1.666

% Asteroid selection requirement verification


%  consts
au = 149597870700e-3; % astronomical unit, km
mu = 1.32712440019e11; % Sun gravitational parameter


Mars_Q = 249200000; % km
Mars_Q_au = 249200000/au; % km
Mars_q = 206700000; % km
Mars_q_au = 206700000/au; % km
Mars_a = (Mars_Q + Mars_q)/2; % km
Mars_vQ = sqrt(mu*(2/Mars_Q - 1/Mars_a)); % km/s
Mars_vq = sqrt(mu*(2/Mars_q - 1/Mars_a)); % km/s

% Best case parameters for transfer

Atiras_a = 0.983*au;
Atiras_v = sqrt(mu/Atiras_a); % km/s
disp(Atiras_v);


%% delta-v calculations
% For dv calculations notation the following scheme will be used
% Mars - 0, Atira - 1, Aten - 2, Apollo - 3, Amor - 4, tt is transfer
% trajectory

% Asteroid atira
tt_10_a = (Atiras_a + Mars_Q)/2; % km
tt_10_vq = sqrt(mu*(2/Atiras_a - 1/tt_10_a)); % km/s
tt_10_vQ = sqrt(mu*(2/Mars_Q  - 1/tt_10_a)); % km/s

dv1_Atira = tt_10_vq  - Atiras_v;
dv2_Atira = Mars_vQ - tt_10_vQ;
dv_Atira = dv1_Atira + dv2_Atira;


% Amor

