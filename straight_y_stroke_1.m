function PSI=straight_y_stroke_1(i,jstart,jmax,PSIi0,PSIj0,X1,Y1,U1,V1)
PSIi=zeros(jmax,1);
PSIj=zeros(jmax,1);
PSI=zeros(jmax,1);
if jstart==2
    PSIj(1)=PSIj0;
end
for j=jstart:jmax
    if i==1
        if isnan(PSIi0)==false
            if length(PSIi0)==1
                PSIi0(2:jmax,1)=PSIi0;
            end
            PSIi(j)=PSIi0(j) -V1(j,i)*(X1(j,i+1)-X1(j,i));
            if j==1
                if isnan(PSIj0)==false
                    PSIj(j)=PSIj0 +U1(j,i)*(Y1(j+1,i)-Y1(j,i));
                end
            else
                PSIj(j)=PSIj(j-1) + 0.5*(U1(j,i)+U1(j-1,i))*(Y1(j,i)-Y1(j-1,i));
            end
            if exist('PSIj(j)','var')==1
                PSI(j)=0.5*(PSIi(j)+PSIj(j));
            else
                PSI(j)=PSIi(j);
            end
        else
            if j==1
                PSI(j) = PSIj0 +U1(j,i)*(Y1(j+1,i)-Y1(j,i));
            else
                PSI(j) = PSI(j-1) + 0.5*(U1(j,i)+U1(j-1,i))*(Y1(j,i)-Y1(j-1,i));
            end
        end
    else
        PSIi(j) = PSIi0(j) -0.5*(V1(j,i)+V1(j,i-1))*(X1(j,i)-X1(j,i-1));
        if j==1
            if isnan(PSIj0)==false
                PSIj(j) = PSIj0 +U1(j,i)*(Y1(j+1,i)-Y1(j,i));
            end
        else
            PSIj(j) = PSIj(j-1) +0.5*(U1(j,i)+U1(j-1,i))*(Y1(j,i)-Y1(j-1,i));
        end
        if exist('PSIj(j)','var')==1
            PSI(j)=0.5*(PSIi(j)+PSIj(j));
        else
            PSI(j)=PSIi(j);
        end
    end
end