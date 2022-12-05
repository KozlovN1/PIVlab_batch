%% Compute stream function out of PIV-derived velocity vector fields; by NK
% Version 1.0
% 2022-10-12
% Nikolai Kozlov

% This is the launcher, while the calculations are done in one of two
% procedures: streamfunc_opt1 or streamfunc_opt2. It has to be run within
% the namespace of PIVlab_batch*.m.

%Parameters: check PIVlab_conf_1_3_*.m
scanpasses = 2; % Normally it should be 2, but you can set 1 for debugging.
%_%

if isnan(leftBC) && isnan(bottomBC) && isnan(rightBC) && isnan(topBC)
    msgbox('Impossible to compute with the specified boundary conditions',...
        'Boundary conditions error','error');
elseif isnan(rightBC)==false && isnan(leftBC)
    % here we put the scanning "1) <-, 2) ->"
    streamfunc_opt2;
else
    % here we put the scanning "1) ->, 2) <-"
    streamfunc_opt1;
end