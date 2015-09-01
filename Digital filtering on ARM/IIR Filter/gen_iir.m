%    Script generating coefficients for an IIR filter
% -------------------------------------------------------
% Author: Michal Varchola     Supervisor: Milos Drutarovsky
% 
% Department of Electronics and Multimedia Communications
%             Technical University of Kosice
%
% Last revision: May 15 2006


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
sbf = 4000/48000;
pbf = 5000/48000;
[b,a,v,u,C] = iirdes('ell','h',[sbf,pbf]*2*pi,pbr,sba);

[nsec,dsec] = pairpz(v,u);

n = size(nsec,1);

for k=1:n
    nt = nsec(1:k,:);
    dt = dsec(1:k,:);
    h1t = bfilnorm(nt,dt);
    if h1t > 1 
        nsec(k,:) = nsec(k,:) / h1t;
        C = C * h1t;
    end
    h1t = max(abs(nsec(k,:)));
    if h1t > 2
        nsec(k,:) = nsec(k,:) * 2 / h1t;
        C = C * h1t / 2;
    end
end

nsec = round(nsec * 2^14);   % scale coefficients to 2.14 format
dsec = round(dsec * 2^14);    
C = round(C * 2^15);

fid = fopen('c_2_14.txt','wt');
for i = 1:(n-1)
    fprintf(fid,'%d,%d,%d,%d,%d,',nsec(i,1),nsec(i,2),nsec(i,3),-dsec(i,2),-dsec(i,3));
end
fprintf(fid,'%d,%d,%d,%d,%d\n',nsec(n,1),nsec(n,2),nsec(n,3),-dsec(n,2),-dsec(n,3));
status = fclose(fid);

fid = fopen('c_coef.txt','wt');
fprintf(fid,'%d\n',C);
status = fclose(fid);

nsec = nsec / 2^14;
dsec = dsec / 2^14;
C = C / 2^15;

points = 4800;
h = frqcasc(nsec, dsec, 1, points);
w = 24 * (1:points) / points;
figure(1);
plot(w, 20*log10(abs(h)));
title('IIR filter magnitude response');
xlabel('f[kHz]');
ylabel('Gain[dB]');
grid;

figure(2);
polar(angle(v), abs(v), 'x');
hold on;
polar(angle(u), abs(u), 'o');
hold off;
title('IIR filter pole-zero plot');
xlabel('Re(z)');
ylabel('Im(z)');
grid off;
