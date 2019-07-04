function plot_impacts(impact_DD, impact_BB)
%Plot the result of the impact observation. Result is a boxplot,
%descriptive statistic table, and a sample comparison test result table.
% The function repeats the results for all variables that are saved in the
% structure of input data. The test results needs thus to be saved in a
% structure variable. Function can still be used for only one impact
% variable at once.

%% Prepare data  
    
    % get the names of all impacts saved in the structure
    fields = fieldnames(impact_DD);
    
    % repeat the impact plot for all impacts of structure
    for ii = 1:length(fields)
        
        %plot each loop another impact on position ii in the structure
        temp_impact = fields{ii}; 
        
        % get same data for both low and high extremes
        for mm = 1:2
            if mm == 1
                impact = impact_DD;
                nn = 0;
            elseif mm == 2
                impact = impact_BB;
                nn = 2;
            end 
            
            % dstats == descriptive statistics 
            dstats(1+nn,1)   = {size(impact.(temp_impact).x1,1)};
            dstats(2+nn,1) = {size(impact.(temp_impact).x2,1)};
            dstats(1+nn,2)   = {impact.(temp_impact).mean1};
            dstats(2+nn,2) = {impact.(temp_impact).mean2};
            dstats(1+nn,3)   = {impact.(temp_impact).std1};
            dstats(2+nn,3) = {impact.(temp_impact).std2};
            dstats(1+nn,4)   = {impact.(temp_impact).median1};
            dstats(2+nn,4) = {impact.(temp_impact).median2};
            dstats(1+nn,5)   = {impact.(temp_impact).iqr1};
            dstats(2+nn,5) = {impact.(temp_impact).iqr2};
            % normal distribution test (Shapiro_wilk_test)
            dstats(1+nn,6) = {impact.(temp_impact).sw_h};
            dstats(2+nn,6) = {impact.(temp_impact).sw_h2};
            dstats(1+nn,7) = {impact.(temp_impact).sw_p};
            dstats(2+nn,7) = {impact.(temp_impact).sw_p2};

            % scomp == sample comparison table
            % equality of variances
            scomp(1+nn*2,1) = {impact.(temp_impact).var_h};
            scomp(1+nn*2,2) = {impact.(temp_impact).var_p};
            scomp(1+nn*2,3) = {impact.(temp_impact).var_left_h};
            scomp(1+nn*2,4) = {impact.(temp_impact).var_left_p};
            scomp(1+nn*2,5) = {impact.(temp_impact).var_right_h};
            scomp(1+nn*2,6) = {impact.(temp_impact).var_right_p};
            % student's t test
            scomp(2+nn*2,1) = {impact.(temp_impact).studtt_h};
            scomp(2+nn*2,2) = {impact.(temp_impact).studtt_p};
            scomp(2+nn*2,3) = {impact.(temp_impact).studtt_left_h};
            scomp(2+nn*2,4) = {impact.(temp_impact).studtt_left_p};
            scomp(2+nn*2,5) = {impact.(temp_impact).studtt_right_h};
            scomp(2+nn*2,6) = {impact.(temp_impact).studtt_right_p};
            impact.(temp_impact).studtt_ci = int32(impact.(temp_impact).studtt_ci);
            scomp(2+nn*2,7) = {[num2str(impact.(temp_impact).studtt_ci')]};
            % welch test
            scomp(3+nn*2,1) = {impact.(temp_impact).welcht_h};
            scomp(3+nn*2,2) = {impact.(temp_impact).welcht_p};
            scomp(3+nn*2,3) = {impact.(temp_impact).welcht_left_h};
            scomp(3+nn*2,4) = {impact.(temp_impact).welcht_left_p};
            scomp(3+nn*2,5) = {impact.(temp_impact).welcht_right_h};
            scomp(3+nn*2,6) = {impact.(temp_impact).welcht_right_p};
            impact.(temp_impact).welcht_ci = int32(impact.(temp_impact).welcht_ci);
            scomp(3+nn*2,7) = {[num2str(impact.(temp_impact).welcht_ci')]};
            % wilcoxon rank sum test
            scomp(4+nn*2,1) = {impact.(temp_impact).ranksum_h};
            scomp(4+nn*2,2) = {impact.(temp_impact).ranksum_p};
            scomp(4+nn*2,3) = {impact.(temp_impact).ranksum_left_h};
            scomp(4+nn*2,4) = {impact.(temp_impact).ranksum_left_p};
            scomp(4+nn*2,5) = {impact.(temp_impact).ranksum_right_h};
            scomp(4+nn*2,6) = {impact.(temp_impact).ranksum_right_p};
            impact.(temp_impact).ci = int32(impact.(temp_impact).ci);
            scomp(4+nn*2,7) = {[num2str(impact.(temp_impact).ci)]};
        end 
        
        % labels for sample 1, 2, 3
        dstats(1,8)   = {strcat(fields(ii),': <10th perc.')};
        dstats(2,8)   = {strcat(fields(ii),': 10th to 90th perc.')};
        dstats(3,8)   = {strcat(fields(ii),': >90th perc.')};
        dstats(4,:) = [];
        
        % No.1: Figure of descriptive statistics
        f = figure();clf;
        f.Position = [700 450 850 150];
        uit = uitable(); 
        uit.Position = [20 20 820 110];
        uit.Data = dstats(:,1:7);
        uit.ColumnName = {'No. of days', 'Mean', 'Std.', 'Median', 'Iqr.', 'SW-test H0', 'SW-test p-val'};
        uit.RowName = string(dstats(:,8));
        clear f
        
        %Boxplot of sample 1, 2, 3
        f = figure();clf;
        % info: sample 2 of impact_DD and impact_BB is the same
        % prepare variables for boxplot
        x = [impact_DD.(temp_impact).x1; impact_DD.(temp_impact).x2; ...
            impact_BB.(temp_impact).x1];
        g = [zeros(length(impact_DD.(temp_impact).x1),1); ones(length(impact_DD.(temp_impact).x2),1); ... 
             2*ones(length(impact_BB.(temp_impact).x1),1)];
        % plot boxplot with notch and labels
        boxplot(x, g, 'notch', 'on', 'labels', {'< 10th perc.', '10th to 90th perc.', '> 90th perc.' })
        f.Position = [50 50 550 350];
        set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on', 'XGrid', 'on', 'YGrid', 'on');
        clear f

        % plot sample comparison table
        f = figure();clf;
        f.Position = [700 50 850 300];
        uit2 = uitable(); 
        uit2.Position = [20 20 820 200];
        scomp(1:4,8) = {'<10th vs. 10th-90th perc.'};
        scomp(5:8,8) = {'>90th vs. 10th-90th perc.'};
        scomp = scomp(:, [8 1:7]);
        uit2.Data = scomp;
        uit2.ColumnName = {'Compared samples', 'Two-tailed H', 'Two-t. p-val', 'Left-t. H', 'Left-t. p-val', ...
            'Right-t. H', 'Right-t. p-val', 'CI'}; 
        uit2.RowName = {'Equality of variances', ['Student''', 's t-test'], 'Welch-test',...
            'Wilcoxon rank sum test', 'Equality of variance', ['Student''', 's t-test'], ...
            'Welch-test', 'Wilcoxon rank sum test'};
        clear f
        
        %write results in a file if flag_writefiles == 1;
        flag_writefiles = 0;
        if flag_writefiles
           xlswrite([temp_impact, '_descriptive.xlsx'], dstats);
           xlswrite([temp_impact, '_hyp_tests.xlsx'], scomp),
           figure();
           boxplot(x, g, 'notch', 'on', 'labels', {'10th perc.', '10th to 90th perc.', '90th perc.' })
           savefig([temp_impact, 'boxplot.fig'])
        end
        
    end
    clear ii
    clear impact
   
end

