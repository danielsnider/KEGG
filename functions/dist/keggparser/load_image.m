function h = load_image(path_name)
% Load static image of parsed KEGG pathway
% path_name - KEGG ID of pathway. For example h = load_image('hsa04062')
% will load pathway with id hsa04062 as an image.
% h - handle to the figure created

url = 'http://www.genome.jp/kegg/pathway/hsa/xxx.png';
full_path =  regexprep(url, 'xxx', path_name);
im_data = imread(full_path);
h = imtool(im_data);