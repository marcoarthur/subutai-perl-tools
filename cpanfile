requires 'perl', '5.010';
requires 'Moose', 'any';
requires 'Mojo::UserAgent', 'any';

# requires 'Some::Module', 'VERSION';

on test => sub {
    requires 'Test::More', '0.96';
};
