Menu Commands:

1. File
	
	1.1 Batch KEGG update - download all pathways for selected organism and stores it as a preprocesses/parsed graph objects in MAT file
	
	1.2 Close - close KEGG_parser
/---------------------------------------------/

2. Help
	
	2.1 Readme - this help
/---------------------------------------------/	

3. Selection boxes and address bar
	
	3.1 Node 1 - node selection for using with pathway editing commands 
	
	3.2 Node 2 - node selection for using with pathway editing commands 
	
	3.3 Interaction type - selection of iteraction type ("binding", "activation", "inhibition")
	
	3.4 Address Bar - shows path to local selected local files OR specifies KEGG pathway map for download from internet
/---------------------------------------------/
	
4. Load Buttons
	
	4.1 Load local map - loads parsed KEGG pathway map from MAT file
	
	4.2 Load local collection - loads parsed KEGG pathway map from locally stored collection in MAT file
	
	4.3 Load local xml - loads and parses KEGG pathway map from downloaded KGML file
	
	4.4 Load from KEGG - downloads and parses KEGG pathway map specified in address bar (requires pathway id, e.g. hsa04062)
/---------------------------------------------/

5. Save Buttons
	
	5.1 Save - saves pathway graph object as single MAT file
	
	5.2 Save 2 collection - replaces pathway graph object with new one. 
	
	5.3 Export xml - exports pathway graph object back to KGML format (not ready yet)
	
	5.4 Export txt - exports as a txt files suitable for loading into Cytoscape (not ready yet)
/---------------------------------------------/
	
6. Editing Buttons
	
	6.1 Add edge - adds edge between nodes specified by "Node 1" and "Node 2" selection boxes
	
	6.2 Delete edge - deletes edge between nodes specified by "Node 1" and "Node 2" selection boxes
	
	6.3 Reverse edge - reverses edge direction between nodes specified by "Node 1" and "Node 2" selection boxes
	
	6.4 Add node - adds new node to pathway graph object (node properties can be edited using Property Inspector)
	
	6.5 Delete node - deletes node specifird by "Node 1" selection box only (also removes all edges to/from the node)
	
	6.6 Refresh layout - save current graph layout, corrects edge positions bewteen nodes.   
