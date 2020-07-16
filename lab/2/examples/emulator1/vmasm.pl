#!/usr/bin/perl -w

use lib ".";
use vmasm;

my $input_file = shift @ARGV;
my $output_file = shift @ARGV;

if(defined($input_file)){
    open($in,"<$input_file") or die("error open input file");
    }
else{
    $in = STDIN;
    }

if(defined($output_file)){
    open($out,">$output_file") or die("error open output file");
    }
else{
    $out = STDOUT;
    }
	
binmode $in;
binmode $out;

print $out parse_input_code($in);

