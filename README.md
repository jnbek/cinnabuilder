cinnabuilder
============
A Perl script to install Cinnamon and actively and well developed themes, applets and extensions for the Cinnamon Desktop in Arch Linux. 
Nice and clean version checking, and autopopulater for the Unofficial User Repository. Each package is built from the ArchLinux User Repositories (AUR) for Arch Linux 64 bit and 32 bit. Other packages include Hotot, Rhythmbox Tray Icon, Rhythmbox Equalizer Git Build, Hexchat, Insync, QBitTorrent and a number of GTK themes for use in the Cinnamon Desktop and some Perl Modules. Simply add to /etc/pacman.conf:

    [cinnamon]
    Server = http://archlinux.zoelife4u.org/cinnamon/$arch

And then run:

    yaourt -Syy

to load the repository. A cinnamon-meta package is available to allow mass installing all of the Cinnamon specific packages.

    yaourt -Sl cinnamon

displays the full list of packages available via this repostory.

(*) This requires both yaourt and package-query to function.
