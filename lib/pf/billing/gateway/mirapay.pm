package pf::billing::gateway::mirapay;

=head1 NAME

pf::billing::gateway::mirapay - Object oriented module for billing purposes

=cut

=head1 DESCRIPTION

pf::billing::gateway::mirapay is a module that implements billing
functions using the Mirapay payment gateway.

=cut

use strict;
use warnings;

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use Readonly;
use Moo;
use pf::log;
use pf::billing::constants;
use pf::config;

our $VERSION = 1.00;

Readonly our $DELIMITER => ',';

=head1 SUBROUTINES

=over

=cut

=item new

Constructor

Create a new object for transactions using Authorize.net payment gateway

=cut

has transactionInfo => (is => 'rw');

sub BUILDARGS {
    my ( $class,$hashArgs) = @_;
    if(ref($hashArgs) eq 'HASH') {
        if (!exists $hashArgs->{transactionInfo} ) {
            return { transactionInfo => $hashArgs };
        } else {
            return $hashArgs;
        }
    }
    die "Invalid arguements";
}

sub new {
    my ( $class, $transaction_infos_ref ) = @_;
    my $logger = Log::Log4perl::get_logger(__PACKAGE__);

    $logger->debug("Instanciating a new " . __PACKAGE__ . " object");

    my $this = bless {
            # Transaction informations
            '_id'                   => undef,
            '_ip'                   => undef,
            '_mac'                  => undef,
            '_item'                 => undef,
            '_description'          => undef,
            '_price'                => undef,
            '_person'               => undef,

            # Client informations
            '_ccnumber'             => undef,
            '_ccexpiration'         => undef,
            '_ccverification'       => undef, #CVV_Code CV
            '_firstname'            => undef, #
            '_lastname'             => undef,
            '_email'                => undef,

    }, $class;

    foreach my $value ( keys %$transaction_infos_ref ) {
        $this->{'_' . $value} = $transaction_infos_ref->{$value};
    }

    return $this;
}

#TODO finish the processPayment workflow
=item processPayment
    Processes the payment request against the mirapay system
=cut

sub processPayment {
    my ( $self ) = @_;
    my $logger     = get_logger();
    my $request    = $self->makeRequest;
    my $useragent  = LWP::UserAgent->new(protocols_allowed=>["https"]);
    my $response   = $useragent->request($request);
    # There was an error processing the payment with the payment gateway
    if ( !$response->is_success ) {
        $logger->error("There was an error in the process of the payment: " . $response->status_line());
        return;
    }
    return $BILLING::SUCCESS;
}


=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2013 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;