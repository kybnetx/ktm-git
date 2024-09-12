#!/usr/bin/perl
# vim: ts=4:sw=4:nu:fdc=1:nospell

use File::Path 'rmtree';

my $CAT = 'cat';
my $SED = 'sed';
my $CP = 'cp';
my $MV = 'mv';
my $FIND = 'find';
my $DOS2UNIX = 'dos2unix';
my $COMPRESS = 'java -jar yuicompressor-2.4.1.jar';

# catalyst application
my $APPNAME='katama';
# where to find it
my $CATALYSTPATH='../server/'.$APPNAME;
# server static subdirectory
my $STATICSUBDIR='static';
# extjs library
my $EXTJSPATH="$CATALYSTPATH/root/$STATICSUBDIR/extjs";
# should we remove debugging lines from library?
my $REMOVE_DEBUG = 1;

# temporary destination for processing
my $TEMP='temp';
my $TEMPORIG='temp/origfiles';

if (opendir(TEMP, $TEMP)) {
	closedir(TEMP);
	rmtree($TEMP);
}

mkdir($TEMP);
mkdir($TEMPORIG);

###################################################

# deployment destination path
my $DEPLOYDIR='/work/ktm/main/deploy';
# definition of server tree on disk
my $SRVROOT='srvroot';
# obligatory application root subdir (precede with slash!)
my $APPUIROOT='/root';
# optional subdir for ui files, images, etc. (precede with slash!)
my $APPSTATIC='/ui';
# appache conf ui application root location (precede with slash!)
my $SRVLOC='/ktm';

###################################################

rmtree($SRVROOT);
mkdir ($SRVROOT);
mkdir ($SRVROOT.$APPUIROOT);
$APPSTATIC && mkdir ($SRVROOT.$APPUIROOT.$APPSTATIC);

# images will be accessed through absolute paths 
my $SRVIMAGES="$APPSTATIC/images";
my $SRVIMAGESEXT="$APPSTATIC/images/extjs";

mkdir ($SRVROOT.$APPUIROOT.$SRVIMAGES);
mkdir ($SRVROOT.$APPUIROOT.$SRVIMAGESEXT);

### END of main path definitions ##################

my $verbose=1;
my $gencnt=1356;

# path replacements
my @PARE_CSS = ({
		# ext images accessed from subdir
		opath => '../extjs/resources/images',
		npath => $SRVLOC.$SRVIMAGESEXT
	}, {
		# app images accessed from subdir
		opath => '../images',
		npath => $SRVLOC.$SRVIMAGES
	}
);

my %PARE = (
	"/$STATICSUBDIR/extjs/resources/css/" => {
		css => [{
			# ext images accessed from ext css
			opath => '../images',
			npath => $SRVLOC.$SRVIMAGESEXT
		}]
	},
	"/$STATICSUBDIR/extjs.ux/" => {
		css => \@PARE_CSS,
	},
	"/$STATICSUBDIR/css/" => {
		css => \@PARE_CSS,
	},
	"/$STATICSUBDIR/" => {
		js => [{
			# ext images accessed from application
			opath => "/$STATICSUBDIR/extjs/resources/images",
			npath => $SRVLOC.$SRVIMAGESEXT
		}, {
			# app images accessed from application
			opath => "/$STATICSUBDIR/images",
			npath => $SRVLOC.$SRVIMAGES
		}]
	}
);

# ok, now get all the images here
system("$CP -a $CATALYSTPATH/root/$STATICSUBDIR/images/* ".$SRVROOT.$APPUIROOT.$SRVIMAGES);
system("$CP -a $EXTJSPATH/resources/images/* ".$SRVROOT.$APPUIROOT.$SRVIMAGESEXT);

# get perl application library
system("$CP -a $CATALYSTPATH/lib ".$SRVROOT);
system("$CP -a $CATALYSTPATH/script ".$SRVROOT);
system("$CP -a $CATALYSTPATH/*.yml ".$SRVROOT);
system("$CP -a $CATALYSTPATH/Makefile.PL ".$SRVROOT);

#print $ENV{'PWD'}.$SRVROOT; die;

# loop through index file
open (ININDEX, "< $CATALYSTPATH/root/index.html") || die;
open (OUTINDEX, "> $SRVROOT$APPUIROOT/index.html") || die;

my $last='empty';
my $opencomment=0;
my %current=(tag => '', rel => '', file => '', type => '', media => '');
my %merge=(files => '', attr => '');
my $newdest='';

