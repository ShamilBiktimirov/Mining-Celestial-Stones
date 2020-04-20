function NEAs = asteroid_selection(dV_max,database1,database2)

au = 149597870;     % astronomical unit in km

% database1 = importdata('Asteroids_preprocess.csv');
% database2 = importdata('Asteroids_oes.csv');
% dV_max = 6.3;

NEAs.preliminary.data = database1.data;
NEAs.preliminary.objectname = database1.textdata;
NEAs.oes = database2.data;

for i = 1:length(NEAs.preliminary.data)
    dV(i) = dV_shoemaker_Mars(NEAs.preliminary.data(i,1),NEAs.preliminary.data(i,2),NEAs.preliminary.data(i,3));   
    if dV(i) > dV_max
        dV(i) = 0;
    end
end

% logical vector aims to delete unappropriate rows
deleterow = false(length(dV), 1);

for n = 1:length(dV)
    if dV(n) == 0
        deleterow(n) = true;
    end
end

% delete rows
dV(deleterow) = [];

NEAs.final = NEAs.preliminary;

for i = 1:7
    NEAs.final.data(:,4+i) = NEAs.oes(:,i);
end

NEAs.final.data(deleterow,:) = [];
NEAs.final.objectname(deleterow) = [];

% Cost function for NEA, cost = numberofmaterialdiameter/dV^2
NEAs.final.data(:,12) = dV(:);
NEAs.final.data(:,13) = NEAs.final.data(:,4)./NEAs.final.data(:,12).^2;


NEAs.final.data = sortrows(NEAs.final.data,13,'descend');
num = 1:length(NEAs.final.data);


% Uncomment it is necessary
% figure(1);
% plot(num,NEAs.final.data(:,13),'*');
% grid on;
% title('Distribution of the selected asteroid');
% xlabel('Asteroid number');
% ylabel('Profit');
% legend('Profit function - Asteroids size/DVmin^2');

for i = 1:7
    NEAs.final.data(:,i) = NEAs.final.data(:,4+i);
end

for i = 1:3
    NEAs.final.data(:,7+i) = zeros(length(num),1);
end

for i = 9:10
    for j = 1:length(num)
        NEAs.final.data(j,i) = 1;
    end
end

NEAs.final.data(:,1) = au*NEAs.final.data(:,1);

NEAs.final.phys(:,1) = NEAs.final.data(:,4);
NEAs.final.phys(:,2) = NEAs.final.data(:,12);
NEAs.final.phys(:,3) = NEAs.final.data(:,13);

NEAs.final.data(:,13) = [];
NEAs.final.data(:,12) = [];
NEAs.final.data(:,11) = [];

NEAs = NEAs.final;
disp('Asteroids Selection, Stage 1 - done');
end
