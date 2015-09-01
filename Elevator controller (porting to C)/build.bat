@echo off & perl -x %0 %* & pause & exit
#!perl
use strict;
use warnings;
use File::Find;
use File::Spec::Unix;
use Cwd 'abs_path';
use Spreadsheet::ParseExcel;

# bootloader
my $options = join(" ", qw(
-mds390
--model-flat24
--stack-10bit
--protect-sp-update
--parms-in-bank1
--stack-auto
--no-xinit-opt
--main-return
--use-accelerator
--nostdinc
--nostdlib
-I ./source
--peep-file optimizer.txt
));
# --all-callee-saves
# --no-c-code-in-asm
# --funsigned-char
# -S = stop after compilation
# --opt-code-size

print "Compiling bootloader...\n";
my $result = `sdcc -c -o ./bootloader/ $options ./bootloader/bootloader.c 2>&1`;
print $result;
die "Compiling failed\n" if $result =~ m/error/i;

open OUT, ">./bootloader/bootloader.lnk" or die $!;
print OUT <<END;
-imxuyYr
-b CSEG = 0x400000
-w 0xc00
-b XSEG = 0x400c00
-v 0x400
./bootloader/bootloader.rel
-e
END
#-b HOME = 0x400000
#-b DSEG = 0x0030
#-b ISEG = 0x0080
#-b BSEG = 0x0000
close OUT or die $!;

print "Linking bootloader...\n";
$result = `sdld -nf "./bootloader/bootloader.lnk" 2>&1`;
print $result;
die "Linking failed\n" if $result ne '';

system("hex_to_c.bat ./bootloader/bootloader.ihx > ./bootloader/bootloader_include.c") == 0
    or die $?;

# main source
my @source;

my %timer_id;

# create build folder
if(!-d "./build") {
    mkdir "./build" or die "Error creating ./build: $!\n";
} else {
    #system "del /Q build";
}

# get all source files and parse them
find(\&add_source_file, './source');

# generate files
open HEADER, ">./source/generated.h" or die "Couldn't create generated.h: $!";
open CODE, ">./source/generated.c" or die "Couldn't create generated.c: $!";

print HEADER "// any changes to this file will be overwritten... change build.bat\n\n";

print CODE "// any changes to this file will be overwritten... change build.bat\n";
print CODE "#include <minimal.h>\n\n";

# timers
print HEADER "\n// timers\n";
my $no_of_timers = 0;
for my $id (sort keys %timer_id)
{
    die "Timer $id is multiply defined\n" if $timer_id{$id} > 1;
    print HEADER qq|#define $id $no_of_timers\n|;
    $no_of_timers++;
}
print HEADER qq|#define NO_OF_TIMERS $no_of_timers\n\n|;

# get date / time
my($second, $minute, $hour, $day_of_month, $month, $year, $day_of_week,
   $day_of_year, $daylight_savings) = localtime();
$year += 1900;
my $build_date = sprintf("%02d-%02d-%02d", $year - 2000, $month + 1, $day_of_month);

print HEADER qq|#define BUILD_DATE "$build_date"\n|;
print HEADER qq|#define SDCC_VERSION "3.0.0"\n|;

=aaa
# strings from excel
my $parser = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse('./config/config.xls');
die $parser->error(), ".\n" unless defined $workbook;
my $worksheet = $workbook->worksheet('Strings');
my($row_min, $row_max) = $worksheet->row_range();
my($col_min, $col_max) = $worksheet->col_range();

my $row = $row_min + 1;     # skip title

