%% Compute stream function out of PIV-derived velocity vector fields; by NK
% This procedure does the job for the scan-right-to-left-first case
% Version 1.0
% 2022-10-12
% Nikolai Kozlov

if scanpasses == 1
    n_strokes = 2;
elseif scanpasses == 2
    n_strokes = 4;
end

PSI=cell(amount/2-N2+1,1);
PSImax=zeros(amount/2-N2+1,1);
PSImin=zeros(amount/2-N2+1,1);
PSIabsmax=zeros(amount/2-N2+1,1);
for psi_count=1:size(u_filtmean,1)
    PSI{psi_count}=zeros(size(u_filtmean{psi_count}));
    X1=x_scaled{psi_count};
    Y1=y_scaled{psi_count};
    U1=u_scaled{psi_count};
    V1=v_scaled{psi_count};
    imax=size(u_filtmean{psi_count},2);
    jmax=size(u_filtmean{psi_count},1);
    %% Reverse x-stroke
    PSI21=zeros(size(u_filtmean{psi_count}));
    PSI22=zeros(size(u_filtmean{psi_count}));
    if isnan(bottomBC)
        PSI21(:,imax) = straight_y_stroke_2(1,imax,1,jmax,rightBC,topBC,X1,Y1,U1,V1);
        PSI22(:,imax) = reverse_y_stroke_2(1,imax,2,jmax,rightBC,PSI21(end,imax),X1,Y1,U1,V1);
        for i=2:imax
            %%% Straight y-stroke
            PSI21(:,imax-i+1) = straight_y_stroke_2(i,imax,1,jmax,PSI21(:,imax-i+1+1),...
                topBC,X1,Y1,U1,V1);
            %%% Reverse y-stroke
            PSI22(:,imax-i+1) = reverse_y_stroke_2(i,imax,2,jmax,PSI22(:,imax-i+1+1),...
                PSI21(end,imax-i+1),X1,Y1,U1,V1);
        end
    elseif isnan(topBC)
        PSI22(:,imax) = reverse_y_stroke_2(1,imax,1,jmax,rightBC,bottomBC,X1,Y1,U1,V1);
        PSI21(:,imax) = straight_y_stroke_2(1,imax,2,jmax,rightBC,PSI22(1,imax),X1,Y1,U1,V1);
        for i=2:imax
            PSI22(:,imax-i+1) = reverse_y_stroke_2(i,imax,1,jmax,PSI22(:,imax-i+1+1),...
                bottomBC,X1,Y1,U1,V1);
            PSI21(:,imax-i+1) = straight_y_stroke_2(i,imax,2,jmax,PSI21(:,imax-i+1+1),...
                PSI22(1,imax-i+1),X1,Y1,U1,V1);
        end
    else
        PSI21(:,imax) = straight_y_stroke_2(1,imax,1,jmax,rightBC,topBC,X1,Y1,U1,V1);
        PSI22(:,imax) = reverse_y_stroke_2(1,imax,1,jmax,rightBC,bottomBC,X1,Y1,U1,V1);
        for i=2:imax
            %%% Straight y-stroke
            PSI21(:,imax-i+1) = straight_y_stroke_2(i,imax,1,jmax,PSI21(:,imax-i+1+1),...
                topBC,X1,Y1,U1,V1);
            %%% Reverse y-stroke
            PSI22(:,imax-i+1) = reverse_y_stroke_2(i,imax,1,jmax,PSI22(:,imax-i+1+1),...
                bottomBC,X1,Y1,U1,V1);
        end
    end
    %% Straight x-stroke
    if scanpasses==2
        PSI11=zeros(size(u_filtmean{psi_count}));
        PSI12=zeros(size(u_filtmean{psi_count}));
        PSI11(:,1)=PSI21(:,1);
        PSI12(:,1)=PSI22(:,1);
        if isnan(bottomBC)
            for i=2:imax
                PSI11(:,i) = straight_y_stroke_1(i,1,jmax,PSI11(:,i-1),topBC,X1,Y1,U1,V1);
                PSI12(:,i) = reverse_y_stroke_1(i,2,jmax,PSI12(:,i-1),PSI11(end,i),X1,Y1,U1,V1);
            end
        elseif isnan(topBC)
            for i=2:imax
                PSI12(:,i) = reverse_y_stroke_1(i,1,jmax,PSI12(:,i-1),bottomBC,X1,Y1,U1,V1);
                PSI11(:,i) = straight_y_stroke_1(i,2,jmax,PSI11(:,i-1),PSI12(1,1),X1,Y1,U1,V1);
            end
        else
            for i=2:imax
                PSI11(:,i) = straight_y_stroke_1(i,1,jmax,PSI11(:,i-1),topBC,X1,Y1,U1,V1);
                PSI12(:,i) = reverse_y_stroke_1(i,1,jmax,PSI12(:,i-1),bottomBC,X1,Y1,U1,V1);
            end
        end
    end
    %% Averaging of two x-strokes
    if n_strokes == 2
        PSI{psi_count}=(PSI11+PSI12)/n_strokes;
    end
    if n_strokes == 4
        PSI{psi_count}=(PSI11+PSI12+PSI21+PSI22)/n_strokes;
    end
    PSImin(psi_count)=min(min(PSI{psi_count},[],1));
    PSImax(psi_count)=max(max(PSI{psi_count},[],1));
    PSIabsmax(psi_count)=max(max(abs(PSI{psi_count}),[],1));

    %% Count progress percentage
    clc
    disp(['Calculating PSI: ' int2str((psi_count+1)/size(u_filtmean,1)*100) ' %']);
end

clearvars psi_count PSI1 PSI2 PSI11 PSI12 PSI21 PSI22 X1 Y1 U1 V1