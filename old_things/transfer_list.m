function C = transfer_list(oe1, oe2, consts)

    global muSun
    
    T_w = 1:consts.dT:consts.T_f;
    T_t = consts.T_t_0:consts.dT_t:consts.T_t_f;
    len_tw = length(T_w);
    len_tt = length(T_t);
    C = zeros(len_tw, len_tt);
    for i = 1:len_tw
        % departure state
        tw = T_w(i);
        [r1, v1] = oe2xyz(oe1, muSun, tw);
        for j = 1:len_tt
            % arrival state
            tt = T_t(j);
            [r2, v2] = oe2xyz(oe2, muSun, tw + tt);
            % transfer calculation
            m = 0;
            [v1_tr, v2_tr, ~] = lambert(r1, r2, tt, m, muSun);
                
            
            in_orbit_norm = cross(r1,v1);
            transfer_normal = cross(r1,v1_tr);
            angle_between_normal = 2 * atan(norm(in_orbit_norm*norm(transfer_normal) - norm(in_orbit_norm)*transfer_normal) / norm(in_orbit_norm * norm(transfer_normal) + norm(in_orbit_norm) * transfer_normal));
 
            if angle_between_normal > pi/2
                 [v1_tr, v2_tr, ~] = lambert(r1, r2, -tt, m,  muSun);
            end
         
            % Patched conic approximation
            dv1 = norm(v1_tr - v1);
            dv2 = norm(v2_tr - v2);
            
            InjectionDV = sqrt(dv1^2 +2*oe1(8)/(oe1(9)+oe1(10))) - sqrt(oe1(8)/(oe1(9)+oe1(10)));
            InsertionDV = sqrt(dv2^2 +2*oe2(8)/(oe2(9)+oe2(10))) - sqrt(oe2(8)/(oe2(9)+oe2(10)));
             
            dV = InjectionDV + InsertionDV;
            
            C(i,j) = dV;
        end
    end    
end