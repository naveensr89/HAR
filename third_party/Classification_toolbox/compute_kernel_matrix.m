function kernel_matrix  = compute_kernel_matrix(patterns1, patterns2, kernel_type, kernel_param)

% Compute the kernel matrix between two sets of patterns, returning a matrix
% of size N1xN2
%
% Inputs:
%   patterns1, patterns2    - Two matrixes of patterns
%   kernel_type             - The kernel function. Can be RBF, Poly,
%                             Linear, Sigmoid, or Precomputed 
%                             (In the last case, patterns1 are returned as 
%                             the kernel matrix 
% Outputs:
%   kernel_matrix           - The kernel matrix
%
% Example:
%   load clouds
%   ker = compute_kernel_matrix(patterns(:, 1:500), patterns(:, 1:500), 'RBF', 1);

%Transform the input patterns
Nf1             = size(patterns1, 2);
Nf2             = size(patterns2, 2);
kernel_matrix   = zeros(Nf1, Nf2);

switch kernel_type,
    case {'Gauss','Gaussian','RBF'},
        for i = 1:Nf2,
            kernel_matrix(:,i)  = exp(-sum((patterns1-patterns2(:,i)*ones(1,Nf1)).^2)'/(2*kernel_param^2));
        end
    case {'Polynomial', 'Poly', 'Linear'}
        if strcmp(kernel_type, 'Linear')
            kernel_param = 1;
        end

        for i = 1:Nf2,
            kernel_matrix(:,i)  = (patterns1'*patterns2(:,i) + 1).^kernel_param;
        end
    case 'Sigmoid'
        kernel_param = str2num(kernel_param);

        if (length(kernel_param) ~= 2)
            error('This kernel needs two parameters to operate!')
        end

        for i = 1:Nf2,
            kernel_matrix(:,i)  = tanh(patterns1'*patterns2(:,i)*kernel_param(1)+kernel_param(2));
        end
    case 'Precomputed'
        kernel_matrix           = patterns1;
    otherwise
        error('Unknown kernel. Can be Gauss, Linear, Poly, or Sigmoid.')
end
