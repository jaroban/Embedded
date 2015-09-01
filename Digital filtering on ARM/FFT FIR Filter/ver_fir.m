%    Script verifying outputs of an OLA filter
% ------------------------------------------------------
% Author: Jaroslav Ban      Supervisor: Milos Drutarovsky
% 
% Department of Electronics and Multimedia Communications
%             Technical University of Kosice
%
% Last revision: May 15 2006

load c_exact.txt;
load inputs.log;
load outputs.log;

N = 1024;

c_exact = round(c_exact' * 2^15) / 2^15;
outputs = outputs' / 2^15;
inputs = inputs' / 2^15;
n = size(outputs, 2);
matlab = real(ola(inputs, c_exact, N));
error = outputs - matlab(1:n);

figure(1);
plot(error);
title('ARM vs. Matlab with the same coefficients');
xlabel('Sample');
ylabel('Error');
grid;

figure(2);
plot(matlab(1:n));
title('Matlab OLA signal');
xlabel('Sample');
ylabel('Value');
grid;

figure(3);
plot(outputs);
title('ARM outputs');
xlabel('Sample');
ylabel('Value');
grid;
