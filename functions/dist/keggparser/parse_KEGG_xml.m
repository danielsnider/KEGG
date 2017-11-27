function [bg,entry, relations] = parse_KEGG_xml(filename, fix_flag)
% [bg,entry, relations] = parse_KEGG_xml(filename)
% Parse KGML (KEGG Markup Language) xml file into Matlab biograph object.
% filename - is full filename including path and extension or URL to KGML
% file
if nargin==1
    fix_flag = [1, 1, 1];
end


xDoc = xmlread(filename);
allPathways = xDoc.getElementsByTagName('pathway');
path_org = char(allPathways.item(0).getAttribute('org'));
path_name = char(allPathways.item(0).getAttribute('name'));
path_title = char(allPathways.item(0).getAttribute('title'));
path_image = char(allPathways.item(0).getAttribute('image'));
allEntries = xDoc.getElementsByTagName('entry');
allRelations = xDoc.getElementsByTagName('relation');
entryAttr = [{'id0'},{'id'}, {'name'}, {'type'}, {'link'},{'reaction'}];
entries = cell(allEntries.getLength,5);

for i = 0:allEntries.getLength-1 %create initial structure variable containing node attributes
    id(i+1,1) = {i+1};
    for j = 2:length(entryAttr)
        if strcmp(entryAttr{j},'id')
            entries{i+1,j} = str2num(char(allEntries.item(i).getAttribute(entryAttr{j})));
        else
            entries{i+1,j} = char(allEntries.item(i).getAttribute(entryAttr{j}));
        end
    end
end
ind_gr = [];
entries(:,1) = id;
entry = cell2struct(entries,entryAttr,2);
for i = 1:length(entry)
    [graph, comp] = keggchildnode(allEntries.item(i-1)); %parse node attributes
    if ~isempty(comp) %check if node contain subnodes
        graph.name = 'component';
        ind_gr = [ind_gr;i];
    end
    entry(i).component = comp;
    entry(i).graph = graph;
end

%---- create relations
flag = 0;
for k = 0:allRelations.getLength-1
    if allRelations.item(k).getChildNodes.getLength == 3
        relations(k+1,:) = [{str2num(char(allRelations.item(k).getAttribute('entry1')))} ...
            {str2num(char(allRelations.item(k).getAttribute('entry2')))}...
            {char(allRelations.item(k).getAttribute('type'))} ....
            {char(allRelations.item(k).getChildNodes.item(1).getAttribute('name'))}...
            {char(allRelations.item(k).getChildNodes.item(1).getAttribute('value'))}...
            {[]}...
            {[]}];
        flag = 1;
    elseif allRelations.item(k).getChildNodes.getLength == 5
        relations(k+1,:) = [{str2num(char(allRelations.item(k).getAttribute('entry1')))} ...
            {str2num(char(allRelations.item(k).getAttribute('entry2')))}...
            {char(allRelations.item(k).getAttribute('type'))} ....
            {char(allRelations.item(k).getChildNodes.item(1).getAttribute('name'))}...
            {char(allRelations.item(k).getChildNodes.item(1).getAttribute('value'))}...
            {char(allRelations.item(k).getChildNodes.item(3).getAttribute('name'))}...
            {char(allRelations.item(k).getChildNodes.item(3).getAttribute('value'))}];
        flag = 1;
    elseif allRelations.item(k).getChildNodes.getLength == 1
        relations(k+1,:) = [{str2num(char(allRelations.item(k).getAttribute('entry1')))} ...
            {str2num(char(allRelations.item(k).getAttribute('entry2')))}...
            {char(allRelations.item(k).getAttribute('type'))} ....
            {[]}...
            {[]}...
            {[]}...
            {[]}];
        flag = 1;
    end
end
if flag ~= 0
    %     mat = [cell2mat(entries(:,1:2))];
    [entry, relations] = reaction_edit(entry, relations);
    [cm, relations, edge_col] = prep_relations(relations,entry, fix_flag); % prepare relations for creation of pathway graph object
    bg = draw_graph(cm, edge_col,entry,path_org); % graph creation, setup of node and edge properies
elseif flag == 0
    cm = zeros(length(entry));
    cm(2,1) = 1;
    bg = draw_graph(cm, [],entry,path_org);
    bg = edge_del(bg, 2,1);
    relations = [];
