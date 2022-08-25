function [block] = extract_block (params)
% Extract block of EEG data
% FORMAT [block] = extract_block (params)
%
% params    .data_folder    Path to data
%           .sbj            Subject number
%           .period         'delay' or 'initial' 
%
% block     .eeg            [32 x T] channels of EEG data at T time points
%           .fsample        Sample rate
%           .label          {i} names of EEG channels, i=1..32

ss = int2str(params.sbj);
data_folder = [params.data_folder,'ID',ss,'\'];
filename1 = [ss,'.eeg'];  % EEG data
filename2 = [ss,'.vhdr']; % Electrode labels, and markers/triggers

% highpass filtering without segmenting

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
%cfg.trialfun = 'mytrialfun_rest'; % Comment if you don't want to divide activity in bins
cfg.trialdef.eventtype = 'Stimulus';

switch params.period,
    case 'delay',
        % Beginning of Quiescence or for every image with the SpotTheDiff Task
        cfg.trialdef.eventvalue = {'S250'}; 
        if mod(params.sbj,2)==0 
            % Even numbered participants are in SpotDiff group
            SpotDiff=1;
        else
            SpotDiff=0;
        end
    case 'initial',
        % Initial rest period
        cfg.trialdef.eventvalue = {'S249'}; 
    otherwise
        disp('Unknown period type in extract_block.m');
        return
end

cfg.trialdef.prestim = 0;
cfg.trialdef.poststim = 600; % 10 minutes
Ritaglio = ft_definetrial(cfg);
data_segmented = ft_redefinetrial(Ritaglio, data_LP_rerefM1);  

if strcmp(params.period,'delay') & SpotDiff
    % Remove all but first trial as this will already cover 10min period
    data_segmented.trial(2:end)=[];
    data_segmented.time(2:end)=[];
    data_segmented.trialinfo(2:end)=[];
    data_segmented.sampleinfo(2:end,:)=[];
end

% Create Layout
cfg = [];
elec = ft_read_sens('easycap-M1.txt');
cfg.elec = elec;
cfg.continuous = 1;
layout = ft_prepare_layout(cfg, data_segmented);


% Final Filtering
cfg = [];
cfg.lpfilter = 'yes';
cfg.lpfreq = 100;
cfg.dftfilter = 'yes';
cfg.dftfreq = [50 100];
cfg.channel = {'all', '-lEOG'};
preprocessed = ft_preprocessing(cfg, data_segmented);

block.eeg = preprocessed.trial{1};
block.fsample = preprocessed.fsample;
block.label = preprocessed.label;


