function [ dirList ] = get_directory_names( dir_name )
    %get_directory_names; this function outputs a cell with directory names (as
    %strings), given a certain dir name (string)
    %from: http://stackoverflow.com/questions/8748976/list-the-subfolders-
    %in-a-folder-matlab-only-subfolders-not-files

    dd = dir(dir_name); %lists all the contents of the folder dir_name
    
    % a logical vector: true if a given element of dd is a directory
    isub = [dd(:).isdir]; 
    
    % a vector of all the names of subfolders of dir_name
    % Note: also includes '.' and '..' from Linux filestructure
    dirList = {dd(isub).name}';
    
    % remove '.' and '..' by indexing with a logical vector from ismember()
    dirList(ismember(dirList,{'.','..'})) = [];

end