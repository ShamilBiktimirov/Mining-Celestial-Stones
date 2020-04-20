clear all;

u_crew = -5; % consumption of a crew kg/day
Base_consumption = [-50,-100,-200]; % consumption of base kg/day
N_crews = [50, 100, 150];

ISRP= [ 200, 300, 400];

t = 1:1:5*365;

% There generation of crews arriving at 2050, 2055, 2060
% It is not allowd to produce babies at Mars at the moment

consumed = zeros(length(t),3);

for i = 1:3
    for j = 1:length(t)
        consumed(j+1,i) = consumed(j,i) + ISRP(i) +  u_crew*N_crews(i) + Base_consumption(i) ;    
    end    
end

consumed_total = consumed(:,1);

for i = 1:5*365
    consumed_total(5*365+i) = consumed(end,1) + consumed(i,2);
end

consumed_pvevrev = consumed_total(end);

for i = 1:5*365
    consumed_total(10*365+i) = consumed_pvevrev(end) + consumed(i,3);
end

plot(consumed_total);
grid on;
xlabel ('Days since campaign start');
ylabel ('Cumulutive consumed water, kg')

figure(1);
