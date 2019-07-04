function [testres] = hypothesis_tests(sample1,sample2, col)
% perform sample comparison hypothesis test of sample 1 with sample 2. 
% the third variable: col determines the column where the values of the
% samples to be compared are saved

% create variables x1 and x2 only containing the values, that are compared
x1 = sample1(:,col);
x2 = sample2(:,col);
% save all results in the test result structure testres
testres.x1 = x1;
testres.x2 = x2;
clear sample1 sample2
%% descriptive statistics
% mean
testres.mean1 = mean(x1,1);
testres.mean2 = mean(x2,1);
% standard deviation
testres.std1  = std(x1,1);
testres.std2  = std(x2,1);
% median
testres.median1 = median(x1,1);
testres.median2 = median(x2,1);
% interquartile range
testres.iqr1 = iqr(x1,1);
testres.iqr2 = iqr(x2,1);
%% Perform tests for more than 2 entries
% if samples each sample has more than two entries: go to else and perform
% sample-comparison hypothesis tests 
if size(x1) < 2 | size(x2) < 2
    testres.jb_h = [];
    testres.jb_h2 = [];
    testres.jb_p2 = 0;
    testres.var_h = [];
    testres.var_p = 0;
    testres.ranksum_p = 0;
    testres.ranksum_h = [];
    testres.sw_h = [];
    testres.sw_p  = 0;
    testres.sw_h2 = [];
    testres.sw_p2  = 0;
else
    %% Shapiro-Wilk test for normal distribution
    %significance level == 5% 
    [testres.sw_h,testres.sw_p] = swtest(x1, 0.05, true);
    [testres.sw_h2,testres.sw_p2] = swtest(x2, 0.05, true);

    %% Test the equality of variances
    %/ Leven test: https://de.mathworks.com/help/stats/vartestn.html
    % H0: data in x1 and x2 comes from normal distributons with
    % the same variance. h = 1 if test rejects the null hypothesis

    [testres.var_h, testres.var_p] = vartest2(x1, x2, 'Tail', 'both');
    [testres.var_left_h, testres.var_left_p] = vartest2(x1, x2, 'Tail', 'left');
    [testres.var_right_h, testres.var_right_p] = vartest2(x1, x2, 'Tail', 'right');

    testres.var_h = logical(testres.var_h);
    testres.var_left_h = logical(testres.var_left_h);
    testres.var_right_h = logical(testres.var_right_h);


    %% Mean test for normal distribution
    % Student's t-test
    % Assumption: equal variance
    %H0: samples are normal distributed with equal means and equal but unknown
    %variance
    [testres.studtt_h,testres.studtt_p, testres.studtt_ci, ~]= ttest2(x1, x2, 'Tail', 'both');
    [testres.studtt_left_h,testres.studtt_left_p, ~, ~]= ttest2(x1, x2, 'Tail', 'left');
    [testres.studtt_right_h,testres.studtt_right_p, ~, ~]= ttest2(x1, x2, 'Tail', 'right');

    testres.studtt_h = logical(testres.studtt_h);
    testres.studtt_left_h = logical(testres.studtt_left_h);
    testres.studtt_right_h = logical(testres.studtt_right_h);

    % Welch's test
    % Assumption: unequal variance
    [testres.welcht_h,testres.welcht_p, testres.welcht_ci, ~] = ttest2(x1, x2, 'Tail', 'both', 'Vartype', 'unequal');
    [testres.welcht_left_h,testres.welcht_left_p, ~, ~] = ttest2(x1, x2, 'Tail', 'left', 'Vartype', 'unequal');
    [testres.welcht_right_h,testres.welcht_right_p, ~, ~] = ttest2(x1, x2, 'Tail', 'right', 'Vartype', 'unequal');

    testres.welcht_h = logical(testres.welcht_h);
    testres.welcht_left_h = logical(testres.welcht_left_h);
    testres.welcht_right_h = logical(testres.welcht_right_h);

    %% Mean test for non-nornmal distribution
    % Wilcoxon rank sum test. Equivalent to a Mann-Whitney U-test.
    % https://de.mathworks.com/help/stats/ranksum.html
    % H0: samples are from continuous distributions with equal medians. 
    [testres.ranksum_p, testres.ranksum_h] = ranksum(x1,x2);
    [testres.ranksum_left_p, testres.ranksum_left_h] = ranksum(x1,x2, 'tail', 'left');
    [testres.ranksum_right_p, testres.ranksum_right_h] = ranksum(x1,x2, 'tail', 'right');

    %% Confidence intervals
    %calculation of confidence interval with a confidence level of
    %approximately 100(1-alpha)% = 95%
    % 1.96 is obtained from z distribution table for 1-alpha/2 = 0.975

    testres.std_x1_min_x2 = sqrt((testres.std1^2 / size(testres.x1,1)) + (testres.std2^2 / size(testres.x2,1)));
    testres.mean_diff = testres.mean1 - testres.mean2;

    testres.ci = [testres.mean_diff-1.96*testres.std_x1_min_x2 ... 
        testres.mean_diff+1.96*testres.std_x1_min_x2];

end

end

