%     Script verifying the outputs of an IIR filter
% -------------------------------------------------------
% Author: Michal Varchola   Supervisor: Milos Drutarovsky
% 
% Department of Electronics and Multimedia Communications
%             Technical University of Kosice
%
% Last revision: May 15 2006

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

load inputs.log;
load outputs.log;

inputs = inputs' / 2^15;
outputs = outputs' / 2^15;
matlab = C * bfilter(nsec, dsec, inputs);
error = outputs - matlab;

figure(1);
plot(error);
title('ARM (2.14) vs Matlab with exact coefficients');
xlabel('Sample');
ylabel('Error');
grid;

nsec = round(nsec * 2^14) / 2^14;  % scale coefficients to 2.14 format
dsec = round(dsec * 2^14) / 2^14;   
C = round(C * 2^14) / 2^14;

matlab = C * bfilter(nsec, dsec, inputs);
error = outputs - matlab;

figure(2);
plot(error);
title('ARM (2.14) vs Matlab with 2.14 coefficients');
xlabel('Sample');
ylabel('Error');
grid;
