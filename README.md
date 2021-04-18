# FFI::ExtractSymbols ![linux](https://github.com/PerlFFI/FFI-ExtractSymbols/workflows/linux/badge.svg) ![macos](https://github.com/PerlFFI/FFI-ExtractSymbols/workflows/macos/badge.svg) ![windows](https://github.com/PerlFFI/FFI-ExtractSymbols/workflows/windows/badge.svg) ![cygwin](https://github.com/PerlFFI/FFI-ExtractSymbols/workflows/cygwin/badge.svg) ![msys2-mingw](https://github.com/PerlFFI/FFI-ExtractSymbols/workflows/msys2-mingw/badge.svg)

Extract symbol names from a shared object or DLL

# SYNOPSIS

```perl
use FFI::ExtractSymbols;
use FFI::CheckLib;

my $libpath = find_lib( lib => 'foo' );

extract_symbols($libpath,
  code => sub {
    print "found a function called $_[0]\n";
  },
);
```

# DESCRIPTION

This module extracts the symbol names from a DLL or shared object.  The
method used depends on the platform.

# FUNCTIONS

## extract\_symbols

```perl
extract_symbols($lib,
  export => sub { ... },
  code   => sub { ... },
  data   => sub { ... },
);
```

Extracts symbols from the dynamic library (DLL on Windows, shared
library most other places) from the library and calls the given
callbacks. Each callback is called once for each symbol that matches
that type.  Each callback gets two arguments.  The first is the symbol
name in a form that can be passed into [FFI::Platypus#find\_symbol](https://metacpan.org/pod/FFI::Platypus#find_symbol),
[FFI::Platypus#function](https://metacpan.org/pod/FFI::Platypus#function) or [FFI::Platypus#attach](https://metacpan.org/pod/FFI::Platypus#attach).  The second is the
exact symbol name as it was extracted from the DLL or shared library.
On some platforms this will be prefixed by an underscore.  Some tools,
such as `c++filt` will require this version as input.  Example:

```perl
extract_symbols( 'libfoo.so',
  export => sub {
    my($symbol1, $symbol2) = @_;
    my $address   = $ffi->find_symbol($symbol1);
    my $demangled = `c++filt $symbol2`;
  },
);
```

- export

    All exported symbols, both code and data.

- code

    All symbols in the "text" section of the DLL or shared object.
    These are usually functions.

- data

    All symbols in the data section of the DLL or shared object.

# CAVEATS

This module _may_ work on static libraries and object files for some
platforms, but that usage is unsupported and may not be portable.

On windows, depending on the implementation available, this module may
not differentiate between code and data symbols.  In that case the
export and code callbacks will be called for both.

On many platforms extra symbols get lumped into DLLs and shared object
files so you should account for and ignore getting unexpected symbols
that you probably don't care about.

# SEE ALSO

- [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus)

    Write Perl bindings to non-Perl libraries without C or XS

- [FFI::CheckLib](https://metacpan.org/pod/FFI::CheckLib)

    Module for checking for the availability of dynamic libraries.

- [Parse::nm](https://metacpan.org/pod/Parse::nm)

    This module can parse the symbol names out of shared object files on
    platforms where `nm` works on those types of files.

    It does not work for Windows DLL files.  It also depends on
    [Regexp::Assemble](https://metacpan.org/pod/Regexp::Assemble) which appears to be unmaintained.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
