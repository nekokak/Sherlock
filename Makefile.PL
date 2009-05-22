use inc::Module::Install;
name 'Sherlock';
all_from 'lib/Sherlock.pm';

test_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
