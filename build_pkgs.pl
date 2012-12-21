#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper;
my $home        = $ENV{'HOME'};
my $export_dir  = "$home/build/AUR";
my $package_dir = "$home/build/PACKAGES";
my $dirref = [ $export_dir, $package_dir ];
foreach my $dir ( @{$dirref} ) {
      if ( !-d $dir ) {
          mkdir $dir, 0755 || die "Could not create $dir: $!";
      }
}
my @aur_fail     = qw();
my $archive_exts = [ 'tar.gz', 'zip', '7z', 'tar.bz2', 'deb', 'part' ];
my @manual_pkgs  = qw(
  cinnamon-applet-windows7-menu
  cinnamon-applet-recent
  cinnamon-applet-cpufreq
  cinnamon-theme-odin
  omg-cinnamon-theme
  omg-suite
);
my @packages = qw(
  muffin-wm
  nemo-fm
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
  cinnamon-theme-jelly-bean
  cinnamon-theme-lambda
  cinnamon-theme-loki
  cinnamon-theme-midnight
  cinnamon-theme-minty
  cinnamon-theme-minty-arch
  cinnamon-theme-nadia
  cinnamon-theme-nightlife
  cinnamon-theme-void
  delorean-dark-theme-3.6-g
  gtk-theme-gnome-cupertino
  elegant-brit-gtk3-theme
  gtk3-theme-miui
  gtk3-theme-sonar
  orta-gtk3-theme
  insync
);
#my $str = q!yaourt -Ss cinnamon | grep -v git | /usr/bin/perl -p -i -e 's/^.*\/(.*).+/$1/xs' | /bin/sed -e's/\s.*//'!;
#my $p = `$str`;
#my @packages = split(/\n/, $p);
print "Beginning Manual Packages First, These require your input, changes or something to build.\n";

foreach my $package (@manual_pkgs) {
      my $return = system("/usr/bin/yaourt -S --export $export_dir $package");
      if ( $return != 0 ) {
          push @aur_fail, $package;
      }
}
foreach my $package (@packages) {
      my $return = system("/usr/bin/yaourt -S --export $export_dir --noconfirm $package");
      if ( $return != 0 ) {
          push @aur_fail, $package;
      }
}

chdir($export_dir);
# cinnamon-theme-glass-60-1-any.pkg.tar.xz
foreach my $tarball ( glob("*.pkg.tar.xz") ) {
      rename $tarball, "$package_dir/$tarball";
      print "Moved: $tarball\n";
}
print "The following packages failed:\n";
print Dumper( \@aur_fail );