function [C_opt, H_opt] = explore(T, A, C, C_opt, H, H_opt, consts)

% Searches the decision tree for orbital transfers, dynamically eliminating
% suboptimal branches.
%
% Input:
%   * T: simulation time
%   * A: location index
%	* C: cost of current schedule 
%   * C_opt: optimal schedule cost
%	* H: detailed history of current schedule: [transfer destination, date, duration, dV]
%	* H_opt: optimal schedule history
%	* consts: program constants
% Output:
%   * C_opt: new optimal schedule cost
%	* H_opt: new optimal schedule history

    if C >= C_opt
    elseif T >= consts.T_f
        C_opt = C;
        H_opt = H;
    else
        for A_n = options(A, consts)
            ind = indexing(A, A_n, consts);
            transfers = consts.transfers{ind};
            remaining = transfers(find(transfers(:,1) > T, consts.k),:);
            for i = 0:size(remaining, 1)
                [T_n, C_n, H_n] = cost(T, A_n, C, H, remaining, i, ind, consts);
                [C_opt, H_opt] = explore(T_n, A_n, C_n, C_opt, H_n, H_opt, consts);
            end
        end
    end
end

function [T_n, C_n, H_n] = cost(T, A_n, C, H, remaining, i, ind, consts)
    if i == 0 % stay until end
        dT = consts.T_f - T;
        dC = consts.r_op*dT;
        H_n = H;
    else
        transfer = remaining(i,:);
        dT = transfer(1) - T + transfer(2);
        dC = consts.r_op*dT + transfer(3);
        if ind > consts.M % return trip
            dC = dC - consts.V_ret;  
        end
        H_n = [H; A_n, transfer];
    end
    T_n = T + dT;
    C_n = C + dC;
end


function opts = options(A, consts)
    % enumerate options
    if A == 0
        opts = 1:consts.M;
    else
        opts = 0;
    end
end

function ind = indexing(A, A_n, consts)
    % generate correct index
    if A == 0
        ind = A_n;
    else
        ind = A + consts.M;
    end
end