end
set(bg,'ID',path_name);
set(bg,'Label',path_title);
set(bg,'Description',path_image);

%-----SubFunctions----

%-----KEGGCHILDNODE----
function [graphics, component] = keggchildnode(keggNode)
% Node attribute parsing and group nodes

child = keggNode.getChildNodes;
childLength = child.getLength;
k = 1;
component = [];
for i = 0:childLength-1
    if child.item(i).getNodeType == 1
        if strcmp(char(child.item(i).getNodeName),'graphics')
            [xx_name, xx_val] = parseattributes(child.item(i));
            k = k+1;
        elseif strcmp(char(child.item(i).getNodeName),'component')
            [~, comp_val] = parseattributes(child.item(i));
            component = [component, str2num(comp_val{:})];
        end
    end
end
graphics = cell2struct(xx_val,xx_name,2);
return;

%-----PARSEATTRIBUTES----
function [attributes_name, attributes_value] = parseattributes(theNode)

attributes = [];
if theNode.hasAttributes
    theAttributes = theNode.getAttributes;
    numAttributes = theAttributes.getLength;
    for count = 0:numAttributes-1
        attrib = theAttributes.item(count);
        attributes_name{count+1} = char(attrib.getName);
        attributes_value{count+1} = char(attrib.getValue);
    end
end

%-----PREP_RELATIONS----
function [cm, relations,edge_col] = prep_relations(relations, entry, fix_flag)
% Prepare egde information from KEGG xml files
% create connection matrix for biograph object


%check if there is empty rows in relations variable
empty_ind = [];
for i = 1:size(relations,1)
    if isempty(relations{i,1})
        empty_ind = [empty_ind; i];
    end
end
try
    relations(empty_ind,:) = [];
end
flag_group = num2cell(zeros(size(relations,1),1));
relations = [relations,flag_group];

% Correct protein compound-protein interactions
if fix_flag(1)==1
    ind = strcmp('compound',relations(:,4));
    rels = relations(ind,:);
    relations_new = num2cell(zeros(1,8));
    for i = 1:size(rels,1)
        rels_new1 = rels(i,:);
        rels_new2 = rels(i,:);
        rels_new1{2} = str2num(rels{i,5});
        rels_new1(4:5) = rels(i,6:7);
        rels_new2{1} = str2num(rels{i,5});
        rels_new2(4:5) = rels(i,6:7);
        x1 = all(bsxfun(@eq,cell2mat(rels_new1(:,1:2)),...
            cell2mat(relations_new(:,1:2))),2);
        relations_new = relations_new(~x1,:);
        x2 = all(bsxfun(@eq,cell2mat(rels_new2(:,1:2)),...
            cell2mat(relations_new(:,1:2))),2);
        relations_new = relations_new(~x2,:);
        relations_new = [relations_new; rels_new1; rels_new2];
    end
    relations(ind,:) = [];
    relations = [relations; relations_new(2:end,:)];
end

