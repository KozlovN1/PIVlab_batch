figure('Position',[0.33*scrsz(3) 0 0.33*scrsz(3) 0.5*scrsz(4)]); 
subplot(2,1,1);
plot(Vmax); 
hold on;
ylabel('{\it V}_{max}, pix/frame','fontsize',16, 'rotation',90);% Maximum velocity
title('V_{max} after the averaging'); 
hold off;
subplot(2,1,2);
plot(Vmean); 
hold on;
ylabel('{\it V}_{mean}, pix/frame','fontsize',16, 'rotation',90);% Maximum velocity
title('V_{mean} after the averaging'); 
hold off;