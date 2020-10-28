function dV_map = calculate_dV_map(oe1, oe2, input)

    global muSun
    
    LD_vec = 1:input.LD_dt:input.Modeling_time;

    TOF_vec = input.min_TOF:input.TOF_dt:input.max_TOF;
    length_LD_vec = length(LD_vec);
    length_TOF_vec = length(TOF_vec);
    dV_map = zeros(length_LD_vec, length_TOF_vec);
    for i = 1:length_LD_vec
        % departure state
        tw = LD_vec(i);
        [r1, v1] = oe2xyz(oe1, muSun, tw);
        for j = 1:length_TOF_vec
            % arrival state
            tt = TOF_vec(j);
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
            
            InjectionDV = sqrt(dv1^2 + 2*oe1(8)/(oe1(9)+oe1(10))) - sqrt(oe1(8)/(oe1(9)+oe1(10)));
            InsertionDV = sqrt(dv2^2 + 2*oe2(8)/(oe2(9)+oe2(10))) - sqrt(oe2(8)/(oe2(9)+oe2(10)));
             
            dV = InjectionDV + InsertionDV;
            
            dV_map(i,j) = dV;
        end
    end    
end