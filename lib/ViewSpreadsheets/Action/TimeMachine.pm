use strict;
use warnings;

=head1 NAME

ViewSpreadsheets::Action::TimeMachine

=cut

package ViewSpreadsheets::Action::TimeMachine;
use base qw/ViewSpreadsheets::Action Jifty::Action/;

use Jifty::Param::Schema;
use Jifty::Action schema {
    param timedate =>
        type is 'datetime',
        render as 'DateTime',
        hints is 'Jour et heure',
        label is '';
    param today =>
        type is 'hidden',
        default is '0';
};

sub xxxvalidate_timedate {
    my $self = shift;
    my $new_value;
    # validation error will set a global popup
}


=head2 take_action

=cut

sub take_action {
    my $self = shift;
    
    # Custom action code

    # this set error near field instead of a global popup
    if ($self->argument_value('timedate') && 
        $self->argument_value('timedate') !~ m/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/) {
            $self->validation_error( timedate => 'Format de date faux ou incomplet' );
            return 0;
    };

    Jifty->web->session->set(RefTime => ( $self->argument_value('today') )?undef:$self->argument_value('timedate') );

    my $dom = Jifty->web->session->get('Dom');
    Jifty->web->session->set(Version => $dom->current_version);
    Jifty->web->tangent(url => '/user');
    
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

