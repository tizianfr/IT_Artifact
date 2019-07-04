function [days_sun, days_wind, days_windandsun] = weather_event_identifier(input)
% This function identifies extreme weather events. The temporal resolution
% of the events is not set. The requirement of the explanatory dataset concerns
% its structure. The first columns are the time stamp. The last column
% needs to be the weather value. How many time columns there are is not
% set. The columns can for example be: Year, Month, Day, [Hour], Value

year1 = input.firstyear.Value; % Defines the first year of observation
year2 = input.lastyear.Value; % Defines the last year of observation
type = input.type; % 'dd' | 'bb' - terms refer to dark doldrum and bright breeze
algo = input.AlgorithmtypeButtonGroup.SelectedObject.Text; % 'quantile' | 'limits'
limit = input.limit*0.01; % convert limit from % to decimal
quant = input.quantile*0.01; % adjust quantile size from percentage to decimal


%% load and rename explanatory variables
% solar radiation variable
solar = load([input.path, 'Explanatory\', input.ExplanatoryVar1.Text]);
[~, input.ExplanatoryVar1.Text, ~] = fileparts(input.ExplanatoryVar1.Text);
solar = solar.(input.ExplanatoryVar1.Text);

% wind speed variable
wind = load([input.path, 'Explanatory\', input.ExplanatoryVar2.Text]);
[~, input.ExplanatoryVar2.Text, ~] = fileparts(input.ExplanatoryVar2.Text);
wind = wind.(input.ExplanatoryVar2.Text);

clear input.ExplanatoryVar1 input.ExplanatoryVar2

%% resize explanatory variables
% cut-off years that are not within observation range
solar(not(solar(:,1)>=year1 & solar(:,1) <= year2), :) = [];
wind(not(wind(:,1)>=year1 & wind(:,1) <= year2), :) = [];

%% from real value to percentage [0-100]
% percentage expresses the linear distance from 0: minimum value to 100: maximum value
% find minimum values in datasets
min_wind = min(wind(:,end));
min_sun = min(solar(:,end));   

% subtract the minimum value of each row. Divide result by maximum value of
% dataset. Take value times 100 to get from decimal to percentage.
wind(:, end) = (wind(:, end) - min_wind) ./ max(wind(:, end))*100;
solar(:, end) = (solar(:, end) - min_sun) ./ max(solar(:, end))*100;

% clear variables not required any longer
clear min_wind min_sun percentage

%% build new variable including the mean of wind and solar intensity
% get time information from wind variable. 
weatherintensity = wind(:,1:end-1);
temp(:,1) = wind(:,end);
temp(:,2) = solar(:,end);

% add wind and solar values
weatherintensity = horzcat(weatherintensity, temp);

% add mean of wind and solar value in last column
weatherintensity(:,end+1) = mean(temp,2);
clear temp

%% Add column and sort rows according to weather value
% add fifth column with number of event (ascending number)
% [to resort the list back to its origin after dark doldrum mask is created]
solar(:,end+1) = 1:size(solar,1);
wind(:,end+1) = 1:size(wind,1);
weatherintensity(:,end+1) = 1:size(weatherintensity,1);

% sort rows respective the column that contains weather values (end-1)
% https://de.mathworks.com/help/matlab/ref/sortrows.html
solar = sortrows(solar , size(solar,2)-1); 
wind = sortrows(wind , size(wind,2)-1); 
weatherintensity = sortrows(weatherintensity , size(weatherintensity,2)-1);

%% preallocate ws and sun mask for speed improvement
mask_ws = zeros(size(wind,1),2);
mask_sun = zeros(size(solar,1),2);

%% Identify weather events
% Chose different branch dependent on algoritm type 'quantile' or 'limits'

% Quantile
if strcmp(algo, 'Quantiles')
    
    %calculate number of events to be identified for given quantile size
    numberofevents = round(size(weatherintensity,1)*quant);
    
    % weather values are already sorted respective their intensity 
    % Set mask entries == 1 for number of events to be identified
    % start for dark doldrums with smallest value, and for bright breezes
    % with highest value
    if strcmp(type, 'dd')
        mask_ws(1:numberofevents, 1) = 1;
        mask_sun(1:numberofevents, 1) = 1;
    elseif strcmp(type, 'bb')
        temp = size(wind,1);
        mask_ws(temp-numberofevents:temp, 1) = 1;
        mask_sun(temp-numberofevents:temp, 1) = 1;  
        clear temp
    end
    
    % Calculation for wind-only observation
        mask_ws(:,2) = wind(:,end); % adopt column with order-information into matrix
        mask_ws = sortrows(mask_ws, 2); % resort mask to original order
        mask_ws = logical(mask_ws(:,1)); % create logical mask with first row
        wind = sortrows(wind , size(wind,2)); % resort wind-value-matrix to original order
        wind(:,end) = []; % delete column containing the information about the order
        days_wind = wind(mask_ws, 1:end); % create matrix containing extreme wind events

    % Calculation for solar-only observation
        mask_sun(:,2) = solar(:,end); % adopt column with order-information into matrix
        mask_sun = sortrows(mask_sun, 2); %resort mask to original order
        mask_sun = logical(mask_sun(:,1)); % create logical mask with first row
        solar = sortrows(solar , size(solar,2)); % resort solar-value-matrix to original order
        solar(:,end) = []; % delete column containing the information about the order 
        % Structure of both solar and wind extreme events
        % TIME Columns[year|month|day|...] | Wind | Solar | Mean       
        days_wind(:, end+1) = solar(mask_ws, end); % add solar values to wind-extreme-event-matrix
        days_wind(:, end+1) = mean(days_wind(:, end-1:end), 2); % add wind and solar mean to wind-extreme-event-matrix
        days_sun = wind(mask_sun, 1:end); % add wind values to solar-extreme-event-matrix
        days_sun(:, end+1) = solar(mask_sun, end); % add solar values to solar-extreme-event-matrix
        days_sun(:, end+1) = mean(days_sun(:, end-1:end), 2); % add means values to solar-extreme-event-matrix
        
    % Observation of Solar and Wind combined   
    if strcmp(type, 'dd')
        %Determine limits. Start with zero.
        lim = 0;
        nn = 0;
        while nn <= numberofevents
            % increase limit by 1% per loop. Find events where values are
            % lower than this limit for both wind and solar intensity
            lim = lim+1;
            mask = weatherintensity(:,end-3) <= lim & weatherintensity(:,end-2) <= lim;
            % count events that are under the new limit. If this number
            % excees the numberofevents, the loop stops
            nn = sum(mask);
        end
        clear mask
        lim = lim-1; % reduce limit by -1 and repeat loop with smaller steps 
        % of 0.01 to receive a limit of higher temporal resolution
        nn = 0;
        while nn < numberofevents
            lim = lim+0.01;
            mask_wi = weatherintensity(:,end-3) <= lim & weatherintensity(:,end-2) <= lim;
            nn = sum(mask_wi);
        end
        clear nn 
        % create matrix with days when wind and sun are under the
        % identified intensity limit
        days_windandsun = weatherintensity(mask_wi, :);
        days_windandsun = sortrows(days_windandsun, size(days_windandsun,2)); % resort rows to original order 
        days_windandsun(:,end) = [];    % delete column with order-specific information
        
    elseif strcmp(type, 'bb') 
        % determine limits. Start with 100 and descend.
        lim = 100;
        nn = 0;
        while nn <= numberofevents
            % decrease limit by 1% per loop. Find events where values are
            % higher than this limit for both wind and solar intensity
            lim = lim-1;
            mask = weatherintensity(:,end-3) >= lim & weatherintensity(:,end-2) >= lim;
            % count events that are above the new limit. If this number
            % excees the numberofevents, the loop stops
            nn = sum(mask);
        end
        clear mask
        lim = lim+1; % raise limit by +1 and repeat loop with smaller steps 
        % of 0.01 to receive a limit of higher temporal resolution
        nn = 0;
        while nn < numberofevents
            lim = lim-0.01;
            mask_wi = weatherintensity(:,end-3) >= lim & weatherintensity(:,end-2) >= lim;
            nn = sum(mask_wi);
        end
        clear nn 
        % create matrix with days when wind and sun are above the
        % identified intensity limit
        days_windandsun = weatherintensity(mask_wi, :);
        days_windandsun = sortrows(days_windandsun, size(days_windandsun,2)); % resort rows to original order 
        days_windandsun(:,end) = [];  % delete column with order-specific information
        clear kk
    end
    

elseif strcmp(algo, 'Limits')
        
    % Find minimum, maximum, and length of wind and solar variable
    min_wind = min(wind(:,end-1));
    max_wind = max(wind(:,end-1));  
    length_wind = max_wind - min_wind;
    
    min_sun = min(solar(:,end-1));  
    max_sun = max(solar(:,end-1));
    length_sun = max_sun - min_sun;
    
    % calculate limits 
    if strcmp(type, 'dd')
        
        lower_limit_wind = 0;
        upper_limit_wind = min_wind + length_wind * limit;
        lower_limit_sun = 0;
        upper_limit_sun = min_sun + length_sun * limit;
        
    elseif strcmp(type, 'bb')
        
        lower_limit_wind = min_wind + length_wind * limit;
        upper_limit_wind = 100;   
        
        lower_limit_sun = min_sun + length_sun * limit;
        upper_limit_sun = 100;
        
    end
        % build mask of wind values == 1 if value is within limits
        mask_ws(lower_limit_wind <= wind(:,end-1) & wind(:,end-1) < upper_limit_wind) = 1;
        mask_ws(:,2) = wind(:,end);
        % build mask of solar values == 1 if value is within limits
        mask_sun(lower_limit_sun <= solar(:,end-1) & solar(:,end-1) < upper_limit_sun) = 1;
        mask_sun(:,2) = solar(:,end); 
        
        clear lower_limit_wind upper_limit_wind lower_limit_sun upper_limit_sun
        clear min_wind max_wind length_wind min_sun max_sun length_sun
        
        % Create matrix of extreme wind events
        mask_ws = sortrows(mask_ws, 2); %resort wind mask to original order
        mask_ws = logical(mask_ws(:,1)); %create logical mask with first row
        wind = sortrows(wind , size(wind,2)); %resort wind-matrix to original order
        wind(:,end) = []; % delete column containing order-information
        days_wind = wind(mask_ws, 1:end);
        
        %Create matrix of extreme solar events
        mask_sun = sortrows(mask_sun, 2); %resort solar mask to original time
        mask_sun = logical(mask_sun(:,1)); %create logical mask with first row
        solar = sortrows(solar , size(solar,2)); %resort solar-matrix to original order
        solar(:,end) = []; % delete column containing order-information
        
            
       % Structure of both solar and wind extreme events
       % TIME Columns[year|month|day|...] | Wind | Solar | Mean  
       
        days_wind(:, end+1) = solar(mask_ws, end); % add solar values to wind-extreme-event-matrix
        days_wind(:, end+1) = mean(days_wind(:, end-1:end), 2); % add wind and solar mean to wind-extreme-event-matrix

        days_sun = wind(mask_sun, 1:end); % add wind values to solar-extreme-event-matrix
        days_sun(:, end+1) = solar(mask_sun, end); % add solar values to solar-extreme-event-matrix
        days_sun(:, end+1) = mean(days_sun(:, end-1:end), 2); % add means values to solar-extreme-event-matrix
        
       % Observation of solar and wind combined
       mask_comb = mask_sun & mask_ws; % both arrays have same order now, combination is possible
       days_windandsun = horzcat(wind(mask_comb, 1:end),solar(mask_comb, end));
       days_windandsun(:,end+1) = mean(days_windandsun(:,end-1:end), 2);
       
       clear mask_comb mask_sun mask_ws wind solar
    
end

%% add column with day of year [1-365]
% add this column for each of the three resulting matrixes (wind, solar,
% and combined observation matrix)

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

