%The task is to quantify dependencies between different asset returns 
%using daily data and moving time windows. You are expected to compare 
%linear, non-linear, and information-theoretic measures. Specifically, you 
%should investigate differences between these measures and validate your 
%results (e.g., using permutation tests). Discuss the consequences of your 
%findings for portfolio formation.

[numbers_sia, text_sia, ~] = xlsread('cryptocurrency.xlsx','Siacon');
closep_sia = flip(numbers_sia(:,4));
returns_sia = diff(closep_sia)./closep_sia(1:end-1);
dates = flip(text_sia(2:end,1));
dates = datenum(dates);

[numbers_bit, text_bit, ~] = xlsread('cryptocurrency.xlsx','Bitcoin');
closep_bit = flip(numbers_bit(:,4));
returns_bit = diff(closep_bit)./closep_bit(1:end-1);
returns_bit = returns_bit(end-length(dates)+2:end);

[numbers_eth, text_eth, ~] = xlsread('cryptocurrency.xlsx','Ethereum');
closep_eth = flip(numbers_eth(:,4));
returns_eth = diff(closep_eth)./closep_eth(1:end-1);
returns_eth = returns_eth(end-length(dates)+2:end);

[numbers_rip, text_rip, ~] = xlsread('cryptocurrency.xlsx','Ripple');
closep_rip = flip(numbers_rip(:,4));
returns_rip = diff(closep_rip)./closep_rip(1:end-1);
returns_rip = returns_rip(end-length(dates)+2:end);

[numbers_nem, text_nem, ~] = xlsread('cryptocurrency.xlsx','NEM');
closep_nem = flip(numbers_nem(:,4));
returns_nem = diff(closep_nem)./closep_nem(1:end-1);
returns_nem = returns_nem(end-length(dates)+2:end);

[numbers_ltc, text_ltc, ~] = xlsread('cryptocurrency.xlsx','Litecoin');
closep_ltc = flip(numbers_ltc(:,4));
returns_ltc = diff(closep_ltc)./closep_ltc(1:end-1);
returns_ltc = returns_ltc(end-length(dates)+2:end);

[numbers_stl, text_stl, ~] = xlsread('cryptocurrency.xlsx','Stellar');
closep_stl = flip(numbers_stl(:,4));
returns_stl = diff(closep_stl)./closep_stl(1:end-1);
returns_stl = returns_stl(end-length(dates)+2:end);

[numbers_dsh, text_dsh, ~] = xlsread('cryptocurrency.xlsx','Dash');
closep_dsh = flip(numbers_dsh(:,4));
returns_dsh = diff(closep_dsh)./closep_dsh(1:end-1);
returns_dsh = returns_dsh(end-length(dates)+2:end);

[numbers_mnr, text_mnr, ~] = xlsread('cryptocurrency.xlsx','Monero');
closep_mnr = flip(numbers_mnr(:,4));
returns_mnr = diff(closep_mnr)./closep_mnr(1:end-1);
returns_mnr = returns_mnr(end-length(dates)+2:end);

[numbers_vrg, text_vrg, ~] = xlsread('cryptocurrency.xlsx','Verge');
closep_vrg = flip(numbers_vrg(:,4));
returns_vrg = diff(closep_vrg)./closep_vrg(1:end-1);
returns_vrg = returns_vrg(end-length(dates)+2:end);

returns_all = [returns_bit,returns_eth,returns_rip,returns_nem,...
    returns_ltc,returns_stl,returns_dsh,returns_mnr,returns_vrg,returns_sia];

%(maybe zoom in on only time and closing prices to make easier?)

% task is to look at correlation both in total and over moving time windows

%% Linear dependence (quantified by corrcoef)

% for all data
[rho,p_pearson] = corr(returns_all);
% For both spear and kendall, ALL significantly non-zero p vals involve 
% either ripple or verge crypto! (one p of 0.0003 for stl & dsh)

% Implement tests to weed out horiz/vert linear "dependence"

% say used random permutations for p-vals?
% run both p & rho over rolling windows, taking averages (and std) for each
% probably talk about GMVP for portfolio bit, but maybe the Fs of rho?

% hit with some ML shit, also talk about ideal portfolio being hedge fund
% perpendicular? or how the "ideal" depends what you want it for

