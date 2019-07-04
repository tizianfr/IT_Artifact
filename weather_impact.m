function [impact_DD, impact_BB] = weather_impact(input, days_DD, days_BB)
% Matches events of a dependent variable saved in input with the events of
% the variables saved in days_DD and days_BB. The script strives to get the
% values of the input-file for the respective events, split it in the three 
% samples: low extreme, non-extreme, and high extreme. 
% It makes hypothesis tests with the three samples

% get first and last year of observation
year1 = input.firstyear.Value;
year2 = input.lastyear.Value;

% load dependent variable and rename it to impact_var
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
% start with low extremes
for ii = 1:size(days_DD, 1)
    
    temp_observation = days_DD(ii,1:end-4);
    mask_DD.impact_var = mask_DD.impact_var + ismember(impact_var(:,1:end-1), temp_observation, 'rows');
    
end

clear temp_observation ii
% continue with high extremes
 for ii = 1:size(days_BB, 1)
    
    temp_observation = days_BB(ii,1:end-4);
    mask_BB.impact_var = mask_BB.impact_var + ismember(impact_var(:,1:end-1), temp_observation, 'rows');
   
 end   
 
 clear temp_observation ii
 
 %% Sample splitting
% split samples in s1 == low extremes, s2 = non-extremes, s3 ==
% high-extremes. s2 contains the events that are not included in s1 and s2
% and are thus not considered extreme
s1 = impact_var(logical(mask_DD.impact_var), :);
s2 = impact_var(not(logical(mask_DD.impact_var + mask_BB.impact_var)), :);
s3 = impact_var(logical(mask_BB.impact_var), :);

clear mask_DD mask_BB

% script has sometimes problems with saving the three samples in the
% workspace in time. Make a pause and continue with the script when sample
% s3 appears in the workspace
while exist('s3', 'var') == 0
    pause(0.5);
end

%% Check impact of explanatory variable on dependent variable
% compare each extreme sample (s1, s3) with non-extreme sample (s2)
impact_DD.(input.dependent.Text) = hypothesis_tests(s1, s2, size(s1,2));
impact_BB.(input.dependent.Text) = hypothesis_tests(s3, s2, size(s3,2));

clear input
clear impact_var s1 s2 s3

end

