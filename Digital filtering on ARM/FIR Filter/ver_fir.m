%     Script verifying the outputs of a FIR filter
% ------------------------------------------------------
% Author: Jaroslav Ban      Supervisor: Milos Drutarovsky
% 
% Department of Electronics and Multimedia Communications
%             Technical University of Kosice
%
% Last revision: May 16 2006

pbr = 10^(0.1/20)-1;
sba = 10^(-75/20);
[n,fo,mo,we] = remezord([4000 5000], [0 1], [sba pbr], 48000);
[b,err,res] = remez(n,fo,mo,we);

load inputs.log;
load outputs.log;
load c_coef.txt;

c_coef = c_coef / 2^15;
inputs = inputs' / 2^15;
outputs = c_coef * outputs' / 2^15;

matlab = filter(b, 1, inputs);
error = outputs - matlab;

figure(1);
plot(error);
title('ARM vs Matlab with exact coefficients');
xlabel('Sample');
ylabel('Error');
grid;
