function [days_sun, days_wind, days_windandsun] = weather_day_identifier(input)
%year1, ...
 %   year2, lower_lim, upper_lim, wind_classifier, sun_classifier)
%UNTITLED Summary of this function goes here
year1 = input.firstyear.Value;
year2 = input.lastyear.Value;
low_lim = 0; %input.lower_limit;
up_lim = 1; %input.upper_limit;
quant = input.quantile*0.01;
type = input.type;
algo = input.algo;

%% load and rename explanatory variables
solar = load([input.path, 'Explanatory\', input.ExplanatoryVar1.Text]);
[~, input.ExplanatoryVar1.Text, ~] = fileparts(input.ExplanatoryVar1.Text);
solar = solar.(input.ExplanatoryVar1.Text);
wind = load([input.path, 'Explanatory\', input.ExplanatoryVar2.Text]);
[~, input.ExplanatoryVar2.Text, ~] = fileparts(input.ExplanatoryVar2.Text);
wind = wind.(input.ExplanatoryVar2.Text);
clear input.ExplanatoryVar1 input.ExplanatoryVar2

%% resize explanatory variables
solar(not(solar(:,1)>=year1 & solar(:,1) <= year2), :) = [];
wind(not(wind(:,1)>=year1 & wind(:,1) <= year2), :) = [];

%% from real value to percentage [0-100]
% percentage expresses the linear distance from 0: minimum value to 100: maximum value
percentage = true;

if percentage
    min_wind = min(wind(:,end));
    min_sun = min(solar(:,end));      
    wind(:, end) = (wind(:, end) - min_wind) ./ max(wind(:, end))*100;
    solar(:, end) = (solar(:, end) - min_sun) ./ max(solar(:, end))*100;
    clear min_wind min_sun
end
clear percentage
%% build new variable including the mean of wind and solar intensity
weatherintensity = wind(:,1:end-1);
temp(:,1) = wind(:,end);
temp(:,2) = solar(:,end);
weatherintensity = horzcat(weatherintensity, temp);
weatherintensity(:,end+1) = mean(temp,2);
clear temp

%% Identify and classify days in given interval
    % add fifth column with no. of day to resort the list back to its origin
    % after dark doldrum mask is created
    solar(:,end+1) = 1:size(solar,1);
    wind(:,end+1) = 1:size(wind,1);
    weatherintensity(:,end+1) = 1:size(weatherintensity,1);
    % sort rows according to column including values
    % https://de.mathworks.com/help/matlab/ref/sortrows.html
    solar = sortrows(solar , size(solar,2)-1); 
    wind = sortrows(wind , size(wind,2)-1); 
    weatherintensity = sortrows(weatherintensity , size(weatherintensity,2)-1); 
    
    % preallocate ws and sun mask
    ws_size = size(wind,1);
    mask_ws = zeros(ws_size,2);
    rs_size = size(solar,1);
    mask_sun = zeros(rs_size,2);

%%
if strcmp(algo, 'quantile')
    numberofdays = round(size(weatherintensity,1)*quant);

    if strcmp(type, 'dd')
        mask_ws(1:numberofdays, 1) = 1;
        mask_sun(1:numberofdays, 1) = 1;
    elseif strcmp(type, 'bb')
        temp = size(wind,1);
        mask_ws(temp-numberofdays:temp, 1) = 1;
        mask_sun(temp-numberofdays:temp, 1) = 1;  
        clear temp
    end
    % wind only
        mask_ws(:,2) = wind(:,end); 
        clear lower_row upper_row
        mask_ws = sortrows(mask_ws, 2); %resort mask to original time
        mask_ws = logical(mask_ws(:,1)); %use first column as logical as mask
        wind = sortrows(wind , size(wind,2)); 
        wind(:,end) = [];
        days_wind = wind(mask_ws, 1:end);

    % solar only 

        mask_sun(:,2) = solar(:,end);
        clear lower_row upper_row
        mask_sun = sortrows(mask_sun, 2); %resort mask to original time
        mask_sun = logical(mask_sun(:,1)); %use first column as logical as mask
        solar = sortrows(solar , size(solar,2)); 
        solar(:,end) = [];
       
        days_wind(:, end+1) = solar(mask_ws, end);
        days_wind(:, end+1) = mean(days_wind(:, end-1:end), 2);
        % year month day wind solar mean
        days_sun = wind(mask_sun, 1:end);
        days_sun(:, end+1) = solar(mask_sun, end);
        days_sun(:, end+1) = mean(days_sun(:, end-1:end), 2); 
    % solar and wind combined    
    
    if strcmp(type, 'dd')
        %determine limits
        lim = 0;
        nn = 0;
        while nn <= numberofdays
            lim = lim+1;
            mask = weatherintensity(:,end-3) <= lim & weatherintensity(:,end-2) <= lim;
            nn = sum(mask);
        end
        clear mask
        lim = lim-1;
        nn = 0;
        while nn < numberofdays
            lim = lim+0.01;
            mask_wi = weatherintensity(:,end-3) <= lim & weatherintensity(:,end-2) <= lim;
            nn = sum(mask_wi);
        end
        clear nn 
        
        days_windandsun = weatherintensity(mask_wi, :);
        days_windandsun = sortrows(days_windandsun, size(days_windandsun,2));
        days_windandsun(:,end) = [];    
        
    elseif strcmp(type, 'bb') 
        lim = 100;
        nn = 0;
        while nn <= numberofdays
            lim = lim-1;
            mask = weatherintensity(:,end-3) >= lim & weatherintensity(:,end-2) >= lim;
            nn = sum(mask);
        end
        clear mask
        lim = lim+1;
        nn = 0;
        while nn < numberofdays
            lim = lim-0.01;
            mask_wi = weatherintensity(:,end-3) >= lim & weatherintensity(:,end-2) >= lim;
            nn = sum(mask_wi);
        end
        clear nn 
        
        days_windandsun = weatherintensity(mask_wi, :);
        days_windandsun = sortrows(days_windandsun, size(days_windandsun,2));
        days_windandsun(:,end) = [];  
        clear kk
    end
    

elseif strcmp(algo, 'limits')
    % wind only 
        min_wind = min(wind(:,end-1));
        max_wind = max(wind(:,end-1));  
        length_wind = max_wind - min_wind;
        
        lower_limit = min_wind + length_wind * low_lim;
        upper_limit = min_wind + length_wind * up_lim;
        mask_ws(lower_limit <= wind(:,end-1) & wind(:,end-1) < upper_limit) = 1;
        mask_ws(:,2) = wind(:,end);
        clear lower_limit upper_limit 
        clear min_wind max_wind length_wind
        mask_ws = sortrows(mask_ws, 2); %resort mask to original time
        mask_ws = logical(mask_ws(:,1)); %use first column as logical as mask
        wind = sortrows(wind , size(wind,2)); 
        wind(:,end) = [];
        days_wind = wind(mask_ws, 1:end);
        
        
        % solar only 
        min_sun = min(solar(:,end-1));  
        max_sun = max(solar(:,end-1));
        length_sun = max_sun - min_sun;
        
        lower_limit = min_sun + length_sun * low_lim;
        upper_limit = min_sun + length_sun * up_lim;
        mask_sun(lower_limit <= solar(:,end-1) & solar(:,end-1) < upper_limit) = 1;
        mask_sun(:,2) = solar(:,end); 
        
        clear lower_limit upper_limit
        clear min_sun max_sun length_sun
        mask_sun = sortrows(mask_sun, 2); %resort mask to original time
        mask_sun = logical(mask_sun(:,1)); %use first column as logical as mask
        solar = sortrows(solar , size(solar,2)); 
        solar(:,end) = [];
        days_sun = solar(mask_sun, 1:end);
        
       % solar and wind combined
       mask_comb = mask_sun & mask_ws; % both arrays have same order now, combination is possible
       days_windandsun = horzcat(wind(mask_comb, 1:end),solar(mask_comb, end));
    
    
end


    dt = datetime(days_sun(:,1:3));
    days_sun(:,end+1) = day(dt, 'dayofyear');
    clear dt
    
    dt = datetime(days_wind(:,1:3));
    days_wind(:,end+1) = day(dt, 'dayofyear');
    clear dt
    
    dt = datetime(days_windandsun(:,1:3));
    days_windandsun(:,end+1) = day(dt, 'dayofyear');
    clear dt


end

