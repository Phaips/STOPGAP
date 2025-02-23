function o = refresh_reflist(p,o,s,idx)
%% refresh_reflist
% Reload reflist if required. If reference name is given, a reference list
% is generated from parameters.
%
% WW 06-2019

%% Refresh reflist

refresh = false;

% Check if loaded
if ~sg_check_param(o,'reflist')
    refresh = true;
end

% Check if changed
if idx > 1
    if ~strcmp(p(idx).ref_name,p(idx-1).ref_name)
        refresh = true;
    end
end

% Load or generate reference list
if refresh
    
    % Check for list
    [~,~,ext] = fileparts(p(idx).ref_name);
    
    switch ext
        
        % Load list
        case '.star'
            disp([s.cn,'Reference list detected... Loading reflist: ',p(idx).ref_name]);
                       
            % Check for local copy
            if o.copy_local
                copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/','reflist_copied',s.wait_time,[o.listdir,p(idx).ref_name],false);
            end
    
            % Read reflist
            o.reflist = sg_reflist_read([o.rootdir,'/',o.listdir,'/',p(idx).ref_name]);
            
        % Generate list
        case ''
            % Generate reflist for classes
            o.reflist = repmat(struct('ref_name',p(idx).ref_name,'class',1,'mask_name',p(idx).mask_name,'symmetry',p(idx).symmetry),o.n_classes,1);
            classes = num2cell(o.classes);  % Parse class numbers
            [o.reflist.class] = classes{:}; % Store class numbers
    end
            
    
      
end


