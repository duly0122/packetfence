package pfappserver::Form::Field::Toggle;

=head1 NAME

pfappserver::Form::Field::Toggle - checkbox specific to PacketFence

=head1 DESCRIPTION

This field extends the default Checkbox. It is checked if the input
value matches (y|yes|true|enabled|1).

=cut

use Moose;
extends 'HTML::FormHandler::Field::Checkbox';
use namespace::autoclean;

=head1 DESCRIPTION

This field returns Y if true, N if false.

=cut

has '+checkbox_value' => ( default => 'Y' );
has '+inflate_default_method'=> ( default => sub { \&toggle_inflate } );

sub toggle_inflate {
    my ($self, $value) = @_;

    return 'N' unless ($value =~ m/^(y|yes|true|enabled|1)$/i);
    return 'Y';
}

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

__PACKAGE__->meta->make_immutable;
1;