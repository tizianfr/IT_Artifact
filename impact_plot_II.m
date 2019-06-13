function impact_plot_II(impact_DD, impact_BB)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%% prepare data weather impacts / PLOT
%for mm = 1:2

    
    fields = fieldnames(impact_DD);

    for ii = 1:length(fields)
        
    temp_impact = fields{ii}; 
    % descriptive statistics
    for mm = 1:2
        if mm == 1
            impact = impact_DD;
            type = ' DD';
            nn = 0;
        elseif mm == 2
            impact = impact_BB;
            type = ' BB';
            nn = 2;
        end 

        d(1+nn,1)   = {size(impact.(temp_impact).x1,1)};
        d(2+nn,1) = {size(impact.(temp_impact).x2,1)};
        d(1+nn,2)   = {impact.(temp_impact).mean1};
        d(2+nn,2) = {impact.(temp_impact).mean2};
        d(1+nn,3)   = {impact.(temp_impact).std1};
        d(2+nn,3) = {impact.(temp_impact).std2};
        d(1+nn,4)   = {impact.(temp_impact).median1};
        d(2+nn,4) = {impact.(temp_impact).median2};
        d(1+nn,5)   = {impact.(temp_impact).iqr1};
        d(2+nn,5) = {impact.(temp_impact).iqr2};
        % normal distribution test
        d(1+nn,6) = {impact.(temp_impact).sw_h};
        d(2+nn,6) = {impact.(temp_impact).sw_h2};
        d(1+nn,7) = {impact.(temp_impact).sw_p};
        d(2+nn,7) = {impact.(temp_impact).sw_p2};

        d(1+nn,8)   = {strcat(fields(ii),': x1', type)};
        d(2+nn,8)   = {strcat(fields(ii),': x2', type)};
        % d(kk+1,6) = impact_DD.(temp_impact).std1;

        d2(1+nn*2,1) = {impact.(temp_impact).var_h};
        d2(1+nn*2,2) = {impact.(temp_impact).var_p};
        d2(1+nn*2,3) = {impact.(temp_impact).var_left_h};
        d2(1+nn*2,4) = {impact.(temp_impact).var_left_p};
        d2(1+nn*2,5) = {impact.(temp_impact).var_right_h};
        d2(1+nn*2,6) = {impact.(temp_impact).var_right_p};
        %d2(1,7)= {fields(ii)};

        d2(2+nn*2,1) = {impact.(temp_impact).studtt_h};
        d2(2+nn*2,2) = {impact.(temp_impact).studtt_p};
        d2(2+nn*2,3) = {impact.(temp_impact).studtt_left_h};
        d2(2+nn*2,4) = {impact.(temp_impact).studtt_left_p};
        d2(2+nn*2,5) = {impact.(temp_impact).studtt_right_h};
        d2(2+nn*2,6) = {impact.(temp_impact).studtt_right_p};
        impact.(temp_impact).studtt_ci = int32(impact.(temp_impact).studtt_ci);
        d2(2+nn*2,7) = {[num2str(impact.(temp_impact).studtt_ci')]};

        d2(3+nn*2,1) = {impact.(temp_impact).welcht_h};
        d2(3+nn*2,2) = {impact.(temp_impact).welcht_p};
        d2(3+nn*2,3) = {impact.(temp_impact).welcht_left_h};
        d2(3+nn*2,4) = {impact.(temp_impact).welcht_left_p};
        d2(3+nn*2,5) = {impact.(temp_impact).welcht_right_h};
        d2(3+nn*2,6) = {impact.(temp_impact).welcht_right_p};
        impact.(temp_impact).welcht_ci = int32(impact.(temp_impact).welcht_ci);
        d2(3+nn*2,7) = {[num2str(impact.(temp_impact).welcht_ci')]};

        d2(4+nn*2,1) = {impact.(temp_impact).ranksum_h};
        d2(4+nn*2,2) = {impact.(temp_impact).ranksum_p};
        d2(4+nn*2,3) = {impact.(temp_impact).ranksum_left_h};
        d2(4+nn*2,4) = {impact.(temp_impact).ranksum_left_p};
        d2(4+nn*2,5) = {impact.(temp_impact).ranksum_right_h};
        d2(4+nn*2,6) = {impact.(temp_impact).ranksum_right_p};
        impact.(temp_impact).ci = int32(impact.(temp_impact).ci);
        d2(4+nn*2,7) = {[num2str(impact.(temp_impact).ci)]};
    end 
    d(4,:) = [];
  
    f = figure('WindowState', 'maximized');
     
    sp = subplot(2,2,1);
    pos = get(sp, 'Position');
    un = get(sp, 'Units');
    delete(sp)
    uit = uitable('Units', un, 'Position', pos);
   % uit.Position = [20 20 700 320];
    uit.Data = d(:,1:7);
    uit.ColumnName = {'No. of days', 'Mean', 'Std.', 'Median', 'Iqr.', 'SW-test H0', 'SW-test p-val'};
    uit.RowName = string(d(:,8));
    %
    subplot(2,2,2);
    % info: sample 2 of impact_DD and impact_BB is the same
    
    x = [impact_DD.(temp_impact).x1; impact_DD.(temp_impact).x2; ...
        impact_BB.(temp_impact).x1];
    g = [zeros(length(impact_DD.(temp_impact).x1),1); ones(length(impact_DD.(temp_impact).x2),1); ... 
         2*ones(length(impact_BB.(temp_impact).x1),1)];
    
    boxplot(x, g, 'notch', 'on', 'labels', {'sample1 DD', 'sample2 DD & BB', 'sample1 BB' })
    %title(['Generated wind power, ', type]);
    
    sp = subplot(2,2,[3,4]);
    pos = get(sp, 'Position');
    un = get(sp, 'Units');
    delete(sp)
    title([temp_impact, type]);
    uit2 = uitable('Units', un, 'Position', pos);
    %uit2.Position = [20 20 700 300];
    uit2.Data = d2;
    uit2.ColumnName = {'Two-tailed H', 'Two-t. p-val', 'Left-t. H', 'Left-t. p-val', ...
        'Right-t. H', 'Right-t. p-val', 'CI'}; 
    uit2.RowName = {'Equality of variances DD', ['Student''', 's t-test DD'], 'Welch-test DD',...
        'Wilcoxon rank sum test DD', 'Equality of variance BB', ['Student''', 's t-test BB'], ...
        'Welch-test BB', 'Wilcoxon rank sum test BB'};
%     xlswrite([temp_impact, '_descriptive.xlsx'], d)
%    xlswrite([temp_impact, '_hyp_tests.xlsx'], d2)
%    figure();
%    boxplot(x, g, 'notch', 'on', 'labels', {'10th perc.', '10th to 90th perc.', '90th perc.' })
%    savefig([temp_impact, 'boxplot.fig'])
    end
    clear ii
    clear impact
%   
end

