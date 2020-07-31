function postprocess(H, consts)
	dates = 1:consts.T_f;
	dvs = zeros(size(dates));
	dvs(H(:,2)) = H(:,4);
	dv_tot = cumsum(dvs);

	rets = zeros(size(dates));
	rets(H(2:2:end,2)) = consts.V_ret;
	rets_tot = cumsum(rets);

	figure
	plot(dates, dv_tot);
	hold on
	plot(dates, rets_tot);
	xlabel('Time [days]')
	ylabel('Value [\DeltaV]')
	title('Value vs. Time')
	legend('Cost', 'Revenue','Location','NorthWest')

	figure
	plot(dates, rets_tot - dv_tot);
	xlabel('Time [days]')
	ylabel('Net Profit [\DeltaV]')
	title('Net Profit vs. Time')
    
    
    schedule = [0, 0
                36, 0
                486, 5
                771, 5
                771+275, 0
                1289, 0
                1289+359, 15
                1688, 15
                1688+485, 0];
    figure 
    plot(schedule(:,1), schedule(:,2));
	xlabel('Time [days]')
	ylabel('Desination')
	title('Supply schedule')
    
    
    
    fprintf('\n');
    frmt = 'Destinaton: %d | Departure date: %5d | Transfer duration: %d | Cost: %3.1f\n';
    for i = 1:size(H,1)
        fprintf(frmt, H(i,1), H(i,2), H(i,3), H(i,4));
    end
    
    eff = sum(H(:,3))/consts.T_f; % fraction of mission time spent in transfer
    fprintf('\n');
	fprintf(' Total revenue returned: %5.3f\n', rets_tot(end));
	fprintf('    Total delta-v spent: %5.3f\n', dv_tot(end));
	fprintf('    Net profit returned: %5.3f\n', rets_tot(end) - dv_tot(end));
	fprintf('Mission time efficiency: %5.3f%%\n', 100*eff);
end