while($row <= $row_max)
{
    my $cell = $worksheet->get_cell($row, 1);
    if($cell)
    $cell->value()
    next unless $cell;
=cut









close HEADER or die $!;
close CODE or die $!;

# assuming that the generated files already existed so they are in the source list
# if not the case, add them here

# ensure that main.asm is the first file
while($source[0][1] ne 'main.c') { push @source, shift @source; }

for my $ref (@source)
{
    my($dir, $file) = @$ref;
    print "Compiling $dir/$file ...\n";
    my $build = $dir;
    $build =~ s|^\./source|./build|; # File::Spec::Unix->catdir('./build', $dir);
    mkdir $build;
    my $command = "sdcc -c -o $build/ $options $dir/$file 2>&1"; # print $command, "\n";
    my $result = `$command`;
    print $result;
    if($result =~ m/error/i) { die "Compiling failed\n"; }
}

print "Fixing main.asm...\n";

# slurp main.asm
open IN, "./build/main.asm" or die "Couldn't open main.asm: $!";
my $text = do { local($/); <IN> };
close IN or die $!;

# fix it
my $code = <<END;
sjmp __reset_vect
nop ; perl
END
$text =~ s/ajmp\s+__reset_vect/$code/;

$code = <<END;
__reset_vect:
mov _ie,#0
mov _ta,#0xaa
mov _ta,#0x55
mov _acon,#2 ; perl
END
$text =~ s/__reset_vect:/$code/;

#$text =~ s/\bljmp\b/ajmp/gi;
#$text =~ s/\blcall\b/acall/gi;

# spew it
open OUT, ">./build/main.asm" or die "Couldn't create main.asm: $!";
print OUT $text;
close OUT or die $!;

# recompile it
system("sdas8051 -plosgff ./build/main.asm"); # asx8051

# object file names
my $objects;

for my $ref (@source)
{
    my($dir, $file) = @$ref;
    my $build = $dir;
    $build =~ s|^\./source|./build|; # File::Spec::Unix->catdir('./build', $dir);
    if($file =~ m|([^\./\\]*)\.|)
    {
        my $path = "$build/$1.rel";
        #$path = abs_path($path);
        $objects .= "$path\n";
    }
}

# generate linker option file
open OUT, ">./build/linker.lnk" or die "Couldn't open linker options file: $!";

# options   $objects
print OUT <<END;
-imxuyYr
-b CSEG = 0x000000
-w 0x10000
-b XSEG = 0x400400
-v 0xc00
-b DSEG = 0x18
-b BSEG = 0x24
./build/main.ihx
$objects
END

=aaa

-w 0xc00
-b XSEG = 0x400c00
-v 0x400

-b HOME = 0x0000
-b CSEG = 0x0100

-b ISEG = 0x0080


#./build/main2.rel
#-e
#-a 0x80   -b PSEG = 0x0000
#
#-v 0x1000
# -b XSEG  = 0xf400
# -b XSEG  = 0x000400
# -g symbol = expression
# -k library path
#   -v 0xffffff
=cut

close OUT or die $!;

# additional stuff
system("del .\\build\\linker.link");
system("copy .\\build\\linker.lnk .\\build\\linker.link");

# invoke linker
print "Linking...\n";
my $link = `sdld -nf "./build/linker.lnk" 2>&1`; #aslink
print $link;
die "Linking failed\n" if $link; #~ m/Error/;  cannot

# post processing
print "Generating hex file...\n";
system("packihx ./build/main.ihx > ./build/main.hex");

# disassemble...
print "Disassembling...\n";
system("dis51 -l 0 3 11 19 27 35 < ./build/main.hex > ./build/main.d51");

#system("packihx ./bootloader/bootloader.ihx > ./bootloader/bootloader.hex") == 0
#    or die "Packing bootloader failed: $?\n";

print "Done\n";

sub add_source_file
{
    if(/\.c$/)
    {
        push @source, [$File::Find::dir, $_] ;
        
        parse_file($_);
    }
}

sub parse_file
{
    my $file = shift;
    
    open IN, '<', $file or die "Couldn't open $file: $!\n";
    
    while(<IN>)
    {
        # if(/thread\s*(\w+)\s*(\w+)\)/) { $thread_id{$1} = 1; }
    
        #if(/\bstack\s*\(\s*(\w+)\s*,\s*(\d+)\s*\)/) { push @timer, $1; }
        
        if(m|//\s*timer\s*(\w+)\s*$|) 
        { 
            $timer_id{$1}++;
        }
    }
    
    close IN or die $!;
}
