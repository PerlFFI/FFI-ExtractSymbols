use strict;
use warnings;
use Test::More tests => 1;
use FFI::ExtractSymbols::ConfigData;

diag '';
diag '';
diag '';

foreach my $key (sort qw( posix_nm function_prefix function_code data_prefix data_code ))
{
  diag sprintf "%-15s = %s", $key, FFI::ExtractSymbols::ConfigData->config($key);
}

diag '';

my %exe = %{ FFI::ExtractSymbols::ConfigData->config('exe') };

foreach my $key (keys %exe)
{
  diag sprintf "%-15s = %s", "exe.$key", ($exe{$key}||'~');
}

diag '';
diag '';


pass 'good stuff';
