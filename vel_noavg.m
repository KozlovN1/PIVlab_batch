vabs{PIVresult,1}=sqrt(u_filt{PIVresult,1}.^2+v_filt{PIVresult,1}.^2);
Vmax1(PIVresult)=max(max(vabs{PIVresult,1},[],1));
Vmean1(PIVresult)=mean(mean(vabs{PIVresult,1},1));