function gen_tab(log2N)
% log2N - base 2 log of the size of FFT
% file - where to put the table
%
%    Script generating FFT coefficients (sin, cos)
% ------------------------------------------------------
% Author: Jaroslav Ban      Supervisor: Milos Drutarovsky
% 
% Department of Electronics and Multimedia Communications
%             Technical University of Kosice
%
% Last revision: May 18 2006

log2N = round(log2N);
N = 2 ^ log2N;
fid = fopen('ffttabls.h', 'wt');
fprintf(fid, 'TABLE_N EQU %d\nTABLE_LOGN EQU %d\n', N, log2N);
scale = 2 ^ 14;
points = N / 8;
dw = 2 * pi / N;
for i = 0:points
    w = i * dw;
    sinn = round(scale * sin(w));
    coss = round(scale * cos(w));
    fprintf(fid, ' DCD 0x%04x%04x\n', sinn, coss);
end
fprintf(fid, ' END\n');
status = fclose(fid);
