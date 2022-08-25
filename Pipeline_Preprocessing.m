%% demo fieldtrip analysis
clear all
close all

addpath('C:\Users\FOX LAPTOP\Desktop\MATLAB\fieldtrip-20220514')
ft_defaults

%% PREPROCESSING

data_folder = 'C:\Users\FOX LAPTOP\Desktop\MATLAB\Data\Data\ID1';
filename1 = '1.eeg';
filename2 = '1.vhdr';

%% highpass filtering without segmenting

cfg = [];
cfg.dataset = fullfile(data_folder, filename2);
cfg.hpfilter = 'yes';
cfg.hpfreq = 0.5;
%cfg.hpfiltord = 2;
%cfg.preproc.detrend = 'yes';
cfg.reref = 'yes';
%cfg.implicitref = 'FCz';
cfg.refchannel = {'all'};

data_LP_rerefM1 = ft_preprocessing(cfg);

% choose the trigger of interest
cfg = [];
cfg.dataset = fullfile(data_folder, filename2);
cfg.trialfun = 'mytrialfun_rest'; % Comment if you don't want to divide activity in bins
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.eventvalue = {'S250'};
cfg.trialdef.prestim = 0;
cfg.trialdef.poststim = 60;
Ritaglio = ft_definetrial(cfg);
data_segmented = ft_redefinetrial(Ritaglio, data_LP_rerefM1);

% %% TRIAL NUMBER

%% Create Layout
cfg = [];
elec = ft_read_sens('easycap-M1.txt');
cfg.elec = elec;
layout = ft_prepare_layout(cfg, data_segmented);

%% visual inspection

cfg = [];
cfg.layout = layout;
cfg.viewmode = 'vertical';
cfg.ylim = [-20 20];
artfct = ft_databrowser(cfg,data_segmented);

%% Reject artifact
artfct.artfctdef.reject = 'complete';
artfct.artfctdef.feedback ='yes';

data_no_vis_artfct = ft_rejectartifact(artfct, data_segmented);


% cd(fullfile(data_folder, SubjFolder))
% 
% save([SubjFolder 'layout'], 'layout')
% save([SubjFolder 'elec'], 'elec')
% save([SubjFolder 'segment.mat'], 'data_segmented')
% save([SubjFolder 'artifact.mat'], 'artfct')
% save([SubjFolder 'no_vis_artfct.mat'], 'data_no_vis_artfct')
%% Prepare neighbours

% Prepare neighbours
cfg = [];
cfg.layout = layout;
cfg.method = 'triangulation';
neighbours = ft_prepare_neighbours(cfg, data_no_vis_artfct);


%% Channel look

% channel
cfg = [];
cfg.method = 'channel';
cfg.layout = layout;
cfg.keepchannel = 'repair';
cfg.neighbours = neighbours;
cfg.elec = elec;
data_interp_bad_chan = ft_rejectvisual(cfg, data_no_vis_artfct)

%% Interpolate Chennel
cfg = [];
cfg.elec = elec;
cfg.badchannel = {'Fp1'}; % Comment if none
cfg.neighbours = neighbours;
data_interp_bad_chan = ft_channelrep

%% summary
cfg = [];
cfg.method = 'summary';
data_interp_bad_end = ft_rejectvisual(cfg, data_interp_bad_chan)

%save([SubjFolder 'interpolated.mat'], 'data_interp_bad_end')

%% ICA
cfg = [];
cfg.method = 'fastica';
cfg.elec = elec;
cfg.layout = layout;
comp = ft_componentanalysis(cfg, data_interp_bad_end);

%% See Components
cfg = [];
cfg.layout = layout;
%cfg.allowoverlap = 'yes';
ft_databrowser(cfg, comp);

%% Reject Components
cfg = [];
cfg.component = [21]; 
ica_rejected = ft_rejectcomponent(cfg, comp, data_interp_bad_end);

% save([SubjFolder 'ICAdone.mat'], 'ica_rejected')

%% Final Filtering
cfg = [];
cfg.lpfilter = 'yes';
cfg.lpfreq = 100;
cfg.dftfilter = 'yes';
cfg.dftfreq = [50 100];
cfg.channel = {'all', '-lEOG'};
preprocessed = ft_preprocessing(cfg, ica_rejected);

%% Look at the data
cfg = [];
cfg.layout = layout;
cfg.viewmode = 'vertical';
cfg.ylim = [-20 20];
ft_databrowser(cfg,preprocessed);

%% Save
sbj = 1;
save(['/Users/menghi/Documents/MATLAB/Fieldtrip_Tutorial/sbj', num2str(sbj),'-Preprocessed'], 'preprocessed','layout')

