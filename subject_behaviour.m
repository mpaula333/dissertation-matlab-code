function [perf] = subject_behaviour (Results)
% Compute correct rates on training and test periods
% FORMAT [perf] = subject_behaviour (Results)
%
% Results       Results data structure from subjX.mat
%
% perf          Output data structure with correct rates during
%
%               .tr         training
%               .pre_old    pre-delay test on old items
%               .pre_new    pre-delay test on new items
%               .post_old    post-delay test on old items
%               .post_new    post-delay test on new items

T=length(Results.training);
for t=1:T,
    lost(t) = Results.training(t).TrialLost; % no response?
    config(t) = Results.training(t).Configuration; % Which stimulus?
    correct(t) = Results.training(t).Feedback; 
end

tr_conf = unique(config); % The configurations shown during training
perf.tr = mean(correct(lost==0)); % Ignore "no response" trials

T=length(Results.test);
for t=1:T,
    old(t) = ismember(Results.test(t).Configuration,tr_conf);
    lost(t) = Results.test(t).TrialLost;
    correct(t) = Results.test(t).Feedback;
end

pre=[ones(1,T/2),zeros(1,T/2)]; % Pre-Delay ? 

perf.pre_old = mean(correct(lost==0 & old==1 & pre==1));
perf.pre_new = mean(correct(lost==0 & old==0 & pre==1));
perf.post_old = mean(correct(lost==0 & old==1 & pre==0));
perf.post_new = mean(correct(lost==0 & old==0 & pre==0));


