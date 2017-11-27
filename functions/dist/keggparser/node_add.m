function bg = node_add(bg, node_pos, node_size, UserData)
% Add new node to existing graph.
% node_pos - [x,y]
% node_size - [height, width]
% UserData - anything you might want to put there

if (nargin <1) || (nargin > 4)
    error('Error');
end

to = full(bg.to);
idx = length(to)+1;
row = zeros(1,size(to,2));
to = [to;row];
col = zeros(size(to,1),1);
to = [to,col];
bg.to = sparse(to);
bg.from = sparse(to)';
bg.nodes(idx) = biograph.node(bg,num2str(idx) ,idx);
if nargin ==2
    bg.nodes(idx).Position = node_pos;
elseif nargin == 3
    bg.nodes(idx).Position = node_pos;
    bg.nodes(idx).Size = node_size;
elseif nargin == 4
    bg.nodes(idx).Position = node_pos;
    bg.nodes(idx).Size = node_size;
    bg.nodes(idx).UserData = UserData;
end
IDstr = get(bg.Nodes,'ID');
IDnumcell = cellfun(@str2num,IDstr,'UniformOutput', false);
IDnum = cat(1,IDnumcell{:});
if ~isempty(IDnum)
    IDnew = max(IDnum)+1;
    set(bg.Nodes(end), 'ID', num2str(IDnew));
end


    
