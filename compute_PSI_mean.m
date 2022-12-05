PSI_mean=zeros(size(PSI,1),1);
for C1=1:1:size(PSI,1)
    PSI_mean(C1,1)=mean(mean(PSI{C1},1));
end
figure('Position',[0.66*scrsz(3) 0.5*scrsz(4) 0.33*scrsz(3) 0.5*scrsz(4)]);
plot(time_s,PSI_mean');title('\Psi_{mean} (mm^2/s) vs time (s)');

filename = 'PSI_mean.csv';
if exist(strcat(directory,filesep,'..',filesep,'PSI_mean.csv'),'file') == 2
    i = 1;
    while isfile(strcat(directory,filesep,'..',filesep,'PSI_mean_(',num2str(i),').csv')) == 1
        i = i+1;
    end
    filename = strcat('PSI_mean_(',num2str(i),').csv');
end

fid3=fopen(strcat(directory,filesep,'..',filesep,filename),'w');
fprintf(fid3,'time, s; mean PSI, mm2/s\n');
for C2=1:1:length(time_s)
    fprintf(fid3,'%e; ',time_s(C2));
    fprintf(fid3,'%e\n',PSI_mean(C2));
end

clearvars C1 C2