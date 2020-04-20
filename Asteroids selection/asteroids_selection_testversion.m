clear all

au = 149597870;     % astronomical unit in km

database = importdata('Asteroids_Database2.csv');
dV_max = 6.3;
 
dV = zeros(length(database),1);

for i = 1:length(dV)
    dV(i) = dV_shoemaker_Mars(database(i,1), database(i,2), database(i,3));   
    if dV(i) > dV_max
        dV(i) = 0;
    end
end
 
deleterow = false(length(dV), 1);

for n = 1:length(dV)
    if dV(n) == 0
        deleterow(n) = true;
    end
end

database(deleterow,:) = [];

disp('Asteroids Selection, Stage 1 - done');
