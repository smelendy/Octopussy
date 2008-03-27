#################### Octopussy Project ####################
# $Id$
###########################################################
=head1 NAME

Octopussy::Report::OpenDocument - Octopussy Report OpenDocument module

=cut

package Octopussy::Report::OpenDocument;

use strict;

#use OpenOffice::OODoc;
use Octopussy;

=head1 FUNCTIONS

=head2 Meta($doc)

=cut

sub Meta($)
{
	my $doc = shift;

	my $m = ooMeta(file => $doc);
	$m->title("toto");
	$m->description("Report generated by Octopussy. See http://www.8pussy.org");
}

=head2 Text($filename, $conf)

=cut

sub Text($$)
{
	my ($filename, $conf) = @_;

	my $doc = ooDocument(file => $filename, create => 'text');
	$doc->appendTable("Report Table", $#{$conf->{data}} + 2, 
		$#{$conf->{headers}} + 1);

	my ($x, $y) = (0,0);
	foreach my $f (@{$conf->{fields}})
	{
		$doc->cellValue("Report Table", $y, $x, "$conf->{headers}[$x]");
		$x++;
	}
	foreach my $line (@{$conf->{data}})
	{
		$x = 0;
		$y++;
		foreach my $f (@{$conf->{fields}})
		{
			if ($f =~ /^(\S+::\S+)\((\S+)\)$/)
    	{
      	my $data = (Octopussy::Plugin::Function_Source($1) eq "OUTPUT"
					? &{$1}($line->{$2}) : $line->{$2});
      	if (ref $data eq "ARRAY")
        {
        	foreach my $dat (@{$data})
         	{
						my $d = $dat;
						$d = "<a href=\"$1\">$1<\/a>" if ($d =~ /^(https*:\/\/.+)/);
						$doc->cellValue("Report Table", $y, $x, "$d\n");
          }
				}
       	elsif (defined $data)
       	{
					$data = "<a href=\"$1\">$1<\/a>"  if ($data =~ /^(https*:\/\/.+)/);
					$doc->cellValue("Report Table", $y, $x, $data);
        }
     	}
     	else
      {
				$doc->cellValue("Report Table", $y, $x, $line->{$f});
     	}
			$x++;
		}
	}
	#Meta($doc, { title => $conf->{title} });
	$doc->save;
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut