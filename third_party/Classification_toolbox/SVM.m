function [test_targets, a_star, Nsv, target_function_value] = SVM(train_patterns, train_targets, test_patterns, params)

% Classify using (a very simple implementation of) the support vector machine algorithm
%
% Inputs:
% 	train_patterns	- Train patterns
%	train_targets	- Train targets
%   test_patterns   - Test  patterns
%	params	        - [kernel, kernel parameter, solver type, Slack]
%                     Kernel can be one of: Gauss, RBF (Same as Gauss), Poly, Sigmoid, Linear, or Precomputed
%                     The kernel parameters are:
%                       RBF kernel  - Gaussian width (One parameter)
%                       Poly kernel - Polynomial degree
%                       Sigmoid     - The slope and constant of the sigmoid (in the format [1 2], with no separating commas)
%					    Linear		- None needed
%                       Precomputed - None needed
%                     Solver type can be one of: Perceptron, Quadprog, Lagrangian, Seq, Cascade
%
% Outputs
%	test_targets	- Predicted targets
%	a			    - SVM coeficients
%
% Note: The number of support vectors found will usually be larger than is actually
% needed because the two first solvers are approximate.
%
%See also: Ada_Boost
%
%Example:
% load clouds
% t = SVM(patterns(:,1:1000), targets(1:1000), patterns(:, 1001:end), '[''RBF'', 1, ''Lagrangian'', 1]');
% disp(mean(t == targets(1001:end)))

[Dim, Nf]       = size(train_patterns);
Dim             = Dim + 1;
train_patterns(Dim,:) = ones(1,Nf);
test_patterns(Dim,:)  = ones(1, size(test_patterns,2));

if (length(unique(train_targets)) == 2)
    z   = 2*(train_targets>0) - 1;
else
    z   = train_targets;
end

%Get kernel parameters
[kernel, ker_param, solver, slack] = process_params(params);

%Transform the input patterns
y   = compute_kernel_matrix(train_patterns, train_patterns, kernel, ker_param);

