load fft_coefs.log;
fil = complex(fft_coefs(:,1),fft_coefs(:,2));
figure(1);
plot(abs(fil));
