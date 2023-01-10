%% Config file for PIVlab_batch
% v 1.6. 2022-12-26
% Do not modify the version number below
PIVconf_ver = '1.6';

%% Main batch parameters; by N. Kozlov
f_f = 10; % frame rate (fps)
dt1 = 0.100; % time step within a pair (seconds)
dt2 = 1; % quasi-steady time interval (seconds)
N2=dt2*f_f;
% dt3=10; % TODO: "skip" interval = between the beginnings
% N3=dt3*f_f;
scalefact = 50/810; % scale factor for length (mm/pix)
scaleuv=scalefact/dt1; % scale factor for velocity (mm/(pix*s))
dt4 = 100; % time interval for averaging, in seconds
N4=dt4*f_f;
border = [206 206+1440 173 173+810]; % used to export the images: [x x+width y y+height]; normally, it coincides with the cell boundaries; if unsure refer to the region of interest (roi_init)
border=border*scalefact;
roi_init = [207,172,764,812]; % [x,y,width,height]
dynamicroi = false;
% if dynamicroi==true see at the end of file
intens_min = 0.;
intens_max = 1.;
usetimestep = false;
if usetimestep==true
    timestepfile = '';
end

%% Misc. parameters; by N. Kozlov
showfields = true;
computestreamfnc = false;
if computestreamfnc==true
    scanpasses = 2;
    leftBC = 0;
    bottomBC = 0;
    rightBC = 0;
    topBC = 0;
end
exec_control = false;

%% Standard PIV Settings; by W. Thielicke, modified by N. Kozlov
s = cell(12,2); % To make it more readable, let's create a "settings table"
%Parameter                          %Setting           %Options
s{1,1}= 'Int. area 1';              s{1,2}=64;         % window size of first pass
s{2,1}= 'Step size 1';              s{2,2}=32;         % step of first pass50
s{3,1}= 'Subpix. finder';           s{3,2}=1;          % 1 = 3point Gauss, 2 = 2D Gauss
s{4,1}= 'Mask';                     s{4,2}=[];         % If needed, generate via: imagesc(image); [temp,Mask{1,1},Mask{1,2}]=roipoly;
                        %!!!!DON'T MODIFY s{5,2}, see roi_init instead!!!!
s{5,1}= 'ROI';                      s{5,2}=roi_init;         % Region of interest: [x,y,width,height] in pixels, may be left empty
                        %_%
s{6,1}= 'Nr. of passes';            s{6,2}=4;          % 1-4 nr. of passes
s{7,1}= 'Int. area 2';              s{7,2}=32;         % second pass window size
s{8,1}= 'Int. area 3';              s{8,2}=24;         % third pass window size
s{9,1}= 'Int. area 4';              s{9,2}=20;         % fourth pass window size
s{10,1}='Window deformation';       s{10,2}='*spline'; % '*spline' is more accurate, but slower
s{11,1}='Repeated Correlation';     s{11,2}=1;         % 0 or 1 : Repeat the correlation four times and multiply the correlation matrices.
s{12,1}='Disable Autocorrelation';  s{12,2}=0;         % 0 or 1 : Disable Autocorrelation in the first pass. 

%% Standard image preprocessing settings; by W. Thielicke, modified by N. Kozlov
p = cell(10,2);
%Parameter                       %Setting           %Options
p{1,1}= 'ROI';                   p{1,2}=s{5,2};     % same as in PIV settings
p{2,1}= 'CLAHE';                 p{2,2}=1;          % 1 = enable CLAHE (contrast enhancement), 0 = disable
p{3,1}= 'CLAHE size';            p{3,2}=20;         % CLAHE window size
p{4,1}= 'Highpass';              p{4,2}=0;          % 1 = enable highpass, 0 = disable
p{5,1}= 'Highpass size';         p{5,2}=15;         % highpass size
p{6,1}= 'Clipping';              p{6,2}=0;          % 1 = enable clipping, 0 = disable
p{7,1}= 'Wiener';                p{7,2}=0;          % 1 = enable Wiener2 adaptive denaoise filter, 0 = disable
p{8,1}= 'Wiener size';           p{8,2}=3;          % Wiener2 window size
                        %!!!!DON'T MODIFY BELOW!!!!
p{9,1}= 'Minimum intensity';     p{9,2}=intens_min;          % Minimum intensity of input image (0 = no change) 
p{10,1}='Maximum intensity';     p{10,2}=intens_max;         % Maximum intensity on input image (1 = no change)
                        %_%

%% PIV postprocessing settings; by W. Thielicke, moved by N. Kozlov
umin = -10; % minimum allowed u velocity, adjust to your data
umax = 10; % maximum allowed u velocity, adjust to your data
vmin = -10; % minimum allowed v velocity, adjust to your data
vmax = 10; % maximum allowed v velocity, adjust to your data
stdthresh=6; % threshold for standard deviation check
epsilon=0.15; % epsilon for normalized median test
thresh=3; % threshold for normalized median test

%% related to dynamic ROI; by NK
if dynamicroi==true
    % Write below the initial parameters appropritate to your ROI
    % transformation with time.
%     e.g.
%     roi_C1 = 1.58;
%     roi_pow = 0.637;
%     roiboundary=0; 
%     roiwidth=0;
%     roiwidth_0=s{5,2}(3);
end
