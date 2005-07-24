package Posy::Plugin::MultiHeader;
use strict;

=head1 NAME

Posy::Plugin::MultiHeader - Posy plugin to enable multiple header templates.

=head1 VERSION

This describes version B<0.03> of Posy::Plugin::MultiHeader.

=cut

our $VERSION = '0.03';

=head1 SYNOPSIS

    @plugins = qw(Posy::Core
	...
	Posy::Plugin::MultiHeader
	...);

=head1 DESCRIPTION

This plugin enables the user to create additional 'header' flavour
templates besides the normal 'header' one.  These templates would be
called, for example, C<header1.html>, C<header2.html> and so on.

This is particularly useful in conjunction with L<Posy::Plugin::Info>, as
one can make multi-level headers which change depending on the sorted-by
.info fields.

This plugin replaces the 'header' action.

=head2 Cautions

This does not play well with 'footer' templates.

=head2 Configuration

This expects configuration settings in the $self->{config} hash,
which, in the default Posy setup, can be defined in the main "config"
file in the data directory.

=over

=item B<multi_header_max>

The maximum number of additional header levels to look for. (default: 0)
Set this to a number greater than zero to turn on this plugin.

=back

=cut

=head1 OBJECT METHODS

Documentation for developers and those wishing to write plugins.

=head2 init

Do some initialization; make sure that default config values are set.

=cut
sub init {
    my $self = shift;
    $self->SUPER::init();

    # set defaults
    $self->{config}->{multi_header_max} = 0
	if (!defined $self->{config}->{multi_header_max});
} # init

=head1 Entry Action Methods

Methods implementing per-entry actions.

=head2 header

$self->header($flow_state, $current_entry, $entry_state)

Calls the parent header method, then sets the additional
header content in @{$flow_state->{headers}}
and adds headers to the page body if they are different
to the previous header.

=cut
sub header {
    my $self = shift;
    my $flow_state = shift;
    my $current_entry = shift;
    my $entry_state = shift;

    if ($self->{config}->{multi_header_max} > 0)
    {
	my $header0 = $flow_state->{header}; # remember old header
	$self->SUPER::header($flow_state, $current_entry, $entry_state);

	if (!exists $flow_state->{headers})
	{
	    $flow_state->{headers} = [];
	}
	my %vars = $self->set_vars($flow_state, $current_entry, $entry_state);

	# if the 'header' has changed, then all lower headers must be displayed
	my $header_change = ($header0 ne $flow_state->{header});
	# iterate through the headers
	for (my $i=1; ($i - 1) < $self->{config}->{multi_header_max}; $i++)
	{
	    my $template = $self->get_template("header$i");
	    # give up if there aren't any
	    if (!defined $template)
	    {
		last;
	    }
	    my $header1 = $self->interpolate("header$i", $template, \%vars);
	    if ($header_change
		or $header1 ne $flow_state->{headers}->[$i])
	    {
		push @{$flow_state->{page_body}}, $header1;
		$flow_state->{headers}->[$i] = $header1;
		$header_change = 1;
	    }
	}
    }
    else
    {
	$self->SUPER::header($flow_state, $current_entry, $entry_state);
    }
    1;	
} # header

=head1 INSTALLATION

Installation needs will vary depending on the particular setup a person
has.

=head2 Administrator, Automatic

If you are the administrator of the system, then the dead simple method of
installing the modules is to use the CPAN or CPANPLUS system.

    cpanp -i Posy::Plugin::MultiHeader

This will install this plugin in the usual places where modules get
installed when one is using CPAN(PLUS).

=head2 Administrator, By Hand

If you are the administrator of the system, but don't wish to use the
CPAN(PLUS) method, then this is for you.  Take the *.tar.gz file
and untar it in a suitable directory.

To install this module, run the following commands:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install

Or, if you're on a platform (like DOS or Windows) that doesn't like the
"./" notation, you can do this:

   perl Build.PL
   perl Build
   perl Build test
   perl Build install

=head2 User With Shell Access

If you are a user on a system, and don't have root/administrator access,
you need to install Posy somewhere other than the default place (since you
don't have access to it).  However, if you have shell access to the system,
then you can install it in your home directory.

Say your home directory is "/home/fred", and you want to install the
modules into a subdirectory called "perl".

Download the *.tar.gz file and untar it in a suitable directory.

    perl Build.PL --install_base /home/fred/perl
    ./Build
    ./Build test
    ./Build install

This will install the files underneath /home/fred/perl.

You will then need to make sure that you alter the PERL5LIB variable to
find the modules.

Therefore you will need to change the PERL5LIB variable to add
/home/fred/perl/lib

	PERL5LIB=/home/fred/perl/lib:${PERL5LIB}

=head1 REQUIRES

    Posy
    Posy::Core

    Test::More

=head1 SEE ALSO

perl(1).
Posy

=head1 BUGS

Please report any bugs or feature requests to the author.

=head1 AUTHOR

    Kathryn Andersen (RUBYKAT)
    perlkat AT katspace dot com
    http://www.katspace.com

=head1 COPYRIGHT AND LICENCE

Copyright (c) 2005 by Kathryn Andersen

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Posy::Plugin::MultiHeader
__END__
