package FFI::ExtractSymbols::PosixNm;

use strict;
use warnings;
use File::Which qw( which );
use File::ShareDir::Dist ();
use constant ();

my $config = File::ShareDir::Dist::dist_config('FFI-ExtractSymbols');

# ABSTRACT: Posix nm implementation for FFI::ExtractSymbols
# VERSION

=head1 DESCRIPTION

Do not use this module directly.  Use L<FFI::ExtractSymbols>
instead.

=head1 SEE ALSO

=over 4

=item L<FFI::ExtractSymbols>

=item L<FFI::Platypus>

=back

=cut

return 1 if FFI::ExtractSymbols->can('extract_symbols');

my $nm = which('nm');
$nm = $config->{'exe'}->{nm}
  unless defined $nm;

if(my $prefix = $config->{'function_prefix'})
{
  my $re = qr{^$prefix};
  *_remove_code_prefix = sub {
    my $symbol = shift;
    $symbol =~ s{$re}{};
    $symbol;
  }
}
else
{ *_remove_code_prefix = sub { $_[0] } }

if(my $prefix = $config->{'data_prefix'})
{
  my $re = qr{^$prefix};
  *_remove_data_prefix = sub {
    my $symbol = shift;
    $symbol =~ s{$re}{};
    $symbol;
  }
}
else
{ *_remove_data_prefix = sub { $_[0] } }

*FFI::ExtractSymbols::extract_symbols = sub
{
  my($libpath, %callbacks) = @_;

  $callbacks{$_} ||= sub {} for qw( export code data );

  foreach my $line (`$nm -g -P -D $libpath`)
  {
    next if $line =~ /^\s/;
    my($symbol, $type) = split /\s+/, $line;
    if($type eq $config->{function_code} || $type eq 'W')
    {
      $callbacks{export}->(_remove_code_prefix($symbol), $symbol);
      $callbacks{code}->  (_remove_code_prefix($symbol), $symbol);
    }
    elsif($type eq $config->{data_code})
    {
      $callbacks{export}->(_remove_data_prefix($symbol), $symbol);
      $callbacks{data}->  (_remove_data_prefix($symbol), $symbol);
    }
  }
  ();
};

1;
