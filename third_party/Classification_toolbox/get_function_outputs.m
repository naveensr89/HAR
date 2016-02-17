function output_arguments = get_function_outputs(algorithm_name)

% Get the output arguments of a Matlab function. The function must be on
% the Matlab path
% This is an internal toolbox function

ml_path = [pwd, ';', path];
in      = [0, strfind(ml_path, ';'), length(ml_path)+1];
found   = 0;

for i = 1:length(in) - 1,
    if found
        break
    end
    
    %Try to find the file on the matlab path
    cur_path        = ml_path(in(i)+1:in(i+1)-1);
    d               = dir([cur_path filesep algorithm_name '.m']);
    
    if ~isempty(d)
        %Open the file and read the function line
        fid         = fopen([cur_path filesep algorithm_name '.m']);
        while 1
            first_line  = fgetl(fid);
            if length(first_line) > 8,
                if strcmp(first_line(1:8), 'function')
                    %Trim the first line to keep only the output part
                    found       = 1;
                    first_line  = first_line(9:end);
                    ind         = strfind(first_line, '=');
                    first_line  = first_line(1:ind-1);
                    
                    %Take the arguments
                    if isempty(strfind(first_line, '['))
                        output_arguments    = strtrim(first_line);
                    else
                        first_line  = strtrim(strrep(strrep(strtrim(first_line), '[', ''), ']', ''));
                        ind         = [0, strfind(first_line, ','), length(first_line)+1];
                        for j = 1:length(ind)-1,
                            output_arguments{j} = strtrim(first_line(ind(j)+1:ind(j+1)-1));
                        end
                    end
                end
            end
            
            if ~ischar(first_line), 
                break, 
            end
        end
    end
end

if ~found
    error(['The file ' algorithm_name '.m was not found on the Matlab path'])
end
