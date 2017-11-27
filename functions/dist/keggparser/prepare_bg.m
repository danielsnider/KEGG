load('kegg_path')
fid = fopen('treat.log', 'w+');
try
    for i = 1:length(kegg_path)
        if ~isempty(kegg_path(i).bg)
            bg = kegg_path(i).bg.deepCopy;
            cm = full(getmatrix(bg));
            horiz = find(sum(cm,2)==0);
            vert = find(sum(cm,1)==0);
            uncon = intersect(horiz, vert);
            fprintf('Number of Nodes in %s: %s, unconnected: %s \n', ...
                kegg_path(i).entry_id, num2str(length(bg.Nodes)), num2str(length(uncon)));
            fprintf(fid, 'Number of Nodes in %s: %s, unconnected: %s \n', ...
                kegg_path(i).entry_id, num2str(length(bg.Nodes)), num2str(length(uncon)));
            ratio(i,1) = length(uncon)/length(bg.Nodes);
            for j = length(uncon):-1:1
                bg = node_del(bg,uncon(j));
            end
            kegg_path(i).bg = bg.deepCopy;
        else
            ratio(i,1) = NaN; 
            kegg_path(i).bg = [];
        end
    end
    fclose(fid);
catch
    fclose(fid);
end

save kp_node_ratio ratio
save kegg_path_ready kegg_path
 