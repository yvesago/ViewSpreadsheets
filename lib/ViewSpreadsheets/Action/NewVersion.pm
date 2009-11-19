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
        render as 'hidden';
        is mandatory;
    param start_date =>
        label is 'Date de début',
        render as 'DateTime';
    param end_date =>
        render as 'DateTime';
    param file =>
        label is 'Fichier',
        render as 'Upload';
    param update_id =>
        render as 'hidden';
    # testfile is only used with unit tests
    param 'testfile' =>
        render as 'hidden';
};

=head2 take_action

=cut

use Spreadsheet::ParseExcel;
use Encode;

sub take_action {
    my $self = shift;
   
    my $domid = $self->argument_value('domain');
    return 0 if (!$domid);

    my $domain = ViewSpreadsheets::Model::Domain->new();
    $domain->load($domid);

    # TODO: vrfy name or use a static namefile
    my $testfile = $self->argument_value('testfile') || 0;

    #################################
    # validate file with a start_date
    my $version_id = $self->argument_value('update_id') || 0;
    if ($version_id) {
        my $update_version = ViewSpreadsheets::Model::Version->new();
        $update_version->load($version_id);
        if ( $update_version->id ) {
            if ( not $self->argument_value('start_date') ) {
                $self->validation_error( start_date => 'valeur obligatoire' );
                return 0;
            };
            if ($self->argument_value('start_date') !~ m/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/) {
                $self->validation_error( start_date => 'Format de date faux ou incomplet' );
                return 0;
            };
            $update_version->set_start_date( $self->argument_value('start_date') );
            #$update_version->set_end_date ( $self->argument_value('end_date') )
            #    if $self->argument_value('end_date');
            $self->result->message('Fichier validé.') if not $self->result->failure;
            Jifty->web->session->set(Version => undef);
            Jifty->web->tangent( url => '/user/dom/'.$domain->id);
            return 1;
        }
        else {
            return 0;
        };
    };

    #####################
    # Load file
    my $fh;
    if ($testfile) { 
       open $fh, 't/'.$testfile;
     }
     else {
       $fh = $self->argument_value('file');
       };

    my $filename = $testfile || scalar($fh);
    $filename = ViewSpreadsheets->clean_file_name($filename);

    my $destdir = ($testfile)? 't/':Jifty::Util->app_root().'/share/web/static/files/';

    # TODO don't allow same file name (??)

    if (!$testfile) {
        local $/;
        binmode $fh;
        open FILE, '>', $destdir.$filename;
        print FILE <$fh>;
        close FILE;
    };

   my $version = ViewSpreadsheets::Model::Version->new();
   # a version whithout start_date is a test
   $version->create(
        sdomain => $self->argument_value('domain'), 
        filename => $filename);
   Jifty->web->session->set(Version => $version);

   # Read spreadsheet
   my $spreadsheet = ViewSpreadsheets::Model::Spreadsheet->new();

   my $oParse = Spreadsheet::ParseExcel->new();
   my $excel = Spreadsheet::ParseExcel::Workbook->Parse($destdir.$filename);
   foreach my $sheet (@{$excel->{Worksheet}}) {
       $sheet->{MaxRow} ||= $sheet->{MinRow};
        next if ! defined $sheet->{MaxRow};
       my ($val,$fontcolor,$backcolor);
       foreach my $row ($sheet->{MinRow} .. $sheet->{MaxRow}) {
           my $valid_row = 0;
           my $numcell = $sheet->{Cells}[$row][$domain->filedesc->pos_pp -1];

           if ($numcell && $numcell->{Val} =~m/^(-?)(\s?)\d/ ) {
                $val = $numcell->{Val};
                # catch font and back color
                my @cellcolor = @{$numcell->{Format}->{Fill}};
                $backcolor = '#'.lc($oParse->ColorIdxToRGB( $cellcolor[1] ));
                $fontcolor = '#'.lc($oParse->ColorIdxToRGB( $numcell->{Format}->{Font}->{Color} ));
                # XXX can't read font color
                $valid_row = 1;
                if ( $domain->filedesc->exclude_line_color ) {
                    $valid_row = 0
                        if $domain->filedesc->exclude_line_color eq $fontcolor ||
                          $domain->filedesc->exclude_line_color eq $backcolor;
                };
                if ( $domain->filedesc->exclude_line_pos ) {
                    $valid_row = 0
                        if $sheet->{Cells}[$row][$domain->filedesc->exclude_line_pos -1]->{Val};
                };
           };

          if ($valid_row) {
               my $text1 = encode('utf8',$sheet->{Cells}[$row][$domain->filedesc->pos_text1 -1]->{Val})
                    if $domain->filedesc->pos_text1;
               my $text2 = encode('utf8',$sheet->{Cells}[$row][$domain->filedesc->pos_text2 -1]->{Val})
                    if $domain->filedesc->pos_text2;
               my $ref1 = encode('utf8',$sheet->{Cells}[$row][$domain->filedesc->pos_ref1 -1 ]->{Val})
                            if $domain->filedesc->pos_ref1;
               my $ref2 = encode('utf8',$sheet->{Cells}[$row][$domain->filedesc->pos_ref2 -1 ]->{Val})
                            if $domain->filedesc->pos_ref2;
               my $pp = sprintf "%.2f", $sheet->{Cells}[$row][$domain->filedesc->pos_pp -1]->{Val}
                        if $domain->filedesc->pos_pp;
               my $rate = sprintf "%.2f", $sheet->{Cells}[$row][$domain->filedesc->pos_rate -1]->{Val}
                        if $domain->filedesc->pos_rate;
               my $price = sprintf "%.2f", $sheet->{Cells}[$row][$domain->filedesc->pos_price -1]->{Val}
                        if $domain->filedesc->pos_price;
               my $highlight;
               if ( $domain->filedesc->high1_pos ) {
                    $highlight = $domain->filedesc->high1_render
                        if $sheet->{Cells}[$row][$domain->filedesc->high1_pos -1]->{Val};
                } 
                elsif ( $domain->filedesc->high1_color ) {
                    $highlight = $domain->filedesc->high1_render
                        if $backcolor eq $domain->filedesc->high1_color || $fontcolor eq $domain->filedesc->high1_color;
                } 
                else {
                $highlight = undef;
                };
                if ( $domain->filedesc->high2_pos ) {
                    $highlight = $domain->filedesc->high2_render
                        if $sheet->{Cells}[$row][$domain->filedesc->high2_pos -1]->{Val};
                }
                elsif ( $domain->filedesc->high2_color ) {
                    $highlight = $domain->filedesc->high2_render
                        if $backcolor eq $domain->filedesc->high2_color || $fontcolor eq $domain->filedesc->high2_color;
                }
                else {
                #$highlight = undef;
                };

               #warn $highlight ;
               $spreadsheet->create(
                line => $row+1,
                ref1 => $ref1, ref2 => $ref2,
                text1 => $text1, text2 => $text2,
                pp => $pp, rate => $rate, price => $price,
                highlight => $highlight,
                version => $version->id
                );
               };
            };
    };

    $self->report_success if not $self->result->failure;
    
    return 1;
};

=head2 report_success

=cut

sub report_success {
    my $self = shift;
    # Your success message here
    $self->result->message('Fichier importé.');
};

1;

