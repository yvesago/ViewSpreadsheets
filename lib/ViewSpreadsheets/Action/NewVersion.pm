use strict;
use warnings;

=head1 NAME

ViewSpreadsheets::Action::NewVersion

=cut

package ViewSpreadsheets::Action::NewVersion;
use base qw/ViewSpreadsheets::Action Jifty::Action/;

use Jifty::Param::Schema;
use Jifty::Action schema {
    param domain =>
        render as 'select',
        is mandatory,
        available are defer { 
            my $col=ViewSpreadsheets::Model::DomainCollection->new; 
            $col->unlimit; 
            my @res = ({display => 'novalue', value => 0}); 
            map {push @res, { display => $_->name, value => $_->id} } @{$col->items_array_ref};
            \@res;};
    param start_date =>
        is mandatory,
        render as 'DateTime';
    param end_date =>
        render as 'DateTime';
    param file =>
        render as 'Upload';
    # testfile is only used with unit tests
    param 'testfile' =>
        render as 'hidden';

};

=head2 take_action

=cut

use Spreadsheet::ParseExcel;

sub take_action {
    my $self = shift;
   
    # TODO: vrfy name or use a static namefile
    my $testfile = $self->argument_value('testfile') || 0;

    my $fh;
    if ($testfile) { 
       open $fh, 't/'.$testfile; }
     else {
       $fh = $self->argument_value('file'); };

    my $filename = $testfile || scalar($fh);
    #warn $filename;

    # TODO don't allow same file name

    if (!$testfile) {
        local $/;
        binmode $fh;
        # TODO: choose destination dir
        open FILE, '>', $filename;
        print FILE <$fh>;
        close FILE;
    };

   my $excel = Spreadsheet::ParseExcel::Workbook->Parse('t/'.$filename);
   foreach my $sheet (@{$excel->{Worksheet}}) {
       printf("Sheet: %s\n", $sheet->{Name});
       $sheet->{MaxRow} ||= $sheet->{MinRow};
        next if !$sheet->{MaxRow};
       foreach my $row ($sheet->{MinRow} .. $sheet->{MaxRow}) {
           $sheet->{MaxCol} ||= $sheet->{MinCol};
            next if !$sheet->{MaxiCol};
           foreach my $col ($sheet->{MinCol} ..  $sheet->{MaxCol}) {
               my $cell = $sheet->{Cells}[$row][$col];
               if ($cell) {
                   printf("( %s , %s ) => %s\n", $row, $col, $cell->{Val});
               }
           }
       }
   }
 return 1;

    my $version = ViewSpreadsheets::Model::Version->new();
    $version->create(
        sdomain => $self->argument_value('domain'), 
        start_date => $self->argument_value('start_date'),
        end_date => $self->argument_value('end_date'),
        filename => $filename);

    $self->report_success if not $self->result->failure;
    
    return 1;
};

=head2 report_success

=cut

sub report_success {
    my $self = shift;
    # Your success message here
    $self->result->message('Success');
};

1;

