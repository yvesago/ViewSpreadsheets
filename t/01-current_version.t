#!/usr/bin/env perl
use warnings;
use strict;

=head1 DESCRIPTION

Test to find current version.

=cut

use ViewSpreadsheets::Test tests => 1;

my $col = ViewSpreadsheets::Model::VersionCollection->new();

my $now = Jifty::DateTime->now;

$col->limit(column => 'start_date', value => $now, operator => '<');

print $col->first->start_date;

my $dom = ViewSpreadsheets::Model::Domain->new();
$dom->load(1);

print $dom->current_version->start_date;


