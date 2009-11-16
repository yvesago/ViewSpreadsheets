use strict;
use warnings;

=head1 NAME

ViewSpreadsheets::Action::ChgNbLines

=cut

package ViewSpreadsheets::Action::ChgNbLines;
use base qw/ViewSpreadsheets::Action Jifty::Action/;

use Jifty::Param::Schema;
use Jifty::Action schema {
    param nblines =>
        label is 'Lignes à afficher',
        hints is 'Entre 5 et 100';

};

sub validate_nblines {
    my $self      = shift;
    my $new_value = shift;
    return $self->validation_error( nblines => 'Mauvaise valeur' )
        if ($new_value !~ m/^\d+$/);
    return $self->validation_error( nblines => 'Entre 5 et 100' )
        if ($new_value < 5 || $new_value > 100);
    return $self->validation_ok('nblines');

};


=head2 take_action

=cut

sub take_action {
    my $self = shift;
    my $nblines = $self->argument_value('nblines') || 30;
   
    Jifty->web->session->set(NBlines => $nblines);
    # Custom action code
    
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

