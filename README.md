cinnabuilder
============
A Perl script to install Cinnamon and actively and well developed themes, applets and extensions for the Cinnamon Desktop in Arch Linux. 
Nice and clean version checking, and autopopulater for the Unofficial User Repository. Each package is built from the ArchLinux User Repositories (AUR) for Arch Linux 64 bit. Other packages include Hotot, Rhythmbox Tray Icon, Rhythmbox Equalizer Git Build, Hexchat, Insync and a number of GTK themes for use in the Cinnamon Desktop and some Perl Modules. Simply add to /etc/pacman.conf:

    [cinnamon]
    Server = http://archlinux.zoelife4u.org/cinnamon/x86_64

And then run:

    yaourt -Syy

to load the repository. A cinnamon-meta package will be coming along shortly to allow mass installing all of the Cinnamon specific packages.

This requires both yaourt and package-query to function.
