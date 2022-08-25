
clear all
close all

disp('This script loops over subjects to extract data from the 10-min delay period');
disp('Data is written to delay.mat in the participants EEG data folder');
disp('That file contains a variable called block - see extract_block.m for format');

desktop=1;

    params.data_folder = 'C:\Users\FOX LAPTOP\Desktop\MATLAB\Data\Data\';


params.period = 'delay'; % Change to 'initial' to look at initial rest period

% Get data for these subjects
id=[1:19];
id(6)=[];

for n=1:length(id),
    params.sbj = id(n);
    
    % Filter and extract block of data - look inside this function for further info
    block = extract_block (params); 
    
    save_str = ['save ',params.data_folder,'ID',int2str(params.sbj),'\delay block'];
    disp(save_str);
    eval(save_str);
end

