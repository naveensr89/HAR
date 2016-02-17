function enter_distributions_commands(command, param)

% This functions handles callbacks from the enter_distributions GUI
% This is an internal toolbox function

switch command
    case 'change_parameter'
        %When there are changes to one of the parameters of an object, save it to file.
        %Used by the manual entry screen.


        tag			= get(param, 'Tag');
        val 			= get(findobj('Tag', 'popNumber'), 'Value');
        zero_or_one = ~get(findobj('Tag', 'rbtClass0'), 'Value');
        num			= str2num(get(param, 'String'));

        switch tag
            case 'txtMeanX'
                evalin('base', ['distribution_parameters(' num2str(zero_or_one+1) ').mu(' num2str(val) ',1)=' num2str(num) ';']);
            case 'txtMeanY'
                evalin('base', ['distribution_parameters(' num2str(zero_or_one+1) ').mu(' num2str(val) ',2)=' num2str(num) ';']);
            case 'txtWeight'
                evalin('base', ['distribution_parameters(' num2str(zero_or_one+1) ').w(' num2str(val) ')=' num2str(num) ';']);
            case 'txtCov11'
                evalin('base', ['distribution_parameters(' num2str(zero_or_one+1) ').sigma(' num2str(val) ',1,1)=' num2str(num) ';']);
            case 'txtCov12'
                evalin('base', ['distribution_parameters(' num2str(zero_or_one+1) ').sigma(' num2str(val) ',1,2)=' num2str(num) ';']);
            case 'txtCov21'
                evalin('base', ['distribution_parameters(' num2str(zero_or_one+1) ').sigma(' num2str(val) ',2,1)=' num2str(num) ';']);
            case 'txtCov22'
                evalin('base', ['distribution_parameters(' num2str(zero_or_one+1) ').sigma(' num2str(val) ',2,2)=' num2str(num) ';']);
        end

    case 'change_class'
        %Change the display of a class, when one of the radio buttons is pressed.
        %Used by the manual entry screen.

        distribution_parameters  = evalin('base', 'distribution_parameters');

        h0 = findobj('Tag', 'rbtClass0');
        h1 = findobj('Tag', 'rbtClass1');
        h  = findobj('Tag', 'txtCount');
        hp = findobj('Tag', 'popNumber');
        n0 = size(distribution_parameters(1).sigma,1);
        n1 = size(distribution_parameters(2).sigma,1);

        if param,
            set(h0, 'Value', not(get(h1, 'Value')));
        else
            set(h1, 'Value', not(get(h0, 'Value')));
        end


        %Set the number of objects (if they exist)
        if (get(h0, 'Value'))
            if (n0>0),
                set(h, 'String', ['There are ' num2str(n0) ' distributions in this class'])
                s = cell(n0, 1);
                for i=1:n0,
                    s(i) =  cellstr(num2str(i));
                end
                set(hp, 'String', s')
                set(hp, 'Value', 1)
                set(hp, 'Max', n0);
            end
        else
            if (n1>0),
                set(h, 'String', ['There are ' num2str(n1) ' distributions in this class'])
                s = cell(n1, 1);
                for i=1:n1,
                    s(i) =  cellstr(num2str(i));
                end
                set(hp, 'String', s')
                set(hp, 'Value', 1)
                set(hp, 'Max', n1);
            end
        end

        enter_distributions_commands('change_object')

    case 'change_object'
        %When the user selects a different object, change the display to show that object.
        %Used by the manual entry screen.

        distribution_parameters  = evalin('base', 'distribution_parameters');

        h 	= findobj('Tag', 'popNumber');
        ht   = findobj('Tag', 'popType');
        hm1  = findobj('Tag', 'txtMeanX');
        hm2 	= findobj('Tag', 'txtMeanY');
        hw 	= findobj('Tag', 'txtWeight');
        hs11 = findobj('Tag', 'txtCov11');
        hs12 = findobj('Tag', 'txtCov12');
        hs21 = findobj('Tag', 'txtCov21');
        hs22 = findobj('Tag', 'txtCov22');
        hc   = findobj('Tag', 'txtCovCaption');

        val = get(h, 'Value');

        zero_or_one = (~get(findobj('Tag', 'rbtClass0'), 'Value'))+1;

        set(hm1,  'String', distribution_parameters(zero_or_one).mu(val,1))
        set(hm2,  'String', distribution_parameters(zero_or_one).mu(val,2))
        set(hs11, 'String', distribution_parameters(zero_or_one).sigma(val,1,1))
        set(hs12, 'String', distribution_parameters(zero_or_one).sigma(val,1,2))
        set(hs21, 'String', distribution_parameters(zero_or_one).sigma(val,2,1))
        set(hs22, 'String', distribution_parameters(zero_or_one).sigma(val,2,2))
        set(hw,   'String', distribution_parameters(zero_or_one).w(val))
        if (strcmp(distribution_parameters(zero_or_one).type(val), 'Gaussian'))
            set(ht,   'Value',  1);
            set(hs21, 'Visible', 'on');
            set(hs22, 'Visible', 'on');
            set(hc, 'String', 'Covariance of the Gaussian:');
        else
            set(ht,   'Value',  2);
            set(hs21, 'Visible', 'off');
            set(hs22, 'Visible', 'off');
            set(hc, 'String', 'Width of the distribution:');
        end
    case 'change_type'
        val 			= get(findobj('Tag', 'popNumber'), 'Value');
        zero_or_one  = ~get(findobj('Tag', 'rbtClass0'), 'Value');
        ht           = findobj('Tag', 'popType');
        hs21         = findobj('Tag', 'txtCov21');
        hs22         = findobj('Tag', 'txtCov22');
        hc           = findobj('Tag', 'txtCovCaption');
        st           = get(ht, 'String');

        if (get(ht, 'Value') == 1)
            %Gaussian
            set(hc, 'String', 'Covariance of the Gaussian:');
            set(hs21, 'Visible', 'on');
            set(hs22, 'Visible', 'on');
        else
            %Uniform
            set(hc, 'String', 'Width of the distribution:');
            set(hs21, 'Visible', 'off');
            set(hs22, 'Visible', 'off');
        end

        evalin('base', ['distribution_parameters(' num2str(zero_or_one+1) ').type{' num2str(val) '} = ''' char(st(get(ht, 'Value'))) ''';']);

        enter_distributions_commands('change_object')

    otherwise
        error('Unknown command')
end
