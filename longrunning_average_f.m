function [Vmax_av, Vmean_av, t_av]=longrunning_average_f(N4, Vmax_sc, Vmean_sc, time_s)

%% averaging the characteristics, Vmax & Vmean, over a defined time interval; by NK
% v. 1.0.1
% 2022-12-27

C1=0; C2=0;
Vmax_av=zeros(size(Vmax_sc,1)-N4+1,1);
Vmean_av=zeros(size(Vmax_sc,1)-N4+1,1);
t_av=zeros(size(Vmax_sc,1)-N4+1,1);

if N4 < size(Vmax_sc,1)
    for LongRunAv=1:size(Vmax_sc,1)
        C1=C1+1; %%counter to average by groups of $N4 pairs
        Vmax_av(C2+1)=Vmax_av(C2+1)+Vmax_sc(LongRunAv);
        Vmean_av(C2+1)=Vmean_av(C2+1)+Vmean_sc(LongRunAv);
        t_av(C2+1)=t_av(C2+1)+time_s(LongRunAv);
        if C1 == N4
            if C2+2 <= size(Vmax_sc,1)-N4+1
                Vmax_av(C2+2)=Vmax_av(C2+1)-Vmax_sc(LongRunAv-N4+1);
                Vmean_av(C2+2)=Vmean_av(C2+1)-Vmean_sc(LongRunAv-N4+1);
                t_av(C2+2)=t_av(C2+1)-time_s(LongRunAv-N4+1);
            end
            Vmax_av(C2+1)=Vmax_av(C2+1)/N4;
            Vmean_av(C2+1)=Vmean_av(C2+1)/N4;
            t_av(C2+1)=t_av(C2+1)/N4;
            C1=C1-1;
            C2=C2+1;
        end
    end

%     clearvars C1 C2 LongRunAv
else
    msgbox('N4 is too large', 'Config error','error');
%     disp('N4 is too large');
end
end