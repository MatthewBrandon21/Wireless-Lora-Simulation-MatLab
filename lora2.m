timespan = 60*1000; %ms
timeinterval = 10; %ms
nrofslots = timespan/timeinterval;
freqspan = 125e3; %hz : 125khz
freqinterval = 100; %hz

start_channel = 1;
end_channel = 1;
nrofchannels = 1;
fiveperc = 0;

maxnrofdevices = 100;
devicestepsize = 1;
nrofdevices = devicestepsize:devicestepsize:maxnrofdevices;
nrofpackets = 1;
lora_duration = [07 5478  36];
%12 293  682
%07 5478  36

packetduration = lora_duration(:,3);
results = zeros(maxnrofdevices/devicestepsize, 2);

for nr = nrofdevices  
    ft = zeros(nrofslots, nrofchannels);    
    ft2 = zeros(nrofslots, nrofchannels);
    colission = zeros(nr, nrofpackets);
    sf = randi([start_channel end_channel], [nr nrofpackets]);
    %time = randi([1 floor(nrofslots - (packetduration*nrofpackets)/timeinterval)], [nr 1]);
    for i = 1:nr
        time_offset = floor((nrofslots - (packetduration(sf(i))*nrofpackets)/timeinterval) * rand(1,1));%time(i, 1);
        for p = 1:nrofpackets    
            for k = 0
                if (sf(i, p)+k<1) | (sf(i, p)+k>nrofchannels)
                    continue
                end
                duration = lora_duration(sf(i, p),3);
                for j = 1:duration/timeinterval
                   %freq(i, 1)
                   if j+time_offset > nrofslots
                       continue
                   end
                   if  ft(j+time_offset, sf(i, p)+k) == 0
                       ft(j+time_offset, sf(i, p)+k) = 1;
                       ft2(j+time_offset,sf(i, p)+k) = i; 
                   else
                        ft(j+time_offset, sf(i, p)+k) = ft(j+time_offset, sf(i, p)+k) + 1;
                        colission(i) = 1;
                        colission(ft2(j+time_offset,sf(i, p)+k)) = 1;
                   end
                end        
            end
            time_offset = ceil(time_offset + duration/timeinterval);
        end   
    end
    results(floor(nr/devicestepsize), 1) = sum(sum(colission));
    results(floor(nr/devicestepsize), 2) = 100*sum(sum(colission))/nr;
    fail = sum(colission, 2) == nrofpackets;
    if (results(floor(nr/devicestepsize), 2) < 5)
       fiveperc = nr; 
    end
end

fiveperc

figure1 = figure();
[hAx,hLine1,hLine2] = plotyy(nrofdevices,results(:, 1),nrofdevices,results(:, 2));
titlestring = sprintf('Lora packet collision simulation with \n %d devices', ...
        maxnrofdevices);
title(titlestring);
xlabel('Number of 25 byte  messages / minute') % x-axis label
ylabel(hAx(1), 'Nr of collisions or Fails') % y-axis label
ylabel(hAx(2), 'Packet error rate (%)') % y-axis label
legend('number of failed transmissions', 'PER');
grid on;

hold off;
