use strict;
use warnings;

=head1 NAME

ViewSpreadsheets::Action::NewOffer

=cut

package ViewSpreadsheets::Action::NewOffer;
use base qw/ViewSpreadsheets::Action Jifty::Action/;

use Jifty::Param::Schema;
use Jifty::Action schema {
    param domain =>
        render as 'hidden';
        is mandatory;
    param start_date =>
        label is 'Date de début',
        is mandatory,
        render as 'DateTime';
    param end_date =>
        label is 'Date de fin',
        is mandatory,
        render as 'DateTime';
    param file =>
        label is 'Fichier',
        is mandatory,
        render as 'Upload';
    param msg =>
        label is 'Message',
        render as 'Jifty::Plugin::WikiToolbar::Textarea',
        type is 'text';
};

=head2 take_action

=cut

sub take_action {
    my $self = shift;
    
    # Custom action code
    my $domid = $self->argument_value('domain');
    return 0 if (!$domid);

    my $domain = ViewSpreadsheets::Model::Domain->new();
    $domain->load($domid);

    my $fh = $self->argument_value('file');

    my $filename = scalar($fh);
    $filename = ViewSpreadsheets->clean_file_name($filename);

    my $destdir = Jifty::Util->app_root().'/share/web/static/files/';

        local $/;
        binmode $fh;
        open FILE, '>', $destdir.$filename;
        print FILE <$fh>;
        close FILE;

   my $offer = ViewSpreadsheets::Model::Offer->new();
   $offer->create(
        sdomain => $domain->id,
        filename => $filename,
        start_date => $self->argument_value('start_date'), 
        end_date => $self->argument_value('end_date'), 
        msg => $self->argument_value('msg')
        );

   Jifty->web->next_page('/user');

   # a version whithout start_date is a test
    
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

