#!./miniperl -w
use strict;
use Config;

if (@ARGV) {
    my $dir = shift;
    chdir $dir or die "Can't chdir '$dir': $!";
}

# Note, the generated utils/Makefile isn't used by VMS yet.
# The next step on cleaning this is up is probably to work to reduce the size
# of the "problem" in both this file and vms/descrip_mms.template by
# attempting to move the work from them to the extension directories and
# ExtUtils::MakeMaker.

require 'regen/regen_lib.pl';

my $target = 'utils/Makefile';
print "Extracting $target (with variable substitutions)\n";
my $fh = open_new($target, undef, {by => $0}, 1);

# These use the Cwd extension.  For statically-built perls, we
# need perl, not just miniperl.
my $perl = defined $Config{usedl} ? '../miniperl' : '../perl';

print $fh <<"EOT";
PERL = $perl
REALPERL = ../perl
RUN =  # Used mainly cross-compilation setups.

EOT

print $fh <<'EOT';

# Files to be built with variable substitution after miniperl is
# available.  Dependencies handled manually below (for now).

pl = c2ph.PL corelist.PL cpan.PL h2ph.PL h2xs.PL instmodsh.PL perlbug.PL perldoc.PL perlivp.PL pl2pm.PL prove.PL splain.PL libnetcfg.PL piconv.PL enc2xs.PL encguess.PL xsubpp.PL pod2html.PL
plextract = c2ph corelist cpan h2ph h2xs instmodsh perlbug perldoc perlivp pl2pm prove splain libnetcfg piconv enc2xs encguess xsubpp pod2html
plextractexe = ./c2ph ./corelist ./cpan ./h2ph ./h2xs ./instmodsh ./perlbug ./perldoc ./perlivp ./pl2pm ./prove ./splain ./libnetcfg ./piconv ./enc2xs ./encguess ./xsubpp ./pod2html

all: $(plextract) 

$(plextract):
	$(RUN) $(PERL) -I../lib $@.PL

c2ph:		c2ph.PL ../config.sh

cpan:		cpan.PL ../config.sh

corelist:	corelist.PL ../config.sh

h2ph:		h2ph.PL ../config.sh

h2xs:		h2xs.PL ../config.sh

instmodsh:	instmodsh.PL ../config.sh

perlbug:	perlbug.PL ../config.sh ../patchlevel.h

perldoc:	perldoc.PL ../config.sh

perlivp:	perlivp.PL ../config.sh

prove:		prove.PL ../config.sh

pl2pm:		pl2pm.PL ../config.sh

splain:		splain.PL ../config.sh ../lib/diagnostics.pm

libnetcfg:	libnetcfg.PL ../config.sh

piconv:		piconv.PL ../config.sh

enc2xs:		enc2xs.PL ../config.sh

enc2xs:		encguess.PL ../config.sh

xsubpp:		xsubpp.PL ../config.sh

pod2html:	pod2html.PL ../config.sh ../ext/Pod-Html/bin/pod2html

clean:

realclean:
	rm -rf $(plextract) pstruct $(plextractexe)
	rm -f ../t/_h2ph_pre.ph

clobber:	realclean

distclean:	clobber

veryclean:	distclean
	-rm -f *~ *.org
EOT

read_only_bottom_close_and_rename($fh);
