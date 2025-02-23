function o = load_subtomo_masks(p,o,s,idx,mode)
%% load_subtomo_masks
% A function to go through a reflist and load the assigned masks.
%
% WW 06-2019

%% Parse reference indices
reflist_classes = [o.reflist.class];
n_ref = numel(o.reflist);
switch mode{2}
    case 'singleref'
        if n_ref == 1
            ref_idx = 1;
        else
%             ref_idx = reflist_classes == 1;
            ref_idx = zeros(o.n_classes,1);
            for i = 1:o.n_classes
                ref_idx(i) = find(reflist_classes == o.classes(i));
            end
        end
    otherwise
        ref_idx = zeros(o.n_classes,1);
        for i = 1:o.n_classes
            ref_idx(i) = find(reflist_classes == o.classes(i));
        end
end

%% Load masks
disp([s.cn,'Loading masks...']);

% Parse mask names
mask_names = {o.reflist.mask_name};

% Initialize mask array
o.mask = cell(o.n_classes,1);


% Load masks
for i = 1:o.n_classes
        
        % Check for loaded masks
        if i == 1
            
            % Parse mask name
            mask_name = [o.maskdir,'/',mask_names{ref_idx(i)}];
            
            % Check for local copy
            if o.copy_local
                copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/',['mask_',num2str(i),'_copied'],s.wait_time,mask_name,false);
            end
            
            % Load first mask
            o.mask{i} = read_vol(s,o.rootdir,mask_name);
            
            % Resize mask
            if sg_check_param(o,'fcrop')
                o.mask{i} = sg_rescale_volume_realspace(o.mask{i},o.boxsize,'linear');
            end
            
            
        else
        
            % Find preloaded mask
            loaded = find(strcmp(mask_names{ref_idx(i)},mask_names(ref_idx(1:i-1))),1);
            
            if ~isempty(loaded)
                % Copy mask
                o.mask{i} = o.mask{loaded};
                
            else
                
                % Parse mask name
                mask_name = [o.maskdir,'/',mask_names{ref_idx(i)}];
                
                % Check for local copy
                if o.copy_local
                    copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/',['mask_',num2str(i),'_copied'],s.wait_time,mask_name,false);
                end
                
                % Load next mask
                o.mask{i} = read_vol(s,o.rootdir,mask_name);

                % Resize mask
                if sg_check_param(o,'fcrop')
                    o.mask{i} = sg_rescale_volume_realspace(o.mask{i},o.boxsize,'linear');
                end
                
            end
            
        end
end

%% Check spectral mask

if strcmp(mode{1},'avg') || p(idx).completed_ali
    
    % Check for spectral mask
    if sg_check_param(p(idx),'ps_name')
        % Read mask
        if ~sg_check_param(o,'specmask')
            % Parse name
            specmask_name = [o.maskdir,'/',p(idx).specmask_name];
            
            % Check for local copy
            if o.copy_local
                copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/',['specmask_copied'],s.wait_time,specmask_name,false);
            end
                
            % Read mask
            o.specmask = read_vol(s,o.rootdir,specmask_name);
            
        end
        % Check supersampling
        if sg_check_param(o,'avg_ss')
            if o.avg_ss > 1
                o.specmask = sg_rescale_volume_realspace(o.specmask,o.boxsize.*o.avg_ss);
            end
        end
    end
    
end



