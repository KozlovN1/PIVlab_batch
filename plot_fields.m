%% Plot vector field and velocity magnitude from the averaged set; by NK
% Version 1.0
% 2022-10-12
% Nikolai Kozlov

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
if isfile(strcat(configdir,filesep,'fields.conf') )
    conffile = fopen(strcat(configdir,filesep,'fields.conf') );
    fgets(conffile);
    exportpng = parse_boolean_conf(conffile);
    exporteps = parse_boolean_conf(conffile);
    dispfig = parse_boolean_conf(conffile);
    dropvectx = fgetl(conffile);
    dropvecty = fgetl(conffile);
    fclose(conffile);
else
    exportpng = 'false';
    exporteps = 'false';
    dispfig = 'true';
    dropvectx = '1';
    dropvecty = '1';
end
%_Show the configs_%
prompt = {'exportpng = ','exporteps = ','dispfig = ',"Each n's x-vector: 1,2... ",...
    "Each n's y-vector: 1,2... "};
dlgtitle = 'Configuration wizard';
dims = [1 50];
definput = {exportpng, exporteps, dispfig, dropvectx, dropvecty};
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
%_%

%% Main
disp(strcat('Data ranges from 1 to _', num2str(length(time_s))));
prompt = 'What element number would you like to evaluate?';
timestep=input(prompt);

scrsz = get(0,'ScreenSize');

fig = figure('Name','Vector plot');
if dispfig==false; set(fig,'Visible','off'); end
% set(fig,'Position',[0.1*scrsz(3) 0.1*scrsz(4) 0.5*scrsz(3) 0.75*scrsz(4)]);

for i=1:1:length(timestep)
    image1=imread(fullfile(directory, filenames{2*(timestep(i)+round(N2/2)-1)-1})); %% reread images
    image2=imadjust(image1);
    image3=adapthisteq(image2);
    imagesc(double(image3));colormap('gray');
    axis image;
    hold on;
    quiver(x{timestep(i)+round(N2/2)-1,1}(1:dropvecty:end,1:dropvectx:end),...
        y{timestep(i)+round(N2/2)-1,1}(1:dropvecty:end,1:dropvectx:end),...
        u_filtmean{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
        v_filtmean{timestep(i),1}(1:dropvecty:end,1:dropvectx:end),...
        'g','AutoScaleFactor',2.5);
    hold off;
    %title(filenames{1},'interpreter','none');
    title(strcat(filenames{2*(timestep(i)+round(N2/2)-1)-1},'_ Elapsed time: _',num2str(time_s(timestep(i))),' s'),'interpreter','none');
    set(gca,'xtick',[],'ytick',[]);
    drawnow;

    %%% Export the figure to a file
    if exportpng==true; print(strcat(exportdir,filesep,'vfield',num2str(timestep(i)),'_vp'),'-dpng','-r300'); end
    if exporteps==true; print(strcat(exportdir,filesep,'vfield',num2str(timestep(i)),'_vp'),'-depsc','-painters'); end
    
    %%% Count progress percentage
    clc
    disp(['Saving figures: ' int2str((i)/length(timestep)*100) ' %']);
end

%% Save the parameters last used
if exist('configdir','var') == 0
    configdir = uigetdir([],'Where to save the configuration file?');
end
conffile = fopen(strcat(configdir,filesep,'fields.conf'), 'w');
fprintf(conffile, '%s ', 'The parameters registered on');
fprintf(conffile, '%s\n', string(datetime) );
fprintf(conffile, '%i\n%i\n%i\n%i\n%i\n', exportpng, exporteps, dispfig,...
    dropvectx, dropvecty);
fclose(conffile);

clearvars timestep image1 prompt C h CB LCB