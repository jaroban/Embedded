@echo off & perl -x %0 %* & exit
#!perl
use strict;
use warnings;

my @m;

while(<>)
{
    if(/^\s*:([0-9A-F]+)\s*$/)
    {
        my $bin = pack('H*', $1);
        die "Invalid checksum at line $.\n" unless unpack("%8C*", $bin) == 0;
        my($len, $addr, $type, @data) = unpack("CnC*", $bin);
        pop @data;
        #print "At $addr, type = $type, len = $len, data = ", join("-", @data), "\n";
        if($type == 0)
        {
            for(my $i = 0; $i < $len; $i++)
            {
                $m[$addr + $i] = $data[$i];
            }
        }
    }
}

my $per_row = 16;

for(my $i = 0; $i < @m; $i++)
{
    print("    ") if ($i % $per_row) == 0;
    $m[$i] = -1 unless defined $m[$i];
    printf("%3d", $m[$i]);
    print(",") if $i < @m - 1;
    print("\n") if ($i % $per_row) == ($per_row - 1);
}
