=item

=cut 
package pf::Authentication::Source::RADIUSSource;
use pf::Authentication::Source;
use Moose;

use pf::config qw($TRUE $FALSE);
use Authen::Radius;

extends 'pf::Authentication::Source';

has '+type' => ( default => 'RADIUS' );
has 'host' => (isa => 'Str', is => 'rw', required => 1);
has 'port' => (isa => 'Int', is => 'rw', required => 1);
has 'secret' => (isa => 'Str', is => 'rw', required => 1);

sub available_attributes {
  my $self = shift;
  my $super_attributes = $self->SUPER::available_attributes; 
  my $own_attributes = ["username"];
  return [@$super_attributes, @$own_attributes];
}

=item  authenticate

=cut
sub authenticate {

  my ( $self, $username, $password ) = @_;
  
  my $logger = Log::Log4perl->get_logger('pf::authentication');

  my $radius = new Authen::Radius(
 				  Host => "$self->{'host'}:$self->{'port'}", 
 				  Secret => $self->{'secret'},
 				 );
  
  if (defined $radius) {
     my $result = $radius->check_pwd($username, $password);
    
     if (Authen::Radius::get_error() eq 'ENONE') {
      
       if ($result) {
 	return ($TRUE, 'Successful authentication using RADIUS.');
      } else {
 	return ($FALSE, 'Invalid login or password');
       }
     }
   }

   $logger->error("Unable to perform RADIUS authentication on any server: " . Authen::Radius::get_error() );
  
   return ($FALSE, 'Unable to authenticate successfully using RADIUS.');
 }

=back

=head1 COPYRIGHT

Copyright (C) 2012 Inverse inc.

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

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start: