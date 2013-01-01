#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
my $s = bless {}, __PACKAGE__;
$s->main();

sub main {
    my $self = shift;
    #--no_skip builds all the packages regardless of if they have an upgrade.
    my ( $no_skip, $help, $do_repo_add ) = '';
    my $opts = GetOptions(
        "no_skip"     => \$no_skip,
        "do_repo_add" => \$do_repo_add,
        "help|h"      => \$help,
    );
    return $self->usage if $help;
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
    my $update_repos = system( "/usr/bin/yaourt -Syy" );
    my @aur_fail = qw();
    #Removed: cinnamon-applet-recent
    my @manual_pkgs = qw(
      nemo-fm
      cinnamon-applet-windows7-menu
    );
    my @packages = qw(
      disper
      gpaste-daemon
      ttf-roboto
      libdbusmenu
      libdbusmenu-gtk3
      libindicator3
      libappindicator3
      muffin-wm
      cinnamon
      cinnamon-applet-better-places
      cinnamon-applet-better-settings
      cinnamon-applet-brightness
      cinnamon-applet-classicmenu
      cinnamon-applet-cpufreq
      cinnamon-applet-display-switcher
      cinnamon-applet-gpaste
      cinnamon-applet-hardware-monitor
      cinnamon-applet-iconized-window-list
      cinnamon-applet-informative-sound
      cinnamon-applet-messaging-menu
      cinnamon-applet-path-monitor
      cinnamon-applet-places
      cinnamon-applet-restart
      cinnamon-applet-screenlocker
      cinnamon-applet-screensaver-inhibit
      cinnamon-applet-screenshot-record
      cinnamon-applet-shutdown
      cinnamon-applet-sysmenu
      cinnamon-applet-system-monitor
      cinnamon-applet-timer-with-notifications
      cinnamon-applet-titlebar
      cinnamon-applet-touchpad
      cinnamon-applet-touchpad-classic
      cinnamon-applet-usermenu
      cinnamon-applet-vbox-launcher
      cinnamon-applet-weather
      cinnamon-applet-window-buttons
      cinnamon-applet-windows-preview
      cinnamon-extension-cinnadock
      cinnamon-extension-coverflow-alt-tab
      cinnamon-extension-desktop-scroller
      cinnamon-extension-maximus-cinnamon
      cinnamon-extension-temp
      cinnamon-extension-win7-alt-tab
      cinnamon-theme-ambiance
      cinnamon-theme-baldr
      cinnamon-theme-cinnamint
      cinnamon-theme-eleganse
      cinnamon-theme-elementary-luna
      cinnamon-theme-faience
      cinnamon-theme-faience+
      cinnamon-theme-glass
      cinnamon-theme-google+
      cinnamon-theme-lambda
      cinnamon-theme-loki
      cinnamon-theme-midnight
      cinnamon-theme-minty
      cinnamon-theme-minty-arch
      cinnamon-theme-nadia
      cinnamon-theme-nightlife
      cinnamon-theme-void
      cinnamon-theme-odin
      omg-cinnamon-theme
      omg-suite
      delorean-dark-theme-3.6-g
      gtk-theme-gnome-cupertino
      gtk3-theme-miui
      orta-gtk3-theme
      gtk-theme-boje
      gtk-theme-plastiq
      gtk-theme-metagrip
      insync
      hotot-data
      hotot-gtk3
      perl-template-alloy
      perl-cgi-ex
      qbittorrent
      rhythmbox-tray-icon
      rhythmbox-equalizer-git
      hexchat
      cinnamon-meta
    );
    #cinnamon-theme-jelly-bean
    print
      "Beginning Manual Packages First\n",
      "These require your input, changes etc to build.\n";

    foreach my $package (@manual_pkgs) {
        my $current_aur   = $self->current_aur($package);
        my $current_local = $self->current_local($package);
        print "$package: AUR: $current_aur LOCAL: $current_local\n";
        next unless ( ($no_skip) || ( !$current_local || $current_aur gt $current_local ) );
        my $return = system( "/usr/bin/yaourt -S --export $export_dir $package" );
        if ( $return != 0 ) {
            push @aur_fail, $package;
        }
    }
    foreach my $package (@packages) {
        my $current_aur   = $self->current_aur($package);
        my $current_local = $self->current_local($package);
        print "$package: AUR: $current_aur LOCAL: $current_local\n";
        next unless ( $no_skip || ( !$current_local || $current_aur gt $current_local ) );
        my $return = system( "/usr/bin/yaourt -S --export $export_dir --noconfirm $package" );
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
        --help or -h:   Show this menu
    Example: $0 --no_skip --do_repo_add
    };
    print "$spew\n";
    return;
}