%Find the SVM coefficients
switch solver
    case 'Quadprog'
        %Quadratic programming
        alpha_star	= quadprog(diag(z)*y'*y*diag(z), -ones(1, Nf), zeros(1, Nf), 1, z, 0, zeros(1, Nf), slack*ones(1, Nf))';
        a_star		= (alpha_star.*z)*y';

        %Find the bias
        sv_for_bias  = find((alpha_star > 0) & (alpha_star < slack - 0.001*slack));
        %sv_for_bias  = find((alpha_star > 0.001*slack) & (alpha_star < slack - 0.001*slack));
        if isempty(sv_for_bias),
            bias     = 0;
        else
            B        = z(sv_for_bias) - a_star(sv_for_bias);
            bias     = mean(B);
        end

        sv           = find(alpha_star > 0);
        %sv           = find(alpha_star > 0.001*slack);

    case 'Perceptron'
        max_iter		= 1e4;
        iter			= 0;
        rate        = 0.01;
        xi				= ones(1,Nf)/Nf*slack;

        if ~isfinite(slack),
            slack = 0;
        end

        %Find a start point
        processed_y	= [y; ones(1,Nf)] .* (ones(Nf+1,1)*z);
        a_star		= mean(processed_y')';

        while ((sum(sign(a_star'*processed_y+xi-1)~=1)>0) & (iter < max_iter))
            iter 		= iter + 1;
            if (iter/5000 == floor(iter/5000)),
                disp(['Working on iteration number ' num2str(iter)])
            end

            %Find the worse classified sample (That farthest from the border)
            dist			= a_star'*processed_y+xi;
            [m, indice] = min(dist);
            a_star		= a_star + rate*processed_y(:,indice);

            %Calculate the new slack vector
            xi(indice)  = xi(indice) + rate;
            xi				= xi / sum(xi) * slack;
        end

        if (iter == max_iter),
            disp(['Maximum iteration (' num2str(max_iter) ') reached']);
        else
            disp(['Converged after ' num2str(iter) ' iterations.'])
        end

        bias   = 0;
        a_star = a_star(1:Nf)';

        sv     = find(((z.*a_star) < slack/Nf) & ((z.*a_star) > 0));
        %sv	  = find(abs(a_star) > slack*1e-3);

    case 'Lagrangian'
        %Lagrangian SVM (See Mangasarian & Musicant, Lagrangian Support Vector Machines)
        tol         = 1e-5;
        max_iter    = 1e5;
        nu          = 1/Nf;
        iter        = 0;

        D           = diag(z);
        alpha       = 1.9/nu;

        e           = ones(Nf,1);
        I           = speye(Nf);
        Q           = I/nu + D*y'*D;
        P           = inv(Q);
        u           = P*e;
        oldu        = u + 1;

        while ((iter<max_iter) & (sum(sum((oldu-u).^2)) > tol)),
            iter    = iter + 1;
            if (iter/5000 == floor(iter/5000)),
                disp(['Working on iteration number ' num2str(iter)])
            end
            oldu    = u;
            f       = Q*u-1-alpha*u;
            u       = P*(1+(abs(f)+f)/2);
        end

        a_star    = (y*D*u(1:Nf))';
        bias      = -e'*D*u;
        sv  = find(u > 1e-3);
        %sv        = find((a_star < slack/Nf) & (a_star > 0));
        %sv        = find(((z'.*a_star) < slack/sqrt(Nf)) & ((z'.*a_star) > 0));
        %sv		  = find(abs(a_star) < slack*1e-3);

    case 'Seq'
        % Sequential SVM, as per Sethu Vijayakumar and Si Wu "Sequential
        % support vector classifiers and regression"

        lambda    = 1/Nf;
        max_diff  = 1e-5;

        D         = (z'*z).*(y + lambda^2);
        max_iter  = 1000;
        iter      = 0;
        stop      = 0;
        h         = zeros(Nf, 1);

        gamma     = 0.2 / max(D(:));

        J         = [];
        training_mode   = 'batch'; %You can choose between sequential, stochastic, or batch
        
        while ~stop & (iter < max_iter)
            switch training_mode
                case 'stochastic'
                    for i = 1:length(h)
                        ii  = max(1, min(Nf, round(Nf*rand(1))));
                        E = h'*D(:, ii);
                        d_h  = min(max(gamma*(1 - E'), -h(i)), slack - h(ii));
                        h(ii)     = h(ii) + d_h;
                    end
                case 'stochastic'
                    for i = 1:length(h)
                        E = h'*D(:, i);
                        d_h  = min(max(gamma*(1 - E'), -h(i)), slack - h(i));
                        h(i)     = h(i) + d_h;
                    end
                case 'batch'
                    E     = h'*D;
                    d_h   = min(max(gamma*(1 - E'), -h), slack - h);
                    h     = h + d_h;
                    iter  = iter + 1;
                    stop  = (max(abs(d_h)) < max_diff);
            end
            
            J(end+1)    = sum(h)-0.5*h'*D*h; %Target function value. Useful for presentations
            
            %disp(d_h'*(1-E'-0.5*D*d_h))
            %disp(['Maximum difference: ' num2str(max(abs(d_h)))])
        end

        a_star = h'.*z;
        sv     = find(h > slack/Nf);
        bias   = 0;

    case 'Cascade'
        %Cascade SVM
        Nlevels = 4;

        is_sv       = ones(1, Nf);
        new_params  = strrep(params, 'Cascade', 'Lagrangian');

        for i = 1:Nlevels,
            new_is_sv   = zeros(1, Nf);
            for j = 1:2^(Nlevels-i),
                in_cur              = [max(1, floor((j-1)*Nf/(2^(Nlevels-i)+1))):min(Nf, floor(j*Nf/(2^(Nlevels-i))))];
                in_cur              = in_cur(find(is_sv(in_cur)));
                try
                    [temp, cur_alpha]   = SVM(train_patterns(:, in_cur), train_targets(in_cur), test_patterns(:, 1:2), new_params);
                    new_is_sv(in_cur)   = ((cur_alpha.*z(in_cur)' < slack) & (cur_alpha.*z(in_cur)' > 0));
                catch
                end
            end

            is_sv   = new_is_sv;
        end

        [temp, cur_a_star]  = SVM(train_patterns(:, find(is_sv)), train_targets(find(is_sv)), test_patterns(:, 1:2), new_params);

        a_star  = zeros(1, Nf);
        a_star(find(is_sv)) = cur_a_star;
        sv      = find(is_sv);
        bias    = 0;%mean(z(sv) - a_star(sv));
    otherwise
        error('Unknown solver. Can be either Quadprog or Perceptron')
end

%Find support verctors
Nsv	    = length(sv);
if isempty(sv),
    warning('No support vectors found. Using all training vectors.');
    sv  = 1:Nf;
    Nsv = Nf;
else
    disp(['Found ' num2str(Nsv) ' support vectors'])
end

%Margin
b	= 1/sqrt(sum(a_star.^2));
disp(['The margin is ' num2str(b)])

%Target function value
if size(a_star, 1) == 1,
    target_function_value   = sum(a_star) - 0.5*a_star*((z'*z).*y)*a_star';
else
    target_function_value   = sum(a_star) - 0.5*a_star'*((z'*z).*y)*a_star;
end

%Classify test patterns
N   = size(test_patterns, 2);
y   = a_star(sv)*compute_kernel_matrix(train_patterns(:, sv), test_patterns, kernel, ker_param);

test_targets = y + bias;

if (length(unique(train_targets)) == 2)
    test_targets = test_targets > 0;
end