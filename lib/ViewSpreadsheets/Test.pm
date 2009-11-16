package ViewSpreadsheets::Test;
use base qw/Jifty::Test/;

=head1 name

ViewSpreadsheets::Test - set test values

=cut

sub test_config {
               my $class = shift;
               my ($config) = @_;
               my $hash = $class->SUPER::test_config($config);
               $hash->{framework}{L10N}->{'AllowedLang'} = "fr";

               return $hash;
           };


sub setup {
  my $class = shift;
  $class->SUPER::setup;

  my $ADMIN = ViewSpreadsheets::CurrentUser->superuser;

  my $filedesc = ViewSpreadsheets::Model::FileDesc->new(current_user => $ADMIN);
  $filedesc->create(
    name => 'dell',
    pos_ref1 => 1,
    pos_plabel => 3,
    pos_refplabel => 2,
    pos_pdesc => 4,
    pos_pp => 5,
    pos_rate => 6,
    pos_price => 7);

  my $domain = ViewSpreadsheets::Model::Domain->new(current_user => $ADMIN);
  $domain->create(
    name => "Dell - portables",
    filedesc => $filedesc->id,
  );

  my $version = ViewSpreadsheets::Model::Version->new(current_user => $ADMIN);
  $version->create(
    sdomain => $domain->id,
    filename => 'testfile_old.xls',
    start_date => '2009-09-01 00:00:00');
  $version->create(
    sdomain => $domain->id,
    filename => 'testfile_current.xls',
    start_date => '2009-09-01 00:00:00');
  $version->create(
    sdomain => $domain->id,
    filename => 'testfile_later.xls',
    start_date => '2019-09-01 00:00:00');
  $version->create(
    sdomain => $domain->id,
    filename => 'testfile.xls',
    );

  # And so on..
};

# You can also override some configuration settings:


1;
