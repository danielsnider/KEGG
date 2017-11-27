function [entry, relations] = reaction_edit(entry, relations)

node_name = arrayfun(@(x) getfield(x,'name'), entry,'UniformOutput', false);
node_type = arrayfun(@(x) getfield(x,'reaction'), entry,'UniformOutput', false);

if any(~cellfun(@isempty, node_type))
    unique_name = unique(node_name);
    rels = cell2mat(relations(:,1:2));
    comp_col = relations(:,5);
    
    for i = 1:length(unique_name)
        lbl = unique_name{i};
        idx = strcmp(node_name, unique_name{i});
        idx = find(idx); %find(~cellfun(@isempty, idx));
        if length(idx) > 1
            %             disp('aaa');
            id_main = entry(idx(1)).id;
            ids2convert = cat(1,entry(idx(2:end)).id);
            entry_temp(i,1) = entry(idx(1));
            for j = 1:length(ids2convert)
                if strcmp(entry(idx(1)).type,'compound')
                    %                     disp('aaa');
                    comp_ind = find(cellfun(@strcmp, comp_col, ...
                        repmat({num2str(ids2convert(j))}, size(comp_col))));
                    if ~isempty(comp_ind)
                        %                         disp('aaa');
                        relations(comp_ind,5) = {num2str(id_main)};
                    end
                else
                    [r,c] = find(rels == ids2convert(j));
                    if ~isempty(r)
                        for k = 1:length(r)
                            relations(r(k),c(k)) = {id_main};
                        end
                    end
                end
            end
        else
            entry_temp(i,1) = entry(idx);
        end
    end
    entry = entry_temp;
end









