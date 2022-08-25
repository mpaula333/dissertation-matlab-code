
clear all
close all

%load ../data/ID1/sbj1
% 
% load ././Data/Data/ID17/sbj17
id = 27;
m = zeros(id,6);
 
for n = 1:id

    if n ~=6

        params.sbj = (n);
        load_str = ['.\.\Data\Data\','ID',int2str(params.sbj),'\sbj',int2str(params.sbj)];
        load(load_str)
        m(n,1) = (n);
        
    
        perf = subject_behaviour (Results);
        disp(perf)
    
        m(n,2)=perf.tr;
        m(n,3)=perf.pre_old;
        m(n,4)=perf.pre_new;
        m(n,5)=perf.post_old;
        m(n,6)=perf.post_new;

    end
end
m(6,:) = []
 disp(m)
 %%
filename= 'results.xlsx';

writematrix(m,filename)

