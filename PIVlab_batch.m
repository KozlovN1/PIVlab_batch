% Batch processing with PIVlab (originally developed for the experiments on chemoconvection).
% Version 1.0.1, 2022-12-27.
% Nikolai Kozlov.

% W. Thielicke says: 
% - You can adjust the settings in "s" and "p", specify a mask and a region
% of interest.
% NB: for that refer to the config file PIVlab_conf*.

%% Init; by NK
prompt = strcat('Do you want to clean and restart over?');
dlgtitle = 'Restart over: y/n?';
definput = {'n'};
dims = [1 50];
answer = inputdlg(prompt,dlgtitle,dims,definput);
if answer{1,1} == 'y'
    clc; 
    clear all; 
    close all;
elseif answer{1,1} == 'n'
else
    disp('I did not understand the answer: y or n?');
end

%% Create list of images inside specified directory
if  exist('directory','var')==1 && ischar(directory)
    directory=uigetdir(directory,'Directory containing the images you want to analyze');
else
    directory=uigetdir([],'Directory containing the images you want to analyze'); %directory containing the images you want to analyze
end
prompt={'Please, provide the file extension: *.bmp or *.tif or *.jpg or *.tiff or *.jpeg'};
dlgtitle='File type';
dims=[1 50];
definput={'*.bmp'}; % *.bmp or *.tif or *.jpg or *.tiff or *.jpeg
suffix=inputdlg(prompt,dlgtitle,dims,definput);
suffix=suffix{1};
direc=dir([directory,filesep,suffix]); filenames={};
[filenames{1:length(direc),1}]=deal(direc.name);
filenames=sortrows(filenames); %sort all image files
amount=length(filenames);

%% Import configs; by NK
workdir = pwd;
if  exist('configdir','var')==1 && ischar(configdir)
    cd(configdir);
    if  exist('configfile','var')==1 && ischar(configfile)
        prompt = strcat('Use the current config file:',configdir,configfile,'?');
        dlgtitle = 'Use this file: y/n?';
        definput = {'y'};
        dims = [1 50];
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        if answer{1,1} == 'n'
            [configfile,configdir]=uigetfile('*.m','Select the config file');
        end
    else
        [configfile,configdir]=uigetfile('*.m','Select the config file');
    end
    cd(workdir);
else
    cd(strcat(directory,filesep,'..'));
    [configfile,configdir]=uigetfile('*.m','Select the config file');
    cd(workdir);
end
run(strcat(configdir,configfile));

