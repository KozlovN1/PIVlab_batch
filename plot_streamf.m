%% Plot streamfunction map from the averaged set; by NK
% Version 1.0
% 2022-10-12
% Nikolai Kozlov

if exist('PSI','var')==1

    %Проверка и выбор директории для экспорта%
    if  exist('exportdir','var')==1 && ischar(exportdir)
        exportdir=uigetdir(exportdir,'Where to save the figures files?');
    elseif exist('configdir','var')==1 && ischar(configdir)
        exportdir=uigetdir(configdir,'Where to save the figures files?');
    else
        exportdir=uigetdir([],'Where to save the figures files?');
    end
    %_%

    %% Check the config file
    if isfile(strcat(configdir,filesep,'streamf.conf') )
        conffile = fopen(strcat(configdir,filesep,'streamf.conf') );
        fgets(conffile);
        figtitle = fgetl(conffile);
        exportpng = parse_boolean_conf(conffile);
        exporteps = parse_boolean_conf(conffile);
        dispfig = parse_boolean_conf(conffile);
        vectors = parse_boolean_conf(conffile);
        dropvectx = fgetl(conffile);
        dropvecty = fgetl(conffile);
        scaleset = parse_boolean_conf(conffile);
        labels = parse_boolean_conf(conffile);
        noaxis = parse_boolean_conf(conffile);
        fillcont = parse_boolean_conf(conffile);
        graymap = parse_boolean_conf(conffile);
        whereistop = fgetl(conffile); % possible values: 'top', 'right', 'bottom', 'left'
        fclose(conffile);
    else
        figtitle = '';
        exportpng = 'false';
        exporteps = 'false';
        dispfig = 'true';
        vectors = 'false';
        dropvectx = '1';
        dropvecty = '1';
        scaleset = 'true';
        labels = 'false';
        noaxis = 'false';
        fillcont = 'false';
        graymap = 'false';
        whereistop = 'top';
    end
    %_Show the configs_%
    prompt = {'Title of your figure:','exportpng = ','exporteps = ',...
        'dispfig = ','vectors = ',"Each n's x-vector: 1,2... ",...
        "Each n's y-vector: 1,2... ",'scaleset = ','labels = ','noaxis = ',...
        'fillcont = ','graymap = ','Where is top: top, right, bottom, left?'};
    dlgtitle = 'Configuration wizard';
    dims = [1 50];
    definput = {figtitle, exportpng, exporteps, dispfig, vectors, dropvectx,...
        dropvecty, scaleset, labels, noaxis, fillcont, graymap, whereistop};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    figtitle = answer{1};
    if answer{2} == "true"
        exportpng = true;
    else
        exportpng = false;
    end
    if answer{3} == "true"
        exporteps = true;
    else
        exporteps = false;
    end
    if answer{4} == "true"
        dispfig = true;
    else
        dispfig = false;
    end
    if answer{5} == "true"
        vectors = true;
    else
        vectors = false;
    end
    dropvectx = str2double(answer{6});
    dropvecty = str2double(answer{7});
    if answer{8} == "true"
        scaleset = true;
    else
        scaleset = false;
    end
    if answer{9} == "true"
        labels = true;
    else
        labels = false;
    end
    if answer{10} == "true"
        noaxis = true;
    else
        noaxis = false;
    end
    if answer{11} == "true"
        fillcont = true;
    else
        fillcont = false;
    end
    if answer{12} == "true"
        graymap = true;
    else
        graymap = false;
    end
    whereistop = answer{13};
    %_%

    %% Main
    disp(strcat('Data ranges from 1 to _', num2str(length(time_s))));
    prompt = 'What elements (numbers) would you like to evaluate?';
    timestep=input(prompt);

    scrsz = get(0,'ScreenSize');

    fig=figure('Name','Streamfunction plot');
