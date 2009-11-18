use strict;
use warnings;

package ViewSpreadsheets::Model::FileDesc;
use Jifty::DBI::Schema;

use ViewSpreadsheets::Record schema {
    column name =>
        is mandatory;
    column pos_ref1 =>
        type is 'int';
    column pos_ref2 =>
        type is 'int';
    column pos_text1 =>
        label is 'position label',
        type is 'int';
    column pos_text2 =>
        label is 'position desc',
        type is 'int';    
    column pos_pp =>
        type is 'int';
    column pos_rate =>
        type is 'int';
    column pos_price =>
        type is 'int';
    column high1_pos =>
        hints is 'Highlight line',
        type is 'int';
    column high1_color =>
        render as 'ViewSpreadsheets::SimpleColor',
        hints is 'Highlight line with color';
    column high1_render =>
        valid_values are qw(no red green blue yellow),
        hints is 'Render line with color';
    column high2_pos =>
        hints is 'Highlight line',
        type is 'int';
    column high2_color =>
        render as 'ViewSpreadsheets::SimpleColor',
        hints is 'Highlight line with color';
    column high2_render =>
        valid_values are qw(no red green blue),
        hints is 'Render line with color';
    column exclude_line_pos =>
        type is 'int';
    column exclude_line_color =>
        render as 'ViewSpreadsheets::SimpleColor',
        hints is 'Line contains color';
};

# Your model-specific methods go here.

sub ViewSpreadsheets::SimpleColor::defaultColors { return "['F00', '0F0', '00f', 'fff', '000']"; };
sub ViewSpreadsheets::SimpleColor::addColors { return "['900', '090', '009', 'ccc', 'ffff00', '99cc00', '00cc99' ]"; };

=head2 current_user_can

=cut

sub current_user_can {
    my $self = shift;
    my $type = shift;
    my %args = (@_);

    return 1 if
          $self->current_user->is_superuser;
    return 1
        if ($type eq 'read');

    return $self->SUPER::current_user_can($type, @_);

};


1;