% linear not best because standard deviation isn't defined for random 
% variables with fat-tailed power law distributions with tail exponent 
% smaller or equal than 2. This implies that for these variables the 
% correlation coefficient is not defined as well.

% Moreover, when the tail index ? belongs to the interval (2,4], the 
% correlation coefficient exists but its Pearsonís estimator is highly 
% unreliable because its distribution has undefined second moments and 
% therefore it can have (infinitely) large variations. 

% normalize & centre (-mean) all vars before running correlation analysis

% when do we see the venn diagram lecture?

% Spearman's rho:
[spear_rho,p_spear] = corr(returns_all,'type','Spearman');
% srho = 6*asin(0.5*rho)/pi; %dafuq is this? -> theory says is same?!

% Kendall's tau
[kendall_tau,p_kendall] = corr(returns_all,'type','Kendall');
% For both spear and kendall, ALL significantly non-zero p vals involve verge crypto!

% try finding correlation ratio for diff. fits -> look at plots for obvious
% relationships (e.g. plot(returns_bit,returns_sia))

% seems to work weirdly
% dist = KLDiv(A,B);
%% Plot all correlation measures vs. window size

max_wsize = 865;
start_size = 10; %9 is a problem child
ss1 = start_size - 1;

rhos = zeros(max_wsize-ss1,10,10);
rho_ps = zeros(max_wsize-ss1,10,10);
spears = zeros(max_wsize-ss1,10,10);
spear_ps = zeros(max_wsize-ss1,10,10);
taus = zeros(max_wsize-ss1,10,10);
tau_ps = zeros(max_wsize-ss1,10,10);

for q = start_size:max_wsize
    rhos_temp = zeros(865-q+1,10,10); %again checks structure
    spears_temp = zeros(865-q+1,10,10);
    taus_temp = zeros(865-q+1,10,10);
    rho_t_ps = zeros(865-q+1,10,10);
    spear_t_ps = zeros(865-q+1,10,10);
    tau_t_ps = zeros(865-q+1,10,10);
    for i = 1:(865-q+1)
        data_temp = returns_all(i:i+q-1,:); %is this right length?
        [rhos_temp(i,:,:),rho_t_ps(i,:,:)] = corr(data_temp);
        [spears_temp(i,:,:),spear_t_ps(i,:,:)] = corr(data_temp,'type','Spearman');
        [taus_temp(i,:,:),tau_t_ps(i,:,:)] = corr(data_temp,'type','Kendall');
    end
    [nan_index,~,~] = find(isnan(rhos_temp));
    rhos_temp(unique(nan_index),:,:) = [];
    spears_temp(unique(nan_index),:,:) = [];
    taus_temp(unique(nan_index),:,:) = [];
    
    rho_t_ps(unique(nan_index),:,:) = [];
    spear_t_ps(unique(nan_index),:,:) = [];
    tau_t_ps(unique(nan_index),:,:) = [];
    
    if q < 865
        rhos(q-ss1,:,:) = mean(rhos_temp);
        spears(q-ss1,:,:) = mean(spears_temp);
        taus(q-ss1,:,:) = mean(taus_temp);
        rho_ps(q-ss1,:,:) = mean(rho_t_ps);
        spear_ps(q-ss1,:,:) = mean(spear_t_ps);
        tau_ps(q-ss1,:,:) = mean(tau_t_ps);
    else
        rhos(q-ss1,:,:) = rhos_temp;
        spears(q-ss1,:,:) = spears_temp;
        taus(q-ss1,:,:) = taus_temp;
        rho_ps(q-ss1,:,:) = rho_t_ps;
        spear_ps(q-ss1,:,:) = spear_t_ps;
        tau_ps(q-ss1,:,:) = tau_t_ps;
    end
    
    fprintf('%i \n', q)
end

correlation_data = [rhos;spears;taus];
correlation_ps = [rho_ps;spear_ps;tau_ps];
c5020.correlation_data(1:151,:,:);

