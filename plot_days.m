function plot_days(app, days_DD, days_BB)
% Plots the identified extreme weather events. X-axis is the day of the
% year from 1 to 365. The y-axis is the intensity of the weather given as a
% percentage from 0 to 100 whereas 0 represents the minimum observed
% weather value and 100 the highest observed weather value (wind, solar
% radiation).

% if flag_3dfigure == 1 then another figure with the three axis wind speed,
% solar radiation, and intensity is plotted
flag_3dfigure = 0;

year1 = app.firstyear.Value;
year2 = app.lastyear.Value;

% scatter plot of wind speed intensity versus day of the year in the app
scatter(app.UIAxes, days_DD(:,end), days_DD(:,end-3), 'x');
hold(app.UIAxes, 'on');
scatter(app.UIAxes, days_BB(:,end), days_BB(:,end-3), 'x');

% scatter plot of solar rad intensity versus day of the year in the app
scatter(app.UIAxes2, days_DD(:,end), days_DD(:,end-2), 'x');
hold(app.UIAxes2, 'on');
scatter(app.UIAxes2, days_BB(:,end), days_BB(:,end-2), 'x');


figure(1);clf
%create figure 2 only if flag above == 1
if flag_3dfigure
    figure(2);clf
end

%plot each year of the plot in the new figures in other colors
kk = 1;
for year = year1:year2
    % choose events of specific year (loop)
    mask_dd = days_DD(:,1) == year;
    mask_bb = days_BB(:,1) == year;
    %last row: day of the year, second last row: intensity 
    x(:,1) = days_DD(mask_dd,end);
    x(:,2) = days_DD(mask_dd,end-1);
    
    x2(:,1) = days_BB(mask_bb,end);
    x2(:,2) = days_BB(mask_bb,end-1);
    
    %combine low and high extreme events, display them in same color for
    %each year
    x = vertcat(x, x2);
    figure(1); hold on
    plot(x(:,1), x(:,2),'.','MarkerSize', 13);
    

    %% repeat for 3d-figure, if flag == 1
    if flag_3dfigure
        
        xx(:,1) = days_DD(mask_dd,end);
        xx(:,2) = days_DD(mask_dd,end-3);
        xx(:,3) = days_DD(mask_dd,end-2);
        
        xx2(:,1) = days_BB(mask_bb,end);
        xx2(:,2) = days_BB(mask_bb,end-3);
        xx2(:,3) = days_BB(mask_bb,end-2);
        xx = vertcat(xx, xx2);
        
        figure(2); hold on
        plot3(xx(:,1), xx(:,2), xx(:,3),'.','MarkerSize', 13);
        clear xx xx2
    end
   %%
    clear x x2 mask_dd mask_bb 
    legend_years(kk,1) = year;
    kk = kk+1;
end
clear kk year

% plot thresholds, legend, and labels. Define limits, set grid, and set
% position
figure(1); hold on
plot(ones(366,1).*max(max(days_DD(:,end-2:end-1))));
plot(ones(366,1).*min(min(days_BB(:,end-2:end-1))));
% title('Extreme weather situations: distribution and intensity');
xlabel('Day');
ylabel('Mean of sun and wind intenity [%]');
legend_years = num2str(legend_years);
legend(legend_years);
xlim([0 370])
clear legend_years
set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on', 'XGrid', 'on');
set(gcf, 'Position', [50 450 550 300]);

% set viewpoint, grid, and position for 3d-figure if flag == 1
if flag_3dfigure
    figure(2);
    view(50,10)
    set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on', 'XGrid', 'on');
    set(gcf, 'Position', [450 450 400 300]);
end

end

