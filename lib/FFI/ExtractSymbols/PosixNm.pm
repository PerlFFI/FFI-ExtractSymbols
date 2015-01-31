package FFI::ExtractSymbols::PosixNm;

use strict;
use warnings;

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
};

1;
