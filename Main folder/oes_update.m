function oes = oes_update(oes_ep, Modeling_Start)
	d2r = pi/180;
    mu = 132712440018.8;                        % gravitational parameter of the Sun

	oes = oes_ep(:,1:10);
	for i = 1:size(oes, 1)
		n = sqrt(mu/oes(i,1)^3);
		M_new = oes(i,6) + n*86400*(Modeling_Start - oes_ep(i,7))/d2r;
		oes(i,6) = mod(M_new, 360);
	end
end