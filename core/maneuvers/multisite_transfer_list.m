function transfers = multisite_transfer_list(oe_table, input)
    oe_colony = oe_table(1,:); % the first body in 
    h = waitbar(0, 'Calculating transfer list...');
    for i = 1:input.n_mining_sites   
        
        % forward transfers
        oe_mining_site = oe_table(i+1,:);
        dV_map = calculate_dV_map(oe_colony, oe_mining_site, input);
        transfers{i} = calculate_transfer_list(dV_map,input);
        
        waitbar((2*i-1)/(2*input.n_mining_sites));

        % backward transfers        
        dV_map = calculate_dV_map(oe_mining_site, oe_colony, input);
        transfers{input.n_mining_sites + i} = calculate_transfer_list(dV_map,input);
 
        waitbar((2*i)/(2*input.n_mining_sites));
    
    end
    close(h);
end