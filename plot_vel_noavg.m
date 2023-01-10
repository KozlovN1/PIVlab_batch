% Below: automatically clean what was filmed with wrong timestep
for i=1:1:size(Vmax1,1)
    if badpairs(i) ~= 0
        if i == 1
            for j=2:1:size(Vmax1,1)
                if badpairs(j) == 0
                    Vmax1(i)=Vmax1(j); Vmean1(i)=Vmean1(j);
                end
            end
        else
            Vmax1(i)=Vmax1(i-1); Vmean1(i)=Vmean1(i-1);
        end
    end
end
figure('Position',[0 0 0.33*scrsz(3) 0.5*scrsz(4)]); 
subplot(2,1,1);
plot(Vmax1); hold on;
ylabel('{\it V}_{max}, pix/frame','fontsize',16, 'rotation',90);% Maximum velocity
title('V_{max} before the averaging'); hold off;
subplot(2,1,2);
plot(Vmean1); hold on;
ylabel('{\it V}_{mean}, pix/frame','fontsize',16, 'rotation',90);% Maximum velocity
title('V_{mean} before the averaging'); hold off;