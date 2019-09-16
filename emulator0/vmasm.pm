#!/usr/bin/perl -w

BEGIN{

use Exporter ();
@ISA = "Exporter";
@EXPORT = qw (%opcodes %counts_operand %optypes $count_opcode $unused_operand &parse_line &parse_input_code);
}
my %opcodes;
my %counts_operand;
my %optypes;
my $count_opcode;
my $unused_operand;

$optypes{"none"} = "\x00";
$optypes{"regb"} = "\x01";
$optypes{"regw"} = "\x02";
$optypes{"immed"} = "\x03";
$optypes{"immaddr"} = "\x04";
$optypes{"regaddr"} = "\x05";

$opcodes{"nop"} = "\x00";
$counts_operand{"nop"} = 0;
$opcodes{"in"} = "\x01";
$counts_operand{"in"} = 1;
$opcodes{"out"} = "\x02";
$counts_operand{"out"} = 1;
$opcodes{"mov"} = "\x03";
$counts_operand{"mov"} = 2;
$opcodes{"add"} = "\x04";
$counts_operand{"add"} = 2;
$opcodes{"sub"} = "\x05";
$counts_operand{"sub"} = 2;
$opcodes{"xor"} = "\x06";
$counts_operand{"xor"} = 2;
$opcodes{"and"} = "\x07";
$counts_operand{"and"} = 2;
$opcodes{"or"} = "\x08";
$counts_operand{"or"} = 2;
$opcodes{"hlt"} = "\x09";
$counts_operand{"hlt"} = 0;

$count_opcode = 10;

#my $optype_none = "\x00";
#my $optype_flagb= "\x01";
#my $optype_flagw= "\x02";
#my $optype_idb  = "\x03";
#my $optype_idw  = "\x04";
#my $optype_regb = "\x05";
#my $optype_regw = "\x06";
#my $optype_immed= "\x07";

$unused_operand = "\x00"x5;


sub parse_operand {

my $op = shift @_;

    if(!defined($op)){
        print STDERR "undefined operand\n";
        return undef;
        }

    if($op =~ /^[0-9]+$/){
        return $optypes{"immed"}.pack("L",$op);
        }
    elsif($op =~ /^0x([a-f0-9]+)$/i){
        return $optypes{"immed"}.pack("h8",scalar reverse($1));
        }
    elsif($op =~ /^(byte )*r([0-9]+)$/){
        if(defined($1)){
            return $optypes{"regb"}.pack("L",$2);
            }
        else{
            return $optypes{"regw"}.pack("L",$2);
            }
        }
    elsif($op =~ /^\[0x([a-f0-9]+)\]$/i){
        return $optypes{"immaddr"}.pack("h8",scalar reverse($1));
        }
    elsif($op =~ /^\[r([0-9]+)\]$/){
        return $optypes{"regaddr"}.pack("L",$1);
        }
    print STDERR "error in operand $op\n";

    return undef;
}


sub parse_line{
    
my $line = shift @_;
my $mnem;
my $ops;
my $op1;
my $op2;

    if(! ($line =~ /^ *([a-z]{2,3}) *(.*) *$/) ){
        print STDERR "error in line $line\n";
        return undef;
        }

    $mnem = $1;
    $ops = $2;

    if( !defined($opcodes{$mnem}) ){
        print STDERR "error in mnemonic $1\n";
        return undef;
        }

    if( $counts_operand{$mnem} == 0){
        return $opcodes{$mnem}.$unused_operand.$unused_operand;
        }
    elsif($counts_operand{$mnem} == 1){
        $op1 = parse_operand($ops);
        if(!defined($op1)){
            print STDERR "request operand in $ops\n";
            return undef;
            }
        return $opcodes{$mnem}.$op1.$unused_operand;
        }
    elsif($counts_operand{$mnem} == 2){

        if( !($ops =~ /^([0-9a-z \[\]x]+), *([0-9a-z \[\]x]+)$/i) ){
            print STDERR "error in operands $ops\n";
            return undef;
            }
        $op1 = $1;
        $op2 = $2;

        $op1 = parse_operand($op1);
        if(!defined($op1)){
            print STDERR "request operand 1 in $op1\n";
            return undef;
            }

        $op2 = parse_operand($op2);
        if(!defined($op2)){
            print STDERR "request operand 2 in $op2\n";
            return undef;
            }
        return $opcodes{$mnem}.$op1.$op2;
        }

    print STDERR "unknow error\n";
    return undef;
}


sub parse_input_code{

my $line;
my $res;
my $line_code;

my $in = shift @_;
if(!defined($in)){
    $in = STDIN;
    }

    while( defined($line = <$in>) ){
        chomp($line);
        if($line =~ /^ *$/){
            next;
            }
        $line_code = parse_line($line);
        if(!defined($line_code)){
            return;
            }
        $res .= $line_code;
        }

    return $res;
}

#print parse_code();

return 1;

END { }