%% Check the config version
if strcmp(PIVconf_ver,'1.6') % "else" & "end" are in the very end
    %% Check the directory to export data; by NK
    if  exist('exportdir','var')==1 && ischar(exportdir)
        exportdir=uigetdir(exportdir,'Where to save the data files?');
    elseif exist('configdir','var')==1 && ischar(configdir)
        exportdir=uigetdir(configdir,'Where to save the data files?');
    else
        exportdir=uigetdir([],'Where to save the data files?');
    end
    %_%
    
    %% Get bad pairs log; by NK
                            %!!!!UPD 13/3/21 DON'T MODIFY BELOW: timestepfile is set in the parameters section!!!!
    if usetimestep==true
        filename1=strcat(configdir,filesep,timestepfile);
        T=readtable(filename1, 'Format', '%u%u%u%u%u%s');
        badpairs=T{:,{'badpair'}}; clearvars T; % after some struggle, this and the previous lines do the same on R2016aU7 as readmatrix on R2019b; this assures backward compatibility
    else
        badpairs=zeros([amount/2 1]); % if timestepfile is not specified, consider all pairs as good
    end

    %% Control the scale of variables; by NK
    uvscaled=false;
    xyscaled=false;
    vabsscaled=false;

    %% Standard PIV Settings (moved to configfile)
    
    %% Standard image preprocessing settings (moved to configfile)
    
    %% PIV analysis loop; by W. Thielicke
    if mod(amount,2) == 1 %Uneven number of images?
        disp('Image folder should contain an even number of images.')
        %remove last image from list
        amount=amount-1;
        filenames(size(filenames,1))=[];
    end
    disp(['Found ' num2str(amount) ' images (' num2str(amount/2) ' image pairs).'])
    x=cell(amount/2,1);
    y=x;
    u=x;
    v=x;
    typevector=x; %typevector will be 1 for regular vectors, 0 for masked areas
    counter=0;
    %% for visualization; by NK
    scrsz = get(0,'ScreenSize');
    if showfields==true
        cnt=0;
        figure('Position',[0 0.5*scrsz(4) 0.33*scrsz(3) 0.5*scrsz(4)]);
    end
    %%
    %% PIV analysis loop:
    for i=1:2:amount
        counter=counter+1;
        %% dynamic ROI; by NK
        if dynamicroi==true
            run(strcat(configdir,'adjustroi')); % v. 1.0.1
        end
        %%
        image1=imread(fullfile(directory, filenames{i})); % read images
        image2=imread(fullfile(directory, filenames{i+1}));
        image1 = PIVlab_preproc (image1,p{1,2},p{2,2},p{3,2},p{4,2},p{5,2},p{6,2},p{7,2},p{8,2},p{9,2},p{10,2}); %preprocess images
        image2 = PIVlab_preproc (image2,p{1,2},p{2,2},p{3,2},p{4,2},p{5,2},p{6,2},p{7,2},p{8,2},p{9,2},p{10,2});
        [x{counter}, y{counter}, u{counter}, v{counter}, typevector{counter}] = piv_FFTmulti (image1,image2,s{1,2},s{2,2},s{3,2},s{4,2},s{5,2},s{6,2},s{7,2},s{8,2},s{9,2},s{10,2},s{11,2},s{12,2});
        clc
        disp(['Processing: ' int2str((i+1)/amount*100) ' %']);

        % Graphical output (disable to improve speed)
        %%{
        if showfields == true
            cnt = cnt+1;
            if cnt == floor(0.1*amount)
                imagesc(double(image1)+double(image2));colormap('gray');
                hold on;
                quiver(x{counter},y{counter},u{counter},v{counter},'g',...
                    'AutoScaleFactor', 1.5);
                hold off;
                axis image;
                title(filenames{i},'interpreter','none')
                set(gca,'xtick',[],'ytick',[])
                drawnow;
                cnt=0;
            end
        end
        %%}
    end

    %% PIV postprocessing loop; by W. Thielicke
    % Settings (moved to the config file)

    u_filt=cell(amount/2,1);
    v_filt=u_filt;
    typevector_filt=u_filt;
    %% rel. averaging; by NK
    vabs=cell(amount/2,1); %% velocity magnitude
    C1=0; 
    C2=0; 
    C3=0;
    u_filtmean=cell((amount/2)-N2+1,1);
    v_filtmean=cell((amount/2)-N2+1,1);
    x_mean=cell((amount/2)-N2+1,1);
    y_mean=cell((amount/2)-N2+1,1);
    vabsmean=cell((amount/2)-N2+1,1);
    Vmax=zeros((amount/2)-N2+1,1); 
    Vmean=zeros((amount/2)-N2+1,1);
    Vmax1=zeros((amount/2),1); 
    Vmean1=zeros((amount/2),1);
    %%
    for PIVresult=1:size(x,1)
        %%
        C1=C1+1; %%counter to average by small groups of $N2 pairs; by NK
        %%
        u_filtered=u{PIVresult,1};
        v_filtered=v{PIVresult,1};
        typevector_filtered=typevector{PIVresult,1};
        %vellimit check
        u_filtered(u_filtered<umin)=NaN;
        u_filtered(u_filtered>umax)=NaN;
        v_filtered(v_filtered<vmin)=NaN;
        v_filtered(v_filtered>vmax)=NaN;
        % stddev check
        meanu=nanmean(nanmean(u_filtered));
        meanv=nanmean(nanmean(v_filtered));
        std2u=nanstd(reshape(u_filtered,size(u_filtered,1)*size(u_filtered,2),1));
        std2v=nanstd(reshape(v_filtered,size(v_filtered,1)*size(v_filtered,2),1));
        minvalu=meanu-stdthresh*std2u;
        maxvalu=meanu+stdthresh*std2u;
        minvalv=meanv-stdthresh*std2v;
        maxvalv=meanv+stdthresh*std2v;
        u_filtered(u_filtered<minvalu)=NaN;
        u_filtered(u_filtered>maxvalu)=NaN;
        v_filtered(v_filtered<minvalv)=NaN;
        v_filtered(v_filtered>maxvalv)=NaN;
        % normalized median check
        %Westerweel & Scarano (2005): Universal Outlier detection for PIV data
        [J,I]=size(u_filtered);
        medianres=zeros(J,I);
        normfluct=zeros(J,I,2);
        b=1;
        for c=1:2
            if c==1; velcomp=u_filtered;else;velcomp=v_filtered;end %#ok<*NOSEM>
            for i=1+b:I-b
                for j=1+b:J-b
                    neigh=velcomp(j-b:j+b,i-b:i+b);
                    neighcol=neigh(:);
                    neighcol2=[neighcol(1:(2*b+1)*b+b);neighcol((2*b+1)*b+b+2:end)];
                    med=median(neighcol2);
                    fluct=velcomp(j,i)-med;
                    res=neighcol2-med;
                    medianres=median(abs(res));
                    normfluct(j,i,c)=abs(fluct/(medianres+epsilon));
                end
            end
        end
        info1=(sqrt(normfluct(:,:,1).^2+normfluct(:,:,2).^2)>thresh);
        u_filtered(info1==1)=NaN;
        v_filtered(info1==1)=NaN;

        typevector_filtered(isnan(u_filtered))=2;
        typevector_filtered(isnan(v_filtered))=2;
        typevector_filtered(typevector{PIVresult,1}==0)=0; %restores typevector for mask

        %Interpolate missing data
        u_filtered=inpaint_nans(u_filtered,4);
        v_filtered=inpaint_nans(v_filtered,4);

        u_filt{PIVresult,1}=u_filtered;
        v_filt{PIVresult,1}=v_filtered;
        typevector_filt{PIVresult,1}=typevector_filtered;

        %% Averaging loop; by NK
        % Check if enough pairs were processed and do averaging (evolution of velocity field)
        if C1 == N2
          %if (size(x,1)-PIVresult) >= (N2-1) %% TODO: check this condition!
            C1=C1-1; 
            C2=C2+1;
            u_filtmean{C2,1}=zeros(size(u_filt{PIVresult-N2+1,1}));% <--- 1beta10 -PIVresult +PIVresult-N2+1
            v_filtmean{C2,1}=zeros(size(v_filt{PIVresult-N2+1,1}));
            x_mean{C2,1}=zeros(size(x{PIVresult-N2+1,1}));
            y_mean{C2,1}=zeros(size(y{PIVresult-N2+1,1}));
            size2 = size(u_filt{PIVresult-N2+1,1},2);
            for i=(PIVresult-N2+1):1:PIVresult
                if badpairs(i) == 0
                    C3=C3+1;
                    for j=1:1:size(u_filt{PIVresult-N2+1,1},1)% <--- 1beta10 -i +PIVresult-N2+1
                        for k=1:1:size(u_filt{PIVresult-N2+1,1},2)
                            % Заполняем с конца, чтобы компенсировать разницу в
                            % размере по x между полями скорости.
                            u_filtmean{C2,1}(j,size2-k+1)=u_filtmean{C2,1}(j,size2-k+1)+...
                                u_filt{i,1}(j,size(u_filt{i,1},2)-k+1);
                            v_filtmean{C2,1}(j,size2-k+1)=v_filtmean{C2,1}(j,size2-k+1)+...
                                v_filt{i,1}(j,size(u_filt{i,1},2)-k+1); 
                        end
                    end
                end
                % Ниже создаём массивы с осреднёнными координатами, чтобы иметь
                % одинаковую размерность массивов с массивами скорости.
                for j=1:1:size(u_filt{PIVresult-N2+1,1},1)% <--- 1beta10 -i +PIVresult-N2+1
                        for k=1:1:size(u_filt{PIVresult-N2+1,1},2)% <--- 1beta10 -i +PIVresult-N2+1
                            x_mean{C2,1}(j,size2-k+1)=x_mean{C2,1}(j,size2-k+1)+...
                                x{i,1}(j,size(u_filt{i,1},2)-k+1);
                            y_mean{C2,1}(j,size2-k+1)=y_mean{C2,1}(j,size2-k+1)+...
                                y{i,1}(j,size(u_filt{i,1},2)-k+1);
                        end
                end
            end
            % 1beta9: ниже добавили координаты
            x_mean{C2,1}=x_mean{C2,1}/N2;
            y_mean{C2,1}=y_mean{C2,1}/N2;
            if C3 ~= 0
                u_filtmean{C2,1}=u_filtmean{C2,1}/C3;
                v_filtmean{C2,1}=v_filtmean{C2,1}/C3;
                vabsmean{C2,1}=sqrt(u_filtmean{C2,1}.^2+v_filtmean{C2,1}.^2);
                Vmax(C2)=max(max(vabsmean{C2,1},[],1));
                Vmean(C2)=mean(mean(vabsmean{C2,1},1));
            elseif C3 == 0
                u_filtmean{C2,1}=NaN;
                v_filtmean{C2,1}=NaN;
                vabsmean{C2,1}=NaN;
                Vmax(C2)=NaN;
                Vmean(C2)=NaN;
            end
            C3 = 0;
        end

        %%Calculate velocity magnitude without averaging (FOR DEBUGGING)
        if exec_control == true
            vel_noavg; % v. 1.0.1
        end

        %%Count progress percentage
        clc
        disp('Processing: 100 %');
        disp(['Postprocessing: ' int2str((PIVresult+1)/size(x,1)*100) ' %']);
    end

    %% plot the Vmax before averaging (FOR DEBUGGING); by NK
    if exec_control == true
        plot_vel_noavg; % v. 1.0.1
    end

    %% Now interpolate NaNs for the averaged values; by NK
    for i=1:1:size(Vmax,1)
        if isnan(Vmax(i))
            if i == 1
                % Scan until the first numeric value and use it %
                for j=2:1:size(Vmax,1)
                    if isnan(Vmax(j)) == false
                        Vmax(i)=Vmax(j); Vmean(i)=Vmean(j);
                    end
                end
                %_%
            elseif i == size(Vmax,1)
                Vmax(i)=Vmax(i-1); Vmean(i)=Vmean(i-1);
            else
                % TODO: use linear interpolation
                %Vmax(i)=0.5*(Vmax(i-1)+Vmax(i+1));
                Vmax(i)=Vmax(i-1); Vmean(i)=Vmean(i-1);
            end
        end
    end
    %BELOW: FOR DEBUGGING - plot
    if exec_control == true
        plot_vel_avg; % v. 1.0.1
    end

    %% Calculating physical values; by NK
    u_scaled=cell((amount/2)-N2+1,1);
    v_scaled=cell((amount/2)-N2+1,1);
    for i=1:1:size(Vmax,1)
        u_scaled{i,1}=u_filtmean{i,1}*scaleuv;
        v_scaled{i,1}=v_filtmean{i,1}*scaleuv;
        vabsmean{i,1}=sqrt(u_scaled{i,1}.^2+v_scaled{i,1}.^2);
    end
    Vmax_sc=Vmax*scaleuv; 
    Vmean_sc=Vmean*scaleuv;
    uvscaled=true;
    vabsscaled=true;

    x_scaled=cell((amount/2)-N2+1,1);
    y_scaled=cell((amount/2)-N2+1,1);
    for i=1:1:size(x_mean,1)
        x_scaled{i,1}=x_mean{i,1}*scalefact;
        y_scaled{i,1}=y_mean{i,1}*scalefact;
    end
    xyscaled=true;

    time_s=zeros(size(Vmax));
    time_s(1)=0.5*N2/f_f;
    for i=1:1:length(Vmax)-1
        time_s(i+1)=time_s(i)+1/f_f;
    end

    %% Calculate the averaged characteristics, Vmax & Vmean, over a defined time interval dt3; by NK
    [Vmax_av, Vmean_av, t_av]=longrunning_average_f(N4, Vmax_sc, Vmean_sc, time_s); % v. 1.0.1

    %% Calculate the streamfunction from the averaged velocity fields; by NK
    if computestreamfnc == true
        streamfunc;
        compute_PSI_mean;
    end

    %% Plot the main results; by NK
    figure('Position',[0.33*scrsz(3) 0.5*scrsz(4) 0.33*scrsz(3) 0.5*scrsz(4)]);
    subplot(2,1,1);
    plot(time_s,Vmax_sc); 
    hold on;
    plot(t_av,Vmax_av);
    xlabel('{\it t}, s','fontsize',16);% time
    ylabel('{\it V}_{max}, mm/s','fontsize',16, 'rotation',90);% Maximum velocity
    title('V_{max} versus time'); 
    hold off;
    subplot(2,1,2);
    plot(time_s,Vmean_sc); 
    hold on;
    plot(t_av,Vmean_av);
    xlabel('{\it t}, s','fontsize',16);% time
    ylabel('{\it V}_{mean}, mm/s','fontsize',16, 'rotation',90);% Maximum velocity
    title('V_{mean} versus time'); 
    hold off;

    %% Save Vmax Vmean; by NK
    if exist(strcat(exportdir,filesep,'Vmax_mean.csv'),'file') == 2
        i = 1;
        while isfile(strcat(exportdir,filesep,'Vmax_mean_(',num2str(i),').csv')) == 1
            i = i+1;
        end
        filename = strcat('Vmax_mean_(',num2str(i),').csv');
    else
        filename = 'Vmax_mean.csv';
    end
    fid2=fopen(strcat(exportdir,filesep,filename),'w');
    fprintf(fid2,'time, s; maximum velocity, mm/s; mean velocity, mm/s\n');
    for i=1:1:length(Vmax_sc)
        fprintf(fid2,'%e; ',time_s(i));
        fprintf(fid2,'%e; ',Vmax_sc(i));
        fprintf(fid2,'%e\n',Vmean_sc(i));
    end

    if exist(strcat(exportdir,filesep,'Vmax_mean_av.csv'),'file') == 2
        i = 1;
        while isfile(strcat(exportdir,filesep,'Vmax_mean_av_(',num2str(i),').csv')) == 1
            i = i+1;
        end
        filename = strcat('Vmax_mean_av_(',num2str(i),').csv');
    else
        filename = 'Vmax_mean_av.csv';
    end
    fid2=fopen(strcat(exportdir,filesep,filename),'w');
    fprintf(fid2,'t_av, s; v_max_av, mm/s; v_mean_av, mm/s\n');
    for i=1:1:length(t_av)
        fprintf(fid2,'%e; ',t_av(i));
        fprintf(fid2,'%e; ',Vmax_av(i));
        fprintf(fid2,'%e\n',Vmean_av(i));
    end
    %% Export velocity fields; by NK
    if  exist(strcat(exportdir,filesep,'vectorfields'),'dir')==0
        mkdir(strcat(exportdir,filesep,'vectorfields'));
    end
    for k=1:length(x_scaled)
        if isnan(u_scaled{k})
        else
            fid=fopen(strcat(exportdir,filesep,'vectorfields',...
                filesep,'velfield_',int2str(k),'_t_',int2str(round(time_s(k),0)),'s.csv'),'w');
            header=strcat('time = ',num2str(time_s(k)),' s\n');
            fprintf(fid,header);
            fprintf(fid,'X, mm; Y, mm; U, mm/s; V, mm/s\n');
            for i=1:size(x_scaled{k},1)
                for j=1:size(x_scaled{k},2)
                    fprintf(fid,'%e; ',x_scaled{k}(i,j));
                    fprintf(fid,'%e; ',y_scaled{k}(i,j));
                    fprintf(fid,'%e; ',u_scaled{k}(i,j));
                    fprintf(fid,'%e\n',v_scaled{k}(i,j));
                end
            end
            fclose(fid);
            clc
            disp('Processing: 100 %');
            disp('Postprocessing: 100 %');
            disp(['Saving velocity vector fields data: ' int2str((k)/length(x_scaled)*100) ' %']);
        end
    end
    disp('Data export finished.');
    %%

    clearvars -except p s x y u v typevector directory filenames u_filt v_filt typevector_filt ...
        vabs vabsmean u_filtmean v_filtmean Vmax Vmean time_s badpairs Vmax1 Vmean1 f_f dt1 dt2 dt4 ...
        N2 N3 N4 clalefact scaleuv t_av Vmax_av Vmean_av amount uvscaled xyscaled x_scaled y_scaled ...
        border x_mean y_mean scalefact scaleuv u_scaled v_scaled Vmax_sc Vmean_sc PSI PSImax PSImin ...
        PSIabsmax vabsscaled configfile configdir exportdir scrsz
    fclose('all');
    disp('DONE.')

else
    msgbox('Wrong version of the config file', 'Config error','error');
end % this is the end of "if PIVconf_ver == "1.*""