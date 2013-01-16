#!/usr/bin/perl -w

use strict;
use warnings;
use YAML;
use Data::Dumper;
use Getopt::Long;
my $s = bless {}, __PACKAGE__;
$s->main();

sub main {
    my $self = shift;
    #--no_skip builds all the packages regardless of if they have an upgrade.
    my ( $no_skip, $help, $do_repo_add,$force ) = '';
    my $is_forced = ' '; # This is stupid!!
    my $opts = GetOptions(
            "no_skip"     => \$no_skip,
            "do_repo_add" => \$do_repo_add,
            "force|f"     => \$force,
            "help|h"      => \$help,
        );
    return $self->usage if $help;
    if ($force) {
        $is_forced = "-f";
    }
    my $home              = $ENV{'HOME'};
    my $export_dir        = "$home/build/AUR";
    my $package_dir       = "$home/build/PACKAGES";
    my $repository_db     = "cinnamon.db";
    my $repository_db_tar = "$repository_db.tar.gz";
    my $dirref            = [ $export_dir, $package_dir ];
    foreach my $dir ( @{$dirref} ) {

        if ( !-d $dir ) {
            mkdir $dir, 0755 || die "Could not create $dir: $!";
        }
    }
    my $update_repos = system("/usr/bin/yaourt -Syy");
    my @aur_fail     = qw();
    my $pkg_file     = "packages.yaml";
    my $yaml         = do { local ( @ARGV, $/ ) = $pkg_file; <> };
    my $pkgs         = Load($yaml);
    print
      "Beginning Manual Packages First\n",
      "These require your input, changes etc to build.\n";

    foreach my $package ( @{ $pkgs->{'manual_pkgs'} } ) {
        my $current_aur   = $self->current_aur($package);
        my $current_local = $self->current_local($package);
        print "$package: AUR: $current_aur LOCAL: $current_local\n";
        next unless ( ($no_skip) || ( !$current_local || $current_aur gt $current_local ) );
        my $return = system("/usr/bin/yaourt -S $is_forced --export $export_dir $package");
        if ( $return != 0 ) {
            push @aur_fail, $package;
        }
    }
    foreach my $package ( @{ $pkgs->{'packages'} } ) {
        my $current_aur   = $self->current_aur($package);
        my $current_local = $self->current_local($package);
        print "$package: AUR: $current_aur LOCAL: $current_local\n";
        next unless ( $no_skip || ( !$current_local || $current_aur gt $current_local ) );
        my $return = system("/usr/bin/yaourt -S $is_forced --export $export_dir --noconfirm $package");
        if ( $return != 0 ) {
            push @aur_fail, $package;
        }
    }

    if ($do_repo_add) {
        chdir($export_dir);
        # cinnamon-theme-glass-60-1-any.pkg.tar.xz
        foreach my $tarball ( glob("*.pkg.tar.xz") ) {
            my $repo_add = system("/usr/bin/repo-add $repository_db_tar $tarball");
            rename $tarball, "$package_dir/$tarball";
            print "Moved: $tarball\n";
        }
        foreach my $db ( ( $repository_db, $repository_db_tar ) ) {
            rename $db, "$package_dir/$db";
            print "Moved: $db\n";
        }
    }
    else {
        chdir($export_dir);
        # cinnamon-theme-glass-60-1-any.pkg.tar.xz
        foreach my $tarball ( glob("*.pkg.tar.xz") ) {
            rename $tarball, "$package_dir/$tarball";
            print "Moved: $tarball\n";
        }
    }
    print "The following packages failed:\n";
    print Dumper( \@aur_fail );
}

sub current_aur {
    my $self    = shift;
    my $pkg     = shift;
    my $exec    = q#/usr/bin/package-query -A -f %V#;
    my $version = `$exec $pkg`;
    chomp $version;
    return $version;
}

sub current_local {
    my $self    = shift;
    my $pkg     = shift;
    my $exec    = q#/usr/bin/package-query -Q -f %v#;
    my $version = `$exec $pkg`;
    chomp $version;
    return $version;
}

sub usage {
    my $self = shift;
    my $spew = qq{
    Usage: $0
    Options:
        --no_skip:      Build all packages even if no upgrade is available
        --do_repo_add:  Execute repo_add in \$package_dir
        --force:        Pass along -f to yaourt --export to force package overwrite for same version.
        --help or -h:   Show this menu
    Example: $0 --no_skip --do_repo_add
    };
    print "$spew\n";
    return;
}
