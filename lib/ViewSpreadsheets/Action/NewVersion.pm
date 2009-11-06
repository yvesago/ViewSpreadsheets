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

};

=head2 take_action

=cut

sub take_action {
    my $self = shift;
    
    # Custom action code
   
    my $fh = $self->argument_value('file');
    my $filename = scalar($fh);
    warn $filename;
    local $/;
    binmode $fh;
    open FILE, '>', $filename;
    print FILE <$fh>;
    close FILE;

    my $version = ViewSpreadsheets::Model::Version->new();
    $version->create(
        sdomain => $self->argument_value('domain'), 
        start_date => $self->argument_value('start_date'),
        end_date => $self->argument_value('end_date'),
        filename => $filename);

    $self->report_success if not $self->result->failure;
    
    return 1;
}

=head2 report_success

=cut

sub report_success {
    my $self = shift;
    # Your success message here
    $self->result->message('Success');
}

1;