%     fig=figure('Name',strcat(filenames{2*(timestep+round(N2/2)-1)-1},', time: _',num2str(time_s(timestep)),' s'));
    if dispfig==false; set(fig,'Visible','off'); end
    % if bckgdnclr==true; set(fig,'Color','#CACACA'); end
    % set(fig,'Position',[0.1*scrsz(3) 0.1*scrsz(4) 0.5*scrsz(3) 0.75*scrsz(4)]);

    for i=1:1:length(timestep)
        switch whereistop
            case 'top'
                if fillcont == true
                    [C,h] = contourf(x_scaled{timestep(i),1},-y_scaled{timestep(i),1},PSI{timestep(i),1},16);
                else
                    [C,h] = contour(x_scaled{timestep(i),1},-y_scaled{timestep(i),1},PSI{timestep(i),1},16);
                end
                if scaleset == true
                    caxis([round(min(PSImin(timestep))*20)/20 round(max(PSImax(timestep))*20)/20]); % one scale for the entire set
                else
                    caxis([round(min(PSImin)*20)/20 round(max(PSImax)*20)/20]); % one scale for the whole series
                end
                if labels == true
                    clabel(C,h,'LabelSpacing',300);
                end
                shading flat; 
                axis image;
                if noaxis==true
                    axis off; 
                else
                    axis([border(1) border(2) -border(4) -border(3)]);
                end
                if graymap==true
                    colormap(gray);
                    set(h,'LineColor','black');
                end
                set(gca,'xtick',[],'ytick',[]);
                title(strcat(figtitle,', time = ',...
                    num2str(round(time_s(timestep(i)),1)),' s'),'FontSize',8);
                if vectors == true
                    hold on;
                    quiver(x_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
                        -y_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
                        u_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
                        -v_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
                        'k','AutoScaleFactor',1.5,'LineWidth',0.5);
                    hold off;
                end
            case 'right'
                %Comment%
                % The figure below presents length (x,y) in mm
                % I switched x--y and u--v, and turned off 'axis ij;'. Now the coloured
                % plots are seen in natural orientation, like if they have been rotated 90
                % degrees ccw. 
                if fillcont == true
                    [C,h] = contourf(y_scaled{timestep(i),1},x_scaled{timestep(i),1},PSI{timestep(i),1},16);
                else
                    [C,h] = contour(y_scaled{timestep(i),1},x_scaled{timestep(i),1},PSI{timestep(i),1},16);
                end
                if scaleset == true
                    caxis([round(min(PSImin(timestep))*20)/20 round(max(PSImax(timestep))*20)/20]); % one scale for the entire set
                else
                    caxis([round(min(PSImin)*20)/20 round(max(PSImax)*20)/20]); % one scale for the whole series
                end
                if labels == true
                    clabel(C,h,'LabelSpacing',300);
                end
                shading flat; 
                axis image;
                if noaxis==true
                    axis off; 
                else
                    axis([border(3) border(4) border(1) border(2)]);
                end
                if graymap==true
                    colormap(gray);
                    set(h,'LineColor','black');
                end
                set(gca,'xtick',[],'ytick',[]);
                title(strcat(figtitle,', time = ',...
                    num2str(round(time_s(timestep(i)),1)),' s'),'FontSize',8);
                if vectors == true
                    hold on;
                    quiver(y_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
                        x_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
                        v_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
                        u_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
                        'k','AutoScaleFactor',1.5,'LineWidth',0.5);
                    hold off;
                end
            case 'bottom'
                if fillcont == true
                    [C,h] = contourf(-x_scaled{timestep(i),1},y_scaled{timestep(i),1},PSI{timestep(i),1},16);
                else
                    [C,h] = contour(-x_scaled{timestep(i),1},y_scaled{timestep(i),1},PSI{timestep(i),1},16);
                end
                if scaleset == true
                    caxis([round(min(PSImin(timestep))*20)/20 round(max(PSImax(timestep))*20)/20]); % one scale for the entire set
                else
                    caxis([round(min(PSImin)*20)/20 round(max(PSImax)*20)/20]); % one scale for the whole series
                end
                if labels == true
                    clabel(C,h,'LabelSpacing',300);
                end
                shading flat; 
                axis image;
                if noaxis==true
                    axis off; 
                else
                    axis([-border(2) -border(1) border(3) border(4)]);
                end
                if graymap==true
                    colormap(gray);
                    set(h,'LineColor','black');
                end
                set(gca,'xtick',[],'ytick',[]);
                title(strcat(figtitle,', time = ',...
                    num2str(round(time_s(timestep(i)),1)),' s'),'FontSize',8);
                if vectors == true
                    hold on;
                    quiver(-x_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
                        y_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
                        -u_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
                        v_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
                        'k','AutoScaleFactor',1.5,'LineWidth',0.5);
                    hold off;
                end
            case 'left'
                if fillcont == true
                    [C,h] = contourf(-y_scaled{timestep(i),1},-x_scaled{timestep(i),1},PSI{timestep(i),1},16);
                else
                    [C,h] = contour(-y_scaled{timestep(i),1},-x_scaled{timestep(i),1},PSI{timestep(i),1},16);
                end
                if scaleset == true
                    caxis([round(min(PSImin(timestep))*20)/20 round(max(PSImax(timestep))*20)/20]); % one scale for the entire set
                else
                    caxis([round(min(PSImin)*20)/20 round(max(PSImax)*20)/20]); % one scale for the whole series
                end
                if labels == true
                    clabel(C,h,'LabelSpacing',300);
                end
                shading flat; 
                axis image;
                if noaxis==true
                    axis off; 
                else
                    axis([-border(4) -border(3) -border(2) -border(1)]);
                end
                if graymap==true
                    colormap(gray);
                    set(h,'LineColor','black');
                end
                set(gca,'xtick',[],'ytick',[]);
                title(strcat(figtitle,', time = ',...
                    num2str(round(time_s(timestep(i)),1)),' s'),'FontSize',8);
                if vectors == true
                    hold on;
                    quiver(-y_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
                        -x_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
                        -v_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
                        -u_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
                        'k','AutoScaleFactor',1.5,'LineWidth',0.5);
                    hold off;
                end
        end

        %%% Show a colorbar for streamfunction.
        if labels == false
            if i==length(timestep)
                CB=colorbar('eastoutside','Limits',[round(min(PSImin(timestep))*20)/20 round(max(PSImax(timestep))*20)/20]);
                    % one scale for the entire set
                set(CB,'FontSize',12,'XTick',round(min(PSImin(timestep))):2:round(max(PSImax(timestep))));
                LCB=ylabel(CB,'Streamfunction, mm^{2}/s'); set(LCB,'FontSize',13);
            end
            drawnow;
        end

        %%% Export the figure to a file
        if exportpng==true; print(strcat(exportdir,filesep,'PSIfield',...
                num2str(timestep(i)),'_sf'),'-dpng','-r300'); end
        if exporteps==true; print(strcat(directory,filesep,'..',filesep,'PSIfield',...
                num2str(timestep(i)),'_sf'),'-depsc','-painters'); end

        %%% Count progress percentage
            clc
            disp(['Saving figures: ' int2str((i)/length(timestep)*100) ' %']);
    end

    %% Save the parameters last used
    if exist('configdir','var') == 0
        configdir = uigetdir([],'Where to save the configuration file?');
    end
    conffile = fopen(strcat(configdir,filesep,'streamf.conf'), 'w');
    fprintf(conffile, '%s ', 'The parameters registered on');
    fprintf(conffile, '%s\n', string(datetime) );
    fprintf(conffile, '%s\n%i\n%i\n%i\n%i\n%i\n%i\n%i\n%i\n%i\n%i\n%i\n%s\n', ...
        figtitle, exportpng, exporteps, dispfig, vectors, dropvectx, dropvecty,...
        scaleset, labels, noaxis, fillcont, graymap, whereistop);
    fclose(conffile);

    clearvars timestep image1 prompt C h CB LCB S
else
    msgbox('No data on streamfunction is found', 'Data error','error');
end