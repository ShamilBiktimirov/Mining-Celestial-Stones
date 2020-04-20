function list = transfer_list(oe1, oe2, consts)
    mu = consts.mu;
    T_w = 1:consts.dT:consts.T_f;
    T_t = consts.T_t_0:consts.dT_t:consts.T_t_f;
    len_tw = length(T_w);
    len_tt = length(T_t);
    C = zeros(len_tw, len_tt);
    for i = 1:len_tw
        % departure state
        tw = T_w(i);
        [r1, v1] = oe2xyz(oe1, mu, tw);
        for j = 1:len_tt
            % arrival state
            tt = T_t(j);
            [r2, v2] = oe2xyz(oe2, mu, tw + tt);
            % transfer calculation
            m = 0;
            [v1_tr, v2_tr, ~] = lambert(r1, r2, tt, m, mu);
            dV = norm(v1_tr - v1) + norm(v2_tr - v2);
            C(i,j) = dV;
        end
    end
    list_raw = mins(C, consts.dV_max);
    % reorganize list for use in explore function
    len = size(list_raw, 1);
    list = zeros(len, 3);
    for k = 1:len
        i = list_raw(k, 1);
        j = list_raw(k, 2);
        list(k, 1) = T_w(i);
        list(k, 2) = T_t(j);
        list(k, 3) = C(i,j);
    end
end