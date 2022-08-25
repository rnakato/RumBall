#! /usr/bin/perl -w 

open(IN, $ARGV[0]) || die;
while(<IN>) {
    next if($_ eq "\n");
    if (!index($_, '#')) {
	print $_;
	next;
    }
    chomp;
    my @clm = split(/\t/, $_);
    my $chr = "";
    if($clm[0] eq "MT") {
	print "chrM";
    } else {
	print "chr$clm[0]";
    }
    for($i=1;$i<=$#clm;$i++) {
	print "\t$clm[$i]";
    }
    print "\n";
}
close IN;
