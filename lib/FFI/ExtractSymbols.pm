package FFI::ExtractSymbols;

use strict;
use warnings;
use FFI::ExtractSymbols::ConfigData;
use base qw( Exporter );

our @EXPORT = qw( extract_symbols );

# ABSTRACT: Extract symbol names from a shared object or DLL
# VERSION

=head1 SYNOPSIS

 use FFI::ExtractSymbols;
 use FFI::CheckLib;
 
 my $libpath = find_lib( lib => 'foo' );
 
 extract_symbols($libpath,
   code => sub {
     print "found a function called $_[0]\n";
   },
 );

=head1 DESCRIPTION

This module extracts the symbol names from a DLL or shared object.  The 
method used depends on the platform.

=head1 FUNCTIONS

=head2 extract_symbols

 extract_symbols($lib,
   export => sub { ... },
   code   => sub { ... },
   data   => sub { ... },
 );

Extracts symbols from the dynamic library (DLL on Windows, shared 
library most other places) from the library and calls the given 
callbacks. Each callback is called once for each symbol that matches 
that type.  Each callback gets two arguments.  The first is the symbol 
name in a form that can be passed into L<FFI::Platypus#find_symbol>, 
L<FFI::Platypus#function> or L<FFI::Platypus#attach>.  The second is the 
exact symbol name as it was extracted from the DLL or shared library.  
On some platforms this will be prefixed by an underscore.  Some tools, 
such as C<c++filt> will require this version as input.  Example:

 extract_symbols( 'libfoo.so',
   export => sub {
     my($symbol1, $symbol2) = @_;
     my $address   = $ffi->find_symbol($symbol1);
     my $demangled = `c++filt $symbol2`;
   },
 );

=over 4

=item export

All exported symbols, both code and data.

=item code

All symbols in the "text" section of the DLL or shared object.
These are usually functions.

=item data

All symbols in the data section of the DLL or shared object.

=back

=head1 CAVEATS

This module I<may> work on static libraries and object files for some 
platforms, but that usage is unsupported and may not be portable.

Not all platforms support retrieving symbols from the data section.

On many platforms extra symbols get lumped into DLLs and shared object 
files so you should account for and ignore getting unexpected symbols 
that you probably don't care about.

=head1 SEE ALSO

=over 4

=item L<FFI::Platypus>

Write Perl bindings to non-Perl libraries without C or XS

=item L<Parse::nm>

This module can parse the symbol names out of shared object files on 
platforms where C<nm> works on those types of files.

It does not work for Windows DLL files.  It also depends on 
L<Regexp::Assemble> which appears to be unmaintained.

=back

=cut

if(FFI::ExtractSymbols::ConfigData->config('posix_nm'))
{
  require FFI::ExtractSymbols::PosixNm;
}

1;