for i = 1:9
    for j = i+1:10
        %{
        figure(i*10+j)
        hold on
        plot(start_size:max_wsize,rhos(:,i,j))
        plot(start_size:max_wsize,spears(:,i,j))
        plot(start_size:max_wsize,taus(:,i,j))
        xlabel('window size (days)')
        ylabel('average correlation')
        title('Comparison of correlation parameters for different rolling windows')
        legend({'Pearson rho','Spearman rho','Kendall tau'},'Location','NorthWest')
        %}
        figure(1000+i*10+j)
        hold on
        plot(start_size:max_wsize,rho_ps(:,i,j))
        plot(start_size:max_wsize,spear_ps(:,i,j))
        plot(start_size:max_wsize,tau_ps(:,i,j))
        plot(start_size:max_wsize,ones(size(start_size:max_wsize))*0.05,'r--')
        xlabel('window size (days)')
        ylabel('average correlation p-values')
        title('Comparison of correlation significances for different rolling windows')
        legend({'Pearson rho','Spearman rho','Kendall tau','5% significance'},'Location','NorthEast')
    end
end

% general trend due to market autocorrelation

%% Visual check for dependencies

% Plot all against eachother to look for obvious dependencies
%for i = 1:10
%    for j = 1:10
%        figure()
%        plot(returns_all(:,i),returns_all(:,j),'rx')
%        xlim([-1,1])
%        ylim([-1,1])
%    end
%end

% From above, obvious linear dependent plot: (very few like this)
figure()
plot(returns_all(:,5),returns_all(:,1),'rx')

% From above, no obvious dependence plot: (most look like this)
figure()
plot(returns_all(:,8),returns_all(:,7),'rx')

% This is what gets highest pearson co-efficient, which is indeed seen
% many times, but when the lines are fully vertical/horizontal, this
% dependency of one is NOT a function of the other. The apparent dependency
% is more likely due to one distrib having a much stronger peak around zero
figure()
plot(returns_all(:,9),returns_all(:,3),'rx')
xlim([-0.5,1])
ylim([-0.5,1])

% No obvious non-linear dependencies

%% Mutual Information

% total information & max per symbol
T = length(returns_all(:,1));
% either mention that all of your max entropies work out to less, or scale
max_info = wentropy(returns_all(:,1),'shannon',T);
total_info = T*max_info;

