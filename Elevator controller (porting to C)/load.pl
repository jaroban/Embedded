use strict;
use warnings;
#use Win32::API;
use Win32::SerialPort qw( :PARAM :STAT 0.07 );

# read hex file 
while(<>)
{
    chomp;

    die "Bad line $.: $_\n" unless /^:([0-9A-F]+)$/;

    my $binary = pack('H*', substr($_, 1));

    die "Bad checksum at line $.: $_\n" unless unpack("%8C*", $binary) == 0;
        
    my($len, $addr, $type, $data) = unpack("C n C X4 C x3 /a", $binary);
    
    my @bytes = unpack('H2' x $len, $data);
    
    print "$type, $addr = ", join(',', @bytes), "\n";
}

#use Device::SerialPort qw( :PARAM :STAT 0.07 );

# set up serial port
my $PortName = "COM3";
#my $quiet = 0;
my $PortObj = new Device::SerialPort($PortName, 0)
       || die "Can't open $PortName: $!\n";
       
$PortObj->user_msg(ON);
$PortObj->databits(8);
$PortObj->baudrate(57600);
$PortObj->parity("odd");
$PortObj->stopbits(1);
#$PortObj->handshake("rts"); "none" "xoff"


my $STALL_DEFAULT=10; # how many seconds to wait for new input
 
 my $timeout=$STALL_DEFAULT;
 
 $port->read_char_time(0);     # don't wait for each character
 $port->read_const_time(1000); # 1 second per unfulfilled "read" call
 
 my $chars=0;
 my $buffer="";
 while ($timeout>0) {
        my ($count,$saw)=$port->read(255); # will read _up to_ 255 chars
        if ($count > 0) {
                $chars+=$count;
                $buffer.=$saw;
                
                print $buffer, "\n";
 
                # Check here to see if what we want is in the $buffer
                # say "last" if we find it
        }
        else {
                $timeout--;
        }
 }

 if ($timeout==0) {
        die "Waited $STALL_DEFAULT seconds and never saw what I wanted\n";
 }

  
$PortObj->close || die "failed to close";

