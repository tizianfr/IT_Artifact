function [impact_DD, impact_BB] = weather_impact(input, days_DD, days_BB)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

year1 = input.firstyear.Value;
year2 = input.lastyear.Value;
impact_var = load([input.path, input.dependent.Text]);
[~, input.dependent.Text, ~] = fileparts(input.dependent.Text);
impact_var = impact_var.(input.dependent.Text);

%% resize variable 
% exclude rows that are not included in the considered period
impact_var(not(impact_var(:,1)>=year1 & impact_var(:,1) <= year2), :) = [];
clear year1 year2
%% initialize mask that is true == 1 for given input day matrix and false == 0 for other days
% Impacts

mask_DD.impact_var = zeros(size(impact_var,1),1);
mask_BB.impact_var = zeros(size(impact_var,1),1);
%% build masks for dependent variables
% mask == 1 if observation of explanatory variable is existing in dependent variable 
for ii = 1:size(days_DD, 1)
    
    temp_observation = days_DD(ii,1:end-4);
    mask_DD.impact_var = mask_DD.impact_var + ismember(impact_var(:,1:end-1), temp_observation, 'rows');
    
end

clear temp_observation ii

 for ii = 1:size(days_BB, 1)
    
    temp_observation = days_BB(ii,1:end-4);
    mask_BB.impact_var = mask_BB.impact_var + ismember(impact_var(:,1:end-1), temp_observation, 'rows');
   
 end   
 
 clear temp_observation ii
 
 %% Sample splitting

s1 = impact_var(logical(mask_DD.impact_var), :);
s2 = impact_var(not(logical(mask_DD.impact_var + mask_BB.impact_var)), :);
s3 = impact_var(logical(mask_BB.impact_var), :);

clear mask_DD mask_BB

while exist('s3', 'var') == 0
    pause(0.5);
end
clear a
%% Check impact of explanatory variable on dependent variable
% compare each extreme sample (s1, s3) with non-extreme sample (s2)
impact_DD.(input.dependent.Text) = hypothesis_tests(s1, s2, size(s1,2));
impact_BB.(input.dependent.Text) = hypothesis_tests(s3, s2, size(s3,2));

clear input
clear impact_var s1 s2 s3
%% load variables
% IMPACT VARIABLES
% load([pwd,'\Variables\price_day_ahead_DE_daily.mat']); %2006-Mai2018
% load([pwd,'\Variables\NRV_Saldo_daily.mat']) % 2013-2017 % available on TransnetBW from 2010-2018
% load([pwd,'\Variables\NRV_SRL_daily.mat']) % 2013-2017
% load([pwd,'\Variables\NRV_MRL_daily.mat']) % 2013-2017
% load([pwd,'\Variables\load_DE_daily.mat']) % 2006-2017
% load([pwd,'\Variables\rebap_daily.mat']) % 2010-2018
% load([pwd,'\Variables\wind_generation_daily.mat']) % 2010-2017
% load([pwd,'\Variables\solar_generation_daily.mat']) % 2012-2017
% load([pwd,'\Variables\trade_daily.mat'])
% %load('realized_gen_aggregated_daily.mat') % 2015-2018
% 
% 
% % EVALUATION VARIABLES
% load([pwd,'\Variables\Explanatory\windspeed_DE_daily.mat']) % 1980 - 2016
% load([pwd,'\Variables\Explanatory\radiation_sum_DE_daily.mat']) % 1980 - 2016
% load([pwd,'\Variables\temperature_DE_daily.mat']) % 1980 - 2016
%% rename variables
% 
% eprice = price_day_ahead_DE_daily;
% bp = NRV_Saldo_daily;
% % mrl and srl datasets contain in row 5 positive and in row 4 negative
% % values
% srl = NRV_SRL_daily(:,1:3);
% srl(:,4) = NRV_SRL_daily(:,end);
% mrl = NRV_MRL_daily(:,1:3);
% mrl(:,4) = NRV_MRL_daily(:,end);
% eload = load_DE_daily;
% rebap = rebap_daily;
% wind = wind_generation_daily;
% sun = solar_generation_daily;
% trade = trade_daily;
% % evaluation
% wind_eva = windspeed_DE_daily;
% sun_eva = radiation_sum_DE_daily;
% temp_eva = temperature_DE_daily;
% 
% clear temperature_DE_daily price_day_ahead_DE_daily NRV_Saldo_daily
% clear NRV_SRL_daily NRV_MRL_daily load_DE_daily rebap_daily
% clear wind_generation_daily solar_generation_daily
% clear windspeed_DE_daily radiation_sum_DE_daily trade_daily
%% resize variables
% radiation_sum_DE_daily(not(radiation_sum_DE_daily(:,1)>=year1 & radiation_sum_DE_daily(:,1) <= year2), :) = [];
% windspeed_DE_daily(not(windspeed_DE_daily(:,1)>=year1 & windspeed_DE_daily(:,1) <= year2), :) = [];

