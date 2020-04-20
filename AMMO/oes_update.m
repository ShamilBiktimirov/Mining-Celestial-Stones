function oes = oes_update(oes_ep, consts)
	d2r = pi/180;
	oes = oes_ep(:,1:6);
	for i = 1:size(oes, 1)
		n = sqrt(consts.mu/oes(i,1)^3);
		M_new = oes(i,6) + n*86400*(consts.T_0 - oes_ep(i,7))/d2r;
		oes(i,6) = mod(M_new, 360);
	end
end