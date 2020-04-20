function transfers = preprocess(oes, consts)
    oe0 = oes(1,:);
    h = waitbar(0, 'Preprocessing...');
    for i = 1:consts.M
        oe1 = oes(i+1,:);
        transfers{i} = transfer_list(oe0, oe1, consts);
        waitbar((2*i-1)/(2*consts.M));
        transfers{consts.M + i} = transfer_list(oe1, oe0, consts);
        waitbar((2*i)/(2*consts.M));
    end
    close(h);
end