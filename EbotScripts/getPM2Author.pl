#! /usr/bin/env perl

use strict;
use warnings;

my $pmid="pmid";
my $forename="forename";
my $lastname="lastname";
my $affiliation="affiliation";

my $check="pmid";
my $getyear=0;

sub printoutput{
    print("$pmid\t${forename}_${lastname}\t$affiliation\n");
}

printoutput;
while(<>){
    chomp;
    if(/<\/PubmedArticle>/){
	$pmid="pmid";
    }
    if(/<\/Author>/){
	printoutput;
	$lastname="lastname";
	$forename="forename";
	$affiliation="";
    }
    if(/<PMID Version="1">(\d+)<\/PMID>/){
	if($pmid eq $check){
	    $pmid=$1;
	}
    }
    if(/<LastName>(.+)<\/LastName>/){
	$lastname=$1;
	$lastname=~s/ /_/g;
    }
    if(/<ForeName>(.+)<\/ForeName>/){
	$forename=$1;
	$forename=~s/ /_/g;
    }
    if(/<Affiliation>(.+)<\/Affiliation>/){
	$affiliation=$1;
    }

}