% eprice(not(eprice(:,1)>=year1 & eprice(:,1) <= year2), :) = [];
% bp(not(bp(:,1)>=year1 & bp(:,1) <= year2), :) = [];
% srl(not(srl(:,1)>=year1 & srl(:,1) <= year2), :) = [];
% mrl(not(mrl(:,1)>=year1 & mrl(:,1) <= year2), :) = [];
% %realized_gen_aggregated_daily.data(not(realized_gen_aggregated_daily.data(:,1)>=year1 ... 
%   %  & realized_gen_aggregated_daily.data(:,1) <= year2), :) = [];
% eload(not(eload(:,1)>=year1 & eload(:,1) <= year2), :) = [];
% rebap(not(rebap(:,1)>=year1 & rebap(:,1) <= year2), :) = [];
% wind(not(wind(:,1)>=year1 & wind(:,1) <= year2), :) = [];
% sun(not(sun(:,1)>=year1 & sun(:,1) <= year2), :) = [];
% trade(not(trade(:,1)>=year1 & trade(:,1) <= year2), :) = [];
% %EVALUATION 
% wind_eva(not(wind_eva(:,1)>=year1 & wind_eva(:,1) <= year2), :) = [];
% sun_eva(not(sun_eva(:,1)>=year1 & sun_eva(:,1) <= year2), :) = [];
% temp_eva(not(temp_eva(:,1)>=year1 & temp_eva(:,1) <= year2), :) = [];

%% initialize masks that are true == 1 for given input day matrix and false == 0 for other days
% Impacts
% mask_DD.eprice = zeros(size(eprice,1),1);
% mask_DD.bp = zeros(size(bp,1),1);
% mask_DD.srl = zeros(size(srl,1),1);
% mask_DD.mrl = zeros(size(mrl,1),1);
% mask_DD.rebap = zeros(size(rebap,1),1);
% mask_DD.solgen = zeros(size(sun,1),1);
% mask_DD.windgen = zeros(size(wind,1),1);
% mask_DD.trade = zeros(size(trade,1),1);
% 
% %Evaluation
% mask_DD.temperature = zeros(size(temp_eva,1),1);
% mask_DD.sun_eva = zeros(size(sun_eva,1),1);
% mask_DD.wind_eva = zeros(size(wind_eva,1),1);

