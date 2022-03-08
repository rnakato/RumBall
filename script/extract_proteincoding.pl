#! /usr/bin/perl -w 

open(IN, $ARGV[0]) || die;
my $num_on=0;
my $num_off=0;
my %Hash;
while(<IN>) {
    next if($_ eq "\n");
    if (!index($_, '#')) {
	print $_;
	next;
    }
    chomp;

    if ($_ =~ /(.+)gene_biotype "(.+?)";/ ){
	$num_on++;
	$Hash{$2}=0 if(!exists($Hash{$2}));
	$Hash{$2}++;
	#	print "$2\n";
	
	print "$_\n" if($2 eq "protein_coding");
    } else {$num_off++;}
}
close IN;

#print "$num_on, $num_off\n";

#foreach my $key (keys %Hash){
#    print "$key, $Hash{$key}\n";
#}
