
clear all
close all

disp('This script loops over subjects to create delay period spectra at a selected electrode');
disp('See extract_multiple_blocks.m for earlier processing');

desktop=1;

    params.data_folder = 'C:\Users\FOX LAPTOP\Desktop\MATLAB\Data\Data\';


%params.period = 'delay';

% Select electrode
electrode_num=16;  % This corresponds to '01'. Look in block.label for names ...

% Get data for these subjects
id=[1:27];
id(6)=[];

for n=1:length(id),
    
    params.sbj = id(n);
    load_str = ['load ','.\.\Data\Data\','ID',int2str(params.sbj),'\delay'];
    disp(load_str);
    eval(load_str);
    
    
    x = block.eeg(electrode_num,:);
    
    % Downsample by a factor of R 
    R = 20;  
    y = resample(x,1,R); 
    
    [pp,f(:,n)] = pwelch(y,[],[],[],block.fsample/R);
    
    % Normalise wrt total power for that subject
    p(:,n) = pp./sum(pp);
end
%% Finding  % of alpha waves
clc
alphavec=zeros(27,1);
t=0;
for n=1:length(id),

    for l=1:length(f)  
        alpha=0;
        t=t+1;
        if 7 <=f(l,n) && f(l,n) <= 14
            alpha = alpha + p(l,n);
        end
    end

     alphavec(n,1)=alpha;                                                                                                                                                      
     disp(alphavec)
end
%%
filename= 'alpha.xlsx';
writematrix(alphavec,filename)

%% Finding  % of delta waves
clc
deltavec=zeros(27,1);
t=0;
for n=1:length(id),
delta=0;
    for l=1:length(f)  
        
        t=t+1;
        if 2 <=f(l,n) && f(l,n) <= 8
            disp('hola')
            delta = delta + p(l,n);
        end
    end

     deltavec(n,1)=delta;  
     disp(deltavec)
end
%%
filename= 'delta.xlsx';
writematrix(deltavec,filename)
%%
% Plot spectrum for first 16 subjects
figure;
pmax=max(max(p));

for n=1:27,
    subplot(4,4,n);
    plot(f(:,n),p(:,n));
    ylim([0 pmax]);
    xlabel('Freq (Hz)');
    ylabel('Power');
    grid on
    title(sprintf('Subject %d',id(n)));
end

save power_spectra p f
%%

    