package FFI::ExtractSymbols::OpenBSD;

use strict;
use warnings;
use File::Which qw( which );
use constant _function_code => 'T';
use constant _data_code     => 'B';

# ABSTRACT: OpenBSD nm implementation for FFI::ExtractSymbols
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

return 1 if FFI::ExtractSymbols->can('extract_symbols') || $^O ne 'openbsd';

my $nm = which('nm');
$nm = FFI::ExtractSymbols::ConfigData->config('exe')->{nm}
  unless defined $nm;

*FFI::ExtractSymbols::extract_symbols = sub
{
  my($libpath, %callbacks) = @_;
  
  $callbacks{$_} ||= sub {} for qw( export code data );
  
  foreach my $line (`$nm -g $libpath`)
  {
    next if $line =~ /^\s/;
    my(undef, $type, $symbol) = split /\s+/, $line;
    if($type eq _function_code)
    {
      $callbacks{export}->($symbol, $symbol);
      $callbacks{code}->  ($symbol, $symbol);
    }
    elsif($type eq _data_code)
    {
      $callbacks{export}->($symbol, $symbol);
      $callbacks{data}->  ($symbol, $symbol);      
    }
  }
  ();
};

1;
