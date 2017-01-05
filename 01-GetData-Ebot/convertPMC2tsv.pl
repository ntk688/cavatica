#!/usr/bin/perl

use strict;
use warnings;

die "usage: $0 keyword paper.tsv author.tsv XML_files ...\n" if @ARGV<4;

my $keyword = shift @ARGV;
my $paper_file_name = shift @ARGV;
my $author_file_name = shift @ARGV;

my ($pmcid, $title, $year, $text);
my @authors;
my %affiliations;
my ($article_c, $pmcid_c, $title_c, $year_c, $text_c) = ( 0, 0, 0, 0, 0 );

$keyword = lc $keyword; # comment this line to do case sensitive search

open PAPER, ">$paper_file_name" or die "can't open paper TSV file $paper_file_name to write";
open AUTHOR, ">$author_file_name" or die "can't open author TSV file $author_file_name to write";

print PAPER "pmid\tyear\tcount\ttitle\n";
print AUTHOR "pmid\tforename_lastname\taffiliation\n";

while (<>) {
  if (/<article /) {
    $pmcid = $title = $year = $text = "";
    @authors = ( );
    %affiliations = ( );
    $article_c++;
  } elsif (/<article-id pub-id-type=\"pmc\">(\d+)<\/article-id>/ && length($pmcid)==0) {
    $pmcid = $1;
    #print STDERR "$pmcid\n";
    $pmcid_c++;
  } elsif (/<article-title>/ && length($title)==0) {
    chomp;
    $title = $_;
    while ($_ !~ /<\/article-title>/) {
      $_ = <>;
      chomp;
      $title .= $_;
    }
    $title =~ /<article-title>(.+)<\/article-title>/;
    $title = $1;
    $title_c++;
  } elsif (/<contrib contrib-type=\"author\">/) {
    my @a;
    while ($_ !~ /<\/contrib>/) {
      $a[0] = $1 if /<surname>(.+?)<\/surname>/;
      $a[1] = $1 if /<given-names>(.+?)<\/given-names>/;
      $a[2] = $1 if /<xref ref-type=\"aff\" rid=\"(.+?)\">/;
      $_ = <>;
    }
    unless (defined($a[0]) || defined($a[1])) {
      warn "incomplete author information";
    } else {
      push @authors, \@a;
    }
  } elsif (/<aff id=\"(.+?)\">(.+?)<\/aff>/) {
    my ($i, $a) = ( $1, $2);
    $a =~ s/^<([^>]+)>.+?<\/\1>//;
    #$a =~ s/<.+?>//g; # uncomment this line if you want HTML markups removed, too
    $affiliations{$i} = $a;
  } elsif (/<pub-date .*?(pub-type=\"[pe]pub\"|date-type=\"pub\")/ && length($year)==0) {
    while (1) {
      if (/<year.*?>(\d+)<\/year/) {
	$year = $1;
	$year_c++;
	last;
      } elsif (/<\/pub-date>/) {
	last;
      }
      $_ = <>;
    }
  } elsif (/<body>/ && defined($text)) {
    chomp;
    $text = $_;
  } elsif (/<\/body>/ && defined($text)) {
    chomp;
    $text .= $_;
    my $copy = lc $text; # drop 'lc' for case sensitive search
    my $count = () = $copy =~ /$keyword/g;
    $count -= () = $copy =~ /\.$keyword\./g; # uncount cases like www.cytoscape.org
    if ($count>0) {
      if ($pmcid) {
	print PAPER "$pmcid\t$year\t$count\t$title\n";
	warn "PMC id $pmcid has no year info" unless length($year);
	for (@authors) {
	  print AUTHOR "$pmcid\t";
	  if (defined $_->[0]) {
	    print AUTHOR "$_->[0]_";
	  } else {
	    print AUTHOR "UNKNOWN_";
	  }
	  if (defined $_->[1]) {
	    print AUTHOR "$_->[1]\t";
	  } else {
	    print AUTHOR "UNKNOWN\t";
	  }
	  if (defined($_->[2]) && defined($affiliations{$_->[2]})) {
	    print AUTHOR "$affiliations{$_->[2]}\n";
	  } else {
	    print AUTHOR "UNKNOWN\n";
	  }
	}
      } else {
	die "Article $title has no PMC ID";
      }
    }
    undef $text;
    $text_c++;
  } elsif (defined($text)) {
    chomp;
    $text .= $_;
  }
}
close PAPER;
close AUTHOR;
print STDERR "Scanned $article_c articles, $pmcid_c PMC ids, $title_c titles, $year_c years and $text_c text bodies\n";