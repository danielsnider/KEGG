function FileName = kegg_batch(fix_flag)
% Performs batch pathway update/download from KEGG pathway
% Using KEGG REST API (for more information see http://www.kegg.jp/kegg/rest/).
% After selection of  organism, all pathways are downloaded, parsed and stored
% as a  kegg_path structure variable (collection).
% Afterwards, collection is stored as a Mat file.
% Function Parse response will be a ground for KEGG REST API class in
% future
try
    
    organism = urlread('http://rest.kegg.jp/list/organism');
    orgs = ParseResponse(organism,'org');
    Selection = listdlg('ListString',orgs(:,2));
    if isempty(Selection)
        disp('Selection canceled');
        FileName = '';
        return;
    end

    homo = organism(Selection);
    path_url = ['http://rest.kegg.jp/list/pathway/',orgs{Selection,1}];
    path_body = urlread(path_url);
    path_cell = ParseResponse(path_body,'path');
    num_pathways = length(path_cell);
    
    fprintf('-----------------------------------\n');
    fprintf('There are %d pathways for selected organisms\n', num_pathways);
    fprintf('-----------------------------------\n');
    flag = input('Do you want to continue? Y/N [Y]: ', 's');
    if regexpi(flag,'y')
        kegg_path = struct('entry_id',{},'definition',{},'bg',{});
        err = [];
        success = [];
        for i = 1:num_pathways
            kegg_path(i,1).entry_id = path_cell{i,1};
            kegg_path(i,1).definition = path_cell{i,2};
            if isempty(regexp(kegg_path(i).definition,'Metabolic pathways','once'))
                try
                    disp(i);
                    success = [success;i];
                    url = 'http://www.genome.jp/kegg-bin/download?entry=xxx&format=kgml';
                    full_path =  regexprep(url, 'xxx', kegg_path(i,1).entry_id);
                    [bg, ~, ~] = parse_KEGG_xml(full_path);
                    kegg_path(i).bg = bg.deepCopy;
                    
                catch
                    ERRORMSG = lasterr;
                    disp(['error kegg_xml: ', ERRORMSG]);
                    err = [err;i];
                    continue;
                end
            end
        end
        
        [FileName,PathName] = uiputfile({'*.mat'},'File Selector');
        full_path = [PathName,FileName];
        save(full_path,'kegg_path');
    end
end

function resp_cell = ParseResponse(response, tag)
if strcmp(tag, 'org')
    ind = regexp(response,'T\d+');
    ind_name = regexp(response,'T\d+','match');
elseif strcmp(tag,'path')
    ind = regexp(response,':\w+\d+')+1;
    ind_name = regexp(response,'(?<=:)\w+\d+','match'); % (?::)\w+\d+
end
rep_string = '';
for i = 1:length(ind);
    if i < length(ind)
        resp_string = response(ind(i):ind(i+1)-1);
        resp_string = regexprep(resp_string, '\t', ' ');
        rep_string =  char(rep_string, resp_string);
        
    elseif i == length(ind)
        resp_string = response(ind(i):end);
        resp_string = regexprep(resp_string, '\t', ' ');
        rep_string =  char(rep_string, resp_string);
    else
        error('problem');
    end
end
resp_cell = cellstr(rep_string);
resp_cell(1) = [];
resp_cell = [ind_name', resp_cell];


