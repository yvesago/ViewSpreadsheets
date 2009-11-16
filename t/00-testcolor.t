use strict;
use Spreadsheet::ParseExcel;

my $file='share/web/static/files/testfile.xls';

use Data::Dumper;

my $show_row = 12;
my $show_col = 7;

printf "=>Show arround (%s , %s)<=\n", $show_row, $show_col;

my $oParse = Spreadsheet::ParseExcel->new();
my $excel = Spreadsheet::ParseExcel::Workbook->Parse($file);
foreach my $sheet (@{$excel->{Worksheet}}) {
   printf("Sheet: %s\n", $sheet->{Name});
   $sheet->{MaxRow} ||= $sheet->{MinRow};
   foreach my $row ($sheet->{MinRow} .. $sheet->{MaxRow}) {
       $sheet->{MaxCol} ||= $sheet->{MinCol};
       #exit if $row > 9;
       foreach my $col ($sheet->{MinCol} ..  $sheet->{MaxCol}) {
           my $cell = $sheet->{Cells}[$row][$col];

           if ($cell) {
               my @cellcolor = @{$cell->{Format}->{Fill}};
               my $backcolor = '#'.lc($oParse->ColorIdxToRGB( $cellcolor[1] ));
               my $fontcolor = '#'.lc($oParse->ColorIdxToRGB( $cell->{Format}->{Font}->{Color} ));
               printf("( %s , %s ) => %s : backcolor %s, fontcolor %s\n", $row+1, $col+1, $cell->{Val}, $backcolor, $fontcolor)
                    if ( $row == $show_row -1 && $col == $show_col -1 ) ||
                       ( $row == $show_row -2 && $col == $show_col -2 ) ||
                       ( $row == $show_row +1 && $col == $show_col +1 );
           }
       }
   }
}

