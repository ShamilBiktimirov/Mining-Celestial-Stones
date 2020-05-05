function [r_ijk, v_ijk] = oe2xyz(oe, mu, t)
% Converts orbital elements (units: degrees) to ECI state
%
% Input:
%   * orbital elements
%   * gravitational parameter
%   * time since given mean anomaly [days]
% Output:
%   * ECI state [km, km/s]
d2r = pi/180;
n = sqrt(mu/oe(1)^3);
a = oe(1);
e = oe(2);
i = oe(3)*d2r;
O = oe(4)*d2r;
w = oe(5)*d2r;
M = oe(6)*d2r + n*86400*t;

E = mean2ecc(M, e);
v = 2*atan(sqrt((1 + e)/(1 - e))*tan(E/2));
r = a*(1-e^2)/(1+e*cos(v));
r_pqw = r*[cos(v); sin(v); 0];
v_pqw = sqrt(mu/(a*(1-e^2)))*[-sin(v); e+cos(v); 0];

Rz_O = [cos(O),-sin(O),0; sin(O),cos(O),0; 0,0,1];
Rx_i = [1,0,0; 0,cos(i),-sin(i); 0,sin(i),cos(i)];
Rz_w = [cos(w),-sin(w),0; sin(w),cos(w),0; 0,0,1];
R = Rz_O*Rx_i*Rz_w;

r_ijk = (R*r_pqw)';
v_ijk = (R*v_pqw)';
end