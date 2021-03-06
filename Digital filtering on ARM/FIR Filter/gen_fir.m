%    Script generating coefficients for a FIR filter
% ------------------------------------------------------
% Author: Jaroslav Ban      Supervisor: Milos Drutarovsky
% 
% Department of Electronics and Multimedia Communications
%             Technical University of Kosice
%
% Last revision: May 16 2006


% Design and implement Finite Infinite Impulse Response (FIR)
% and Infinite Impulse Response (IIR) high-pass digital filters
% with the following parameters (requirements):
% 1) pass-band edge frequency 5 kHz
% 2) stop-band frequency 4 kHz
% 3) sampling frequency is 48 kHz
% 4) maximal allowed passband ripple is 0.1 dB
% 5) stop-band attenuation must be at least 70 dB
% 6) use minimal number of filter coefficients and optimize it for 
%    16-bit fixed point DSP implementations by using proper scaling
%    and pole-zero pairing.
% Design complete filter in Matlab environment. For hardware testing
% use IIR implementation based on cascade of second-order sections.

pbr = 10^(0.1/20)-1;
sba = 10^(-75/20);
[n,fo,mo,we] = remezord([4000 5000], [0 1], [sba pbr], 48000);
[b,err,res] = remez(n,fo,mo,we);

[h1,H1,H2,Hinf] = filnorm(b,1);  % h1 scaling
y_max = 1;                  
x_max = 1;
c = y_max / (x_max * h1);

b = c * b;
b_1_15 = round(b * 2^15);        % scale coefficients to 1.15 format

c = round((1/c) * 2^15);
fid = fopen('c_coef.txt','wt');
fprintf(fid,'%d\n',c);       
status = fclose(fid);

fid = fopen('c_1_15.txt','wt');
n = length(b_1_15);
for i = 1:(n-1)
    fprintf(fid,'%d,',b_1_15(n+1-i)); % program requires coefs in reverse order
end
fprintf(fid,'%d\n',b_1_15(1));
status = fclose(fid);

b = b_1_15 / 2^15;
[h,w] = freqz(b,1,24000);
w = 24 * w / pi;

figure(1);
plot(w, 20 * log10(abs(h)));
title('FIR filter magnitude response (after 16-bit scaling)');
xlabel('f[kHz]');
ylabel('Gain[dB]');

figure(2);
plot(24 * res.fgrid / pi, res.error);
title('Difference between the original and scaled FIR filter magnitude response');
xlabel('f[kHz]');
ylabel('Gain[dB]');

figure(3);
plot(w(1:4000), 20 * log10(abs(h(1:4000))));
title('Magnitude response in the stop-band');
xlabel('f[kHz]');
ylabel('Gain[dB]');
