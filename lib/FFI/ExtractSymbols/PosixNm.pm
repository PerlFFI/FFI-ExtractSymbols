package FFI::ExtractSymbols::PosixNm;

use strict;
use warnings;
use FFI::ExtractSymbols::ConfigData;
use constant _function_prefix =>
  FFI::ExtractSymbols::ConfigData->config('function_prefix');
use constant _function_code =>
  FFI::ExtractSymbols::ConfigData->config('function_code');
use constant _data_prefix =>
  FFI::ExtractSymbols::ConfigData->config('data_prefix');
use constant _data_code =>
  FFI::ExtractSymbols::ConfigData->config('data_code');

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

*FFI::ExtractSymbols::extract_symbols = sub
{
  my($libpath, %callbacks) = @_;
  
  $callbacks{$_} ||= sub {} for qw( export code data );
  
  foreach my $line (`nm -g -P $libpath`)
  {
    next if $line =~ /^\s/;
    my($symbol, $type) = split /\s+/, $line;
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