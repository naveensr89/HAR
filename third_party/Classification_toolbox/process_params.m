function varargout = process_params(parameters)

% This function receives a parameter vector and returns it's components
% This is an internal toolbox function

if isnumeric(parameters)
    %If the parameter vector is composed of numbers, it is simple to parse
    for i = 1:length(parameters)
        varargout{i}    = parameters(i);
    end
else
    %Check if the input is ok
    if length(strfind(parameters, '[')) ~= length(strfind(parameters, ']'))
        error('The number of opening and closing brackets in the parameter vectors is not equal!')
    end
    
    if strcmp(parameters(1), '[')
        parameters  = parameters(2:end-1);
    end
    parameters(end+1)   = ',';
    parameters          = strrep(parameters, ', ', ',');
    parameters          = strrep(parameters, ' ,', ',');
    parameters          = strrep(parameters, '''', '');
    
    param_counter   = 0;
    loc_pointer     = 0;
    in_brackets     = 0;
    while ~isempty(parameters) && (loc_pointer ~= length(parameters))
        loc_pointer = loc_pointer + 1;
        switch parameters(loc_pointer)
            case '['
                in_brackets = in_brackets + 1;
            case ']'
                in_brackets = in_brackets - 1;
            case ','
                if (in_brackets == 0) %If we are not inside brackets
                    param_counter   = param_counter + 1;
                    cur_param       = parameters(1:loc_pointer-1);
                    
                    %Try to make the parameter into a number
                    if ~isempty(str2num(cur_param))
                        cur_param   = str2num(cur_param);
                    end
                    
                    %Save the parameter
                    varargout{param_counter}    = cur_param;
                    parameters                  = parameters(loc_pointer+1:end);
                    loc_pointer                 = 0;
                end
            otherwise
        end
    end
end
