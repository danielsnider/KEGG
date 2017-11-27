for i = 1:104
    if i ~=85
        
        map_name = kegg_path(i).entry_id;
        [tok, map_name] = strtok(map_name, 'path');
        map_name = strtrim(map_name);
        url = 'http://www.kegg.jp/kegg-bin/download?entry=xxx&format=kgml';
        full_path =  regexprep(url, 'xxx', map_name);
        fix_flag = [0,0,0];
        try
            [bg, ~, ~] = parse_KEGG_xml(full_path,fix_flag);
            kegg_path(i).bg = bg.deepCopy;
        catch
            disp(i);
        end
    end
end

save kegg_path kegg_path