while (<ININDEX>) {
	chomp;

	# get rid of the comments
	s/\w*<--.*?-->\w*//;
	/<--/ && ($opencomment=1);
	s/.*?-->\w*// && ($opencomment=0);
	$opencomment && next;

	# get rid of empty lines
	/^\w*$/ && next;

	# reset tag identifier only if it was realy closed
	if($current{tag} =~ /closed/) {
		$current{tag}=''; $current{rel}=''; $current{file}='';
		$current{type}=''; $current{media}='';
	}

	# the tags we want to recognise and modify
	/<\w*link\w*/ && ($current{tag}='open-link');
	/<\w*script\w*/ && ($current{tag}='open-script');

	# find out the type of tags
	if($current{tag} =~ /open/) {
		/type\w*=\w*"(.+?)"/ && ($current{type}=$1);
		/media\w*=\w*"(.+?)"/ && ($current{media}=$1);
		/rel\w*=\w*"(.+?)"/ && ($current{rel}=$1);
		/href\w*=\w*"(.+?)"/ && ($current{file}=$1);
		/src\w*=\w*"(.+?)"/ && ($current{file}=$1);
		# the tags get closed, adjust identifier;
		if(/\/\w*>/ || /<\w*\/\w*link\w*>/ || /<\w*\/\w*script\w*>/) {
			$current{tag} =~ s/open/closed/;
		}
	}

	# if previous tag(s) were of different type, finish their merge
	if(($last ne 'empty') && ($current{tag} !~ /$last/)) {
		$newdest='';
		if($last =~ /link/) {
			$newdest = getname('css');
			outit("\t<link $merge{attr} href=\"$SRVLOC$APPSTATIC/$newdest\" />");
		}
		elsif($last =~ /script/) {
			$newdest = getname('js');
			outit("\t<script src=\"$SRVLOC$APPSTATIC/$newdest\" $merge{attr} ></script>");
		}
		else {
			outit("### ERROR ###\n");
			die;
		}

		# exceptional hack to use proper library
		#################################################
		$merge{files} =~ s/ext-all-debug\.js/ext-all.js/;
		#################################################

		# first copy all original files here
		@srcfiles = split(' ', $merge{files});
		for $srcfile (@srcfiles) {
			system($CP, "$CATALYSTPATH/root/".$srcfile, $TEMPORIG);
		}

		processfiles($merge{files}, $newdest);

		# all is fine again
		$merge{files}='';
		$merge{attr}='';
		$last='empty';
	}

	# prepare for new tag if the current was finished
	if($current{tag} =~ /closed/) {
		$last = $current{tag};
		$last =~ s/closed-//;

		# merge only text files
		if($current{type} =~ /text/) {
			$merge{files} .= $current{file}." ";
			if(! $merge{attr}) {
				if($current{type} =~ /javascript/) {
					$merge{attr} = 'type="text/javascript"';
				}
				else {
					$merge{attr} = 'rel="stylesheet" type="text/css" media="all"';
				}
			}
		}

		# images get other treatment
		elsif($current{type} =~ /image/) {
			$current{file} =~ /\/([^\/]+?)$/;
			outit("\t<link rel=\"$current{rel}\" type=\"$current{type}\" href=\"$SRVLOC$SRVIMAGES/$1\" />");
			$last='empty';
		}
	}

	# the managed tags; no fall through
	if($current{tag} =~ /link|script/) {
		next;
	}

	outit($_);
}

close OUTINDEX;
close ININDEX;

# now remove comments from library files

if($REMOVE_DEBUG) {
	my $littlescript="filelist=`$FIND $SRVROOT/lib -name '*.pm'`; for file in \$filelist; do $SED '/#\\[\\[/,/#\\]\\]/d' \$file > \$file.out; mv \$file.out \$file ; done;";
	system("$littlescript");
	system("$SED \"s\#-Debug ##\" $SRVROOT/lib/$APPNAME.pm > $SRVROOT/lib/$APPNAME.pm.out");
	system("$MV $SRVROOT/lib/$APPNAME.pm.out $SRVROOT/lib/$APPNAME.pm");
}

# write appache config

open (APCONF, "> $APPNAME.conf") || die "Cannot write $APPNAME.conf\n";
print APCONF <<EOF;
PerlSwitches -I$DEPLOYDIR/$SRVROOT/lib

PerlModule $APPNAME

<Location $SRVLOC>
    SetHandler modperl
    PerlResponseHandler $APPNAME
</Location>

Alias $SRVLOC$APPSTATIC $DEPLOYDIR/$SRVROOT/root$APPSTATIC

<Location $SRVLOC$APPSTATIC>
    SetHandler default-handler
    AddOutputFilterByType DEFLATE text/javascript text/css
</Location>
EOF
close APCONF;

rmtree("$TEMP");

1;

sub outit() {
	my ($line) = @_;
	print OUTINDEX "$line\n";
	$verbose && print "$line\n";
}

sub getname() {
	my ($extension) = @_;
	$gencnt++;
	return 'servdpl'.$gencnt.'.'.$extension;
}

sub processfiles() {
	my ($mergefiles, $srvdest) = @_;

	my $newmergefiles = '';
	my @procfiles = split(' ', $mergefiles);

	for my $srcfilepath (@procfiles) {

		$srcfilepath =~ /(.+?\/)([^\/]+?)\.(css|js)$/;
		my ($srcpath, $file, $fext, $destpath) = ($1, $2, $3, "$TEMPORIG/$2.$3");
		$newmergefiles .= "$destpath ";

		system($DOS2UNIX, $destpath);

		#####################################################
		# exception file: ktm.js - adjust REST service prefix
		if("$file.$fext" =~ /ktm\.js/) {
			system("$SED \"s\#^[ \t]*ktm\.ASR[ ]*=[ ]*.*#ktm.ASR = '$SRVLOC';#\" $destpath > $destpath.out");
			system("$MV $destpath.out $destpath");
		}
		#####################################################

		# adjust image paths in css and js files
		if($PARE{$srcpath}{$fext}) {
			for my $repath ( @{$PARE{$srcpath}{$fext}} ) {
				system("$SED s\#$repath->{opath}#$repath->{npath}# $destpath > $destpath.out");
				system("$MV $destpath.out $destpath");
			}
		}
	}

	system("$CAT $newmergefiles > $TEMP/$srvdest");
	system("$COMPRESS -o $SRVROOT$APPUIROOT$APPSTATIC/$srvdest $TEMP/$srvdest");
}