% Correct group nodes
if fix_flag(2)==1
    
    node_type = cellstr(char(entry(:).type));
    
    group_ind = find(strcmpi(node_type,'group'));
    if ~isempty(group_ind)
        group_exist = true;
        groups = entry(group_ind);
    else
        group_exist = false;
    end
    
    % groups = flipud(groups);
    while group_exist
        
        for i = 1:length(groups)
            relations_new = num2cell(zeros(1,8));
            rel_template = {[0],[0],'PPrel','binding/association','---',[],[],[1]};
            rel_ids = cell2mat(relations(:,1:2));
            gr_in_relations_ind = find(groups(i).id == rel_ids(:,2));
            gr_out_relations_ind = find(groups(i).id == rel_ids(:,1));
            comp_node_id = sort(groups(i).component);
            comp_relations_in = bsxfun(@eq, comp_node_id,rel_ids(:,2));
            comp_relations_out = bsxfun(@eq, comp_node_id,rel_ids(:,1));
            comp_in_count  = sum(comp_relations_in);
            comp_out_coount  = sum(comp_relations_out);
            total = ([comp_node_id; comp_in_count; comp_out_coount])';
            total = sortrows(total,[-2,3,1]);
            rel_inner = rel_template;
            rel_in_temp =  relations(gr_in_relations_ind,:);
            rel_out_temp = relations(gr_out_relations_ind,:);
            check = any(total(:,2:3));
            bin = sum(check.*2.^[0,1]);
            
            switch bin
                case 0
                    for j = 1:length(total(:,1))-1
                        rel_inner(j,:) = rel_template;
                        rel_inner{j,1} = total(j,1);
                        rel_inner{j,2} = total(end,1);
                    end
                    if ~isempty(rel_in_temp)
                        rel_in_temp(:,2) = {total(end,1)};
                    end
                    if ~isempty(rel_out_temp)
                        rel_out_temp(:,1) = {total(end,1)};
                    end
                case 1
                    for j = 2:length(total(:,1))
                        rel_inner(j,:) = rel_template;
                        rel_inner{j,1} = total(j,1);
                        rel_inner{j,2} = total(1,1);
                    end
                    if ~isempty(rel_in_temp)
                        rel_in_temp(:,2) = {total(1,1)};
                    end
                    if ~isempty(rel_out_temp)
                        rel_out_temp(:,1) = {total(1,1)};
                    end
                case 2
                    for j = 1:length(total(:,1))-1
                        rel_inner(j,:) = rel_template;
                        rel_inner{j,1} = total(j,1);
                        rel_inner{j,2} = total(end,1);
                    end
                    if ~isempty(rel_in_temp)
                        rel_in_temp(:,2) = {total(end,1)};
                    end
                    if ~isempty(rel_out_temp)
                        rel_out_temp(:,1) = {total(end,1)};
                    end
                case 3
                    C = nchoosek(comp_node_id,2);
                    for z = 1:size(C,1)
                        check(z,:) = [any(all(bsxfun(@eq, rel_ids,C(z,:)),2)), ...
                            any(all(bsxfun(@eq,rel_ids,fliplr(C(z,:))),2))];
                        if ~any(any(check(z,:)))
                            for j = 2:length(total(:,1))
                                rel_inner(j,:) = rel_template;
                                rel_inner{j,1} = total(j,1);
                                rel_inner{j,2} = total(1,1);
                            end
                            if ~isempty(rel_in_temp)
                                rel_in_temp(:,2) = {total(1,1)};
                            end
                            if ~isempty(rel_out_temp)
                                rel_out_temp(:,1) = {total(1,1)};
                            end
                        else
                            ind = total(:,1) == C(check(z,:));
                            total(ind,:)=[];
                            if ~isempty(rel_in_temp)
                                rel_in_temp(:,2) = {total(end,1)};
                            end
                            if ~isempty(rel_out_temp)
                                rel_out_temp(:,1) = {total(end,1)};
                            end
                        end
                        
                    end
            end
            relations([gr_in_relations_ind(:); gr_out_relations_ind(:)],:) = [];
            relations_new = [relations_new; rel_in_temp; rel_inner;rel_out_temp];
            relations = [relations; relations_new];
        end
        rel_gr_ind = unique([cat(1,relations{:,1});cat(1,relations{:,2})]);
        gr_id = cat(1,groups(:).id);
        mask  = any(bsxfun(@eq, gr_id, rel_gr_ind'),2);
        groups = groups(mask);
        if isempty(groups)
            group_exist = false;
        end
        
    end % end of while
    rel_ids = cell2mat(relations(:,1:2));
    relations(any(rel_ids == 0,2),:)=[];
    entry(group_ind)=[];
end

mat = [(1:length(entry))',cat(1,entry.id)];
cm = zeros(length(entry));

index = relations(:,1:2);
for i = 1:size(index,1)
    %     disp(i);
    if ~isempty(index{i,1}) && ~isempty(index{i,2})
        cm_ind1 = (mat(:,2)==index{i,1});
        cm_ind2 = (mat(:,2)==index{i,2});
        %         cm_ind1 = cm_ind1(1);
        %         cm_ind2 = cm_ind2(1);
        cm(mat(cm_ind1,1),mat(cm_ind2,1))=1;
        edge_imp = [relations(i,4),relations(i,6)];
        if any(strcmpi(edge_imp,'activation'))
            edge_col(i,:) = [mat(cm_ind1,1),mat(cm_ind2,1), 1, 0, 0,0];
        elseif any(strcmpi(edge_imp,'inhibition'))
            edge_col(i,:) = [mat(cm_ind1,1),mat(cm_ind2,1), 0, 1, 0,0];
        elseif any(strcmpi(edge_imp,'binding/association'))
            % correction of binding direction depending on node positions
            if (relations{i,end}==0) && (fix_flag(3)==1)
                if (str2num(entry(mat(cm_ind1,1)).graph.x) - ...
                        str2num(entry(mat(cm_ind2,1)).graph.x))>0 %((mat(cm_ind1,2)< mat(cm_ind2,2))&&...
                    
                    cm(mat(cm_ind1,1),mat(cm_ind2,1))=0;
                    cm(mat(cm_ind2,1),mat(cm_ind1,1))=1;
                    edge_col(i,:) = [mat(cm_ind2,1),mat(cm_ind1,1), 0, 0, 1,0];
                else
                    edge_col(i,:) = [mat(cm_ind1,1),mat(cm_ind2,1), 0, 0, 1,0];
                end
            else
                edge_col(i,:) = [mat(cm_ind1,1),mat(cm_ind2,1), 0, 0, 1,1];
            end
            
        elseif any(strcmpi(edge_imp,'dissociation'))
            edge_col(i,:) = [mat(cm_ind1,1),mat(cm_ind2,1), 0, 0, 0,0];
        elseif any(strcmpi(edge_imp,'indirect effect'))
            edge_col(i,:) = [mat(cm_ind1,1),mat(cm_ind2,1), 1, 0, 1,0];
        else
            edge_col(i,:) = [mat(cm_ind1,1),mat(cm_ind2,1), 0, 0, 1,0];
        end
    end
    
end
edge_col = sortrows( edge_col,[1,2]);

%----DRAW_GRAPH----
function bg = draw_graph(cm, edge_col,entry,org)
% Graph construction from connection matrix, edge colors, entry elements,
% and information about organism
% cm  - connection matrix
% egde_col - matrix of edge colors obtained from prep_relations function.
% entry - list of nodes and attributes generated in parse_KEGG_xml.m
root_pos = get(0,'ScreenSize');
bg = biograph(cm,[],'NodeAutoSize','off','Scale', 1, 'LayoutScale',1);
if ~isempty(edge_col)
    for i = 1:size(edge_col,1)
        if (edge_col(i,1)~=edge_col(i,2));
            edgr_ind = bg.to(edge_col(i,1),edge_col(i,2));
            set(bg.Edges(edgr_ind),'LineColor',edge_col(i,3:5));
            set(bg.Edges(edgr_ind),'Userdata',edge_col(i,6)); % Information whether relation belongs to group relations
        end
    end
end
dolayout(bg)
GeneList = [];
for i = 1:length(bg.Nodes)
    try
        if isfield(entry(i).graph,'name')
            tx = parse_node_name(entry(i).graph.name);
        else
            tx = parse_node_name(entry(i).name);
        end
        bg.Nodes(i).ID= num2str(entry(i).id);
        bg.Nodes(i).Label = tx;
        node_type = entry(i).graph.type;
        if strcmp(node_type,'roundrectangle')
            node_type = 'ellipse';
        end
        if strcmp(node_type,'line')
            node_type = 'rectangle';
            usr.List = [];
            usr.link = [];
            continue;
        end
        
        bg.Nodes(i).Shape = node_type;
        bg.Nodes(i).Position = [str2double(entry(i).graph.x), ...
            root_pos(4)-(str2double(entry(i).graph.y))];
        bg.Nodes(i).Size = [str2double(entry(i).graph.width), ...
            str2double(entry(i).graph.height)];
        usr.link = entry(i).link;
        pattern = ['(?<=',org,':)\d+'];
        GIs =regexp(entry(i).name,pattern,'match');
        if isempty(GIs)
            usr.List = [];
        else
            usr.List =  str2num(char(GIs(:)));
            GeneList = [GeneList;usr.List];
        end
        bg.Nodes(i).UserData =  usr;
    catch
        ERRMSG = lasterr;
        disp(['Error in draw_graph: ', ERRMSG]);
    end
end
dolayout(bg,'PathsOnly', true);
set(bg,'ShowTextInNodes','Label');


%----PARSE_NODE_NAME----
function text = parse_node_name(node_text)
text = regexp(node_text, '\w*(?=,)', 'match','once');
if isempty(text)
    text = node_text;
end