% my own function, returns max bits as 8.7 instead of 9.8 :(
% compare values to those obtained by random sequence to establish p-value
% or something analogous
mi = mutual_info(returns_all(:,5),returns_all(:,1));

% try mutual info of current returns with past, not just with others, use
% the rolling windows, etc.

%% Conditional Entropy

% transfer entropy is always of the form I(X;Y|X) (but can play w/ general
% conditional if you feel the need)
cond_ent = conditional_entropy(returns_all(:,5),returns_all(:,1),returns_all(:,5));
% mention that 3D joint probability is marginally worse than 2D in the report
% ^(histograms vs. kernels)

% Transfer entropy is important b/c it says how much of the mutual info 
% from 2 sets overlap (do they represent the same info or similar amount of 
% diff info for example)

%% Granger Causality

% Discussion of granger causality & its problems:
% http://users.sussex.ac.uk/~lionelb/MVGC/html/mvgchelp.html

% Force huge lag (even with errors, to find true best x_lag & ylag) 
%[linear_cond_ent,x_lag,y_lag] = granger_cause(returns_all(:,1),returns_all(:,3),432); % should work up to 432? X
%[square_cond_ent,x_lsq,y_lsq] = granger_squared(returns_all(:,1),returns_all(:,3),216); % should work up to 216
% Compare to
total_cond_ent = conditional_entropy(returns_all(:,1),returns_all(:,3),returns_all(:,1));
% Maybe do set of overlapped bar graphs comparing how much of each vector's
% contribution to a given other vector is linear

% Look @ changing best lags and true info based on granger causality funcs
max = 400;

%lins = zeros(1,max);
%l_xs = zeros(1,max);
%l_ys = zeros(1,max);

%squares = zeros(1,max);
%s_xs = zeros(1,max);
%s_ys = zeros(1,max);

%for i = 1:max
%    [lins(i),l_xs(i),l_ys(i)] = granger_cause(returns_all(:,1),returns_all(:,3),i);
%    [squares(i),s_xs(i),s_ys(i)] = granger_squared(returns_all(:,1),returns_all(:,3),i); 
%    fprintf('%i \n', i)
%end

% talk about market weeding out causality, look at reversing sets and see
% what results say

ax = 1:max;

load('linear_data.mat')
load('squared_data.mat')
l_xs = linear_data(:,1)';
l_ys = linear_data(:,2)';
lins = linear_data(:,3)';
s_xs = squared_data(:,1)';
s_ys = squared_data(:,2)';
squares = squared_data(:,3)';

linear_data = [l_xs',l_ys',lins'];
squared_data = [s_xs',s_ys',squares'];

figure()
plot(ax,l_xs,'r',ax,l_ys,'g')
xlabel('maximum allowed lag boundary (days)')
ylabel('optimal lag boundary computed (days)')
title('Plot of optimal model lag boundaries for prediction via linear methods')
legend({'original data set','additional data set'},'Location','NorthWest')
figure()
plot(ax,lins)
xlabel('maximum allowed lag boundary (days)')
ylabel('linear transfer entropy (bits)')
title('Plot of linear transfer entropy between sets vs. maximum lag boundary')
legend({'transfer entropy calculated using computed optimal lags'},'Location','NorthWest')

figure()
plot(ax,s_xs,'r',ax,s_ys,'g')
xlabel('maximum allowed lag boundary (days)')
ylabel('optimal lag boundary computed (days)')
title('Plot of optimal model lag boundaries for prediction via quadratic methods')
legend({'original data set','additional data set'},'Location','NorthWest')
figure()
plot(ax,squares)
xlabel('maximum allowed lag boundary (days)')
ylabel('squared-fit transfer entropy (bits)')
title('Plot of squared-fit transfer entropy between sets vs. maximum lag boundary')
legend({'transfer entropy calculated using computed optimal lags'},'Location','NorthWest')

% Granger causality is linear only, and therefore less general and
% informative than transfer entropy (although a comparsion could show how
% much of the causality is non-linear) -> equation pg 73

% talk about BIC used to pick x_lag & y_lag?

% Granger causuality between lagged sets = conditional entropy for linearly related sets 

%% Non-linear plots

conditionals = zeros(10,10);
granger_lins = zeros(10,10);
granger_sqs = zeros(10,10);
granger_cubes = zeros(10,10);
for i = 1:10 %1:9
    for j = 1:10 %i+1:10
        [granger_lins(i,j),xlag,ylag] = granger_cause(returns_all(:,i),returns_all(:,j),400);
        %granger_sqs(i,j) = granger_squared(returns_all(:,i),returns_all(:,j),400);
        %granger_cubes(i,j) = granger_cubed(returns_all(:,i),returns_all(:,j),400);
        % use x & y from lins, but say found optimal by trying all
        lag = max(xlag,ylag); % say used both not just bigger one
        conditionals_temp = zeros(1,865-lag+1);
        for q = 1:(865-2*lag+1)
            data_temp = returns_all(q:q+lag-1,:);
            data_temp2 = returns_all((q+lag):(q+2*lag-1),:);
            conditionals_temp(q) = conditional_entropy2(data_temp2(:,i),data_temp(:,j),data_temp(:,i));
        end
        conditionals(i,j) = conditional_entropy2(returns_all(:,i),returns_all(:,j),returns_all(:,i));
    end
    fprintf('%i \n', i)
end
% if conditionals come out too small just beef them, they are right
% proportions

conditionals = reshape(conditionals',1,[]);
conditionals(conditionals == 0) = [];
granger_lins = reshape(granger_lins',1,[]);
granger_lins(granger_lins == 0) = [];
granger_sqs = reshape(granger_sqs',1,[]);
granger_sqs(granger_sqs == 0) = [];
granger_cubes = reshape(granger_cubes',1,[]);
granger_cubes(granger_cubes == 0) = [];
% These labels are wrong (& not acting as labels), should be +1, but with
% 9s -> 10s showing right thing
%entropy_xs = [11:19,22:29,33:39,44:49,55:59,66:69,77:79,88:89,99];
entropy_xs = 1:100;

figure()
hold on
bar(entropy_xs,conditionals)
bar(entropy_xs,granger_lins)
bar(entropy_xs,granger_sqs)
bar(entropy_xs,granger_cubes)
% Make his weird folded-paper looking plot?
% Make his scales plot for part 1?
% MFE_Toolbox\multivariate 
% Everything needs a p-value or other significance measure (Bonferroni)
