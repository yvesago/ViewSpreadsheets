#!/usr/bin/env perl
use warnings;
use strict;

=head1 DESCRIPTION

A (very) basic test harness for the NewVersion action.

=cut

use ViewSpreadsheets::Test tests => 1;

# Make sure we can load the action
use_ok('ViewSpreadsheets::Action::NewVersion');

my $dom = ViewSpreadsheets::Model::Domain->new();
  $dom->load(1);
  warn $dom->name;

Jifty::Test->web;

Jifty->web->new_action(
    class => 'NewVersion',
    arguments => {
        domain => 1,
        start_date => '2009-09-01T14:00:00',
#        end_date =>
        testfile => 'testfile.xls' 
    })->run;

my $Version = ViewSpreadsheets::Model::Version->new();
  $Version->load(1);
  warn $Version->sdomain->name;

my $spreadCol = ViewSpreadsheets::Model::SpreadsheetCollection->new();
$spreadCol->limit(column => 'version', value => $Version->id);

while (my $s = $spreadCol->next) {
    warn $s->price;
};