%% build bright breeze masks
% % Impacts
% mask_BB.eprice = zeros(size(eprice,1),1);
% mask_BB.bp = zeros(size(bp,1),1);
% mask_BB.srl = zeros(size(srl,1),1);
% mask_BB.mrl = zeros(size(mrl,1),1);
% mask_BB.rebap = zeros(size(rebap,1),1);
% mask_BB.solgen = zeros(size(sun,1),1);
% mask_BB.windgen = zeros(size(wind,1),1);
% mask_BB.trade = zeros(size(trade,1),1);
% 
% %Evaluation
% mask_BB.temperature = zeros(size(temp_eva,1),1);
% mask_BB.sun_eva = zeros(size(sun_eva,1),1);
% mask_BB.wind_eva = zeros(size(wind_eva,1),1);
% %% build masks
% 
% for ii = 1:size(days_DD, 1)
%     temp_observation = [days_DD(ii,1) days_DD(ii,2) days_DD(ii,3)];
%     %Impacts
%     mask_DD.eprice = mask_DD.eprice + ismember(eprice(:,1:end-1), temp_observation, 'rows');
%     mask_DD.bp = mask_DD.bp + ismember(bp(:,1:3), temp_observation, 'rows');
%     mask_DD.srl = mask_DD.srl + ismember(srl(:,1:3), temp_observation, 'rows');
%     mask_DD.mrl = mask_DD.mrl + ismember(mrl(:,1:3), temp_observation, 'rows');
%     mask_DD.rebap = mask_DD.rebap + ismember(rebap(:,1:3), temp_observation, 'rows');
%     mask_DD.solgen = mask_DD.solgen + ismember(sun(:,1:3), temp_observation, 'rows');
%     mask_DD.windgen = mask_DD.windgen + ismember(wind(:,1:3), temp_observation, 'rows');
%     mask_DD.trade = mask_DD.trade + ismember(trade(:,1:3), temp_observation, 'rows');
%     % mask.realgen = ismember(realized_gen_aggregated_daily.data(:,1:3), temp_day, 'rows');
%     
%     % Evaluation
%     mask_DD.temperature = mask_DD.temperature + ismember(temp_eva(:,1:3), temp_observation, 'rows');
%     mask_DD.sun_eva = mask_DD.sun_eva + ismember(sun_eva(:,1:3), temp_observation, 'rows');
%     mask_DD.wind_eva = mask_DD.wind_eva + ismember(wind_eva(:,1:3), temp_observation, 'rows');
% 
% end     
% clear temp_day ii
%    
%  for ii = 1:size(days_BB, 1)
%     temp_observation = [days_BB(ii,1) days_BB(ii,2) days_BB(ii,3)];
%     % Impacts
%     mask_BB.eprice = mask_BB.eprice + ismember(eprice(:,1:end-1), temp_observation, 'rows');
%     mask_BB.bp = mask_BB.bp + ismember(bp(:,1:3), temp_observation, 'rows');
%     mask_BB.srl = mask_BB.srl + ismember(srl(:,1:3), temp_observation, 'rows');
%     mask_BB.mrl = mask_BB.mrl + ismember(mrl(:,1:3), temp_observation, 'rows');
%     mask_BB.rebap = mask_BB.rebap + ismember(rebap(:,1:3), temp_observation, 'rows');
%     mask_BB.solgen = mask_BB.solgen + ismember(sun(:,1:3), temp_observation, 'rows');
%     mask_BB.windgen = mask_BB.windgen + ismember(wind(:,1:3), temp_observation, 'rows');
%     mask_BB.trade = mask_BB.trade + ismember(trade(:,1:3), temp_observation, 'rows');
%     % mask.realgen = ismember(realized_gen_aggregated_daily.data(:,1:3), temp_day, 'rows');
%     
%     % Evaluation
%     mask_BB.temperature = mask_BB.temperature + ismember(temp_eva(:,1:3), temp_observation, 'rows');
%     mask_BB.sun_eva = mask_BB.sun_eva + ismember(sun_eva(:,1:3), temp_observation, 'rows');
%     mask_BB.wind_eva = mask_BB.wind_eva + ismember(wind_eva(:,1:3), temp_observation, 'rows');
%     
%    
%  end   
% clear temp_day ii
%     
        %mask.eprice = ismember(eprice(:,1:end-1), temp_day, 'rows');
%      for ii = 1:size(days_BB, 1)
%          temp_day = [days_BB(ii,1) days_BB(ii,2) days_BB(ii,3)];
%          mask_DD.exclude = mask_DD.eprice + ismember(eprice(:,1:end-1), temp_day, 'rows');
%      end 
     
%% SAMPLE SPLITTING 
% % IMPACTS
% %IMPACTS.maskexclude = mask.exclude;
% s1.eprice = eprice(logical(mask_DD.eprice), :);
% s2.eprice = eprice(not(logical(mask_DD.eprice + mask_BB.eprice)), :);
% s3.eprice = eprice(logical(mask_BB.eprice), :);
% 
% s1.bp = bp(logical(mask_DD.bp), :);
% s2.bp = bp(not(logical(mask_DD.bp + mask_BB.bp)), :);
% s3.bp = bp(logical(mask_BB.bp), :);
% 
% s1.srl = srl(logical(mask_DD.srl), :);
% s2.srl = srl(not(logical(mask_DD.srl + mask_BB.srl)), :);
% s3.srl = srl(logical(mask_BB.srl), :);
% 
% s1.mrl = mrl(logical(mask_DD.mrl), :);
% s2.mrl = mrl(not(logical(mask_DD.mrl + mask_BB.mrl)), :);  
% s3.mrl = mrl(logical(mask_BB.mrl), :); 
% 
% s1.rebap = rebap(logical(mask_DD.rebap), :);
% s2.rebap = rebap(not(logical(mask_DD.rebap + mask_BB.rebap)), :);  
% s3.rebap = rebap(logical(mask_BB.rebap), :);
% 
% s1.solgen = sun(logical(mask_DD.solgen), :);
% s2.solgen = sun(not(logical(mask_DD.solgen + mask_BB.solgen)), :);  
% s3.solgen = sun(logical(mask_BB.solgen), :);
% 
% s1.windgen = wind(logical(mask_DD.windgen), :);
% s2.windgen = wind(not(logical(mask_DD.windgen + mask_BB.windgen)), :);        
% s3.windgen = wind(logical(mask_BB.windgen), :);
% 
% s1.trade = trade(logical(mask_DD.trade), :);
% s2.trade = trade(not(logical(mask_DD.trade + mask_BB.trade)), :);        
% s3.trade = trade(logical(mask_BB.trade), :);
% 
% %% SAMPLE SPLITTING
% % Evaluation
% s1.temperature = temp_eva(logical(mask_DD.temperature), :);
% s2.temperature = temp_eva(not(logical(mask_DD.temperature + mask_BB.temperature)), :); 
% s3.temperature = temp_eva(logical(mask_BB.temperature), :);
% 
% s1.sun_eva = sun_eva(logical(mask_DD.sun_eva), :);
% s2.sun_eva = sun_eva(not(logical(mask_DD.sun_eva + mask_BB.sun_eva)), :); 
% s3.sun_eva = sun_eva(logical(mask_BB.sun_eva), :);
% 
% s1.wind_eva = wind_eva(logical(mask_DD.wind_eva), :);
% s2.wind_eva = wind_eva(not(logical(mask_DD.wind_eva + mask_BB.wind_eva)), :); 
% s3.wind_eva = wind_eva(logical(mask_BB.wind_eva), :);
        

