use strict;
use Spreadsheet::ParseExcel;

my $file='share/web/static/files/testfile.xls';

use Data::Dumper;

my $show_row = 12;
my $show_col = 7;


my $oparse = Spreadsheet::ParseExcel->new();
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
               my $frontcolor = $cellcolor[1];
               my $fontcolor = $cell->{Format}->{Font}->{Color} ;
               printf("( %s , %s ) => %s : backcolor %s, fontcolor %s\n", $row, $col, $cell->{Val}, $frontcolor, $fontcolor) 
                    if $row == $show_row -1 && $col == $show_col -1;
           }
       }
   }
}

