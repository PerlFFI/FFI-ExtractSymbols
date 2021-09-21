package FFI::ExtractSymbols::Windows;

use strict;
use warnings;
use File::ShareDir::Dist ();
use File::Which qw( which );
use Path::Tiny;

my $config = File::ShareDir::Dist::dist_config('FFI-ExtractSymbols');

# ABSTRACT: Windows (and Cygwin) implementation for FFI::ExtractSymbols
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

return 1 if FFI::ExtractSymbols->can('extract_symbols') || $^O !~ /^(MSWin32|cygwin)$/;

$FFI::ExtractSymbols::mode = 'mixed';

#
my %sections;

*FFI::ExtractSymbols::extract_symbols = sub
{
  my($libpath, %callbacks) = @_;
  $callbacks{$_} ||= sub {} for qw( export code data );

  my $raw  = Path::Tiny->new($libpath)->slurp_raw;

  #
  return 1 if 0x5A4D != unpack 'v', substr $raw, 0, 2; # MZ signature failed
  my $peo = unpack 'V', substr $raw, 0x3C, 4;
  return 1 if "PE\0\0" ne substr $raw, $peo, 4; # PE signature failed

  #
  my ( $sizeOfOptionalHeader, undef, $magic ) = unpack 'vvv', substr $raw, $peo + 20, 8;
  return 1 if !$sizeOfOptionalHeader;    # No optional COFF and thus no exports
  my $pe32plus   = $magic == 0x20b;    # 32bit: Ox10b 64bit: 0x20b ROM?: 0x107
  my $opt_header = substr $raw, $peo + 24, $sizeOfOptionalHeader;

  # COFF header
  my $numberOfSections = unpack 'v', substr $raw, $peo + 6, 2;

  # Windows "optional" header
  my $imageBase = $pe32plus ? unpack 'Q', substr $opt_header, 24, 8 : unpack 'V',
    substr $opt_header, 28, 4;
  my $numberOfRVAandSizes = unpack 'V', substr $opt_header, ( $pe32plus ? 108 : 112 ), 4;
  {
    %sections = ();
    my $sec_begin = $peo + 24 + $sizeOfOptionalHeader;
    my $sec_data  = substr $raw, $sec_begin, $numberOfSections * 40;
    for my $x ( 0 .. $numberOfSections - 1 ) {
      my $sec_head = $sec_begin + ( $x * 40 );
      my $sec_name = unpack 'Z*', substr $raw, $sec_head, 8;
      $sections{$sec_name} = [ unpack 'VV VVVV vv V', substr $raw, $sec_head + 8 ];
    }
  }

  # dig into directory
  my ( $edata_pos, $edata_len ) = unpack 'VV', substr $opt_header, $pe32plus ? 112 : 96, 8;
  my @fields = unpack 'V10', substr $raw, _rva2offset($edata_pos), 40;
  my ( $ptr_func, $ptr_name, $ptr_ord ) = map { _rva2offset( $fields[$_] ) } 7 .. 9;
  my %retval = ( name => unpack 'Z*', substr $raw, _rva2offset( $fields[3] ), 256 );
  my @ord    = unpack 'V' x $fields[5], substr $raw, $ptr_func, 4 * $fields[5];

  for my $idx ( 0 .. $fields[5] ) {
    my $ord_cur  = unpack 'v', substr $raw, $ptr_ord + ( 2 * $idx ), 2;
    my $func_cur = $ord[$ord_cur];    # Match the ordinal to the function RVA
    next if $idx > ( $fields[6] - 1 );
    my $name_cur = unpack 'V',  substr $raw, $ptr_name + ( 4 * $idx ), 4;
    my $symbol = unpack 'Z*', substr $raw, _rva2offset($name_cur), 512;
    $ord_cur += $fields[4];           # Add the ordinal base value
    $callbacks{export}->($symbol, $symbol);
    $callbacks{code}  ->($symbol, $symbol);
  }
};

sub _rva2offset
{
  my ($virtual) = @_;
  for my $section ( values %sections ) {
    if ( ( $virtual >= $section->[1] ) and ( $virtual < $section->[1] + $section->[0] ) ) {
      return $virtual - ( $section->[1] - $section->[3] );
    }
  }
}

1;
