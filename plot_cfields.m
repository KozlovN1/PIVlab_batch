%% Plot vector field over velocity magnitude color map from the averaged set; by NK
% Version 1.0
% 2022-10-02
% Nikolai Kozlov

%Check and select the directory for export%
if exist('exportdir','var')==1 && ischar(exportdir)
    exportdir=uigetdir(exportdir,'Where to save the figures files?');
elseif exist('configdir','var')==1 && ischar(configdir)
    exportdir=uigetdir(configdir,'Where to save the figures files?');
else
    exportdir=uigetdir([],'Where to save the figures files?');
end
%_%

%% Check the config file
if isfile(strcat(configdir,filesep,'cfields.conf') )
    conffile = fopen(strcat(configdir,filesep,'cfields.conf') );
    fgets(conffile);
    exportpng = parse_boolean_conf(conffile);
    exporteps = parse_boolean_conf(conffile);
    dispfig = parse_boolean_conf(conffile);
    dropvectx = fgetl(conffile);
    dropvecty = fgetl(conffile);
    whereistop = fgetl(conffile); % possible values: 'top', 'right', 'bottom', 'left'
    fclose(conffile);
else
    exportpng = 'false';
    exporteps = 'false';
    dispfig = 'true';
    dropvectx = '1';
    dropvecty = '1';
    whereistop = 'top'; 
end
%_Show the configs_%
prompt = {'exportpng = ','exporteps = ','dispfig = ',"Each n's x-vector: 1,2... ",...
    "Each n's y-vector: 1,2... ", 'Where is top: top, right, bottom, left?'};
dlgtitle = 'Configuration wizard';
dims = [1 50];
definput = {exportpng, exporteps, dispfig, dropvectx, dropvecty, whereistop};
answer = inputdlg(prompt,dlgtitle,dims,definput);
if answer{1} == "true"
    exportpng = true;
else
    exportpng = false;
end
if answer{2} == "true"
    exporteps = true;
else
    exporteps = false;
end
if answer{3} == "true"
    dispfig = true;
else
    dispfig = false;
end
dropvectx = str2double(answer{4});
dropvecty = str2double(answer{5});
whereistop = answer{6};
%_%

%% Main
disp(strcat('Data ranges from 1 to _', num2str(length(time_s))));
prompt = 'What elements (numbers) would you like to evaluate?';
timestep=input(prompt);

scrsz = get(0,'ScreenSize');

fig = figure('Name','Coloured vector plot');
if dispfig==false; set(fig,'Visible','off'); end

for i=1:1:length(timestep)
% the figure below presents length (x,y) in mm
% figure('Name',strcat(filenames{2*(timestep(i)+round(N2/2)-1)-1},', time: _',num2str(time_s(timestep(i))),' s')); 
%imagesc(double(image1));colormap('gray');
    switch whereistop
        case 'top'
            [C,h] = contourf(x_scaled{timestep(i)},-y_scaled{timestep(i)},vabsmean{timestep(i),1},256);
            caxis([0 round(max(Vmax_sc(timestep))*20)/20]);
            set(h,'LineColor','none');
            shading flat; colormap(jet);
            hold on;
            quiver(x_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
            -y_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
            u_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
            -v_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
            'k','AutoScaleFactor',1.5,'LineWidth',0.55);
        case 'right'
            % I switched x--y and u--v, and turned off 'axis ij;'. Now the coloured
            % plots are seen in natural orientation, like if they have been rotated 90
            % degrees ccw. 
            [C,h] = contourf(y_scaled{timestep(i)},x_scaled{timestep(i)},vabsmean{timestep(i),1},256);
            caxis([0 round(max(Vmax_sc(timestep))*20)/20]);
            set(h,'LineColor','none');
            shading flat; colormap(jet);
            hold on;
            quiver(y_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
            x_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
            v_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
            u_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
            'k','AutoScaleFactor',1.5,'LineWidth',0.55);
        case 'bottom' % TO CHECK !!!
            [C,h] = contourf(-x_scaled{timestep(i)},y_scaled{timestep(i)},vabsmean{timestep(i),1},256);
            caxis([0 round(max(Vmax_sc(timestep))*20)/20]);
            set(h,'LineColor','none');
            shading flat; colormap(jet);
            hold on;
            quiver(-x_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
            y_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
            -u_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
            v_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
            'k','AutoScaleFactor',1.5,'LineWidth',0.55);
        case 'left'
            [C,h] = contourf(-y_scaled{timestep(i)},-x_scaled{timestep(i)},vabsmean{timestep(i),1},256);
            caxis([0 round(max(Vmax_sc(timestep))*20)/20]);
            set(h,'LineColor','none');
            shading flat; colormap(jet);
            hold on;
            quiver(-y_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
            -x_scaled{timestep(i)}(1:dropvecty:end,1:dropvectx:end),...
            -v_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
            -u_scaled{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
            'k','AutoScaleFactor',1.5,'LineWidth',0.55);
    end
    hold off;
    axis image; 
%     axis(border); 
%     axis off; 
%     axis ij;
    set(gca,'xtick',[],'ytick',[]);
    %title(filenames{2*(timestep+round(N2/2)-1)-1},'interpreter','none');

    %%% Show a colorbar for velocity magnitude.
    if i==length(timestep)
        CB=colorbar('eastoutside','Limits',[0 round(max(Vmax_sc(timestep))*20)/20]);
        set(CB,'FontSize',8,'XTick',0:1:round(max(Vmax_sc(timestep))));
                % round(max(Vmax)*20)/20 rounds with precision 0.05, 
                % round(max(Vmax)*2)/2 -- 0.5, round(max(Vmax)*4)/4 -- 0.25
        LCB=ylabel(CB,'Velocity magnitude, mm/s'); set(LCB,'FontSize',10);
    end
    drawnow;

    %%% Export the figure to a file
    if exportpng==true; print(strcat(exportdir,filesep,'vfield',num2str(timestep(i)),'_сvp'),'-dpng','-r300'); end
    if exporteps==true; print(strcat(exportdir,filesep,'vfield',num2str(timestep(i)),'_сvp'),'-depsc','-painters'); end
    
    %%% Count progress percentage
    clc
    disp(['Saving figures: ' int2str((i)/length(timestep)*100) ' %']);
end

%% Save the parameters last used
if exist('configdir','var') == 0
    configdir = uigetdir([],'Where to save the configuration file?');
end
conffile = fopen(strcat(configdir,filesep,'cfields.conf'), 'w');
fprintf(conffile, '%s ', 'The parameters registered on');
fprintf(conffile, '%s\n', string(datetime) );
fprintf(conffile, '%i\n%i\n%i\n%i\n%i\n%s\n', exportpng, exporteps, dispfig,...
    dropvectx, dropvecty, whereistop);
fclose(conffile);

clearvars timestep image1 prompt C h CB LCB
