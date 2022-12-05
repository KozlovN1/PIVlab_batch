function PSI=reverse_y_stroke_1(i,jstart,jmax,PSIi0,PSIj0,X1,Y1,U1,V1)
PSIi=zeros(jmax,1);
PSIj=zeros(jmax,1);
PSI=zeros(jmax,1);
if jstart==2
    PSIj(jmax)=PSIj0;
end
for j=jstart:jmax
    if i==1
        if isnan(PSIi0)==false
            if length(PSIi0)==1
                PSIi0(2:jmax,1)=PSIi0;
            end
            PSIi(jmax-j+1)=PSIi0(jmax-j+1) -V1(jmax-j+1,i)*(X1(jmax-j+1,i+1)-X1(jmax-j+1,i));
            if j==1
                PSIj(jmax-j+1)=PSIj0 +U1(jmax-j+1,i)*(Y1(jmax-j+1-1,i)-Y1(jmax-j+1,i));
            else
                PSIj(jmax-j+1)=PSIj(jmax-j+1+1)+0.5*(U1(jmax-j+1,i)...
                    +U1(jmax-j+1+1,i))*(Y1(jmax-j+1,i)-Y1(jmax-j+1+1,i));
            end
            PSI(jmax-j+1)=0.5*(PSIi(jmax-j+1)+PSIj(jmax-j+1));
        else
            if j==1
                PSI(jmax-j+1)=PSIj0 +U1(jmax-j+1,i)*(Y1(jmax-j+1-1,i)-Y1(jmax-j+1,i));
            else
                PSI(jmax-j+1)=PSI(jmax-j+1+1)...
                    +0.5*(U1(jmax-j+1,i)+U1(jmax-j+1+1,i))*(Y1(jmax-j+1,i)-Y1(jmax-j+1+1,i));
            end
        end
    else
        PSIi(jmax-j+1)=PSIi0(jmax-j+1)...
                    -0.5*(V1(jmax-j+1,i)+V1(jmax-j+1,i-1))*(X1(jmax-j+1,i)-X1(jmax-j+1,i-1));
        if j==1
            PSIj(jmax-j+1)=PSIj0 +U1(jmax-j+1,i)*(Y1(jmax-j+1-1,i)-Y1(jmax-j+1,i));
        else
            PSIj(jmax-j+1)=PSIj(jmax-j+1+1)...
                +0.5*(U1(jmax-j+1,i)+U1(jmax-j+1+1,i))*(Y1(jmax-j+1,i)-Y1(jmax-j+1+1,i));
        end
        PSI(jmax-j+1)=0.5*(PSIi(jmax-j+1)+PSIj(jmax-j+1));
    end
end