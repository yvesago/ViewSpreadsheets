use strict;
use warnings;

package ViewSpreadsheets::SimpleColor;
use base qw/Jifty::Web::Form::Field/;

=head1 NAME

ViewSpreadsheets::SimpleColor - widget for a simple color picker

=head1 SYNOPSIS

  column line_color =>
     render as 'ViewSpreadsheets::SimpleColor',

  sub ViewSpreadsheets::SimpleColor::defaultColors { return "['F00', '0F0', '00f', 'fff', '000']"; };
  sub ViewSpreadsheets::SimpleColor::addColors { return "['900', '090', '009', 'ccc']"; };


=head2 accessors

allow to addColors or define new defaultColors
 
=cut

__PACKAGE__->mk_accessors(qw(addColors defaultColors));

#sub accessors { shift->SUPER::accessors(), 'addColors', 'defaultColors' }


=head2 render_widget

html widget

=cut

sub render_widget {
    my $self  = shift;
    my $field;

    my $element_id = "@{[ $self->element_id ]}";
    $element_id=~s/.*(S\d{7})$/$1/;

    my $defaultColors = $self->defaultColors() || undef;
    my $addColors = $self->addColors() || undef;
    my $current_value = $self->current_value || undef;

    $field .= qq!<div>!;
    $field .= qq!<input id="$element_id"!;
    $field .= qq! name="@{[ $self->input_name ]}"!;
    $field .= qq! type="text" value="$current_value" /></div>!;
    $field .= <<"EOF";
<script language="javascript">

jQuery(document).ready(function() {
EOF

$field .= qq!    jQuery.fn.colorPicker.defaultColors = $defaultColors ;! if ($defaultColors) ;
$field .= qq!    jQuery.fn.colorPicker.addColors( $addColors ) ;! if ($addColors) ;

$field .= <<"EOF2";
    jQuery('#$element_id').colorPicker();
  });
</script>
EOF2

    Jifty->web->out($field);
    '';
};

=head2 render_value

Renders value as a div block

=cut

sub render_value {
    my $self  = shift;
    my $field;

    my $current_value = $self->current_value || undef;
    $field .= <<"E2F";
<div style="
  height: 16px;
  width: 16px;
  padding: 0 !important;
  border: 1px solid #ccc;
  background-color: $current_value;
  cursor: pointer;
  line-height: 16px;">\&nbsp;</div>
E2F

    Jifty->web->out($field);
    '';
};

=head1 AUTHOR

Yves Agostini, <yvesago@cpan.org>

=head1 LICENSE

Copyright 2009, Yves Agostini.

This program is free software and may be modified and distributed under the same terms as Perl itself.

=cut


1;

