function trl = mytrialfun_rest(cfg);

% this function requires the following fields to be specified
% cfg.dataset
% cfg.trialdef.eventtype
% cfg.trialdef.eventvalue
% cfg.trialdef.prestim
% cfg.trialdef.poststim

hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

trl = [];

for i=1:length(event)
    
    if strcmp(event(i).type, cfg.trialdef.eventtype)
        
        % it is a trigger, see whether it has the right value
        if ismember(event(i).value, cfg.trialdef.eventvalue)
            % add this to the trl definition
            begsample     = event(i).sample - cfg.trialdef.prestim*hdr.Fs;
            endsample     = event(i).sample + cfg.trialdef.poststim*hdr.Fs - 1;
            for dividetrigger = 1:5
                
                offset        = -cfg.trialdef.prestim*hdr.Fs;
                trigger       = event(i).value; % remember the trigger (=condition) for each trial
                trl(end+1, :) = [round([begsample endsample offset])];
                begsample = endsample+1;
                endsample = endsample+cfg.trialdef.poststim*hdr.Fs;
            end
        end
    end
    
end