% clear mask_DD mask_BB
  
%% Impacts variables


% % Impacts
% impact_DD.price = hypothesis_tests(s1.eprice, s2.eprice, 4);
% impact_DD.bp = hypothesis_tests(s1.bp, s2.bp, 4);
% impact_DD.srl = hypothesis_tests(s1.srl, s2.srl, 4)   ;
% impact_DD.mrl = hypothesis_tests(s1.mrl, s2.mrl, 4)  ;
% impact_DD.rebap = hypothesis_tests(s1.rebap, s2.rebap, 5) ; 
% impact_DD.solgen = hypothesis_tests(s1.solgen, s2.solgen, 4) ; 
% impact_DD.windgen = hypothesis_tests(s1.windgen, s2.windgen, 4) ;
% impact_DD.trade = hypothesis_tests(s1.trade, s2.trade, 4) ;
% %IMPACTS.realgen = hypothesis_tests();
% 
% % Evaluation
% evaluation.DD.temperature = hypothesis_tests(s1.temperature, s2.temperature, 4) ; 
% evaluation.DD.sun_eva = hypothesis_tests(s1.sun_eva, s2.sun_eva, 4) ; 
% evaluation.DD.wind_eva = hypothesis_tests(s1.wind_eva, s2.wind_eva, 4) ; 
% 
% %%
% impact_BB.price = hypothesis_tests(s3.eprice, s2.eprice, 4);
% impact_BB.bp = hypothesis_tests(s3.bp, s2.bp, 4);
% impact_BB.srl = hypothesis_tests(s3.srl, s2.srl, 4)   ;
% impact_BB.mrl = hypothesis_tests(s3.mrl, s2.mrl, 4)  ;
% impact_BB.rebap = hypothesis_tests(s3.rebap, s2.rebap, 5) ; 
% impact_BB.solgen = hypothesis_tests(s3.solgen, s2.solgen, 4) ; 
% impact_BB.windgen = hypothesis_tests(s3.windgen, s2.windgen, 4) ;
% impact_BB.trade = hypothesis_tests(s3.trade, s2.trade, 4) ;
% 
% % Evaluation
% evaluation.BB.temperature = hypothesis_tests(s3.temperature, s2.temperature, 4) ;
% evaluation.BB.sun_eva = hypothesis_tests(s3.sun_eva, s2.sun_eva, 4) ;
% evaluation.BB.wind_eva = hypothesis_tests(s3.wind_eva, s2.wind_eva, 4) ;
  
  %%  
    
    % proof / check of method: mean wind speed and mean solar radiation
    % should increase linear in each loop
%     Doublecheck.windspeed(1, 1) = mean(days_DD(:,4));
%     Doublecheck.windspeed(1, 3) = std(days_DD(:,4));
%     %
%     Doublecheck.solarrad(1, 1) = mean(days_DD(:,5));
%     Doublecheck.solarrad(1, 3) = std(days_DD(:,5));
    %
%     clear mask_price temp_day mask_realgen mask_temperature
%     clear mask_srl mask_mrl mask_bp
%     clear price ii balpower realized_gen temperature srl mrl
end

